CREATE TABLE impostos 
(
	id integer NOT NULL,
	imposto character(20),
	percentual_base_calculo numeric(5,2) DEFAULT 0.00,
	base_calculo_mensal integer DEFAULT 0,	
	CONSTRAINT impostos_id_pk PRIMARY KEY (id)
  
);

SELECT * FROM impostos
--select * from imposto_aliquotas
--SELECT * FROM imposto_aliquotas WHERE tipo_imposto = 1
CREATE TABLE imposto_aliquotas
(
	id serial NOT NULL,
	tipo_imposto integer,
	data_vigencia date,	
	faixa_base_calculo_ini numeric(12,2) DEFAULT 0.00,
	faixa_base_calculo_fim numeric(12,2) DEFAULT 0.00,
	aliquota numeric(5,2) DEFAULT 0.00,
	parcela_deducao numeric(12,2) DEFAULT 0.00,
	valor_dependente numeric(12,2) DEFAULT 0.00,
	id_cidade integer,	
	
	CONSTRAINT imposto_tabela_irrf_id_pk PRIMARY KEY (id),
	CONSTRAINT ind_imposto_aliquotas_tipo_imposto_fk FOREIGN KEY (tipo_imposto)
	REFERENCES impostos (id) MATCH SIMPLE
		ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT ind_imposto_aliquotas_id_cidade_fk FOREIGN KEY (id_cidade)
	REFERENCES cidades (id_cidade) MATCH SIMPLE
		ON UPDATE CASCADE ON DELETE CASCADE
  
);

--DELETE FROM scr_ciot WHERE id_ciot < 7
--SELECT * FROM impostos_fornecedor
CREATE TABLE impostos_fornecedor
(

	id serial NOT NULL,
	id_fornecedor integer,
	tipo_imposto integer,
	mes_ref integer,
	ano_ref integer,
	data_ref date,
	data_registro timestamp DEFAULT now(),
	valor_operacao numeric(12,2) DEFAULT 0.00,
	percentual_base_calculo numeric(5,2) DEFAULT 0.00,
	base_calculo numeric(12,2) DEFAULT 0.00,
	aliquota numeric(5,2) DEFAULT 0.00,
	valor_imposto numeric(12,2) DEFAULT 0.00,
	deducoes numeric(12,2) DEFAULT 0.00,
	id_ciot integer,
	qt_dependentes integer,		
	automatico integer DEFAULT 1,

	CONSTRAINT impostos_fornecedor_id_pk PRIMARY KEY (id),

	CONSTRAINT ind_impostos_fornecedor_id_ciot_fk FOREIGN KEY (id_ciot)
	REFERENCES scr_ciot (id_ciot) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT ind_imposto_fornecedor_tipo_imposto_fk FOREIGN KEY (tipo_imposto)
		REFERENCES impostos (id) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE

);

