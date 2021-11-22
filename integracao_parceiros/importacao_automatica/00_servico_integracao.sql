INSERT INTO servicos_integracao (id, identificador, descricao, ativo)
VALUES (1001, 'NFE-SOFTLOG', 'Integração de Parceiros Softlog Romaneio', 1);

/*
SELECT * FROM empresa_acesso_servicos 
DELETE FROM empresa_acesso_servicos WHERE id = 9


INSERT INTO empresa_acesso_servicos (id_empresa, id_servico_integracao, host, usuario, senha, port, codigo_acesso, descricao)
VALUES (1, 1001, 'pg4.softlog.eti.br', '15598197000180', null, '5432', '53', 'NFe Parceiros');

SELECT * FROM empresa
SELECT * FROM edi_tms_agenda_envio WHERE id_banco_dados = 73

UPDATE edi_tms_agenda_envio set proximo_processamento = proximo_processamento - INTERVAL'2 HOURS' WHERE id_subscricao = 9 AND id_banco_dados = 73;


SELECT * FROM msg_edi_lista_chaves ORDER BY data_registro DESC LIMIT 100

*/