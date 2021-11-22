ALTER TABLE empresa ADD COLUMN certificado text;
ALTER TABLE filial ADD COLUMN certificado text;

ALTER TABLE empresa ADD COLUMN certificado_id text;
ALTER TABLE filial ADD COLUMN certificado_id text;

ALTER TABLE empresa ADD COLUMN certificado_senha character(30);
ALTER TABLE filial ADD COLUMN certificado_senha character(30);

ALTER TABLE filial ADD COLUMN habilitada_plugnotas integer DEFAULT 0;





/*

UPDATE empresa SET certificado_senha = 'softlog2020';
UPDATE filial SET certificado_senha = 'softlog2020';

UPDATE filial SET habilitada_plugnotas = 1
UPDATE empresa SET certificado_id = '5ecc441a4ea3b318cec7f999'

*/
