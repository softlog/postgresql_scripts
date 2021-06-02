-- View: public.v_scr_faturamento_email

-- DROP VIEW public.v_scr_faturamento_email;

CREATE OR REPLACE VIEW public.v_scr_faturamento_email AS 
 WITH cur_ativ AS (
         SELECT DISTINCT ON (scr_faturamento_log_atividades.id_faturamento) scr_faturamento_log_atividades.id_faturamento,
                CASE
                    WHEN scr_faturamento_log_atividades.atividade_executada::text ~~ '%@%'::text THEN 1
                    ELSE 0
                END AS ativ
           FROM scr_faturamento_log_atividades
          ORDER BY scr_faturamento_log_atividades.id_faturamento, scr_faturamento_log_atividades.id_faturamento_log_atividade DESC
        ), t AS (
         SELECT f.codigo_empresa AS empresa_emitente,
            f.codigo_filial AS filial_emitente,
            f.numero_fatura,
            f.numero_boleto,
            f.data_vencimento,
            f.atraso,
            f.data_pagamento,
            f.id_cobrador,
            f.id_vendedor,
            f.fatura_sacado_id,
            f.fatura_nome,
            f.valor_fatura,
            f.imposto,
            f.qtde_ctrc + f.qtde_minutas AS qtde_docs,
            f.perc_desconto,
            f.desconto,
            f.fatura_banco,
            f.fatura_agencia,
            f.fatura_conta_corrente,
            f.fatura_cnpj,
            f.fatura_cidade,
            f.data_fechamento,
            f.data_processamento,
            f.valor_pago,
            f.juros,
            f.multa,
            f.abatimento,
            f.tarifa,
            f.valor_inss,
            f.valor_total,
            f.data_cancelamento,
            f.motivo_cancelamento,
            f.id_faturamento,
            f.status,
            f.id_remessa,
            f.valor_recebido,
            NULL::numeric(12,2) AS valor_corrigido,
            caixas.ultimo_encerramento,
            f.id_caixa,
            f.tabela_credito_sistema,
            f.numero_lancamento,
            con.id_string_conexao,
            NULL::bpchar[] AS array_conhecimento,
            ''::text AS lst_nf,
            f.tipo_fatura
           FROM scr_faturamento f
             LEFT JOIN scf_caixas caixas ON caixas.id_caixa = f.id_caixa
             RIGHT JOIN msg_subscricao m ON m.codigo_cliente = f.fatura_sacado_id
             LEFT JOIN string_conexoes con ON con.banco_dados::name = current_database()
          WHERE m.id_notificacao IN (100,102) AND m.ativo = 1 AND m.email IS NOT NULL
          GROUP BY f.id_faturamento, caixas.id_caixa, con.id_string_conexao
          ORDER BY f.numero_fatura
        )
 SELECT DISTINCT t.empresa_emitente,
    t.filial_emitente,
    t.numero_fatura,
    t.numero_boleto,
    COALESCE(fa.data_vencimento, t.data_vencimento) AS data_vencimento,
    t.atraso,
    t.data_pagamento,
    t.id_cobrador,
    t.id_vendedor,
    t.fatura_sacado_id,
    t.fatura_nome,
    t.valor_fatura,
    t.imposto,
    t.qtde_docs,
    t.perc_desconto,
    t.desconto,
    t.fatura_banco,
    t.fatura_agencia,
    t.fatura_conta_corrente,
    t.fatura_cnpj,
    t.fatura_cidade,
    t.data_fechamento,
    t.data_processamento,
    t.valor_pago,
    t.juros,
    t.multa,
    t.abatimento,
    t.tarifa,
    t.valor_inss,
    t.valor_total,
    t.data_cancelamento,
    t.motivo_cancelamento,
    t.id_faturamento,
    t.status,
    t.id_remessa,
    t.valor_recebido,
    t.valor_corrigido,
    t.ultimo_encerramento,
    t.id_caixa,
    t.tabela_credito_sistema,
    t.numero_lancamento,
    t.id_string_conexao,
    t.array_conhecimento,
    t.lst_nf,
    ''::text AS lst_conhecimentos,
    fa.posicao_aviso,
    fa.ultimo_aviso,
    fa.avisar,
    fa.bloquear,
    fa.bloqueado,
    fa.fez_acordo,
    fa.bloqueia_servico,
    fa.dias_atraso,
    t.tipo_fatura,
    cur_ativ.ativ
   FROM t
     LEFT JOIN v_scr_faturas_atrasadas fa ON fa.id_faturamento = t.id_faturamento
     LEFT JOIN cur_ativ ON cur_ativ.id_faturamento = t.id_faturamento;

