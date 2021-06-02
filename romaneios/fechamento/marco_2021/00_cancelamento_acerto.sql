ALTER TABLE scr_romaneio_despesas ADD COLUMN id_relatorio_viagem integer;
ALTER TABLE scr_relatorio_viagem ADD COLUMN cancelado integer DEFAULT 0;
ALTER TABLE scr_relatorio_viagem ADD COLUMN motivo_cancelamento text;

