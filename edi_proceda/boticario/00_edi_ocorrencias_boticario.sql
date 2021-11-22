CREATE TABLE edi_ocorrencias_boticario 
(
	id serial NOT NULL,
	codigo_status integer,
	descricao character(150),
	tipo character(50),
	processo character(15),
	id_ocorrencia_softlog integer,
	CONSTRAINT edi_ocorrencias_ssw_id_pk PRIMARY KEY (id)
);


INSERT INTO edi_ocorrencias_boticario (codigo_status,descricao, tipo, processo) VALUES (1,'MERCADORIA ENTREGUE','ENTREGA','ENTREGA');
