--ALTER TABLE scr_ocorrencia_edi ADD COLUMN inicio_entrega integer DEFAULT 0;

ALTER TABLE scr_ocorrencia_edi DROP COLUMN inicio_entrega;


--SELECT * FROM scr_ocorrencia_edi ORDER BY 1 DESC LIMIT 1
--SELECT * FROM scr_ocorrencia_edi ORDER BY codigo_edi;
--UPDATE scr_ocorrencia_edi SET inicio_entrega = 0 WHERE codigo_edi = 1;
--UPDATE scr_ocorrencia_edi SET inicio_entrega = 1 WHERE codigo_edi = 701;

--SELECT * FROM cliente_tipo_parametros ORDER BY 1 

INSERT INTO cliente_tipo_parametros VALUES (144, 'OCORRENCIA_INICIO_ENTREGA', 'Código da Ocorrência que indica início de entrega.');


/*
INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, valor_parametro)
VALUES (32, 144, '701')
-- DELETE FROM cliente_parametros WHERE id_cliente_parametro = 9
-- SELECT * FROM cliente_parametros WHERE id_tipo_parametro = 144

--		SELECT remetente_id, remetente_cnpj, remetente_nome FROM v_mgr_notas_fiscais WHERE data_expedicao >= '2021-03-01' GROUP BY remetente_id, remetente_cnpj, remetente_nome

--		SELECT * FROM cliente_parametros LIMIT 1


SELECT 
	nf.id_nota_fiscal_imp,
	nf.consignatario_id,
	nf.remetente_id, 
	nf.remetente_cnpj, 
	nf.remetente_nome,
	nf.data_emissao,
	nf.data_expedicao,
	nfo.data_ocorrencia,
	nf.data_previsao_entrega,
	nf.chave_nfe 
FROM 
	v_mgr_notas_fiscais nf
	LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
		ON nfo.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
WHERE 
	data_expedicao >= '2021-03-01' 
	AND nfo.id_ocorrencia = 701
	



UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio WHERE id_nota_fiscal_imp = 40931

	
GROUP BY 
	remetente_id, 
	remetente_cnpj, 
	remetente_nome

BEGIN;
WITH t AS (
	SELECT 
		nf.id_nota_fiscal_imp,
		nf.consignatario_id,
		nf.remetente_id, 
		nf.remetente_cnpj, 
		nf.remetente_nome,
		nf.data_emissao,
		nf.data_expedicao,
		nfo.data_ocorrencia,
		nf.data_previsao_entrega,
		nf.chave_nfe 
	FROM 
		v_mgr_notas_fiscais nf
		LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
			ON nfo.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
	WHERE 
		data_expedicao >= '2021-03-01' 
		AND nfo.id_ocorrencia = 701	
)
UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio FROM t WHERE t.id_nota_fiscal_imp = scr_romaneio_nf.id_nota_fiscal_imp;
COMMIT;


*/