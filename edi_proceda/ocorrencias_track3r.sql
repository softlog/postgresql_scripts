CREATE TABLE scr_ocorrencias_track3r
(
	id serial NOT NULL,
	categoria integer,
	id_ocorrencia integer,
	ocorrencia character(150),
	id_ocorrencia_softlog integer,
	CONSTRAINT scr_ocorrencias_track3r_pk PRIMARY KEY (id)
);