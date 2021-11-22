SELECT 	
	rv.*,
	SUM(d.peso_total) as peso_total,
	SUM(d.total_frete) as total_frete,
	SUM(d.total_frete_bruto) as total_frete_bruto,
	SUM(r.vl_despesas_viagem) as vl_despesas_viagem,	
	SUM(r.vl_servico_for) as vl_servico_for
FROM 
	scr_conhecimento c
	LEFT JOIN scr_viagens_docs d
		ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1
	LEFT JOIN scr_romaneios r 
		ON r.id_romaneio = d.id_romaneio
	LEFT JOIN scr_relatorio_viagem_romaneios vr
		ON vr.id_romaneio = r.id_romaneio
	RIGHT JOIN scr_relatorio_viagem rv 
		ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
WHERE 
	c.data_emissao IS NOT NULL
	AND r.data_saida >= '2021-06-01'
	AND r.cancelado = 0	
GROUP BY	
	rv.id_relatorio_viagem
	
ORDER BY 
1 DESC


SELECT 	
	c.tabele_frete,
	c.total_frete,
	rv.*
FROM 
	scr_conhecimento c
	LEFT JOIN scr_viagens_docs d
		ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1
	LEFT JOIN scr_romaneios r 
		ON r.id_romaneio = d.id_romaneio
	LEFT JOIN scr_relatorio_viagem_romaneios vr
		ON vr.id_romaneio = r.id_romaneio
	RIGHT JOIN scr_relatorio_viagem rv 
		ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
WHERE 
	c.data_emissao IS NOT NULL
	AND r.data_saida >= '2021-06-01'
	AND r.cancelado = 0	
ORDER BY 
1 DESC

