CREATE TABLE fila_processamento_efrete
(
	id serial NOT NULL,
	status integer DEFAULT 0,
	id_banco_dados integer,
	id_documento integer,
	data_processamento timestamp,  
	data_registro timestamp DEFAULT now(),
	tentativas integer DEFAULT 0,
	CONSTRAINT fila_processamento_efrete_id_pk PRIMARY KEY (id)
);