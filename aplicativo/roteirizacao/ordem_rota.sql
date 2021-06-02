ALTER TABLE scr_romaneio_nf ADD COLUMN ordem_rota integer;
ALTER TABLE scr_conhecimento_entrega ADD COLUMN ordem_rota integer;



SELECT placa_veiculo, data_saida FROM scr_romaneios WHERE data_saida >= (current_date -1)::timestamp ORDER BY data_saida 