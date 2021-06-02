--- 
INSERT INTO servicos_integracao (id, identificador, descricao, ativo)
VALUES (101,'AVERBWEB','AVERBACAO AVERBWEB',1);

/*

DELETE FROM scr_conhecimento_averbacao 
SELECT * FROM empresa_acesso_servicos
DELETE FROM empresa_acesso_servicos WHERE id_servico_integracao = 101

INSERT INTO empresa_acesso_servicos (id_empresa, id_servico_integracao, host, usuario, senha, averba_rodo, averba_manifesto)
VALUES (1, 101, 'https://teste.averbweb.net.br/Webservice/soapserver','webservice.141','eR5b=yv7', 1,1);

SELE
SELECT serie_doc FROM scr_conhecimento LIMIT 1



SELECT fpy_limpa_texto(fpy_get_cte_30(c.id_conhecimento)) as xml, c.cancelado, c.serie_doc, ltrim(RIGHT(c.numero_ctrc_filial, 7),'0') as numero_cte, cnpj_cpf(filial.cnpj) as cnpj_emitente, trim(s.host) as host, trim(s.usuario) as usuario, trim(s.senha) as senha, trim(s.codigo_acesso) as codigo_acesso, CASE WHEN s.id_servico_integracao = 101 THEN f_get_args_averbweb(c.id_conhecimento, 1, 1) ELSE NULL END::text as args, CASE WHEN c.tipo_transporte IN (2, 3, 4, 12, 16, 20, 21, 26) THEN NULL ELSE s.id_servico_integracao END as id_servico_integracao, CASE WHEN c.tipo_transporte IN (2, 3, 4, 12, 16, 20, 21, 26) AND s.id_servico_integracao IS NOT NULL THEN 'Não averbado pelo tipo de transporte' WHEN s.id_servico_integracao IS NULL THEN 'Sem informação para averbação' ELSE '' END as mensagem FROM scr_conhecimento c LEFT JOIN empresa ON empresa.codigo_empresa = c.empresa_emitente LEFT JOIN filial ON filial.codigo_empresa = c.empresa_emitente AND filial.codigo_filial = c.filial_emitente LEFT JOIN empresa_acesso_servicos s ON s.id_empresa = empresa.id_empresa WHERE id_conhecimento = 4120 AND id_servico_integracao IN (1,100,101)
*/
--SELECT * FROM servicos_integracao ORDER BY 1