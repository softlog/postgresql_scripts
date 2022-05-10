-- View: public.v_emb_conhecimentos_embarcados_mgr

-- DROP VIEW public.v_emb_conhecimentos_embarcados_mgr;

CREATE OR REPLACE VIEW public.v_emb_conhecimentos_embarcados_mgr AS 
 SELECT DISTINCT c.id_emb_conhecimento_embarcado,
    c.codigo_empresa,
    c.codigo_filial,
    c.serie_conhecimento,
    c.numero_conhecimento,
    c.data_emissao,
    c.condicao_frete,
    c.peso_transportado,
    c.valor_frete,
    c.base_calculo_icms,
    c.aliquota_icms,
    c.valor_icms,
    c.frete_peso,
    c.frete_valor,
    c.sec_cat,
    c.itr,
    c.despacho,
    c.pedagio,
    c.valor_ademe,
    c.substituicao_tributaria,
    c.cnpj_emitente,
    f.nome_razao AS transportadora,
    c.cnpj_remetente,
    filial.razao_social AS embarcadora,
    c.acao_documento,
    c.tipo_transporte,
    c.cfop,
    c.tipo_meio_transporte,
    c.total_outras_despesas,
    c.valor_iss,
    c.serie_conhecimento_origem,
    c.numero_conhecimento_origem,
    c.pendencias,
    vc.id_conhecimento,
    vc.numero_ctrc_filial AS numero_minuta,
    string_agg(nf.numero_nota_fiscal::text, ','::text) AS lst_nf,
    dc.numero_documento AS numero_fatura,
    dc.data_vencimento AS vencimento_fatura
   FROM emb_conhecimentos_embarcados c
     LEFT JOIN fornecedores f ON f.cnpj_cpf::bpchar = c.cnpj_emitente
     LEFT JOIN filial ON filial.cnpj = c.cnpj_remetente
     LEFT JOIN v_emb_conhecimentos_embarcados vc ON vc.id_emb_conhecimento_embarcado = c.id_emb_conhecimento_embarcado
     LEFT JOIN emb_notas_fiscais nf ON nf.id_emb_conhecimento_embarcado = c.id_emb_conhecimento_embarcado
     LEFT JOIN emb_documentos_cobranca_itens dci ON dci.id_emb_conhecimento_embarcado = c.id_emb_conhecimento_embarcado
     LEFT JOIN emb_documentos_cobranca dc ON dc.id_emb_documento_cobranca = dci.id_emb_documento_cobranca
  GROUP BY c.id_emb_conhecimento_embarcado, f.id_fornecedor, filial.id_filial, vc.id_conhecimento, vc.numero_ctrc_filial, dc.id_emb_documento_cobranca;

