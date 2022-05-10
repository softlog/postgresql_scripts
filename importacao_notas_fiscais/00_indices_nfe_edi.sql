CREATE INDEX ind_scr_doc_integracao_nfe_id_doc_integracao 
   ON scr_doc_integracao_nfe (id_doc_integracao ASC NULLS LAST);

CREATE INDEX ind_scr_doc_integracao_nfe_id_nota_fiscal_imp
   ON scr_doc_integracao_nfe (id_nota_fiscal_imp ASC NULLS LAST);

CREATE INDEX ind_scr_doc_integracao_nfe_chave_doc 
   ON scr_doc_integracao_nfe (chave_doc ASC NULLS LAST);

