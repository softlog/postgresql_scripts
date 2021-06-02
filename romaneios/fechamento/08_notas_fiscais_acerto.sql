-- View: public.v_notas_fiscais_acerto

DROP VIEW public.v_notas_fiscais_acerto;

CREATE OR REPLACE VIEW public.v_notas_fiscais_acerto AS 
 SELECT nf.id_nota_fiscal_imp,
    rvr.id_relatorio_viagem,
        CASE
            WHEN r.tipo_romaneio = 1 THEN 'Romaneio'::text
            ELSE 'Viagem'::text
        END::character(20) AS tipo_romaneio,
    r.numero_romaneio,
    nf.numero_nota_fiscal,
    nf.data_nota_fiscal,
    c.numero_ctrc_filial,
    nf.valor,
    nf.peso,
    nf.qtd_volumes,
    nf.canhoto,
    c.remetente_nome,
    c.destinatario_nome,
    nf.id_ocorrencia
   FROM scr_relatorio_viagem_romaneios rvr
     LEFT JOIN scr_romaneios r ON r.id_romaneio = rvr.id_romaneio
     LEFT JOIN scr_viagens_docs docs ON docs.id_romaneio = r.id_romaneio AND docs.tipo_documento = 1
     LEFT JOIN scr_viagens_docs mdfe ON mdfe.id_documento = r.id_romaneio AND mdfe.tipo_documento = 2
     LEFT JOIN scr_conhecimento_entrega ce ON ce.id_romaneios = r.id_romaneio
     LEFT JOIN scr_manifesto m ON mdfe.id_documento = m.id_manifesto
     LEFT JOIN scr_conhecimento c ON
        CASE
            WHEN docs.id_documento IS NOT NULL THEN c.id_conhecimento = docs.id_documento
            WHEN ce.id_conhecimento IS NOT NULL THEN c.id_conhecimento = ce.id_conhecimento
            WHEN m.id_manifesto IS NOT NULL THEN m.id_manifesto = c.id_manifesto
            ELSE NULL::boolean
        END
     LEFT JOIN scr_conhecimento_notas_fiscais nf ON nf.id_conhecimento = c.id_conhecimento
  WHERE (nf.id_ocorrencia <> ALL (ARRAY[0, 1])) AND nf.id_ocorrencia < 100;

