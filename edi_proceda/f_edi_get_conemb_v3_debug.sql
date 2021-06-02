
	WITH hora AS (
		SELECT now() as data_tempo
	),
	lista AS ( 
		SELECT unnest(ARRAY[299276]) as id
	),
	seniorlog AS (
		SELECT
			1::integer as tipo,
			CASE WHEN current_database() = 'softlog_seniorlog' THEN '001' ELSE NULL END::character(3) as codigo_filial,
			CASE WHEN current_database() = 'softlog_seniorlog' THEN '001' ELSE NULL END::character(3) as codigo_empresa
	),
	conemb AS (
		SELECT 		
			c.id_conhecimento,
			COALESCE(c.chave_cte,'') as chave_cte,
			COALESCE(prot_autorizacao_cte,'') as prot_autorizacao_cte,
			'322' as ident,					
			CASE WHEN tipo_documento = 1 THEN '57' ELSE '07' END::text as tipo_documento,
			f.razao_social as filial_emissora,			
			CASE WHEN c.tipo_documento = 2 THEN '' ELSE COALESCE(c.serie_doc,'') END::text as serie_conhecimento,			
			lpad(right(c.numero_ctrc_filial,7),12,'0') as numero_conhecimento,
			to_char(c.data_emissao, 'DDMMYYYY') as data_emissao,
			to_char(data_emissao,'DDMMYYYHHMISS') as data_recebimento_sefaz,
			CASE WHEN frete_cif_fob = 1 THEN 'C' ELSE 'F' END as condicao_frete,
			(peso::numeric(12,2) * 100)::integer as peso,
			(c.total_frete * 100)::integer as total_frete,			
			CASE WHEN c.tipo_imposto IN (6, 7, 8) THEN 'S' ELSE 'N' END::text as st,			
			CASE WHEN c.tipo_imposto IN (6, 7, 8) THEN '1' ELSE '2' END::text as st1,
			' '::text as espaco,
			f.cnpj as filial_cnpj,
			c.remetente_cnpj,
			c.consig_red_cnpj,
			'I'::text as acao_documento,
			CASE tipo_transporte 
				WHEN 1  THEN 'N'
				WHEN 2  THEN 'D'
				WHEN 3  THEN 'R'
				WHEN 5  THEN 'F'
				WHEN 6  THEN 'T'
				WHEN 12 THEN 'C'
				WHEN 14 THEN 'I'
				WHEN 16 THEN 'P'
					ELSE 'N'
			END::text as tipo_conhecimento,
			cod_operacao_fiscal as cfop,
			c.remetente_nome,			
			to_char(hora.data_tempo,'DDMMYY') as data,
			to_char(hora.data_tempo,'HH24MI') as hora,
			('CONEMB' || to_char(hora.data_tempo,'DDMMYY')) as ident_000,
			('CONEMB' || to_char(hora.data_tempo,'DDMMYYYY')) as ident_320,			
			('CON' || to_char(hora.data_tempo,'DDMMYYHH24MI')) as ident_320_stemac,		
			('CONHE' || to_char(hora.data_tempo,'DDMMHH24MI') || '1') as ident_320_simpress,	
			f.razao_social as transportadora,
			f.cnpj as transportadora_cnpj,
			0::integer as iss,
			CASE WHEN calculado_de_id_cidade = 3784 THEN '3000' ELSE '' END::text as info_fiscal_predileta,
			origem.cod_ibge as codigo_municipio_origem,
			destino.cod_ibge as codigo_municipio_destino,
			CASE 	WHEN c.calculado_de_id_cidade = c.calculado_ate_id_cidade 
				THEN (c.total_frete * (iss.aliquota/100)) * 100
				ELSE NULL
			END::integer as valor_iss,
			CASE 	WHEN c.calculado_de_id_cidade = c.calculado_ate_id_cidade 
				THEN  iss.aliquota * 100
				ELSE NULL
			END::integer as aliquota_iss,
			CASE 	WHEN c.calculado_de_id_cidade = c.calculado_ate_id_cidade 
				THEN  c.total_frete * 100
				ELSE NULL
			END::integer as bc_iss	
				
		FROM 				
			hora,			
			scr_conhecimento c
			--lista
			--RIGHT JOIN lista
			--	ON c.id_conhecimento = lista.id
			--LEFT JOIN v_scr_conhecimento_cf_conemb cf 
			--	ON cf.id_conhecimento = c.id_conhecimento
			LEFT JOIN seniorlog
				ON seniorlog.tipo = 1
			LEFT JOIN filial f 
				ON f.codigo_empresa = COALESCE(seniorlog.codigo_empresa,c.empresa_emitente) 
				AND f.codigo_filial = COALESCE(seniorlog.codigo_filial, c.filial_emitente)
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = COALESCE(seniorlog.codigo_empresa,c.empresa_emitente) 			
			LEFT JOIN cidades origem 
				ON origem.id_cidade = c.calculado_de_id_cidade
			LEFT JOIN cidades destino
				ON destino.id_cidade = c.calculado_ate_id_cidade
			LEFT JOIN imposto_aliquotas iss
				ON iss.tipo_imposto = 2 AND iss.id_cidade = c.calculado_de_id_cidade
		WHERE 			
			--EXISTS(SELECT 1 FROM lista WHERE lista.id = c.id_conhecimento)
			--ARRAY[c.id_conhecimento] <@ ARRAY[299276]
			--c.id_conhecimento IN( 299276,299277)
			--c.id_conhecimento IN (202422,202414,202294,202355,202395)
			c.id_conhecimento IN (4632606)
			
	) , 
	cf AS (
		SELECT 
			cf.id_conhecimento, 
			cf.valor_pagar,
			cf.valor_item,
			cf.id_tipo_calculo,
			cf.quantidade
		FROM 
			v_scr_conhecimento_cf cf			
		WHERE
			cf.id_conhecimento IN (4632606)		
	)
	,cf_conemb AS (
		SELECT 
			id_conhecimento,
          	    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 1 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS frete_peso,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = ANY (ARRAY[2, 19, 20, 21, 22, 23]) THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS frete_valor,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 16 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS sec_cat,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 18 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS itr,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 17 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS despacho,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = ANY (ARRAY[4, 5, 6]) THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS pedagio,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 15 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS valor_ademe,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 1000 THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS valor_icms,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 1000 THEN cf.valor_item * 100::numeric
			    ELSE 0.00
			END)::numeric(12,2) AS aliquota_icms,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = 1000 THEN cf.quantidade
			    ELSE 0.00
			END)::numeric(12,2) AS base_calculo_icms,
		    sum(
			CASE
			    WHEN cf.id_tipo_calculo = ANY (ARRAY[24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 100, 101, 102, 103, 104, 105, 106, 107, 108]) THEN cf.valor_pagar
			    ELSE 0.00
			END)::numeric(12,2) AS total_outras_despesas
		FROM 
			cf		
		GROUP BY 
			id_conhecimento
	)
	, t AS (
		SELECT 
			conemb.*,
			(cf.base_calculo_icms * 100)::integer as base_calculo_icms,
			(cf.aliquota_icms * 100)::integer as aliquota_icms,
			(cf.valor_icms * 100)::integer as valor_icms,			
			(COALESCE(cf.frete_peso,0) * 100)::integer as frete_peso,
			(COALESCE(cf.frete_valor,0) * 100)::integer as frete_valor,
			(COALESCE(cf.sec_cat,0) * 100)::integer as sec_cat,
			(cf.itr * 100)::integer as itr,
			(cf.despacho * 100)::integer as despacho,
			(cf.pedagio * 100)::integer as pedagio,
			(cf.valor_ademe * 100)::integer as gris,
			(COALESCE(cf.total_outras_despesas,0) * 100)::integer as outras_despesas	
		FROM 
			conemb
			LEFT JOIN cf_conemb cf
				ON cf.id_conhecimento = conemb.id_conhecimento
			
	), 
	t2 AS (
		SELECT 
			nf.id_conhecimento,
			(((row_number() over (partition by nf.id_conhecimento order by nf.numero_nota_fiscal))-1)/40)::integer as grupo,
			rpad(nf.serie_nota_fiscal,3,' ') as serie_nota_fiscal,
			nf.numero_nota_fiscal,
			nf.numero_pedido_nf,
			nf.numero_romaneio_nf,	
			nf.chave_nfe,		
			(COALESCE(nf.valor_total_produtos,0) * 100)::integer as valor_total_produtos			
		FROM
			scr_conhecimento_notas_fiscais nf
			LEFT JOIN t ON t.id_conhecimento = nf.id_conhecimento
		WHERE
			EXISTS (
				SELECT 1
				FROM t
				WHERE t.id_conhecimento = nf.id_conhecimento
			)		
	),
	totais_produtos AS (
		SELECT 
			id_conhecimento,
			SUM(valor_total_produtos) as valor_total_produtos,
			MAX(numero_pedido_nf) as numero_pedido_nf,
			MAX(numero_romaneio_nf) as numero_romaneio_nf
		FROM
			t2
		GROUP BY 
			id_conhecimento			
	),
	t3 AS (
		SELECT 
			grupo,		
			id_conhecimento,
			last_value(grupo) over (partition by id_conhecimento) as ultimo_grupo,
			rpad(
				string_agg(
					serie_nota_fiscal || right(numero_nota_fiscal,8),
					'' order by grupo, numero_nota_fiscal
				),
				440,
				'   00000000'
			) as lst_nf_8,
			rpad(
				string_agg(
					rpad(ltrim(serie_nota_fiscal,'0'),3,' ') || right(numero_nota_fiscal,8),
					'' order by grupo, numero_nota_fiscal
				),
				440,
				'   00000000'
			) as lst_nf_8_marilan,
			rpad(
				string_agg(
					rpad(ltrim(serie_nota_fiscal,'0'),3,' ') || numero_nota_fiscal,
					'' order by grupo, numero_nota_fiscal
				),
				480,
				'   000000000'
			) as lst_nf_9_coty,
			rpad(
				string_agg(
					rpad(serie_nota_fiscal,3,'0') || numero_nota_fiscal,
					'' order by grupo, numero_nota_fiscal
				),
				480,
				' '
			) as lst_nf_9,
			rpad(
				string_agg(
					rpad(trim(leading from serie_nota_fiscal,'0'),3,' ') || numero_nota_fiscal,
					'' order by grupo, numero_nota_fiscal
				),
				480,
				' '
			) as lst_nf_9s,
			rpad(string_agg(' ' || chave_nfe,'' order by grupo, chave_nfe),900,	' ') as lst_chaves_nfe
		FROM
			t2
		GROUP BY 
			grupo,
			id_conhecimento		
	),
	reg_329 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as registro, id_conhecimento, grupo FROM (
				SELECT
					'329'::text as ident,
					t.remetente_cnpj,										
					t.id_conhecimento,
					t.chave_cte,
					t.outras_despesas,					
					t.iss,
					t.tipo_documento,
					t.prot_autorizacao_cte,
					t.consig_red_cnpj,
					CASE WHEN t.tipo_documento = '07' THEN '55' ELSE t.tipo_documento END as tipo_documento_marilan,					
					' '::text as espaco,
					max(t3.grupo) as grupo,
					info_fiscal_predileta
				FROM 
					t
					LEFT JOIN t3 ON t3.id_conhecimento = t.id_conhecimento
				GROUP BY 
					t.id_conhecimento,
					t.chave_cte,
					t.outras_despesas,
					t.iss,
					t.tipo_documento,
					t.prot_autorizacao_cte,
					t.consig_red_cnpj,
					t.info_fiscal_predileta,
					t.remetente_cnpj					
					
			) row
		) 
		SELECT
			array_agg(registro) as json_329, id_conhecimento, grupo
		FROM 
			temp
		GROUP BY 
			id_conhecimento, grupo
	),	
	reg_322 AS (	
		WITH temp AS (
			SELECT  row_to_json(row,true) as registro, id_conhecimento, grupo, '321'::text as reg_pai FROM (
				SELECT 			
					t.id_conhecimento,
					t.tipo_documento,
					t.chave_cte,
					t.prot_autorizacao_cte,
					t.ident,
					t.filial_emissora,
					t.serie_conhecimento,
					ltrim(t.numero_conhecimento,'0') as numero_conhecimento,
					t.numero_conhecimento as numero_conhecimento_z,
					t.data_emissao,
					t.data_recebimento_sefaz,
					t.condicao_frete,
					t.peso,
					t.total_frete,
					COALESCE(t.bc_iss, t.base_calculo_icms) as base_calculo_icms,
					COALESCE(t.aliquota_iss, t.aliquota_icms) as aliquota_icms,
					COALESCE(t.valor_iss, t.valor_icms) as valor_icms,
					t.frete_peso,
					t.frete_valor,
					t.sec_cat,
					t.itr,
					t.despacho,
					t.pedagio,
					t.gris,
					t.st,
					t.st1,
					t.filial_cnpj,
					t.remetente_cnpj,
					t.consig_red_cnpj,
					t.tipo_conhecimento,
					t.cfop,
					t.espaco,
					t.acao_documento,
					t.codigo_municipio_origem,
					t.codigo_municipio_destino,
					CASE WHEN t3.ultimo_grupo = t3.grupo THEN 'U' ELSE 'C' END as continuacao,
					CASE WHEN t3.ultimo_grupo = t3.grupo THEN ' ' ELSE 'C' END as continuacao_marilan,
					t3.lst_nf_8,
					t3.lst_nf_8_marilan,
					t3.lst_nf_9,
					t3.lst_nf_9s,
					lst_nf_9_coty,
					lst_chaves_nfe,
					t3.grupo,
					tprod.valor_total_produtos,
					COALESCE(tprod.numero_pedido_nf,'') as numero_pedido_nf,
					CASE WHEN t.tipo_documento = '07' THEN '55' ELSE t.tipo_documento END as tipo_documento_marilan,										
					CASE 	WHEN t.tipo_documento = '57' 
						THEN t.serie_conhecimento 	
						ELSE 'NFS' 
					END::text as serie_marilan,
					CASE 	WHEN t.tipo_documento = '57' 
						THEN t.numero_conhecimento 	
						ELSE lpad(trim(COALESCE(tprod.numero_pedido_nf,'')),12,' ') 
					END::text as numero_marilan,
					COALESCE(reg_329.json_329,'{}'::json[]) as reg_329
				FROM 
					t
					LEFT JOIN t3 
						ON t.id_conhecimento = t3.id_conhecimento	
					LEFT JOIN totais_produtos
						ON t.id_conhecimento = totais_produtos.id_conhecimento
					LEFT JOIN reg_329 
						ON t.id_conhecimento = reg_329.id_conhecimento
							AND t3.grupo = reg_329.grupo
					LEFT JOIN totais_produtos tprod 
						ON tprod.id_conhecimento = t.id_conhecimento
				ORDER BY
					id_conhecimento,
					grupo
			)row 
		) SELECT array_agg(registro) as reg_322 FROM temp
	),
	reg_000 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_000  FROM (
				SELECT 		
					'000'::text as ident,
					t.transportadora as remetente,
					t.remetente_nome as destinatario,
					t.data,
					t.hora,
					t.ident_000,
					t.espaco
				FROM
					t
				GROUP BY 
					t.transportadora,
					t.remetente_nome,
					t.data,
					t.hora,
					t.ident_000,
					t.espaco
			) row
		) SELECT array_agg(json_000) as json_000 FROM temp
	),
	reg_320 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_320 FROM (
				SELECT 		
					'320'::text as ident,
					t.ident_320,
					ident_320_stemac,
					ident_320_simpress,
					t.espaco
				FROM
					t
				GROUP BY 
					t.ident_320,
					ident_320_stemac,
					ident_320_simpress,
					t.espaco
			) row
		) SELECT array_agg(json_320) as json_320 FROM temp
	),
	reg_321 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_321 FROM (
				WITH temp AS (
					SELECT 		
						'321'::text as ident,
						t.transportadora as razao_social,
						t.transportadora_cnpj as cnpj,
						t.espaco				
					FROM
						t,
						reg_322
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
					reg_322.reg_322
				FROM 
					temp, 
					reg_322		
					
			) row
		)
		SELECT array_agg(json_321) as json_321 FROM temp
	),
	reg_323 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_323 FROM 
			(
				SELECT 
					'323'::text as ident,
					count(*) as qt_ct,
					sum(total_frete) as valor_total_ct,
					''::text as espaco
				FROM
					t
			) row
		) 
		SELECT array_agg(json_323) as json_323 FROM temp
	)	
	SELECT row_to_json(row, true) as json_conemb 	
	FROM 
	(
		SELECT 
			reg_000.json_000 as reg_000,
			reg_320.json_320 as reg_320,
			reg_321.json_321 as reg_321,
			reg_323.json_323 as reg_323
		FROM 
			reg_000, 
			reg_320, 
			reg_321, 
			reg_323
	) row;
