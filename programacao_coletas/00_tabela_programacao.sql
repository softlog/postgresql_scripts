CREATE TABLE scr_programacao_coleta 
(
	id serial NOT NULL,
	cnpj_transportador character(14),
	codigo_base character(10),
	cnpj_pagador character(14),	
	frete_cif_fob character(3),
	codigo_programacao text,
	placa character(7),
	status character(30), 
	data date,
	hora_prevista_carregamento time, 
	entrada time,
	saida time,
	id_coleta integer,  
	data_registro timestamp DEFAULT now(),
	CONSTRAINT scr_programacao_coleta_id_pk PRIMARY KEY (id)
);



CREATE TABLE scr_programacao_coleta_entrega
(
	id serial NOT NULL,
	id_programacao_coleta integer,
	codigo_cliente integer,
	apelido_cliente character(100),
	status character(30), 
	ordem integer,	
	estimativa timestamp,
	eta_original timestamp,
	eta_atual timestamp,
	chegada_cliente timestamp,
	saida_cliente timestamp,
	id_coleta integer,  
	data_registro timestamp DEFAULT now(),
	CONSTRAINT scr_programacao_coleta_entrega_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_scr_programacao_coleta_entrega_id_programacao_coleta_fk FOREIGN KEY (id_programacao_coleta)
		REFERENCES scr_programacao_coleta (id) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE

);



