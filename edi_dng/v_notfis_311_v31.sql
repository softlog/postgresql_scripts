-- View: public.v_notfis_311_v31

-- DROP VIEW public.v_notfis_311_v31;

CREATE OR REPLACE VIEW public.v_notfis_311_v31 AS 
 SELECT cli.codigo_cliente AS id_registro,
    cli.cnpj_cpf,
    ((((((((('311'::text || lpad(cli.cnpj_cpf::text, 14, '0'::text)) || rpad(COALESCE(cli.inscricao_estadual, ''::character varying)::text, 15, ' '::text)) || rpad("left"(COALESCE(cli.endereco, ''::bpchar)::text, 40), 40, ' '::text)) || rpad("left"(COALESCE(c.nome_cidade, ''::bpchar)::text, 35), 35, ' '::text)) || rpad(COALESCE(cli.cep, ''::bpchar)::text, 9, ' '::text)) || rpad(COALESCE(c.uf, ''::bpchar)::text, 9, ' '::text)) || to_char('now'::text::date::timestamp with time zone, 'DDMMYYYY'::text)::character(8)::text) || rpad("left"(cli.nome_cliente::text, 40), 40, ' '::text)) || rpad(''::text, 67, ' '::text)) || chr(13) || chr(10) AS registro
   FROM cliente cli
     LEFT JOIN cidades c ON c.id_cidade::numeric = cli.id_cidade;

