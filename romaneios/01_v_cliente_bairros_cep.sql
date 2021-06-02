-- View: public.v_cliente_bairros_cep

-- DROP VIEW public.v_cliente_bairros_cep;

CREATE OR REPLACE VIEW public.v_cliente_bairros_cep AS 
 WITH t AS (
         SELECT cli.codigo_cliente,
            cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            left(cli.cep, 5)::integer  AS rad_cep,
            right(cli.cep, 8)::integer AS suf_cep,
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
     LEFT JOIN v_bairros_cep_faixa f ON t.cod_ibge = f.cod_ibge::bpchar
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


