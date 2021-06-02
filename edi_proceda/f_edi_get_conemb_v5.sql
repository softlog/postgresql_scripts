-- Function: public.f_edi_get_conemb_v3(integer[])
-- SELECT * FROM  f_edi_get_conemb_v5('{237414,237413,237412,237411,237410}')
-- DROP FUNCTION public.f_edi_get_conemb_v3(integer[]);

--SELECT id_conhecimento, numero_ctrc_filial, remetente_nome FROM scr_conhecimento ORDER BY 1 DESC LIMIT 100


CREATE OR REPLACE FUNCTION public.f_edi_get_conemb_v5(lst_conhecimento integer[])
  RETURNS json AS
$BODY$
DECLARE
	v_resultado json;
	str_sql text;
	v_cursor refcursor;
	v_id text;
BEGIN

	
	v_id = array_to_string(lst_conhecimento,',');


	str_sql = 'WITH hora AS (
		SELECT now() as data_tempo
	),
	lista AS ( 
		SELECT unnest(ARRAY[299276]) as id
	),	
	conemb AS (
		SELECT 		
			c.id_conhecimento,
			COALESCE(c.chave_cte,'''') as chave_cte,
			COALESCE(prot_autorizacao_cte,'''') as prot_autorizacao_cte,
			''522'' as ident,					
			CASE WHEN tipo_documento = 1 THEN ''57'' ELSE ''07'' END::text as tipo_documento,
			f.razao_social as filial_emissora,
			COALESCE(trim(c.serie_doc),'''') as serie_conhecimento,
			lpad(right(c.numero_ctrc_filial,7),12,''0'') as numero_conhecimento,
			to_char(c.data_emissao, ''DDMMYYYY'') as data_emissao,
			to_char(data_emissao,''DDMMYYYHHMISS'') as data_recebimento_sefaz,
			CASE WHEN frete_cif_fob = 1 THEN ''C'' ELSE ''F'' END as condicao_frete,
			(peso::numeric(12,3) * 1000)::integer as peso,
			(peso_cubado::numeric(12,4) * 10000)::integer as peso_cubado,
			(volume_cubico::numeric(12,4) * 10000)::integer as peso_cubagem,
			(qtd_volumes::numeric(12,2) * 100)::integer as volumes,
			(c.total_frete * 100)::integer as total_frete,			
			CASE WHEN c.tipo_imposto IN (6, 7, 8) THEN ''S'' ELSE ''N'' END::text as st,			
			CASE WHEN c.tipo_imposto IN (6, 7, 8) THEN ''1'' ELSE ''2'' END::text as st1,
			'' ''::text as espaco,
			trim(f.cnpj) as filial_cnpj,
			c.remetente_cnpj,
			c.consig_red_cnpj,
			''I''::text as acao_documento,
			CASE tipo_transporte 
				WHEN 1  THEN ''N''
				WHEN 2  THEN ''D''
				WHEN 3  THEN ''R''
				WHEN 5  THEN ''F''
				WHEN 6  THEN ''T''
				WHEN 12 THEN ''C''
				WHEN 14 THEN ''I''
				WHEN 16 THEN ''P''
					ELSE ''N''
			END::text as tipo_conhecimento,
			cod_operacao_fiscal as cfop,
			trim(c.remetente_nome) as remetente_nome,
			to_char(hora.data_tempo,''DDMMYY'') as data,
			to_char(hora.data_tempo,''HH24MI'') as hora,
			(''CONEMB'' || to_char(hora.data_tempo,''DDMMYY'')) as ident_000,
			(''CONEMB'' || to_char(hora.data_tempo,''DDMMYYYY'')) as ident_520,			
			(''CON'' || to_char(hora.data_tempo,''DDMMYYHH24MI'')) as ident_520_stemac,		
			(''CONHE'' || to_char(hora.data_tempo,''DDMMHH24MI'') || ''1'') as ident_520_simpress,	
			CASE WHEN current_database() = ''softlog_bsb2'' THEN trim(f.razao_social) ELSE trim(empresa.razao_social) END::text as transportadora,
			CASE WHEN current_database() = ''softlog_bsb2'' THEN f.cnpj ELSE empresa.cnpj END::text as transportadora_cnpj,			
			trim(f.razao_social) as filial,
			0::integer as iss,
			CASE WHEN calculado_de_id_cidade = 3784 THEN ''3000'' ELSE '''' END::text as info_fiscal_predileta,
			cf.uf as uf_emissora,
			c.calculado_de_uf as uf_coleta,
			c.calculado_ate_uf as uf_destino,
			c.destinatario_cnpj,
			CASE WHEN c.tipo_transporte = 2 THEN c.destinatario_cnpj ELSE '''' END::text as cnpj_destino_devolucao,
			CASE WHEN c.tipo_transporte = 2 THEN '''' ELSE c.remetente_cnpj END::text as cnpj_destino,
			CASE WHEN c.tipo_transporte = 2 THEN c.destinatario_cnpj ELSE c.remetente_cnpj END::text as cnpj_emissor,
			''''::text consignatario_cnpj
		FROM 			
			hora,
			scr_conhecimento c
			--lista
			--RIGHT JOIN lista
			--	ON c.id_conhecimento = lista.id
			--LEFT JOIN v_scr_conhecimento_cf_conemb cf 
			--	ON cf.id_conhecimento = c.id_conhecimento
			LEFT JOIN filial f 
				ON f.codigo_empresa = c.empresa_emitente AND f.codigo_filial = c.filial_emitente
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = c.empresa_emitente	
			LEFT JOIN cidades cf
				ON cf.id_cidade = f.id_cidade
		WHERE 
			
			--EXISTS(SELECT 1 FROM lista WHERE lista.id = c.id_conhecimento)
			--ARRAY[c.id_conhecimento] <@ ARRAY[299276]
			--c.id_conhecimento IN( 299276,299277)
			--c.id_conhecimento IN (202422,202414,202294,202355,202395)
			c.id_conhecimento IN (' || v_id || ')
			
	), 
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
			cf.id_conhecimento IN (' || v_id || ')		
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
			t.remetente_cnpj,					
			rpad(nf.serie_nota_fiscal,3,'' '') as serie_nota_fiscal,
			ltrim(nf.serie_nota_fiscal,''0'') as serie_nota_fiscal_trim,
			nf.numero_nota_fiscal,
			to_char(nf.data_nota_fiscal, ''DDMMYYYY'') as data_emissao,
			nf.numero_pedido_nf,
			nf.numero_romaneio_nf,			
			(COALESCE(nf.valor,0) * 100)::integer as valor_nota_fiscal,
			(COALESCE(nf.qtd_volumes,0) * 100)::integer as qtd_volumes,
			(COALESCE(nf.peso::numeric(12,3),0) * 1000)::integer as peso_bruto,
			(COALESCE(nf.volume_cubico,0) * 10000)::integer as peso_cubagem,
			(COALESCE(nf.volume_cubico,0) * 300 * 10000)::integer as peso_cubado,
			(COALESCE(nf.valor_total_produtos,0) * 100)::integer as valor_total_produtos,
			CASE WHEN t.tipo_conhecimento = ''D'' THEN ''S'' ELSE ''N'' END as devolucao,
			CASE WHEN t.tipo_conhecimento = ''D'' THEN ''0'' ELSE ''1'' END as tipo_nota_fiscal,
			''N''::text as tem_bonificacao,
			t.uf_coleta as estado_gerador,
			COALESCE(cfop_pred_nf,'''') as cfop,
			''''::text as desdobro,
			COALESCE(numero_pedido_nf::text,'''') as notfis_505_23			
		FROM
			t
			LEFT JOIN  scr_conhecimento_notas_fiscais nf
				ON t.id_conhecimento = nf.id_conhecimento
	),
	reg_505_23 AS (
		SELECT 
			id_conhecimento,
			MAX(notfis_505_23) as notfis_505_23
		FROM 
			t2
		GROUP BY id_conhecimento	
	),	
	reg_524 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as registro, id_conhecimento FROM (
				SELECT
					''524''::text as ident,
					t2.id_conhecimento,
					t2.remetente_cnpj,
					t2.numero_nota_fiscal,
					t2.serie_nota_fiscal,
					t2.data_emissao,
					t2.valor_nota_fiscal,
					t2.qtd_volumes,
					t2.peso_bruto,
					t2.peso_cubagem,
					t2.peso_cubado,
					t2.notfis_505_23,
					''''::text as notfis_505_24,
					''''::text as notfis_505_25,
					''''::text as notfis_505_26,
					t2.devolucao,
					t2.tipo_nota_fiscal,
					t2.tem_bonificacao,
					t2.cfop,
					t2.estado_gerador,
					t2.desdobro,
					'' ''::text as espaco					
				FROM 
					t2
			) row
		) 
		SELECT
			array_agg(registro) as json_524, id_conhecimento
		FROM 
			temp
		GROUP BY 
			id_conhecimento
	),	
	reg_523 AS (
		WITH temp AS (
			SELECT row_to_json(row, true) as registro, id_conhecimento FROM (
				SELECT 
					''523''::text as ident,
					t.id_conhecimento,
					t.volumes,
					t.peso,
					t.peso_cubado,
					t.peso_cubagem,
					t.peso,
					t.total_frete,
					t.frete_peso,
					t.frete_valor,
					t.sec_cat,
					t.itr,
					t.despacho,
					t.pedagio,
					t.gris,
					t.st,
					t.st1,					
					t.outras_despesas,
					0::integer as desconto,
					''N''::text as indicador_desconto,
					CASE WHEN t.st = ''N'' THEN  t.base_calculo_icms ELSE 0 END as base_calculo_icms,
					CASE WHEN t.st = ''N'' THEN  t.aliquota_icms ELSE 0 END as aliquota_icms,
					CASE WHEN t.st = ''N'' THEN  t.valor_icms ELSE 0 END as valor_icms,
					CASE WHEN t.st = ''S'' THEN  t.base_calculo_icms ELSE 0 END as base_calculo_icms_st,
					CASE WHEN t.st = ''S'' THEN  t.aliquota_icms ELSE 0 END as aliquota_icms_st,
					CASE WHEN t.st = ''S'' THEN  t.valor_icms ELSE 0 END as valor_icms_st,
					0::integer as base_calculo_iss,
					0::integer as aliquota_iss,
					0::integer as valor_iss,
					0::integer as valor_ir,
					''''::text as direito_fiscal,
					''''::text as tipo_imposto,
					reg_524.json_524 as reg_524	
				FROM 
					t
					LEFT JOIN reg_524 
						ON reg_524.id_conhecimento = t.id_conhecimento
				ORDER BY
					id_conhecimento
			) row
	
		)
		SELECT
			array_agg(registro) as json_523, id_conhecimento
		FROM 
			temp
		GROUP BY 
			id_conhecimento
	),
	reg_522 AS (	
		WITH temp AS (
			SELECT  row_to_json(row,true) as registro, id_conhecimento FROM (
				SELECT 		
					''522''::text as ident,	
					t.id_conhecimento,
					t.tipo_documento,
					t.chave_cte,
					t.prot_autorizacao_cte,
					t.ident,
					t.filial_emissora,
					t.serie_conhecimento,
					t.transportadora_cnpj,
					ltrim(t.numero_conhecimento,''0'') as numero_conhecimento,
					t.numero_conhecimento as numero_conhecimento_z,
					t.data_emissao,
					t.data_recebimento_sefaz,
					t.condicao_frete,
					t.filial_cnpj,
					t.remetente_cnpj,
					t.consig_red_cnpj,
					t.tipo_conhecimento,
					t.cfop,
					t.espaco,
					t.acao_documento,										
					t.uf_emissora,
					t.uf_coleta,
					t.uf_destino,
					t.cnpj_destino,
					t.cnpj_emissor,
					t.cnpj_destino_devolucao,
					reg_505_23.notfis_505_23,
					''''::text as notfis_505_24,
					''''::text as notfis_505_25,
					''''::text as notfis_505_26,
					reg_523.json_523 as reg_523
				FROM 
					t
					LEFT JOIN reg_523
						ON t.id_conhecimento = reg_523.id_conhecimento							
					LEFT JOIN reg_505_23
						ON reg_505_23.id_conhecimento = t.id_conhecimento
				ORDER BY
					id_conhecimento
			)row 
		) SELECT array_agg(registro) as reg_522 FROM temp 
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
	reg_520 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_520 FROM (
				SELECT 		
					''520''::text as ident,
					t.ident_520,
					ident_520_stemac,
					ident_520_simpress,
					t.espaco
				FROM
					t
				GROUP BY 
					t.ident_520,
					ident_520_stemac,
					ident_520_simpress,
					t.espaco
			) row
		) SELECT array_agg(json_520) as json_520 FROM temp
	),
	reg_521 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_521 FROM (
				WITH temp AS (
					SELECT 		
						''521''::text as ident,
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
					reg_522.reg_522
				FROM 
					temp, 
					reg_522		
					
			) row
		)
		SELECT array_agg(json_521) as json_521 FROM temp
	),
	reg_529 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_529 FROM 
			(
				SELECT 
					''529''::text as ident,
					count(*) as qt_ct,
					sum(total_frete) as valor_total_ct,
					''''::text as espaco
				FROM
					t
			) row
		) 
		SELECT array_agg(json_529) as json_529 FROM temp
	)	
	SELECT row_to_json(row, true) as json_conemb 	
	FROM 
	(
		SELECT 
			reg_000.json_000 as reg_000,
			reg_520.json_520 as reg_520,
			reg_521.json_521 as reg_521,
			reg_529.json_529 as reg_529
		FROM 
			reg_000, 
			reg_520, 
			reg_521, 
			reg_529
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

