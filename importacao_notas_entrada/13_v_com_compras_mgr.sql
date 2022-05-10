-- View: public.v_com_compras_mgr

-- DROP VIEW public.v_com_compras_mgr;

CREATE OR REPLACE VIEW public.v_com_compras_mgr AS 
 WITH log_ativ AS (
         SELECT com_compras_log_atividades.id_compra,
            com_compras_log_atividades.data_hora::date AS data_hora
           FROM com_compras_log_atividades
          WHERE com_compras_log_atividades.atividade_executada::text ~~ 'REPLICADA%'::text
        )
 SELECT DISTINCT ON (com_compras.numero_compra, com_compras.vl_total) com_compras.id_compra,
    com_compras.numero_compra,
    com_compras.status,
    com_compras.codigo_empresa,
    com_compras.codigo_filial,
    com_compras.cnpj_fornecedor,
    fornecedores.nome_razao,
    com_compras.tipo_documento,
    v_tipo_documento_compras.documento::character(50) AS tipo_documento_descricao,
    com_compras.numero_pedido_compra,
    (((tpdoc.codigo::text || '-'::text) || btrim(tpdoc.descricao::text)))::character(150) AS modelo_doc_fiscal,
    com_compras.serie_doc,
    com_compras.numero_documento,
    com_compras.data_emissao,
    com_compras.data_entrada,
    com_compras.data_registro::date AS data_registro,
    log_ativ.data_hora AS data_reg_ativ,
    com_compras.tipo_pagamento,
    com_compras.vl_total,
    com_compras.historico,
    com_compras_centro_custos.codigo_centro_custo,
    scf_centro_custos.nome_centro_custo,
    COALESCE(com_compras.placa_veiculo, ''::bpchar)::character(8) AS placa_veiculo,
    COALESCE(com_compras.id_os, 0) AS id_os,
    (( SELECT count(1) AS itens
           FROM com_compras_itens
          WHERE com_compras_itens.id_compra = com_compras.id_compra))::integer AS nr_itens,
        CASE
            WHEN COALESCE(com_compras.destino_lancamento, 1) = 2 THEN 2
            ELSE 1
        END AS destino_lancamento,
    ( SELECT string_agg(com_compras_itens.placa_veiculo::text, ','::text) AS placas_itens
           FROM com_compras_itens
          WHERE com_compras_itens.id_compra = com_compras.id_compra) AS placas_itens,
    COALESCE(com_compras.chave_nfe, ''::bpchar)::character(44) AS chave_nfe,
    conta_pagar_id,
    com_compras.modelo_doc_fiscal as modelo_fiscal,
    scf_contas_pagar.numero_ordem_pagamento,
    responsavel.nome_razao as responsavel_nome,
    responsavel.id_fornecedor as responsavel_id,
    responsavel.cnpj_cpf as responsavel_cnpj_cpf
   FROM com_compras
     LEFT JOIN fornecedores ON com_compras.cnpj_fornecedor = fornecedores.cnpj_cpf::bpchar
     LEFT JOIN fornecedores responsavel ON responsavel.cnpj_cpf = fornecedores.cnpj_cpf
     LEFT JOIN v_tipo_documento_compras ON com_compras.tipo_documento::integer = v_tipo_documento_compras.tipo_documento
     LEFT JOIN efd_mod_doc_fiscal tpdoc ON com_compras.modelo_doc_fiscal = tpdoc.codigo
     LEFT JOIN com_compras_centro_custos ON com_compras.id_compra = com_compras_centro_custos.id_compra
     LEFT JOIN scf_centro_custos ON com_compras_centro_custos.codigo_centro_custo::numeric = scf_centro_custos.codigo_centro_custo
     LEFT JOIN log_ativ ON com_compras.id_compra = log_ativ.id_compra
     LEFT JOIN scf_contas_pagar ON scf_contas_pagar.id_conta_pagar = com_compras.conta_pagar_id
  ORDER BY com_compras.numero_compra DESC, com_compras.vl_total;
