INSERT INTO cliente_tipo_parametros (id_tipo_parametro, nome_parametro, descricao_parametro)
VALUES (45, 'USAR_FILIAL_XML', 'Utiliza a Filial indicada no XML da NFe');

-- SELECT codigo_cliente  FROM cliente WHERE cnpj_cpf = '09053134000145'
-- SELECT * FROM cliente_parametros 

INSERT INTO cliente_parametros(codigo_cliente, id_tipo_parametro, valor_parametro)
VALUES (8709, 45, '1');


