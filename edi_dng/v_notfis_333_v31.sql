-- View: public.v_notfis_333_v31

-- DROP VIEW public.v_notfis_333_v31;

CREATE OR REPLACE VIEW public.v_notfis_333_v31 AS 
 SELECT nf.id_nota_fiscal_imp AS id_registro,
    nf.remetente_id,
    nf.destinatario_id,
    nf.consignatario_id,
    nf.id_conhecimento,
    rnf.id_romaneio,
    (((((((((((((((((((((((((((((('333'::text || lpad(COALESCE(nf.cfop_pred_nf, ''::bpchar)::text, 4, '0'::text)) || '0'::text) || lpad(''::text, 8, '0'::text)) || lpad(''::text, 4, '0'::text)) || lpad(''::text, 8, '0'::text)) || lpad(''::text, 4, '0'::text)) || rpad(''::text, 15, ' '::text)) || ' '::text) || rpad(''::text, 10, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || btrim(to_char(0.00, '0000000000000V99'::text))) || rpad(''::text, 5, ' '::text)) || rpad(''::text, 10, ' '::text)) || rpad(''::text, 5, ' '::text)) || rpad(''::text, 12, ' '::text)) || rpad(''::text, 5, ' '::text)) || chr(13) || chr(10) AS registro
   FROM scr_notas_fiscais_imp nf
     LEFT JOIN scr_romaneio_nf rnf ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
UNION
 SELECT nf.id_conhecimento_notas_fiscais AS id_registro,
    c.remetente_id,
    c.destinatario_id,
    c.consig_red_id AS consignatario_id,
    c.id_conhecimento,
    rnf.id_romaneios AS id_romaneio,
    (((((((((((((((((((((((((((((('333'::text || lpad(COALESCE(nf.cfop_pred_nf, ''::bpchar)::text, 4, '0'::text)) || '0'::text) || lpad(''::text, 8, '0'::text)) || lpad(''::text, 4, '0'::text)) || lpad(''::text, 8, '0'::text)) || lpad(''::text, 4, '0'::text)) || rpad(''::text, 15, ' '::text)) || ' '::text) || rpad(''::text, 10, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || lpad(''::text, 15, '0'::text)) || rpad(''::text, 3, ' '::text)) || rpad(''::text, 8, ' '::text)) || btrim(to_char(0.00, '0000000000000V99'::text))) || rpad(''::text, 5, ' '::text)) || rpad(''::text, 10, ' '::text)) || rpad(''::text, 5, ' '::text)) || rpad(''::text, 12, ' '::text)) || rpad(''::text, 5, ' '::text)) || chr(13) || chr(10) AS registro
   FROM scr_conhecimento_entrega rnf
     LEFT JOIN scr_conhecimento c ON c.id_conhecimento = rnf.id_conhecimento
     LEFT JOIN scr_conhecimento_notas_fiscais nf ON c.id_conhecimento = nf.id_conhecimento;

ALTER TABLE public.v_notfis_333_v31
  OWNER TO softlog_bsb;
