-- View: public.v_scr_romaneio_despesas

-- DROP VIEW public.v_scr_romaneio_despesas;

CREATE OR REPLACE VIEW public.v_scr_romaneio_despesas AS 
 WITH tbl_romaneio_despesas AS (
         SELECT scr_romaneio_despesas.id_romaneio_despesa,
            scr_romaneio_despesas.id_romaneio,
            scr_romaneio_despesas.id_fornecedor,
            scr_romaneio_despesas.id_despesa,
            scr_romaneio_despesas.cod_empresa,
            scr_romaneio_despesas.cod_filial,
            scr_romaneio_despesas.id_unidade,
            scr_romaneio_despesas.quantidade,
            scr_romaneio_despesas.vl_unitario,
            scr_romaneio_despesas.valor_despesa,
            scr_romaneio_despesas.codigo_centro_custo,
            scr_romaneio_despesas.observacao,
            scr_romaneio_despesas.data_referencia,
            scr_romaneio_despesas.descricao,
            scr_romaneio_despesas.tipo_operacao,
            scr_romaneio_despesas.credito_debito,
            scr_romaneio_despesas.forma_pagamento,
            scr_romaneios.id_acerto,
            scr_romaneio_despesas.odometro,
            scr_romaneio_despesas.horimetro,
            scr_romaneio_despesas.lancar_conta,
            scr_romaneio_despesas.id_conta_pagar,
            scr_romaneio_despesas.data_vencimento,
            scr_romaneio_despesas.data_emissao,
            scr_despesas_viagem_1.tipo_controle,
            scr_romaneios.numero_romaneio
           FROM scr_romaneio_despesas
             LEFT JOIN scr_romaneios ON scr_romaneios.id_romaneio = scr_romaneio_despesas.id_romaneio AND scr_romaneios.id_acerto IS NOT NULL
             LEFT JOIN scr_despesas_viagem scr_despesas_viagem_1 ON scr_romaneio_despesas.id_despesa = scr_despesas_viagem_1.id_despesa
        ), 
        tbl_totais_despesas AS (
         SELECT tbl_romaneio_despesas.id_romaneio,
            tbl_romaneio_despesas.id_acerto,
            COALESCE(sum(
                CASE
                    WHEN tbl_romaneio_despesas.tipo_operacao = 1 AND tbl_romaneio_despesas.tipo_controle <> 5 THEN tbl_romaneio_despesas.valor_despesa
                    ELSE 0::numeric
                END), 0.00)::numeric(12,2) AS total_acrescimos,
            COALESCE(sum(
                CASE
                    WHEN tbl_romaneio_despesas.tipo_operacao = 2 THEN tbl_romaneio_despesas.valor_despesa
                    ELSE 0::numeric
                END), 0.00)::numeric(12,2) AS total_neutro,
            COALESCE(sum(
                CASE
                    WHEN tbl_romaneio_despesas.tipo_operacao = 3 THEN tbl_romaneio_despesas.valor_despesa
                    ELSE 0::numeric
                END), 0.00)::numeric(12,2) AS total_desconto
           FROM tbl_romaneio_despesas
          WHERE tbl_romaneio_despesas.credito_debito = ANY (ARRAY[1, 2])
          GROUP BY tbl_romaneio_despesas.id_romaneio, tbl_romaneio_despesas.id_acerto
        ), tbl_romaneio_motorista AS (
         SELECT '-1'::integer AS id_romaneio_despesa,
            scr_romaneios.id_romaneio,
            scr_romaneios.id_motorista,
            '-1'::integer AS id_despesa,
            scr_romaneios.cod_empresa,
            scr_romaneios.cod_filial,
            NULL::numeric(12,3) AS id_unidade,
            1 AS quantidade,
            COALESCE(scr_romaneios.vl_servico_for - tbl_totais_despesas.total_desconto + tbl_totais_despesas.total_acrescimos, scr_romaneios.vl_servico_for)::numeric(12,2) AS vl_unitario,
            COALESCE(scr_romaneios.vl_servico_for - tbl_totais_despesas.total_desconto + tbl_totais_despesas.total_acrescimos, scr_romaneios.vl_servico_for)::numeric(12,2) AS valor_despesa,
            fornecedores.codigo_centro_custo,
            NULL::text AS observacao,
            scr_romaneios.data_romaneio,
                CASE
                    WHEN scr_romaneios.tipo_romaneio = 1 THEN 'ROMANEIO COLETA/ENTREGA Nº '::text
                    ELSE 'ROMANEIO VIAGEM Nº '::text
                END || scr_romaneios.numero_romaneio::text AS descricao,
            2 AS tipo_operacao,
            2 AS credito_debito,
            2 AS forma_pagamento,
            scr_romaneios.id_acerto,
            NULL::integer AS id_conta_pagar
           FROM scr_romaneios
             LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
             LEFT JOIN tbl_totais_despesas ON scr_romaneios.id_romaneio = tbl_totais_despesas.id_romaneio
          WHERE scr_romaneios.fechamento = 1 AND scr_romaneios.id_acerto IS NOT NULL
        ), tbl_fechamento_periodo AS (
         SELECT '-2'::integer AS id_romaneio_despesa,
            0 AS id_romaneio,
            scr_relatorio_viagem.id_fornecedor,
            '-2'::integer AS id_despesa,
            scr_relatorio_viagem.empresa AS cod_empresa,
            scr_relatorio_viagem.filial AS cod_filial,
            NULL::numeric(12,3) AS id_unidade,
            1 AS quantidade,
            sum(scr_relatorio_viagem_fechamentos.valor_pagar) AS vl_unitario,
            sum(scr_relatorio_viagem_fechamentos.valor_pagar) AS valor_despesa,
            NULL::integer AS codigo_centro_custo,
            NULL::text AS observacao,
            scr_relatorio_viagem.fechamento_final,
            'RELATÓRIO VIAGEM Nº '::text || scr_relatorio_viagem.numero_relatorio::text AS descricao,
            2 AS tipo_operacao,
            2 AS credito_debito,
            2 AS forma_pagamento,
            scr_relatorio_viagem.id_relatorio_viagem,
            NULL::integer AS id_conta_pagar
           FROM scr_relatorio_viagem_fechamentos
             LEFT JOIN scr_relatorio_viagem ON scr_relatorio_viagem.id_relatorio_viagem = scr_relatorio_viagem_fechamentos.id_relatorio_viagem
           WHERE desconto = 0
          GROUP BY scr_relatorio_viagem.id_relatorio_viagem
        ), agrupamento AS (
         SELECT 1 AS origem,
            tbl_romaneio_despesas.id_romaneio_despesa,
            tbl_romaneio_despesas.id_romaneio,
            tbl_romaneio_despesas.id_fornecedor,
            tbl_romaneio_despesas.id_despesa,
            tbl_romaneio_despesas.cod_empresa,
            tbl_romaneio_despesas.cod_filial,
            tbl_romaneio_despesas.id_unidade,
            tbl_romaneio_despesas.quantidade,
            tbl_romaneio_despesas.vl_unitario,
            tbl_romaneio_despesas.valor_despesa,
            tbl_romaneio_despesas.codigo_centro_custo,
            tbl_romaneio_despesas.observacao,
            tbl_romaneio_despesas.data_referencia,
            tbl_romaneio_despesas.descricao::text || COALESCE(('('::text || tbl_romaneio_despesas.numero_romaneio::text) || ')'::text, ''::text) AS descricao,
            tbl_romaneio_despesas.tipo_operacao,
            tbl_romaneio_despesas.credito_debito,
            tbl_romaneio_despesas.forma_pagamento,
            tbl_romaneio_despesas.id_acerto,
            tbl_romaneio_despesas.odometro,
            tbl_romaneio_despesas.horimetro,
            tbl_romaneio_despesas.lancar_conta,
            tbl_romaneio_despesas.id_conta_pagar,
            tbl_romaneio_despesas.data_vencimento,
            tbl_romaneio_despesas.data_emissao
           FROM tbl_romaneio_despesas
        UNION
         SELECT 2 AS origem,
            tbl_romaneio_motorista.id_romaneio_despesa,
            tbl_romaneio_motorista.id_romaneio,
            tbl_romaneio_motorista.id_motorista AS id_fornecedor,
            tbl_romaneio_motorista.id_despesa,
            tbl_romaneio_motorista.cod_empresa,
            tbl_romaneio_motorista.cod_filial,
            tbl_romaneio_motorista.id_unidade,
            tbl_romaneio_motorista.quantidade,
            tbl_romaneio_motorista.vl_unitario,
            tbl_romaneio_motorista.valor_despesa,
            tbl_romaneio_motorista.codigo_centro_custo,
            tbl_romaneio_motorista.observacao,
            tbl_romaneio_motorista.data_romaneio AS data_referencia,
            tbl_romaneio_motorista.descricao,
            tbl_romaneio_motorista.tipo_operacao,
            tbl_romaneio_motorista.credito_debito,
            tbl_romaneio_motorista.forma_pagamento,
            tbl_romaneio_motorista.id_acerto,
            NULL::integer AS odometro,
            NULL::numeric(9,1) AS horimetro,
            NULL::integer AS lancar_conta,
            NULL::integer AS id_conta_pagar,
            NULL::date AS data_vencimento,
            NULL::date AS data_emissao
           FROM tbl_romaneio_motorista
        UNION
         SELECT 3 AS origem,
            '-3'::integer AS id_romaneio_despesa,
            0 AS id_romaneio,
            scr_relatorio_viagem.id_fornecedor,
            '-3'::integer AS id_despesa,
            scr_relatorio_viagem.empresa,
            scr_relatorio_viagem.filial,
            NULL::numeric(12,3) AS id_unidade,
            1 AS quantidade,
            COALESCE(sum(tbl_totais_despesas.total_acrescimos * '-1'::integer::numeric), 0.00) AS vl_unitario,
            COALESCE(sum(tbl_totais_despesas.total_acrescimos * '-1'::integer::numeric), 0.00) AS valor_despesa,
            NULL::integer AS codigo_centro_custo,
            NULL::text AS observacao,
            scr_relatorio_viagem.fechamento_final AS data_referencia,
            'REF. RELATÓRIO VIAGEM Nº '::text || COALESCE(scr_relatorio_viagem.numero_relatorio::text, ''::text) AS descricao,
            2 AS tipo_operacao,
            2 AS credito_debito,
            2 AS forma_pagamento,
            scr_relatorio_viagem.id_relatorio_viagem AS id_acerto,
            NULL::integer AS odometro,
            NULL::numeric(9,1) AS horimetro,
            NULL::integer AS lancar_conta,
            NULL::integer AS id_conta_pagar,
            NULL::date AS data_vencimento,
            NULL::date AS data_emissao
           FROM scr_relatorio_viagem
             LEFT JOIN tbl_totais_despesas ON scr_relatorio_viagem.id_relatorio_viagem = tbl_totais_despesas.id_acerto
          GROUP BY scr_relatorio_viagem.id_relatorio_viagem
        UNION
         SELECT 4 AS origem,
            tbl_fechamento_periodo.id_romaneio_despesa,
            tbl_fechamento_periodo.id_romaneio,
            tbl_fechamento_periodo.id_fornecedor,
            tbl_fechamento_periodo.id_despesa,
            tbl_fechamento_periodo.cod_empresa,
            tbl_fechamento_periodo.cod_filial,
            tbl_fechamento_periodo.id_unidade,
            tbl_fechamento_periodo.quantidade,
            tbl_fechamento_periodo.vl_unitario,
            tbl_fechamento_periodo.valor_despesa,
            tbl_fechamento_periodo.codigo_centro_custo,
            tbl_fechamento_periodo.observacao,
            tbl_fechamento_periodo.fechamento_final AS data_referencia,
            tbl_fechamento_periodo.descricao,
            tbl_fechamento_periodo.tipo_operacao,
            tbl_fechamento_periodo.credito_debito,
            tbl_fechamento_periodo.forma_pagamento,
            tbl_fechamento_periodo.id_relatorio_viagem AS id_acerto,
            NULL::integer AS odometro,
            NULL::numeric(9,1) AS horimetro,
            NULL::integer AS lancar_conta,
            NULL::integer AS id_conta_pagar,
            NULL::date AS data_vencimento,
            NULL::date AS data_emissao
           FROM tbl_fechamento_periodo
  ORDER BY 1
        )
 SELECT agrupamento.origem,
    agrupamento.id_romaneio_despesa,
    agrupamento.id_romaneio,
    agrupamento.id_fornecedor,
    agrupamento.id_despesa,
    agrupamento.cod_empresa,
    agrupamento.cod_filial,
    agrupamento.id_unidade,
    agrupamento.quantidade,
    agrupamento.vl_unitario,
    agrupamento.valor_despesa,
    agrupamento.codigo_centro_custo,
    agrupamento.observacao,
    agrupamento.data_referencia,
    agrupamento.descricao,
    agrupamento.tipo_operacao,
    agrupamento.credito_debito,
    agrupamento.forma_pagamento,
    agrupamento.id_acerto,
    agrupamento.odometro,
    agrupamento.horimetro,
    agrupamento.lancar_conta,
    agrupamento.id_conta_pagar,
    agrupamento.data_vencimento,
    agrupamento.data_emissao,
    scr_despesas_viagem.tipo_controle
   FROM agrupamento
     LEFT JOIN scr_despesas_viagem ON agrupamento.id_despesa = scr_despesas_viagem.id_despesa
  WHERE
        CASE
            WHEN agrupamento.origem = 3 AND agrupamento.valor_despesa = 0::numeric THEN false
            ELSE true
        END
  ORDER BY agrupamento.origem;

ALTER TABLE public.v_scr_romaneio_despesas
  OWNER TO softlog_saocarlos2;
