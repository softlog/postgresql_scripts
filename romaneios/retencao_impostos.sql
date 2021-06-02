ALTER TABLE scr_relatorio_viagem ADD COLUMN inss_desconto numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN inss_base_calculo numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN inss_aliquota numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN inss_valor numeric(12,2) DEFAULT 0.00;

ALTER TABLE scr_relatorio_viagem ADD COLUMN irrf_desconto numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN irrf_base_calculo numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN irrf_aliquota numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN irrf_valor numeric(12,2) DEFAULT 0.00;

ALTER TABLE scr_relatorio_viagem ADD COLUMN sest_senat_desconto numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN sest_senat_base_calculo numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN sest_senat_aliquota numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN sest_senat_valor numeric(12,2) DEFAULT 0.00;
