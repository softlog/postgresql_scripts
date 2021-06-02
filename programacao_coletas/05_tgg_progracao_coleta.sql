
CREATE TRIGGER tgg_progracao_coleta 
AFTER INSERT OR UPDATE 
ON scr_programacao_coleta
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_programacao_coleta()