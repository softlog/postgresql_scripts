/*	

	Substituicao da tabela frt_tipo_inspecao_itens pela tb_check;
	A frt_operacao_diaria passa a ter um numero de controle e passa a ter um registro por veiculo.
	As inspecoes serao gravadas na tabela frt_operacao_diaria_inspecao.	
	
*/

ALTER TABLE frt_operacao_diaria ADD COLUMN numero_operacao_diaria character(13);
ALTER TABLE frt_operacao_diaria ADD COLUMN placa_veiculo character(9);
ALTER TABLE frt_operacao_diaria RENAME COLUMN hora_final TO data_final;
ALTER TABLE frt_operacao_diaria ADD COLUMN autorizado integer DEFAULT 0;

COMMENT ON COLUMN frt_operacao_diaria.numero_operacao_diaria
		IS 'Numero da operacao diaria composto por codigo_empresa, codigo_filial, numero_sequencial';
		
COMMENT ON COLUMN frt_operacao_diaria.placa_veiculo
		IS 'Placa do veiculo';		

DROP TABLE frt_operacao_diaria_inspecao;
CREATE TABLE frt_operacao_diaria_inspecao
(
	id_operacao_diaria_inspecao serial NOT NULL,
	id_operacao_diaria integer,
	id_check integer,
	valor_positivo integer,
	valor_negativo integer,	
	CONSTRAINT frt_operacao_diaria_inspecao_id_pk PRIMARY KEY (id_operacao_diaria_inspecao),
	CONSTRAINT frt_operacao_diaria_inspecao_id_operacao_diaria_fk FOREIGN KEY (id_operacao_diaria)
		REFERENCES frt_operacao_diaria (id_operacao_diaria) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,		
	CONSTRAINT frt_operacao_diaria_inspecao_id_check_fk FOREIGN KEY (id_check)
		REFERENCES tb_check (id_check) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT	
);

ALTER TABLE frt_operacao_diaria_inspecao ADD COLUMN obs_check character(100);




--SELECT * FROM frt_operacao_diaria
/*
INSERT INTO frt_operacao_diaria (data_inicial, hora_final, codigo_empresa, codigo_filial, numero_operacao_diaria, placa_veiculo)
VALUES ('2020-06-02 06:00:00','2020-06-02 20:00:00','001','001','0010010000001','TTT3187')

INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 71, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 70, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 69, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 68, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 67, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 66, 1, 0);
INSERT INTO frt_operacao_diaria_inspecao (id_operacao_diaria, id_check, valor_positivo, valor_negativo) VALUES ( 1, 65, 1, 0);



*/