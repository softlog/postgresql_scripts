
	SELECT 
		rv.id_relatorio_viagem,
		rv.id_fornecedor,	
		rv.fechamento_inicial,
		SUM(inss_valor) as total_inss_valor,
		SUM(vl_pagar_for) as total_vl_pagar_for
	FROM 
		scr_relatorio_viagem rv
	GROUP BY
		id_relatorio_viagem