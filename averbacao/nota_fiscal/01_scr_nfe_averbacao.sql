-- Table: public.scr_conhecimento_averbacao

-- DROP TABLE public.scr_conhecimento_averbacao;

CREATE TABLE public.scr_nfe_averbacao
(
	id serial,
	id_nota_fiscal_imp integer,
	id_seguradora integer,
	averbado integer DEFAULT 0,
	cancelado integer DEFAULT 0,
	data date,
	hora time without time zone,
	protocolo character(60),
	cod_erro character(10),
	erro text,
	data_registro timestamp without time zone DEFAULT now(),
	data_cancelamento timestamp without time zone,
	reenvia integer DEFAULT 0,
	xml_cancelamento text,
	id_acesso_servico integer,
	numero_averbacao character(50), -- Numero da averbacao
	retorno_averbacao text, -- Retorno da Averbação (XML)
	retorno_cancelamento text,
	CONSTRAINT scr_nfe_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_nfe_id_nf_fk FOREIGN KEY (id_nota_fiscal_imp)
		REFERENCES public.scr_notas_fiscais_imp (id_nota_fiscal_imp) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT ind_scr_nfe_averbacao_id_seguradora_fk FOREIGN KEY (id_seguradora)
		REFERENCES public.fornecedores (id_fornecedor) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE
	)
WITH (
  OIDS=FALSE
);



-- Index: public.scr_conhecimento_averbacao_id_conhecimento

-- DROP INDEX public.scr_conhecimento_averbacao_id_conhecimento;



-- Trigger: tgg_send_averbacao_fila on public.scr_conhecimento_averbacao

-- DROP TRIGGER tgg_send_averbacao_fila ON public.scr_conhecimento_averbacao;


