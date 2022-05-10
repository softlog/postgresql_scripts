/*
CREATE TRIGGER tgg_lanca_frt_ab_epta
AFTER INSERT OR UPDATE 
ON frt_ab_epta_sga
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_lanca_frt_ab_epta();
*/

CREATE TRIGGER tgg_lanca_frt_ab_epta_before
BEFORE INSERT OR UPDATE 
ON frt_ab_epta_sga
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_lanca_frt_ab_epta();