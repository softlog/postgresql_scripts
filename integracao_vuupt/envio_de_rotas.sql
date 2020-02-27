 SELECT
            fr.id,
        	fr.id_romaneio,
            r.numero_romaneio,
            r.data_saida,
	       (r.data_saida + INTERVAL'24 hours') as data_fim,
        	string_agg(
            '{"type":"service","service_id":"' || fnf.id_integracao::text,'"},'
                )  || '"}' as lst_services,
        	count(*) as qt_nf,
        	SUM(CASE
        		WHEN fnf.enviado = 1
        		THEN 1
        		ELSE 0
        	END)::integer as qt_enviado,
        	SUM(CASE
        		WHEN fnf.enviado = 0
        		THEN 1
        		ELSE 0
        	END)::integer as qt_nao_enviado,
        	r.placa_veiculo,
        	CASE
        		WHEN v.porte IN (1,6) THEN 5
        		WHEN v.porte IN (2,4,5) THEN 4
        		ELSE 3
        	END::integer as tipo_veiculo_vuupt,
            v.id_vuupt as id_vuupt_veiculo,
            v.id_veiculo,
            m.cnpj_cpf as motorista_cpf,
            m.id_vuupt as id_vuupt_motorista,
            m.nome_razao as motorista_nome,            
            (fpy_primeira_palavra(trim(lower(m.nome_razao))) || LEFT(m.cnpj_cpf,3) || '@dng.com.br') as motorista_email

        FROM
        	fila_documentos_integracoes fr
        	LEFT JOIN fila_documentos_integracoes fnf
        		ON fnf.tipo_documento = 1 AND
        			fr.id_romaneio = fnf.id_romaneio
        	LEFT JOIN scr_romaneios r
        		ON fr.id_romaneio = r.id_romaneio
        	LEFT JOIN veiculos v
        		ON v.placa_veiculo = r.placa_veiculo
        	LEFT JOIN v_tipo_veiculo vt
        		ON v.porte = vt.codigo
            LEFT JOIN fornecedores m
                ON m.id_fornecedor = r.id_motorista
        WHERE
         	fr.enviado = 0
         	AND fr.pendencia = 0
         	AND fr.tipo_documento = 4
         	AND fr.tipo_integracao = 5
         	AND fnf.tipo_integracao = 5
         	AND fr.producao = 1
        GROUP BY
            m.id_fornecedor,
            fr.id,
            r.numero_romaneio,
            r.data_saida,
        	fr.id_romaneio,
        	r.placa_veiculo,
        	v.porte,
            v.id_vuupt,
            v.id_veiculo
         ORDER BY
            fr.id