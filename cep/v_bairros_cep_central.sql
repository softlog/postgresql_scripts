-- View: public.v_bairros_cep

-- DROP VIEW public.v_bairros_cep;

CREATE OR REPLACE VIEW public.v_bairros_cep AS 
 SELECT b.bai_nu_sequencial AS id_bairro,
    b.ufe_sg AS uf,
    b.loc_nu_sequencial AS id_cidade,
    upper(b.bai_no::text) AS bairro,
    b.bai_no_abrev,
    i.cod_ibge,
    null::text as faixas_cep
   FROM log_bairro b
     LEFT JOIN log_cod_ibge_localidade i ON i.loc_nu_sequencial = b.loc_nu_sequencial;

ALTER TABLE public.v_bairros_cep
  OWNER TO softlog_cep;
