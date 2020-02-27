CREATE TRIGGER tgg_z_scr_romaneios_filas
AFTER INSERT OR UPDATE OR DELETE
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_romaneios_envio()