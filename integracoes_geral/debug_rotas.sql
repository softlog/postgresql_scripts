SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 ORDER BY data_registro DESC LIMIT 1000

SELECT * FROM fila

SELECT * FROM fila_envio_romaneios
                        WHERE
                            1=1
                            AND id_tipo_servico = 301
                            --AND id = 32357
                    		AND id_notificacao = 1000
                    		AND status_envio = 0
                    		AND numero_protocolo IS NULL



                    		SELECT * FROM fila_envio_romaneios
                        WHERE
                            1=1
                            AND id_tipo_servico = 301
                            --AND id = 32357
                    		AND id_notificacao = 1000
                    		AND status_envio = 0


			BEGIN;
			UPDATE fila_envio_romaneios SET status_envio = 1 WHERE numero_protocolo IS NOT NULL AND id_tipo_servico = 301 AND status_envio = 0;
			COMMIT;

			
                    	SELECT row_to_json(row,true)::text as dados,  row.id, row.id_ocorrencia_nf, row.id_nota_fiscal_imp, numero_protocolo FROM (
                    	SELECT
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
                            COALESCE(edi.longitude,'0') as longitude,
                            fila.numero_protocolo
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
                                ON fila2.id_romaneio = rnf.id_romaneio AND fila2.id_notificacao = 1000
                                    AND fila2.id_tipo_servico = 2 AND fila2.status_confirmacao = 1

                            LEFT JOIN scr_romaneios r
                                ON fila2.id_romaneio = r.id_romaneio

                            LEFT JOIN fornecedores mot
                                ON r.id_motorista = mot.id_fornecedor
                        WHERE
                    		fila.id_tipo_servico = 301
                    		AND fila.id_notificacao = 1000
                    		AND fila.status_envio = 0
				--AND fila.numero_protocolo IS NULL
                            AND fila.id = 34520
                        ORDER BY fila2.id LIMIT 1) row

                        