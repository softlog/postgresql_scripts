-- View: public.v_notfis_318_v31

-- DROP VIEW public.v_notfis_318_v31;

CREATE OR REPLACE VIEW public.v_notfis_318_v31 AS 
 SELECT r.id_romaneio,
    (((((((('318'::text 
    || btrim(to_char(sum(CASE WHEN r.id_transportador_redespacho = 1102 THEN 0.01 ELSE nf.valor END), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.peso_presumido), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.volume_cubico), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.volume_presumido), '0000000000000V99'::text))) 
    || btrim(to_char(0.00, '0000000000000V99'::text))) 
    || btrim(to_char(0.00, '0000000000000V99'::text))) 
    || rpad(''::text, 147, ' '::text)) || chr(13)) || chr(10) AS registro
   FROM scr_romaneios r
     LEFT JOIN scr_notas_fiscais_imp nf ON nf.id_romaneio = r.id_romaneio
  WHERE nf.id_romaneio IS NOT NULL
  GROUP BY r.id_romaneio;

