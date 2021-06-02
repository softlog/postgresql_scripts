-- Function: f_manifesto_automatico()

-- DROP FUNCTION f_viagem_automatica();

CREATE OR REPLACE FUNCTION f_tgg_manifesto_automatico()
  RETURNS trigger AS
$BODY$
DECLARE 
	--Do romaneio para o conhecimento
	vExisteManifesto integer;
	vCursor refcursor;
	vNumeroChave integer;
	vNumeroManifesto character(13);
	vTipoFrota integer;
	vIdProprietario integer;
	vNumero_tabela_motorista character(13);
	vIdManifesto integer;	
	vDataNota timestamp;
	vIdMotorista integer;
	vCpfMotorista character(14);
	vCnpjProprietario character(14);
	vPlacaVeiculo character(7);
	vDataEmissao date;
	vIdOrigem integer;
	vIdDestino integer;
	vCapacidadeCubica numeric(8,3);
	vCapacidadeTonelada numeric(8,2);

	-----------------------------------
	v_id_calculado_de_id_cidade
	
BEGIN

-- 	OPEN vCursor FOR 
-- 		SELECT MAX(data_nota_fiscal) FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = NEW.id_conhecimento;
-- 
-- 	FETCH vCursor INTO vDataNota;
-- 
-- 	IF NOT FOUND THEN 
-- 		RETURN NULL;
-- 	END IF;
	
-- 	CLOSE vCursor;

	IF NEW.id_manifesto IS NOT NULL THEN 
		RETURN NEW;
	END IF;
 	
	IF NEW.flg_manifesto = 1 AND NEW.id_motorista IS NOT NULL AND NEW.placa_veiculo IS NOT NULL AND NEW.empresa_emitente IS NOT NULL AND NEW.filial_emitente IS NOT NULL AND NEW.data_emissao IS NOT NULL
	THEN 


		vIdMotorista := NEW.id_motorista;
		vPlacaVeiculo := NEW.placa_veiculo;
		vIdOrigem := NEW.calculado_de_id_cidade;
		vIdDestino := NEW.calculado_ate_id_cidade;
		vDataEmissao := NEW.data_emissao;
		
		--Verifica se existe viagem aberta
		--     Para determinado motorista, determinado veiculo, determinado dia, determinada região de origem, determinada região de destino
-- 		OPEN vCursor FOR 
-- 			SELECT 	count(*) as qt_viagem 
-- 			FROM 	scr_romaneios
-- 				LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
-- 				LEFT JOIN regiao_cidades reg_origem_ct ON reg_origem_ct.id_cidade = NEW.calculado_de_id_cidade
-- 				LEFT JOIN regiao_cidades reg_destino_ct ON reg_destino_ct.id_cidade = NEW.calculado_ate_id_cidade
-- 				LEFT JOIN regiao_cidades reg_origem_rom ON reg_origem_rom.id_cidade = scr_romaneios.id_origem
-- 				LEFT JOIN regiao_cidades reg_destino_rom ON reg_destino_rom.id_cidade = scr_romaneios.id_destino				
-- 			WHERE 	
-- 				id_motorista = NEW.id_motorista
-- 				AND placa_veiculo = NEW.placa_veiculo
-- 				AND data_romaneio::date = vDataNota
-- 				AND reg_origem_ct.id_regiao = reg_origem_rom.id_regiao
-- 				AND reg_destino_ct.id_regiao = reg_destino_rom.id_regiao;
				
-- 		FETCH vCursor INTO vExiste_viagem;
-- 
-- 		CLOSE vCursor;
-- 		
		--Se não existe Viagem, cria a viagem
		vExisteManifesto := 0;
		
		IF vExisteManifesto = 0 THEN 

			--Constroi Numero da Viagem
			OPEN vCursor FOR SELECT proximo_numero_sequencia('scr_manifesto_'  || trim(NEW.empresa_emitente) || '_' || trim(NEW.filial_emitente));

			FETCH vCursor INTO vNumeroChave;

			CLOSE vCursor;
		
			vNumeroManifesto = NEW.empresa_emitente || NEW.filial_emitente || TRIM(to_char(vNumeroChave,'0000000'));


			--Recupera o id e o Cnpj_CPF do Proprietario
			OPEN vCursor FOR
				SELECT 
					fornecedores.id_fornecedor,
					fornecedores.cnpj_cpf
				FROM 
					veiculos
					LEFT JOIN fornecedores ON veiculos.id_proprietario = fornecedores.id_fornecedor
				WHERE placa_veiculo = NEW.placa_veiculo;

			FETCH vCursor INTO vIdProprietario, vCnpjProprietario;

			CLOSE vCursor;

			-- Recupera o Cpf do Motorista
			OPEN vCursor FOR
				SELECT 
					fornecedores.cnpj_cpf
				FROM 
					fornecedores
				WHERE id_fornecedor = vIdMotorista;

			FETCH vCursor INTO vCpfMotorista;


			CLOSE vCursor;
			
			-- Recupera as capacidades do veiculo
			OPEN vCursor FOR
				SELECT 
					veiculos_tipos.capacidade_cubica::numeric(8,3),  
					veiculos_tipos.capacidade_tonelada::numeric(8,2)
				FROM 
					veiculos 
					LEFT JOIN veiculos_tipos ON veiculos_tipos.id_tipo_veiculo = veiculos.id_tipo_veiculo 
				WHERE placa_veiculo = NEW.placa_veiculo;

			FETCH vCursor INTO vCapacidadeCubica, vCapacidadeTonelada;
			
			CLOSE vCursor;


			-- Grava registro de Manifesto
			OPEN vCursor FOR
				INSERT INTO scr_manifesto 
					(
						empresa_manifesto, -- 1
						filial_manifesto, -- 2
						numero_manifesto, -- 3
						data_emissao, -- 4
						id_cidade_origem, -- 5
						id_cidade_destino, -- 6
						data_viagem, -- 7
						tipo_manifesto, -- 8
						placa_veiculo, -- 9
						placa_carreta, -- 10
						placa_carreta2, -- 11
						capacidade_kg, -- 12
						capacidade_m3, -- 13
						cnpj_cpf_proprietario, -- 14
						id_proprietario, -- 15
						cpf_motorista, -- 16
						id_motorista, -- 17
						qtde_ctrc, -- 18
						qtde_volume, -- 19
						limite_valor_nf, -- 20 
						valor_total_nf, -- 21
						total_frete, -- 22
						frete_pago_terceiro, -- 23
						peso_pago, -- 24
						peso_calculado, -- 25
						cubagem_calculada, -- 26
						data_registro, -- 27					
						ocorrencia --28
												
					)
				VALUES 
					(
						NEW.empresa_emitente,--1
						NEW.filial_emitente, --2 
						vNumeroManifesto, -- 3
						NEW.data_emissao, --4
						NEW.calculado_de_id_cidade,--5
						NEW.calculado_ate_id_cidade,--6
						NEW.data_emissao,-- 7
						1, --8
						NEW.placa_veiculo, --9
						NEW.placa_reboque1, --10
						NEW.placa_reboque2, --11
						vCapacidadeTonelada, --12
						vCapacidadeCubica, --13
						vCnpjProprietario, --14
						vIdProprietario, -- 15
						vCpfMotorista,--16
						NEW.id_motorista,--17
						1,--18
						NEW.qtd_volumes,--19
						null,--20
						NEW.valor_nota_fiscal,--21
						NEW.total_frete,--22
						0.00,--23
						0.00,--24
						NEW.peso::numeric(8,2),--25
						NEW.volume_cubico::numeric(8,3),--26
						now(), --27
						'SEM DANOS' --28
					)
				RETURNING id_manifesto;

			
			FETCH vCursor INTO vIdManifesto;

			--Grava no Conhecimento o Id do Manifesto
			NEW.id_manifesto = vIdManifesto;

			--Grava log de atividades
			INSERT INTO scr_manifesto_log_atividades(id_manifesto, data_hora, atividade_executada, usuario) 
			VALUES (vIdManifesto, now(), 'INCLUSÃO AUTOMÁTICA','Suporte'); 
		ELSE 
			-- OPEN vCursor FOR 
-- 					SELECT 	id_romaneio
-- 					FROM 	scr_romaneios
-- 					WHERE 	
-- 						id_motorista = NEW.id_motorista
-- 						AND placa_veiculo = NEW.placa_veiculo
-- 						AND data_romaneio::date = vDataNota;
-- 
-- 			FETCH vCursor INTO vIdRomaneio;
-- 
-- 			CLOSE vCursor;	
		END IF;	

			

	ELSE
		--Se existe, deleta documento da viagem
		OPEN vCursor FOR DELETE FROM scr_viagens_docs WHERE id_documento = NEW.id_conhecimento RETURNING id_romaneio;

		FETCH vCursor INTO vIdManifesto;

		IF NOT FOUND THEN 
			CLOSE vCursor;
			RETURN NULL;
		END IF;
		
		CLOSE vCursor;	
		
	END IF;
	

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



--   SELECT * FROM scr_conhecimento WHERE data_emissao IS NOT NULL ORDER BY id_conhecimento DESC LIMIT 100;
--   SELECT * FROM scr_manifesto;

 --UPDATE scr_conhecimento SET flg_manifesto = 1 WHERE id_conhecimento = 22498;
  --UPDATE scr_conhecimento SET id_manifesto = NULL WHERE id_conhecimento = 22522;