
CREATE TRIGGER tgg_lanca_nf_coleta
AFTER INSERT OR UPDATE 
ON scr_notas_fiscais_imp
FOR EACH ROW
WHEN (NEW.cod_interno_frete IS NOT NULL)
EXECUTE PROCEDURE f_tgg_lanca_nf_coleta();

--SELECT * FROM col_coletas LIMIT 100