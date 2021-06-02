-- View: public.v_acertos_relatorio_viagem

-- DROP VIEW public.v_acertos_relatorio_viagem;

CREATE OR REPLACE VIEW public.v_acertos_relatorio_viagem AS 
 SELECT ((scr_romaneios.tipo_romaneio::character(3)::text || btrim(to_char(scr_romaneios.id_romaneio, '0000000000'::text))))::character(11) AS chave,
    scr_romaneios.tipo_romaneio AS categoria,
    scr_romaneios.cod_empresa,
    scr_romaneios.cod_filial,
    scr_romaneios.id_motorista AS id_fornecedor,
    scr_romaneios.id_romaneio AS id_documento,
    scr_romaneios.numero_romaneio AS nr_documento,
    0 AS tipo_documento,
    scr_romaneios.data_romaneio::date AS data_referencia,
    scr_romaneios.vl_servico_for AS valor_pagar,
    'C'::character(1) AS operacao,
    scr_romaneios.numero_romaneio,
    scr_romaneios.id_romaneio,
    fornecedores.prazo_pagamento,
    fornecedores.frequencia_pagamento,
    fornecedores.codigo_centro_custo,
    scr_romaneios.id_acerto,
    scr_romaneios.fechamento,
    scr_romaneios.data_chegada,
    scr_romaneios.data_saida,
    scr_romaneios.diarias,
    COALESCE(proprietario.id_fornecedor, proprietario2.id_fornecedor) AS id_proprietario,
    scr_romaneios.placa_veiculo,
    ''::text AS lista_notas,
    scr_romaneios.numero_tabela_motorista,
        CASE
            WHEN scr_tabela_motorista.cpf_motorista = proprietario.cnpj_cpf::bpchar THEN 1
            ELSE 0
        END AS is_tabela_proprietario    
   FROM scr_romaneios
     LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
     LEFT JOIN veiculos ON scr_romaneios.placa_veiculo = veiculos.placa_veiculo
     LEFT JOIN fornecedores proprietario ON proprietario.cnpj_cpf::bpchar = scr_romaneios.cnpj_cpf_proprietario
     LEFT JOIN fornecedores proprietario2 ON proprietario2.id_fornecedor = veiculos.id_proprietario
     LEFT JOIN scr_tabela_motorista ON scr_tabela_motorista.numero_tabela_motorista = scr_romaneios.numero_tabela_motorista
  WHERE scr_romaneios.fechamento = 1 AND scr_romaneios.id_acerto IS NULL AND scr_romaneios.cancelado = 0
UNION
 SELECT (('3'::text || btrim(to_char(scr_conhecimento_redespacho.id_conhecimento_redespacho, '0000000000'::text))))::character(11) AS chave,
    3 AS categoria,
    scr_romaneios.cod_empresa,
    scr_romaneios.cod_filial,
    scr_romaneios.id_transportador_redespacho AS id_fornecedor,
    scr_conhecimento_redespacho.id_conhecimento_redespacho AS id_documento,
    scr_conhecimento.numero_ctrc_filial AS nr_documento,
    scr_conhecimento.tipo_documento,
    scr_romaneios.data_romaneio::date AS data_referencia,
    scr_conhecimento_redespacho.total_frete AS valor_pagar,
    'C'::character(1) AS operacao,
    scr_romaneios.numero_romaneio,
    scr_romaneios.id_romaneio,
    fornecedores.prazo_pagamento,
    fornecedores.frequencia_pagamento,
    fornecedores.codigo_centro_custo,
    scr_conhecimento_redespacho.id_acerto,
    scr_romaneios.fechamento,
    scr_romaneios.data_chegada,
    scr_romaneios.data_saida,
    scr_romaneios.diarias,
    proprietario.id_fornecedor AS id_proprietario,
    scr_romaneios.placa_veiculo,
    ( SELECT string_agg(nf.numero_nota_fiscal::text, ','::text) AS string_agg
           FROM scr_conhecimento_notas_fiscais nf
          WHERE nf.id_conhecimento = scr_conhecimento.id_conhecimento) AS lista_notas,
    scr_romaneios.numero_tabela_motorista,
    0 AS is_tabela_proprietario
   FROM scr_conhecimento_redespacho
     LEFT JOIN scr_romaneios ON scr_romaneios.id_romaneio = scr_conhecimento_redespacho.id_romaneios
     LEFT JOIN scr_conhecimento ON scr_conhecimento_redespacho.id_conhecimento = scr_conhecimento.id_conhecimento
     LEFT JOIN fornecedores ON scr_romaneios.id_transportador_redespacho = fornecedores.id_fornecedor
     LEFT JOIN veiculos ON scr_romaneios.placa_veiculo = veiculos.placa_veiculo
     LEFT JOIN fornecedores proprietario ON proprietario.cnpj_cpf::bpchar = scr_romaneios.cnpj_cpf_proprietario
     LEFT JOIN scr_tabela_motorista ON scr_tabela_motorista.numero_tabela_motorista = scr_romaneios.numero_tabela_motorista
  WHERE scr_conhecimento_redespacho.id_acerto IS NULL AND scr_conhecimento_redespacho.id_romaneios IS NOT NULL AND scr_romaneios.cancelado = 0
UNION
 SELECT (('3'::text || btrim(to_char(scr_conhecimento_redespacho.id_conhecimento_redespacho, '0000000000'::text))))::character(11) AS chave,
    3 AS categoria,
    scr_conhecimento.empresa_emitente AS cod_empresa,
    scr_conhecimento.filial_emitente AS cod_filial,
    scr_conhecimento.redespachador_id AS id_fornecedor,
    scr_conhecimento_redespacho.id_conhecimento_redespacho AS id_documento,
    scr_conhecimento.numero_ctrc_filial AS nr_documento,
    scr_conhecimento.tipo_documento,
    scr_conhecimento.data_emissao::date AS data_referencia,
    scr_conhecimento_redespacho.total_frete AS valor_pagar,
    'C'::character(1) AS operacao,
    (((scr_conhecimento.empresa_emitente::text || scr_conhecimento.filial_emitente::text) || '0000000'::text))::character(13) AS numero_romaneio,
    NULL::integer AS id_romaneio,
    fornecedores.prazo_pagamento,
    fornecedores.frequencia_pagamento,
    fornecedores.codigo_centro_custo,
    scr_conhecimento_redespacho.id_acerto,
    1 AS fechamento,
    scr_conhecimento.data_entrega AS data_chegada,
    scr_conhecimento.data_emissao::date AS data_saida,
    0::numeric(5,1) AS diarias,
    proprietario.id_fornecedor AS id_proprietario,
    scr_conhecimento.placa_veiculo::character(8) AS placa_veiculo,
    ( SELECT string_agg(nf.numero_nota_fiscal::text, ','::text) AS string_agg
           FROM scr_conhecimento_notas_fiscais nf
          WHERE nf.id_conhecimento = scr_conhecimento.id_conhecimento) AS lista_notas,
    scr_romaneios.numero_tabela_motorista,
    0 AS is_tabela_proprietario
   FROM scr_conhecimento_redespacho
     LEFT JOIN scr_conhecimento ON scr_conhecimento_redespacho.id_conhecimento = scr_conhecimento.id_conhecimento
     LEFT JOIN fornecedores ON scr_conhecimento.redespachador_id = fornecedores.id_fornecedor
     LEFT JOIN veiculos ON scr_conhecimento.placa_veiculo = veiculos.placa_veiculo
     LEFT JOIN scr_romaneios ON scr_conhecimento_redespacho.id_romaneios = scr_romaneios.id_romaneio
     LEFT JOIN fornecedores proprietario ON proprietario.cnpj_cpf::bpchar = scr_romaneios.cnpj_cpf_proprietario
     LEFT JOIN scr_tabela_motorista ON scr_tabela_motorista.numero_tabela_motorista = scr_romaneios.numero_tabela_motorista
  WHERE scr_conhecimento_redespacho.id_acerto IS NULL AND scr_conhecimento_redespacho.id_romaneios IS NULL
  ORDER BY 2;

