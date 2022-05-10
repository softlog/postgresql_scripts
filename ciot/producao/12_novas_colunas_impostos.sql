--SELECT * FROM impostos_fornecedor LIMIT 1

ALTER TABLE impostos_fornecedor ADD COLUMN id_manifesto integer;
ALTER TABLE impostos_fornecedor ADD COLUMN id_romaneio integer;