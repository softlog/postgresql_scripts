--DROP FOREIGN TABLE v_bairros_cep_faixa CASCADE;
--ROLLBACK;
CREATE OR REPLACE VIEW public.v_bairros_cep_faixa AS 
 SELECT b.id_bairro AS id_bairro,
    b.uf,
    b.bairro,
    b.bai_no_abrev,
    f.fcb_nu_ordem AS id_faixa_bairro,
    f.fcb_rad_ini,
    f.fcb_suf_ini,
    f.fcb_rad_fim,
    f.fcb_suf_fim,
    b.id_cidade as loc_nu_sequencial,
    upper(fc.cidade::text) AS localidade,
    fc.cod_ibge,
    fc.cidade as loc_no,
    fc.cep,
    1::integer as loc_in_situacao,
    'M'::text as loc_in_tipo_localidade,
    fc.id_cidade as loc_nu_sequencial_sub,
    null::text as loc_rad1_ini,
    null::text as loc_suf1_ini,
    null::text as loc_rad1_fim,
    null::text as loc_suf1_fim,
    null::text as loc_rad2_ini,
    null::text as loc_suf2_ini,
    null::text as loc_rad2_fim,
    null::text as loc_suf2_fim,
    f.fcb_faixa
   FROM v_bairros_cep b
     LEFT JOIN log_faixa_bairro f ON b.id_bairro = f.bai_nu_sequencial
   LEFT JOIN qualocep_cidade fc
		ON fc.id_cidade = b.id_cidade
     LEFT JOIN qualocep_faixa_cidades i
	ON i.id_cidade = fc.id_cidade;


--SELECT * FROm v_bairros_cep_faixa 

CREATE OR REPLACE VIEW public.v_bairros_cep_em_regioes_cidades AS 
SELECT cep.id_bairro,
    cep.uf,
    cep.id_cidade AS id_cidade_cep,
    cep.bairro::character(250) AS bairro,
    cep.cod_ibge,
    c.nome_cidade,
    r.id_regiao,
    r.descricao AS regiao
FROM v_bairros_cep cep
     LEFT JOIN cidades c ON c.cod_ibge = cep.cod_ibge
     LEFT JOIN regiao_cidades rc ON rc.id_cidade = c.id_cidade
     LEFT JOIN regiao r ON rc.id_regiao = r.id_regiao     
WHERE r.tipo_regiao = 1
UNION 
SELECT cep.id_bairro,
    cep.uf,
    cep.id_cidade AS id_cidade_cep,
    cep.bairro::character(250) AS bairro,
    cep.cod_ibge,
    c.nome_cidade,
    r.id_regiao,
    r.descricao AS regiao
FROM v_bairros_cep cep
     LEFT JOIN cidades c ON c.cod_ibge = cep.cod_ibge     
     LEFT JOIN regiao r ON r.id_cidade_polo = c.id_cidade
WHERE r.tipo_regiao = 1;



CREATE OR REPLACE VIEW public.v_bairros_cep_em_regioes_cidades_faixa AS 
 SELECT t1.id_bairro,
    t1.uf,
    t1.nome_cidade,
    t1.id_cidade_cep,
    t1.cod_ibge,
    t1.bairro,
    t1.id_regiao,
    t1.regiao,    
    t2.fcb_rad_ini::integer AS cep_rad_ini,
    t2.fcb_suf_ini::integer AS cep_suf_ini,
    t2.fcb_rad_fim::integer AS cep_rad_fim,
    t2.fcb_suf_fim::integer AS cep_suf_fim
   FROM v_bairros_cep_em_regioes_cidades t1
     LEFT JOIN v_bairros_cep_faixa t2 ON t1.id_bairro = t2.id_bairro;

------------------------------------------------------------------------------------------------------------------------------------
---- VISOES DEPENDENTES
------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.v_cep_mapeamento_entregas_bairro AS 
 WITH t AS (
         SELECT cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            "left"(cli.cep::text, 5)::integer AS rad_cep,
            "right"(cli.cep::text, 3)::integer AS suf_cep,
            c.id_cidade,
            c.nome_cidade,
            c.cod_ibge
           FROM cliente cli
             LEFT JOIN cidades c ON c.id_cidade::numeric = cli.id_cidade
        )
 SELECT t.cnpj_cpf,
    t.nome_cliente,
    t.cep,
    t.rad_cep,
    t.suf_cep,
    t.id_cidade,
    t.nome_cidade,
    t.cod_ibge,
    f.id_bairro,
    f.bairro,
    f.id_regiao
   FROM t
     LEFT JOIN v_bairros_cep_em_regioes_cidades_faixa f ON t.cod_ibge = f.cod_ibge
  WHERE t.rad_cep >= f.cep_rad_ini AND t.suf_cep >= f.cep_suf_ini AND t.rad_cep <= f.cep_rad_fim AND t.suf_cep <= f.cep_suf_fim
  ORDER BY f.bairro;


CREATE OR REPLACE VIEW public.v_cliente_bairros_cep AS 
 WITH t AS (
         SELECT cli.codigo_cliente,
            cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            0 AS rad_cep,
            0 AS suf_cep,
            c.id_cidade,
            c.nome_cidade,
            c.cod_ibge
           FROM cliente cli
             LEFT JOIN cidades c ON c.id_cidade = cli.id_cidade::integer
        )
 SELECT t.codigo_cliente,
    t.cnpj_cpf,
    t.nome_cliente,
    t.cep,
    t.rad_cep,
    t.suf_cep,
    t.id_cidade,
    t.nome_cidade,
    t.cod_ibge,
    f.id_bairro,
    f.bairro
   FROM t
     LEFT JOIN v_bairros_cep_faixa f ON t.cod_ibge = f.cod_ibge
  WHERE
        CASE
            WHEN t.rad_cep = f.fcb_rad_ini::integer THEN t.suf_cep >= f.fcb_suf_ini::integer
            ELSE t.rad_cep > f.fcb_rad_ini::integer
        END AND
        CASE
            WHEN t.rad_cep = f.fcb_rad_fim::integer THEN t.suf_cep <= f.fcb_suf_fim::integer
            ELSE t.rad_cep < f.fcb_rad_fim::integer
        END
  ORDER BY f.bairro;

  
CREATE OR REPLACE VIEW public.v_regiao_setores AS 
 WITH t AS (
         SELECT rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            rc.distancia_cidade_polo,
            rc.tempo_dias,
            rc.tempo_horas,
            rc.cidade_satelite,
            rc.interior_redespacho,
            rc.capital,
            rc.percurso_fluvial,
            r_1.hora_inicio_viagem
           FROM regiao_cidades rc
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rc.id_regiao
          WHERE r_1.tipo_regiao = 2
        UNION
         SELECT NULL::integer AS id_cidade,
            rb.id_bairro,
            rb.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            NULL::integer AS distancia_cidade_polo,
            NULL::integer AS tempo_dias,
            NULL::integer AS tempo_horas,
            NULL::integer AS cidade_satelite,
            NULL::integer AS interior_redespacho,
            NULL::integer AS capital,
            NULL::integer AS percurso_fluvial,
            r_1.hora_inicio_viagem
           FROM regiao_bairros rb
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rb.id_regiao
        )
 SELECT DISTINCT t.id_cidade,
    c.nome_cidade AS cidade,
    t.id_bairro,
    bc.bairro,
    t.id_setor,
    t.setor,
    t.tipo_composicao,
    t.id_cidade_polo,
    t.id_regiao,
    r.descricao AS regiao,
    r.id_cidade_polo AS id_cidade_polo_regiao,
    t.distancia_cidade_polo,
    t.tempo_dias,
    t.tempo_horas,
    t.cidade_satelite,
    t.interior_redespacho,
    t.capital,
    t.percurso_fluvial,
    t.hora_inicio_viagem
   FROM t
     LEFT JOIN regiao r ON r.id_regiao = t.id_regiao
     LEFT JOIN v_bairros_cep bc ON bc.id_bairro = t.id_bairro
     LEFT JOIN cidades c ON c.id_cidade = t.id_cidade;



CREATE OR REPLACE VIEW public.v_notas_para_entrega AS 
 WITH notas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.destinatario_id,
            c.nome_cliente AS destinatario_nome,
            c.cep AS destinatario_cep,
            c.endereco AS destinatario_endereco,
            c.numero AS destinatario_numero,
            c.bairro AS destinatario_bairro,
            cd.id_cidade AS id_destino,
            cd.nome_cidade AS destinatario_cidade,
            cd.uf AS destinatario_uf,
            cep.id_bairro,
            cep.bairro
           FROM scr_notas_fiscais_imp nf
             LEFT JOIN cliente c ON c.codigo_cliente = nf.destinatario_id
             LEFT JOIN cidades cd ON c.id_cidade::integer = cd.id_cidade
             LEFT JOIN v_cliente_bairros_cep cep ON cep.codigo_cliente = nf.destinatario_id
          WHERE nf.id_romaneio IS NULL
        ), rotas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            s.id_cidade,
            NULL::integer AS id_bairro,
            s.tipo_composicao,
            s.id_setor,
            s.id_cidade_polo,
            s.id_regiao,
            s.id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_setores s ON s.id_cidade = nf.id_destino
          WHERE s.id_setor IS NOT NULL
        UNION
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.id_destino AS id_cidade,
            s.id_bairro,
            s.tipo_composicao,
            s.id_setor,
            s.id_cidade_polo,
            s.id_regiao,
            s.id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_setores s ON s.id_bairro = nf.id_bairro
          WHERE s.id_setor IS NOT NULL
        )
 SELECT rotas.id_nota_fiscal_imp,
    rotas.numero_nota_fiscal,
    rotas.serie_nota_fiscal,
    rotas.id_cidade,
    rotas.id_bairro,
    rotas.tipo_composicao,
    rotas.id_setor,
    rotas.id_cidade_polo,
    rotas.id_regiao,
    rotas.id_cidade_polo_regiao
   FROM rotas;



CREATE OR REPLACE VIEW public.v_cidades_para_entrega AS 
 SELECT regiao.id_cidade_polo AS id_cidade,
    cidades.nome_cidade,
    cidades.sigla_cidade,
    cidades.uf,
    regiao.id_regiao
   FROM regiao
     LEFT JOIN cidades ON cidades.id_cidade = regiao.id_cidade_polo
  WHERE regiao.tipo_regiao = 1 AND (EXISTS ( SELECT 1
           FROM v_notas_para_entrega
          WHERE v_notas_para_entrega.id_cidade_polo_regiao = regiao.id_cidade_polo));



CREATE OR REPLACE VIEW public.v_setor_para_entrega AS 
 SELECT regiao.id_regiao,
    regiao.descricao,
    regiao.id_cidade_polo,
    regiao.id_regiao_agrupadora,
    regiao.tipo_composicao
   FROM regiao
     RIGHT JOIN v_cidades_para_entrega ON v_cidades_para_entrega.id_regiao = regiao.id_regiao_agrupadora
  WHERE regiao.tipo_regiao = 2;


  
CREATE OR REPLACE VIEW public.v_regiao_setores2 AS 
 WITH t AS (
         SELECT rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao
           FROM regiao_cidades rc
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rc.id_regiao
          WHERE r_1.tipo_regiao = 2
        UNION
         SELECT NULL::integer AS id_cidade,
            rb.id_bairro,
            rb.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao
           FROM regiao_bairros rb
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rb.id_regiao
          WHERE 1 = 2
        )
 SELECT DISTINCT t.id_cidade,
    c.nome_cidade AS cidade,
    t.id_bairro,
    bc.bairro,
    t.id_setor,
    t.setor,
    t.tipo_composicao,
    t.id_cidade_polo,
    t.id_regiao,
    r.descricao AS regiao,
    r.id_cidade_polo AS id_cidade_polo_regiao
   FROM t
     LEFT JOIN regiao r ON r.id_regiao = t.id_regiao
     LEFT JOIN v_bairros_cep bc ON bc.id_bairro = t.id_bairro
     LEFT JOIN cidades c ON c.id_cidade = t.id_cidade;


 
CREATE OR REPLACE VIEW public.v_notas_para_transferencia AS 
 WITH notas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.destinatario_id,
            c.nome_cliente AS destinatario_nome,
            c.cep AS destinatario_cep,
            c.endereco AS destinatario_endereco,
            c.numero AS destinatario_numero,
            c.bairro AS destinatario_bairro,
            cd.id_cidade AS id_destino,
            cd.nome_cidade AS destinatario_cidade,
            cd.uf AS destinatario_uf,
            cep.id_bairro,
            cep.bairro
           FROM scr_notas_fiscais_imp nf
             LEFT JOIN cliente c ON c.codigo_cliente = nf.destinatario_id
             LEFT JOIN cidades cd ON c.id_cidade::integer = cd.id_cidade
             LEFT JOIN v_cliente_bairros_cep cep ON cep.codigo_cliente = nf.destinatario_id
          WHERE nf.id_romaneio IS NULL AND nf.id_ocorrencia = 0 AND nf.data_expedicao >= ('now'::text::date - 3)
        ), rotas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.tipo_composicao,
            rc.id_setor,
            rc.id_cidade_polo,
            rc.id_regiao,
            r.id_cidade_polo AS id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_cidades rc ON rc.id_cidade = nf.id_destino
             LEFT JOIN regiao r ON r.id_regiao = rc.id_regiao
        )
 SELECT rotas.id_nota_fiscal_imp,
    rotas.numero_nota_fiscal,
    rotas.serie_nota_fiscal,
    rotas.id_cidade,
    rotas.id_bairro,
    rotas.tipo_composicao,
    rotas.id_setor,
    rotas.id_cidade_polo,
    rotas.id_regiao,
    rotas.id_cidade_polo_regiao
   FROM rotas;


CREATE OR REPLACE VIEW public.v_cliente_bairros_cep_nao_encontrado AS 
 WITH t AS (
         SELECT cli.codigo_cliente,
            cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            "left"(cli.cep::text, 5)::integer AS rad_cep,
            "right"(cli.cep::text, 3)::integer AS suf_cep,
            c.id_cidade,
            c.nome_cidade,
            c.uf,
            c.cod_ibge
           FROM cliente cli
             LEFT JOIN cidades c ON c.id_cidade = cli.id_cidade::integer
        ), t2 AS (
         SELECT v_bairros_cep.cod_ibge
           FROM v_bairros_cep
          WHERE v_bairros_cep.cod_ibge IS NOT NULL
          GROUP BY v_bairros_cep.cod_ibge
        ), t3 AS (
         SELECT t.codigo_cliente,
            t.cnpj_cpf,
            t.nome_cliente,
            t.cep,
            t.rad_cep,
            t.suf_cep,
            t.id_cidade,
            t.nome_cidade,
            t.uf,
            t.cod_ibge
           FROM t
             LEFT JOIN t2 ON t2.cod_ibge = t.cod_ibge
          WHERE t2.cod_ibge IS NOT NULL
        )
 SELECT t3.codigo_cliente,
    t3.cnpj_cpf,
    t3.nome_cliente,
    t3.cep,
    t3.rad_cep,
    t3.suf_cep,
    t3.id_cidade,
    t3.nome_cidade,
    t3.uf,
    t3.cod_ibge
   FROM t3
  WHERE NOT (EXISTS ( SELECT 1
           FROM v_cliente_bairros_cep cep
          WHERE cep.codigo_cliente = t3.codigo_cliente));

-- View: public.v_mgr_notas_fiscais

-- DROP VIEW public.v_mgr_notas_fiscais;

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
            WHEN r.regime_especial_mg = 1 AND co.uf = 'SP'::bpchar AND cd.uf = 'SP'::bpchar AND nf.limite_minimo_re = 1 THEN 1
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
    CASE WHEN current_database() = 'softlog_medilog' THEN NULL ELSE v_rs.id_setor END id_setor,
    CASE WHEN current_database() = 'softlog_medilog' THEN NULL ELSE v_rs.setor END::character varying(35) setor,
    CASE WHEN current_database() = 'softlog_medilog' THEN NULL ELSE v_rs.id_regiao END id_regiao,
    CASE WHEN current_database() = 'softlog_medilog' THEN NULL ELSE v_rs.regiao END::character varying(35) regiao,    
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
    nf.qtd_ajudantes
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
     LEFT JOIN v_regiao_setores v_rs ON current_database() NOT IN ('softlog_medilog','softlog_transribeiro') AND v_rs.id_cidade = d.id_cidade::integer;

--ALTER VIEW v_mgr_notas_fiscais OWNER TO softlog_transribeiro
         