-- Function: public.edi_ocorrencias_entrega()
-- SELECT * FROM edi_ocorrencias_entrega WHERE id = 2048851
/*
SELECT count(*) from edi_ocorrencias_entrega
BEGIN;
UPDATE edi_ocorrencias_entrega SET id = id WHERE id = 2114852;
ROLLBACK;
BEGIN;
UPDATE edi_ocorrencias_entrega SET id = id WHERE id = 6065560



SELECT id_nota_fiscal_imp, chave_nfe, remetente_nome, data_emissao, id_ocorrencia FROm v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 000100496 ORDER BY data_emissao DESC;

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 19950218

ROLLBACK;
*/
--SELECT * FROM edi_ocorrencias_edi  WHERE chave_nfe = '35210416619378000108550200006209081304429734'
-- SELECT * FROM edi_ocorrencias_entrega WHERE chave_nfe = '35210416619378000108550200006209081304429734'
-- SELECT * FROM f_get_div_docs_digitalizado('1217',3)
-- SELECT id_nota_fiscal_imp, data_registro, id_ocorrencia, data_ocorrencia, id_romaneio FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210402057329000114550000011630151520559845'
-- SELECT * FROM scr_conhecimento
-- SELECT id_nota_fiscal_imp, chave_nfe FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::integer = 1163015
--SELECT * FROM scr_romaneio_nf WHERE id_nota_fiscal_imp = 18453343
-- SELECT * FROM scr_conhecimento_notas_fiscais WHERE chave_nfe = '35210463957302000172550010016678911235647845'
-- SELECT * FROM scr_conhecimento_ocorrencias_nf WHERE id_conhecimento_notas_fiscais = 597294
-- DROP FUNCTION public.edi_ocorrencias_entrega();
-- SELECT * FROM scr_romaneios WHERE id_romaneio IN (160802,160769,160782)
--SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp = 19015391
--SELECT * FROM fornecedores WHERE cnpj_cpf = '06979529676'


/*

SELECT * FROM edi_ocorrencias_entrega WHERE uuid_usuario = 'p7BCfbWUcXbjt5XQIE43'

SELECT * FROM edi_ocorrencias_entrega WHERE chave_nfe = '35210522892980000117550010003920821977824937'

SELECT * FROM edi_ocorrencias_entrega WHERE id_nota_fiscal_imp = 19436901

UPDATE edi_ocorrencias_entrega SET id=id WHERE id = 5479651

SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp = 19436901


SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 19436901

SELECT id_ocorrencia FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 19436901
SELECT 
	nf.id_nota_fiscal_imp, 
	nf.data_ocorrencia,
	c.data_emissao
FROM 
	scr_notas_fiscais_imp nf
	LEFT JOIN scr_conhecimento c
		ON c.id_conhecimento = nf.id_conhecimento
WHERE 
	numero_nota_fiscal::integer IN (1135275, 1135361,1135487,1135488,1135514,1135572,1135624);


SELECT * FROM edi_ocorrencias_entrega WHERE id_nota_fiscal_imp IN (744330,744455,744685,744689,744732,744763,744796)
BEGIN;
WITH t AS (
	SELECT 

	
		*		
	FROM 
		edi_ocorrencias_entrega 
		
	WHERE 
		NOT EXISTS (SELECT 1 FROM scr_notas_fiscais_imp_ocorrencias nfo					
			    WHERE nfo.id_nota_fiscal_imp = edi_ocorrencias_entrega.id_nota_fiscal_imp AND edi_ocorrencias_entrega.numero_ocorrencia = nfo.id_ocorrencia)
		AND edi_ocorrencias_entrega.data_importacao >= '2021-05-14'::timestamp
		
		
		
)
UPDATE edi_ocorrencias_entrega SET id = id WHERE EXISTS (SELECT 1 FROM t WHERE t.id = edi_ocorrencias_entrega.id)



SELECT 
	string_agg(nf.id_nota_fiscal_imp::text, ',') as lst_nfe,
	nf.chave_nfe,	
	max(nf.id_ocorrencia) as id_ocorrencia,	
	nf.data_registro::date as data_registro
FROM 
	scr_notas_fiscais_imp nf
WHERE 
	nf.data_registro >= '2021-03-01 00:00:00'
GROUP BY 
	nf.chave_nfe,
	nf.data_registro::date
HAVING max(nf.id_ocorrencia) = 1 AND count(*) > 1 AND min(nf.id_ocorrencia) = 1

WITH t AS (
	SELECT 
		*
		
	FROM 
		edi_ocorrencias_entrega 
	
		
	WHERE 
		NOT EXISTS (SELECT 1 FROM scr_notas_fiscais_imp_ocorrencias nfo					
			    WHERE nfo.id_nota_fiscal_imp = edi_ocorrencias_entrega.id_nota_fiscal_imp AND edi_ocorrencias_entrega.numero_ocorrencia = nfo.id_ocorrencia)
		AND edi_ocorrencias_entrega.data_importacao >= '2021-03-01'::timestamp
)
SELECT * FROM t



UPDATE edi_ocorrencias_entrega SET id = id WHERE id = 29919

WITH t AS (
	SELECT 
		id,
		nf.id_nota_fiscal_imp,
		nf.chave_nfe
	FROM 
		edi_ocorrencias_entrega 
		LEFT JOIN scr_notas_fiscais_imp nf
			ON nf.chave_nfe = edi_ocorrencias_entrega.chave_nfe
		
	WHERE 
		NOT EXISTS (SELECT 1 FROM scr_notas_fiscais_imp_ocorrencias nfo					
			    WHERE nf.chave_nfe = edi_ocorrencias_entrega.chave_nfe AND edi_ocorrencias_entrega.numero_ocorrencia = nfo.id_ocorrencia)
		AND edi_ocorrencias_entrega.data_importacao >= '2021-03-12'::timestamp
		
		
)
UPDATE edi_ocorrencias_entrega SET id = id WHERE EXISTS (SELECT 1 FROM t WHERE t.id = edi_ocorrencias_entrega.id)


*/


/*
 SELECT * FROM edi_ocorrencias_entrega WHERE servico_integracao = 4
update edi_ocorrencias_entrega SET id = id where id_conhecimento IS NULL AND servico_integracao = 1
-- SELECT * FROM edi_ocorrencias_entrega WHERE chave_nfe = '53200626921908000202550020003156461474649616' AND servico_integracao = 1 
-- SELECT * FROM edi_ocorrencias_entrega ORDER BY 1 DESC LIMIT 10 WHERE chave_nfe = '53200626921908000202550020003156461474649616'
-- SELECT id_nota_fiscal_imp, id_ocorrencia FROM scr_notas_fiscais_imp WHERE chave_nfe = '53200606234797000178550010010484351100098401' 

		SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 18453343

				SELECT id_ocorrencia_softlog, *
				FROM edi_ocorrencias_comprovei
				WHERE codigo_status = split_part('001 - Entrega com restrições','-',1)::integer;
				

				--SELECT split_part('001 - Entrega com restrições                        ','-',1)::integer;

	SELECT * FROM edi_ocorrencias_entrega LIMIT 1
	UPDATE edi_ocorrencias_entrega SET chave_nfe = chave_nfe WHERE chave_nfe = '42180107432517001170550030006125001000014526'


	SELECT 
		edi.id, 
		edi.id_nota_fiscal_imp as id_nota_fiscal_imp_edi, 
		edi.chave_nfe,
		nf.id_nota_fiscal_imp
	FROM 
		edi_ocorrencias_entrega edi 
		LEFT JOIN scr_notas_fiscais_imp nf 
			ON nf.chave_nfe = edi.chave_nfe
	WHERE 
		edi.data_importacao >= '2021-03-01'::timestamp
		AND edi.id_nota_fiscal_imp <> nf.id_nota_fiscal_imp
	
	


	WHERE 
		EXISTS (SELECT 1
			FROM scr_notas_fiscais_imp nf
			WHERE nf.chave_nfe = edi_ocorrencias_entrega.chave_nfe
				AND nf.id_nota_fiscal_imp <> 

	WITH t AS (
		SELECT motivo_ocorrencia
		FROM edi_ocorrencias_entrega 
		GROUP BY motivo_ocorrencia
		ORDER BY 1
	)
	SELECT 
		edi.*,
		
	
	BEGIN;
	
	UPDATE edi_ocorrencias_entrega SET 		
		id_nota_fiscal_imp = NULL,
		id_conhecimento_notas_fiscais = NULL,
		id_conhecimento = NULL 
	WHERE 
		chave_nfe = '53200626921908000202550020003156461474649616';


	SELECT * FROM 
	COMMIT;

	BEGIN;
	WITH t AS (
		SELECT 
			chave_nfe,
			count(*) as qt
		FROM 
			scr_notas_fiscais_imp
		
		WHERE 
			data_registro::date >= '2020-04-01'


		GROUP BY 
			chave_nfe
		HAVING COUNT(*) >1
	)
	UPDATE edi_ocorrencias_entrega SET 	
		id_nota_fiscal_imp = NULL,
		id_conhecimento_notas_fiscais = NULL,
		id_conhecimento = NULL 
	FROM t
	WHERE edi_ocorrencias_entrega.chave_nfe = t.chave_nfe 

	
	

COMMIT;
ROLLBACK;
SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp IN (632302,632599) ORDER BY id_nota_fiscal_imp, data_hora DESC


	SELECT char_length(link_img) as tamanho, * FROM scr_docs_digitalizados ORDER BY 1 DESC LIMIT 100

--SELECT * FROM itrack_tmp ORDER BY 1 DESC LIMIT 100000


SELECT * FROM edi_ocorrencias_entrega WHERE chave_nfe IS NOT NULL AND servico_integracao = 8 

SELECT max(data_ocorrencia) as maxima, min(data_ocorrencia), chave_nfe, numero_ocorrencia FROM edi_ocorrencias_entrega  GROUP BY chave_nfe, numero_ocorrencia HAVING COUNT(*) > 1

*/


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
	v_lst_nf integer[];
	ja_existe integer;

	v_tentativas_reentrega integer;	
	v_tentativas_devolucao integer;	
	v_tem_devolucao_direta integer;
	
	v_devolucao_direta integer;		
	v_gera_pendencia integer;
	v_gera_reentrega integer;
	v_gera_devolucao integer;
	v_qt_pendencias integer;
	v_gerou_devolucao integer;

	v_codigo_cliente integer;

	v_id_ocorrencia_nf integer;
	v_id_doc_digitalizado integer;
	
	v_cpf_motorista text;
	v_observacao text;
	
BEGIN

	
	--RAISE NOTICE 'Iniciando Trigger';
	--Se a Ocorrência veio via Integracao Parceiros Softlog, recebe o código 4
	
	IF NEW.id_ocorrencia_app = -1000 THEN 
		NEW.servico_integracao = 4;
	END IF;

	--Softlog Aplicativo e Integracao Parceiros
	BEGIN
		IF NEW.servico_integracao IN (2,4)  THEN 
			
			/*
				WITH t AS (
					SELECT * FROM edi_ocorrencias_entrega
					WHERE data_importacao >= current_date::timestamp
					ORDER By 1 DESC LIMIT 2000
				)
				SELECT * FROM t ORDER BY chave_nfe

				SELECT * FROM edi_ocorrencias_entrega LIMIT 10

				SELECT count(*)
				FROM edi_ocorrencias_entrega
				WHERE 
					id_nota_fiscal_imp = 19987977
					AND numero_ocorrencia = 1
					AND data_ocorrencia = '2021-07-14 14:49:00'
					AND id <> 6113701;

			*/
			--Nao gravar ocorrencia com a mesma data mais de uma vez
			IF TG_OP = 'INSERT' THEN 

				IF NEW.id_nota_fiscal_imp IS NOT NULL THEN 
					SELECT count(*)
					INTO ja_existe
					FROM edi_ocorrencias_entrega
					WHERE 
						id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
						AND numero_ocorrencia = NEW.numero_ocorrencia
						AND data_ocorrencia = NEW.data_ocorrencia
						AND id <> NEW.id;
					

				ELSE 
					SELECT count(*)
					INTO ja_existe
					FROM edi_ocorrencias_entrega
					WHERE 
						chave_nfe = NEW.chave_nfe 
						AND numero_ocorrencia = NEW.numero_ocorrencia
						AND data_ocorrencia = NEW.data_ocorrencia
						AND id <> NEW.id;
				END IF;

				IF ja_existe > 0 THEN 
					RAISE NOTICE 'Já existe ocorrencia igual';
					NEW.descartar = 1;
					RETURN NEW;
				END IF;

			END IF;

			--Ocorrência de Entrega só pode acontecer uma vez.

			IF NEW.id_nota_fiscal_imp IS NOT NULL THEN 
				
				SELECT count(*)
				INTO ja_existe
				FROM edi_ocorrencias_entrega
				WHERE 
					id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
					AND numero_ocorrencia = 1
					AND id <> NEW.id;
				
			ELSE

				SELECT count(*)
				INTO ja_existe
				FROM edi_ocorrencias_entrega
				WHERE 
					chave_nfe = NEW.chave_nfe 
					AND numero_ocorrencia = 1
					AND id <> NEW.id;

			END IF;
				

			IF ja_existe > 0  THEN 
				RAISE NOTICE 'Já existe ocorrencia de entrega';
				NEW.descartar = 1;
				RETURN NEW;
			END IF;


			IF TG_OP = 'UPDATE' AND fp_get_session('executa_trigger')::integer IS NULL THEN 
				
				RETURN NEW;
			END IF;


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

			--RAISE NOTICE 'Operacao por Nota %', v_operacao_por_nota;
			
			
			
			--v_operacao_por_nota = 1;
			v_codigo_ocorrencia = NEW.numero_ocorrencia;
			--RAISE NOTICE 'Operacao por nota %', v_operacao_por_nota;
			IF NEW.id_nota_fiscal_imp IS NOT NULL THEN 

				
				IF NEW.servico_integracao = 4 THEN 
					v_historico = 'OCORRENCIA via PARCEIRO SOFTLOG:' || v_codigo_ocorrencia::text;
				ELSE
					SELECT 
						m.cnpj_cpf,
						chr(13) 
						|| 'SINCRONIZADO DO APP SCONFIRMEI MOTORISTA ' 						
						|| trim(m.nome_razao) 
						|| ' - ' 
						|| trim(cnpj_cpf(m.cnpj_cpf)) 
						|| ' AS ' 
						|| to_char(NEW.data_importacao, 'DD/MM/YYYY HH24:MI:SS')
						|| ' Codigo da Ocorrencia: '
						|| v_codigo_ocorrencia::text
					INTO 
						v_cpf_motorista,
						v_observacao
					FROM 
						fornecedores m
						LEFT JOIN scr_app_uuid u
						    ON u.id_fornecedor = m.id_fornecedor
					WHERE
					     u.uuid = NEW.uuid_usuario;
					
					v_historico = 'OCORRENCIA sCONFIRMEI Cod:' || v_codigo_ocorrencia::text || '/M:' || trim(cnpj_cpf(v_cpf_motorista));

					
				END IF;


				SELECT id_nota_fiscal_imp
				INTO v_id_nota_fiscal_imp
				FROM scr_notas_fiscais_imp
				WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

				IF v_id_nota_fiscal_imp IS NULL THEN 
					NEW.id_nota_fiscal_imp = NULL;
					RETURN NEW;
				END IF;
				
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
						nome_recebedor  = LEFT(NEW.recebedor,50),
						obs = COALESCE(obs,'') || v_observacao
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

				FETCH v_cursor INTO v_id_ocorrencia_nf;

				CLOSE v_cursor;
				
				NEW.id_ocorrencia_nf = v_id_ocorrencia_nf;				
				
				--Grava imagem se existir
				
				--SELECT * FROM scr_docs_digitalizados LIMIT 1
				IF NEW.url_imagem IS NOT NULL AND v_operacao_por_nota = 1  THEN 
					OPEN v_cursor FOR
					INSERT INTO scr_docs_digitalizados (
						link_img,
						id_nota_fiscal_imp,
						id_ocorrencia_nota_fiscal_imp 
					)
					VALUES (
						NEW.url_imagem,
						NEW.id_nota_fiscal_imp,
						v_id_ocorrencia_nota_fiscal_imp
					)
					RETURNING id;

					FETCH v_cursor INTO v_id_doc_digitalizado;

					CLOSE v_cursor;

					NEW.id_doc_digitalizado = v_id_doc_digitalizado;

					
				END IF;

				
				IF v_operacao_por_nota = 1 THEN 

					SELECT 	pendencia, gera_reentrega, gera_devolucao, devolucao_direta 
					INTO 	v_gera_pendencia, v_gera_reentrega, v_gera_devolucao, v_devolucao_direta
					FROM 	scr_ocorrencia_edi 
					WHERE 	codigo_edi = v_codigo_ocorrencia;

					RAISE NOTICE 'Gera Pendencia %', v_gera_pendencia;
					RAISE NOTICE 'Gera Reentrega %', v_gera_reentrega;
					RAISE NOTICE 'Gera Devolucao %', v_gera_devolucao;


					v_gerou_devolucao = 0;
					
					SELECT codigo_cliente 
					INTO v_codigo_cliente
					FROM cliente 					
					WHERE cnpj_cpf = NEW.cnpj_emitente;
					IF v_gera_pendencia = 1 AND v_gera_devolucao = 1  THEN 
						SELECT valor_parametro::integer
						INTO v_tentativas_devolucao
						FROM cliente_parametros
						
						WHERE codigo_cliente = v_codigo_cliente
							AND id_tipo_parametro = 142;

								
						v_tentativas_devolucao = COALESCE(v_tentativas_devolucao,0);

						IF v_tentativas_devolucao > 0 THEN 

							SELECT	
								count(*) as qt
							INTO 	
								v_qt_pendencias 
							FROM 	scr_notas_fiscais_imp_ocorrencias oco
								LEFT JOIN scr_ocorrencia_edi edi
									ON edi.codigo_edi = oco.id_ocorrencia
							WHERE 	
								edi.pendencia = 1
								AND oco.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

							IF v_qt_pendencias >= v_tentativas_devolucao THEN 						
								PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 2);
								v_gerou_devolucao = 1;
								--Colocar Flag
							END IF;

						END IF;
					END IF;

					IF v_gera_pendencia = 1 AND  v_devolucao_direta = 1 THEN 

						SELECT valor_parametro::integer
						INTO v_tem_devolucao_direta 
						FROM cliente_parametros
						WHERE codigo_cliente = v_codigo_cliente
							AND id_tipo_parametro = 143;

						v_tem_devolucao_direta = COALESCE(v_tem_devolucao_direta,0);

						IF v_tem_devolucao_direta = 1 THEN 
							PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 2);
							v_gerou_devolucao = 1;
						END IF;				
			
					END IF;
					
					IF v_gera_pendencia = 1 AND v_gera_reentrega = 1 AND v_gerou_devolucao = 0 THEN 
						SELECT valor_parametro::integer
						INTO v_tentativas_reentrega
						FROM cliente_parametros
						WHERE codigo_cliente = v_codigo_cliente
							AND id_tipo_parametro = 141;
								
						v_tentativas_reentrega = COALESCE(v_tentativas_reentrega,0);

						--RAISE NOTICE 'Tentativas de Reentrega %', v_tentativas_reentrega;
						IF v_tentativas_reentrega > 0 THEN 
							
							SELECT	
								count(*) as qt
							INTO 	
								v_qt_pendencias 
							FROM 	scr_notas_fiscais_imp_ocorrencias oco
								LEFT JOIN scr_ocorrencia_edi edi
									ON edi.codigo_edi = oco.id_ocorrencia
							WHERE 	
								edi.pendencia = 1 AND gera_reentrega = 1
								AND oco.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

							IF v_qt_pendencias >= v_tentativas_reentrega AND v_gerou_devolucao = 0 THEN 	
								--RAISE NOTICE 'Replicando nota';
								PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 3);
								--Colocar Flag
							END IF;

						END IF;
					END IF;	
						
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
						cliente.codigo_cliente = t.destinatario_id
						AND latitude IS NOT NULL;
			
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
					v_historico,
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

				--SELECT * FROM scr_conhecimento_notas_fiscais LIMIT 1
				--SELECT * FROM edi_ocorrencias_entrega 
				--Faz update na nota fiscal 
				OPEN v_cursor FOR 
				UPDATE scr_conhecimento_notas_fiscais nf
					SET 
						id_ocorrencia = v_codigo_ocorrencia,
						data_ocorrencia = NEW.data_ocorrencia::date,				
						hora_ocorrencia = to_char(NEW.data_ocorrencia,'HH24MM'),					
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
					v_historico,
					'suporte'
				);	
			END IF;
		END IF;
	EXCEPTION WHEN OTHERS  THEN 
		RAISE NOTICE 'ERRO ****************************************%', SQLERRM;					
	END;



	--Comprovei
	IF NEW.servico_integracao = 1 THEN 
		
		SELECT 
			count(*) 
		INTO 
			v_qt
		FROM 
			edi_ocorrencias_entrega
		WHERE 
			numero_ocorrencia = NEW.numero_ocorrencia 
			AND chave_nfe = NEW.chave_nfe
			AND id <> NEW.id;


		/*
		SELECT 
			count(*)
		INTO 
			v_qt
		FROM 
			edi_ocorrencias_entrega
		WHERE
			chave_nfe = NEW.chave_nfe;
		*/
			
		RAISE NOTICE 'QT %',v_qt;
		
		IF v_qt > 0 THEN 
			RAISE NOTICE 'Saindo';
			RETURN NULL;
		END IF;
			
		v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA','001')::integer,0);
		
	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;

	-- 	END IF;
		
		--53200606234797000178550010010476451100012232
		IF v_operacao_por_nota IN (0,1) THEN 		

			IF NEW.url_imagem IS NOT NULL OR NEW.url_assinatura IS NOT NULL THEN 
				v_tem_canhoto = 1;
			ELSE
				v_tem_canhoto = 0;
			END IF;

			-- Procura associacao com Nota Importada
			IF NEW.id_nota_fiscal_imp IS NULL THEN 
				SELECT array_agg(id_nota_fiscal_imp), MAX(empresa_emitente)
				INTO v_lst_nf, v_empresa
				FROM scr_notas_fiscais_imp
				WHERE chave_nfe = NEW.chave_nfe
				ORDER BY 1 DESC;

			
-- 				SELECT id_nota_fiscal_imp, empresa_emitente 
-- 				INTO v_id_nota_fiscal_imp, v_empresa
-- 				FROM scr_notas_fiscais_imp
-- 				WHERE chave_nfe = NEW.chave_nfe
-- 				ORDER BY 1 DESC LIMIT 1;
				--tamanho = array_length(va_img,1);

				IF v_lst_nf IS NOT NULL THEN 
					tamanho = array_length(v_lst_nf,1);
					v_id_nota_fiscal_imp = v_lst_nf[1];
					NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
					--v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
				ELSE 
					tamanho = 0;
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


			--RAISE NOTICE 'Codigo Ocorrencia %', v_codigo_ocorrencia;
			IF tamanho > 0 THEN 
				FOR i IN 1..tamanho LOOP

					v_id_nota_fiscal_imp = v_lst_nf[i];
					
					RAISE NOTICE 'Realizando Processamento da Nota %', v_id_nota_fiscal_imp;
					
					IF  v_codigo_ocorrencia <> -1 THEN 

						v_codigo_ocorrencia = COALESCE(v_codigo_ocorrencia,1);

						IF NEW.data_ocorrencia IS NULL THEN
							--Se não tem data de baixa, seta status 2
							-- que é o indicativo de erro;
							NEW.status = 2;			
							RETURN NEW;
						END IF;

						--Coloca id da nota fiscal imp na variavel global 
						-- para trigger de ocorrencia automatica abortar insercao
						PERFORM fp_set_session('id_nota_fiscal_imp',v_id_nota_fiscal_imp::text);

						--RAISE NOTICE 'Entrei aqui';
						--Faz update na nota fiscal 
						UPDATE scr_notas_fiscais_imp nf
							SET 
								id_ocorrencia   = v_codigo_ocorrencia,
								data_ocorrencia = NEW.data_ocorrencia,
								nome_recebedor  = LEFT(NEW.recebedor,50)
						WHERE
							nf.id_nota_fiscal_imp   = v_id_nota_fiscal_imp;
						

						OPEN v_cursor FOR 
						INSERT INTO scr_notas_fiscais_imp_ocorrencias(
							id_nota_fiscal_imp, 
							id_ocorrencia,
							data_ocorrencia,
							data_registro,
							canhoto)
						 VALUES(
							v_id_nota_fiscal_imp,
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
								id_ocorrencia_nota_fiscal_imp,
								upload_s3
							)
							VALUES (
								NEW.url_imagem,
								v_id_nota_fiscal_imp,
								v_id_ocorrencia_nota_fiscal_imp,
								1
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
							v_id_nota_fiscal_imp,
							now(),
							'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
							'suporte'
						);					
					END IF;
				END LOOP;
			END IF;
		END IF;

		--SELECT * FROM parametros ORDER BY 5
		--RAISE NOTICE 'Operacao por Nota %',v_codigo_ocorrencia;
		
		IF v_operacao_por_nota = 0  THEN 

			

				
			RAISE NOTICE 'Operacao Por CTe';			
			tamanho = 0;
			IF NEW.id_conhecimento_notas_fiscais IS NULL THEN 
				SELECT 	array_agg(id_conhecimento_notas_fiscais)
				INTO 	v_lst_nf
				FROM 	scr_conhecimento_notas_fiscais nf			
				WHERE 	chave_nfe = NEW.chave_nfe
				ORDER BY 1 DESC;

				IF v_lst_nf IS NOT NULL THEN 
					tamanho = array_length(v_lst_nf,1);
					v_id_conhecimento_notas_fiscais = v_lst_nf[1];
				ELSE
					tamanho = 0;
				END IF;
			END IF;

			IF tamanho > 0 THEN 
				FOR i IN 1..tamanho LOOP 
				
					v_id_conhecimento_notas_fiscais = v_lst_nf[i];
						
					SELECT  
						nf.id_conhecimento, v_empresa
					INTO 	
						v_id_conhecimento, v_empresa
					FROM 
						scr_conhecimento_notas_fiscais nf
						LEFT JOIN scr_conhecimento c
							ON c.id_conhecimento = nf.id_conhecimento		
					WHERE 
						id_conhecimento_notas_fiscais = v_id_conhecimento_notas_fiscais
					ORDER BY 1 
					DESC LIMIT 1;

					IF v_id_conhecimento_notas_fiscais IS NOT NULL THEN 
										
						NEW.id_conhecimento_notas_fiscais = v_id_conhecimento_notas_fiscais;
						NEW.id_conhecimento = v_id_conhecimento;					
						--v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
					END IF ;


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
					PERFORM fp_set_session('id_nota_fiscal_imp',v_id_nota_fiscal_imp::text);
					
					UPDATE scr_conhecimento_notas_fiscais nf
						SET 
							id_ocorrencia = v_codigo_ocorrencia,
							data_ocorrencia = COALESCE(NEW.data_ocorrencia::date),				
							hora_ocorrencia = COALESCE(to_char(NEW.data_ocorrencia,'HH24MM')),
							nome_recebedor_nf  = COALESCE(LEFT(NEW.recebedor,50),'NAO INFORMADO'),
							canhoto = v_tem_canhoto
					WHERE
						nf.id_conhecimento_notas_fiscais = v_id_conhecimento_notas_fiscais;

					IF v_codigo_ocorrencia = 1 THEN 
						RAISE NOTICE 'Gravando Entrega Conhecimento %', v_id_conhecimento;
						WITH t AS (
							SELECT
								SUM((CASE WHEN COALESCE(nf.id_ocorrencia,0) NOT IN (1,2) THEN 1 ELSE 0 END)) as qt,
								nf.id_conhecimento
							FROM
								scr_conhecimento_notas_fiscais nf
							WHERE
								nf.id_conhecimento = v_id_conhecimento
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
									id_conhecimento_notas_fiscais,
									upload_s3
								)
								VALUES (
									NEW.url_imagem,
									v_id_conhecimento,								
									v_id_conhecimento_notas_fiscais,
									1
								);		
							END IF;

							/*
							IF NEW.url_assinatura IS NOT NULL THEN 
								INSERT INTO scr_docs_digitalizados (
									link_img,
									id_conhecimento,								
									id_conhecimento_notas_fiscais,
									upload_s3
								)
								VALUES (
									NEW.url_assinatura,
									v_id_conhecimento,								
									v_id_conhecimento_notas_fiscais,
									1
								);		
							END IF;
							*/

						END IF;

						--SELECT * FROM scr_conhecimento_log_atividades LIMIT 1
						--Grava Log Atividades
						/*
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
						*/
					
						
						INSERT INTO scr_conhecimento_log_atividades(
							id_conhecimento, 
							data_hora, 
							atividade_executada, 
							usuario
							)
						VALUES (
							v_id_conhecimento,
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
									id_conhecimento_notas_fiscais,
									upload_s3
								)
								VALUES (
									NEW.url_imagem,
									v_id_conhecimento,								
									v_id_conhecimento_notas_fiscais,
									1
								);		
							END IF;

							/*
							IF NEW.url_assinatura IS NOT NULL THEN 
								INSERT INTO scr_docs_digitalizados (
									link_img,
									id_conhecimento,								
									id_conhecimento_notas_fiscais,
									upload_s3
								)
								VALUES (
									NEW.url_assinatura,
									v_id_conhecimento,								
									v_id_conhecimento_notas_fiscais,
									1
								);		
							END IF;
							*/
						END IF;

						--SELECT * FROM scr_conhecimento_log_atividades LIMIT 1
						--Grava Log Atividades
						/*
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
						*/
						
						INSERT INTO scr_conhecimento_log_atividades(
							id_conhecimento, 
							data_hora, 
							atividade_executada, 
							usuario
							)
						VALUES (
							v_id_conhecimento,
							now(),
							'OCORRENCIA via COMPROVEI Codigo:' || v_codigo_ocorrencia::text,
							'suporte'
						);
						

					END IF;
				END LOOP;
			END IF;
			
			--Faz update na nota fiscal 
		END IF;
	END IF;

	----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	IF NEW.servico_integracao = 3 THEN 


		/*
		BEGIN;
		UPDATE edi_ocorrencias_entrega SET id = id, chave_nfe = '42210505399786000770550010000016451144024006' WHERE id = 58625;

		DELETE FROM edi_ocorrencias_entrega WHERE servico_integracao = 3
		DELETE FROM edi_ocorrencias_entrega WHERE chave_nfe = '42210505399786000770550010000016451144024006'
		ROLLBACK;
		COMMIT;

		--SELECT * FROM scr_notas_fiscais_imp WHERE chave_nfe = '91576000158550050008859761297197344'
		SELECT id_nota_fiscal_imp, empresa_emitente, data_ocorrencia
			
			FROM scr_notas_fiscais_imp
			WHERE chave_nfe = '42210505399786000770550010000016451144024006'
			ORDER BY 1 DESC LIMIT 1;
			SELECT * FROM 
		*/
		RAISE NOTICE '%', NEW.chave_nfe;
		IF TG_OP = 'UPDATE' THEN 
-- 			IF NEW.url_imagem = '' THEN 
-- 				RETURN NEW;
-- 			END IF;
-- 			IF NEW.url_imagem <> COALESCE(OLD.url_imagem,'') THEN 
-- 
-- 			
-- 				SELECT id_ocorrencia_nf 
-- 				INTO v_id_ocorrencia_nf
-- 				FROM   scr_notas_fiscais_imp_ocorrencias
-- 				WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp AND id_ocorrencia = NEW.numero_ocorrencia;
-- 
-- 				IF v_id_ocorrencia_nf IS NOT NULL THEN 
-- 					--RAISE NOTICE 'INSERINDO IMAGEM';
-- 					INSERT INTO scr_docs_digitalizados (
-- 					link_img,
-- 					id_nota_fiscal_imp,
-- 					id_ocorrencia_nota_fiscal_imp
-- 					)
-- 					VALUES (
-- 						NEW.url_imagem,
-- 						NEW.id_nota_fiscal_imp,
-- 						v_id_ocorrencia_nota_fiscal_imp
-- 					);		
-- 				
-- 
-- 					UPDATE scr_notas_fiscais_imp 
-- 							SET digitalizado = 1 
-- 					WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;	
-- 					
-- 					UPDATE scr_notas_fiscais_imp_ocorrencias SET canhoto = 1 WHERE id_ocorrencia_nf = v_id_ocorrencia_nf;
-- 				END IF;
-- 				
-- 				
-- 			END IF;
			RETURN NEW;
		END IF;

		RAISE NOTICE 'Verificando se UUID ja existe';
		SELECT 
			count(*) 
		INTO 
			v_qt
		FROM 
			edi_ocorrencias_entrega
		WHERE 
			id <> NEW.id AND uuid_usuario = NEW.uuid_usuario;

		

		RAISE NOTICE 'QT %',v_qt;
		IF v_qt > 0 THEN 
			RAISE NOTICE 'Ja existe ocorrencia registrada!';
			RETURN NULL;
		END IF;

	-- 	IF NEW.id_nota_fiscal_imp IS NOT NULL AND OLD.id_nota_fiscal_imp IS NOT NULL THEN 
	-- 		RETURN NULL;
	-- 	END IF;
		
		--SELECT id_nota_fiscal_imp, chave_nfe, empresa_emitente FROM scr_notas_fiscais_imp WHERE chave_nfe IS NOT NULL ORDER BY 1 DESC LIMIT 1

		-- Procura associacao com Nota Importada
		IF NEW.id_nota_fiscal_imp IS NULL THEN 
			
			SELECT id_nota_fiscal_imp, empresa_emitente 
			INTO v_id_nota_fiscal_imp, v_empresa
			FROM scr_notas_fiscais_imp
			WHERE chave_nfe = NEW.chave_nfe
			ORDER BY 1 DESC LIMIT 1;
			
			--RAISE NOTICE 'Nota Fiscal %',v_id_nota_fiscal_imp;
			IF v_id_nota_fiscal_imp IS NOT NULL THEN 
			RAISE NOTICE 'Nota Fiscal %',v_id_nota_fiscal_imp;
				NEW.id_nota_fiscal_imp = v_id_nota_fiscal_imp;
				v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);
			END IF ;	
		END IF;
		
		

		v_codigo_ocorrencia = NEW.numero_ocorrencia;
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
			PERFORM fp_set_session('id_nota_fiscal_imp',NEW.id_nota_fiscal_imp::text);

			--RAISE NOTICE 'Entrei aqui';


			
			IF trim(NEW.url_imagem) = '' THEN 
				NEW.url_imagem = NULL;
			END IF;
			
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
			

				UPDATE scr_notas_fiscais_imp 
						SET digitalizado = 1 
				WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;	

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
				'OCORRENCIA via Webservice Softlog Codigo:' || v_codigo_ocorrencia::text,
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
							id_ocorrencia_nota_fiscal_imp,
							upload_s3 
						)
						VALUES (
							va_img[i],
							NEW.id_nota_fiscal_imp,
							v_id_ocorrencia_nota_fiscal_imp,
							1
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

	IF NEW.servico_integracao = 8 THEN 

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

		IF v_codigo_ocorrencia IS NULL THEN 
			RETURN NEW;
		END IF;
		
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
					nome_recebedor  = NEW.recebedor,
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



	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

