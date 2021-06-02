ALTER TABLE scr_relatorio_viagem ADD COLUMN base_calculo_acumulada numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN observacao_base_calculo text;

ALTER TABLE scr_relatorio_viagem ALTER COLUMN irrf_aliquota  TYPE numeric(12,3);
ALTER TABLE scr_relatorio_viagem ALTER COLUMN inss_aliquota TYPE numeric(12,3);
ALTER TABLE scr_relatorio_viagem ALTER COLUMN sest_senat_aliquota TYPE numeric(12,3);

