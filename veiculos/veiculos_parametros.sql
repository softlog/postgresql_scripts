-- Table: public.cliente_parametros

-- DROP TABLE public.cliente_parametros;
--SELECT * FROM veiculo_tipo_parametros

CREATE TABLE public.veiculo_parametros
(
  id serial,
  id_veiculo integer,
  id_tipo_parametro integer,
  valor_parametro text,
  tipo_dado_parametro character(1),
  codigo_empresa character(3),
  codigo_filial character(3),
  CONSTRAINT veiculo_parametros_id_veiculo_pk PRIMARY KEY (id),
/*
  CONSTRAINT ind_veiculo_parametros_id_veiculo_fk FOREIGN KEY (id_veiculo)
      REFERENCES public.veiculos (id_veiculo) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
*/
  CONSTRAINT ind_veiculo_parametros_id_tipo_parametro_fk FOREIGN KEY (id_tipo_parametro)
      REFERENCES public.veiculo_tipo_parametros (id_tipo_parametro) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);


CREATE TABLE public.veiculo_tipo_parametros
(
  id_tipo_parametro serial,
  nome_parametro character(30),
  descricao_parametro character(100),
  CONSTRAINT veiculo_tipo_parametros_id_tipo_parametro_pk PRIMARY KEY (id_tipo_parametro)
)
WITH (
  OIDS=FALSE
);