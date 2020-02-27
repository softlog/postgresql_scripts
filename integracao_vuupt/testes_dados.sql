SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010106343'

SELECT fp_set_session('pst_cod_empresa', '001');
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 114416;
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 114416;


UPDATE fila_documentos_integracoes SET enviado = 0 WHERE id > 40
INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
SELECT 
	5,
	1,
	nf.id_nota_fiscal_imp,
	r.id_romaneio
FROM 		
	scr_romaneios r
	LEFT JOIN scr_notas_fiscais_imp nf
		ON nf.id_romaneio = r.id_romaneio
WHERE
	r.id_romaneio = 113695



