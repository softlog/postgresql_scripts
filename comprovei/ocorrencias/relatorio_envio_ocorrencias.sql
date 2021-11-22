SELECT 		
	
	nf.numero_nota_fiscal,
	nf.serie_nota_fiscal,
	nf.data_emissao,
	nfo.data_ocorrencia as data_entrega,
	fila.data_envio as data_integracao,
	retira_acento(CASE WHEN link_img_pendente = 1 THEN 'Canhoto Pendente' ELSE (((((((fila.mensagem2::json)->>'details')::json)->0)::json)->>'response')::json)->>'message' END) as status_integracao
FROM 
	fila_envio_romaneios fila
	LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
		ON nfo.id_ocorrencia_nf = fila.id_ocorrencia_nf
	LEFT JOIn scr_notas_fiscais_imp nf
		ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp
WHERE 
	id_tipo_servico = 301 
	AND fila.data_registro >= '2021-10-01 00:00:00'
ORDER By nfo.data_ocorrencia DESC 



SELECT 		
	fila.id_romaneio,
	nf.numero_nota_fiscal,
	nf.serie_nota_fiscal,
	nf.data_emissao,
	nfo.data_ocorrencia as data_entrega,
	fila.data_envio as data_integracao,
	fila.*
	--retira_acento(CASE WHEN link_img_pendente <> link_img_pendente THEN 'Canhoto Pendente' ELSE (((((((fila.mensagem2::json)->>'details')::json)->0)::json)->>'response')::json)->>'message' END) as status_integracao
FROM 
	fila_envio_romaneios fila
	LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
		ON nfo.id_ocorrencia_nf = fila.id_ocorrencia_nf
	LEFT JOIn scr_notas_fiscais_imp nf
		ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp
WHERE 
	id_tipo_servico = 2
	AND fila.data_registro >= '2021-10-01 00:00:00'
	--AND fila.id_romaneio = 198980
ORDER By fila.id_romaneio DESC 
