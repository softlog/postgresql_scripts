CREATE TABLE public.scr_ciot_pagamentos
(
	id_ciot_pagamento serial,
	id_ciot integer,
	data_pagamento timestamp,
	valor numeric(12,2),
	tipo_pagamento integer,
	categoria integer,
	id_cc_fornecedor integer,
	observacao character(30),
	documento character(13),
	lancar_efrete integer DEFAULT 0,
	integrado_efrete integer DEFAULT 0,
	id_romaneio integer,
	id_manifesto integer,	
	CONSTRAINT id_ciot_pagamentos_pk PRIMARY KEY (id_ciot_pagamento), 

	CONSTRAINT ind_scr_ciot_pagamentos_id_ciot_fk FOREIGN KEY (id_ciot)
	REFERENCES scr_ciot (id_ciot) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT ind_scr_ciot_pagamentos_id_cc_fornecedor_fk FOREIGN KEY (id_cc_fornecedor)
	REFERENCES fornecedores_contas_correntes (id_cc_fornecedor) MATCH SIMPLE
	ON UPDATE RESTRICT ON DELETE RESTRICT

)
WITH (
  OIDS=FALSE
);

ALTER TABLE scr_ciot_pagamentos ADD COLUMN id_manifesto integer;
ALTER TABLE scr_ciot_pagamentos ADD COLUMN id_romaneio integer;
--ALTER TABLE scr_ciot_pagamentos ADD COLUMN documento character(13);
--ALTER TABLE scr_ciot_pagamentos ADD COLUMN lancar_efrete integer DEFAULT 0;
--ALTER TABLE scr_ciot_pagamentos ADD COLUMN integrado_efrete integer DEFAULT 0;

--SELECT * FROM scr_ciot
ALTER TABLE fila_documentos_integracoes ADD COLUMN id_pagamento integer;



--SELECT * FROM fornecedores_contas_correntes
--INSERT INTO scr_ciot_pagamentos (id_ciot, data_pagamento, valor, tipo_pagamento, categoria, id_cc_fornecedor, id_manifesto)
--VALUES (10, now() + INTERVAL'10 days', 571.74 , 1, 3,  15, 3032)
--UPDATE scr_ciot_pagamentos SET integrado_efrete = 1
--UPDATE scr_ciot_pagamentos SET data_pagamento = current_date
--SELECT * FROm scr_ciot
--ALTER TABLE scr_ciot ADD COLUMN dispara_integracao integer DEFAULT 0;





