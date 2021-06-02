DROP TABLE scr_ciot_erros;

CREATE TABLE public.fila_documentos_integracoes_retorno
(
	id serial,
	tipo_integracao integer DEFAULT 1,
	data_processamento timestamp DEFAULT now(),
	mensagem text,	
	id_fila_documentos_integracao integer,
	
	 
	CONSTRAINT fila_documentos_integracoes_retorno_id_pk PRIMARY KEY (id), 

	CONSTRAINT ind_fila_documentos_integracoes_retorno_id_fila_documentos_integracao_fk FOREIGN KEY (id_fila_documentos_integracao)
	REFERENCES fila_documentos_integracoes (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE     

)
WITH (
  OIDS=FALSE
);
/*

SELECT * FROM fornecedor_parametros

--DELETE FROM fila_documentos_integracoes

SELECT * FROM fila_documentos_integracoes_retorno

SELECT * FROM fila_documentos_integracoes

SELECT id_fornecedor, nome_razao FROM fornecedores WHERE id_fornecedor IN (1211, 2080) ORDER BY 1 DESC LIMIT 10
UPDATE fornecedores SET id_fornecedor = id_fornecedor WHERE id_fornecedor > 2074
S
1211
2080


--SELECT * FROM v_documentos_efrete ORDER BY data_processamento



UPDATE fornecedores SET efrete_proprietario = 0 WHERE id_fornecedor = 2080

*/