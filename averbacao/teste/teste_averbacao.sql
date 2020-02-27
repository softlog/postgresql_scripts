SELECT * FROM fila_importacao_xml WHERE chave_doc = '52191211227424000100550010000042751231315569'

SELECT * FROM empresa_acesso_servicos 

SELECT * FROM empresa

SELECT id_conhecimento, numero_ctrc_filial, tipo_transporte, tipo_documento, data_emissao, cstat, responsavel_seguro, modal FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010000202';

--SELECT * FROM scr_conhecimento_averbacao WHERE id_conhecimento = 183;

UPDATE scr_conhecimento SET cstat = NULL WHERE id_conhecimento = 263666;
UPDATE scr_conhecimento SET cstat = '100' WHERE id_conhecimento = 263666;


SELECT c.id_manifesto, c.numero_ctrc_filial, c.data_emissao, averb.*
FROM 
	scr_conhecimento_averbacao averb 
	LEFT JOIN scr_conhecimento c 
		On c.id_conhecimento = averb.id_conhecimento
WHERE id_manifesto = 44
ORDER BY id DESC;

UPDATE empresa_acesso_servicos SET averba_aereo = 1 WHERE id = 8;

BEGIN;
UPDATE scr_conhecimento SET id_manifesto = NULL WHERE id_manifesto = 44
COMMIT;
SELECT

    numero_ctrc_filial,    
    chave_cte,
    xml_cte_com_assinatura,
    xml_proc_cte,
    xml_retorno,
    xml_proc_cancelamento,
    cancelado,
    modal,
    tipo_documento
FROM
    scr_conhecimento c
    LEFT JOIN scr_cte_lote_itens
        ON scr_cte_lote_itens.id_conhecimento = c.id_conhecimento
    LEFT JOIN cliente pagador ON pagador.codigo_cliente = c.pagador_id
    LEFT JOIN filial t ON t.codigo_empresa = c.empresa_emitente AND t.codigo_filial = c.filial_emitente
WHERE
    c.id_conhecimento =  183
    AND coalesce((xpath('/protCTe/infProt/cStat/text()', 	replace(xml_retorno,'xmlns="http://www.portalfiscal.inf.br/cte"','')::xml)::text[])[1],'') = '100'