SELECT numero_ctrc_filial, id_conhecimento, calculado_de_id_cidade, calculado_ate_id_cidade, tipo_documento FROM scr_conhecimento WHERE numero_ctrc_filial like '%3646'


SELECT * FROM cidades WHERE id_cidade = 1550
--SELECT * FROM imposto_aliquotas WHERE tipo_imposto = 2

INSERT INTO imposto_aliquotas (tipo_imposto, data_vigencia, aliquota, id_cidade)
VALUES (2,'2020-01-01', 5.00, 5505)


--SELECT codigo_empresa, codigo_filial, cnpj FROM filial