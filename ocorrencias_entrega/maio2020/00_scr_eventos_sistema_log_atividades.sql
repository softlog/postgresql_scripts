-- Table: public.scr_notas_fiscais_imp_log_atividades

-- DROP TABLE public.scr_notas_fiscais_imp_log_atividades;

CREATE TABLE public.scr_eventos_sistema_log_atividades
(
  id serial,
  id_ocorrencia integer, 
  codigo_cliente integer, 
  id_fornecedor integer,  
  codigo_parametro integer, 
  data_hora timestamp without time zone,
  atividade_executada text,
  usuario character(30),
  historico text,
  CONSTRAINT scr_eventos_sistema_log_atividades_id_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


-- Index: public.scr_notas_fiscais_imp_log_atividades_atividade_executada_idx

-- DROP INDEX public.scr_notas_fiscais_imp_log_atividades_atividade_executada_idx;

-- Index: public.scr_notas_fiscais_imp_log_atividades_data_hora_idx

-- DROP INDEX public.scr_notas_fiscais_imp_log_atividades_data_hora_idx;

CREATE INDEX scr_eventos_sistema_log_atividades_data_hora_idx
  ON public.scr_eventos_sistema_log_atividades
  USING btree
  ((data_hora::date));

-- Index: public.scr_notas_fiscais_imp_log_atividades_id_nota_fiscal_imp

-- DROP INDEX public.scr_notas_fiscais_imp_log_atividades_id_nota_fiscal_imp;
/*
CREATE INDEX scr_notas_fiscais_imp_log_atividades_id_nota_fiscal_imp
  ON public.scr_eventos_sistema_log_atividades
  USING btree
  (id_nota_fiscal_imp);


CREATE INDEX scr_notas_fiscais_imp_log_atividades_codigo_cliente
  ON public.scr_eventos_sistema_log_atividades
  USING btree
  (codigo_cliente);


CREATE INDEX scr_notas_fiscais_imp_log_atividades_codigo_cliente
  ON public.scr_eventos_sistema_log_atividades
  USING btree
  (codigo_cliente);

*/
-- Index: public.scr_notas_fiscais_imp_log_atividades_usuario_idx

-- DROP INDEX public.scr_notas_fiscais_imp_log_atividades_usuario_idx;

CREATE INDEX scr_eventos_sistema_log_atividades_usuario_idx
  ON public.scr_eventos_sistema_log_atividades
  USING btree
  (usuario COLLATE pg_catalog."default");

