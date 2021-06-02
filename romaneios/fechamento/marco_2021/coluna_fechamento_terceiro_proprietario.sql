--SELECT * FROM v_acertos_relatorio_viagem WHERE data_referencia >= '2021-03-01'

ALTER TABLE scr_relatorio_viagem ADD COLUMN terceiro_proprietario integer DEFAULT 1;