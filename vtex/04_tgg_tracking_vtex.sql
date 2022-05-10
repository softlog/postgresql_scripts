
CREATE TRIGGER tgg_tracking_vtex
AFTER INSERT OR UPDATE 
ON scr_conhecimento_ocorrencias_nf
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_tracking_vtex();


CREATE TRIGGER tgg_tracking_vtex_nf_imp
AFTER INSERT OR UPDATE 
ON scr_notas_fiscais_imp_ocorrencias
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_tracking_vtex();