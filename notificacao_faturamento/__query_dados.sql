SELECT 
	f.numero_fatura,
	chave_cte,
	cnpj_cpf(fatura_cnpj) || ' - ' || trim(f.fatura_nome) as cliente,
	cnpj_cpf(filial.cnpj) || ' - ' || filial.razao_social as transportadora,
	f.fatura_sacado_id,
	filial.categoria_uso_softlog,
	f.nr_nfs,
	f.tipo_fatura,
	c.id_conhecimento,
	fpy_get_cte_30(c.id_conhecimento) as xml,
	nf.id_nota_fiscal_imp
FROM
	scr_faturamento f
	LEFT JOIN filial 
		ON f.codigo_filial = filial.codigo_filial 
			AND f.codigo_empresa = filial.codigo_empresa
	LEFT JOIN scr_conhecimento c
		ON c.id_conhecimento = f.id_faturamento
	LEFT JOIN scr_conhecimento_notas_fiscais nf
		ON nf.id_conhecimento = c.id_conhecimento
WHERE 
	f.id_faturamento = 6340;

SELECT * FROM scr_faturamento WHERE numero_fatura LIKE '%6289'


SELECT * FROM msg_subscricao LIMIT 1

INSERT INTO msg_subscricao (ativo, id_notificacao, codigo_cliente, email, tipo_host)
VALUES (1, 102, 770, 'paulo.sergio.softlog@gmail.com',1);

SELECT codigo_cliente FROM cliente WHERE cnpj_cpf = '06234797000178'


SELECT  
	c.id_conhecimento,
	numero_ctrc_filial, 
	to_char(c.data_emissao, 'DD/MM/YYYY HH24:MI::SS') as data_emissao,
	remetente_cnpj,
	remetente_nome,
	cr.nome_cidade as cidade_origem,
	cr.uf as uf_origem,
	destinatario_cnpj,
	destinatario_nome,
	ced.bairro as bairro_destino,
	cd.nome_cidade as cidade_destino,
	cd.uf as uf_destino,
	c.qtd_volumes as volumes,
	c.peso,
	c.total_frete, 
	CASE WHEN c.tipo_imposto IN (6,7,8,9,10) THEN c.aliquota_icms_st ELSE aliquota END as aliquota,
	CASE WHEN c.tipo_imposto IN (6,7,8,9,10) THEN c.icms_st ELSE c.imposto END as imposto,
	f.numero_fatura,
	string_agg(nf.numero_nota_fiscal,',') as lst_notas_fiscais,
	status_ctrc(c.status,c.cancelado)::char(30) as status
FROM 
	scr_conhecimento c
	LEFT JOIN cliente_enderecos cer
		ON cer.id_endereco = c.remetente_id_endereco
	LEFT JOIN cidades cr
		ON cer.id_cidade = cr.id_cidade
	LEFT JOIN cliente_enderecos ced
		ON c.destinatario_id_endereco = ced.id_endereco
	LEFT JOIN cidades cd
		ON cd.id_cidade = ced.id_cidade
	LEFT JOIN scr_faturamento f
		ON f.id_faturamento = c.id_faturamento		
	LEFT JOIN scr_conhecimento_notas_fiscais nf
		ON nf.id_conhecimento = c.id_conhecimento
WHERE
	c.id_faturamento = 6340
GROUP BY 
	c.id_conhecimento,
	cer.id_endereco,
	ced.id_endereco,
	cr.id_cidade,
	cd.id_cidade,
	f.id_faturamento;


SELECT  DISTINCT ON (id_conhecimento_notas_fiscais)
	img.id,
	c.id_conhecimento,
	nf.id_conhecimento_notas_fiscais,
	nf.id_nota_fiscal_imp,
	--img2.*,
	nf.numero_nota_fiscal,
	COALESCE(link_s3, link_img) as url_img
FROM 
	scr_conhecimento c
	LEFT JOIN scr_conhecimento_notas_fiscais nf
		ON nf.id_conhecimento = c.id_conhecimento
 	LEFT JOIN scr_docs_digitalizados img
 		ON img.id_conhecimento_notas_fiscais = nf.id_conhecimento_notas_fiscais
 	
WHERE
	c.id_faturamento = 6340
	AND img.id IS NOT NULL
ORDER BY id_conhecimento_notas_fiscais, id ASC;


--SELECT fd_modelo_index()



--SELECT * FROM scr_conhecimento_digitalizado WHERE id_conhecimento = 312508

SELECT * FROM scr_docs_digitalizados WHERE id_conhecimento_notas_fiscais IN (638953,638950,638951,638952)


-- SELECT * FROM fd_dados_tabela('scr_conhecimento') WHERE campo like '%aliquota%'
--SELECT total_peso FROM scr_conhecimento LIMIT 1