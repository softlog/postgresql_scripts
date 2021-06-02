
CREATE TABLE scr_relatorio_viagem_ab
(
	id serial NOT NULL,
	id_relatorio_viagem integer,
	id_ab integer,
	valor numeric(12,2) DEFAULT 0.00,
	descontar integer DEFAULT 1,	  
	CONSTRAINT scr_relatorio_viagem_ab_id_pk PRIMARY KEY (id),
	CONSTRAINT scr_relatorio_viagem_ab_id_relatorio_viagem_fk FOREIGN KEY (id_relatorio_viagem)
		REFERENCES scr_relatorio_viagem (id_relatorio_viagem) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT scr_relatorio_viagem_ab_id_ab_fk FOREIGN KEY (id_ab)
		REFERENCES frt_ab (id_ab) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT

);


ALTER TABLE scr_relatorio_viagem ADD COLUMN valor_ab numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN valor_os numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN valor_cp numeric(12,2) DEFAULT 0.00;
