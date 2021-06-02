
CREATE TRIGGER tgg_update_fila_app
AFTER INSERT OR UPDATE OR DELETE
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_update_fila_app()