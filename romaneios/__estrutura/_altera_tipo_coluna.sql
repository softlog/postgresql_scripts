ALTER TABLE scr_relatorio_viagem_fechamentos ALTER COLUMN valor_item TYPE numeric(20,6);
ALTER TABLE scr_relatorio_viagem_fechamentos ADD COLUMN desconto integer DEFAULT 0;

UPDATE scr_tabela_motorista_tipo_calculo SET dividir_por = 100 WHERE id_tipo_calculo = 23;


--SELECT * FROM scr_relatorio_viagem WHERE id_relatorio_viagem = 83
--SELECT * FROM scr_tabela_motorista_tipo_calculo ORDER BY 1



--SELECT id_fechamento, id_relatorio_viagem, tipo_calculo,excedente, base_calculo, valor_item, total_itens, valor_minimo, valor_pagar FROM scr_relatorio_viagem_fechamentos, desconto WHERE 1=2 ORDER BY tipo_calculo, excedente