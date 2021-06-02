CREATE INDEX ind_scr_docs_digitalizados_id_nf
   ON scr_docs_digitalizados (id_conhecimento_notas_fiscais ASC NULLS LAST);


CREATE INDEX ind_scr_docs_digitalizados_id_nf2
   ON scr_docs_digitalizados (id_nota_fiscal_imp ASC NULLS LAST);

