--DROP TABLE scr_relatorio_viagem_os;
CREATE TABLE scr_relatorio_viagem_os
(
	id serial NOT NULL,
	id_relatorio_viagem integer,
	id_os integer,
	valor numeric(12,2) DEFAULT 0.00,
	descontar integer DEFAULT 1,	  
	CONSTRAINT scr_relatorio_viagem_os_id_pk PRIMARY KEY (id),
	CONSTRAINT scr_relatorio_viagem_os_id_relatorio_viagem_fk FOREIGN KEY (id_relatorio_viagem)
		REFERENCES scr_relatorio_viagem (id_relatorio_viagem) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT scr_relatorio_viagem_ab_id_os_fk FOREIGN KEY (id_os)
		REFERENCES frt_os (id_os) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE

);