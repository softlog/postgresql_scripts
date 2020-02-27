-- Type: public.t_calculo_frete_peso

-- DROP TYPE public.t_impostos_fornecedor;

CREATE TYPE public.t_impostos_fornecedor AS
(
	id integer,
	tipo_imposto integer,
	imposto character(20),
	id_fornecedor integer,
	mes_ref integer,
	ano_ref integer,
	data_ref date,
	valor_operacao numeric(12,2),
	percentual_base_calculo numeric(5,2),
	base_calculo numeric(12,2),
	aliquota numeric(5,2),
	valor_imposto numeric(12,2),
	deducoes numeric(12,2),
	id_ciot integer,
	qt_dependentes integer,			
	automatico integer 
);


DELETE FROM impostos_fornecedor;
DELETE FROM scr_ciot;

.id, impostos_fornecedor.tipo_imposto, impostos.imposto, impostos_fornecedor.data_ref, impostos_fornecedor.valor_operacao, impostos_fornecedor.percentual_base_calculo, impostos_fornecedor.base_calculo, impostos_fornecedor.aliquota, impostos_fornecedor.valor_imposto, impostos_fornecedor.id_ciot, impostos_fornecedor.automatico FROM impostos_fornecedor LEFT JOIN impostos ON impostos.id = impostos_fornecedor.tipo_imposto