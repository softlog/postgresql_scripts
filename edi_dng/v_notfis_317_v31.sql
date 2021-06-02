-- View: public.v_notfis_317_v31

-- DROP VIEW public.v_notfis_317_v31;

CREATE OR REPLACE VIEW public.v_notfis_317_v31 AS 
 SELECT filial.codigo_filial,
    filial.codigo_empresa,
    filial.cnpj,
    ((((((((((('317'::text || rpad("left"(filial.razao_social::text, 40), 40, ' '::text)) || lpad(filial.cnpj::text, 14, '0'::text)) || rpad(COALESCE(filial.inscricao_estadual, ''::bpchar)::text, 15, ' '::text)) || rpad("left"(COALESCE(filial.endereco, ''::character varying)::text, 40), 40, ' '::text)) || rpad("left"(COALESCE(filial.bairro, ''::character varying)::text, 20), 20, ' '::text)) || rpad("left"(COALESCE(c.nome_cidade, ''::bpchar)::text, 35), 35, ' '::text)) || rpad(COALESCE(filial.cep, ''::bpchar)::text, 9, ' '::text)) || rpad("left"(COALESCE(c.cod_ibge, ''::bpchar)::text, 9), 9, ' '::text)) || rpad(COALESCE(c.uf, ''::bpchar)::text, 9, ' '::text)) || rpad(COALESCE(filial.ddd, ''::bpchar)::text || COALESCE(filial.telefone, ''::bpchar)::text, 35, ' '::text)) || rpad(''::text, 11, ' '::text)) || chr(13)|| chr(10) AS registro
   FROM filial
     LEFT JOIN cidades c ON c.id_cidade::numeric = filial.id_cidade;


