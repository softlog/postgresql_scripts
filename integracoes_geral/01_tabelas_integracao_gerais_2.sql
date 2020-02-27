CREATE TABLE api_integracao 
(
	id serial NOT NULL,
	tipo_integracao integer,
	tipo_cadastro integer,
	tipo_api text,
	id_fila integer,
	id_softlog integer,
	id_integracao text,
	resposta text,
	CONSTRAINT api_integracao_id_pk PRIMARY KEY (id)
);

/*
DELETE FROM api_integracao;
UPDATE cliente SET latitude = NULL, longitude = NULL WHERE codigo_cliente IN (3844, 4122)


SELECT * FROM api_integracao ORDER BY 1 DESC LIMIT 100
*/