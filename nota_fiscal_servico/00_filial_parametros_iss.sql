CREATE TABLE filial_parametros_iss
(
	id serial,
	id_filial integer,
	id_cidade integer,
	aliquota_iss integer,
	serie character(3),
	numero_doc character(9),
	id_produto_iss integer,
	codigo_servico character(10),	
	CONSTRAINT filial_parametros_iss_pk PRIMARY KEY (id),
	CONSTRAINT ind_filial_parametros_iss_id_filial_fk FOREIGN KEY (id_filial)
		REFERENCES filial (id_filial) MATCH SIMPLE
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT ind_filial_parametros_iss_id_cidade_fk FOREIGN KEY (id_cidade)
		REFERENCES cidades (id_cidade) MATCH SIMPLE
		ON UPDATE RESTRICT ON DELETE RESTRICT
		
);

ALTER TABLE filial_parametros_iss DROP COLUMN incentivo_fiscal;
ALTER TABLE filial_parametros_iss DROP COLUMN incentivo_cultural;

ALTER TABLE public.filial_parametros_iss
   ALTER COLUMN aliquota_iss TYPE numeric(12,2);

/*
UPDATE com_nfe_parametros SET id_produto_iss = 8 
UPDATE filial_parametros_iss SET numero_doc = '1';
UPDATE filial_parametros_iss SET serie_doc = 'U';
UPDATE filial_parametros_iss SET lote = '1';
UPDATE filial_parametros_iss SET cnae = '4930202';
UPDATE filial_parametros_iss SET usuario = '82980861120';
UPDATE filial_parametros_iss SET senha = '963147';

SELECT * FROM empresa
SELECT * FROM com_nfe_parametros

SELECT filial_parametros_iss.id, filial_parametros_iss.id_filial, filial_parametros_iss.id_cidade, cidades.nome_cidade, cidades.uf, filial_parametros_iss.aliquota_iss, filial_parametros_iss.serie, filial_parametros_iss.numero_doc, filial_parametros_iss.id_produto_iss, filial_parametros_iss.codigo_servico, filial_parametros_iss.natureza_tributacao, filial_parametros_iss.incentivo_fiscal, filial_parametros_iss.incentivo_cultural, filial_parametros_iss.tipo_tributacao, filial_parametros_iss.exigibilidade, filial_parametros_iss.codigo_tributacao, filial_parametros_iss.lote, filial_parametros_iss.usuario, filial_parametros_iss.senha, filial_parametros_iss.cnae FROM filial_parametros_iss LEFT JOIN cidades ON cidades.id_cidade = filial_parametros_iss.id_cidade WHERE 1=2

*/

ALTER TABLE filial_parametros_iss ADD COLUMN natureza_tributacao integer;
--ALTER TABLE filial_parametros_iss ADD COLUMN incentivo_fiscal integer DEFAULT 0;
--ALTER TABLE filial_parametros_iss ADD COLUMN incentivo_cultural integer DEFAULT 0;
ALTER TABLE filial_parametros_iss ADD COLUMN tipo_tributacao integer;
ALTER TABLE filial_parametros_iss ADD COLUMN exigibilidade integer;
ALTER TABLE filial_parametros_iss ADD COLUMN codigo_tributacao character(15);

ALTER TABLE filial_parametros_iss ADD COLUMN cnae character(7);
ALTER TABLE filial_parametros_iss ADD COLUMN lote character(15);
ALTER TABLE filial_parametros_iss ADD COLUMN usuario character(50);
ALTER TABLE filial_parametros_iss ADD COLUMN senha character(50);


ALTER TABLE com_nfe_parametros DROP COLUMN id_produto_5933;
ALTER TABLE com_nfe_parametros DROP COLUMN id_produto_6933;

ALTER TABLE com_nfe_parametros ADD COLUMN id_produto_iss integer;

ALTER TABLE com_nfe_parametros DROP COLUMN incentivo_fiscal;
ALTER TABLE com_nfe_parametros DROP COLUMN incentivo_cultural;

ALTER TABLE com_nfe_parametros ADD COLUMN natureza_tributacao integer;
--ALTER TABLE com_nfe_parametros ADD COLUMN incentivo_fiscal integer DEFAULT 0;
--ALTER TABLE com_nfe_parametros ADD COLUMN incentivo_cultural integer DEFAULT 0;
ALTER TABLE com_nfe_parametros ADD COLUMN codigo_servico character(10);
ALTER TABLE com_nfe_parametros ADD COLUMN tipo_tributacao integer;
ALTER TABLE com_nfe_parametros ADD COLUMN exigibilidade integer;
ALTER TABLE com_nfe_parametros ADD COLUMN aliquota integer;

ALTER TABLE com_nf DROP COLUMN incentivo_fiscal;
ALTER TABLE com_nf DROP COLUMN incentivo_cultural;

ALTER TABLE com_nf ADD COLUMN natureza_tributacao integer;
--ALTER TABLE com_nf ADD COLUMN incentivo_fiscal integer DEFAULT 0;
--ALTER TABLE com_nf ADD COLUMN incentivo_cultural integer DEFAULT 0;
ALTER TABLE com_nf ADD COLUMN codigo_servico_mun character(10);
ALTER TABLE com_nf ADD COLUMN tipo_tributacao_servico integer;
ALTER TABLE com_nf ADD COLUMN exigibilidade integer;
ALTER TABLE com_nf ADD COLUMN id_cidade_iss integer;


ALTER TABLE com_nf ADD COLUMN id_integracao text;
ALTER TABLE com_nf ADD COLUMN protocolo_emit_nfse text;
ALTER TABLE com_nf ADD COLUMN protocolo_cancelamento_nfse text;
ALTER TABLE com_nf ADD COLUMN cancela_nfse integer DEFAULT 0;
ALTER TABLE com_nf ADD COLUMN pdf_nfse text;
ALTER TABLE com_nf ADD COLUMN xml_nfse text;

--SELECT * FROM com_nf LIMIT 1

/*
SELECT * FROM com_produtos 

SELECT * FROM com_nf LIMIT 10

SELECT * FROM cidades WHERE nome_cidade LIKE '%APARECIDA%GOIANIA%'
DELETE FROM filial_parametros_iss WHERE id = 2
SELECT * FROM filial_parametros_iss

UPDATE cidades SET cod_ibge = '5300108' WHERE id_cidade = 5696

UPDATE com_nf SET id_cidade_iss = 5281 
INSERT INTO com_produtos (descr_item, id_unidade, issqn_aliquota, codigo_mercosul)
VALUES ('SERVICO DE TRANSPORTE',1, 5.0, '0000000');

INSERT INTO filial_parametros_iss (id_filial, id_cidade, aliquota_iss, serie, id_produto_iss, codigo_servico, natureza_tributacao, tipo_tributacao, exigibilidade)
VALUES (27, 5355, 5.00, '1', 11, '1601', 2, 6, 1 )

INSERT INTO filial_parametros_iss (id_filial, id_cidade, aliquota_iss, serie, id_produto_iss, codigo_servico, natureza_tributacao, tipo_tributacao, exigibilidade)
VALUES (27, 5281, 5.00, '1', 11, '1601', 2, 6, 1 )



*/
