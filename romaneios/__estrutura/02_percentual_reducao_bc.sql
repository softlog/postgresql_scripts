--SELECT * FROM scr_tabela_motorista_tipo_calculo ORDER BY 1

--SELECT * FROM scr_tabela_motorista_regiao_calculos ORDER BY 1



ALTER TABLE scr_tabela_motorista_regiao_calculos ADD COLUMN percentual_reducao numeric(12,2) DEFAULT 0.00;