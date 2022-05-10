CREATE TABLE frt_ab_epta_sga
(
	id serial,
	ident character(1),
	ident_veiculo character(10),
	hodometro character(10),
	horimetro character(10),
	ident_custom character(20),
	numero_empresa character(3),
	numero_filial character(3),
	numero_posto character(5),
	numero_tanque character(5),
	numero_bomba character(5),
	numero_bico character(5),
	ident_produto character(3),
	data_abastecimento character(10),
	hora_abastecimento character(8),
	id_abastecedor character(19),
	quantidade character(11),
	cpf_frentista character(14),
	cpf_motorista character(14),
	valor_unitario character(6),
	valor_total character(10),
	numero_cupom character(10),
	encerrante_bomba character(20),
	placa_veiculo character(10),
	cnpj_cadastro_posto character(14),
	campo_livre character(10),
	campo_livre_2 character(10),
	campo_livre_3 character(10),	
	id_ab integer,
	CONSTRAINT frt_ab_epta_sga_id_pk PRIMARY KEY (id)
);

/*
SELECT * FROM frt_ab_epta_sga
*/