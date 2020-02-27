SELECT * FROM fila_documentos_integracoes WHERE id = 10813

SELECT * FROM scr_romaneios WHERE numero_romaneio = '0010010108450'
{

	"ids": [1041292,1041293,1041294],
	"main_id": 1041291
}

{"lst_id_integracao":[null,1041292,1041293,1041294],"id_integracao_principal":1041291,"id_main":10809,"qt":4,"qt_enviado":4,"id_romaneio":116642}
SELECT * FROM fila_documentos_integracoes WHERE id_romaneio =116752

			WITH t AS (
					SELECT
						array_agg(fd.id_integracao) as lst_id_integracao,
						SUM(CASE
                                WHEN fd.principal = 1
                                THEN fd.id_integracao
                                ELSE 0
                        END) as id_integracao_principal,
						min(fd.id) as id_main,
						count(*) as qt,
						SUM(CASE
                                WHEN fd.enviado = 1
                                THEN 1
                                ELSE 0
                        END) as qt_enviado,
						fd.id_romaneio
					FROM
                            fila_documentos_integracoes fd
                            LEFT JOIN scr_notas_fiscais_imp nf
							 ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
					WHERE
						fd.tipo_documento = 1
						--AND fd.enviado = 0
						AND fd.tipo_integracao = 5
						AND fd.agrupado = 0
						AND fd.id_romaneio = 116752
					GROUP BY
						nf.destinatario_id,
						fd.id_romaneio
				)
				SELECT row_to_json(t) as agrupamento FROM t
			WHERE qt_enviado = qt;

-- 
-- 				SELECT 
-- 					5,
-- 					-10,
-- 					MIN(nf.id_nota_fiscal_imp),					
-- 					r.id_romaneio
-- 				FROM 		
-- 					scr_romaneios r				
-- 					LEFT JOIN scr_notas_fiscais_imp nf
-- 						ON nf.id_romaneio = r.id_romaneio				
-- 				WHERE
-- 					r.id_romaneio = NEW.id_romaneio
-- 				GROUP BY 
-- 					nf.destinatario_id,
-- 					r.id_romaneio;
		WITH t AS (
				SELECT
					array_agg(CASE
						WHEN fd.principal = 1
						THEN NULL
						ELSE fd.id_integracao
					END) as lst_id_integracao,
					SUM(CASE
						WHEN fd.principal = 1
						THEN fd.id_integracao
						ELSE 0
					END) as id_integracao_principal,
					min(fd.id) as id_main,
					count(*) as qt,
					SUM(CASE
						WHEN fd.enviado = 1
						THEN 1
						ELSE 0
					END) as qt_enviado,
					fd.id_romaneio
				FROM
					fila_documentos_integracoes fd
					LEFT JOIN scr_notas_fiscais_imp nf
						ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
				WHERE
					1=1
					AND fd.tipo_documento = 1					
					AND tipo_integracao = 5
					AND fd.id_romaneio = 116633
				GROUP BY
					nf.destinatario_id,
					fd.id_romaneio
			)
			SELECT row_to_json(t) as agrupamento FROM t
			WHERE qt_enviado = qt;

				
				WITH t AS (
					SELECT 
						array_agg(CASE WHEN fd.principal = 1 THEN NULL ELSE fd.id_integracao END) as lst_id_integracao,
						SUM(CASE WHEN fd.principal = 1 THEN fd.id_integracao ELSE 0 END) as id_integracao_principal,
						min(fd.id) as id_main,
						count(*) as qt,
						SUM(CASE WHEN fd.enviado = 1 THEN 1 ELSE 0 END) as qt_enviado,
						fd.id_romaneio
					FROM 
						fila_documentos_integracoes fd					
						LEFT JOIN scr_notas_fiscais_imp nf
							ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
						
					WHERE
						fd.tipo_documento = 1
						--AND fd.enviado = 1
						AND tipo_integracao = 5
						AND fd.id_romaneio = 116633
					GROUP BY 
						nf.destinatario_id,
						fd.id_romaneio
				) 
				SELECT row_to_json(t) as agrupamento FROM t WHERE qt_enviado = qt;


				SELECT * FROM scr_romaneios WHERE id_romaneio = 116633

				SELECT * FROM api_integracao  ORDER BY 1 DESC LIMIT 1000 WHERE id_fila = 10799

				{"message":"Erro inserindo item - Servi\u00e7o n\u00e3o pode ser atribu\u00eddo porque j\u00e1 faz parte de uma rota: <a href=\"\/manager\/orders\/1040667\" target=\"_blank\">Entrega Doc. 000315668 - CIMED INDUSTRIA DE MEDICAMENTOS LTDA<\/a>","status_code":400}
				SELECT * FROM fila_documentos_integracoes WHERE id = 10813
				UPDATE fila_documentos_integracoes SET agrupado = 1 WHERE id_romaneio = 116633
				UPDATE fila_documentos_integracoes SET enviado = 0, agrupado = 0, pendencia = 0 WHERE id_romaneio = 116633 AND tipo_documento = 4
				UPDATE fila_documentos_integracoes SET enviado = 0, pendencia = 0 WHERE id_romaneio = 116633 AND tipo_documento = 4
							