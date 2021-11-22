-- View: public.v_tipo_imposto

-- DROP VIEW public.v_tipo_imposto;

CREATE OR REPLACE VIEW public.v_tipo_imposto AS 
 SELECT 0 AS codigo,
    'SERVIÇO INSENTO'::text AS descricao
UNION
 SELECT 1 AS codigo,
    'ICMS'::text AS descricao
UNION
 SELECT 2 AS codigo,
    'ISENTO ICMS'::text AS descricao
UNION
 SELECT 3 AS codigo,
    'INSENTO ISS'::text AS descricao
UNION
 SELECT 4 AS codigo,
    'ISS'::text AS descricao
UNION
 SELECT 5 AS codigo,
    'INSENTO-EXPORTAÇÃO ART.7'::text AS descricao
UNION
 SELECT 6 AS codigo,
    'SUBSTITUIÇÃO TRIBUTÁRIA ART.25'::text AS descricao;
UNION
 SELECT 7 AS codigo,
    'SUBSTITUIÇÃO TRIBUTÁRIA ART.25'::text AS descricao;

