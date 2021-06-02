--DROP TABLE scr_relatorio_viagem_contas_pagar;
CREATE TABLE scr_relatorio_viagem_contas_pagar
(
	id serial NOT NULL,
	id_relatorio_viagem integer,
	id_conta_pagar_cc integer,
	valor numeric(12,2) DEFAULT 0.00,
	descontar integer DEFAULT 1,	  
	CONSTRAINT scr_relatorio_viagem_cp_id_pk PRIMARY KEY (id),
	
	CONSTRAINT scr_relatorio_viagem_cp_id_relatorio_viagem_fk FOREIGN KEY (id_relatorio_viagem)
		REFERENCES scr_relatorio_viagem (id_relatorio_viagem) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
			
	CONSTRAINT scr_relatorio_viagem_cp_id_conta_pagar_cc_fk FOREIGN KEY (id_conta_pagar_cc)
		REFERENCES scf_contas_pagar_centro_custos (id_cpagar_custo) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE

);

