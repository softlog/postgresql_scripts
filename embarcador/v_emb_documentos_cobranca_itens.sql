-- View: public.v_emb_documentos_cobranca_itens

-- DROP VIEW public.v_emb_documentos_cobranca_itens;

CREATE OR REPLACE VIEW public.v_emb_documentos_cobranca_itens AS 
 WITH t1 AS (
         SELECT c.lista_notas_fiscais,
            c.qt_notas,
            c.comp_aliquota,
            c.comp_frete,
            c.id_conhecimento,
            c.diferenca,
            itens.id_documento_cobranca_itens,
            c.numero_ctrc_filial,
            c.total_frete,
            c.total_frete_previsto,
            c.aliquota_icms,
            c.aliquota_icms_previsto,
            itens.cnpj_transportadora,
            itens.serie_conhecimento,
            itens.numero_conhecimento,
            itens.id_emb_documento_cobranca,
            itens.id_emb_conhecimento_embarcado,
            itens.aprovado,
            itens.conferido
           FROM emb_documentos_cobranca_itens itens
             LEFT JOIN v_emb_conhecimentos_embarcados c ON itens.id_emb_conhecimento_embarcado = c.id_emb_conhecimento_embarcado
          WHERE itens.id_emb_conhecimento_embarcado IS NOT NULL AND c.numero_ctrc_filial IS NOT NULL
        ), t2 AS (
         SELECT count(*) AS qt_minutas,
            t1.id_emb_conhecimento_embarcado,
            string_agg(t1.numero_ctrc_filial::text, ','::text) AS lst_minutas
           FROM t1
          GROUP BY t1.id_emb_conhecimento_embarcado
        ), t3 AS (
         SELECT count(*)::integer AS qt,
            t2.id_emb_conhecimento_embarcado,
            t2.qt_minutas,
            nf.numero_nota_fiscal
           FROM emb_notas_fiscais nf
             RIGHT JOIN t2 ON t2.id_emb_conhecimento_embarcado = nf.id_emb_conhecimento_embarcado
          GROUP BY t2.id_emb_conhecimento_embarcado, t2.qt_minutas, nf.numero_nota_fiscal
        ), t4 AS (
         SELECT t3.id_emb_conhecimento_embarcado,
            count(*) AS qt_nf_conhecimento,
            t3.qt_minutas,
            string_agg(t3.numero_nota_fiscal::text, ','::text) AS lista_notas_conhecimento
           FROM t3
          GROUP BY t3.id_emb_conhecimento_embarcado, t3.qt_minutas
        ), t5 AS (
         SELECT t1.id_emb_conhecimento_embarcado,
            t4.lista_notas_conhecimento,
            string_agg(((t1.numero_ctrc_filial::text || ' Nfs:('::text) || t4.lista_notas_conhecimento) || ')'::text, '/'::text) AS lst_minutas_notas,
            max(
                CASE
                    WHEN t4.qt_minutas > 1 THEN 0::bigint
                    ELSE t4.qt_nf_conhecimento
                END) AS qt_nf_conhecimento,
            max(
                CASE
                    WHEN t4.qt_minutas > 1 THEN '-1'::integer
                    ELSE t1.id_conhecimento
                END) AS id_conhecimento,
            t4.qt_minutas,
            t1.cnpj_transportadora,
            t1.serie_conhecimento,
            t1.numero_conhecimento,
            t1.id_emb_documento_cobranca,
            t1.id_documento_cobranca_itens,
            t1.aprovado,
            t1.conferido
           FROM t1
             RIGHT JOIN t4 ON t1.id_emb_conhecimento_embarcado = t4.id_emb_conhecimento_embarcado
          GROUP BY t1.id_emb_conhecimento_embarcado, t4.lista_notas_conhecimento, t4.qt_minutas, t1.cnpj_transportadora, t1.serie_conhecimento, t1.numero_conhecimento, t1.id_emb_documento_cobranca, t1.id_documento_cobranca_itens, t1.aprovado, t1.conferido
        ), t6 AS (
         SELECT t5.id_documento_cobranca_itens,
            t5.cnpj_transportadora,
            t5.serie_conhecimento,
            t5.numero_conhecimento,
            t5.id_emb_documento_cobranca,
            t5.id_emb_conhecimento_embarcado,
            t5.lst_minutas_notas,
            t5.lista_notas_conhecimento,
            t5.qt_nf_conhecimento,
            t5.id_conhecimento,
            t5.qt_minutas,
            t5.aprovado,
            t5.conferido,
            t1.lista_notas_fiscais,
            t1.qt_notas,
            t1.comp_aliquota,
            t1.comp_frete,
            t1.id_conhecimento,
            t1.diferenca,
            t1.numero_ctrc_filial,
            t1.total_frete,
            t1.total_frete_previsto,
            t1.aliquota_icms,
            t1.aliquota_icms_previsto,
                CASE
                    WHEN t1.comp_aliquota = 2 THEN 'Alíquota de imposto a maior'::text
                    WHEN t1.comp_aliquota = 3 THEN 'Alíquota de imposto a menor'::text
                    ELSE NULL::text
                END AS comparacao_aliquota,
                CASE
                    WHEN t1.comp_frete = 2 THEN 'Frete cobrado a maior'::text
                    WHEN t1.comp_frete = 3 THEN 'Frete cobrado a menor'::text
                    ELSE NULL::text
                END AS comparacao_frete,
                CASE
                    WHEN t1.id_conhecimento IS NULL THEN 'Notas do Conhecimento em mais de uma minuta: '::text || t5.lst_minutas_notas
                    ELSE NULL::text
                END AS comparacao_minuta,
                CASE
                    WHEN t1.qt_notas <> t5.qt_nf_conhecimento AND t1.id_conhecimento IS NOT NULL THEN 'Conhecimento e Minuta tem quantidade de notas diferente: '::text || t5.lst_minutas_notas
                    ELSE NULL::text
                END AS comparacao_notas,
                CASE
                    WHEN t1.comp_aliquota = 1 THEN 0
                    ELSE 1
                END AS aliquota_diferente,
                CASE
                    WHEN t1.comp_frete = 1 THEN 0
                    ELSE 1
                END AS valor_frete_diferente,
                CASE
                    WHEN t1.id_conhecimento IS NULL THEN 1
                    ELSE 0
                END AS minuta_incompativel,
                CASE
                    WHEN t1.qt_notas <> t5.qt_nf_conhecimento AND t1.id_conhecimento IS NOT NULL THEN 1
                    ELSE 0
                END AS notas_diferente
           FROM t5
             LEFT JOIN t1 ON t5.id_conhecimento = t1.id_conhecimento
        )
 SELECT t6.id_documento_cobranca_itens,
    t6.lista_notas_conhecimento::character(250) AS lista_nf,
    t6.numero_ctrc_filial,
    COALESCE(t6.total_frete, 0.00) AS total_frete,
    COALESCE(t6.total_frete_previsto, 0.00) AS total_frete_previsto,
    COALESCE(t6.diferenca, 0.00) AS diferenca,
    COALESCE(t6.aliquota_icms, 0.00) AS aliquota_icms,
    COALESCE(t6.aliquota_icms_previsto, 0.00) AS aliquota_icms_previsto,
    t6.cnpj_transportadora,
    t6.serie_conhecimento,
    t6.numero_conhecimento,
    t6.id_emb_documento_cobranca,
    t6.id_emb_conhecimento_embarcado,
    rtrim(((COALESCE(t6.comparacao_aliquota || '/'::text, ''::text) || COALESCE(t6.comparacao_frete || '/'::text, ''::text)) || COALESCE(t6.comparacao_minuta || '/'::text, ''::text)) || COALESCE(t6.comparacao_notas || '/'::text, ''::text), './'::text)::character(250) AS mensagem,
    t6.aprovado,
    t6.conferido,
    t6.aliquota_diferente,
    t6.valor_frete_diferente,
    t6.minuta_incompativel,
    t6.notas_diferente
   FROM t6 t6(id_documento_cobranca_itens, cnpj_transportadora, serie_conhecimento, numero_conhecimento, id_emb_documento_cobranca, id_emb_conhecimento_embarcado, lst_minutas_notas, lista_notas_conhecimento, qt_nf_conhecimento, id_conhecimento, qt_minutas, aprovado, conferido, lista_notas_fiscais, qt_notas, comp_aliquota, comp_frete, id_conhecimento_1, diferenca, numero_ctrc_filial, total_frete, total_frete_previsto, aliquota_icms, aliquota_icms_previsto, comparacao_aliquota, comparacao_frete, comparacao_minuta, comparacao_notas, aliquota_diferente, valor_frete_diferente, minuta_incompativel, notas_diferente)
  ORDER BY t6.numero_conhecimento;
