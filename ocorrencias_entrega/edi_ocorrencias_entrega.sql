-- Function: public.edi_ocorrencias_entrega()

-- DROP FUNCTION public.edi_ocorrencias_entrega();

CREATE OR REPLACE FUNCTION public.edi_ocorrencias_entrega()
  RETURNS trigger AS
$BODY$
DECLARE
	v_qt integer;
	v_usuario text;
	v_id_nota_fiscal_imp integer;
	v_id_conhecimento_notas_fiscais integer;
	v_id_ocorrencia_nota_fiscal_imp integer;
	v_id_conhecimento integer;
	v_cursor refcursor;
	v_operacao_por_nota integer;
	v_empresa character(3);
	v_codigo_ocorrencia integer;
	v_status integer;
	v_historico text;
	v_tem_canhoto integer;	
	va_img text[];
	tamanho integer;
	i integer;
BEGIN

	--Se a Ocorrência veio via Integracao Parceiros Softlog, recebe o código 4
	IF NEW.id_ocorrencia_app = -1000 THEN 
		NEW.servico_integracao = 4;
	END IF;

	--Comprovei
	IF NEW.servico_integracao = 1 THEN 
		
		SELECT 
			count(*) 
		INTO 
			v_qt
		FROM 
			edi_ocorrencias_entrega
		WHERE 
			numero_ocorrencia = NEW.numero_ocorrencia AND id <> NEW.id;


		--RAISE NOTICE 'QT %',v_qt;
		IF v_qt > 0 THEN 
			RETURN NULL;
		END IF;
			
		v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA','001')::integer,0);

	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;

	-- 	END IF;
		
		IF v_operacao_por_nota = 1 THEN 			
			-- Procura associacao com Nota Importada
			IF NEW.id_nota_fiscal_imp IS NULL THEN 
			
				SELECT id_nota_fiscal_imp, empresa_emitente 
				INTO v_id_nota_fiscal_imp, v_empresa
				FROM scr_notas_fiscais_imp
				WHERE chave_nfe = NEW.chave_nfe
				ORDER BY 1 DESC LIMIT 1;

				IF v_id_nota_fiscal_imp IS NOT NULL THEN 
					NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
					--v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
				END IF ;	
			END IF;

			--SELECT * FROM edi_ocorrencias_entrega
			--SELECT * FROM edi_ocorrencias_comprovei
			--SELECT * FROM scr_ocorrencia_edi ORDER BY 1
			--Tratamento das Ocorrencias
			BEGIN 
				SELECT id_ocorrencia_softlog 
				INTO v_codigo_ocorrencia 
				FROM edi_ocorrencias_comprovei
				WHERE codigo_status = split_part(NEW.motivo_ocorrencia,'-',1)::integer;
			EXCEPTION WHEN OTHERS  THEN
				v_codigo_ocorrencia = -1;
			END;
			
			--RAISE NOTICE 'Operacao por nota %', v_operacao_por_nota;
			IF v_operacao_por_nota = 1 AND v_codigo_ocorrencia <> -1 THEN 

				v_codigo_ocorrencia = COALESCE(v_codigo_ocorrencia,1);

				IF NEW.data_ocorrencia IS NULL THEN
					--Se não tem data de baixa, seta status 2
					-- que é o indicativo de erro;
					NEW.status = 2;			
					RETURN NEW;
				END IF;

				--Coloca id da nota fiscal imp na variavel global 
				-- para trigger de ocorrencia automatica abortar insercao
				PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

				--RAISE NOTICE 'Entrei aqui';
				--Faz update na nota fiscal 
				UPDATE scr_notas_fiscais_imp nf
					SET 
						id_ocorrencia   = v_codigo_ocorrencia,
						data_ocorrencia = NEW.data_ocorrencia,
						nome_recebedor  = LEFT(NEW.recebedor,50)
				WHERE
					nf.id_nota_fiscal_imp   = NEW.id_nota_fiscal_imp;


				

				OPEN v_cursor FOR 
				INSERT INTO scr_notas_fiscais_imp_ocorrencias(
					id_nota_fiscal_imp, 
					id_ocorrencia,
					data_ocorrencia,
					data_registro,
					canhoto)
				 VALUES(
					NEW.id_nota_fiscal_imp,
					v_codigo_ocorrencia,
					NEW.data_ocorrencia,
					now(),
					0)
				RETURNING id_ocorrencia_nf;

				FETCH v_cursor INTO v_id_ocorrencia_nota_fiscal_imp;

				CLOSE v_cursor;

				--Grava imagem se existir
				IF NEW.url_imagem IS NOT NULL THEN 
					INSERT INTO scr_docs_digitalizados (
						link_img,
						id_nota_fiscal_imp,
						id_ocorrencia_nota_fiscal_imp 
					)
					VALUES (
						NEW.url_imagem,
						NEW.id_nota_fiscal_imp,
						v_id_ocorrencia_nota_fiscal_imp
					);		
				END IF;

				--Grava Log Atividades
				INSERT INTO scr_notas_fiscais_imp_log_atividades(
					id_nota_fiscal_imp, 
					data_hora, 
					atividade_executada, 
					usuario
					)
				VALUES (
					NEW.id_nota_fiscal_imp,
					now(),
					'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
					'suporte'
				);
				
			END IF;
		END IF;

		--RAISE NOTICE 'Operacao por Nota %',v_codigo_ocorrencia;
		IF v_operacao_por_nota = 0  THEN 
			RAISE NOTICE 'Operacao Por CTe';
			--SELECT * FROM edi_ocorrencias_entrega
			-- Procura associacao com Nota Importada
			IF NEW.id_conhecimento_notas_fiscais IS NULL THEN 
			
				SELECT id_conhecimento_notas_fiscais, nf.id_conhecimento, v_empresa, id_nota_fiscal_imp
				INTO v_id_conhecimento_notas_fiscais, v_id_conhecimento, v_empresa, v_id_nota_fiscal_imp
				FROM scr_conhecimento_notas_fiscais nf
				LEFT JOIN scr_conhecimento c
					ON c.id_conhecimento = nf.id_conhecimento		
				WHERE chave_nfe = NEW.chave_nfe
				ORDER BY 1 DESC LIMIT 1;

				IF v_id_conhecimento_notas_fiscais IS NOT NULL THEN 
					NEW.id_conhecimento_notas_fiscais = v_id_conhecimento_notas_fiscais;
					NEW.id_conhecimento = v_id_conhecimento;
					NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
					--v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
				END IF ;				
	
			END IF;




			BEGIN 
				SELECT id_ocorrencia_softlog 
				INTO v_codigo_ocorrencia 
				FROM edi_ocorrencias_comprovei
				WHERE codigo_status = split_part(NEW.motivo_ocorrencia,'-',1)::integer;

				RAISE NOTICE 'Ocorrencia % = %', split_part(NEW.motivo_ocorrencia,'-',1)::integer, v_codigo_ocorrencia;
	
			EXCEPTION WHEN OTHERS  THEN				
				v_codigo_ocorrencia = -1;
				RETURN NEW;
			END;

			RAISE NOTICE 'Ocorrencia % = %', split_part(NEW.motivo_ocorrencia,'-',1)::integer, v_codigo_ocorrencia;
			IF v_codigo_ocorrencia IS NULL OR v_codigo_ocorrencia = -1 THEN 
				NEW.id_conhecimento_notas_fiscais = NULL;
				NEW.id_conhecimento = NULL;
				NEW.id_nota_fiscal_imp = NULL;
				RETURN NEW;
			END IF;		
			
			IF NEW.data_ocorrencia IS NULL THEN
				--Se não tem data de baixa, seta status 2
				-- que é o indicativo de erro;
				NEW.status = 2;			
				RETURN NEW;			
			END IF;

			
			IF NEW.url_imagem IS NOT NULL OR NEW.url_assinatura IS NOT NULL THEN 
				v_tem_canhoto = 1;
			ELSE
				v_tem_canhoto = 0;
			END IF;

			--Coloca id da nota fiscal imp na variavel global 
			-- para trigger de ocorrencia automatica abortar insercao
			PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);
			
			UPDATE scr_conhecimento_notas_fiscais nf
				SET 
					id_ocorrencia = v_codigo_ocorrencia,
					data_ocorrencia = COALESCE(NEW.data_ocorrencia::date),				
					hora_ocorrencia = COALESCE(to_char(NEW.data_ocorrencia,'HH24MM')),
					nome_recebedor_nf  = COALESCE(LEFT(NEW.recebedor,50),'NAO INFORMADO'),
					canhoto = v_tem_canhoto
			WHERE
				nf.id_conhecimento_notas_fiscais = NEW.id_conhecimento_notas_fiscais;

			IF v_codigo_ocorrencia = 1 THEN 
				RAISE NOTICE 'Gravando Entrega Conhecimento %', NEW.id_conhecimento;
				WITH t AS (
					SELECT
						SUM((CASE WHEN COALESCE(nf.id_ocorrencia,0) NOT IN (1,2) THEN 1 ELSE 0 END)) as qt,
						nf.id_conhecimento
					FROM
						scr_conhecimento_notas_fiscais nf
					WHERE
						nf.id_conhecimento = NEW.id_conhecimento
					GROUP BY
						nf.id_conhecimento

				)					
				UPDATE scr_conhecimento
					SET
						nome_recebedor 	= COALESCE(LEFT(NEW.recebedor,50)),
						data_entrega   	= COALESCE(NEW.data_ocorrencia::date),
						hora_entrega   	= COALESCE(to_char(NEW.data_ocorrencia,'HH24MM')),
						data_baixa     	= COALESCE(NEW.data_ocorrencia::date),
						status 		= 5,
						canhoto		= v_tem_canhoto
						
				FROM
					t
				WHERE
					scr_conhecimento.id_conhecimento  = t.id_conhecimento
					AND t.qt = 0;	



				IF v_tem_canhoto THEN 
					IF NEW.url_imagem IS NOT NULL THEN 
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_conhecimento,
							id_nota_fiscal_imp,
							id_conhecimento_notas_fiscais
						)
						VALUES (
							NEW.url_imagem,
							NEW.id_conhecimento,
							v_id_nota_fiscal_imp,
							v_id_conhecimento_notas_fiscais
						);		
					END IF;

					IF NEW.url_assinatura IS NOT NULL THEN 
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_conhecimento,
							id_nota_fiscal_imp,
							id_conhecimento_notas_fiscais
						)
						VALUES (
							NEW.url_assinatura,
							NEW.id_conhecimento,
							v_id_nota_fiscal_imp,
							v_id_conhecimento_notas_fiscais
						);		
					END IF;

				END IF;

				--SELECT * FROM scr_conhecimento_log_atividades LIMIT 1
				--Grava Log Atividades
				INSERT INTO scr_notas_fiscais_imp_log_atividades(
					id_nota_fiscal_imp, 
					data_hora, 
					atividade_executada, 
					usuario
					)
				VALUES (
					NEW.id_nota_fiscal_imp,
					now(),
					'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
					'suporte'
				);

				INSERT INTO scr_conhecimento_log_atividades(
					id_conhecimento, 
					data_hora, 
					atividade_executada, 
					usuario
					)
				VALUES (
					NEW.id_conhecimento,
					now(),
					'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
					'suporte'
				);
				

			ELSE 
				
				

				IF v_tem_canhoto THEN 
					IF NEW.url_imagem IS NOT NULL THEN 
					
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_conhecimento,
							id_nota_fiscal_imp,
							id_conhecimento_notas_fiscais
						)
						VALUES (
							NEW.url_imagem,
							NEW.id_conhecimento,
							v_id_nota_fiscal_imp,
							v_id_conhecimento_notas_fiscais
						);		
					END IF;

					IF NEW.url_assinatura IS NOT NULL THEN 
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_conhecimento,
							id_nota_fiscal_imp,
							id_conhecimento_notas_fiscais
						)
						VALUES (
							NEW.url_assinatura,
							NEW.id_conhecimento,
							v_id_nota_fiscal_imp,
							v_id_conhecimento_notas_fiscais
						);		
					END IF;
				END IF;

				--SELECT * FROM scr_conhecimento_log_atividades LIMIT 1
				--Grava Log Atividades
				INSERT INTO scr_notas_fiscais_imp_log_atividades(
					id_nota_fiscal_imp, 
					data_hora, 
					atividade_executada, 
					usuario
					)
				VALUES (
					NEW.id_nota_fiscal_imp,
					now(),
					'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
					'suporte'
				);

				INSERT INTO scr_conhecimento_log_atividades(
					id_conhecimento, 
					data_hora, 
					atividade_executada, 
					usuario
					)
				VALUES (
					NEW.id_conhecimento,
					now(),
					'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
					'suporte'
				);
				

			END IF;
			
			--Faz update na nota fiscal 
		END IF;
	END IF;


	IF NEW.servico_integracao IN (2,4)  THEN 


		IF NEW.id_conhecimento_notas_fiscais IS NOT NULL THEN 
			SELECT empresa_emitente 
			INTO v_empresa
			FROM scr_conhecimento_notas_fiscais nf
				LEFT JOIN scr_conhecimento c
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE id_conhecimento_notas_fiscais = NEW.id_conhecimento_notas_fiscais 
			ORDER BY 1 DESC LIMIT 1;

			v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
		ELSE 
			v_operacao_por_nota = 1;
		END IF; 

		
		IF TG_OP = 'UPDATE' THEN 
			RETURN NULL;
		END IF;

		
-- 		SELECT 
-- 			count(*) 
-- 		INTO 
-- 			v_qt
-- 		FROM 
-- 			edi_ocorrencias_entrega
-- 		WHERE 
-- 			numero_ocorrencia = NEW.numero_ocorrencia AND id <> NEW.id;
-- 
-- 
-- 		RAISE NOTICE 'QT %',v_qt;
-- 		IF v_qt > 0 THEN 
-- 			RETURN NULL;
-- 		END IF;

	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;
	-- 	END IF;

		-- Procura associacao com Nota Importada
-- 		IF NEW.id_nota_fiscal_imp IS NULL THEN 
-- 		
-- 			SELECT id_nota_fiscal_imp, empresa_emitente 
-- 			INTO v_id_nota_fiscal_imp, v_empresa
-- 			FROM scr_notas_fiscais_imp
-- 			WHERE chave_nfe = NEW.chave_nfe
-- 			ORDER BY 1 DESC LIMIT 1;
-- 
-- 			IF v_id_nota_fiscal_imp IS NOT NULL THEN 
-- 				NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
-- 				v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
-- 			END IF ;	
-- 		END IF;
		
		
		--SELECT * FROM scr_ocorrencia_edi ORDER BY 1
		--Tratamento das Ocorrencias
		
		--v_operacao_por_nota = 1;
		v_codigo_ocorrencia = NEW.numero_ocorrencia;
		RAISE NOTICE 'Operacao por nota %', v_operacao_por_nota;
		IF NEW.id_nota_fiscal_imp IS NOT NULL THEN 

			
			IF NEW.data_ocorrencia IS NULL THEN
				--Se não tem data de baixa, seta status 2
				-- que é o indicativo de erro;
				NEW.status = 2;			
				RETURN NEW;
			END IF;

			--Coloca id da nota fiscal imp na variavel global 
			-- para trigger de ocorrencia automatica abortar insercao
			PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

			
			--Faz update na nota fiscal 
			UPDATE scr_notas_fiscais_imp nf
				SET 
					id_ocorrencia   = v_codigo_ocorrencia,
					data_ocorrencia = NEW.data_ocorrencia,
					nome_recebedor  = LEFT(NEW.recebedor,50)
			WHERE
				nf.id_nota_fiscal_imp   = NEW.id_nota_fiscal_imp;


			

			OPEN v_cursor FOR 
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				v_codigo_ocorrencia,
				NEW.data_ocorrencia,
				now(),
				0)
			RETURNING id_ocorrencia_nf;

			FETCH v_cursor INTO v_id_ocorrencia_nota_fiscal_imp;

			CLOSE v_cursor;

			
			--Grava imagem se existir
			IF NEW.url_imagem IS NOT NULL AND v_operacao_por_nota = 1  THEN 
				INSERT INTO scr_docs_digitalizados (
					link_img,
					id_nota_fiscal_imp,
					id_ocorrencia_nota_fiscal_imp 
				)
				VALUES (
					NEW.url_imagem,
					NEW.id_nota_fiscal_imp,
					v_id_ocorrencia_nota_fiscal_imp
				);	
					
			END IF;

			IF NEW.url_imagem IS NOT NULL THEN 
				UPDATE scr_notas_fiscais_imp 
					SET digitalizado = 1 
				WHERE 
					id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;
			END IF;

			
			--Grava Latitude, Longitude 
			IF NEW.latitude IS NOT NULL AND v_operacao_por_nota = 1 THEN 
				WITH t AS (
					SELECT destinatario_id 					
					FROM scr_notas_fiscais_imp
					WHERE scr_notas_fiscais_imp.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
				)				
				UPDATE cliente SET 
					latitude = NEW.latitude::double precision,
					longitude = NEW.longitude::double precision
				FROM 
					t 
				WHERE 
					cliente.codigo_cliente = t.destinatario_id;
		
			END IF;
			
			--Grava Log Atividades
			INSERT INTO scr_notas_fiscais_imp_log_atividades(
				id_nota_fiscal_imp, 
				data_hora, 
				atividade_executada, 
				usuario
				)
			VALUES (
				NEW.id_nota_fiscal_imp,
				now(),
				'OCORRENCIA via sCONFIRMEI Codigo:' || v_codigo_ocorrencia::text,
				'suporte'
			);
		END IF;
		IF v_operacao_por_nota = 0 THEN 

			RAISE NOTICE 'Setando ocorrencia no banco de dados';
			IF NEW.url_imagem IS NOT NULL AND NEW.numero_ocorrencia = 1 THEN 
				v_tem_canhoto = 1;
			ELSE
				v_tem_canhoto = 0;
			END IF;

			
			--SELECT * FROM edi_ocorrencias_entrega 
			--Faz update na nota fiscal 
			OPEN v_cursor FOR 
			UPDATE scr_conhecimento_notas_fiscais nf
				SET 
					id_ocorrencia = v_codigo_ocorrencia,
					data_ocorrencia = NEW.data_ocorrencia::date,				
					hora_ocorrencia = to_char(NEW.data_ocorrencia,'HH24MM'),
					nome_recebedor_nf  = LEFT(NEW.recebedor,50),					
					canhoto = v_tem_canhoto
			WHERE
				nf.id_conhecimento_notas_fiscais = NEW.id_conhecimento_notas_fiscais
			RETURNING
				nf.id_conhecimento,
				nf.id_conhecimento_notas_fiscais;

			FETCH v_cursor INTO v_id_conhecimento, v_id_conhecimento_notas_fiscais;

			CLOSE v_cursor;

			
			RAISE NOTICE '%s', 'Id conhecimento: ' || v_id_conhecimento::text || '- Id NF ' || v_id_conhecimento_notas_fiscais::text;

			WITH t AS (
				SELECT
					SUM((CASE WHEN COALESCE(o.pendencia,1) = 1 THEN 1 ELSE 0 END)) as qt,
					nf.id_conhecimento
				FROM
					scr_conhecimento_notas_fiscais nf
					LEFT JOIN scr_ocorrencia_edi o
						ON o.codigo_edi = nf.id_ocorrencia
					
				WHERE
					nf.id_conhecimento = NEW.id_conhecimento
				GROUP BY
					nf.id_conhecimento

			)			
			UPDATE scr_conhecimento
				SET
					nome_recebedor 	= LEFT(NEW.recebedor,50),
					cpf_recebedor   = LEFT(NEW.doc_recebedor,11),
					data_entrega   	= NEW.data_ocorrencia,
					hora_entrega   	= to_char(NEW.data_ocorrencia,'HH24MM'),
					data_baixa     	= NEW.data_ocorrencia,
					status 		= 5,
					canhoto		= v_tem_canhoto
					
			FROM
				t
			WHERE
				scr_conhecimento.id_conhecimento  = t.id_conhecimento
				AND t.qt = 0;	

			IF NEW.url_imagem IS NOT NULL THEN 				
				INSERT INTO scr_docs_digitalizados (
					link_img,
					id_conhecimento,
					id_nota_fiscal_imp,
					id_conhecimento_notas_fiscais
				)
				VALUES (
					NEW.url_imagem,
					NEW.id_conhecimento,
					NEW.id_nota_fiscal_imp,
					NEW.id_conhecimento_notas_fiscais
				);	
			END IF;

			--Grava Latitude, Longitude
			IF NEW.latitude IS NOT NULL THEN 
				WITH t AS (
					SELECT destinatario_id 					
					FROM scr_conhecimento
					WHERE scr_conhecimento.id_conhecimento = NEW.id_conhecimento
				)				
				UPDATE cliente SET 
					latitude = NEW.latitude::double precision,
					longitude = NEW.longitude::double precision
				FROM 
					t 
				WHERE 
					cliente.codigo_cliente = t.destinatario_id;		
			END IF;
			
			
			--Grava Log Atividades
			INSERT INTO scr_conhecimento_log_atividades(
				id_conhecimento, 
				data_hora, 
				atividade_executada, 
				usuario
				)
			VALUES (
				NEW.id_conhecimento,
				now(),
				'OCORRENCIA via sCONFIRMEI NF:' || NEW.numero_nfe ||' Cod.:' || v_codigo_ocorrencia::text,
				'suporte'
			);	
		END IF;
	END IF;

	IF NEW.servico_integracao = 3 THEN 

		SELECT 
			count(*) 
		INTO 
			v_qt
		FROM 
			edi_ocorrencias_entrega
		WHERE 
			numero_ocorrencia = NEW.numero_ocorrencia AND id_carga_itrack <> NEW.id_carga_itrack AND id_carga_itrack = NEW.id_carga_itrack;


		RAISE NOTICE 'QT %',v_qt;
		IF v_qt > 0 THEN 
			RETURN NULL;
		END IF;

	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;
	-- 	END IF;
	
		IF NEW.id_carga_itrack IS NOT NULL THEN 
			SELECT nf.id_nota_fiscal_imp, empresa_emitente
			INTO v_id_nota_fiscal_imp, v_empresa
			FROM 
				fila_documentos_integracoes fila
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = fila.id_nota_fiscal_imp
			WHERE id_integracao = NEW.id_carga_itrack;

			IF v_id_nota_fiscal_imp IS NOT NULL THEN 
				NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
				v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
			END IF ;			
		END IF;
	

		-- Procura associacao com Nota Importada
		IF NEW.id_nota_fiscal_imp IS NULL THEN 
		
			SELECT id_nota_fiscal_imp, empresa_emitente 
			INTO v_id_nota_fiscal_imp, v_empresa
			FROM scr_notas_fiscais_imp
			WHERE chave_nfe = NEW.chave_nfe
			ORDER BY 1 DESC LIMIT 1;

			IF v_id_nota_fiscal_imp IS NOT NULL THEN 
				NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
				v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
			END IF ;	
		END IF;
		
		--SELECT * FROM edi_ocorrencias_entrega
		--SELECT * FROM scr_ocorrencia_edi ORDER BY 1
		--Tratamento das Ocorrencias
		SELECT id_ocorrencia_softlog 
		INTO v_codigo_ocorrencia 
		FROM edi_ocorrencias_itrack
		WHERE codigo_itrack = NEW.numero_ocorrencia;
		
		RAISE NOTICE 'Operacao por nota %', v_operacao_por_nota;
		IF v_operacao_por_nota = 1 THEN 

			v_codigo_ocorrencia = COALESCE(v_codigo_ocorrencia,1);

			IF NEW.data_ocorrencia IS NULL THEN
				--Se não tem data de baixa, seta status 2
				-- que é o indicativo de erro;
				NEW.status = 2;			
				RETURN NEW;
			END IF;

			--Coloca id da nota fiscal imp na variavel global 
			-- para trigger de ocorrencia automatica abortar insercao
			PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

			RAISE NOTICE 'Entrei aqui';
			
			IF NEW.url_imagem IS NOT NULL THEN 
				v_tem_canhoto = 1;
			ELSE
				v_tem_canhoto = 0;
			END IF;

			
			--Faz update na nota fiscal 
			UPDATE scr_notas_fiscais_imp nf
				SET 
					id_ocorrencia   = v_codigo_ocorrencia,
					data_ocorrencia = NEW.data_ocorrencia,
					nome_recebedor  = LEFT(NEW.recebedor,50),
					canhoto = v_tem_canhoto				
			WHERE
				nf.id_nota_fiscal_imp   = NEW.id_nota_fiscal_imp;


			

			OPEN v_cursor FOR 
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				v_codigo_ocorrencia,
				NEW.data_ocorrencia,
				now(),
				v_tem_canhoto)
			RETURNING id_ocorrencia_nf;

			FETCH v_cursor INTO v_id_ocorrencia_nota_fiscal_imp;

			CLOSE v_cursor;

			--Grava imagem se existir
			IF trim(NEW.url_imagem) = '' THEN 
				NEW.url_imagem = NULL;
			END IF;
			
			IF NEW.url_imagem IS NOT NULL THEN 
		
				va_img = string_to_array(NEW.url_imagem,';');
				tamanho = array_length(va_img,1);
				
				FOR i IN 1..tamanho LOOP
					IF va_img[i] <> '' THEN 
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_nota_fiscal_imp,
							id_ocorrencia_nota_fiscal_imp 
						)
						VALUES (
							va_img[i],
							NEW.id_nota_fiscal_imp,
							v_id_ocorrencia_nota_fiscal_imp
						);		
					END IF;
				END LOOP;

				UPDATE scr_notas_fiscais_imp 
					SET digitalizado = 1 
				WHERE 
					id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;	

							
			END IF;

			--Grava Log Atividades
			INSERT INTO scr_notas_fiscais_imp_log_atividades(
				id_nota_fiscal_imp, 
				data_hora, 
				atividade_executada, 
				usuario
				)
			VALUES (
				NEW.id_nota_fiscal_imp,
				now(),
				'OCORRENCIA via ITrack Codigo:' || v_codigo_ocorrencia::text,
				'suporte'
			);
			
		END IF;
	END IF;



	IF NEW.servico_integracao = 5 THEN 
		--RETURN NEW;

-- 		SELECT 
-- 			count(*) 
-- 		INTO 
-- 			v_qt
-- 		FROM 
-- 			edi_ocorrencias_entrega
-- 		WHERE 
-- 			id_ocorrencia_app = NEW.id_ocorrencia_app AND id <> NEW.id
-- 			AND servico_integracao = 5;
-- 
-- 
-- 		RAISE NOTICE 'QT %',v_qt;
-- 		IF v_qt > 0 THEN 
-- 			RETURN NULL;
-- 		END IF;

	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;
	-- 	END IF;
	
		-- IF NEW.id_carga_itrack IS NOT NULL THEN 
-- 			SELECT nf.id_nota_fiscal_imp, empresa_emitente
-- 			INTO v_id_nota_fiscal_imp, v_empresa
-- 			FROM 
-- 				fila_documentos_integracoes fila
-- 				LEFT JOIN scr_notas_fiscais_imp nf
-- 					ON nf.id_nota_fiscal_imp = fila.id_nota_fiscal_imp
-- 			WHERE id_integracao = NEW.id_carga_itrack;
-- 
-- 			IF v_id_nota_fiscal_imp IS NOT NULL THEN 
-- 				NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
-- 				v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
-- 			END IF ;			
-- 		END IF;
	

		
		--SELECT * FROM edi_ocorrencias_entrega
		--SELECT * FROM scr_ocorrencia_edi ORDER BY 1
		--Tratamento das Ocorrencias
		
		SELECT id_ocorrencia_softlog 
		INTO v_codigo_ocorrencia 
		FROM edi_ocorrencias_vuupt
		WHERE codigo_vuupt = NEW.numero_ocorrencia;

		v_operacao_por_nota = 1;

		IF v_codigo_ocorrencia IS NULL THEN 
			RETURN NEW;
		END IF;
		--RAISE NOTICE 'Operacao por nota %', v_operacao_por_nota;
		IF v_operacao_por_nota = 1 THEN 

			v_codigo_ocorrencia = COALESCE(v_codigo_ocorrencia,1);

			IF NEW.data_ocorrencia IS NULL THEN
				--Se não tem data de baixa, seta status 2
				-- que é o indicativo de erro;
				NEW.status = 2;			
				RETURN NEW;
			END IF;

			--Coloca id da nota fiscal imp na variavel global 
			-- para trigger de ocorrencia automatica abortar insercao
			--PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

			--RAISE NOTICE 'Entrei aqui';
			
			IF NEW.url_imagem IS NOT NULL THEN 
				v_tem_canhoto = 1;
			ELSE
				v_tem_canhoto = 0;
			END IF;

			
			--Faz update na nota fiscal 
			UPDATE scr_notas_fiscais_imp nf
				SET 
					id_ocorrencia   = v_codigo_ocorrencia,
					data_ocorrencia = NEW.data_ocorrencia,
					nome_recebedor  = LEFT(NEW.recebedor,50),
					canhoto = v_tem_canhoto				
			WHERE
				nf.id_nota_fiscal_imp   = NEW.id_nota_fiscal_imp;


			

			OPEN v_cursor FOR 
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				v_codigo_ocorrencia,
				NEW.data_ocorrencia,
				now(),
				v_tem_canhoto)
			RETURNING id_ocorrencia_nf;

			FETCH v_cursor INTO v_id_ocorrencia_nota_fiscal_imp;

			CLOSE v_cursor;

			--Grava imagem se existir
			IF trim(NEW.url_imagem) = '' THEN 
				NEW.url_imagem = NULL;
			END IF;
			
			IF NEW.url_imagem IS NOT NULL THEN 
		
				va_img = string_to_array(NEW.url_imagem,';');
				tamanho = array_length(va_img,1);
				
				FOR i IN 1..tamanho LOOP
					IF va_img[i] <> '' THEN 
						INSERT INTO scr_docs_digitalizados (
							link_img,
							id_nota_fiscal_imp,
							id_ocorrencia_nota_fiscal_imp 
						)
						VALUES (
							va_img[i],
							NEW.id_nota_fiscal_imp,
							v_id_ocorrencia_nota_fiscal_imp
						);		
					END IF;
				END LOOP;

				UPDATE scr_notas_fiscais_imp 
					SET digitalizado = 1 
				WHERE 
					id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;	

							
			END IF;

			--Grava Log Atividades
			INSERT INTO scr_notas_fiscais_imp_log_atividades(
				id_nota_fiscal_imp, 
				data_hora, 
				atividade_executada, 
				usuario
				)
			VALUES (
				NEW.id_nota_fiscal_imp,
				now(),
				'OCORRENCIA via VUUPT Servico:' || NEW.id_ocorrencia_app::text,
				'suporte'
			);
			
		END IF;
	END IF;


	IF NEW.servico_integracao = 30  THEN 
		

		v_operacao_por_nota = 1;

		
		IF TG_OP = 'UPDATE' THEN 
			--RETURN NULL;
		END IF;

		SELECT id_nota_fiscal_imp
		INTO v_id_nota_fiscal_imp
		FROM scr_notas_fiscais_imp 
		WHERE chave_nfe = NEW.chave_nfe;

		NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
		
		v_codigo_ocorrencia = NEW.numero_ocorrencia;

		IF NEW.id_nota_fiscal_imp IS NOT NULL THEN 

			
			IF NEW.data_ocorrencia IS NULL THEN
				--Se não tem data de baixa, seta status 2
				-- que é o indicativo de erro;
				NEW.status = 2;			
				RETURN NEW;
			END IF;

			--Coloca id da nota fiscal imp na variavel global 
			-- para trigger de ocorrencia automatica abortar insercao
			PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

			
			--Faz update na nota fiscal 
			UPDATE scr_notas_fiscais_imp nf
				SET 
					id_ocorrencia   = v_codigo_ocorrencia,
					data_ocorrencia = NEW.data_ocorrencia,
					nome_recebedor  = LEFT(NEW.recebedor,50)
			WHERE
				nf.id_nota_fiscal_imp   = NEW.id_nota_fiscal_imp;


			

			OPEN v_cursor FOR 
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				v_codigo_ocorrencia,
				NEW.data_ocorrencia,
				now(),
				0)
			RETURNING id_ocorrencia_nf;

			FETCH v_cursor INTO v_id_ocorrencia_nota_fiscal_imp;

			CLOSE v_cursor;


			v_usuario = COALESCE(fp_get_session('pst_login'),'suporte');
			
			--Grava imagem se existir
			--Grava Log Atividades
			INSERT INTO scr_notas_fiscais_imp_log_atividades(
				id_nota_fiscal_imp, 
				data_hora, 
				atividade_executada, 
				usuario
				)
			VALUES (
				NEW.id_nota_fiscal_imp,
				now(),
				'OCORRENCIA via OCOREN Codigo:' || v_codigo_ocorrencia::text,
				'suporte'
			);
		END IF;
		
	END IF;


	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

