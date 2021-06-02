--DROP TABLE sped_cta;
CREATE TABLE sped_cta
(
	id serial NOT NULL,
	data_alteracao date,
	cod_nat_cc integer,
	ind_cta integer,
	nivel integer,
	cod_cta character(200),
	nome_cta character(60),
	cod_cta_ref character(60),		
	CONSTRAINT sped_cta_id_pk PRIMARY KEY (id)	
	
);

ALTER TABLE com_produtos ADD COLUMN id_cta integer;
ALTER TABLE com_compras_itens ADD COLUMN id_cta integer;
--ALTER TABLE empresa ADD COLUMN id_cta_transporte integer;
--ALTER TABLE filial ADD COLUMN id_cta_transporte integer;

