--DROP TABLE scr_relatorio_viagem_req;
CREATE TABLE scr_relatorio_viagem_req
(
	id serial NOT NULL,
	id_relatorio_viagem integer,
	id_req integer,
	valor numeric(12,2) DEFAULT 0.00,
	descontar integer DEFAULT 1,	  
	CONSTRAINT scr_relatorio_viagem_req_id_pk PRIMARY KEY (id),

	CONSTRAINT scr_relatorio_viagem_req_id_relatorio_viagem_fk FOREIGN KEY (id_relatorio_viagem)
		REFERENCES scr_relatorio_viagem (id_relatorio_viagem) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT scr_relatorio_viagem_req_id_req_fk FOREIGN KEY (id_req)
		REFERENCES com_requisicao (id_requisicao) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT

);



ALTER TABLE scr_relatorio_viagem ADD COLUMN valor_req numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_relatorio_viagem ADD COLUMN valor_outros numeric(12,2) DEFAULT 0.00;