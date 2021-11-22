CREATE TABLE scr_tipo_imposto
(
	id_tipo_imposto integer NOT NULL,
	tipo_imposto character(100),
	padrao_sistema integer DEFAULT 1,  
	st integer DEFAULT 0,
	CONSTRAINT scr_tipo_imposto_id_tipo_imposto_pk PRIMARY KEY (id_tipo_imposto)
);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (1,'1. 00-ICMS',1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (2,'2. 40-ISENTO ICMS',1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (3,'3. ISENTO ISS',1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (4,'4. ISS',1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (5,'5. EXPORTACAO ARTIGO 7',1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema, st)
VALUES (6,'6. 60-SUBSTITUIÇÃO TRIBUTÁRIA ART. 25',0, 1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema, st)
VALUES (7,'7. 60-SUBSTITUIÇÃO TRIBUTÁRIA ART. 316',0, 1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema, st)
VALUES (8,'8. 60-SUBSTITUIÇÃO TRIBUTÁRIA (GERAL)',0, 1);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (9,'9. 90-UF DIVERSA DA TRANSPORTADORA',0);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (10,'10. 20-ICMS COM BASE DE CÁLCULO REDUZIDA',0);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (11,'11. SN-SIMPLES NACIONAL',0);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (12,'12. 41-ICMS NÃO TRIBUTADO',0);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (13,'13. 51-ICMS DIFERIDO',0);

INSERT INTO scr_tipo_imposto (id_tipo_imposto, tipo_imposto, padrao_sistema)
VALUES (14,'14. 90-ISENTO ICMS',0);

ALTER TABLE scr_tipo_imposto ADD COLUMN isento integer DEFAULT 0;

--SELECT * FROM scr_tipo_imposto ORDER BY 1
UPDATE scr_tipo_imposto SET isento = 1 WHERE id_tipo_imposto IN (2, 3, 4, 13, 14);

CREATE TABLE scr_tipo_norma
(
	id serial,
	descricao character(100),	
	CONSTRAINT scr_tipo_norma_id_pk PRIMARY KEY (id)
);


INSERT INTO scr_tipo_norma (descricao) 
VALUES 
('LEI'),
('DECRETO'),
('ESTATUTO'),
('REGIMENTO'),
('PORTARIA'),
('RESOLUCAO')



/*
this.AddItem('1. 00-ICMS')
this.AddItem('2. 40-ISENTO ICMS')
this.AddItem('3. ISENTO ISS')
this.AddItem('4. ISS')
this.AddItem('5. EXPORTAÇÃO ARTIGO 7')
this.AddItem('6. 60-SUBSTITUIÇÃO TRIBUTÁRIA ART. 25')
this.AddItem('7. 60-SUBSTITUIÇÃO TRIBUTÁRIA ART. 316')
this.AddItem('8. 60-SUBSTITUIÇÃO TRIBUTÁRIA (GERAL)')
this.AddItem('9. 90-UF DIVERSA DA TRANSPORTADORA')
this.AddItem('10. 20-ICMS COM BASE DE CÁLCULO REDUZIDA')
this.AddItem('11. SN-SIMPLES NACIONAL')
this.AddItem('12. 41-ICMS NÃO TRIBUTADO')
this.AddItem('13. 51-ICMS DIFERIDO')
this.AddItem('14. 90-ICMS ISENTO')

SELECT id, id_estado, tipo, norma_descricao, legislacao, data_vigencia, data_validade, id_tipo_imposto, cst, isenta, reducao, texto_observacao FROM estado_regras_fiscais WHERE 1=2 ORDER BY id_tipo_imposto 
SELECT id, id_estado, numero_certidao, codigo_autenticidade, data_vigencia, data_validade FROM estado_certidoes_negativas WHERE 1=2 ORDER BY data_vigencia DESC

SELECT id_tipo_imposto, tipo_imposto FROM scr_tipo_imposto 

SELECT id, id_estado, tipo, norma_descricao, legislacao, data_vigencia, data_validade, id_tipo_imposto, cst, isenta, reducao, texto_observacao, numero, exige_natureza_carga FROM estado_regras_fiscais WHERE 1=2 ORDER BY id_tipo_imposto 

LEI
DECRETO
ESTATUTO
REGIMENTO
PORTARIA
RESOLUCAO
SELECT * FROM estado_regras_fiscais
*/


CREATE TABLE estado_regras_fiscais
(
	id serial NOT NULL,
	id_estado integer,
	tipo character(15),
	norma_descricao character(200),	
	numero character(50),
	legislacao text,
	data_vigencia date,
	data_validade date,
	id_tipo_imposto integer,
	cst character(3),
	isenta integer DEFAULT 0,
	reducao numeric(5,2) DEFAULT 0.00,
	exige_cnd integer DEFAULT 1,
	exige_natureza_carga integer DEFAULT 1, 
	texto_observacao text,
	interestadual integer DEFAULT 0,
	intermunicipal integer DEFAULT 0,
	frete_cif integer DEFAULT 0,
	frete_fob integer DEFAULT 0,
	contribuinte_interno integer DEFAULT 0,
	nao_contribuinte integer DEFAULT 0,
	orgao_publico integer DEFAULT 0,
	produtor_rural integer DEFAULT 0,
	CONSTRAINT estado_regras_fiscais_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_regras_fiscais_id_estado_fk FOREIGN KEY (id_estado)
      REFERENCES estado (id_estado_pk) MATCH SIMPLE
      ON UPDATE RESTRICT ON DELETE RESTRICT
);


CREATE TABLE estado_certidoes_negativas
(
	id serial NOT NULL,
	id_estado integer,
	numero_certidao character(50),
	codigo_autenticidade character(200),
	data_vigencia date,
	data_validade date,
	CONSTRAINT estado_certidoes_negativas_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_estado_certidoes_negativas_id_estado_fk FOREIGN KEY (id_estado)
      REFERENCES estado (id_estado_pk) MATCH SIMPLE
      ON UPDATE RESTRICT ON DELETE RESTRICT
);


-- SELECT estado_regras_fiscais.id, (estado.id_estado || ' - ' || trim(scr_tipo_imposto.tipo_imposto)) as regra FROM estado_regras_fiscais LEFT JOIN scr_tipo_imposto ON scr_tipo_imposto.id_tipo_imposto = estado_regras_fiscais.id_tipo_imposto LEFT JOIN estado ON estado.id_estado_pk = estado_regras_fiscais.id_estado ORDER BY estado.id_estado
-- SELECT scr_natureza_carga_icms.id, scr_natureza_carga_icms.id_natureza_carga,id_estado_regra_fiscal FROM scr_natureza_carga_icms WHERE 1=2 ORDER BY 1

CREATE TABLE scr_natureza_carga_icms
(
	id serial NOT NULL,
	id_natureza_carga integer,
	id_estado_regra_fiscal integer,
	CONSTRAINT scr_natureza_carga_icms_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_snc_icms_id_natureza_carga_fk FOREIGN KEY (id_natureza_carga)
      REFERENCES scr_natureza_carga (id_natureza_carga) MATCH SIMPLE
      ON UPDATE RESTRICT ON DELETE RESTRICT,
      	CONSTRAINT ind_snc_icms_id_estado_regra_fiscal_fk FOREIGN KEY (id_estado_regra_fiscal)
      REFERENCES estado_regras_fiscais (id) MATCH SIMPLE
      ON UPDATE RESTRICT ON DELETE RESTRICT

      
);

