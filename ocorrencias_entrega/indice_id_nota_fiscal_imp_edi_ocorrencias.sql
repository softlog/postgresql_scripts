CREATE INDEX edi_ocorrencias_entrega_id_nota_fiscal_imp_idx
  ON public.edi_ocorrencias_entrega
  USING btree (id_nota_fiscal_imp );