CREATE TABLE nfse_tmp
(
	id serial NOT NULL,
	dados text,
	cnpj character(14),
	data_registro timestamp DEFAULT now(),
	id_nf integer,
	CONSTRAINT nfse_tmp_id_pk PRIMARY KEY (id)
 );
