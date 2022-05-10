
CREATE OR REPLACE VIEW public.v_emb_conhecimentos_embarcados AS 
 SELECT count(*) AS qt_notas,
    ec.id_emb_conhecimento_embarcado,
    ec.serie_conhecimento,
    ec.numero_conhecimento,
    ec.data_emissao,
    ec.valor_frete AS total_frete,
    ec.frete_peso,
    ec.frete_valor,
    ec.sec_cat,
    ec.itr,
    ec.despacho,
    ec.pedagio,
    ec.valor_ademe,
    ec.valor_icms,
    ec.base_calculo_icms,
    ec.aliquota_icms,
    COALESCE(ec.total_outras_despesas, 0.00)::numeric(13,2) AS total_outras_despesas,
    cf.total_frete AS total_frete_previsto,
    cf.frete_peso AS frete_peso_previsto,
    cf.frete_valor AS frete_valor_previsto,
    cf.sec_cat AS sec_cat_previsto,
    cf.itr AS itr_previsto,
    cf.despacho AS despacho_previsto,
    cf.pedagio AS pedagio_previsto,
    cf.valor_ademe AS valor_ademe_previsto,
    cf.total_outras_despesas AS total_outras_despesas_previsto,
    cf.valor_icms AS valor_icms_previsto,
    cf.aliquota_icms AS aliquota_icms_previsto,
    ec.valor_frete - cf.total_frete AS diferenca,
        CASE
            WHEN ec.aliquota_icms = cf.aliquota_icms THEN 1
            WHEN ec.aliquota_icms > cf.aliquota_icms THEN 2
            ELSE 3
        END AS comp_aliquota,
        CASE
            WHEN (ec.valor_frete - ec.valor_icms) = (cf.total_frete - cf.valor_icms) THEN 1
            WHEN (ec.valor_frete - ec.valor_icms) > (cf.total_frete - cf.valor_icms) THEN 2
            ELSE 3
        END AS comp_frete,
    string_agg(nf.numero_nota_fiscal, ','::text) AS lista_notas_fiscais,
    cf.base_calculo_icms AS base_calculo_icms_previsto,
    nfe.cnpj_emitente,
    nf.numero_ctrc_filial,
    nf.id_conhecimento,
    sum(nf.qtd_volumes) AS qtd_volumes,
    sum(nf.valor) AS valor,
    sum(nf.volume_cubico) AS volume_cubico,
    sum(nf.valor_total_produtos) AS valor_total_produtos
   FROM emb_conhecimentos_embarcados ec
     LEFT JOIN emb_notas_fiscais nfe ON nfe.id_emb_conhecimento_embarcado = ec.id_emb_conhecimento_embarcado
     LEFT JOIN v_notas_fiscais_embarcadas nf ON nf.id_conhecimento_notas_fiscais = nfe.id_conhecimento_notas_fiscais
     LEFT JOIN v_scr_conhecimento_cf_conemb cf ON cf.id_conhecimento = nf.id_conhecimento
  WHERE nf.redespachador_cnpj IS NOT NULL
  GROUP BY ec.id_emb_conhecimento_embarcado, nfe.cnpj_emitente, cf.total_frete, cf.frete_peso, cf.frete_valor, cf.sec_cat, cf.itr, cf.despacho, cf.pedagio, cf.valor_ademe, cf.total_outras_despesas, cf.valor_icms, cf.aliquota_icms, cf.base_calculo_icms, nf.numero_ctrc_filial, nf.id_conhecimento;

