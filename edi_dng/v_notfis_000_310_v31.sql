-- View: public.v_notfis_000_310_v31

-- DROP VIEW public.v_notfis_000_310_v31;

CREATE OR REPLACE VIEW public.v_notfis_000_310_v31 AS 
 SELECT f.codigo_filial,
    f.codigo_empresa,
    f.cnpj,
    (((((((((((('000'::text || rpad("left"(f.razao_social::text, 35), 35, ' '::text)) || rpad('PARCEIRO'::text, 35, ' '::text)) 
    || to_char(now(), 'DDMMYY'::text)::character(6)::text) || to_char(now(), 'HHMI'::text)::character(4)::text) || 'NF'::text) 
    || to_char(now(), 'DDMMHHMISS'::text)) || rpad(''::text, 145, ' '::text)) || chr(13) || chr(10)) ||  '310'::text) || 'NOTF'::text) || to_char(now(), 'DDMMHHMISS'::text)) || rpad(''::text, 223, ' '::text)) || chr(13) || chr(10) AS registro
   FROM filial f
     LEFT JOIN cidades c ON c.id_cidade::numeric = f.id_cidade;

ALTER TABLE public.v_notfis_000_310_v31
  OWNER TO softlog_dfreire;


