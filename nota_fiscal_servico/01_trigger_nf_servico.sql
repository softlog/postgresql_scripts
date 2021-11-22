CREATE TRIGGER tgg_insere_nf_servico
AFTER INSERT OR UPDATE 
ON scr_conhecimento
FOR EACH ROW
WHEN (NEW.tipo_documento = 2)
EXECUTE PROCEDURE f_tgg_insere_nf_servico()



