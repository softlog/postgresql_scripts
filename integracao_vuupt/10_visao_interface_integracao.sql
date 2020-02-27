--SElECT * FROM v_fila_integracao_vuupt
--SELECT id, tipo_integracao, tipo_integracao_desc, tipo_documento, tipo_documento_desc, data_registro, data_processamento, enviado, status, pendencia, pendencia_desc, numero_romaneio, nome_motorista, cpf_motorista, placa_veiculo, id_integracao FROM v_fila_documentos_integracao
CREATE VIEW  v_fila_documentos_integracao AS 
SELECT 
	fd.id,
	fd.tipo_integracao,
	CASE 
		WHEN fd.tipo_integracao = 5 THEN 'VUUPT'
		WHEN fd.tipo_integracao = 4 THEN 'PARCEIROS SOFTLOG'
		WHEN fd.tipo_integracao = 3 THEN 'ITRACK'
		WHEN fd.tipo_integracao = 2 THEN 'SCONFIRMEI'
		WHEN fd.tipo_integracao = 1 THEN 'COMPROVEI'
		ELSE 'DESCONHECIDO'
	END as tipo_integracao_desc,
	fd.tipo_documento,
	CASE 
		WHEN fd.tipo_documento = 1 THEN 'NFe'
		WHEN fd.tipo_documento = 2 THEN 'NFe com CTe'
		WHEN fd.tipo_documento = 3 THEN 'CTe'
		WHEN fd.tipo_documento = 4 THEN 'Romaneio'
		WHEN fd.tipo_documento = -1 THEN 'NFe Exclusão'
	END as tipo_documento_desc,
	fd.data_registro,
	fd.data_processamento,
	fd.enviado,
	CASE 
		WHEN fd.enviado = 0 THEN 'NAO ENVIADO' 
		ELSE 'ENVIADO'
	END as status,
	fd.pendencia,
	CASE	
		WHEN fd.pendencia = 1 THEN 'COM PROBLEMAS'
		ELSE 'OK'
	END as pendencia_desc, 
	r.numero_romaneio,
	mot.nome_razao as nome_motorista,
	mot.cnpj_cpf as cpf_motorista,
	r.placa_veiculo,
	fd.id_integracao
FROM
	fila_documentos_integracoes fd
	LEFT JOIN scr_romaneios r
		ON r.id_romaneio = fd.id_romaneio
	LEFT JOIN fornecedores mot
		ON mot.id_fornecedor = r.id_motorista	
WHERE 
	tipo_documento = 4
	AND tipo_integracao = 5;

--SELECT * FROM v_fila_documentos_integracao_nfe LIMIT 1
SELECT id, enviado, pendencia, id_nota_fiscal_imp, id_romaneio, data_emissao, data_expedicao, serie, numero_nota_fiscal, remetente_nome, remetente_cnpj_cpf, remetente_id_vuupt, destinatario_nome, destinatario_cnpj_cpf, destinatario_id_vuupt, destinatario_endereco, destinatario_numero, destinatario_bairro, destinatario_cep, destinatario_nome_cidade, destinatario_uf, destinatario_uf, destinatario_latitude 
FROM v_fila_documentos_integracao_nfe WHERE 1=2

CREATE VIEW  v_fila_documentos_integracao_nfe AS 
SELECT 
	fd.id,
	fd.enviado, 
	fd.pendencia,
	--Nota Fiscal
	r.id_romaneio,
	r.numero_romaneio,
	to_char(r.data_romaneio,'YYYY-MM-DD HH24:MI:SS') as data_romaneio,	                          
	to_char(r.data_saida,'YYYY-MM-DD HH24:MI:SS') as data_saida,
	to_char(r.data_chegada, 'YYYY-MM-DD HH24:MI:SS') as data_chegada,
	r.placa_veiculo,
	r.id_motorista,
	mot.cnpj_cpf as motorista_cpf,
	mot.id_cidade as motorista_id_cidade,
	r.id_transportador_redespacho,
	red.cnpj_cpf as redespachador_cpf,
	red.id_cidade as redespacho_id_cidade,
	r.id_origem,			
	nf.id_nota_fiscal_imp,
	trim(to_char(nf.data_emissao,'YYYY-MM-DD')) as data_emissao,
	trim(to_char(nf.data_expedicao,'YYYY-MM-DD')) as data_expedicao,
	trim(nf.serie_nota_fiscal) as serie,
	trim(nf.numero_nota_fiscal) as numero_nota_fiscal,
	nf.chave_nfe,
	trim(nf.serie_nota_fiscal) || '/' || trim(nf.numero_nota_fiscal) as codigo_servico_softlog,
	nf.valor,					
	nf.peso_presumido as peso,
	nf.peso_liquido,
	nf.id_ocorrencia,
	to_char(nf.data_ocorrencia,'YYYY-MM-DD HH24:MI:SS') as data_ocorrencia,
	nf.volume_presumido as volume,
	null::integer as id_conhecimento_notas_fiscais,
	nf.id_conhecimento,
	fp.valor_parametro as id_motorista_vuupt, 

	--Remetente
	rem.codigo_cliente as remetente_id,
	trim(rem.nome_cliente) as remetente_nome,
	trim(rem.cnpj_cpf) as remetente_cnpj_cpf,
	CASE 	WHEN char_length(rem.cnpj_cpf) = 9 
		THEN 'person'
		ELSE 'company'
	END::text as remetente_tipo_contato,
	CASE 	WHEN rem.end_complemento IS NOT NULL 
		THEN trim(fpy_limpa_caracteres(rem.endereco)) || ', ' || trim(fpy_limpa_caracteres(rem.end_complemento)) 
		ELSE trim(fpy_limpa_caracteres(rem.endereco))
	END as remetente_endereco,
	trim(fpy_limpa_caracteres(rem.numero)) as remetente_numero,
	trim(fpy_limpa_caracteres(rem.bairro)) as remetente_bairro,
	rem.id_cidade as remetente_id_cidade, 
	rem.cep as remetente_cep,
	(rem.ddd || ' ' || rem.telefone) as remetente_telefone,
	trim(fpy_limpa_caracteres(cr.nome_cidade)) as remetente_nome_cidade,
	cr.uf as remetente_uf,
	rem.latitude as remetente_latitude,
	rem.longitude as remetente_longitude,
	rem.id_vuupt as remetente_id_vuupt,

	--Destinatario
	dest.codigo_cliente as destinatario_id,
	trim(dest.nome_cliente) as destinatario_nome,
	trim(dest.cnpj_cpf) as destinatario_cnpj_cpf,
	CASE 	WHEN char_length(rem.cnpj_cpf) = 9 
		THEN 'person'
		ELSE 'company'
	END::text as destinatario_tipo_contato,
	CASE 	WHEN dest.end_complemento IS NOT NULL 
		THEN trim(fpy_limpa_caracteres(dest.endereco)) || ', ' || trim(fpy_limpa_caracteres(dest.end_complemento)) 
		ELSE trim(fpy_limpa_caracteres(dest.endereco))
	END as destinatario_endereco,
	trim(fpy_limpa_caracteres(dest.numero)) as destinatario_numero,
	trim(fpy_limpa_caracteres(dest.bairro)) as destinatario_bairro,
	dest.id_cidade as destinatario_id_cidade, 
	dest.cep as destinatario_cep,
	(dest.ddd || ' ' || dest.telefone) as destinatario_telefone,
	trim(fpy_limpa_caracteres(cd.nome_cidade)) as destinatario_nome_cidade,
	cd.uf as destinatario_uf,
	dest.latitude as destinatario_latitude,
	dest.longitude as destinatario_longitude,
	dest.id_vuupt as destinatario_id_vuupt		
FROM 
	fila_documentos_integracoes fd
	LEFT JOIN scr_romaneios r
		ON r.id_romaneio = fd.id_romaneio
	LEFT JOIN scr_notas_fiscais_imp nf
		ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
	LEFT JOIN fornecedores mot
		ON mot.id_fornecedor = r.id_motorista
	LEFT JOIN fornecedor_parametros fp
		ON fp.id_fornecedor = mot.id_fornecedor 
			AND id_tipo_parametro = 5
	LEFT JOIN fornecedores red
		ON red.id_fornecedor = r.id_transportador_redespacho
	LEFT JOIN cliente rem
		ON rem.codigo_cliente = nf.remetente_id
	LEFT JOIN cidades cr
		ON cr.id_cidade = rem.id_cidade
	
	LEFT JOIN cliente dest 
		ON dest.codigo_cliente = nf.destinatario_id
	LEFT JOIN cidades cd
		ON cd.id_cidade = dest.id_cidade
	
WHERE
	fd.tipo_documento  = 1
	AND fd.tipo_integracao = 5;

CREATE OR REPLACE VIEW api_integracao_nfe AS 
SELECT 
	ID, 
	TIPO_INTEGRACAO, 
	TIPO_CADASTRO, 
	TIPO_API, 
	ID_FILA, 
	ID_SOFTLOG, 
	ID_INTEGRACAO,  
	RESPOSTA, 
	PRODUCAO, 
	DATA_REGISTRO 
FROM 
	API_INTEGRACAO  
ORDER BY 
	data_registro