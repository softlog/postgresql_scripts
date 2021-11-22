-- View: public.v_notfis_312_v31

-- DROP VIEW public.v_notfis_312_v31;

CREATE OR REPLACE VIEW public.v_notfis_312_v31 AS 
 SELECT cli.codigo_cliente AS id_registro,
    cli.cnpj_cpf,
    ((((((((((((('312'::text || rpad("left"(cli.nome_cliente::text, 35), 35, ' '::text)) || lpad(cli.cnpj_cpf::text, 14, '0'::text)) || rpad(COALESCE(cli.inscricao_estadual, ''::character varying)::text, 15, ' '::text)) || rpad("left"(COALESCE(cli.endereco, ''::bpchar)::text, 65), 65, ' '::text)) || rpad("left"(COALESCE(cli.bairro, ''::bpchar)::text, 19), 19, ' '::text)) || rpad("left"(COALESCE(c.nome_cidade, ''::bpchar)::text, 30), 30, ' '::text)) || rpad(COALESCE(cli.cep, ''::bpchar)::text, 8, ' '::text)) || rpad("left"(COALESCE(c.cod_ibge, ''::bpchar)::text, 9), 9, ' '::text)) || rpad(COALESCE(c.uf, ''::bpchar)::text, 2, ' '::text)) || rpad(''::text, 4, ' '::text)) || rpad(COALESCE(cli.ddd, ''::bpchar)::text || COALESCE(cli.telefone, ''::character varying)::text, 35, ' '::text)) ||
        CASE
            WHEN char_length(btrim(cli.cnpj_cpf::text)) = 14 THEN '1'::text
            ELSE '2'::text
        END) || rpad(''::text, 1, ' '::text)) || chr(13) || chr(10) AS registro
   FROM cliente cli
     LEFT JOIN cidades c ON c.id_cidade::numeric = cli.id_cidade;

ALTER TABLE public.v_notfis_312_v31
  OWNER TO softlog_dfreire;
