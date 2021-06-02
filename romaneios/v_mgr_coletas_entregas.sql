-- View: public.v_mgr_coletas_entregas

-- DROP VIEW public.v_mgr_coletas_entregas;

CREATE OR REPLACE VIEW public.v_mgr_coletas_entregas AS 
 SELECT scr_romaneios.id_romaneio,
    scr_romaneios.data_romaneio,
    scr_romaneios.cod_empresa,
    scr_romaneios.cod_filial,
    scr_romaneios.tipo_romaneio,
    scr_romaneios.numero_romaneio,
    scr_relatorio_viagem.numero_relatorio,
    scr_romaneios.tipo_frota AS tipo_frota_codigo,
        CASE
            WHEN scr_romaneios.tipo_frota = 1 THEN 'Propria'::text
            WHEN scr_romaneios.tipo_frota = 2 THEN 'Agregado'::text
            ELSE 'Terceiro'::text
        END::character(10) AS tipo_frota,
    fornecedores.nome_razao AS motorista,
    fornecedores.cnpj_cpf AS motorista_cpf,
    scr_romaneios.placa_veiculo,
    scr_romaneios.placa_reboque,
    scr_romaneios.placa_reboque2,
    scr_romaneios.id_origem,
    origem.nome_cidade AS cidade_origem,
    origem.sigla_cidade AS sigla_origem,
    origem.uf AS uf_origem,
    scr_romaneios.data_saida,
    scr_romaneios.id_destino,
    destino.nome_cidade AS cidade_destino,
    destino.sigla_cidade AS sigla_destino,
    destino.uf AS uf_destino,
    scr_romaneios.data_chegada,
    scr_romaneios.cancelado,
    scr_romaneios.data_cancelamento,
    scr_romaneios.motivo_cancelamento,
        CASE
            WHEN scr_romaneios.cancelado = 1 THEN 'Cancelado'::text
            WHEN scr_romaneios.emitido = 0 THEN 'Aguardando Emissao'::text
            WHEN scr_romaneios.problema_integracao = 1 THEN 'Pendênc.Integração'::text
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 0 THEN 'Emitido'::text            
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 1 AND scr_romaneios.fechamento = 0 THEN 'Baixado'::text
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 1 AND scr_romaneios.fechamento = 1 AND COALESCE(scr_romaneios.id_acerto,0) = 0 THEN 'Fechado'::text
            WHEN COALESCE(scr_romaneios.id_acerto,0) > 0 THEN 'Acertado'::text
            ELSE 'Desconhecido'::text
        END::character(18) AS status,
        CASE
            WHEN scr_romaneios.cancelado = 1 THEN 0            
            WHEN scr_romaneios.emitido = 0 THEN 1
            WHEN scr_romaneios.problema_integracao = 1 THEN 7
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 0 THEN 2
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 1 AND scr_romaneios.fechamento = 0 THEN 3
            WHEN scr_romaneios.emitido = 1 AND scr_romaneios.baixa = 1 AND scr_romaneios.fechamento = 1 AND COALESCE(scr_romaneios.id_acerto, 0) = 0 THEN 4
            WHEN COALESCE(scr_romaneios.id_acerto,0) > 0 THEN 5            
            ELSE 6
        END AS status_codigo,
    count(scr_conhecimento.id_conhecimento)::numeric AS qtentregas,
    string_agg(
        CASE
            WHEN scr_conhecimento.tipo_documento = 1 THEN 'CT.:  '::text || scr_conhecimento.numero_ctrc_filial::text
            WHEN scr_conhecimento.tipo_documento = 2 THEN 'MIN.: '::text || scr_conhecimento.numero_ctrc_filial::text
            ELSE NULL::text
        END::character(19)::text, ' / '::text)::character(200) AS lst_entregas,
    count(col_coletas.id_coleta)::numeric AS qtcoletas,
    string_agg(col_coletas.id_coleta_filial::text, ' / '::text)::character(200) AS lst_coletas,
    scr_romaneios.vl_servico_for,
    scr_romaneios.vl_adiantamentos_for,
    scr_romaneios.vl_acrescimos_for,
    scr_romaneios.vl_pagar_for,
    scr_romaneios.vl_despesas_diretas,
    scr_romaneios.total_peso,
    scr_romaneios.total_volume_cubado,
    scr_romaneios.total_peso_cubado,
    scr_romaneios.total_volumes,
    scr_romaneios.total_frete,
    scr_romaneios.total_nf,
    scr_romaneios.id_acerto,
    scr_romaneios.baixa,
    scr_romaneios.fechamento,
    scr_romaneios.redespacho,
        CASE
            WHEN scr_romaneios.redespacho = 0 THEN 'Coleta/Entrega'::text
            ELSE 'Redespacho'::text
        END::character(15) AS tipo,
    scr_romaneios.id_transportador_redespacho,
    redespachador.cnpj_cpf AS redespachador_cnpj,
    redespachador.nome_razao AS redespachador,
        CASE
            WHEN scr_romaneios.tipo_modal = 1 THEN 'Rodoviario'::text
            ELSE 'Aereo'::text
        END::character(10) AS modal,
    scr_romaneios.tipo_destino,
    scr_romaneios.cnpj_cpf_proprietario,
    ( SELECT string_agg(sra.numero_averbacao::text, ', '::text) AS string_agg
           FROM scr_romaneio_averbacao sra
          WHERE sra.id_romaneio = scr_romaneios.id_romaneio) AS numero_averbacao,
     scr_romaneios.problema_integracao,
     scr_romaneios.msg_integracao
   FROM scr_romaneios
     LEFT JOIN scr_relatorio_viagem ON scr_romaneios.id_acerto = scr_relatorio_viagem.id_relatorio_viagem
     LEFT JOIN fornecedores ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
     LEFT JOIN cidades origem ON scr_romaneios.id_origem = origem.id_cidade
     LEFT JOIN cidades destino ON scr_romaneios.id_destino = destino.id_cidade
     LEFT JOIN scr_viagens_docs ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio
     LEFT JOIN scr_romaneio_fechamentos ON scr_romaneios.id_romaneio = scr_romaneio_fechamentos.id_romaneio
     LEFT JOIN scr_conhecimento_entrega ON scr_conhecimento_entrega.id_romaneios = scr_romaneios.id_romaneio
     LEFT JOIN scr_conhecimento ON scr_conhecimento_entrega.id_conhecimento = scr_conhecimento.id_conhecimento
     LEFT JOIN col_coletas_romaneio ON col_coletas_romaneio.id_romaneios = scr_romaneios.id_romaneio
     LEFT JOIN col_coletas ON col_coletas.id_coleta = col_coletas_romaneio.id_coleta
     LEFT JOIN fornecedores redespachador ON redespachador.id_fornecedor = scr_romaneios.id_transportador_redespacho
  WHERE scr_romaneios.tipo_romaneio = 1 AND scr_romaneios.numero_romaneio IS NOT NULL
  GROUP BY scr_romaneios.id_romaneio, scr_relatorio_viagem.id_relatorio_viagem, fornecedores.id_fornecedor, origem.id_cidade, destino.id_cidade, redespachador.id_fornecedor;

