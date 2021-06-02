ALTER TABLE scr_relatorio_viagem ADD COLUMN km_inicial integer;
ALTER TABLE scr_relatorio_viagem ADD COLUMN km_final integer;
ALTER TABLE scr_relatorio_viagem ADD COLUMN qtd_litros_ab numeric(20,4) DEFAULT 0.00;

SELECT * FROM edi_