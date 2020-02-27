
CREATE TABLE edi_ocorrencias_vuupt
(
	id serial NOT NULL,
	codigo_vuupt integer,
	descricao character(150),
	id_ocorrencia_softlog integer,
	CONSTRAINT edi_ocorrencias_vuupt_id_pk PRIMARY KEY (id)
);

