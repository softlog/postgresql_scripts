-- Function: f_viagem_automatica()
-- SELECT * FROM scr_romaneios ORDER BY 1 DESC LIMIT 10
-- DROP FUNCTION f_viagem_automatica();
-- SELECT * FROM scr_conhecimento ORDER BY 1 DESC LIMIT 10;
/*

SELECT id_conhecimento, data_emissao, data_viagem, cancelado, id_motorista, placa_veiculo FROM scr_conhecimento WHERE numero_ctrc_filial IN ('0010010037924')

SELECT id_motorista FROM scr_notas_fiscais_imp WHERE id_conhecimento = 5690
SELECT * FROM scr_viagens_docs WHERE id_documento IN (792,793,794)

SELECT fp_set_session('pst_login','suporte');
SELECT fp_set_session('pst_cod_empresa', '001');

BEGIN;
UPDATE scr_conhecimento SET data_emissao = NULL WHERE id_conhecimento IN (12240);
UPDATE scr_conhecimento SET data_emissao = '2021-11-09 17:27:40' WHERE id_conhecimento IN (12240);
ROLLBACK;

SELECT * FROM scr_viagens_docs WHERE id_documento = 5690;
BEGIN;
UPDATE scr_conhecimento SET data_emissao = data_digitacao WHERE cstat = '100' AND data_emissao IS NULL ;

UPDATE scr_conhecimento SET data_emissao = NULL WHERE id_conhecimento = 5579;
UPDATE scr_conhecimento SET data_emissao = data_digitacao WHERE id_conhecimento = 5579;

SE
SELECT * FROM scr_viagens_docs WHERE id_documento = 5579
SELECT * FROM scr_viagens_docs WHERE id_romaneio = 2151
SELECT * FROM scr_romaneios WHERE id_romaneio = 3531
DELETE FROM scr_romaneios WHERE id_romaneio = 1634

SELECT id_conhecimento, numero_ctrc_filial, cancelado FROM scr_conhecimento WHERE id_conhecimento = 5579

SELECT max(id_conhecimento) FROM scr_conhecimento 
SELECT id_conhecimento, data_emissao, data_digitacao, data_viagem FROM scr_conhecimento WHERE data_emissao IS NULL 
ROLLBACK

*/

-- UPDATE scr_conhecimento SET flg_viagem = 1 WHERE id_motorista = 21;
-- Function: public.f_viagem_automatica();
-- DROP FUNCTION public.f_viagem_automatica();



CREATE OR REPLACE FUNCTION public.f_viagem_automatica()
  RETURNS trigger AS
$BODY$
DECLARE 

	v_usuario text;

	--Do romaneio para o conhecimento
	vExiste_viagem integer;
	vCursor refcursor;
	vNumeroChave integer;
	vNumeroViagem character(13);
	vTipoFrota integer;
	vCnpj_cpf_proprietario character(14);
	vNumero_tabela_motorista character(13);
	vIdRomaneio integer;	
	vDataViagem timestamp;
	vIdMotorista integer;
	vPlacaVeiculo character(7);
	v_placas_engates text;
	vDataDigitacao date;
	vIdOrigem integer;	
	vIdDestino integer;
	vResultado text;
	
	vEmpresa text;
	v_viagem_automatica integer;
	v_valor_presumido integer;
	v_id_coleta integer;
	v_id_viagem_doc integer;
	v_tabela text;
	v_executa boolean;
	vPagadorId integer;
	v_percentual_bc numeric(5,2);
	v_percentual_bc2 numeric(5,2);
	v_id_origem integer;
	v_id_destino integer;
	v_usa_odometro integer;
	v_desagrupa_destino integer;
BEGIN
	
	-- Verifica se é para lançar viagem automática
	-- Verifica se existe viagem aberta para determinado motorista, determinado veículo
	--	Se existe, lança documento, se não cria uma nova viagem

	-- retorna_regiao_origem_motorista(scr_romaneios.id_origem, scr_romaneios.numero_tabela_motorista) as id_regiao_origem,
	--	scr_romaneios.id_destino,
	--	retorna_regiao_destino_motorista(retorna_regiao_origem_motorista(scr_romaneios.id_origem, scr_romaneios.numero_tabela_motorista),
	--	scr_romaneios.id_destino, scr_romaneios.numero_tabela_motorista) as id_regiao_destino,

	-- SELECT * FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010001243' AND flg_viagem = 1 AND id_motorista IS NOT NULL AND placa_veiculo IS NOT NULL AND empresa_emitente IS NOT NULL AND filial_emitente IS NOT NULL
	-- SELECT id_conhecimento, numero_ctrc_filial FROM scr_conhecimento WHERE id_motorista IS NULL AND cancelado = 0
	-- SELECT 
	-- 		numero_ctrc_filial, 
	-- 		id_motorista,
	-- 		placa_veiculo,
	-- 		empresa_emitente,
	-- 		filial_emitente,
	-- 		calculado_de_id_cidade,
	-- 		calculado_ate_id_cidade
	-- 		
	-- 	FROM scr_conhecimento WHERE id_conhecimento IN (4261,4260)

	
	
	--SELECT * FROM debug ORDER BY 1 DESC LIMIT 10
	--PERFORM f_debug('Teste ',NEW.id_conhecimento::text);

	v_usuario = fp_get_session('pst_login');
	v_usuario = COALESCE(v_usuario, 'suporte');
		
	v_executa = false;

	--Verifica se foi emitido
	IF (COALESCE(NEW.data_emissao,now()) <> COALESCE(OLD.data_emissao,now())) AND NEW.data_emissao IS NOT NULL AND NEW.cancelado = 0 THEN 
		RAISE NOTICE 'TEM emissao';
		v_executa = true;
	ELSE
	
		IF NEW.data_emissao IS NOT NULL THEN 
			IF OLD.id_motorista IS NULL AND NEW.id_motorista IS NOT NULL THEN 
				v_executa = true;
			END IF;
		END IF;		

		IF NEW.data_emissao IS NOT NULL THEN 
			IF OLD.placa_veiculo IS NULL AND NEW.placa_veiculo IS NOT NULL THEN 
				v_executa = true;
			END IF;
		END IF;

		IF NEW.data_emissao IS NOT NULL THEN 
			IF OLD.odometro_inicial IS NULL AND NEW.odometro_inicial IS NOT NULL THEN 
				v_executa = true;
			END IF;
		END IF;

	END IF;


	IF NEW.cancelado = 1 THEN 
		v_executa = true;
	END IF;
	
	IF v_executa THEN 
	--IF 1=1 THEN 
		RAISE NOTICE 'Executa Viagem Automatica';	
		
		vEmpresa 	= COALESCE(NEW.empresa_emitente,'001');

		SELECT COALESCE(valor_parametro::integer,0)::integer
		INTO v_viagem_automatica
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_VIAGEM_AUTOMATICA';

		
		IF v_viagem_automatica = 0 THEN 		
			RETURN NEW;
		END IF;

		RAISE NOTICE 'Viagem Automatica = 1';
		
		IF NEW.flg_viagem = 0 THEN 
			-- SELECT id_conhecimento, flg_viagem FROM scr_conhecimento WHERE numero_ctrc_filial = '0020010000306'
			-- SELECT * FROM scr_notas_fiscais_imp WHERE id_conhecimento = 4926
			RETURN NEW;
		END IF;

		RAISE NOTICE 'Flag de Viagem marcado';
		
		SELECT COALESCE(valor_parametro::integer,0)::integer
		INTO v_valor_presumido 
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_USAR_VALOR_PRESUMIDO';
		

		SELECT COALESCE(valor_parametro::integer,0)::integer
		INTO v_usa_odometro
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_VIAGEM_AUTO_ODOMETRO';

		v_usa_odometro = COALESCE(v_usa_odometro, 0);

		IF v_usa_odometro = 1 AND NEW.odometro_inicial IS NULL THEN 			
			RAISE NOTICE 'Nao tem odometro inicial';	
			RETURN NEW;
			
		END IF;


		/*

			SELECT COALESCE(valor_parametro::integer,1)::integer
			INTO v_agrupa_destino
			FROM parametros 
			WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_VIAGEM_AGRUPA_DESTINO';


			v_agrupa_destino = COAELESCE(v_agrupa_destino, 1);

			
		*/

		
		/*

			OPEN vCursor FOR 
				SELECT MAX(data_nota_fiscal) FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = NEW.id_conhecimento;

			FETCH vCursor INTO vDataViagem;

			CLOSE vCursor;
			
		*/
		
		-- Verifica se tem Coleta associada com o CTe.
		IF COALESCE(v_valor_presumido,1) = 0 THEN 
			RAISE NOTICE 'Valor Presumido';
			SELECT COALESCE((col_coletas.data_coleta::text || ' ' || col_coletas.hora_coleta::text)::timestamp, vDataViagem), col_coletas.id_coleta 

			INTO vDataViagem, v_id_coleta

			FROM 
				col_coletas
				LEFT JOIN col_coletas_itens
					ON col_coletas.id_coleta = col_coletas_itens.id_coleta
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = col_coletas_itens.id_nota_fiscal_imp					
			WHERE 
				id_conhecimento = NEW.id_conhecimento 
			LIMIT 1;
			

			/*
			SELECT id_conhecimento, cod_interno_frete FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 6305
			
			SELECT id_coleta FROM col_coletas WHERE cod_interno_frete = '4032532055'
			SELECT * FROM col_coletas_itens WHERE id_coleta = 425
			SELECT data_emissao FROM scr_conhecimento WHERE id_conhecimento = 123

			SELECT COALESCE((col_coletas.data_coleta::text || ' ' || col_coletas.hora_coleta::text)::timestamp, now()), col_coletas.id_coleta 
			
			FROM 
				col_coletas
				LEFT JOIN col_coletas_itens
					ON col_coletas.id_coleta = col_coletas_itens.id_coleta
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = col_coletas_itens.id_nota_fiscal_imp					
			WHERE 
				id_conhecimento = 123;

			*/
		END IF;

		IF vDataViagem IS NULL THEN 
			vDataViagem = COALESCE(NEW.data_emissao, NEW.data_emissao);	
		END IF;

		RAISE NOTICE 'Data Viagem %', vDataViagem;
		RAISE NOTICE 'Id Coleta %', v_id_coleta;
		
		-- IF NOT FOUND THEN 
-- 			RETURN NULL;
-- 		END IF;		

		--Verifica se tem percentual de redução no pagador
		BEGIN
			SELECT 	COALESCE(replace(valor_parametro,',','.')::numeric(12,2),0.00)
			INTO v_percentual_bc
			FROM cliente_parametros
				LEFT JOIN cliente
					ON cliente.codigo_cliente = cliente_parametros.codigo_cliente
			WHERE 
				cliente_parametros.id_tipo_parametro = 94
				AND cliente.codigo_cliente = NEW.consig_red_id;
				
		EXCEPTION WHEN OTHERS  THEN 
			
			RAISE NOTICE 'ERRO ****************************************%', SQLERRM;
			RAISE NOTICE 'CODIGO INTERNO FRETE %', vCodInternoFrete;
		END; 

		v_percentual_bc = COALESCE(v_percentual_bc, 0.00);

				
		IF 	NEW.id_motorista IS NOT NULL
			AND NEW.placa_veiculo IS NOT NULL
			AND NEW.empresa_emitente IS NOT NULL 
			AND NEW.filial_emitente IS NOT NULL
		THEN 
			RAISE NOTICE 'Criando a Viagem';

			vIdMotorista := NEW.id_motorista;
			vPlacaVeiculo := NEW.placa_veiculo;
			
			vIdOrigem := NEW.calculado_de_id_cidade;
			vIdDestino := NEW.calculado_ate_id_cidade;
			
			--Verifica se existe viagem aberta
			-- Para determinado motorista, 
			-- determinado veiculo, 
			-- determinado dia, 
			-- determinada região de origem, 
			-- determinada região de destino

			--Verifica se tem coleta associada 
			IF v_id_coleta IS NOT NULL AND v_valor_presumido = 0 THEN 
				SELECT id_romaneio, numero_tabela_motorista
				INTO vIdRomaneio, v_tabela
				FROM scr_romaneios
				WHERE id_coleta = v_id_coleta;
								
			ELSE
				IF COALESCE(NEW.desagrupa_destino_viagem,0) = 1 THEN 
					SELECT id_romaneio
					INTO vIdRomaneio
					FROM 	scr_romaneios
						LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
						-- LEFT JOIN regiao_cidades reg_origem_ct ON reg_origem_ct.id_cidade = NEW.calculado_de_id_cidade				
		-- 				LEFT JOIN regiao_cidades reg_destino_ct ON reg_destino_ct.id_cidade = NEW.calculado_ate_id_cidade
		-- 				LEFT JOIN regiao_cidades reg_origem_rom ON reg_origem_rom.id_cidade = scr_romaneios.id_origem				
		-- 				LEFT JOIN regiao_cidades reg_destino_rom ON reg_destino_rom.id_cidade = scr_romaneios.id_destino				
					WHERE 	
						id_motorista 			= NEW.id_motorista
						AND placa_veiculo		= NEW.placa_veiculo
						AND data_saida::date 		= vDataViagem::date
						AND scr_romaneios.id_origem 	= NEW.calculado_de_id_cidade				
						AND scr_romaneios.id_destino 	= NEW.calculado_ate_id_cidade
						AND scr_romaneios.cancelado 	= 0
						AND NOT EXISTS (SELECT 1 FROM scr_relatorio_viagem_romaneios WHERE scr_relatorio_viagem_romaneios.id_romaneio = scr_romaneios.id_romaneio);
		-- 				AND reg_origem_ct.id_regiao = reg_origem_rom.id_regiao
		-- 				AND reg_destino_ct.id_regiao = reg_destino_rom.id_regiao;
				ELSE
					SELECT id_romaneio
					INTO vIdRomaneio
					FROM 	scr_romaneios
						LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
		-- 				LEFT JOIN regiao_cidades reg_origem_ct ON reg_origem_ct.id_cidade = NEW.calculado_de_id_cidade				
		-- 				LEFT JOIN regiao_cidades reg_destino_ct ON reg_destino_ct.id_cidade = NEW.calculado_ate_id_cidade
		-- 				LEFT JOIN regiao_cidades reg_origem_rom ON reg_origem_rom.id_cidade = scr_romaneios.id_origem				
		-- 				LEFT JOIN regiao_cidades reg_destino_rom ON reg_destino_rom.id_cidade = scr_romaneios.id_destino				
					WHERE 	
						id_motorista 			= NEW.id_motorista
						AND placa_veiculo		= NEW.placa_veiculo
						AND data_saida::date 		= vDataViagem::date
						AND scr_romaneios.id_origem 	= NEW.calculado_de_id_cidade				
		-- 				AND scr_romaneios.id_destino 	= NEW.calculado_ate_id_cidade
						AND scr_romaneios.cancelado 	= 0
						AND NOT EXISTS (SELECT 1 FROM scr_relatorio_viagem_romaneios WHERE scr_relatorio_viagem_romaneios.id_romaneio = scr_romaneios.id_romaneio);
		-- 				AND reg_origem_ct.id_regiao = reg_origem_rom.id_regiao
		-- 				AND reg_destino_ct.id_regiao = reg_destino_rom.id_regiao;
				END IF;
			END IF;					

			
			--RAISE NOTICE 'Romaneio %', vIdRomaneio;
			
			--Se não existe Viagem, cria a viagem
			IF vIdRomaneio IS NULL AND NEW.cancelado = 0 THEN 

				RAISE NOTICE 'Criando uma nova viagem';

				--Constroi Numero da Viagem
				vNumeroChave = proximo_numero_sequencia('scr_viagens_'  || trim(NEW.empresa_emitente) || '_' || trim(NEW.filial_emitente));

		
				vNumeroViagem = NEW.empresa_emitente || NEW.filial_emitente || TRIM(to_char(vNumeroChave,'0000000'));


				--Recupera o Tipo da Frota e o Cnpj_CPF do Proprietario
				SELECT 
					tipo_frota,
					cnpj_cpf
				INTO 
					vTipoFrota, vCnpj_cpf_proprietario
				FROM 
					veiculos
					LEFT JOIN fornecedores ON veiculos.id_proprietario = fornecedores.id_fornecedor
				WHERE 
					placa_veiculo = NEW.placa_veiculo;

				
				SELECT scr_tabela_motorista.numero_tabela_motorista
				INTO v_tabela
				FROM scr_tabela_motorista
					LEFT JOIN scr_tabela_motorista_regioes tr
						ON tr.id_tabela_motorista = scr_tabela_motorista.id_tabela_motorista
				WHERE cpf_motorista = vCnpj_cpf_proprietario
					AND tr.placa_veiculo = NEW.placa_veiculo
					AND scr_tabela_motorista.ativa = 1;
					

				IF v_tabela IS NULL THEN
				 
					SELECT scr_tabela_motorista.numero_tabela_motorista
					INTO v_tabela
					FROM scr_tabela_motorista
						LEFT JOIN fornecedores
							ON fornecedores.cnpj_cpf = scr_tabela_motorista.cpf_motorista						
						LEFT JOIN scr_tabela_motorista_regioes tr
							ON tr.id_tabela_motorista = scr_tabela_motorista.id_tabela_motorista
					WHERE fornecedores.id_fornecedor = NEW.id_motorista
						AND tr.placa_veiculo = NEW.placa_veiculo
						AND scr_tabela_motorista.ativa = 1;
				
				END IF;

							
				
				--Busca as placas de engate
				SELECT placas_engates 
				INTO v_placas_engates
				FROM v_frt_veic_tracionado
				WHERE placa_tracao = NEW.placa_veiculo;


				--SELECT odometro_inicial FROM scr_romaneios LIMIT 1

				OPEN vCursor FOR
				
					INSERT INTO scr_romaneios 
						(
							tipo_romaneio,
							cod_empresa,
							cod_filial,
							numero_romaneio,
							data_romaneio,
							id_origem,
							id_destino,
							data_saida,
							tipo_frota,
							placa_veiculo,
							placas_engates,
							cnpj_cpf_proprietario,
							id_motorista,
							id_coleta,
							numero_tabela_motorista,
							odometro_inicial
						)
					VALUES 
						(
							2,
							NEW.empresa_emitente,
							NEW.filial_emitente,
							vNumeroViagem,
							vDataViagem::timestamp,
							NEW.calculado_de_id_cidade,
							NEW.calculado_ate_id_cidade,
							vDataViagem,
							vTipoFrota,
							NEW.placa_veiculo,
							v_placas_engates,
							vCnpj_cpf_proprietario,
							NEW.id_motorista,
							v_id_coleta,
							v_tabela,
							NEW.odometro_inicial						
							
						)
					RETURNING id_romaneio;
							
				FETCH vCursor INTO vIdRomaneio;

				RAISE NOTICE 'Romaneio Criado %', vIdRomaneio;
				INSERT INTO scr_romaneio_log_atividades (id_romaneio, data_transacao, usuario, acao_executada)
				VALUES (vIdRomaneio, now(), v_usuario, 'CRIACAO AUTOMATICA CTe/MIN ' || NEW.numero_ctrc_filial);				 
			
			END IF;	


			--Verifica se tem percentual de reducao na tabela
			IF v_tabela IS NOT NULL THEN 

				v_id_origem = retorna_regiao_origem_motorista(NEW.calculado_de_id_cidade, v_tabela);
				v_id_destino = retorna_regiao_destino_motorista(v_id_origem, NEW.calculado_ate_id_cidade, v_tabela);

				SELECT 
					tr.perc_red_bc_comissao
				INTO 
					v_percentual_bc2					
				FROM 	
					scr_tabela_motorista t
					LEFT JOIN scr_tabela_motorista_regioes tr
						ON t.id_tabela_motorista = tr.id_tabela_motorista
				WHERE 
					numero_tabela_motorista = v_tabela
					AND id_regiao_origem = v_id_origem
					AND id_regiao_destino = v_id_destino;

				IF v_percentual_bc2 IS NOT NULL THEN
					IF v_percentual_bc2 > 0.00 THEN 
						v_percentual_bc = v_percentual_bc2;
					END IF;
				END IF;
				
			END IF;

			--Se CTe estiver cancelado
			IF NEW.cancelado = 1 THEN 
				DELETE FROM scr_viagens_docs 
				WHERE 
					id_documento = NEW.id_conhecimento 
					AND tipo_documento = 1
					AND id_romaneio = vIdRomaneio;				
				RETURN NEW;

				
			END IF;

			--UPDATE scr_viagens_docs SET tipo_documento = 1 WHERE tipo_documento = 2
			-- Grava o conhecimento na viagem			
			SELECT id_viagem_doc
			INTO v_id_viagem_doc
			FROM scr_viagens_docs
			WHERE id_romaneio = vIdRomaneio
				AND id_documento = NEW.id_conhecimento
				AND tipo_documento = 1;

			IF v_id_viagem_doc IS NULL THEN 
				INSERT INTO scr_viagens_docs (
					id_romaneio,
					id_documento,
					tipo_documento,
					total_frete,
					peso_total,
					qtd_volumes,
					volume_cubado,
					total_frete_bruto,
					peso_total_bruto,
					perc_red_bc_comissao					
				) VALUES (
					vIdRomaneio,
					NEW.id_conhecimento,
					1,
					CASE WHEN NEW.tipo_transporte IN (20) THEN 
						0.00
					ELSE
						COALESCE(NEW.total_frete::numeric(12,2)/(1 + (v_percentual_bc/100)),0.00) 
					END,
					
					CASE WHEN NEW.tipo_transporte IN (2,3,12,20) THEN 
						0.00
					ELSE
						COALESCE(NEW.peso::numeric(12,2),0.00) 
					END,
					
					CASE WHEN NEW.tipo_transporte IN (2,3,12,20) THEN 
						0
					ELSE
						COALESCE(NEW.qtd_volumes::integer,0.00) 
					END,
					
					CASE WHEN NEW.tipo_transporte IN (2,3,12,20) THEN 
						0.00
					ELSE
						COALESCE(NEW.volume_cubico::numeric(12,2),0.00) 
					END, 
					
					CASE WHEN NEW.tipo_transporte IN (2,3,12,20) THEN 
						0.00
					ELSE
						COALESCE(NEW.total_frete::numeric(12,2),0.00) 
					END,
					CASE WHEN NEW.tipo_transporte IN (2,3,12,20) THEN 
						0.00
					ELSE
						COALESCE(NEW.peso::numeric(12,2),0.00) 
					END,
					v_percentual_bc				
					
				);	

			END IF;

			UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE id_romaneio = vIdRomaneio;
			
--			vResultado =  f_grava_docs_viagens('''' || trim(NEW.numero_ctrc_filial) || '''', NEW.tipo_documento::integer, vIdRomaneio::integer, NEW.id_motorista::integer, vDataViagem::timestamp);
--			RAISE NOTICE 'Docs Viagem %', vResultado;
			--PERFORM f_debug('Docs Viagem',vResultado);

		ELSE
			--Se existe, deleta documento da viagem
			OPEN vCursor FOR 
			DELETE FROM scr_viagens_docs 
			WHERE 
				id_documento = NEW.id_conhecimento 
				AND tipo_documento = 1
				AND id_romaneio = vIdRomaneio
			RETURNING id_romaneio ;

			FETCH vCursor INTO vIdRomaneio;

			IF NOT FOUND THEN 
				CLOSE vCursor;
				RETURN NULL;
			END IF;
			
			CLOSE vCursor;	
			
		END IF;
	END IF;	

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


DROP TRIGGER upd_ins_viagem_automatica ON scr_conhecimento;

CREATE TRIGGER upd_ins_viagem_automatica
  AFTER UPDATE 
  ON scr_conhecimento
  FOR EACH ROW
  EXECUTE PROCEDURE f_viagem_automatica();

-- Function: f_emite_conhecimento_automatico_normal(integer[], integer, integer, refcursor, refcursor, refcursor)

-- DROP FUNCTION f_emite_conhecimento_automatico_normal(integer[], integer, integer, refcursor, refcursor, refcursor);

