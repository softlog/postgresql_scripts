CREATE TRIGGER tgg_eventos_sistema_romaneio
AFTER INSERT OR UPDATE OR DELETE
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_eventos_sistema();


CREATE TRIGGER tgg_eventos_sistema_manifesto
AFTER INSERT OR UPDATE OR DELETE
ON scr_manifesto
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_eventos_sistema();
