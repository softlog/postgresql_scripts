
CREATE TABLE scr_imagens_base64
(
	id serial NOT NULL,
	nome_imagem text,
	id_documento_app integer,
	arquivo text,  
	CONSTRAINT scr_imagens_base64_id_pk PRIMARY KEY (id)  
);

--SELECT * FROM scr_imagens_base64