CREATE FOREIGN TABLE fila_processamento_efrete
(	
	status integer DEFAULT 0,
	id_banco_dados integer,
	id_documento integer,
	data_processamento timestamp,  
	data_registro timestamp DEFAULT now(),
	tentativas integer DEFAULT 0
	
) SERVER integracao_softlog_fdw;