CREATE FOREIGN TABLE fila_download_imagens(
	
	id_doc integer,
	status integer DEFAULT 0,
	id_banco_dados integer,
	data_registro timestamp DEFAULT now(),
	data_processamento timestamp,	
	qt_tentativas integer DEFAULT 0
) 
SERVER integracao_softlog_fdw;

