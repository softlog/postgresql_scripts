CREATE TRIGGER tgg_scr_docs_digitalizados 
AFTER INSERT OR UPDATE OR DELETE
ON scr_docs_digitalizados
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_docs_digitalizados()