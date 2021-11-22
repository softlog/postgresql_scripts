CREATE INDEX ind_edi_ocorrencias_entrega_id_ocorrencia_nf
   ON edi_ocorrencias_entrega (id_ocorrencia_nf ASC NULLS LAST);


BEGIN;
UPDATE fila_envio_romaneios SET
                            status_envio = 1,
                            numero_protocolo = '2021082619G6IKSTDPEUE',
                            mensagem = '{"protocol":"2021082619G6IKSTDPEUE"}',
                            data_envio = now()
                        WHERE id = 9350;
                       ROLLBACK;

SELECT * FROM fila_envio_romaneios WHERE id = 9350


                       SELECT
                        id,
                        id_romaneio,
                        numero_protocolo
                     FROM
                        fila_envio_romaneios
                     WHERE
                     	id_tipo_servico = 301
                   		AND id_notificacao = 1000
                    	AND status_envio = 1
                        AND numero_protocolo IS NOT NULL
                     ORDER BY
                        data_registro
                     DESC


		     BEGIN;
                     UPDATE fila_envio_romaneios SET
                            status_envio = 1,
                            numero_protocolo = '2021082619G6JKSTDXVSW',
                            mensagem = '{"protocol":"2021082619G6JKSTDXVSW"}',
                            data_envio = now()
                        WHERE id = 9354

                        ROLLBACK;