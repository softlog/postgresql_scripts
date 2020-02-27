CREATE OR REPLACE FUNCTION f_tgg_envia_fila_efrete()
  RETURNS trigger AS
$BODY$
DECLARE
	v_bd integer;
BEGIN

	SELECT id_string_conexao
	INTO v_bd
	WHERE banco_dados = current_database();

	INSERT INTO fila_processamento_efrete (id_banco_dados, id_documento, data_registro, tentativas)
	VALUES (v_bd, NEW.id, now(), 0);	

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_envia_fila_efrete
AFTER INSERT OR UPDATE 
ON fila_documentos_integracoes
FOR EACH ROW
WHEN (NEW.tipo_documento = 6)
EXECUTE PROCEDURE f_tgg_envia_fila_efrete()