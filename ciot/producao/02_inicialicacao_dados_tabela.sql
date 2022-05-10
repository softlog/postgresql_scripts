INSERT INTO impostos (id, imposto, percentual_base_calculo)
VALUES (1,  'IRRF', 10.00);

INSERT INTO impostos (id, imposto, percentual_base_calculo)
VALUES (2,  'ISS', 100.00);

INSERT INTO impostos (id, imposto, percentual_base_calculo)
VALUES (3,  'INSS', 20.00);

INSERT INTO impostos (id, imposto, percentual_base_calculo)
VALUES (4,  'SEST/SENAT', 20.00);

--SELECT * FROM imposto_aliquotas WHERE tipo_imposto = 1
--TRUNCATE imposto_aliquotas


INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, valor_dependente)
VALUES (1, '2015-04-01',0.00, 1903.98, 0.00, 0.00, 189.59);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, valor_dependente)
VALUES (1, '2015-04-01', 1903.99,2826.65,7.50, 142.80, 189.59);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, valor_dependente)
VALUES (1, '2015-04-01',2826.66,3751.05, 15.00, 354.80, 189.59);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, valor_dependente)
VALUES (1, '2015-04-01',3751.06,4664.68, 22.5, 636.13, 189.59);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, valor_dependente)
VALUES (1, '2015-04-01',4664.69,0.00, 27.5, 869.36, 189.59);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-01-01',0,1830.29, 8.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-01-01',1830.30,3050.52, 9.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-01-01',3050.53, 6101.06 , 11.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-03-01',0.00, 1045.00, 7.5, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-03-01',1045.01, 2089.60, 9.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-03-01',2089.61,3134.40, 12.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (3, '2020-03-01',3134.41, 6101.06, 12.00, 0.00);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao)
VALUES (4, '2020-01-01',0.00, 0.00, 2.50, 0.00);

--GOIANIA
INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, id_cidade)
VALUES (2, '2020-01-01',0.00, 0.00, 5.00, 0.00, 5355);

--RECIFE
INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, id_cidade)
VALUES (2, '2020-01-01',0.00, 0.00, 5.00, 0.00, 1593);

INSERT INTO imposto_aliquotas(tipo_imposto, data_vigencia, faixa_base_calculo_ini, faixa_base_calculo_fim, aliquota, parcela_deducao, id_cidade)
VALUES (2, '2020-01-01',0.00, 0.00, 5.00, 0.00, 1550);



