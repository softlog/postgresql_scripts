CREATE TABLE edi_romaneios
(
	id serial NOT NULL,
	codigo_empresa character(3),
	codigo_filial character(3),
	placa_veiculo character(7),
	id_motorista integer,
	data_romaneio timestamp,
	tipo_destino text,
	id_origem integer,
	id_destino integer,
	id_setor integer,
	data_registro timestamp,
	id_usuario integer,
	id_romaneio integer,
	lst_notas integer[],
	CONSTRAINT edi_romaneios_id_pk PRIMARY KEY (id)
  
);


ALTER TABLE edi_romaneios ADD COLUMN tipo_rota integer DEFAULT 1;
ALTER TABLE edi_romaneios ADD COLUMN odometro_inicial integer;
ALTER TABLE edi_romaneios ADD COLUMN horimetro_inicial integer;
ALTER TABLE edi_romaneios ADD COLUMN id_tipo_atividade integer;
ALTER TABLE edi_romaneios ADD COLUMN id_produto integer;
ALTER TABLE edi_romaneios ADD COLUMN placa_maquina character(15);
ALTER TABLE edi_romaneios ADD COLUMN peso_carga numeric(20,4);
ALTER TABLE edi_romaneios ADD COLUMN data_inicio timestamp;
ALTER TABLE edi_romaneios ADD COLUMN data_fim timestamp;
ALTER TABLE edi_romaneios ADD COLUMN url_odometro text;
ALTER TABLE edi_romaneios ADD COLUMN url_horimetro text;

--DELETE FROM scr_romaneios;
UPDATE edi_romaneios SET id_romaneio = NULL 
--SELECT * FROM edi_romaneios
--TRUNCATE edi_romaneios
--SELECT * FROM scr_romaneios
--SELECT array_length(lst_notas,1) FROM edi_romaneios
--DROP TABLE edi_romaneios
--SELECT * FROM edi_romaneios