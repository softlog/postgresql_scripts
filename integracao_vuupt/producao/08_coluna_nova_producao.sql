ALTER TABLE fila_documentos_integracoes ADD COLUMN producao integer DEFAULT 1;
ALTER TABLE fila_documentos_integracoes ADD COLUMN excluir integer DEFAULT 0;

ALTER TABLE api_integracao ADD COLUMN producao integer DEFAULT 1;
ALTER TABLE api_integracao ADD COLUMN data_registro timestamp DEFAULT NOW();
--SELECT * FROM api_integracao LIMIT 2

ALTER TABLE cliente ADD COLUMN id_vuupt text;

ALTER TABLE fornecedores ADD COLUMN id_vuupt text;
ALTER TABLE veiculos ADD COLUMN id_vuupt text;


--SELECT * FROM api_integracao ORDER BY 1 DESC LIMIT 10
/*
SELECT * FROM 
UPDATE veiculos SET id_vuupt = NULL
--UPDATE fila_documentos_integracoes SET producao = 0;


SELECT 
	id_softlog, 
	string_agg(id_integracao,',') as lst_id,
	count(*) as qt
FROM 
	api_integracao 
WHERE 
	tipo_api = 'customer'
GROUP BY 
	id_softlog
HAVING COUNT(*) > 1

	SELECT * FROM api_integracao ORDER BY 1 DESC LIMIT 100
	SELECT * FROM fila_documentos_integracoes WHERE producao = 1 AND enviado = 0 AND tipo_documento = 1

	SELECT endereco, end_complemento FROM cliente WHERE cnpj_cpf = '05947352000334'
	*/

--DELETE FROM api_integracao WHERE id IN (10195,10194)
	