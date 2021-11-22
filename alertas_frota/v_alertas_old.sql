-- View: public.v_alertas

-- DROP VIEW public.v_alertas;

CREATE OR REPLACE VIEW public.v_alertas AS 
 WITH cur_man AS (
         SELECT DISTINCT ON (v.placa_veiculo, a.id_pmveic) v.placa_veiculo,
            v.id_veiculo,
            v.chk_km,
            a.id_pmveic,
                CASE
                    WHEN v.chk_km = 1 THEN f_prox_manutencao(a.id_pmveic, 'KM'::text)
                    ELSE f_prox_manutencao(a.id_pmveic, 'HR'::text)
                END AS obs_manut
           FROM frt_pmveic a
             LEFT JOIN ( SELECT veiculos.placa_veiculo,
                    veiculos.chk_km,
                    veiculos.id_veiculo
                   FROM veiculos
                  WHERE veiculos.ativo = 1 AND veiculos.bloqueado <> 1) v USING (placa_veiculo)
          WHERE a.pmveic_ativo = 1 AND v.placa_veiculo IS NOT NULL
        ), cur_posicao AS (
         SELECT DISTINCT v.id_veiculo,
            v.obs_manut,
            "position"(v.obs_manut, '$'::text) AS pos_kmhr
           FROM cur_man v
        ), tmp_alertas AS (
         SELECT fornecedores.mot_validade AS data_vencto,
            'DOC. MOTORISTA'::character(25) AS tipo_alerta,
            'CNH'::character(60) AS descr_doc,
            COALESCE(fornecedores.mot_registro, ''::character varying)::character(40) AS numero_doc,
            (('MOTORISTA: '::text || btrim(COALESCE(fornecedores.nome_razao, ''::character varying)::text)))::character(200) AS descr_alerta,
            fornecedores.id_fornecedor AS id_alerta,
            ''::character(50) AS obs_alerta,
            0 AS km_faltam,
            0 AS hr_faltam
           FROM fornecedores
          WHERE fornecedores.tipo_motorista = 1 AND fornecedores.mot_validade IS NOT NULL
        UNION
         SELECT fornecedores.mot_validade_averbacao AS data_vencto,
            'DOC. MOTORISTA'::character(25) AS tipo_alerta,
            'AVERBACAO'::character(60) AS descr_doc,
            COALESCE(fornecedores.mot_averbacao, ''::character varying)::character(40) AS numero_doc,
            (('MOTORISTA: '::text || btrim(fornecedores.nome_razao::text)))::character(200) AS descr_alerta,
            fornecedores.id_fornecedor AS id_alerta,
            ''::character(50) AS obs_alerta,
            0 AS km_faltam,
            0 AS hr_faltam
           FROM fornecedores
          WHERE fornecedores.tipo_motorista = 1 AND fornecedores.mot_validade_averbacao IS NOT NULL
        UNION
         SELECT fornecedores.mot_seg_validade AS data_vencto,
            'DOC. MOTORISTA'::character(25) AS tipo_alerta,
            'CARTAO SEGURADORA'::character(60) AS descr_doc,
            COALESCE(fornecedores.mot_seg_cartao, ''::character varying)::character(40) AS numero_doc,
            (('MOTORISTA: '::text || btrim(fornecedores.nome_razao::text)))::character(200) AS descr_alerta,
            fornecedores.id_fornecedor AS id_alerta,
            ''::character(50) AS obs_alerta,
            0 AS km_faltam,
            0 AS hr_faltam
           FROM fornecedores
          WHERE fornecedores.tipo_motorista = 1 AND fornecedores.mot_seg_validade IS NOT NULL
        UNION
         SELECT v.validade_rntrc AS data_vencto,
            'DOC. VEICULO'::character(25) AS tipo_alerta,
            'RNTRC'::character(60) AS descr_doc,
            COALESCE(v.rntrc, ''::bpchar)::character(40) AS numero_doc,
            (((((((('PLACA: '::text || btrim(v.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
            v.id_veiculo AS id_alerta,
            ''::character(50) AS obs_alerta,
            0 AS km_faltam,
            0 AS hr_faltam
           FROM v_veiculos v
          WHERE v.validade_rntrc IS NOT NULL AND v.ativo = 1 AND v.bloqueado <> 1
        UNION
         SELECT v_tb_categ_doc.doc_validade AS data_vencto,
            'DOC. VEICULO'::character(25) AS tipo_alerta,
            COALESCE(v_tb_categ_doc.doc_sigla, ''::bpchar)::character(60) AS descr_doc,
            COALESCE(v_tb_categ_doc.doc_numero, ''::bpchar)::character(40) AS numero_doc,
            (((((((('PLACA: '::text || btrim(v_tb_categ_doc.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
            v_tb_categ_doc.id_veiculo AS id_alerta,
            ''::character(50) AS obs_alerta,
            0 AS km_faltam,
            0 AS hr_faltam
           FROM v_tb_categ_doc
             LEFT JOIN v_veiculos v USING (id_veiculo)
          WHERE v_tb_categ_doc.doc_validade IS NOT NULL AND v.id_veiculo IS NOT NULL AND v.ativo = 1 AND v.bloqueado <> 1
        UNION
         SELECT "left"(m.obs_manut, 10)::date AS data_vencto,
            'MANUTENCAO'::character(25) AS tipo_alerta,
            COALESCE(p.descr_item, ''::bpchar)::character(60) AS descr_doc,
            (('FROTA '::text || btrim(COALESCE(v.numero_frota, ''::bpchar)::text)))::character(40) AS numero_doc,
            (((((((('PLACA: '::text || btrim(a.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
            a.id_veiculo AS id_alerta,
            "substring"(m.obs_manut, 12, s.pos_kmhr - 12)::character(50) AS obs_alerta,
                CASE
                    WHEN v.chk_km = 1 THEN "substring"(m.obs_manut, s.pos_kmhr + 1, 12)::integer
                    ELSE 0
                END AS km_faltam,
                CASE
                    WHEN v.chk_hr = 1 THEN "substring"(m.obs_manut, s.pos_kmhr + 1, 12)::integer
                    ELSE 0
                END AS hr_faltam
           FROM frt_pmveic a
             LEFT JOIN cur_man m USING (placa_veiculo)
             LEFT JOIN cur_posicao s ON m.id_veiculo = s.id_veiculo AND m.obs_manut = s.obs_manut
             LEFT JOIN v_veiculos v USING (placa_veiculo)
             LEFT JOIN frt_pmit i USING (id_pmit)
             LEFT JOIN v_produtos p ON i.pmit_id_origem = p.id_produto
          WHERE 1 = 1 AND a.pmveic_ativo = 1 AND m.placa_veiculo IS NOT NULL AND s.id_veiculo IS NOT NULL AND v.placa_veiculo IS NOT NULL AND v.ativo = 1 AND v.bloqueado <> 1 AND p.id_produto IS NOT NULL
        ), tbl_alertas AS (
         SELECT tmp_alertas.data_vencto,
            tmp_alertas.tipo_alerta,
            tmp_alertas.descr_doc,
            tmp_alertas.numero_doc,
            tmp_alertas.descr_alerta,
            tmp_alertas.id_alerta,
            tmp_alertas.data_vencto - now()::date AS faltam_dias,
            tmp_alertas.obs_alerta,
            tmp_alertas.km_faltam,
            tmp_alertas.hr_faltam
           FROM tmp_alertas
          WHERE tmp_alertas.data_vencto IS NOT NULL AND tmp_alertas.data_vencto > '1901-01-01'::date
          ORDER BY tmp_alertas.data_vencto
        )
 SELECT tbl_alertas.data_vencto,
    tbl_alertas.tipo_alerta,
    tbl_alertas.descr_doc,
    tbl_alertas.numero_doc,
    tbl_alertas.descr_alerta,
    tbl_alertas.faltam_dias,
    tbl_alertas.obs_alerta,
        CASE
            WHEN tbl_alertas.faltam_dias < 0 THEN 1
            WHEN tbl_alertas.faltam_dias >= 0 AND tbl_alertas.faltam_dias <= (6 - date_part('dow'::text, now()::date)::integer) THEN 2
            WHEN tbl_alertas.faltam_dias > (6 - date_part('dow'::text, now()::date)::integer) AND tbl_alertas.faltam_dias <= date_part('days'::text, date_trunc('month'::text, now()::date::timestamp with time zone) + '1 mon'::interval - '1 day'::interval - now()::date::timestamp with time zone)::integer THEN 3
            WHEN tbl_alertas.faltam_dias > date_part('days'::text, date_trunc('month'::text, now()::date::timestamp with time zone) + '1 mon'::interval - '1 day'::interval - now()::date::timestamp with time zone)::integer THEN 4
            ELSE NULL::integer
        END AS situacao,
    tbl_alertas.id_alerta,
        CASE tbl_alertas.tipo_alerta
            WHEN 'DOC. MOTORISTA'::bpchar THEN ('DO FORM ("fornecedor_v01.scx") WITH "fornecedores", "id_fornecedor", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("fornecedor_v01")'::text
            WHEN 'DOC. VEICULO'::bpchar THEN ('DO FORM ("veiculos_frotista.scx") WITH "veiculos", "id_veiculo", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("veiculos_frotista")'::text
            WHEN 'MANUTENCAO'::bpchar THEN ('DO FORM ("veiculos_frotista.scx") WITH "veiculos", "id_veiculo", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("veiculos_frotista")'::text
            ELSE ''::text
        END AS do_form,
    tbl_alertas.km_faltam,
    tbl_alertas.hr_faltam
   FROM tbl_alertas;

ALTER TABLE public.v_alertas
  OWNER TO softlog_seniorlog;
