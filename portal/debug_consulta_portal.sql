			--EXPLAIN ANALYSE
			--EXPLAIN ANALYSE
			WITH 
			ent AS (
				SELECT '{"tipo_pesquisa":"1",
					"acesso_raiz":"1",
					"user_categoria":"2",
					"dt_ini":"2021/02/01",
					"dt_fim":"2021/02/25",
					"limite":10000,
					"cnpj_cliente":"04307650001611",
					"numero_nota_fiscal":"000142609",
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
					CASE WHEN 1 = 0 THEN 
						((param->>'cnpj_cliente')::text) 
					ELSE
						LEFT(((param->>'cnpj_cliente')::text),8)
					END::text as cnpj_cliente,
					CASE WHEN 1 = 0 THEN 
						(''::text) 
					ELSE
						LEFT(NULL::text,8)
					END::text as fixo_cnpj_embarcador,
					(trim((param->>'numero_nota_fiscal')::character(9))) as numero_nota_fiscal,
					(trim((param->>'destinatario_nome')::text)) as destinatario_nome,
					(trim((param->>'chave_nfe')::text))::character(44) as chave_nfe,
					(trim((param->>'chave_cte')::text))::character(44) as chave_cte,
					((param->>'numero_pedido')::text) as numero_pedido,
					((param->>'status')::text)::integer as status,
					((param->>'em_aberto')::text)::integer as em_aberto
				FROM ent
			)
			,
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
							AND 2 = 5
					LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
 						ON nfo.id_nota_fiscal_imp = imp.id_nota_fiscal_imp
 							AND imp.id_ocorrencia = 1


						
					-- LEFT JOIN scr_conhecimento_notas_fiscais con 
-- 					    ON con.id_conhecimento = imp.id_conhecimento
				
				WHERE 	
					1=1
					
					--AND (oco.publica = 1 OR (current_database() = 'softlog_bsb' AND imp.id_ocorrencia = 0))
					AND 
						CASE 
							WHEN NULL IS NOT NULL THEN 
								EXISTS (	SELECT 1 
										FROM scr_notas_fiscais_imp_ocorrencias 
										WHERE scr_notas_fiscais_imp_ocorrencias.id_nota_fiscal_imp = imp.id_nota_fiscal_imp
											AND scr_notas_fiscais_imp_ocorrencias.id_ocorrencia = NULL
								)
							ELSE
								true
						END
								
							
					AND 
						CASE 	WHEN 2 = 2  AND 1 = 0 THEN 
								(rem.cnpj_cpf = d.cnpj_cliente OR dest.cnpj_cpf = d.cnpj_cliente)
							WHEN 2 = 2 AND 1 = 1 THEN 
								(rem.cnpj_cpf LIKE '%' || d.cnpj_cliente || '%' OR dest.cnpj_cpf LIKE '%' || d.cnpj_cliente || '%')
							ELSE
								true
						END
					AND 
					
						CASE WHEN 2 = 1 THEN 
							imp.data_emissao >= d.dt_ini AND imp.data_emissao <= d.dt_fim
						ELSE
							true
						END
					AND 
						CASE WHEN 2 = 2 THEN 
							imp.numero_nota_fiscal::integer = d.numero_nota_fiscal::integer
						ELSE
							true
						END
									
				ORDER BY 
					imp.id_nota_fiscal_imp,
					nfo.id_ocorrencia, 
					nfo.id_ocorrencia_nf
				
					
	
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
			