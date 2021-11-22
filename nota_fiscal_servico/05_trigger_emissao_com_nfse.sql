
CREATE OR REPLACE FUNCTION f_tgg_emissao_com_nfse()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_banco_dados integer;	
BEGIN

	SELECT id_string_conexao 
	INTO v_id_banco_dados
	FROM string_conexoes
	WHERE banco_dados = current_database();

	INSERT INTO fila_nfse(tipo_servico, id_banco_dados, id_doc)
	VALUES (1,v_id_banco_dados, NEW.id_nf);

        NEW.emite_nfse = 0;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



CREATE TRIGGER tgg_emissao_com_nfse 
BEFORE UPDATE OF emite_nfse
ON com_nf
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_emissao_com_nfse();
--SELECT * FROM fila_nfse
--UPDATE fila_nfse SET status = 1 WHERE id_doc = 10
--SELECT * FROM filial_parametros_iss
-- DELETE FROM filial_parametros_iss WHERE id IN (4,5,6,7)

--UPDATE filial SET habilitada_plugnotas = 1


--UPDATE com_nf SET id_integracao = '5fa5a9d096d6cb3035ec7833' WHERE id_nf = 24