-- Table: public.scr_manifesto_averbacao

-- DROP TABLE public.scr_manifesto_averbacao;

CREATE TABLE scr_romaneio_averbacao
(
  id serial,
  id_romaneio integer,
  id_seguradora integer,
  averbado integer DEFAULT 0,
  cancelado integer DEFAULT 0,  
  data_chancela timestamp without time zone,
  data_cancelamento timestamp without time zone,
  data_encerramento timestamp without time zone,
  protocolo character(60),
  data_registro timestamp without time zone DEFAULT now(),  
  tem_erro integer DEFAULT 0,
  data_processamento_chancela timestamp without time zone,
  data_processamento_cancelamento timestamp without time zone,  
  reenvia integer DEFAULT 0,
  chancelou integer DEFAULT 0,
  cancelou integer DEFAULT 0,  
  id_processamento_chancela integer,
  id_processamento_cancelamento integer,  
  id_acesso_servico integer,
  numero_averbacao character(50), -- Numero da averbacao
  retorno_averbacao text, -- Retorno da averbacao (XML)
  CONSTRAINT scr_romaneio_averbacao_id_pk PRIMARY KEY (id),
  CONSTRAINT ind_scr_romaneio_averbacao_id_seguradora_fk FOREIGN KEY (id_seguradora)
      REFERENCES public.fornecedores (id_fornecedor) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ind_scr_romaneio_averbacao_id_romaneio_fk FOREIGN KEY (id_romaneio)
      REFERENCES public.scr_romaneios(id_romaneio) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

-- DROP INDEX public.scr_manifesto_averbacao_id_manifesto_idx;

CREATE INDEX scr_romaneio_averbacao_id_romaneio_idx
  ON public.scr_romaneio_averbacao
  USING btree
  (id_romaneio);


ALTER TABLE scr_romaneio_averbacao ADD COLUMN cod_erro text;
ALTER TABLE scr_romaneio_averbacao ADD COLUMN erro text;
ALTER TABLE scr_romaneio_averbacao ADD COLUMN retorno_cancelamento text;
