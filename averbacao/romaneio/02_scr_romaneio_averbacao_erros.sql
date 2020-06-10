-- Table: public.scr_manifesto_averbacao_erros

-- DROP TABLE public.scr_manifesto_averbacao_erros;

CREATE TABLE public.scr_romaneio_averbacao_erros
(
  id serial,
  romaneio_averbacao_id integer,
  codigo_erro character(5),
  descricao_erro character(100),
  valor_esperado character(70),
  valor_informado character(70),
  id_processamento integer,
  data_registro timestamp without time zone DEFAULT now(),
  CONSTRAINT scr_romaneio_averbacao_erros_id_pk PRIMARY KEY (id),
  CONSTRAINT ind_scr_romaneio_averbacao_erros_manifesto_averbacao_id_fk FOREIGN KEY (romaneio_averbacao_id)
      REFERENCES public.scr_romaneio_averbacao (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
