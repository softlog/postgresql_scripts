ALTER TABLE scr_faturamento ADD COLUMN gera_nfse integer DEFAULT 0;
ALTER TABLE com_nf ADD COLUMN id_faturamento integer;

CREATE TRIGGER tgg_insere_nf_servico_from_fatura
AFTER UPDATE OF gera_nfse 
ON scr_faturamento
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_insere_nf_servico_from_fatura()


