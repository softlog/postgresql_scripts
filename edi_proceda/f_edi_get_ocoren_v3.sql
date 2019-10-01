-- Function: public.f_edi_get_ocoren_v3(integer[])
-- DROP FUNCTION public.f_edi_get_ocoren_v3(integer[]);
CREATE OR REPLACE FUNCTION public.f_edi_get_ocoren_v3(lst_conhecimentos integer[])
  RETURNS json AS
$BODY$
DECLARE
	v_operacao_por_nota text;
	v_resultado json;
	str_sql text;
	v_cursor refcursor;
	v_id text;
BEGIN

	SELECT 	COALESCE(MAX(valor_parametro),'0')
	INTO 	v_operacao_por_nota 
	FROM 	parametros 
	WHERE 	upper(cod_parametro) = 'PST_OPERACAO_POR_NOTA';	

	v_id = array_to_string(lst_conhecimentos,',');

	str_sql = 'WITH hora AS (
		SELECT now() as data_tempo
	),
	t AS (		
	SELECT 	
		1::integer as id,
		1::integer as operacao,	
		c.id_conhecimento,
		nf.id_conhecimento_notas_fiscais,
		''342'' as ident,		
		right(nf.numero_nota_fiscal,8) as numero_nota_fiscal,
		nf.numero_nota_fiscal as numero_nota_fiscal_9,
		rpad(COALESCE(trim(leading from nf.serie_nota_fiscal,''0''),''''),3,'' '') AS serie_nota_fiscal, 	
		COALESCE(o.id_ocorrencia_proceda, o.codigo_edi,0) as cod_ocorrencia,
		to_char(c.data_digitacao,''DDMMYYYY'') as data_digitacao, 
		to_char(c.data_digitacao,''HHMI'') as hora_digitacao, 
		to_char(COALESCE(nf.data_ocorrencia,c.data_digitacao), ''DDMMYYYY'') as data_ocorrencia,
		to_char(COALESCE(nf.data_ocorrencia,c.data_digitacao), ''HHMI'') as hora_ocorrencia,
		CASE 
			WHEN COALESCE(o.codigo_edi,0) = 0 	THEN ''PROCESSO DE TRANSPORTE INICIADO''
			WHEN COALESCE(codigo_edi,0) IN (1,2)	THEN ''ENTREGA REALIZADA. RECEBIDA POR: '' || 
									COALESCE(TRIM(UPPER(c.nome_recebedor)),''Não Informado'') 		 
						ELSE LEFT(o.ocorrencia,70) 
		END::character(70) as observacao_livre, 
		COALESCE(obs.codigo_edi_obs,0)::integer as cod_observacao,
		(''OCOREN'' || to_char(hora.data_tempo,''DDMMYY'')) as ident_000,
		(''OCOREN'' || to_char(hora.data_tempo,''DDMMYYYY'')) as ident_320,
		(''OCO'' || to_char(hora.data_tempo,''DDMMYYHH24MI'')) as ident_320_stemac,
		to_char(hora.data_tempo,''DDMMYY'') as data,
		to_char(hora.data_tempo,''HH24MI'') as hora,
		empresa.razao_social as transportadora,
		empresa.cnpj as transportadora_cnpj,	
		f.razao_social as filial_emissora,
		f.cnpj as filial_cnpj,
		c.remetente_cnpj,
		c.remetente_nome,
		'' ''::text as espaco,
		lpad(right(c.numero_ctrc_filial,7),15,''0'') as numero_conhecimento,
		COALESCE(to_char(c.data_emissao, ''DDMMYYYY''),'''') as data_emissao,
		(c.total_frete * 100)::integer as total_frete,
		c.total_frete::text as total_frete2,
		nf.chave_nfe,
		trim(nf.numero_pedido_nf) as numero_pedido_nf
	FROM 	
		hora,
		scr_conhecimento_notas_fiscais nf
		LEFT JOIN scr_conhecimento c	
			ON nf.id_conhecimento = c.id_conhecimento 	
		LEFT JOIN scr_ocorrencia_edi 	o	
			ON nf.id_ocorrencia = o.codigo_edi 	
		LEFT JOIN scr_ocorrencia_obs_edi obs	
			ON nf.id_ocorrencia_obs = obs.codigo_edi_obs 
		LEFT JOIN filial f 
			ON f.codigo_empresa = c.empresa_emitente AND f.codigo_filial = c.filial_emitente
		LEFT JOIN empresa 
			ON empresa.codigo_empresa = c.empresa_emitente		

	WHERE 
		--ARRAY[nf.id_conhecimento_notas_fiscais] <@ ARRAY[12583,12682,12683,12684,12686,12818,12869]
		CASE 
			WHEN ''' || v_operacao_por_nota || ''' = ''0'' THEN 
				c.id_conhecimento IN (' || v_id || ')		
				--AND o.codigo_edi <> 0	
			ELSE
				1=2
		END 				
		AND 
		CASE 	WHEN current_database() = ''softlog_mgguinchos'' 
			THEN nf.id_ocorrencia <> 0
			ELSE 1=1 
		END
	UNION
	SELECT 	
		nfo.id_ocorrencia_nf as id,
		2::integer as operacao,
		nf.id_nota_fiscal_imp as id_conhecimento,
		nfo.id_ocorrencia_nf as id_conhecimento_notas_fiscais,
		''342'' as ident,
		right(nf.numero_nota_fiscal,8) as numero_nota_fiscal,
		nf.numero_nota_fiscal as numero_nota_fiscal_9,
		rpad(COALESCE(trim(leading from nf.serie_nota_fiscal,''0''),''''),3,'' '') AS serie_nota_fiscal, 	
		COALESCE(o.id_ocorrencia_proceda,o.codigo_edi,0) as cod_ocorrencia, 	
		to_char(nfo.data_registro,''DDMMYYYY'') as data_digitacao, 	
		to_char(nfo.data_registro,''HHMI'') as hora_digitacao, 	
		to_char(COALESCE(nfo.data_ocorrencia,nfo.data_registro), ''DDMMYYYY'') as data_ocorrencia,
		to_char(COALESCE(nfo.data_ocorrencia,nfo.data_registro), ''HHMI'') as hora_ocorrencia,
		CASE 
			WHEN nf.obs_ocorrencia IS NOT NULL 	THEN left(nfo.obs_ocorrencia,70)
			WHEN nfo.obs_ocorrencia IS NOT NULL 	THEN left(nfo.obs_ocorrencia,70)
			WHEN COALESCE(o.codigo_edi,0) = 0 	THEN ''PROCESSO DE TRANSPORTE INICIADO''
			WHEN COALESCE(codigo_edi,0) IN (1,2)	THEN ''ENTREGA REALIZADA. RECEBIDA POR: '' || 
									COALESCE(TRIM(UPPER(nf.nome_recebedor)),''Não Informado'') 		 
						ELSE LEFT(o.ocorrencia,70) 
		END::character(70) as observacao_livre, 	
		COALESCE(obs.codigo_edi_obs,0)::integer as cod_observacao,
		(''OCOREN'' || to_char(hora.data_tempo,''DDMMYY'')) as ident_000,
		(''OCOREN'' || to_char(hora.data_tempo,''DDMMYYYY'')) as ident_320,
		(''OCO'' || to_char(hora.data_tempo,''DDMMYYHH24MI'')) as ident_320_stemac,
		to_char(hora.data_tempo,''DDMMYY'') as data,
		to_char(hora.data_tempo,''HH24MI'') as hora,
		empresa.razao_social as transportadora,
		empresa.cnpj as transportadora_cnpj,		
		f.razao_social as filial_emissora,
		f.cnpj as filial_cnpj,
		c.cnpj_cpf as remetente_cnpj,
		c.nome_cliente as remetente_nome,
		'' ''::text as espaco,
		lpad(right(con.numero_ctrc_filial,7),15,''0'') as numero_conhecimento,
		COALESCE(to_char(con.data_emissao, ''DDMMYYYY''),'''') as data_emissao,
		(con.total_frete * 100)::integer as total_frete,
		con.total_frete::text as total_frete2,
		nf.chave_nfe,
		trim(nf.numero_pedido_nf) as numero_pedido_nf
	FROM 	
		hora,
		scr_notas_fiscais_imp_ocorrencias nfo 			
		LEFT JOIN scr_notas_fiscais_imp nf
			ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp
		LEFT JOIN cliente c
			ON c.codigo_cliente = nf.remetente_id
		LEFT JOIN scr_ocorrencia_edi 	o	
			ON nfo.id_ocorrencia = o.codigo_edi 	
		LEFT JOIN scr_ocorrencia_obs_edi obs	
			ON nf.id_ocorrencia_obs = obs.codigo_edi_obs 
		LEFT JOIN filial f 
			ON f.codigo_empresa = c.empresa_responsavel AND f.codigo_filial = nf.filial_emitente
		LEFT JOIN empresa 
			ON empresa.codigo_empresa = c.empresa_responsavel
		LEFT JOIN scr_conhecimento con
			ON con.id_conhecimento = nf.id_conhecimento
	WHERE 		
		--ARRAY[nf.id_conhecimento_notas_fiscais] <@ ARRAY[12583,12682,12683,12684,12686,12818,12869]
		--ARRAY[c.id_conhecimento] <@ lst_conhecimentos
		--lst_conhecimentos contem o id das ocorrencias da nota fiscal
		--ARRAY[nfo.id_ocorrencia_nf] <@ lst_conhecimentos		
		CASE 
			WHEN ''' || v_operacao_por_nota || ''' = ''1'' THEN 
				nfo.id_ocorrencia_nf IN (' || v_id || ')
				--AND o.codigo_edi <> 0
				AND CASE WHEN current_database() NOT IN (''softlog_assislog'') 
					 THEN o.ocorrencia_coleta = 0 AND o.publica = 1
					 ELSE 1=1
				END					
			ELSE
				1=2
		END 		
		
	ORDER BY 	
		1,2,3
	),	
	reg_342 AS (	
		WITH temp AS (
			SELECT  row_to_json(row,true) as registro, id_conhecimento FROM (
				SELECT 	
					t.id,
					t.id_conhecimento,
					t.ident,					
					t.filial_cnpj as filial_cnpj,
					t.remetente_cnpj,
					t.serie_nota_fiscal,
					lpad(trim(t.serie_nota_fiscal),3,''0'') as serie_nota_fiscal_z,
					t.numero_nota_fiscal,
					t.numero_nota_fiscal_9,
					t.cod_ocorrencia,
					t.data_ocorrencia,
					t.hora_ocorrencia,
					t.cod_observacao,
					t.chave_nfe,
					CASE 
						WHEN t.cod_ocorrencia = 0 AND current_database() = ''softlog_assislog'' THEN 
							''0200108'' ||  t.chave_nfe
						ELSE 
							COALESCE(t.observacao_livre,'''') 
					END::text as observacao_livre,
					left(COALESCE(t.observacao_livre,''''),70) as observacao_livre_2,
					t.espaco,
					t.numero_conhecimento,
					lpad(ltrim(t.numero_conhecimento,''0''),15,'' '') as numero_conhecimento2,
					COALESCE(t.data_emissao,'''') as data_emissao,
					t.total_frete,
					lpad(t.total_frete2,8,'' '') as total_frete2,
					''''::text as link_rastreamento,
					t.numero_pedido_nf
				FROM 
					t					
				ORDER BY
					numero_nota_fiscal					
			)row 
		) SELECT array_agg(registro) as reg_342 FROM temp
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
	reg_340 AS (
		WITH temp AS (
			SELECT row_to_json(row,true) as json_340 FROM (
				SELECT 		
					''340''::text as ident,
					t.ident_320,
					t.ident_320_stemac,
					t.espaco
				FROM
					t
				GROUP BY 
					t.ident_320,
					t.ident_320_stemac,
					t.espaco
			) row
		) SELECT array_agg(json_340) as json_340 FROM temp
	),
	reg_341 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_341 FROM (
				WITH temp AS (
					SELECT 		
						''341''::text as ident,
						t.transportadora as razao_social,
						t.transportadora_cnpj as cnpj,
						t.espaco				
					FROM
						t,
						reg_342
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
					reg_342.reg_342
				FROM 
					temp, 
					reg_342		
					
			) row
		)
		SELECT array_agg(json_341) as json_341 FROM temp
	)	
	SELECT row_to_json(row, true) as json_ocoren	
	FROM 
	(
		SELECT 
			reg_000.json_000 as reg_000,
			reg_340.json_340 as reg_340,
			reg_341.json_341 as reg_341			
		FROM 
			reg_000, 
			reg_340, 
			reg_341 
			
	) row';


	RAISE NOTICE '%', str_sql;
	OPEN v_cursor FOR EXECUTE str_sql;
	
	FETCH v_cursor INTO v_resultado;

	CLOSE v_cursor;
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
