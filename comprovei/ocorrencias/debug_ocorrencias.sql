/*
SELECT id_nota_fiscal_imp, serie_nota_fiscal, id_romaneio FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal = '000671627' ORDER BY 1 DESC

Nota Fiscal 20559072
Romaneio 195296
Id Ocorrencia NF 27152493
Id Fila Ocorrencia 32357

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 20559072

SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 195296


SELECT * FROM fila_envio_romaneios WHERE id_ocorrencia_nf = 27152493

SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 AND data_envio IS NOT NULL ORDER BY data_envio DESC

SELECT * FROM fila_envio_romaneios WHERE status_envio = 0 AND id_tipo_servico = 301

SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 195520

id_tipo_servico = 2 AND status_envio = 0 
data_envio IS NULL ORDER BY data_envio DESC

AND mensagem2 like '%driver%'

UPDATE fila_envio_romaneios SET status_envio = 1 WHERE numero_protocolo IS NOT NULL AND id_tipo_servico = 301 
data_registro >= '2021-09-16 15:00:00' AND numero_protocolo IS NOT NULL AND id_tipo_servico = 301

AND data_envio IS NOT NULL ORDER BY data_envio DESC LIMIT 100

*/

SELECT row_to_json(row,true)::text as dados,  row.id, row.id_ocorrencia_nf, row.id_nota_fiscal_imp FROM (
                    	SELECT
			    fila2.*,
                            nfo.id_ocorrencia_nf,
                            nf.id_nota_fiscal_imp,
                    		fila.id,
                            nf.chave_nfe,
                            r.numero_romaneio,
                            r.id_romaneio,
                            trim(mot.cnpj_cpf) as cpf_motorista,
                            to_char(r.data_saida,'YYYY-MM-DD') as data_romaneio,
                            lpad(eoc.codigo_status::text,3,'0') as id_ocorrencia,
                            to_char(nfo.data_ocorrencia - INTERVAL'30 minutes','YYYY-MM-DD HH24:MI:SS') as data_ini_ocorrencia,
                            to_char(nfo.data_ocorrencia,'YYYY-MM-DD HH24:MI:SS') as data_fim_ocorrencia,
                            trim(nfo.obs_ocorrencia) as observacao,
                            COALESCE(edi.url_imagem, f_get_url_canhoto(nf.id_nota_fiscal_imp,3)) as link_img,
                            trim(nf.nome_recebedor) as nome_recebedor,
                            COALESCE(edi.latitude,'0') as latitude,
                            COALESCE(edi.longitude,'0') as longitude
                    	FROM
                            fila_envio_romaneios fila

                            LEFT JOIN  scr_notas_fiscais_imp_ocorrencias nfo
                                ON fila.id_ocorrencia_nf = nfo.id_ocorrencia_nf

                            LEFT JOIN scr_notas_fiscais_imp nf
                                ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp

                            LEFT JOIN edi_ocorrencias_comprovei eoc
                                ON eoc.id_ocorrencia_softlog = nfo.id_ocorrencia

                            LEFT JOIN edi_ocorrencias_entrega edi
                                ON edi.id_ocorrencia_nf = nfo.id_ocorrencia_nf

                            LEFT JOIN scr_romaneio_nf rnf
                                ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp

                            LEFT JOIN fila_envio_romaneios fila2
                                ON fila2.id_romaneio = rnf.id_romaneio AND fila2.id_notificacao = 1000 AND fila2.status_confirmacao = 1
                                    AND fila2.id_tipo_servico = 2

                            LEFT JOIN scr_romaneios r
                                ON fila2.id_romaneio = r.id_romaneio

                            LEFT JOIN fornecedores mot
                                ON r.id_motorista = mot.id_fornecedor
                        WHERE
                    		fila.id_tipo_servico = 301
                    		AND fila.id_notificacao = 1000
                    		--AND fila.status_envio = 0
                            AND fila.id = 32357
                        ORDER BY fila2.id ASC LIMIT 1
                ) row

                SELECT * FROM fila_envio_romaneios WHERE 