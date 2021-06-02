SELECT 
	
	r.data_saida::date as data_saida, 
	r.id_motorista, 
	r.placa_veiculo,
	TRIM (c.nome_cidade) AS nome_cidade,
	TRIM(mot.nome_razao) as nome_motorista, 	            
	COUNT(*) as qtd_entregas,
	SUM(CASE WHEN o.codigo_edi IN (1,2) THEN 1 ELSE 0 END) as qt_entregue,
	SUM(CASE WHEN o.codigo_edi NOT IN (0,1,2) THEN 1 ELSE 0 END) as qt_nao_entregue,
	SUM(CASE WHEN o.codigo_edi = 0 THEN 1 ELSE 0 END) as pendente
	
FROM  
	scr_romaneios r 
	LEFT JOIN scr_romaneio_nf rnf
	    ON rnf.id_romaneio = r.id_romaneio		
	LEFT JOIN scr_notas_fiscais_imp nf
	    ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
	LEFT JOIN scr_ocorrencia_edi o
	    ON nf.id_ocorrencia = o.codigo_edi
	LEFT JOIN fornecedores mot
	    ON mot.id_fornecedor = r.id_motorista
	LEFT JOIN cidades c
	    ON r.id_origem = c.id_cidade	
	LEFT JOIN cliente rem
		ON rem.codigo_cliente = nf.remetente_id
	LEFT JOIN cliente dest
		ON dest.codigo_cliente = nf.destinatario_id

WHERE 
	--c.uf = '{}'
	--AND nf.numero_nota_fiscal like '%{}%'
	data_saida::date = '2020-10-20'
	AND r.tipo_destino = 'D'
	AND r.cancelado = 0
	AND (rem.cnpj_cpf = '{{cnpj_cliente}}' OR dest.cnpj_cpf = '{{cnpj_cliente}}')-- Se acesso raiz for igual 0
	AND (rem.cnpj_cpf LIKE '%{{cnpj_cliente}}%' OR dest.cnpj_cpf = '%{{cnpj_cliente}}%')-- Se acesso raiz for igual 1, usa apenas os 8 primeiros numeros
	--AND r.numero_romaneio = '0080010036635'
	--AND reg.id_cidade_polo = 3308
	        	       
GROUP BY 
	r.data_saida::date, 
	r.id_motorista, 
	r.placa_veiculo,	
	mot.nome_razao,
	c.nome_cidade




--------------------------------------------------------------
	
		SELECT 
	                cidades.id_cidade,
	                cidades.nome_cidade
	
                FROM 
	                regiao
	                LEFT JOIN cidades 
		                ON cidades.id_cidade = regiao.id_cidade_polo
		        RIGHT JOIN scr_romaneios r
				ON r.id_origem = cidades.id_cidade

		WHERE cidades.id_cidade is not Null
                GROUP BY 
	                cidades.id_cidade,
	                cidades.nome_cidade

                ORDER BY cidades.nome_cidade
	