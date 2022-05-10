CREATE TABLE frt_ab_epta_sga_tp_mat
(
  id serial,
  ident_produto character(3),
  descricao text,
  id_produto_softlog integer,
  CONSTRAINT frt_ab_epta_sga_tp_mat_id_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

/*
UPDATE frt_ab_epta_sga_tp_mat SET id_produto_softlog = 6 WHERE id = 2;

SELECT * FROM frt_ab_epta_sga_bomba

INSERT INTO frt_ab_epta_sga_bomba (numero_filial, numero_posto, numero_bomba)
VALUES ('002','00002','00001');
UPDATE frt_ab_epta_sga_bomba SET id_bp = 1

SELECT * FROM frt_ab_epta_sga

UPDATE frt_ab SET ab_id_combust = 1, ab_id_bomba  =1;
UPDATE frt_ab_itens SET ab_id_combust = 1, ab_id_bomba  =1;

SELECT * FROM tb_combust_lub_itens

SELECT * FROM frt_ab 

UPDATE frt_ab SET ab_obs = '

*/

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('001','DIESEL S500');

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('002','DIESEL S10');

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('003','ETANOL');

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('004','GASOLINA COMUM');

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('005','GASOLINA ADITIVADA');

INSERT INTO frt_ab_epta_sga_tp_mat (ident_produto, descricao)
VALUES ('006','ARLA32');


CREATE TABLE frt_ab_epta_sga_bomba
(
  id serial,
  numero_filial character(3),
  numero_posto  character(5),
  numero_bomba character(5),  
  id_bp integer,
  CONSTRAINT frt_ab_epta_sga_bomba_id_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


CREATE TABLE frt_ab_epta_sga_posto
(
  id serial,  
  numero_filial character(3),
  numero_posto character(5),  
  id_posto integer,
  CONSTRAINT frt_ab_epta_sga_posto_id_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

--SELECT * FROM scr_relatorio_viagem

/*
SELECT * FROM frt_ab_epta_sga

*/


