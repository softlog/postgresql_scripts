
--DELETE FROM veiculo_tipo_parametros;
INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (1, 'ID_RASTREADOR_KRONA', 'ID do Rastreador para Gerenciadora Krona',NULL);


INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (2, 'TIPO_COMUNICACAO_KRONA', 'Tipo de Comunicação para Gerenciadora Krona', 'GPS/GPRS,GPS/GPRS,GLOBAL,GPS/GPRS+SATELITE,GPS/SATELITE');

INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (3, 'TECNOLOGIA_KRONA', 'Tecnologia para Gerenciadora Krona', 'AUTOTRAC,CARGO TRACCK,CILTRONICS,COMBATE,CONTROLLOC,OMNILINK,ONIX,SASCAR,SIGHRA,STI,TRACKER,TRACKME,VSS,CONTROL,NÃO TEM');

INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (4, 'ID_RASTREADOR_KRONA_SEC', 'ID do Rastreador para Gerenciadora Krona Secundário', NULL);

INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (5, 'TIPO_COMUNICACAO_KRONA_SEC', 'Tipo de Comunicação para Gerenciadora Krona Secundário','GPS/GPRS,GPS/GPRS,GLOBAL,GPS/GPRS+SATELITE,GPS/SATELITE');

INSERT INTO veiculo_tipo_parametros(id_tipo_parametro, nome_parametro, descricao_parametro, lista_opcoes)
VALUES (6, 'TECNOLOGIA_KRONA_SEC', 'Tecnologia para Gerenciadora Krona Secundário', 'AUTOTRAC,CARGO TRACCK,CILTRONICS,COMBATE,CONTROLLOC,OMNILINK,ONIX,SASCAR,SIGHRA,STI,TRACKER,TRACKME,VSS,CONTROL,NÃO TEM');

INSERT INTO fornecedor_tipo_parametros(id, nome_parametro, descricao_parametro)
VALUES (12, 'LIBERACAO_KRONA_MOTORISTA', 'Código de Liberação do Motorista no KRONA');


/*
TRUNCATE veiculo_parametros;
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 1, '1318553');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 2, 'SASCAR');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 3, 'GPS/GPRS');

--DELETE FROM veiculo_parametros
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 1, '1318553');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 2, 'SASCAR');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 3, 'GPS/GPRS');

INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 4, '623370594');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 5, 'POSITRON');
INSERT INTO veiculo_parametros (id_veiculo, id_tipo_parametro, valor_parametro)
VALUES (369, 6, 'RF/GPS/GPRS');

INSERT INTO fornecedor_parametros (

*/