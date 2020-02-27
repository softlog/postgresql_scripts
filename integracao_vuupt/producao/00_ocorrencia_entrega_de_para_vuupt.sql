
CREATE TABLE edi_ocorrencias_vuupt
(
	id serial NOT NULL,
	codigo_vuupt integer,
	descricao character(150),
	id_ocorrencia_softlog integer,
	CONSTRAINT edi_ocorrencias_itrack_id_pk PRIMARY KEY (id)
);

/*
INSERT INTO edi_ocorrencias_vuupt (id, codigo_vuupt, descricao, id_ocorrencia_softlog)
VALUES (1,1,'Processo de Transporte Iniciado',1)

UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 21 WHERE id = 583;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 229 WHERE id = 584;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog =  60 WHERE id = 585;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 79 WHERE id = 589;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 78 WHERE id = 590;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 81 WHERE id = 591;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 80 WHERE id = 592;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 54 WHERE id = 612;
UPDATE edi_ocorrencias_vuupt SET id_ocorrencia_softlog = 301 WHERE id = 613;
SELECT * FROM edi_ocorrencias_vuupt
*/

