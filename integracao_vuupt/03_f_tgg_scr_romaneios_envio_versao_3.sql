-- Function: public.f_tgg_scr_romaneios_envio()

-- DROP FUNCTION public.f_tgg_scr_romaneios_envio();
--SELECT * FROM scr_romaneios ORDER BY 1 DESC LIMIT 100
CREATE OR REPLACE FUNCTION public.f_tgg_scr_romaneios_envio()
  RETURNS trigger AS
$BODY$
DECLARE
	v_lista_cnpj text;
	v_tem_parametro integer;
	has_comprovei integer;
	has_itrack integer;
	has_vuupt integer;
	has_notrexo integer;
	vEmpresa text;
	vEmitido integer;
	vExiste integer;
BEGIN

	vEmpresa = fp_get_session('pst_cod_empresa');
	
	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_COMPROVEI';	 


	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_itrack
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_ITRACK';	 

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_vuupt
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_VUUPT';	 

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_notrexo
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_NOTREXO';

	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND has_comprovei = 1 THEN 

		--RAISE NOTICE 'Scr Romaneios';
		
		IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
			RETURN NULL;
		END IF;

		IF NEW.emitido = 0 THEN 
			RETURN NULL;
		END IF;

		RAISE NOTICE 'Tem notificacao';

		SELECT 
			string_agg(cliente.cnpj_cpf,',') as lst_cnpj
		INTO 
			v_lista_cnpj
		FROM 		
			scr_romaneios r
			LEFT JOIN scr_romaneio_nf rnf
				ON rnf.id_romaneio = r.id_romaneio
			LEFT JOIN scr_notas_fiscais_imp nf
				ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
			RIGHT JOIN msg_subscricao sub
				ON sub.codigo_cliente = nf.remetente_id AND sub.id_notificacao = 1000
			LEFT JOIN cliente
				ON cliente.codigo_cliente = sub.codigo_cliente
		WHERE
			r.id_romaneio = NEW.id_romaneio
			AND sub.ativo = 1;

		
		
		IF v_lista_cnpj IS NOT NULL THEN 
			--Grava as informações na Fila
			INSERT INTO fila_envio_romaneios(id_notificacao, id_romaneio, cnpjs_subscritos)
			VALUES (1000, NEW.id_romaneio, v_lista_cnpj);
		END IF;		 
	END IF; 
	
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND NEW.tipo_destino = 'D' AND has_itrack = 1 THEN 

	
		RAISE NOTICE 'Verifica ITrack';
		BEGIN 
			IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				RETURN NULL;
			END IF;

			IF NEW.emitido = 0 THEN 
				RETURN NULL;
			END IF;
			
			SELECT COUNT(*) INTO v_tem_parametro 
			FROM fornecedores f
				LEFT JOIN fornecedor_parametros fp
					ON fp.id_fornecedor = f.id_fornecedor
			WHERE
				f.cnpj_cpf = NEW.cpf_motorista
				AND trim(fp.valor_parametro) = '1'
				AND fp.id_tipo_parametro = 2;

			IF v_tem_parametro = 0 THEN 
				RETURN NEW;
			END IF;

			RAISE NOTICE 'Motorista autorizado';

			INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
			SELECT 
				3,
				1,
				rnf.id_nota_fiscal_imp,
				r.id_romaneio
			FROM 		
				scr_romaneios r
				LEFT JOIN scr_romaneio_nf rnf
					ON rnf.id_romaneio = r.id_romaneio			
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp			
			WHERE
				r.id_romaneio = NEW.id_romaneio
				AND rnf.id_nota_fiscal_imp IS NOT NULL;

		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos ITrack';
			RETURN NEW;
		END;			
	END IF; 

	--SELECT * FROM fornecedor_parametros
	RAISE NOTICE 'Tem VUUPT %', has_vuupt;
	RAISE NOTICE 'Redespacho %', COALESCE(NEW.id_transportador_redespacho,0);
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND has_vuupt = 1 THEN 

	
		RAISE NOTICE 'INTEGRACAO VUUPT';
 		BEGIN 

			

		
			IF NEW.emitido = 1 THEN 

				IF OLD.emitido = 1 THEN 
					RETURN NULL;
				END IF;

				RAISE NOTICE 'Romaneio Emitido';

				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista				
					AND fp.id_tipo_parametro = 5;

				RAISE NOTICE 'Parametro %', v_tem_parametro;
				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;

				--SELECT * FROM fornecedor_tipo_parametros
				RAISE NOTICE 'Motorista autorizado';
				--SELECT * FROM cliente_parametros


				SELECT 	count(*) 
				INTO 	vExiste
				FROM 	fila_documentos_integracoes
				WHERE 	id_romaneio = NEW.id_romaneio AND tipo_documento = 4;

				IF vExiste > 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Enfileirando';

				--Servicos
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				SELECT 
					5,
					1,
					nf.id_nota_fiscal_imp,
					r.id_romaneio
				FROM 		
					scr_romaneios r				
					LEFT JOIN scr_notas_fiscais_imp nf
						ON nf.id_romaneio = r.id_romaneio
				WHERE
					r.id_romaneio = NEW.id_romaneio;

				--Agrupamento Entrega
				WITH t AS (
				
					SELECT 
						MIN(fd.id) as nf_principal,					
						fd.id_romaneio
					FROM 		
						fila_documentos_integracoes fd										
						LEFT JOIN scr_notas_fiscais_imp nf
							ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
					WHERE
						fd.id_romaneio = NEW.id_romaneio
						AND fd.tipo_documento = 1
						AND fd.tipo_integracao = 5
					GROUP BY 
						nf.destinatario_id,
						fd.id_romaneio
				) 
				UPDATE fila_documentos_integracoes SET 
					principal = 1 
				FROM t
				WHERE t.nf_principal = fila_documentos_integracoes.id;
					
								
					
					

				--Romaneios
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_romaneio)
				VALUES (5,4,NEW.id_romaneio);
				
			END IF;

		 EXCEPTION WHEN OTHERS THEN 
 			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
 			RETURN NEW;
 		END;			
	END IF;     

	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND has_vuupt = 1 THEN 

		
			RAISE NOTICE 'INTEGRACAO VUUPT';
			BEGIN 

				IF NEW.id_romaneio IS NULL AND OLD.id_romaneio IS NOT NULL THEN 
				
					INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_integracao, id_nota_fiscal_imp, id_romaneio)
					SELECT 
						5,
						-1,
						fdi.id_integracao,
						fdi.id_nota_fiscal_imp,
						fdi.id_romaneio
					FROM 		
						fila_documentos_integracoes fdi					
					WHERE
						id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
						AND id_romaneio = OLD.id_romaneio
						AND tipo_documento = 1;				

				END IF;

			 EXCEPTION WHEN OTHERS THEN 
				RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
				RETURN NEW;
			END;			
	END IF; 

	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND has_notrexo = 1 THEN 

	
		RAISE NOTICE 'INTEGRACAO ';
 		BEGIN 

			

		
			IF NEW.emitido = 1 THEN 

				IF OLD.emitido = 1 THEN 
					RETURN NULL;
				END IF;

				RAISE NOTICE 'Romaneio Emitido';

				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista				
					AND fp.id_tipo_parametro = 5;

				RAISE NOTICE 'Parametro %', v_tem_parametro;
				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;

				--SELECT * FROM fornecedor_tipo_parametros
				RAISE NOTICE 'Motorista autorizado';
				--SELECT * FROM cliente_parametros


				SELECT 	count(*) 
				INTO 	vExiste
				FROM 	fila_documentos_integracoes
				WHERE 	id_romaneio = NEW.id_romaneio AND tipo_documento = 4;

				IF vExiste > 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Enfileirando';

				--Servicos
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				SELECT 
					5,
					1,
					nf.id_nota_fiscal_imp,
					r.id_romaneio
				FROM 		
					scr_romaneios r				
					LEFT JOIN scr_notas_fiscais_imp nf
						ON nf.id_romaneio = r.id_romaneio
				WHERE
					r.id_romaneio = NEW.id_romaneio;

				--Agrupamento Entrega
				WITH t AS (
				
					SELECT 
						MIN(fd.id) as nf_principal,					
						fd.id_romaneio
					FROM 		
						fila_documentos_integracoes fd										
						LEFT JOIN scr_notas_fiscais_imp nf
							ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
					WHERE
						fd.id_romaneio = NEW.id_romaneio
						AND fd.tipo_documento = 1
						AND fd.tipo_integracao = 5
					GROUP BY 
						nf.destinatario_id,
						fd.id_romaneio
				) 
				UPDATE fila_documentos_integracoes SET 
					principal = 1 
				FROM t
				WHERE t.nf_principal = fila_documentos_integracoes.id;
					
								
					
					

				--Romaneios
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_romaneio)
				VALUES (5,4,NEW.id_romaneio);
				
			END IF;

		 EXCEPTION WHEN OTHERS THEN 
 			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
 			RETURN NEW;
 		END;			
	END IF; 
	    
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

/*
SELECT * FROM fornecedor_tipo_parametros
SELECT id_romaneio FROM scr_romaneios ORDER BY id_romaneio DESC LIMIT 10

SELECT * FROM fila_documentos_integracoes WHERE tipo_documento = 4 ORDER BY 1 DESC LIMIT 10;

SELECT fp_set_session('pst_cod_empresa','001')
5472

SELECT id_romaneio, tipo_destino, cpf_motorista, emitido FROM scr_romaneios WHERE numero_romaneio = '0020010052165'
BEGIN;
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio IN (115381);
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio IN (115381);
COMMIT;
ROLLBACK;

DELETE FROM fila_documentos_integracoes WHERE id_nota_fiscal_imp IS NULL

UPDATE fila_documentos_integracoes SET qt_tentativas = 1 WHERE pendencia = 1 AND enviado = 0 AND data_registro::date  = current_date

SELECT chave_nfe FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 11833662
	SELECT * FROM fila_documentos_integracoes WHERE pendencia = 1 AND enviado = 0 AND data_registro::date  = current_date
	SELECT * FROM fila_documentos_integracoes ORDER BY 1

	SELECT numero_nota_fiscal FROm scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 11462982

			SELECT 
				string_agg(nf.id_nota_fiscal_imp::text, ',') as lst
			FROM 		
				scr_romaneios r
				LEFT JOIN scr_romaneio_nf rnf
					ON rnf.id_romaneio = r.id_romaneio			
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp			
-- 				RIGHT JOIN cliente_parametros cp
-- 					ON nf.consignatario_id =  cp.codigo_cliente 
-- 					AND cp.id_tipo_parametro = 1000			
			WHERE
				r.id_romaneio = 71756
				AND rnf.id_nota_fiscal_imp IS NOT NULL;



	11462985


        SELECT
		*
        FROM
            fila_documentos_integracoes
        WHERE
		id_nota_fiscal_imp IN (11954118,12075763,12075763,12084282,12084282,12084307,12084307,12084310,12084312,12084353,12084356,12084363,12084369,12084475,12084479,12084683,12084726,12084749,12084936,12084988,12086258,12086292,12086897,12087286,12087302,12087311,12087319,12087322,12087323,12087325,12087330,12087341,12087350,12087359,12087402,12087413,12087442,12087446,12087447,12087476,12087487,12087488,12087542,12087664,12090594,12090595,12090602,12090603,12090604,12090605,12090606,12090612,12090613,12090614,12090616,12090617,12090618,12090619,12090620,12090621,12090622,12090624,12090625,12090626,12090627,12090782,12090824,12090825,12090826,12090828,12090832,12090833,12090912,12090913,12090914,12090961,12090963,12091001,12091002,12091003,12091004,12091006,12091007,12091008,12091065,12091067,12091083,12092378,12100245,12100248)

            enviado = 1
            AND pendencia = 1
            AND tipo_documento = 1
            AND tipo_integracao = 3

            UPDATE fila_documentos_integracoes SET qt_tentativas = 2 WHERE id_integracao = -1 AND data_registro::date = current_date
*/

