/*
SELECT * FROM f_portal_consulta_entrega(NULL, NULL, NULL, NULL);


SELECT * FROM 

SELECT * FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210263957302000172550010016354161147892640'

SELECT	
	destinatario,
	numero_nota_fiscal,
	numero_pedido_nf,
	serie_nota_fiscal,
	chave_cte,
	chave_nfe,
	data_emissao,
	data_ocorrencia,
	data_previsao_entrega,
	dias_atraso,
	entregue, 
	status,
	codigo_rastreamento,
	ocorrencia 
FROM
	f_portal_consulta_entrega('{"tipo_pesquisa":"2",
		"acesso_raiz":"1",
		"user_categoria":"2",
		"dt_ini":"2021/04/01",
		"dt_fim":"2021/04/26",
		"limite":10000,
		"cnpj_cliente":"04307650001611",
		"numero_nota_fiscal":"000142609",
		"destinatario_nome":null,
		"chave_nfe":"",
		"chave_cte":null,
		"numero_pedido":null,
		"status":null,
		"em_aberto":null,
		"fixo_01_cnpj_embarcador":null	
	}'::json )


SELECT id_nota_fiscal_imp, remetente_cnpj FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 142609::integer AND remetente_cnpj like '%04307650%'
         SELECT
                    destinatario,
		    numero_nota_fiscal,
                    numero_pedido_nf,
                    serie_nota_fiscal,
                    chave_cte,
                    chave_nfe,
                    data_emissao,
                    data_ocorrencia,
                    data_previsao_entrega,
                    dias_atraso,
                    entregue,
                    status,
                    codigo_rastreamento,
                    ocorrencia
            FROM
                    f_portal_consulta_entrega(
			'{ "tipo_pesquisa":"1",
                    "acesso_raiz":"1",
                    "user_categoria":"1",
                    "dt_ini":"2021/05/11",
                    "dt_fim":"2021/05/11",
                    "limite":10000,
                    "cnpj_cliente":"SUPORTE SOFTLOG",
		    "fixo_01_cnpj_embarcador":""
                    }'::json )

550010019354421518556486
SELECT 05889907000177    

*/
	
--DROP FUNCTION public.f_portal_consulta_entrega(

CREATE OR REPLACE  FUNCTION public.f_portal_consulta_entrega(parametros json)
  RETURNS SETOF t_consulta_entrega AS
$BODY$
DECLARE
	registro t_consulta_entrega%rowtype;	
	v_tp integer;
	v_ar integer;
	v_uc integer;
	v_di date;
	v_df date;
	v_lim integer; 
	v_cliente text;
	v_fixo_01_cnpj text;
	v_nf text;
	v_dest text;
	v_chave_nfe text;
	v_chave_cte text;
	v_np text;
	v_status text;
	v_em_aberto text;
	param json;

	v_id_ocorrencia integer;
	
BEGIN
	
	param = parametros; --Para concilitar os testes
	
	v_tp = ((parametros->>'tipo_pesquisa')::text)::integer as tipo_pesquisa;
	v_ar = ((parametros->>'acesso_raiz')::text)::integer as acesso_raiz;
	v_uc = ((parametros->>'user_categoria')::text)::integer as user_categoria;
	v_lim = ((param->>'limite')::text)::integer;
	v_cliente = ((param->>'cnpj_cliente')::text);
	v_fixo_01_cnpj = ((param->>'fixo_01_cnpj_embarcador')::text);

	IF COALESCE(v_fixo_01_cnpj,'') = '' THEN 
		v_fixo_01_cnpj = NULL;
	END IF;

	v_ar = COALESCE(v_ar,0);
	
	RAISE NOTICE 'CNPJ FIXO %', v_fixo_01_cnpj;
	RAISE NOTICE 'Acesso Raiz %', v_ar;
	SELECT 
		valor_parametro::integer
	INTO 
		v_id_ocorrencia
	FROM 
		cliente_parametros cp	
		LEFT JOIN cliente 
				ON cliente.codigo_cliente = cp.codigo_cliente
	WHERE 	cp.id_tipo_parametro = 144 AND cliente.cnpj_cpf = v_cliente;


	FOR registro IN 			


			--EXPLAIN ANALYSE
			WITH 
			ent AS (
				SELECT '{"tipo_pesquisa":"1",
					"acesso_raiz":"1",
					"user_categoria":"2",
					"dt_ini":"2021/02/01",
					"dt_fim":"2021/02/25",
					"limite":10000,
					"cnpj_cliente":"63957302000172",
					"numero_nota_fiscal":null,
					"destinatario_nome":null,
					"chave_nfe":null,
					"chave_cte":null,
					"numero_pedido":null,
					"status":null,
					"em_aberto":null		
					}'::json as param
			),
			d AS (
				SELECT 
					((param->>'tipo_pesquisa')::text)::integer as tipo_pesquisa,
					((param->>'acesso_raiz')::text)::integer as acesso_raiz,
					((param->>'user_categoria')::text)::integer as user_categoria,
					((param->>'dt_ini')::text)::date as dt_ini,
					((param->>'dt_fim')::text)::date as dt_fim,
					((param->>'limite')::text)::integer as limite,
					CASE WHEN v_ar = 0 THEN 
						((param->>'cnpj_cliente')::text) 
					ELSE
						LEFT(((param->>'cnpj_cliente')::text),8)
					END::text as cnpj_cliente,
					CASE WHEN v_ar = 0 THEN 
						(v_fixo_01_cnpj::text) 
					ELSE
						LEFT(v_fixo_01_cnpj::text,8)
					END::text as fixo_cnpj_embarcador,
					(trim((param->>'numero_nota_fiscal')::character(9))) as numero_nota_fiscal,
					(trim((param->>'destinatario_nome')::text)) as destinatario_nome,
					(trim((param->>'chave_nfe')::text))::character(44) as chave_nfe,
					(trim((param->>'chave_cte')::text))::character(44) as chave_cte,
					((param->>'numero_pedido')::text) as numero_pedido,
					((param->>'status')::text)::integer as status,
					((param->>'em_aberto')::text)::integer as em_aberto
				--FROM ent
			),
			t AS (
			
				SELECT	DISTINCT ON (imp.id_nota_fiscal_imp, nfo.id_ocorrencia)
					--rem.nome_cliente as remetente,
					--rem.nome_cliente as remetente,
					--rem.cnpj_cpf cnpj_cpf_remetente,
					--dest.cnpj_cpf as cnpj_cpf_destinatario,
					imp.id_nota_fiscal_imp,
					con.id_conhecimento,										
					imp.id_conhecimento,					
					dest.nome_cliente as destinatario,
					imp.numero_nota_fiscal,
					imp.numero_pedido_nf,
					imp.serie_nota_fiscal,
					imp.chave_cte, 
					imp.chave_nfe,
					imp.data_emissao,
					COALESCE(nfo.data_ocorrencia, imp.data_ocorrencia) as data_ocorrencia,
					nfo.id_ocorrencia,
					--CASE WHEN oco.codigo_edi IN (1,2) THEN imp.data_ocorrencia ELSE NULL END::date as data_entrega,
					--imp.data_previsao_entrega, 
					imp.data_expedicao,
					0::integer as dias_atraso,									
					COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) as data_previsao_entrega,
-- 					CASE WHEN oco.codigo_edi IN (1,2) THEN 
-- 						CASE WHEN COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) < imp.data_ocorrencia::date THEN
-- 							 imp.data_ocorrencia::date - COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1)
-- 						ELSE
-- 							0
-- 						END
-- 					ELSE
-- 						CASE WHEN COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) < current_date THEN 
-- 							 current_date - COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1)
-- 						ELSE
-- 							0
-- 						END
-- 					END::integer as dias_atraso,
					CASE WHEN oco.codigo_edi IN (1,2) THEN 1 ELSE 0 END::integer as entregue,
					imp.status,
					'01' || lpad(fd_get_id_banco_dados(current_database())::text,5,'0') ||
					lpad(imp.id_nota_fiscal_imp::text,12,'0') as codigo_rastreamento,
					oco.ocorrencia::character(50) as ocorrencia
				FROM 					
					scr_notas_fiscais_imp imp
					LEFT JOIN d 
						ON 1=1 
					LEFT JOIN cliente rem
						ON imp.remetente_id = rem.codigo_cliente
					LEFT JOIN cliente dest
						ON imp.destinatario_id = dest.codigo_cliente
					LEFT JOIN scr_ocorrencia_edi oco 
						ON oco.codigo_edi = imp.id_ocorrencia
					LEFT JOIN scr_conhecimento con
						ON con.id_conhecimento = imp.id_conhecimento
							AND v_tp = 5
					LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
 						ON nfo.id_nota_fiscal_imp = imp.id_nota_fiscal_imp
 							AND imp.id_ocorrencia = 1


						
					-- LEFT JOIN scr_conhecimento_notas_fiscais con 
-- 					    ON con.id_conhecimento = imp.id_conhecimento
				
				WHERE 	
					1=1
					
					AND (oco.publica = 1 OR (current_database() = 'softlog_bsb' AND imp.id_ocorrencia = 0))
					AND 
						CASE 
							WHEN v_id_ocorrencia IS NOT NULL THEN 
								EXISTS (	SELECT 1 
										FROM scr_notas_fiscais_imp_ocorrencias 
										WHERE scr_notas_fiscais_imp_ocorrencias.id_nota_fiscal_imp = imp.id_nota_fiscal_imp
											AND scr_notas_fiscais_imp_ocorrencias.id_ocorrencia = v_id_ocorrencia
								)
							ELSE
								true
						END
								
							
					AND 
						CASE 	WHEN v_uc = 2  AND v_ar = 0 THEN 
								(rem.cnpj_cpf = d.cnpj_cliente OR dest.cnpj_cpf = d.cnpj_cliente)
							WHEN v_uc = 2 AND v_ar = 1 THEN 
								(rem.cnpj_cpf LIKE '%' || d.cnpj_cliente || '%' OR dest.cnpj_cpf LIKE '%' || d.cnpj_cliente || '%')
							ELSE
								true
						END
					AND 
					
						CASE 	WHEN v_fixo_01_cnpj IS NULL THEN 
								true
							WHEN v_uc = 1  AND v_ar = 0 THEN 
								(rem.cnpj_cpf = d.fixo_cnpj_embarcador OR dest.cnpj_cpf = d.fixo_cnpj_embarcador)
							WHEN v_uc = 1 AND v_ar = 1 THEN 
								(rem.cnpj_cpf LIKE '%' || d.fixo_cnpj_embarcador || '%' OR dest.cnpj_cpf LIKE '%' || d.fixo_cnpj_embarcador || '%')
							ELSE
								true
						END
					AND 
						CASE WHEN v_tp = 1 THEN 
							imp.data_emissao >= d.dt_ini AND imp.data_emissao <= d.dt_fim
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 2 THEN 
							imp.numero_nota_fiscal::integer = d.numero_nota_fiscal::integer
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 3 THEN 
							dest.nome_cliente LIKE '%' || d.destinatario_nome || '%'
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 4 THEN 
							imp.chave_nfe = d.chave_nfe
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 5 THEN 
							con.chave_cte = d.chave_cte
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 6 THEN 
							imp.numero_pedido_nf LIKE '%' || d.numero_pedido || '%'
						ELSE
							true
						END
					AND 	
						CASE WHEN v_tp = 7 THEN 
							imp.data_emissao >= d.dt_ini AND imp.data_emissao <= d.dt_fim
							AND 
							imp.id_ocorrencia = d.status
						ELSE
							true
						END
					AND 
						CASE WHEN v_tp = 8 THEN 
								imp.data_emissao >= d.dt_ini AND imp.data_emissao <= d.dt_fim
							AND 
								imp.id_ocorrencia not in (1,2) 
							--AND 
							--	NOT (imp.id_ocorrencia >= 300 AND imp.id_ocorrencia < 400)
							AND	
								imp.id_romaneio IS NOT NULL 
						ELSE
							true
						END
					AND CASE WHEN nfo.id_ocorrencia IS NOT NULL THEN nfo.id_ocorrencia = 1 ELSE true END					
				ORDER BY 
					imp.id_nota_fiscal_imp,
					nfo.id_ocorrencia, 
					nfo.id_ocorrencia_nf
				LIMIT v_lim
					
	
		),		
		t2 AS (
			SELECT	
				
				destinatario,
				numero_nota_fiscal,
				numero_pedido_nf,
				serie_nota_fiscal,
				chave_cte,
				chave_nfe,
				data_emissao,
				data_ocorrencia,
				data_previsao_entrega,
				CASE WHEN id_ocorrencia IN (1,2) THEN 
					CASE WHEN COALESCE(data_previsao_entrega, data_expedicao + 1) < data_ocorrencia::date THEN
						 data_ocorrencia::date - COALESCE(data_previsao_entrega, data_expedicao + 1)
					ELSE
						0
					END
				ELSE
					CASE WHEN COALESCE(data_previsao_entrega, data_expedicao + 1) < current_date THEN 
						 current_date - COALESCE(data_previsao_entrega, data_expedicao + 1)
					ELSE
						0
					END
				END::integer as dias_atraso,
				entregue, 
				status,
				codigo_rastreamento,
				ocorrencia 
			FROM
				t
			
			
				-- LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
-- 						ON nfo.id_nota_fiscal_imp = t.id_nota_fiscal_imp
-- 							AND nfo.id_ocorrencia = 1
-- 			ORDER BY 
-- 				nfo.id_nota_fiscal_imp, nfo.id_ocorrencia_nf
-- 
-- 
		) 

		SELECT 
			destinatario,
			numero_nota_fiscal,
			numero_pedido_nf,
			serie_nota_fiscal,
			chave_cte,
			chave_nfe,
			data_emissao,
			data_ocorrencia,
			data_previsao_entrega,
			dias_atraso,
			entregue, 
			status,
			codigo_rastreamento,
			ocorrencia
		FROM 
			t2
		ORDER BY 
			data_ocorrencia
		
	LOOP
		RETURN NEXT registro;	
	END LOOP;

	RETURN ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;


  