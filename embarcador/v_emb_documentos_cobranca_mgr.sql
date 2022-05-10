-- View: public.v_emb_documentos_cobranca_mgr

-- DROP VIEW public.v_emb_documentos_cobranca_mgr;

CREATE OR REPLACE VIEW public.v_emb_documentos_cobranca_mgr AS 
 SELECT c.id_emb_documento_cobranca,
    c.codigo_empresa,
    c.codigo_filial,
    c.cnpj_transportadora,
    f.nome_razao AS transportadora_nome,
    cid.nome_cidade AS transportadora_cidade,
    cid.uf AS transportadora_uf,
    c.tipo_documento,
    c.serie_documento,
    c.numero_documento,
    c.data_emissao,
    c.data_vencimento,
    c.valor_documento,
    c.tipo_cobranca,
    c.valor_icms,
    c.valor_juros_mora,
    c.data_limite_desconto,
    c.valor_desconto,
    c.nome_banco,
    c.numero_agencia,
    c.digito_agencia,
    c.numero_conta_corrente,
    c.digito_conta_corrente,
    c.acao_documento,
    c.pendencias,
    c.status,
    c.conferido,
    c.fechada,
    string_agg(edci.numero_conhecimento::text, ','::text) AS lst_conhecimentos
   FROM emb_documentos_cobranca c
     LEFT JOIN fornecedores f ON f.cnpj_cpf::bpchar = c.cnpj_transportadora
     LEFT JOIN cidades cid ON cid.id_cidade::numeric = f.id_cidade
     LEFT JOIN emb_documentos_cobranca_itens edci ON c.id_emb_documento_cobranca = edci.id_emb_documento_cobranca
  GROUP BY c.id_emb_documento_cobranca, f.id_fornecedor, cid.id_cidade;
