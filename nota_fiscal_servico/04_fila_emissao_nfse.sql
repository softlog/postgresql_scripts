CREATE FOREIGN TABLE fila_nfse
(
	id serial,
	tipo_servico integer,
	id_banco_dados integer,
	id_doc integer,
	data_registro timestamp DEFAULT now(),
	status integer DEFAULT 0,
	data_processamento timestamp,
	retorno text
) SERVER integracao_softlog_fdw;

