-- Function: public.f_scr_set_obs_ctrc_2(json)
/*

UPDATE scr_conhecimento SET id_conhecimento = id_conhecimento WHERE tipo_imposto = 13
SELECT f_scr_set_obs_ctrc_2(row_to_json(scr_conhecimento,true)), calculado_de_uf, data_digitacao FROM scr_conhecimento WHERE tipo_imposto IN (13)


*/
-- DROP FUNCTION public.f_scr_set_obs_ctrc_2(json);

CREATE OR REPLACE FUNCTION public.f_scr_set_obs_ctrc_2(rconhecimento json)
  RETURNS text AS
$BODY$
DECLARE
        --Função que seta as observações no conhecimento 
        vIdObservacao 	integer;
        vObservacao 	text;        
        vRegimeTributario integer;
        vAliquotaSimples numeric(7,2);
        vTotalFrete numeric(12,2);
        vImpostoSimples numeric(10,2);        
        vObservacoes text;   

        vProprietario text;     
        vMotorista text;
        vCertNegativa text;
        
BEGIN   
	--RAISE NOTICE 'Iniciando';
	vObservacoes = '';	

	RAISE NOTICE 'Tipo Imposto %', (rConhecimento->>'tipo_imposto')::integer;
	--DELETE FROM scr_conhecimento_obs WHERE id_conhecimento = (rConhecimento->>'id_conhecimento')::integer;
	IF (rConhecimento->>'tipo_imposto')::integer = 14 THEN 

		RAISE NOTICE 'Tipo Imposto 14';
		
		vObservacao = '';
		
		SELECT	trim(fornecedores.nome_razao) || ' CNPJ\CPF: ' || cnpj_cpf(fornecedores.cnpj_cpf)
		INTO 	vProprietario 
		FROM 	veiculos
			LEFT JOIN fornecedores 
				ON veiculos.id_proprietario::integer = fornecedores.id_fornecedor
		WHERE 
			veiculos.placa_veiculo = rConhecimento->>'placa_veiculo';


		
		SELECT	trim(fornecedores.nome_razao) || ' CPF: ' || cnpj_cpf(fornecedores.cnpj_cpf)
		INTO 	vMotorista 
		FROM 	fornecedores 			
		WHERE 
			fornecedores.id_fornecedor = (rConhecimento->>'id_motorista')::integer;


		SELECT 
			(
				'Nr. ' 
				|| trim(ecn.numero_certidao) 
				|| ' CODIGO DE AUTENTICIDADE Nr. ' 
				|| trim(ecn.codigo_autenticidade) 
				|| ', VALIDADE ' 
				|| to_char(ecn.data_validade,'DD/MM/YYYY')
				|| ';'
			)
		INTO
			vCertNegativa
		FROM 
			estado uf
			LEFT JOIN estado_certidoes_negativas ecn
				ON ecn.id_estado = uf.id_estado_pk
		WHERE 
			uf.id_estado = rConhecimento->>'calculado_de_uf'
			AND (rConhecimento->>'data_digitacao')::date >= ecn.data_vigencia 
			AND (rConhecimento->>'data_digitacao')::date <= ecn.data_validade;


		
		--IF vCertNegativa IS NOT NULL AND vMotorista IS NOT NULL AND vProprietario IS NOT NULL THEN 
			vObservacao = 'FRETE PAGO, MERCADORIA COM CLAUSULA CIF, ICMS DO FRETE DISPENSADO CONFORME PORTARIA 47/2000; TRANSPORTE SUBCONTRATADO; '
			|| COALESCE('PROPRIETARIO DO VEICULO:VAMOS SEMINOVOS; ' || vProprietario || ';','')
			|| COALESCE('MOTORISTA: ' || vMotorista || ';','') 
			|| COALESCE('PLACA: ' || trim((rConhecimento->>'placa_veiculo')::text) || '; ','')
			|| COALESCE('CERTIDAO NEGATIVA DE DEBITO ' || vCertNegativa, '');
		--END IF;

		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');

		RAISE NOTICE 'Observação %', vObservacao;
		--'Nº 0033829601, CODIGO DE AUTENTICIDADE Nº TKAA2AK2TA9LU279, VALIDADE 30/10/2021.
		
	END IF;
	
	IF (rConhecimento->>'tipo_imposto')::integer = 13 THEN 

		vObservacao = '';

		SELECT	trim(fornecedores.nome_razao) || ' CNPJ\CPF: ' || cnpj_cpf(fornecedores.cnpj_cpf)
		INTO 	vProprietario 
		FROM 	veiculos
			LEFT JOIN fornecedores 
				ON veiculos.id_proprietario::integer = fornecedores.id_fornecedor
		WHERE 
			veiculos.placa_veiculo = rConhecimento->>'placa_veiculo';


		SELECT	trim(fornecedores.nome_razao) || ' CPF: ' || cnpj_cpf(fornecedores.cnpj_cpf)
		INTO 	vMotorista 
		FROM 	fornecedores 			
		WHERE 
			fornecedores.id_fornecedor = (rConhecimento->>'id_motorista')::integer;


		SELECT 
			(
				'Nr. ' 
				|| trim(ecn.numero_certidao) 
				|| ' CODIGO DE AUTENTICIDADE Nr. ' 
				|| trim(ecn.codigo_autenticidade) 
				|| ', VALIDADE ' 
				|| to_char(ecn.data_validade,'DD/MM/YYYY')
				|| ';'
			)
		INTO
			vCertNegativa
		FROM 
			estado uf
			LEFT JOIN estado_certidoes_negativas ecn
				ON ecn.id_estado = uf.id_estado_pk
		WHERE 
			uf.id_estado = rConhecimento->>'calculado_de_uf'
			AND (rConhecimento->>'data_digitacao')::date >= ecn.data_vigencia 
			AND (rConhecimento->>'data_digitacao')::date <= ecn.data_validade;


		--RAISE NOTICE 'Certidao % Motorista % Proprietario %', vCertNegativa, vMotorista, vProprietario;
		
		--IF vCertNegativa IS NOT NULL AND vMotorista IS NOT NULL AND vProprietario IS NOT NULL THEN 
		
			vObservacao = 'ICMS DO FRETE DIFERIDO CONFORME INCISO XIII DO ART.37, ANEXO 7° RTCE-MT; TRANSPORTE SUBCONTRATADO; '
			|| COALESCE('PROPRIETARIO DO VEICULO:VAMOS SEMINOVOS; ' || vProprietario || '; ','')
			|| COALESCE('MOTORISTA: ' || vMotorista || ';','') 
			|| COALESCE('PLACA: ' || trim((rConhecimento->>'placa_veiculo')::text) || '; ','')
			|| COALESCE('CERTIDAO NEGATIVA DE DEBITO ' || vCertNegativa, '');

			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
			
		--END IF;

					
		
		
	END IF;


	-- Tipo do Transporte
	IF (rConhecimento->>'tipo_transporte')::integer IN (2,3,12,20,21) THEN 

		CASE WHEN rConhecimento->>'tipo_transporte' = '2' THEN 
			vIdObservacao = 4;
			
		     WHEN rConhecimento->>'tipo_transporte' = '3' THEN
			vIdObservacao = 5;
			
		     WHEN rConhecimento->>'tipo_transporte' = '12' THEN
			vIdObservacao = 6;
			
		     WHEN rConhecimento->>'tipo_transporte' = '20' THEN
			vIdObservacao = 7;
			
		     WHEN rConhecimento->>'tipo_transporte' = '21' THEN
			vIdObservacao = 8;
				
		     ELSE
		     
		END CASE;       

		SELECT format(observacao,COALESCE(rConhecimento->>'conhecimento_origem',''))
		INTO vObservacao 
		FROM scr_conhecimento_obs_template		
		WHERE id_observacao = vIdObservacao;
		
		--INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)
		--VALUES ((rConhecimento->>'id_conhecimento')::integer, vIdObservacao, vObservacao);					
		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		
	END IF;

	
	-- Regime Tributário Simples
	IF trim(rConhecimento->>'total_frete') = '' THEN 
		vTotalFrete = 0;
	ELSE 
		vTotalFrete = (rConhecimento->>'total_frete')::numeric(12,2);
	END IF;

	 
	IF  vTotalFrete > 0.00 THEN 
		
		-- Busca os parâmetros para determinar a imposto
		SELECT 	regime_tributario, aliquota_icms_simples 
		INTO 	vRegimeTributario, vAliquotaSimples
		FROM    filial
		WHERE 	codigo_empresa = rConhecimento->>'empresa_emitente' 
			AND codigo_filial = rConhecimento->>'filial_emitente';

		-- Se os parâmetros não estão nulos		
		IF COALESCE(vRegimeTributario,vAliquotaSimples,0) IS NOT NULL AND vRegimeTributario = 1 THEN
			vImpostoSimples = (vTotalFrete * vAliquotaSimples)/100;

			SELECT 	format(observacao, vImpostoSimples, vAliquotaSimples) 
			INTO 	vObservacao 
			FROM 	scr_conhecimento_obs_template		
			WHERE 	id_observacao = 1;		

			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
			-- INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)
-- 			VALUES ((rConhecimento->>'id_conhecimento')::integer, 1, vObservacao);
		END IF;	
		
		IF current_database() = 'softlog_medilog' THEN
			vObservacoes = vObservacoes || '/' 
			|| format('TOTAL IMPOSTOS INCIDENTES 15,90%% VALOR %s CONF.LEI 12.741/2012. PIS 0,65%% COFINS 3,00%%',
				replace( (vTotalFrete * 0.1590)::numeric(12,2)::text,'.',','));
		END IF;
	END IF;

	

	-- CIF a vista 
	IF rConhecimento->>'avista' = '1' AND rConhecimento->>'cif_fob' = '1' THEN 
		SELECT observacao 
		INTO vObservacao 
		FROM scr_conhecimento_obs_template		
		WHERE id_observacao = 3;	
		
		-- INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)		
-- 		VALUES ((rConhecimento->>'id_conhecimento')::integer, 3, vObservacao);		
		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');	

	END IF;
	
	-- Fob a vista	
	IF rConhecimento->>'avista' = '1' AND rConhecimento->>'cif_fob' = '2' THEN 
		SELECT observacao 
		INTO vObservacao 
		FROM scr_conhecimento_obs_template		
		WHERE id_observacao = 2;	
				
		-- INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)
		-- VALUES ((rConhecimento->>'id_conhecimento')::integer, 2, vObservacao);
		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
	END IF;

	
	--Isenção do tipo de transporte de Exportação
	IF rConhecimento->>'cod_operacao_fiscal' = '7358' THEN 
		SELECT 	observacao,rConhecimento
		INTO 	vObservacao 
		FROM 	scr_conhecimento_obs_template		
		WHERE 	id_observacao = 10;

-- 		INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)
-- 		VALUES ((rConhecimento->>'id_conhecimento')::integer, 10, vObservacao);
		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
	END IF;
	
	
	-- Observacoes Fisco UF
	IF rConhecimento->>'tipo_imposto' IN ('1') THEN 	
		SELECT 	obs_fisco_uf
		INTO 	vObservacao
		FROM 	estado
		WHERE 	id_estado = rConhecimento->>'calculado_de_uf';		

		IF vObservacao IS NOT NULL THEN
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	
	END IF;	

	--Observacoes no cadastro de estado para operacao interna
	IF rConhecimento->>'tipo_imposto' IN ('1') 
		AND rConhecimento->>'calculado_de_uf' = rConhecimento->>'calculado_ate_uf' 
	THEN 	

		SELECT 	obs_fiscal_interna
		INTO 	vObservacao
		FROM 	estado
		WHERE 	id_estado = rConhecimento->>'calculado_de_uf';		

		IF vObservacao IS NOT NULL THEN
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	
	END IF;	

	--Observacoes no cadastro de estado para operacao interestadual
	IF rConhecimento->>'tipo_imposto' IN ('1') 
		AND rConhecimento->>'calculado_de_uf' <> rConhecimento->>'calculado_ate_uf' 
	THEN 	

		SELECT 	obs_fiscal_interna
		INTO 	vObservacao
		FROM 	estado
		WHERE 	id_estado = rConhecimento->>'calculado_de_uf';		

		IF vObservacao IS NOT NULL THEN
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	
	END IF;		

	-- Observacoes Fisco UF Interno
	IF rConhecimento->>'tipo_imposto' IN ('1') THEN 	
		SELECT 	obs_fisco_uf
		INTO 	vObservacao
		FROM 	estado
		WHERE 	id_estado = rConhecimento->>'calculado_de_uf';		

		IF vObservacao IS NOT NULL THEN
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	
	END IF;	


	IF COALESCE(rConhecimento->>'placa_veiculo','') <> '' THEN 
	
		SELECT 
			CASE WHEN tipo_frota <> 1 THEN
			'TRANSPORTE SUBCONTRATADO COM: ' || trim(proprietario.nome_razao) ||
			', PROPRIETARIO DO VEICULO: ' || trim(vm.nome_marca) || ' ' || trim(vmo.descricao_modelo) ||
			', PLACA: ' || v.placa_veiculo || ', RENAVAM: ' || v.renavan || ', UF: ' || c.uf
			ELSE
				''
			END::text as obs
		INTO 
			vObservacao
		FROM 
			veiculos v
			LEFT JOIN fornecedores proprietario
				ON proprietario.id_fornecedor = v.id_proprietario
			LEFT JOIN veiculos_marcas vm 
				ON vm.id_marca_veiculo = v.id_marca
			LEFT JOIN veiculos_modelos vmo
				ON vmo.id_modelo_veiculo = v.id_modelo
			LEFT JOIN cidades c
				ON c.id_cidade = v.id_cidade_veiculo
		WHERE
			tipo_frota <> 1
			AND placa_veiculo = rConhecimento->>'placa_veiculo';

		IF vObservacao IS NOT NULL THEN
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	

	END IF;
	
	-- Tipo Imposto 
	IF rConhecimento->>'tipo_imposto' IN ('2','5') THEN 
		CASE WHEN rConhecimento->>'tipo_imposto' = '2' 	THEN 
			vIdObservacao = 9;		
				
		     WHEN rConhecimento->>'tipo_imposto' = '5' 	THEN
			vIdObservacao = 10;			
		     ELSE
		END CASE; 

		SELECT 	observacao,rConhecimento
		INTO 	vObservacao 
		FROM 	scr_conhecimento_obs_template		
		WHERE 	id_observacao = vIdObservacao;

-- 		INSERT INTO scr_conhecimento_obs (id_conhecimento, id_observacao, observacao)
-- 		VALUES ((rConhecimento->>'id_conhecimento')::integer, vIdOBservacao, vObservacao);
		IF vIdObservacao = 9 AND rConhecimento->>'calculado_de_uf' = 'MG' THEN 
			vObservacoes = vObservacoes || '/' || 'Isento de ICMS conforme Item 144 do Anexo I do RICMS/MG';
		ELSE
			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;
	
	END IF ;

	-- Observacoes Fisco UF
	IF rConhecimento->>'tipo_imposto' IN ('6','7','8') THEN	
		IF rConhecimento->>'calculado_de_uf' = 'GO' AND COALESCE((rConhecimento->>'data_emissao'::text)::date,CURRENT_DATE::date)::date >= '2016-11-01'::date THEN
			vObservacoes = vObservacoes || '/O RECOLHIMENTO DO ICMS E DE RESPONSABILIDADE DO REMETENTE DA MERCADORIA, NA FORMA DO ART. 17-A, DO ANEXO VIII, DO RCTE-GO/';
		ELSE
			SELECT 	observacao,rConhecimento
			INTO 	vObservacao 
			FROM 	scr_conhecimento_obs_template	
			WHERE 	id_observacao = 11;

			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');
		END IF;	
	END IF;	
	
	-- Implementar mensagem do peso cubado.	
	IF (rConhecimento->>'calculo_difal')::integer = 1 THEN 
		RAISE NOTICE 'Calculo Difal';
		BEGIN 
			SELECT 	format(observacao, 
					(rConhecimento->>'base_calculo_difal')::numeric(12,2),
					(rConhecimento->>'aliquota_fcp')::numeric(12,2),
					(rConhecimento->>'aliq_icms_interna')::numeric(12,2),
					(rConhecimento->>'aliq_icms_inter')::numeric(12,2),
					(
						(
							(rConhecimento->>'difal_icms_destino')::numeric(12,2)/
							(
								(rConhecimento->>'difal_icms_origem')::numeric(12,2)+
								(rConhecimento->>'difal_icms_destino')::numeric(12,2)
							)
								
						)*100
					)::numeric(12,2),
					(rConhecimento->>'valor_fcp')::numeric(12,2),
					(rConhecimento->>'difal_icms_destino')::numeric(12,2),
					(rConhecimento->>'difal_icms_origem')::numeric(12,2)
				) 
			INTO 	vObservacao 
			FROM 	scr_conhecimento_obs_template		
			WHERE 	id_observacao = 14;		

			vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');		
		EXCEPTION 		
			WHEN others THEN
				RAISE NOTICE 'Erro Calculo Difal';
				vObservacoes = vObservacoes;
		END; 
	END IF;


	SELECT texto_observacao
	INTO vObservacao 
	FROM cliente 
	WHERE exige_observacao = 1 AND codigo_cliente = (rConhecimento->>'consig_red_id')::integer;

	IF vObservacao IS NOT NULL THEN 
		vObservacoes = vObservacoes || '/' || ltrim(vObservacao,'/');		
	END IF;
	
        RETURN vObservacoes;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

