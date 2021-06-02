-- View: public.v_notfis_316_v31

-- DROP VIEW public.v_notfis_316_v31;

CREATE OR REPLACE VIEW public.v_notfis_316_v31 AS 
 SELECT f.codigo_filial,
    f.codigo_empresa,
    f.cnpj,
    (((((((((((('316'::text || rpad("left"(f.razao_social::text, 40), 40, ' '::text)) || lpad(f.cnpj::text, 14, '0'::text)) || rpad(COALESCE(f.inscricao_estadual, ''::bpchar)::text, 15, ' '::text)) || rpad("left"(COALESCE(f.endereco, ''::character varying)::text, 40), 40, ' '::text)) || rpad("left"(COALESCE(f.bairro, ''::character varying)::text, 20), 20, ' '::text)) || rpad("left"(COALESCE(c.nome_cidade, ''::bpchar)::text, 35), 35, ' '::text)) || rpad(COALESCE(f.cep, ''::bpchar)::text, 9, ' '::text)) || rpad("left"(COALESCE(c.cod_ibge, ''::bpchar)::text, 9), 9, ' '::text)) || rpad(COALESCE(c.uf, ''::bpchar)::text, 9, ' '::text)) || rpad(''::text, 4, ' '::text)) || rpad(COALESCE(f.ddd, ''::bpchar)::text || COALESCE(f.telefone, ''::bpchar)::text, 35, ' '::text)) || rpad(''::text, 7, ' '::text)) || chr(13) || chr(10) AS registro
   FROM filial f
     LEFT JOIN cidades c ON c.id_cidade::numeric = f.id_cidade;

