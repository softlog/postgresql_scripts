INSERT INTO cliente_tipo_parametros (id_tipo_parametro, nome_parametro, descricao_parametro) 
VALUES (141, 'TENTATIVAS_PARA_REENTREGA', 'Quantidade de pendências de entrega para gerar cobrança de reentrega.');

INSERT INTO cliente_tipo_parametros (id_tipo_parametro, nome_parametro, descricao_parametro) 
VALUES (142, 'TENTATIVAS_PARA_DEVOLUCAO', 'Quantidade de pendências de entrega para gerar cobrança de devolução.');

INSERT INTO cliente_tipo_parametros (id_tipo_parametro, nome_parametro, descricao_parametro) 
VALUES (143, 'PAGA_DEVOLUCAO_DIRETA', 'Cobrança de Devolução Direta.');

ALTER TABLE scr_ocorrencia_edi ADD COLUMN devolucao_direta INTEGER DEFAULT 0;


UPDATE cliente_tipo_parametros SET 
	descricao_parametro = 'Quantidade de pendências de entrega para gerar cobrança de reentrega.'
WHERE 
	id_tipo_parametro = 141;


UPDATE cliente_tipo_parametros SET 
	descricao_parametro = 'Quantidade de pendências de entrega para gerar cobrança de devolução.'
WHERE 
	id_tipo_parametro = 142;	


UPDATE cliente_tipo_parametros SET 
	descricao_parametro = 'Cobrança de Devolução Direta.'
WHERE 
	id_tipo_parametro = 143;	


/*
SELECT id_nota_fiscal_imp, id_ocorrencia, chave_nfe, data_ocorrencia, tipo_transporte FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::integer = 121197;



SELECT id_nota_fiscal_imp, id_ocorrencia, chave_nfe, data_ocorrencia FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210419897687000138550010001211971203316279'
BEGIN;


UPDATE scr_notas_fiscais_imp SET data_ocorrencia = now(), id_ocorrencia = 64 WHERE id_nota_fiscal_imp = 46269;

SELECT id_nota_fiscal_imp, tipo_transporte, data_emissao, id_ocorrencia FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210205889907000177550020002121071539954052';

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 46269 ORDER BY 1;


SELECT * FROM scr_ocorrencia_edi ORDER BY 2 DESC
ROLLBACK;
--DELETE FROM scr_notas_fiscais_imp_ocorrencias WHERE id_ocorrencia_nf = 46269




*/
	

--SELECT * FROM cliente_parametros LIMIT 1

-- DELETE FROM cliente_tipo_parametros WHERE id_tipo_parametro IN (141,142)
-- SELECT * FROM edi_tms_embarcadores ORDER BY 1
-- 
-- SELECT * FROM edi_tms_embarcador_docs WHERE id_embarcador = 4
-- 
-- 
-- SELECT * FROM edi_tms_agenda_envio WHERE id_banco_dados = 81 AND id_subscricao = 3
-- 
-- UPDATE edi_tms_agenda_envio SET  proximo_processamento = '2018-02-21 14:50:00.645577' WHERE id_banco_dados = 81 AND id_subscricao = 3;
-- 
-- SELECT * FROM empresa_acesso_servicos
-- 
-- UPDATE empresa_acesso_servicos SET codigo_acesso = 'faturada' WHERE id = 3