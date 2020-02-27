CREATE TABLE efd_servicos
(
	id integer NOT NULL,
	codigo character(4),
	servico text,
	data_vigencia date, 
	CONSTRAINT efd_servicos_id_pk PRIMARY KEY (id)
);




