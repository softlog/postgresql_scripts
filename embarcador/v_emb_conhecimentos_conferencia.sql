
CREATE OR REPLACE VIEW public.v_emb_conhecimentos_conferencia AS 
 WITH tbl AS (
         SELECT unnest(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]) AS ordem,
            unnest(ARRAY['Frete Peso'::text, 'Frete Valor'::text, 'SEC CAT'::text, 'ITR'::text, 'Despacho'::text, 'Pedágios'::text, 'Gris/Ademe'::text, 'Base Cálculo ICMS'::text, 'Alíquota ICMS'::text, 'Valor ICMS'::text, 'Outras Despesas'::text, 'Total Frete'::text]) AS componente_frete,
            unnest(ARRAY[v_emb_conhecimentos_embarcados.frete_peso_previsto, v_emb_conhecimentos_embarcados.frete_valor_previsto, v_emb_conhecimentos_embarcados.sec_cat_previsto, v_emb_conhecimentos_embarcados.itr_previsto, v_emb_conhecimentos_embarcados.despacho_previsto, v_emb_conhecimentos_embarcados.pedagio_previsto, v_emb_conhecimentos_embarcados.valor_ademe_previsto, v_emb_conhecimentos_embarcados.base_calculo_icms_previsto, v_emb_conhecimentos_embarcados.aliquota_icms_previsto, v_emb_conhecimentos_embarcados.valor_icms_previsto, v_emb_conhecimentos_embarcados.total_outras_despesas_previsto, v_emb_conhecimentos_embarcados.total_frete_previsto]) AS valor_previsto,
            unnest(ARRAY[v_emb_conhecimentos_embarcados.frete_peso, v_emb_conhecimentos_embarcados.frete_valor, v_emb_conhecimentos_embarcados.sec_cat, v_emb_conhecimentos_embarcados.itr, v_emb_conhecimentos_embarcados.despacho, v_emb_conhecimentos_embarcados.pedagio, v_emb_conhecimentos_embarcados.valor_ademe, v_emb_conhecimentos_embarcados.base_calculo_icms, v_emb_conhecimentos_embarcados.aliquota_icms, v_emb_conhecimentos_embarcados.valor_icms, v_emb_conhecimentos_embarcados.total_outras_despesas, v_emb_conhecimentos_embarcados.total_frete]) AS valor_cobrado,
            unnest(ARRAY[v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento, v_emb_conhecimentos_embarcados.id_conhecimento]) AS id_conhecimento,
            unnest(ARRAY[v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado, v_emb_conhecimentos_embarcados.id_emb_conhecimento_embarcado]) AS id_emb_conhecimento_embarcado
           FROM v_emb_conhecimentos_embarcados
        )
 SELECT DISTINCT tbl.ordem,
    tbl.componente_frete,
    tbl.valor_cobrado,
    tbl.valor_previsto,
    tbl.valor_cobrado - tbl.valor_previsto AS diferenca,
    tbl.id_conhecimento,
    tbl.id_emb_conhecimento_embarcado
   FROM tbl
  ORDER BY tbl.id_emb_conhecimento_embarcado;
