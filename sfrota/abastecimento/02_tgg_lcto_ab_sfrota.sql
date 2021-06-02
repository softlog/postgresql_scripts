
CREATE TRIGGER tgg_lcto_ab_sfrota
AFTER INSERT OR UPDATE 
ON frt_ab_import_sfrota
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_lcto_ab_sfrota()