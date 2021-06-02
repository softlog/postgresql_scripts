ALTER TABLE scr_romaneios ADD COLUMN tipo_rota integer DEFAULT 1;
--ALTER TABLE scr_romaneios ADD COLUMN id_filial_origem integer;
--ALTER TABLE scr_romaneios ADD COLUMN id_filial_destino integer;
ALTER TABLE scr_romaneios ADD COLUMN id_tipo_atividade integer;
ALTER TABLE scr_romaneios ADD COLUMN id_produto integer;
ALTER TABLE scr_romaneios ADD COLUMN url_odometro text;
ALTER TABLE scr_romaneios ADD COLUMN url_horimetro text;


--DELETE FROM scr_romaneios;
--UPDATE edi_romaneios SET id_romaneio = NULL

--SELECT * FROM empresa
--SELECT * FROM scr_romaneio_log_atividades

--ALTER TABLE public.frt_pneus ALTER COLUMN horimetro_atual TYPE NUMERIC(9,1);

--SELECT * FROM frt_tipo_atividades

--select codigo_filial_sub, nome_descritivo, sigla, id_filial_sub from filial_sub WHERE 1=2