
CREATE TRIGGER tgg_envia_fila_efrete 
AFTER INSERT OR UPDATE 
ON fila_documentos_integracoes
FOR EACH ROW
WHEN (NEW.tipo_integracao = 6)
EXECUTE PROCEDURE f_tgg_envia_fila_efrete()