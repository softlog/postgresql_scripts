-- Function: public.f_tgg_scr_romaneios_envio()
--has_n
-- DROP FUNCTION public.f_tgg_scr_romaneios_envio();
/*
INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, lst_documentos, id_romaneio, data_registro)
				WITH t AS (
					SELECT 
						(((row_number() over (partition by id_romaneio order by id_nota_fiscal_imp))-1)/150)::integer as grupo,
						id_romaneio,
						id_nota_fiscal_imp,
						now() 
					FROM 
						scr_romaneio_nf
					WHERE 
						id_romaneio = 207948)
SELECT 10, 1, string_agg(id_nota_fiscal_imp::text, ',') as lista, 207948, now() FROM t GROUP BY grupo;

SELECT id_romaneio, emitido, numero_romaneio FROM scr_romaneios WHERE id_romaneio = 209934
 numero_romaneio = '0010010017853'
SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 209934
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 19459;
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 19459;

SELECT id_nota_fiscal_imp FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 17991 AND data_expedicao = '2021-05-10'




*/

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
	has_alper integer;
	vEmpresa text;
	vEmitido integer;
	vExiste integer;
	vExecuta boolean;
BEGIN

	vEmpresa = fp_get_session('pst_cod_empresa');
	RAISE NOTICE 'EMPRESA %s',vEmpresa;
	
	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_COMPROVEI';	 

	RAISE NOTICE 'Comprovei %', has_comprovei;

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

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_alper
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_ALPER';



	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_alper,0) = 1  THEN 

		RAISE NOTICE 'Verifica Alper';
		BEGIN 
			vExecuta = true;

			
			IF COALESCE(NEW.emitido,0) = COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				vExecuta = false;
			END IF;

			IF NEW.emitido = 0 THEN 
				vExecuta = false;
			END IF;			

			IF vExecuta THEN 

				/*
				
				--SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 190497
				
				UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE id_romaneio = 190497;
				
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
				SELECT * FROM fila_documentos_integracoes ORDER BY 1 DESC LIMIT 10000

				WITH t AS (
					SELECT 
						(((row_number() over (partition by id_romaneio order by id_nota_fiscal_imp))-1)/150)::integer as grupo,
						id_romaneio,
						id_nota_fiscal_imp
					FROM 
						scr_romaneio_nf
					WHERE 
						id_romaneio = 190497
				) 
				SELECT string_agg(id_nota_fiscal_imp::text, ',') as lista FROM t GROUP BY grupo

				SELECT 
					count(*) as qt, 
					id_romaneio 
				FROM 
					fila_documentos_integracoes 
				WHERE 
					id_romaneio IS NOT NULL 
				GROUP BY id_romaneio 
				HAVING count(*) > 149

				SELECT * FROM fila_documentos_integracoes WHERE lst_documentos IS NOT NULL 
				
				*/
				
				
				
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, lst_documentos, id_romaneio, data_registro)
				WITH t AS (
					SELECT 
						(((row_number() over (partition by id_romaneio order by id_nota_fiscal_imp))-1)/150)::integer as grupo,
						id_romaneio,
						id_nota_fiscal_imp,
						now() 
					FROM 
						scr_romaneio_nf
					WHERE 
						id_romaneio = NEW.id_romaneio
						AND NOT EXISTS(
							SELECT 1 
							FROM fila_documentos_integracoes 
							WHERE lst_documentos LIKE '%' || scr_romaneio_nf.id_nota_fiscal_imp::text || '%'
								AND fila_documentos_integracoes.id_romaneio = NEW.id_romaneio
						)
				) 
				SELECT 10, 1, string_agg(id_nota_fiscal_imp::text, ',') as lista, NEW.id_romaneio, now() FROM t GROUP BY grupo;

				/*
				BEGIN;
				
				UPDATE fila_documentos_integracoes SET enviado = 1 WHERE enviado = 0 AND pendencia = 0 AND tipo_integracao = 10
				COMMIT;
				ROLLBACK;
				SELECT numero_nota_fiscal, chave_nfe FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp IN (6489103,6489104,6489105,6489106,6489107,6489108,6489109,6489110,6489111,6489112,6489113,6489114,6489115,6489116,6489117,6489118,6489119,6489120,6489121,6489122,6489123,6489124,6489125,6489126,6489127,6489128,6489129,6489130,6489131,6489132,6489133,6489134,6489135,6489136,6489137,6489138,6489139,6489140,6489141,6489142,6489143,6489144,6489145,6489146,6489147,6489148,6489149,6489150,6489151,6489152,6489153,6489154,6489155,6489156,6489157,6489158,6489159,6489160,6489161,6489162,6489163,6489164,6489165,6489166,6489167,6489168,6489169,6489170,6489171,6489172,6489173,6489174,6489175,6489176,6489177,6489178,6489179,6489180,6489181,6489182,6489183,6489184,6489185,6489186,6489187,6489188,6489189,6489190,6489191,6489192,6489193,6489194,6489195,6489196,6489197,6489198,6489199,6489200,6489201,6489202,6489203,6489204,6489205,6489206,6489207,6489208,6489209,6489210,6489211,6489212,6489213,6489214,6489215,6490918,6490919,6490920,6490921,6490922,6490923,6490924,6490925,6490926,6490927,6490928,6490929,6490930,6490931,6490932,6491333,6491354,6491358,6491360,6491370,6491386,6491389,6491390,6491391,6491392,6491393,6491445,6491483,6491499,6491512,6491513,6491514,6491515,6491516,6491517,6491519,6491520)
				*/

				/*
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				SELECT 
					10,
					1,
					rnf.id_nota_fiscal_imp,
					r.id_romaneio
				FROM 		
					scr_romaneios r
					LEFT JOIN scr_romaneio_nf rnf
						ON rnf.id_romaneio = r.id_romaneio								
				WHERE
					r.id_romaneio = NEW.id_romaneio
					AND rnf.id_nota_fiscal_imp IS NOT NULL;
				*/
				
			END IF;

		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos Alper';
			RETURN NEW;
		END;	
	END IF; 

	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_comprovei,0) = 1   THEN 

		RAISE NOTICE 'Integracao Comprovei';
		--RAISE NOTICE 'Scr Romaneios';
		vExecuta = true;
		IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
			vExecuta = false;
		END IF;

		IF NEW.emitido = 0 THEN 
			vExecuta = false;
		END IF;

		IF NEW.dispara_integracao = 1 THEN
			vExecuta = true;
		END IF;

		IF vExecuta THEN 
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
	END IF; 
	
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND NEW.tipo_destino = 'D' AND COALESCE(has_itrack,0) = 1 THEN 

	
		RAISE NOTICE 'Verifica ITrack';
		BEGIN 
			vExecuta = true;
			
			IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				vExecuta = false;
			END IF;

			IF NEW.emitido = 0 THEN 
				vExecuta = false;
			END IF;

			IF vExecuta THEN 
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


				/*
				SELECT COUNT(*) INTO v_tem_parametro 
				FROM cliente c
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = c.codigo_cliente
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista
					AND trim(fp.valor_parametro) = '1'
					AND fp.id_tipo_parametro = 2;

				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;
				*/

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
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = nf.remetente_id
								AND cp.id_tipo_parametro = 1000
				WHERE
					r.id_romaneio = NEW.id_romaneio
					AND rnf.id_nota_fiscal_imp IS NOT NULL
					AND COALESCE(cp.valor_parametro, '0') = '1';
			END IF;

		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos ITrack';
			RETURN NEW;
		END;			
	END IF; 

	--SELECT * FROM fornecedor_parametros
	--RAISE NOTICE 'Tem VUUPT %', has_vuupt;
	--RAISE NOTICE 'Redespacho %', COALESCE(NEW.id_transportador_redespacho,0);
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND COALESCE(has_vuupt,0) = 1 THEN 

	
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

	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND COALESCE(has_vuupt,0) = 1 THEN 

		
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

	RAISE NOTICE 'Tem NOTREXO %', has_notrexo;			
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_notrexo,0) = 1 THEN 

	
		RAISE NOTICE 'INTEGRACAO NOTREXO';
 		BEGIN 

			
	
			IF NEW.dispara_integracao = 1 THEN 


				RAISE NOTICE 'Romaneio Emitido';

				--TODO 

				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista				
					AND fp.id_tipo_parametro = 6;

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
				WHERE 	id_romaneio = NEW.id_romaneio AND tipo_documento = 6;

				IF vExiste > 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Enfileirando';

				
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				VALUES (6,4,NULL, NEW.id_romaneio);

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

