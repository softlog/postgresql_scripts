CREATE OR REPLACE FUNCTION f_tgg_send_cadastro_integracao()
  RETURNS trigger AS
$BODY$
DECLARE
	v_existe integer;
BEGIN
        IF TG_TABLE_NAME = 'msg_subscricao' THEN 
		--Enfileira Cadastro de Embarcador no Comprovei
		IF NEW.id_notificacao = 1000 AND NEW.ativo = 1 THEN 
			SELECT count(*) 
			INTO v_existe
			FROM fila_envio_romaneios
			WHERE codigo_cliente = NEW.codigo_cliente
				AND id_notificacao = 1000
				AND id_tipo_servico = 100;

			IF v_existe = 0 THEN 
				INSERT INTO fila_envio_romaneios (id_notificacao, id_tipo_servico, codigo_cliente)
				VALUES (1000, 300, NEW.codigo_cliente);				
			END IF;

		END IF;

        END IF; 
        
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_msg_subscricao ON msg_subscricao;
CREATE TRIGGER tgg_msg_subscricao
AFTER INSERT OR UPDATE 
ON msg_subscricao
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_send_cadastro_integracao();


/*
SELECT * FROM fila_envio_romaneios WHERE codigo_cliente IS NOT NULL
id_romaneio = 226487

UPDATE msg_subscricao SET codigo_cliente = codigo_cliente WHERE id_notificacao = 1000;
SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010193144'
		  SELECT
                        id,
                        id_romaneio,
                        cnpjs_subscritos as lst_cnpj,
                        numero_protocolo,
                        f_get_dados_romaneio_json(id_romaneio, cnpjs_subscritos)
                            as dados_envio
                     FROM
                        fila_envio_romaneios
                     WHERE
                        status_envio = 1
                        AND status_confirmacao = 0
                        AND numero_protocolo IS NOT NULL
                        AND id_notificacao = 1000
                     ORDER BY
                        data_registro
                     DESC

                     

*/