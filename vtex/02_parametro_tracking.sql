INSERT INTO cliente_tipo_parametros (
	id_tipo_parametro,
	nome_parametro,
	descricao_parametro
) VALUES (
	31,
	'INTEGRACAO_FIKBELLA_VTEX',
	'Envia ocorrências de entrega para webservice do Cliente'
)

--SELECT * FROM cliente_parametros

/*
INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, valor_parametro)
VALUES (32, 31,'1' )

SELECT codigo_cliente, nome_cliente, cnpj_cpf FROM cliente WHERE cnpj_cpf = '05889907000177'
*/