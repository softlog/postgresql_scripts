-- Function: public.f_tgg_scr_romaneios_envio()
--has_n
-- DROP FUNCTION public.f_tgg_scr_romaneios_envio();
/*

SELECT * FROM msg_fila_averb_atm WHERE is_nfe = 1

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
						id_romaneio = 207948);
						
SELECT 10, 1, string_agg(id_nota_fiscal_imp::text, ',') as lista, 207948, now() FROM t GROUP BY grupo;

SELECT id_romaneio, emitido, numero_romaneio, cpf_motorista, tipo_destino FROM scr_romaneios WHERE numero_romaneio = '0010010033462'
SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 46666

SELECT fp_set_session('pst_cod_empresa','001');
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio IN (11793,11791,11795,11796,11798,11797,11799,11800,11801,11802,11803,11808,11806,11807,11816,11805,11811,11818,11810,11819,11813,11812,11809,11804);
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio IN (11793,11791,11795,11796,11798,11797,11799,11800,11801,11802,11803,11808,11806,11807,11816,11805,11811,11818,11810,11819,11813,11812,11809,11804)

SELECT id_nota_fiscal_imp FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 17991 AND data_expedicao = '2021-05-10';

SELECT id_romaneio, emitido, numero_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010206031'

SELECT string_agg(id_romaneio::text,',') FROM scr_romaneios WHERE data_romaneio >= current_date::timestamp AND emitido = 1 AND cancelado = 0;
SELECT * FROM fila_documentos_integracoes WHERE enviado = 0 AND tipo_integracao = 11

SELECT nf.id_nota_fiscal_imp, nf.chave_nfe, mensagens::text FROM fila_documentos_integracoes LEFT JOIN scr_notas_fiscais_imp nf ON nf.id_nota_fiscal_imp = fila_documentos_integracoes.id_nota_fiscal_imp WHERE fila_documentos_integracoes.data_registro >= '2021-06-29'::timestamp  AND id_integracao = -1
ORDER BY 1 DESC LIMIT 1000
WHERE tipo_integracao = 3

SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 12870
id_nota_fiscal_imp = 792803


SELECT * FROM fila_documentos_integracoes WHERE tipo_documento = 1 ORDER BY 1 DESC LIMIT 10000

SELECT * FROM fila_documentos_integracoes ORDER BY 1 DESC LIMIT 10000

SELECT * FROM scr_romaneio_nf WHERE id_romaneio = 231136
SELECT lpad('1',3,'0')
SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 231136 ORDER BY id DESC 

UPDATE fila_envio_romaneios SET status_confirmacao = 0, data_registro = NOW() WHERE id = 6526
WHERE id_romaneio = 225529


SELECT * FROM scr_romaneios WHERE id_romaneio = 15324

SELECT id_romaneio, emitido FROM scr_romaneios WHERE numero_romaneio = '0010010197940'
SELECT COUNT(*) 
FROM fornecedores f
	LEFT JOIN fornecedor_parametros fp
		ON fp.id_fornecedor = f.id_fornecedor
WHERE
	f.cnpj_cpf = '53747810578'
	AND trim(fp.valor_parametro) = '1'
	AND fp.id_tipo_parametro = 2;

SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010032899';



SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 232897



SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 46666



SELECT * FROM scr_romaneio_nf WHERE id_nota_fiscal_imp = 792803

	SELECT 
		string_agg(cliente.cnpj_cpf,',') as lst_cnpj
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
		r.id_romaneio = 225529
		AND sub.ativo = 1;

		SELECT * FROM msg_subscricao WHERE id_notificacao = 1000

	SELECT * FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 58435
	SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010040012590'
	SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010206036'


	UPDATE fila_envio_romaneios SET data_registro = now() WHERE status_envio = 0 AND data_registro > '2021-11-10 00:00:00'
	id_ocorrencia_nf = 27152493
	SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 ORDER BY 1 DESC LIMIT 100
	WHERE id_nota_fiscal_imp = 20559072
	id_tipo_servico = 2 ORDER BY 1 DESC
	COMMIT;

	SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 20559072
	SELECT * FROM scr_romaneios 	

	SELECT id_romaneio, emitido, numero_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010206031'
	UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 46666;
	UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 46666

	SELECT fp_set_session('pst_cod_empresa', '001')
	ROLLBACK;
	BEGIN;
	UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 244684;
	UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 244684;
	SELECT * FROM fila_envio_romaneios WHERE id_romaneio IN (244684);
	COMMIT;
*/

CREATE OR REPLACE FUNCTION public.f_tgg_scr_romaneios_envio()
  RETURNS trigger AS
$BODY$
DECLARE
	v_lista_cnpj text;
	v_lista_nf text;
	v_tem_parametro integer;
	has_comprovei integer;
	has_comprovei_oco integer;
	has_itrack integer;
	has_vuupt integer;
	has_notrexo integer;
	has_alper integer;
	has_krona integer;
	
	vEmpresa text;
	vEmitido integer;
	vExiste integer;
	vExecuta boolean;
	vRomaneioTransferencia integer;
	has_comprovei_total integer;
BEGIN

	vEmpresa = fp_get_session('pst_cod_empresa');
	RAISE NOTICE 'EMPRESA %s',vEmpresa;
	
	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_COMPROVEI';	 

--	RAISE NOTICE 'Comprovei %', has_comprovei;

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei_oco
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_OCORRENCIAS_COMPROVEI';	 


	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei_total
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_COMPROVEI_TODOS';	 

	has_comprovei_total = COALESCE(has_comprovei_total,0);


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


	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_krona
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_KRONA';
	





	
	-- Tabela de scr_romaneios 	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_krona,0) = 1 THEN 

		RAISE NOTICE 'Verifica Krona';
		BEGIN 
		
			vExecuta = true;

			--Envia para Krona apenas se tiver origem informada
			IF COALESCE(NEW.id_remetente_origem,0) = 0 THEN 
				vExecuta = False;
			END IF;

			--Envia para Krona apenas quando muda o status para emitido.
			IF COALESCE(NEW.emitido,0) = COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				vExecuta = False;
			END IF;


			--Nao envia se nao tiver emitido
			IF NEW.emitido = 0 THEN 
				vExecuta = False;
			END IF;		

			

			--Verifica se o motorista esta autorizado pelo Krona.
			SELECT 
				count(*) 
			INTO 
				v_tem_parametro 
			FROM 
				fornecedores f
				LEFT JOIN fornecedor_parametros fp
					ON fp.id_fornecedor = f.id_fornecedor
			WHERE
				f.id_fornecedor = NEW.id_motorista
				--AND trim(fp.valor_parametro) = '1'
				AND fp.id_tipo_parametro = 12;
				

			---35235207890   

			IF v_tem_parametro = 0 THEN 				
				vExecuta = False;
			ELSE
				RAISE NOTICE 'Motorista autorizado';
			END IF;

			IF vExecuta THEN 
			
				SELECT count(*) as qt 
				INTO vExiste
				FROM fila_documentos_integracoes
				WHERE 
					id_romaneio = NEW.id_romaneio 
					AND tipo_integracao = 11 
					AND tipo_documento = 2;

				IF vExiste > 0 THEN 
					vExecuta = False;			
				END IF;
				
			END IF;

			
			
			IF vExecuta THEN 

				RAISE NOTICE 'Executa Integracao';

				/*
				SELECT * FROM fornecedor_parametros WHERE id_tipo_parametro = 12
				SELECT 
					*
				FROM 
					fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					1=1
					AND f.id_fornecedor = 1277
					AND trim(fp.valor_parametro) = '1'
					AND fp.id_tipo_parametro = 12;
					

SELECT
            id,
            f_get_dados_romaneio_krona(id_romaneio, '%(usuario)s', '%(password)s') as dados,
            id_romaneio
        FROM
            fila_documentos_integracoes
        WHERE
            enviado = 0
            AND pendencia = 0
            AND tipo_integracao = 11
            AND qt_tentativas < 4
        ORDER BY
            1
				SELECT fp_set_session('pst_cod_empresa', '001')
				UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 43106;
				UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 43106

				SELECT id_romaneio, cpf_motorista, id_motorista FROM scr_romaneios WHERE numero_romaneio = '0010010030763'
				
				SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 43106
				
				UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE id_romaneio = 190497;
				SELECT * FROM 
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

				SELECT * FROM fila_documentos_integracoes WHERE tipo_integracao = 11
				
				*/				
				
				
				
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, lst_documentos, id_romaneio, data_registro)
				
				VALUES (11, 2, NULL, NEW.id_romaneio, now());
				

				RAISE NOTICE 'Romaneio %', NEW.id_romaneio;

				
				
			END IF;

		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos KRONA';
			--RETURN NEW;
		END;	
	END IF; 


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
				RAISE NOTICE 'Executa Integracao';
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

				RAISE NOTICE 'Romaneio %', NEW.id_romaneio;

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
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_comprovei,0) = 1   AND COALESCE(has_comprovei_oco,0) = 0 THEN 


		
		
		RAISE NOTICE 'Integracao Comprovei';
		BEGIN
			--RAISE NOTICE 'Scr Romaneios';
			vExecuta = true;
			IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				RAISE NOTICE 'Sem alteracao status para emitido';
				vExecuta = false;
			END IF;

			IF NEW.emitido = 0 THEN 
				RAISE NOTICE 'Nao emitido';
				vExecuta = false;
			ELSE 
				RAISE NOTICE 'Emitido';
			END IF;
			
			IF NEW.dispara_integracao = 1 THEN
				RAISE NOTICE 'Forca Importacao';
				vExecuta = true;
			END IF;

			RAISE NOTICE 'Verifica transferencia';
			SELECT 	(COALESCE(valor_parametro,'1'))::integer
			INTO 	vRomaneioTransferencia
			FROM 	parametros 
			WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_TRANSFERENCIA_COMPROVEI';

			vRomaneioTransferencia = COALESCE(vRomaneioTransferencia,1);
			
			IF NEW.tipo_destino = 'T' AND vRomaneioTransferencia = 0 THEN 
				RAISE NOTICE 'NAO ENVIA TRANSFERENCIA';
				vExecuta = false;
			ELSE 
				RAISE NOTICE 'ENVIA TRANSFERENCIA';
			END IF;

			
		
			IF vExecuta THEN 
				RAISE NOTICE 'Executa Integracao';


				IF has_comprovei_total = 0 THEN 
					SELECT 
						string_agg(cliente.cnpj_cpf,',') as lst_cnpj,
						string_agg(rnf.id_nota_fiscal_imp::text,',') as lst_nf
					INTO 
						v_lista_cnpj,
						v_lista_nf
					
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
				ELSE
					SELECT 
						string_agg(cliente.cnpj_cpf,',') as lst_cnpj,
						string_agg(rnf.id_nota_fiscal_imp::text,',') as lst_nf
					INTO 
						v_lista_cnpj,
						v_lista_nf
					
					FROM 		
						scr_romaneios r
						LEFT JOIN scr_romaneio_nf rnf
							ON rnf.id_romaneio = r.id_romaneio
						LEFT JOIN scr_notas_fiscais_imp nf
							ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
						LEFT JOIN cliente
							ON cliente.codigo_cliente = nf.remetente_id
					WHERE
						r.id_romaneio = NEW.id_romaneio;
						
				END IF;
								
				--SELECT * FROM msg_notificacao ORDER BY 1 
				RAISE NOTICE 'Verifica se envia';
				IF v_lista_cnpj IS NOT NULL THEN 
					--Grava as informações na Fila
					INSERT INTO fila_envio_romaneios(id_notificacao, id_romaneio, cnpjs_subscritos, lst_notas_fiscais)
					VALUES (1000, NEW.id_romaneio, v_lista_cnpj, v_lista_nf);
				ELSE 
					RAISE NOTICE 'Cliente não configurado ';
				END IF;		 
			END IF;
			
		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos Comprovei';
			RETURN NEW;
		END;

		
	END IF; 


	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_comprovei_oco,0) = 1   THEN 


		
		
		RAISE NOTICE 'Integracao Comprovei';
		BEGIN
			--RAISE NOTICE 'Scr Romaneios';
			vExecuta = true;
			IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				RAISE NOTICE 'Sem alteracao status para emitido';
				vExecuta = false;
			END IF;

			IF NEW.emitido = 0 THEN 
				RAISE NOTICE 'Nao emitido';
				vExecuta = false;
			ELSE 
				RAISE NOTICE 'Emitido';
			END IF;
			
			IF NEW.dispara_integracao = 1 THEN
				RAISE NOTICE 'Forca Importacao';
				vExecuta = true;
			END IF;

			RAISE NOTICE 'Verifica transferencia';
			SELECT 	(COALESCE(valor_parametro,'1'))::integer
			INTO 	vRomaneioTransferencia
			FROM 	parametros 
			WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_TRANSFERENCIA_COMPROVEI';

			vRomaneioTransferencia = COALESCE(vRomaneioTransferencia,1);
			
			IF NEW.tipo_destino = 'T' AND vRomaneioTransferencia = 0 THEN 
				RAISE NOTICE 'NAO ENVIA TRANSFERENCIA';
				vExecuta = false;
			ELSE 
				RAISE NOTICE 'ENVIA TRANSFERENCIA';
			END IF;
			
		
			IF vExecuta THEN 

				RAISE NOTICE 'Executa Integracao';


				
				SELECT 
					string_agg(cliente.cnpj_cpf,',') as lst_cnpj,
					string_agg(rnf.id_nota_fiscal_imp::text, ',') as lst_nf
				INTO 
					v_lista_cnpj,
					v_lista_nf
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

				--SELECT * FROM msg_notificacao ORDER BY 1 
				-- RAISE NOTICE 'Verifica se envia';
				IF v_lista_cnpj IS NOT NULL THEN 
					--Grava as informações na Fila
					INSERT INTO fila_envio_romaneios(id_notificacao, id_tipo_servico, id_romaneio, cnpjs_subscritos, lst_notas_fiscais)
					SELECT 
						1000, 
						2, 
						NEW.id_romaneio, 
						v_lista_cnpj,
						v_lista_nf
					WHERE NOT EXISTS (SELECT 1 
							  FROM fila_envio_romaneios 
							  WHERE fila_envio_romaneios.id_romaneio = NEW.id_romaneio 
							  AND id_notificacao = 1000 AND id_tipo_servico = 2
					);
					

				ELSE 
					RAISE NOTICE 'Cliente não configurado ';
				END IF;		 
			END IF;
		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos Comprovei';
			RETURN NEW;
		END;

		
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
					AND COALESCE(cp.valor_parametro, '0') = '1'
					AND NOT EXISTS (SELECT 1 
							FROM fila_documentos_integracoes
							WHERE id_romaneio = NEW.id_romaneio 
							AND id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
							AND tipo_integracao = 3
							) ;
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

--DROP TRIGGER tgg_scr_romaneios_envio ON public.scr_romaneios;

