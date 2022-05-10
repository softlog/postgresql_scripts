-- Table: public.xml_nfe

-- DROP TABLE public.xml_nfe;

CREATE TABLE public.xml_nfe
(
	id serial,
	chave_nfe character(44),
	data_emissao date,
	inscr_estadual character(20),
	codigo_empresa character(3),
	codigo_filial character(3),
	xml_nfe text,
	status integer DEFAULT 0,
	processada integer DEFAULT 0,
	data_registro timestamp DEFAULT now(),
	id_compra integer,
	cfop_entrada character(4),
	cst_icms character(4),
	data_entrada date,
	CONSTRAINT pk_xml_nfe_id PRIMARY KEY (id)
  
)
WITH (
  OIDS=FALSE
);

ALTER TABLE xml_nfe ADD COLUMN fornecedor_id integer;
ALTER TABLE xml_nfe ADD COLUMN cfop_saida character(4);
ALTER TABLE xml_nfe ADD COLUMN valor_total numeric(12,2);
ALTER TABLE xml_nfe ADD COLUMN tipo_documento integer DEFAULT 0;
ALTER TABLE xml_nfe ADD COLUMN gera_escrituracao integer DEFAULT 0;
ALTER TABLE xml_nfe ADD COLUMN conta_pagar_id integer;
ALTER TABLE xml_nfe ADD COLUMN numero character(9);
ALTER TABLE xml_nfe ADD COLUMN serie character(5);

ALTER TABLE xml_nfe ADD COLUMN itens_cadastrados integer DEFAULT 1;
ALTER TABLE xml_nfe ADD COLUMN itens_parametrizados integer DEFAULT 1;
ALTER TABLE xml_nfe ADD COLUMN parametro_cfop integer DEFAULT 1;
ALTER TABLE xml_nfe ADD COLUMN escriturar integer DEFAULT 0;
ALTER TABLE xml_nfe ADD COLUMN data_escrituracao timestamp;


ALTER TABLE com_compras ADD COLUMN conta_pagar_id integer;
-- Index: public.ind_xml_nfe_chave_nfe

-- DROP INDEX public.ind_xml_nfe_chave_nfe;

CREATE INDEX ind_xml_nfe_chave_nfe
  ON public.xml_nfe
  USING btree
  (chave_nfe COLLATE pg_catalog."default");

-- Index: public.ind_xml_nfe_fk_cad_empresa_codigo

-- DROP INDEX public.ind_xml_nfe_fk_cad_empresa_codigo;

-- Index: public.ind_xml_nfe_processada

-- DROP INDEX public.ind_xml_nfe_processada;

CREATE INDEX ind_xml_nfe_processada
  ON public.xml_nfe
  USING btree
  (processada);

-- Index: public.ind_xml_nfe_status

-- DROP INDEX public.ind_xml_nfe_status;

CREATE INDEX ind_xml_nfe_status
  ON public.xml_nfe
  USING btree
  (status);


-- Trigger: tgg_grava_chave on public.xml_nfe

-- DROP TRIGGER tgg_grava_chave ON public.xml_nfe;

