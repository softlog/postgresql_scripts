-- Table: public.filial_sub
-- DROP TABLE IF EXISTS public.filial_sub;
CREATE TABLE public.filial_sub
(
  id_filial_sub SERIAL,
  id_filial integer,
  codigo_filial_sub character(3), -- Código da filial
  nome_descritivo character varying(50), -- Nome descritivo da filial
  sigla character(4), -- Sigla da Unidade
  ativa integer DEFAULT 1, -- Define se a filial esta ativa
  ddd character(2), -- Ddd
  telefone character(8), -- Telefone
  pessoa_contato character(40),
  obs CHARACTER(150), 
  CONSTRAINT id_filial_sub PRIMARY KEY (id_filial_sub),
  CONSTRAINT filial_sub_filial UNIQUE (id_filial,codigo_filial_sub),
  CONSTRAINT fk_filial_sub_id_filial FOREIGN KEY (id_filial)
      REFERENCES public.filial (id_filial) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE public.filial_sub
  IS 'Tabela de Sub Unidades das Filiais/Unidades';

COMMENT ON COLUMN public.filial_sub.id_filial_sub IS 'ID da Sub Unidade';
COMMENT ON COLUMN public.filial_sub.id_filial IS 'ID da Filial/Unidade';
COMMENT ON COLUMN public.filial_sub.codigo_filial_sub IS 'Código da Sub Unidade';
COMMENT ON COLUMN public.filial_sub.nome_descritivo IS 'Nome da Sub Unidade';
COMMENT ON COLUMN public.filial_sub.sigla IS 'Sigla da Sub Unidade';
COMMENT ON COLUMN public.filial_sub.ativa IS 'Define se a Sub Unidade esta ativa';
COMMENT ON COLUMN public.filial_sub.ddd IS 'Ddd';
COMMENT ON COLUMN public.filial_sub.telefone IS 'Telefone';
COMMENT ON COLUMN public.filial_sub.pessoa_contato IS 'Pessoa de Contato na Sub Unidade';
COMMENT ON COLUMN public.filial_sub.obs IS 'Observacoes sobre a Sub Unidade';

ALTER TABLE filial_sub ADD COLUMN km_distancia_base INTEGER;
ALTER TABLE filial_sub ADD COLUMN tempo_estimado NUMERIC(8,1);