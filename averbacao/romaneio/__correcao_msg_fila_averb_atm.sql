-- Foreign Table: public.msg_fila_averb_atm

DROP FOREIGN TABLE msg_fila_averb_atm;

CREATE FOREIGN TABLE msg_fila_averb_atm
(	
	id_doc integer,
	id_banco_dados integer,
	status integer DEFAULT 0,
	cancelado integer DEFAULT 0,
	data_fila timestamp without time zone DEFAULT now(),
	data_processamento timestamp without time zone,
	id_averbacao integer,
	is_manifesto integer DEFAULT 0,
	is_romaneio integer DEFAULT 0
)
SERVER integracao_softlog_central_fdw;
