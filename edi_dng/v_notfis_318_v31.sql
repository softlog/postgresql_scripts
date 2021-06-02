-- View: public.v_notfis_318_v31

-- DROP VIEW public.v_notfis_318_v31;

CREATE OR REPLACE VIEW public.v_notfis_318_v31 AS 
 SELECT r.id_romaneio,
    ((((((('318'::text || btrim(to_char(sum(nf.valor), '0000000000000V99'::text))) || btrim(to_char(sum(nf.peso_presumido), '0000000000000V99'::text))) || btrim(to_char(sum(nf.volume_cubico), '0000000000000V99'::text))) || btrim(to_char(sum(nf.volume_presumido), '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || rpad(''::text, 147, ' '::text))  || chr(13) || chr(10) AS registro
   FROM scr_romaneios r
     LEFT JOIN scr_romaneio_nf rnf
	ON rnf.id_romaneio = r.id_romaneio
     LEFT JOIN scr_notas_fiscais_imp nf ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
  WHERE rnf.id_romaneio IS NOT NULL
  GROUP BY r.id_romaneio
 UNION 
  SELECT r.id_romaneio,
    ((((((('318'::text 
    || btrim(to_char(sum(nf.valor), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.peso), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.volume_cubico), '0000000000000V99'::text))) 
    || btrim(to_char(sum(nf.qtd_volumes), '0000000000000V99'::text))) 
    || btrim(to_char(0.00, '0000000000000V99'::text))) 
    || btrim(to_char(0.00, '0000000000000V99'::text))) 
    || rpad(''::text, 147, ' '::text)) 
    || chr(13)
    || chr(10) AS registro
   FROM scr_romaneios r
     	LEFT JOIN scr_conhecimento_entrega rnf
		ON r.id_romaneio = rnf.id_romaneios
	LEFT JOIN scr_conhecimento c	
		ON c.id_conhecimento = rnf.id_conhecimento
	LEFT JOIN scr_conhecimento_notas_fiscais nf
		ON c.id_conhecimento = nf.id_conhecimento	
  GROUP BY r.id_romaneio;


--SELECT * FROM v_notfis_318_v31 WHERE id_romaneio = 31243


--SELECT * FROM f_edi_notfis_nfe_romaneio(31243) as texto_edi;
