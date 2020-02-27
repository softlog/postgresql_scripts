CREATE TABLE public.scr_ciot
(
	id_ciot serial,
	numero_ciot character(12),
	origem integer, -- 1 Manifesto, 2 Romaneio
	data_abertura timestamp without time zone,
	data_encerramento timestamp without time zone,
	data_cancelamento timestamp without time zone,
	status_ciot integer default 0,
	retorno_abertura text,
	retorno_encerramento text,
	retorno_cancelamento text,
	id_manifesto integer,
	id_romaneio integer,  
	recolhe_inss integer DEFAULT 1,  
	base_calculo_mes numeric(12,2) DEFAULT 0.00, 
	 
	CONSTRAINT id_ciot_pk PRIMARY KEY (id_ciot), 

	CONSTRAINT ind_scr_ciot_id_manifesto_fk FOREIGN KEY (id_manifesto)
	REFERENCES scr_manifesto (id_manifesto) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE,     

	CONSTRAINT ind_scr_ciot_id_romaneio_fk FOREIGN KEY (id_romaneio)
	REFERENCES scr_romaneios (id_romaneio) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);


