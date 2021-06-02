ALTER TABLE col_coletas ADD COLUMN cod_interno_frete character(13);
ALTER TABLE col_coletas ADD COLUMN id_programacao_coleta integer;
ALTER TABLE col_coletas ADD COLUMN id_manifesto integer;

ALTER TABLE col_coletas ADD COLUMN flg_manifesto integer DEFAULT 0;
ALTER TABLE scr_manifesto ALTER COLUMN qtde_volume TYPE numeric(10,3);


ALTER TABLE col_coletas ADD COLUMN saida_coleta timestamp;
ALTER TABLE scr_romaneios ADD COLUMN id_coleta integer;


/*

SELECT string_agg(id_conhecimento::text,',') FROM scr_conhecimento WHERE data_emissao IS NOT NULL;

BEGIN;
UPDATE scr_conhecimento SET id_conhecimento = id_conhecimento WHERE id_conhecimento IN (123,129,173,197,125,200,157,177,128,202,213,142,195,178,217,149,150,131,113,161,109,155,207,114,210,156,239,212,158,222,159,214,115,120,166,130,144,162,240,163,167,139,175,168,112,116,141,165,117,215,132,133,134,118,135,119,121,136,137,180,122,138,219,221,143,140,124,186,181,187,146,145,147,223,174,126,253,182,127,176,151,152,153,247,148,184,154,199,160,164,169,110,179,170,111,229,171,172,235,183,204,209,238,201,245,216,205,252,206,255,248,211,256,231,257,249,233,246,218,234,250,220,236,251,237,185,188,189,190,191,192,193,241,194,196,242,198,203,243,244,208,254,224,225,226,227,228,230,232);
COMMIT;

--ROLLBACK
SELECT id_nota_fiscal_imp FROM col_coletas_itens;
--SELECT cod_interno_frete FROM scr_notas_fiscais_imp LIMIT 100

SELECT numero_tabela_motorista FROM scr_romaneios
--SELECT * FROM cliente_parametros
DELETE FROM scr_romaneios;

SELECT * FROM scr_viagens_docs ORDER BY id_romaneio

--SELECT * FROM scr_romaneio_log_atividades

*/