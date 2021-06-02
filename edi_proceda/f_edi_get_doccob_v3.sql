-- Function: public.f_edi_get_doccob_v3(integer[])
-- SELECT f_edi_get_doccob_v3('{8337}') as dados
-- SELECT * FROM edi_tms_docs oRDER BY 1
-- DROP FUNCTION public.f_edi_get_doccob_v3(integer[]);

CREATE OR REPLACE FUNCTION public.f_edi_get_doccob_v3(lst_faturas integer[])
  RETURNS json AS
$BODY$
DECLARE
	v_resultado json;
	str_sql text;
	v_cursor refcursor;
	v_id text;
BEGIN

	v_id = array_to_string(lst_faturas,',');

	
	--SELECT * FROM scr_faturamento LIMIT 1
	str_sql = 'WITH hora AS (
		SELECT now() as data_tempo
	),
	seniorlog AS (
		SELECT 
			1::integer as tipo,
			CASE WHEN current_database() = ''softlog_seniorlog'' THEN ''001'' ELSE NULL END::character(3) as codigo_filial,
			CASE WHEN current_database() = ''softlog_seniorlog'' THEN ''001'' ELSE NULL END::character(3) as codigo_empresa
	),
	t AS (
		SELECT 	
			fat.id_faturamento, 	
			''352''::text as ident,
			''0''::text as tipo_documento,
			lpad((RIGHT(fat.numero_fatura,7)),10,''0'') as numero_documento, 	
			to_char(COALESCE(fat.data_emissao,fat.data_processamento),''DDMMYYYY'') as data_emissao,			
			''''::text as serie_documento,
			to_char(fat.data_vencimento, ''DDMMYYYY'') as data_vencimento, 	
			(fat.valor_fatura * 100)::integer as valor_fatura, 	
			(CASE 
				WHEN fat.fatura_banco IS NULL 
					THEN ''CAR'' 
					ElSE ''BCO'' 
			END)::character(3) as tipo_cobranca, 	
			COALESCE(fat.imposto*100,0)::integer as valor_icms,			
			(fat.juros * 100)::integer as valor_juros_dia, 	
			COALESCE(to_char(fat.data_lim_desconto,''DDMMYYYY''),''00000000'') as data_limite_desconto,			
			(fat.desconto * 100)::integer as valor_desconto, 	
			COALESCE(banco.nome_banco,'''') as agente_cobranca, 	
			0::integer as numero_agencia, 	
			''''::text as digito_agencia,
			0::integer as numero_conta, 	
			''''::text as digito_conta,
			fatura_conta_corrente,
			''I''::text as acao_documento,
			f.razao_social as filial_emissora,
			fat.fatura_nome as remetente_nome, 
			to_char(hora.data_tempo,''DDMMYY'') as data,
			to_char(hora.data_tempo,''HH24MI'') as hora,
			(''DOCCOB'' || to_char(hora.data_tempo,''DDMMYY'')) as ident_000,
			(''COB'' || to_char(hora.data_tempo,''DDMMHH24MI'') || ''0'') as ident_000_sugestao,
			(''DOCCOB'' || to_char(hora.data_tempo,''DDMMYYYY'')) as ident_350,
			(''COB'' || to_char(hora.data_tempo,''DDMMYYHH24MI'')) as ident_350_stemac,
			(''COBRA'' || to_char(hora.data_tempo,''DDMMHH24MI'') || ''0'') as ident_350_sugestao,
			empresa.razao_social as transportadora,
			empresa.cnpj as transportadora_cnpj,
			''''::text as espaco
		FROM 	
			hora,						
			scr_faturamento fat	
			LEFT JOIN seniorlog 
				ON seniorlog.tipo = 1
			LEFT JOIN banco 
				ON fat.fatura_banco = banco.numero_banco			
			LEFT JOIN filial f 
				ON f.codigo_empresa = COALESCE(seniorlog.codigo_empresa,fat.codigo_empresa) 
				AND f.codigo_filial = COALESCE(seniorlog.codigo_filial, fat.codigo_filial)
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = COALESCE(seniorlog.codigo_empresa,fat.codigo_empresa) 
		WHERE 
			--ARRAY[fat.id_faturamento] <@ ''{2245,2182,2126}''::integer[]
			fat.id_faturamento IN (' || v_id || ')
			--ARRAY[fat.id_faturamento] <@ lst_faturas
			
	),	
	c as (
		SELECT 	
			''353''::text as ident,
			c.id_conhecimento, 	
			t.id_faturamento,
			CASE WHEN c.tipo_documento = 2 THEN '''' ELSE COALESCE(c.serie_doc,'''') END::text as serie_conhecimento,			
			lpad(right(c.numero_ctrc_filial,7),12,''0'') as numero_conhecimento,
			filial.nome_descritivo as filial_emissora, 	
			c.remetente_cnpj, 	
			c.destinatario_cnpj,
			filial.cnpj as filial_cnpj,
			--filial.razao_social as filial_emissora,			
			(c.total_frete * 100)::integer as valor_frete,
			to_char(c.data_emissao,''DDMMYYYY'') as data_emissao,	
			CASE 	WHEN c.calculado_de_id_cidade = c.calculado_ate_id_cidade 
				THEN (c.total_frete * (iss.aliquota/100)) 
				ELSE 0.00
			END::integer as valor_iss,
			(COALESCE(icms_st,0.00) + COALESCE(imposto,0.00)) as valor_icms,
			c.chave_cte,
			0::integer as zeros,
			'' ''::text as espaco
		FROM 	
			t
			LEFT JOIN scr_conhecimento c 
				ON c.id_faturamento = t.id_faturamento
			LEFT JOIN filial 
				ON c.filial_emitente = filial.codigo_filial 
					AND c.empresa_emitente = filial.codigo_empresa	
			LEFT JOIN imposto_aliquotas iss
				ON iss.tipo_imposto = 2 AND iss.id_cidade = c.calculado_de_id_cidade
	),
	imposto AS (
		SELECT 
			id_faturamento,
			SUM(valor_icms + valor_iss) as valor_icms 
		FROM 
			c
		GROUP BY id_faturamento
	)
	,nf as (
		SELECT 	
			c.id_conhecimento,
			''354''::text as ident,
			c.remetente_cnpj,
			c.destinatario_cnpj,
			c.filial_cnpj,
			right(nf.numero_nota_fiscal,8) as numero_nota_fiscal, 	
			numero_nota_fiscal as numero_nota_fiscal_9,
			rpad(COALESCE(nf.serie_nota_fiscal,''''),3,'' '') as serie_nota_fiscal, 	
			rpad(COALESCE(ltrim(nf.serie_nota_fiscal,''0''),''''),3,'' '') as serie_nota_fiscal_2,
			(nf.valor_total_produtos * 100)::integer as valor_mercadoria, 	
			to_char(nf.data_nota_fiscal,''DDMMYYYY'') as data_emissao,
			(nf.peso::numeric(12,2) * 100)::integer as peso,
			'' ''::text as espaco 
		FROM 	
			c
			LEFT JOIN scr_conhecimento_notas_fiscais nf
				ON c.id_conhecimento = nf.id_conhecimento
		
	),
	reg_354 AS (
		WITH temp AS (
			SELECT row_to_json (row,true) as registro, id_conhecimento FROM (
				SELECT 
					nf.ident,
					nf.id_conhecimento,
					nf.serie_nota_fiscal,
					nf.serie_nota_fiscal_2,
					nf.numero_nota_fiscal,
					nf.numero_nota_fiscal_9,
					nf.data_emissao,
					nf.peso,
					nf.valor_mercadoria,
					nf.remetente_cnpj,
					nf.destinatario_cnpj,
					nf.filial_cnpj,
					nf.espaco
				FROM 
					nf				
				ORDER BY
					nf.id_conhecimento
			) row
		) 
		SELECT 
			array_agg(registro) as json_354, 
			id_conhecimento 
		FROM 
			temp
		GROUP BY id_conhecimento
	),
	reg_353 AS (		
		WITH temp AS (
			SELECT row_to_json (row,true) as registro, id_faturamento FROM (
				SELECT 
					c.ident,
					c.id_conhecimento,
					c.id_faturamento,
					c.filial_emissora,
					c.serie_conhecimento,
					c.numero_conhecimento,
					lpad(c.numero_conhecimento,12,''0'') as numero_conhecimento_z,
					c.valor_frete,
					c.data_emissao,
					c.remetente_cnpj,
					c.destinatario_cnpj,
					c.filial_cnpj,
					c.chave_cte,
					c.zeros,
					c.espaco,
					reg_354.json_354 as reg_354
				FROM 
					c
					LEFT JOIN reg_354
						ON reg_354.id_conhecimento = c.id_conhecimento
				ORDER BY
					numero_conhecimento
			) row
		) 
		SELECT 
			array_agg(registro) as json_353, 
			id_faturamento
		FROM 
			temp
		GROUP BY id_faturamento
	),
	reg_352 AS (
		WITH temp AS (
			SELECT row_to_json (row,true) as registro FROM (
				SELECT 
					t.ident,
					t.id_faturamento,
					t.filial_emissora,
					t.tipo_documento,
					t.serie_documento,
					t.numero_documento,
					t.data_emissao,
					t.data_vencimento,
					t.valor_fatura,
					t.tipo_cobranca,
					(COALESCE(imposto.valor_icms,0) * 100)::integer as valor_icms,
					t.valor_juros_dia,
					t.data_limite_desconto,
					t.valor_desconto,
					t.agente_cobranca,
					t.numero_agencia,
					0::integer as digito_agencia_2,
					t.digito_agencia,
					t.numero_conta,
					t.digito_conta,
					0::integer as digito_conta_2,
					t.acao_documento,
					t.espaco,		
								
					reg_353.json_353 as reg_353
				FROM 
					t
					LEFT JOIN reg_353
						ON reg_353.id_faturamento = t.id_faturamento
					LEFT JOIN imposto
						ON imposto.id_faturamento = t.id_faturamento
				ORDER BY
					numero_documento
			) row
		) 
		SELECT 
			array_agg(registro) as json_352
		FROM 
			temp
	),
	reg_000 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_000  FROM (
				SELECT 		
					''000''::text as ident,
					t.transportadora as remetente,
					t.remetente_nome as destinatario,
					t.data,
					t.hora,
					t.ident_000,
					t.ident_000_sugestao,					
					t.espaco
				FROM
					t
				GROUP BY 
					t.transportadora,
					t.remetente_nome,
					t.data,
					t.hora,
					t.ident_000,
					t.ident_000_sugestao,
					t.espaco
			) row
		) SELECT array_agg(json_000) as json_000 FROM temp
	),
	reg_350 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_350 FROM (
				SELECT 		
					''350''::text as ident,
					t.ident_350,
					t.ident_350_sugestao,
					t.ident_350_stemac,
					t.espaco
				FROM
					t
				GROUP BY 
					t.ident_350,
					t.ident_350_sugestao,
					t.ident_350_stemac,
					t.espaco
			) row
		) SELECT array_agg(json_350) as json_350 FROM temp
	),
	reg_351 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_351 FROM (
				WITH temp AS (
					SELECT 		
						''351''::text as ident,
						t.transportadora as razao_social,						
						t.transportadora_cnpj as cnpj,
						t.espaco						
					FROM
						t
					GROUP BY 
						t.transportadora,
						t.transportadora_cnpj,		
						t.espaco
				)
				SELECT 
					ident,
					razao_social,
					cnpj,
					espaco,
					reg_352.json_352 as reg_352
				FROM 
					temp, 
					reg_352		
					
			) row
		)		
		SELECT array_agg(json_351) as json_351 FROM temp
	),
	reg_355 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_355 FROM 
			(
				SELECT 
					''355''::text as ident,
					count(*) as qt_docs,
					sum(valor_fatura) as valor_total_docs,
					''''::text as espaco
				FROM
					t
			) row
		) 
		SELECT array_agg(json_355) as json_355 FROM temp
	)	
	SELECT row_to_json(row, true) as json_conemb 
	
	FROM 
	(
		SELECT 
			reg_000.json_000 as reg_000,
			reg_350.json_350 as reg_350,
			reg_351.json_351 as reg_351,
			reg_355.json_355 as reg_355
		FROM 
			reg_000, 
			reg_350, 
			reg_351, 
			reg_355
	) row;';

	RAISE NOTICE '%', str_sql;

	OPEN v_cursor FOR EXECUTE str_sql;

	FETCH v_cursor INTO v_resultado;

	CLOSE v_cursor;
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

