-- View: public.v_mgr_scr_relatorio_viagem

-- DROP VIEW public.v_mgr_scr_relatorio_viagem;

CREATE OR REPLACE VIEW public.v_mgr_scr_relatorio_viagem AS 
 SELECT scr_relatorio_viagem.id_relatorio_viagem,
    scr_relatorio_viagem.categoria_acerto AS categoria_acerto_cod,
        CASE
            WHEN scr_relatorio_viagem.categoria_acerto = 1 THEN 'Agregado/Terceiro'::text
            WHEN scr_relatorio_viagem.categoria_acerto = 2 THEN 'Redespacho'::text
            WHEN scr_relatorio_viagem.categoria_acerto = 3 THEN 'Motorista/Próprio'::text
            ELSE NULL::text
        END::character(20) AS categoria_acerto,
    scr_relatorio_viagem.filial,
    scr_relatorio_viagem.empresa,
    scr_relatorio_viagem.id_fornecedor,
        CASE
            WHEN scr_relatorio_viagem.categoria_acerto <> 2 THEN fornecedores.nome_razao
            ELSE NULL::character varying
        END::character(50) AS motorista,
        CASE
            WHEN scr_relatorio_viagem.categoria_acerto <> 2 THEN fornecedores.cnpj_cpf
            ELSE NULL::character varying
        END::character(50) AS motorista_cpf,
        CASE
            WHEN scr_relatorio_viagem.categoria_acerto = 2 THEN fornecedores.nome_razao
            ELSE NULL::character varying
        END::character(50) AS redespachador,
        CASE
            WHEN scr_relatorio_viagem.categoria_acerto = 2 THEN fornecedores.cnpj_cpf
            ELSE NULL::character varying
        END::character(50) AS redespachador_cnpj,
    scr_relatorio_viagem.numero_relatorio,
    scr_relatorio_viagem.fechamento_inicial,
    scr_relatorio_viagem.fechamento_final,
    scr_relatorio_viagem.data_relatorio,
    scr_relatorio_viagem.historico,
    scr_relatorio_viagem.qtde_diarias,
    scr_relatorio_viagem.qtde_dias_parados,
    scr_relatorio_viagem.qtde_horas_extras,
    scr_relatorio_viagem.numero_tabela_motorista,
    scr_relatorio_viagem.total_frete,
    scr_relatorio_viagem.total_despesas_diretas,
    scr_relatorio_viagem.total_despesas_indiretas,
    scr_relatorio_viagem.vl_fretes_recebidos,
    scr_relatorio_viagem.vl_servico_for,
    scr_relatorio_viagem.vl_adiantamentos_for,
    scr_relatorio_viagem.vl_acrescimos_for,
    scr_relatorio_viagem.vl_pagar_for,
    scr_relatorio_viagem.codigo_centro_custo,
    scr_relatorio_viagem.observacao,
    scr_relatorio_viagem.tipo_parcela,
    scr_relatorio_viagem.parcelas,
    scr_relatorio_viagem.periodicidade,
    scr_relatorio_viagem.lancamento_conta_pagar,
    scr_relatorio_viagem.total_diarias_viagens,    
    string_agg(
        CASE
            WHEN scr_romaneios.tipo_romaneio = 1 THEN scr_romaneios.numero_romaneio
            ELSE NULL::bpchar
        END::text, ' / '::text) AS lst_col_entregas,
    string_agg(
        CASE
            WHEN scr_romaneios.tipo_romaneio = 2 THEN scr_romaneios.numero_romaneio
            ELSE NULL::bpchar
        END::text, ' / '::text) AS lst_viagens,
    string_agg(scr_romaneios.placa_veiculo::text, ' / '::text) AS lst_veiculos,
    scr_relatorio_viagem.placa_veiculo,
   scr_relatorio_viagem.cancelado,
   scr_relatorio_viagem.motivo_cancelamento
   FROM scr_relatorio_viagem
     LEFT JOIN fornecedores ON scr_relatorio_viagem.id_fornecedor = fornecedores.id_fornecedor
     LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
  GROUP BY scr_relatorio_viagem.id_relatorio_viagem, fornecedores.id_fornecedor;

