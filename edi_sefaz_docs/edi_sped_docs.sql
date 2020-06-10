-- Table: public.edi_sped_docs

-- DROP TABLE public.edi_sped_docs;

CREATE TABLE edi_sefaz_docs
(
	id serial, -- Id
	nome_leiaute text, -- Nome do leiaute
	tipo_documento text, -- Categoria do sped
	versao_leiaute text, -- Versao do leiaute
	inicio date, -- Data que a versao do leiaute passou a vigorar
	fim date, -- Data que a versao do leiaute deixou de vigorar
	descricao_leiaute text, -- Descritivo do leiaute
	leiaute text, -- Estrutura do Leiaute
	funcao_responsavel text,	
	CONSTRAINT edi_sefaz_docs_id PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE public.edi_sefaz_docs
  OWNER TO softlog;
COMMENT ON COLUMN public.edi_sefaz_docs.id IS 'Id';
COMMENT ON COLUMN public.edi_sefaz_docs.nome_leiaute IS 'Nome do leiaute';
COMMENT ON COLUMN public.edi_sefaz_docs.tipo_documento IS 'CTe, MDFe, NFe, NFC, Minuta, Romaneio';
COMMENT ON COLUMN public.edi_sefaz_docs.versao_leiaute IS 'Versao do leiaute';
COMMENT ON COLUMN public.edi_sefaz_docs.inicio IS 'Data que a versao do leiaute passou a vigorar';
COMMENT ON COLUMN public.edi_sefaz_docs.fim IS 'Data que a versao do leiaute deixou de vigorar';
COMMENT ON COLUMN public.edi_sefaz_docs.descricao_leiaute IS 'Descritivo do leiaute';
COMMENT ON COLUMN public.edi_sefaz_docs.leiaute IS 'Estrutura do Leiaute';
COMMENT ON COLUMN public.edi_sefaz_docs.funcao_responsavel IS 'Funcao do banco de dados responsavel de fornecer os dados';


