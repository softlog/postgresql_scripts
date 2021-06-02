
CREATE TYPE public.t_consulta_entrega AS (
	destinatario text,
	numero_nota_fiscal character(9),
	numero_pedido_nf text,
	serie_nota_fiscal character(3),
	chave_cte character(44),
	chave_nfe character(44),
	data_emissao date,
	data_ocorrencia timestamp,
	data_previsao_entrega date,
	dias_atraso integer,
	entregue integer, 
	status integer,
	codigo_rastreamento text,
	ocorrencia text
);





/*    

	SELECT	
	        --rem.nome_cliente as remetente,
	        --rem.nome_cliente as remetente,
	        --rem.cnpj_cpf cnpj_cpf_remetente,
		--dest.cnpj_cpf as cnpj_cpf_destinatario,
		dest.nome_cliente as destinatario,
	        imp.numero_nota_fiscal,
	        imp.numero_pedido_nf,
	        imp.serie_nota_fiscal,
		imp.chave_cte, 
	        imp.chave_nfe,
	        imp.data_emissao,
	        imp.data_ocorrencia,
	        --CASE WHEN oco.codigo_edi IN (1,2) THEN imp.data_ocorrencia ELSE NULL END::date as data_entrega,
	        COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) as data_previsao_entrega,
	        CASE WHEN oco.codigo_edi IN (1,2) THEN 
			CASE WHEN COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) < imp.data_ocorrencia::date THEN
				 imp.data_ocorrencia::date - COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1)
			ELSE
				0
			END
		ELSE
			CASE WHEN COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1) < current_date THEN 
				 current_date - COALESCE(imp.data_previsao_entrega, imp.data_expedicao + 1)
			ELSE
				0
			END
		END::integer as dias_atraso,
	        CASE WHEN oco.codigo_edi IN (1,2) THEN 1 ELSE 0 END::integer as entregue,
	        imp.status,
		'01' || lpad(fd_get_id_banco_dados(current_database())::text,5,'0') ||
		lpad(imp.id_nota_fiscal_imp::text,12,'0') as codigo_rastreamento,
		oco.ocorrencia::character(50) as ocorrencia
        FROM 
	        scr_notas_fiscais_imp imp
		LEFT JOIN cliente rem
		    ON imp.remetente_id::integer = rem.codigo_cliente::integer
		LEFT JOIN cliente dest
		    ON imp.destinatario_id::integer = dest.codigo_cliente::integer
		LEFT JOIN scr_ocorrencia_edi oco 
		    ON oco.codigo_edi::integer = imp.id_ocorrencia::integer
		LEFT JOIN scr_conhecimento_notas_fiscais con 
		    ON con.id_conhecimento::integer = imp.id_conhecimento::integer
	
	WHERE 	(rem.cnpj_cpf = '05889907000177' OR dest.cnpj_cpf = '05889907000177')	
		and (oco.publica = 1 OR (current_database() = 'softlog_bsb' AND imp.id_ocorrencia = 0))
		AND imp.data_emissao BETWEEN '2020/11/20' AND '2020/11/27' 
		--AND oco.codigo_edi = 1  	
		AND imp.id_ocorrencia not in (1,2)
		AND con.id_ocorrencia not in (1,2)
		AND imp.id_romaneio IS NOT NULL
*/