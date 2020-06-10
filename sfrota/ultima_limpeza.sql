
--SELECT (current_date - INTERVAL'360 days') as data

--SELECT (current_date - (current_date - INTERVAL'360 days')::date)

	SELECT 
		u.id_filial_sub,
		u.nome_descritivo,
		u.id_filial_sub,
		u.id_filial,		
		COALESCE(MAX(r.data_chegada), current_date - INTERVAL'360 days')::date as data_limpeza,
		(current_date - 
			(
				COALESCE(
				MAX(r.data_chegada)::date, 
				current_date
			) - INTERVAL'360 days')::date
		) as dias
		
	FROM 
		filial_sub u
		LEFT JOIN scr_romaneios r
			ON r.id_destino = u.id_filial_sub
				AND r.tipo_rota = 2
				AND r.tipo_romaneio = 3
				AND r.id_tipo_atividade = 2
	WHERE 
		u.id_filial = 1 --Parametrizar

	GROUP BY
		u.id_filial_sub

	

