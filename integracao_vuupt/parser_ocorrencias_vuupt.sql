WITH t AS (
	SELECT dados::json as dados, id_edi_ocorrencia_entrega, data_registro FROM vuupt_tmp
)

SELECT 
	dados->>'event', 
	(dados->>'payload')::json->>'id' as id, 
	((dados->>'payload')::json->>'completed_at')::timestamp as data_ocorrencia, 
	((dados->>'payload')::json->>'code') as numero_nota_fiscal,
	((dados->>'payload')::json->>'customer')::json->>'code' as destinatario_cnpj,
	((dados->>'payload')::json->>'latitude') as latitude,
	((dados->>'payload')::json->>'longitude') as longitude,
	id_edi_ocorrencia_entrega,
	data_registro
FROM t
WHERE 
	dados->>'event' = 'Vuupt\Events\Service\ServiceDoneEvent'
ORDER BY data_registro DESC;


/*
SELECT codigo_cliente, nome_cliente, id_vuupt FROM cliente WHERE trim(id_vuupt) = '332942'

SELECT 
	nf.id_nota_fiscal_imp,
	nf.numero_nota_fiscal,
	nf.chave_nfe	
FROM 
	scr_notas_fiscais_imp nf
	LEFT JOIN cliente d
		ON d.codigo_cliente = nf.destinatario_id	
WHERE 
	numero_nota_fiscal::integer = 00158342
	AND d.cnpj_cpf = '12070242000130'
	

--SELECT * FROM fila_documentos_integracoes WHERE id_integracao = 998374
SELECT 
SELECT * FROM vuupt_tmp WHERE dados like '%Vuupt\\E%'
DELETE FROM vuupt_tmp WHERE id = 2
*/