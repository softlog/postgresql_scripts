-- View: public.v_mgr_notas_fiscais
-- ALTER VIEW public.v_mgr_notas_fiscais OWNER TO softlog_lfc

BEGIN;

SELECT * FROM fd_drop_visoes_dependentes('v_mgr_notas_fiscais');

DROP VIEW v_mgr_notas_fiscais;

--Código que altera ou recria a visão


CREATE OR REPLACE VIEW public.v_mgr_notas_fiscais AS 
 SELECT nf.id_nota_fiscal_imp,
    nf.selecionado,
    (((nf.remetente_id::text || '_'::text) || nf.destinatario_id::text) || '_'::text) || nf.data_emissao::text AS grupo_rem_dest_data,
    (nf.remetente_id::text || '_'::text) || nf.destinatario_id::text AS grupo_rem_dest,
    (nf.remetente_id::text || '_'::text) || nf.numero_nota_fiscal::text AS grupo_rem_nota,
    nf.id_cotacao_frete,
    nf.id_conhecimento,
    rom.numero_romaneio,
    rom.id_romaneio,
    c.numero_ctrc_filial,
        CASE
            WHEN nf.tipo_operacao = 1 THEN c.data_digitacao
            ELSE c.data_emissao
        END AS data_emissao_conhecimento,
    nf.tipo_operacao,
    nf.tipo_documento,
    nf.modal,
    nf.tipo_ctrc_cte,
    nf.tipo_transporte,
    nf.natureza_carga,
    nf.status,
    nf.id_agrupador,
    nf.nao_agrupa,
    COALESCE(p.empresa_responsavel, nf.empresa_emitente) AS empresa_emitente,
    COALESCE(p.filial_responsavel, nf.filial_emitente) AS filial_emitente,
    COALESCE(filial2.cnpj, filial.cnpj) AS filial_cnpj,
    COALESCE(filial2.id_cidade, filial.id_cidade) AS filial_id_cidade,
    COALESCE(filial2_cidade.nome_cidade, filial_cidade.nome_cidade) AS filial_cidade,
    COALESCE(filial2_cidade.uf, filial_cidade.uf) AS filial_uf,
    nf.frete_cif_fob,
    nf.remetente_id,
    (((((initcap(r.nome_cliente::text) || ' ('::text) || cnpj_cpf(r.cnpj_cpf::text)) || '), '::text) || cr.nome_cidade::text) || '-'::text) || cr.uf::text AS remetente_descritivo,
    r.cnpj_cpf AS remetente_cnpj,
    r.cnpj_cpf_responsavel AS remetente_cnpj_responsavel,
    r.nome_cliente AS remetente_nome,
        CASE
            WHEN r.frete::text = 'A PAGAR'::text THEN 2
            ELSE 1
        END AS remetente_avista,
    re.logradouro AS remetente_endereco,
    re.numero AS remetente_numero,
    re.bairro AS remetente_bairro,
    re.id_cidade AS remetente_id_cidade,
    cr.nome_cidade AS remetente_cidade,
    cr.uf AS remetente_uf,
    re.cep AS remetente_cep,
    r.inscricao_estadual AS remetente_ie,
    re.ddd AS remetente_ddd,
    re.telefone AS remetente_telefone,
    nf.calculado_de_id_cidade,
    co.nome_cidade AS cidade_origem_calculo,
    co.uf AS uf_origem_calculo,
    nf.destinatario_id,
    (((((initcap(d.nome_cliente::text) || ' ('::text) || cnpj_cpf(d.cnpj_cpf::text)) || '), '::text) || cd.nome_cidade::text) || '-'::text) || cd.uf::text AS destinatario_descritivo,
    d.cnpj_cpf AS destinatario_cnpj,
    d.cnpj_cpf_responsavel AS destinatario_cnpj_responsavel,
    d.nome_cliente AS destinatario_nome,
        CASE
            WHEN d.frete::text = 'A PAGAR'::text THEN 2
            ELSE 1
        END AS destinatario_avista,
    de.logradouro AS destinatario_endereco,
    de.numero AS destinatario_numero,
    de.bairro AS destinatario_bairro,
    de.id_cidade AS destinatario_id_cidade,
    cd.nome_cidade AS destinatario_cidade,
    cd.uf AS destinatario_uf,
    de.cep AS destinatario_cep,
    d.inscricao_estadual AS destinatario_ie,
    de.ddd AS destinatario_ddd,
    de.telefone AS destinatario_telefone,
    nf.calculado_ate_id_cidade,
    cde.nome_cidade AS cidade_destino_calculo,
    cde.uf AS uf_destino_calculo,
    cde.id_agente_redespacho_padrao,
    nf.consignatario_id,
    p.empresa_responsavel,
    p.cnpj_cpf AS pagador_cnpj,
    p.nome_cliente AS pagador_nome,
    pe.logradouro AS pagador_endereco,
    pe.numero AS pagador_numero,
    pe.bairro AS pagador_bairro,
    pe.id_cidade AS pagador_id_cidade,
    cp.nome_cidade AS pagador_cidade,
    cp.uf AS pagador_uf,
    pe.cep AS pagador_cep,
    p.inscricao_estadual AS pagador_ie,
    pe.ddd AS pagador_ddd,
    pe.telefone AS pagador_telefone,
        CASE
            WHEN p.substituto_tributario = 1 AND nf.frete_cif_fob = 1 THEN 1
            ELSE 0
        END AS st,
    p.classificacao_fiscal AS pagador_classificacao_fiscal,
    nf.classificacao_fiscal,
    nf.redespachador_id,
    t.nome_razao AS transportadora,
    t.cnpj_cpf AS transportadora_cnpj,
    t.endereco AS transportadora_endereco,
    t.numero AS transportadora_numero,
    t.bairro AS transportadora_bairro,
    t.id_cidade AS transportadora_id_cidade,
    ct.nome_cidade AS transportadora_cidade,
    ct.uf AS transportadora_uf,
    t.cep AS transportadora_cep,
    t.iest AS transportadora_ie,
    t.ddd AS transportadora_ddd,
    t.telefone1 AS transportadora_telefone,
    nf.avista,
    nf.tipo_imposto,
    nf.aliquota,
    nf.aliquota_st,
    nf.perc_base_calculo,
    nf.perc_base_calculo_st,
    nf.imposto_incluso,
    nf.placa_veiculo,
    nf.placa_carreta1,
    nf.placa_carreta2,
    nf.id_motorista,
    m.nome_razao AS motorista,
    COALESCE(nf.numero_tabela_frete, p.tabela_padrao) AS numero_tabela_frete,
    nf.cfop,
    nf.natureza_operacao,
    nf.data_emissao,
    nf.data_registro,
    nf.data_expedicao,
    nf.numero_nota_fiscal,
    nf.modelo_nf,
    nf.serie_nota_fiscal,
    nf.qtd_volumes,
    nf.usa_valor_presumido,
    nf.peso,
    nf.peso_presumido,
    nf.valor,
    nf.volume_cubico,
    nf.volume_presumido,
    nf.tipo_nota,
    nf.numero_pedido_nf,
    nf.valor_base_calculo,
    nf.valor_icms_nf,
    nf.valor_base_calculo_icms_st,
    nf.valor_icms_nf_st,
    nf.cfop_pred_nf,
    nf.valor_total_produtos,
    nf.pin,
    nf.chave_nfe,
    nf.chave_cte,
    nf.numero_doc_referenciado,
    nf.pendencia,
    nf.pendencia_valores,
    nf.pendencia_rota,
    nf.pendencia_responsavel,
    nf.pendencia_tabela,
    nf.pendencia_emissao,
    nf.pendencia_tributacao,
    nf.pendencia_viagem,
    nf.coleta_escolta,
    nf.coleta_expresso,
    nf.coleta_emergencia,
    nf.coleta_normal,
    nf.entrega_escolta,
    nf.entrega_expresso,
    nf.entrega_emergencia,
    nf.entrega_normal,
    nf.taxa_dce,
    nf.taxa_exclusivo,
    nf.coleta_dificuldade,
    nf.entrega_dificuldade,
    nf.entrega_exclusiva,
    nf.coleta_exclusiva,
    nf.id_usuario,
    nf.id_ocorrencia,
    nf.id_ocorrencia_obs,
    nf.canhoto,
    nf.data_ocorrencia,
    nf.nome_recebedor,
    nf.cpf_recebedor,
    0 AS pendencia_entrega,
    nf.regime_especial_mg,
    r.regime_especial_mg AS regime_especial_mg_cliente,
        CASE
            WHEN r.regime_especial_mg = 1 AND co.uf = cd.uf AND co.uf <> 'MG'::bpchar AND nf.limite_minimo_re = 1 THEN 1
            ELSE 0
        END AS regime_especial_sp,
    nf.total_entregas,
    nf.peso_agregado_nf,
    nf.volume_cubico_agregado_nf,
    nf.dt_agenda_coleta,
    nf.dt_agenda_entrega,
    nf.id_conhecimento_principal,
    nf.data_cte_re,
    nf.cod_interno_frete,
    p.utiliza_cod_interno_frete,
    nf.id_tipo_veiculo,
    ttv.tipo_veiculo,
    ttv.capacidade_peso_final,
        CASE
            WHEN current_database() = 'softlog_medilog'::name THEN NULL::integer
            ELSE v_rs.id_setor
        END AS id_setor,
        CASE
            WHEN current_database() = 'softlog_medilog'::name THEN NULL::character varying
            ELSE v_rs.setor
        END::character varying(35) AS setor,
        CASE
            WHEN current_database() = 'softlog_medilog'::name THEN NULL::integer
            ELSE v_rs.id_regiao
        END AS id_regiao,
        CASE
            WHEN current_database() = 'softlog_medilog'::name THEN NULL::character varying
            ELSE v_rs.regiao
        END::character varying(35) AS regiao,
    nf.vl_combinado,
    nf.vl_tonelada,
    nf.vl_percentual_nf,
    nf.peso_liquido,
    nf.especie_mercadoria,
    nf.codigo_vendedor,
    nf.data_previsao_entrega,
    nf.id_pre_fatura_entrega,
    pf.id_pre_fatura,
    nf.tipo_carga,
    pfe.vl_veiculo_ref,
    pfe.frete_peso_total,
    nf.vl_frete_peso,
    pfe.msg,
    pf.status AS status_pre_fatura,
    r.cnpj_cod_interno_frete,
    nf.consumidor_final,
    nf.difal_icms,
    nf.difal_icms_origem,
    nf.difal_icms_destino,
    nf.aliq_icms_interna,
    nf.aliquota_fcp,
    nf.valor_fcp,
    nf.calculo_difal,
    uf_dest.tomador_contribuinte,
    uf_dest.aliquota_fcp AS aliquota_fcp_uf,
    r.tipo_contribuinte AS tipo_contribuinte_r,
    d.tipo_contribuinte AS tipo_contribuinte_d,
    p.tipo_contribuinte,
    nf.aliq_icms_inter,
    nf.obs,
    pf.tipo_carga AS tipo_carga_pf,
    nf.inverter_rem_dest,
    nf.placa_coleta,
    nf.tabela_redespacho,
    nf.id_cidade_origem_redespacho,
    t.nome_cidade AS cidade_origem_redespacho,
    t.uf AS uf_origem_redespacho,
    t.numero_tabela_frete::character(13) AS tabela_redespacho_red,
    COALESCE(conf_re.regime_especial_combinado, 0) AS regime_especial_combinado,
    nf.valor_combinado_re,
    nf.valor_combinado_minuta_re,
    nf.codigo_nota,
    r.tipo_data,
    nf.vl_frete_nota,
    nf.data_emissao_hr,
    nf.id_minuta_re,
    nf.expedidor_cnpj,
    nf.peso_transportado,
    nf.flg_viagem_automatica,
    nf.odometro_inicial,
    nf.data_viagem,
    nf.total_frete_origem,
    nf.km_rodado,
    nf.qtd_ajudantes,
    (((nf.remetente_id::text || '_'::text) || nf.destinatario_id::text) || '_'::text) || nf.cod_interno_frete::text AS grupo_rem_dest_programacao,
    nf.obs_medidas,
    veic.tipo_frota,
    nf.desagrupa_destino_viagem
   FROM scr_notas_fiscais_imp nf
     LEFT JOIN cliente r ON r.codigo_cliente = nf.remetente_id
     LEFT JOIN v_regime_especial_combinado conf_re ON conf_re.codigo_cliente = r.codigo_cliente
     LEFT JOIN cliente_enderecos re ON re.codigo_cliente = r.codigo_cliente AND re.id_tipo_endereco = 3
     LEFT JOIN cidades cr ON cr.id_cidade = re.id_cidade::integer
     LEFT JOIN cliente d ON d.codigo_cliente = nf.destinatario_id
     LEFT JOIN cliente_enderecos de ON de.codigo_cliente = d.codigo_cliente AND de.id_tipo_endereco = 3
     LEFT JOIN cidades cd ON cd.id_cidade = de.id_cidade::integer
     LEFT JOIN cliente p ON p.codigo_cliente = nf.consignatario_id
     LEFT JOIN cliente_enderecos pe ON pe.codigo_cliente = p.codigo_cliente AND pe.id_tipo_endereco = 3
     LEFT JOIN cidades cp ON pe.id_cidade::integer = cp.id_cidade
     LEFT JOIN fornecedores m ON m.id_fornecedor = nf.id_motorista
     LEFT JOIN v_transportadoras t ON nf.redespachador_id = t.id_fornecedor
     LEFT JOIN cidades ct ON t.id_cidade::integer = ct.id_cidade
     LEFT JOIN scr_conhecimento c ON c.id_conhecimento = nf.id_conhecimento
     LEFT JOIN cidades co ON co.id_cidade = nf.calculado_de_id_cidade
     LEFT JOIN cidades cde ON cde.id_cidade = nf.calculado_ate_id_cidade
     LEFT JOIN estado uf_dest ON cde.uf = uf_dest.id_estado
     LEFT JOIN filial ON filial.codigo_empresa = nf.empresa_emitente AND filial.codigo_filial = nf.filial_emitente
     LEFT JOIN cidades filial_cidade ON filial_cidade.id_cidade = filial.id_cidade::integer
     LEFT JOIN filial filial2 ON filial2.codigo_empresa = p.empresa_responsavel AND filial2.codigo_filial = '001'::bpchar
     LEFT JOIN cidades filial2_cidade ON filial2_cidade.id_cidade = filial2.id_cidade::integer
     LEFT JOIN scr_romaneios rom ON rom.id_romaneio = nf.id_romaneio
     LEFT JOIN scr_ocorrencia_edi o ON o.codigo_edi = nf.id_ocorrencia
     LEFT JOIN scr_tabelas_tipo_veiculo ttv ON ttv.id_tipo_veiculo = nf.id_tipo_veiculo
     LEFT JOIN scr_pre_fatura_entregas pfe ON pfe.id_pre_fatura_entrega = nf.id_pre_fatura_entrega
     LEFT JOIN scr_pre_faturas pf ON pf.id_pre_fatura = pfe.id_pre_fatura
     LEFT JOIN veiculos veic ON veic.placa_veiculo = nf.placa_veiculo
     LEFT JOIN v_regiao_setores v_rs ON
        CASE
            WHEN v_rs.tipo_composicao = 1 THEN (current_database() <> ALL (ARRAY['softlog_medilog'::name, 'softlog_transribeiro'::name])) AND v_rs.id_cidade = d.id_cidade::integer
            WHEN v_rs.tipo_composicao = 2 THEN (current_database() <> ALL (ARRAY['softlog_medilog'::name, 'softlog_transribeiro'::name])) AND v_rs.id_bairro = d.id_bairro
            ELSE false
        END;
     
SELECT * FROM fd_restaura_visoes_dependentes('v_mgr_notas_fiscais');

COMMIT;     

--ALTER VIEW v_mgr_notas_fiscais OWNER TO softlog_transribeiro
