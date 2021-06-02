-- View: public.v_notfis_nfe_313_v31

-- DROP VIEW public.v_notfis_nfe_313_v31;

CREATE OR REPLACE VIEW public.v_notfis_nfe_313_v31 AS 
 SELECT nf.id_nota_fiscal_imp AS id_registro,
    nf.remetente_id,
    nf.destinatario_id,
    nf.consignatario_id,
    nf.id_conhecimento,
    rnf.id_romaneio,
    nf.empresa_emitente,
    nf.filial_emitente,
    ((((((((((((((((((((((((((((((('313'::text || rpad(''::text, 15, ' '::text)) || rpad(''::text, 7, ' '::text)) ||
        CASE
            WHEN nf.modal = 2 THEN '2'::text
            ELSE '1'::text
        END) || rpad(''::text, 1, '0'::text)) || rpad(''::text, 1, '0'::text)) ||
        CASE
            WHEN nf.frete_cif_fob = 2 THEN 'F'::text
            ELSE 'C'::text
        END) || lpad('001'::text, 3, '0'::text)) || lpad("right"(nf.numero_nota_fiscal::text, 8), 8, '0'::text)) || lpad(COALESCE(to_char(nf.data_emissao::timestamp with time zone, 'DDMMYYYY'::text), ''::text), 8, '0'::text)) || rpad(COALESCE(nf.natureza_carga, ''::bpchar)::text, 15, ' '::text)) || rpad('UNIDADE'::text, 15, ' '::text)) || btrim(to_char(nf.volume_presumido, '00000V99'::text))) || btrim(to_char(nf.valor, '0000000000000V99'::text))) || btrim(to_char(nf.peso_presumido, '00000V99'::text))) || btrim(to_char(nf.volume_cubico, '000V99'::text))) || rpad(''::text, 1, ' '::text)) || rpad(''::text, 1, ' '::text)) || btrim(to_char(0.00, '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || rpad(''::text, 7, ' '::text)) || rpad(''::text, 1, ' '::text)) || btrim(to_char(0.00, '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || btrim(to_char(0.00, '0000000000000V99'::text))) || rpad('I'::text, 1, ' '::text)) || btrim(to_char(0.00, '0000000000V99'::text))) || btrim(to_char(0.00, '0000000000V99'::text))) || rpad(''::text, 1, ' '::text)) || rpad(''::text, 44, COALESCE(nf.chave_nfe::text, '0'::text))) || chr(13)) || chr(10) AS registro
   FROM scr_notas_fiscais_imp nf
     LEFT JOIN scr_romaneio_nf rnf ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp;

