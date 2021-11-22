-- Function: public.f_scr_get_dados_fiscais(json)

-- DROP FUNCTION public.f_scr_get_dados_fiscais(json);

CREATE OR REPLACE FUNCTION public.f_scr_get_dados_fiscais(dados json)
  RETURNS SETOF t_dados_fiscais AS
$BODY$
DECLARE
	
BEGIN	
	--PERFORM f_debug('Dados Imposto',dados::text);
	
	RETURN QUERY 
	WITH ent AS (
			SELECT '{
				"id": 7876,
				"tipo_operacao": 1,
				"tipo_documento": 1,
				"tipo_transporte": 6,
				"modal": 1,
				"frete_cif_fob": 1,
				"remetente_id": 1058,
				"destinatario_id": 7,
				"consignatario_id": 1058,
				"natureza_carga": "ALGODAO CONCENTRAL GRANEL",
				"filial_emitente": "002",
				"empresa_emitente": "002",
				"consumidor_final": 0,
				"calculado_de_id_cidade": 5151,
				"calculado_ate_id_cidade": 5300,
				"redespachador_id": null
			}
			'::json as j
	),		
	row_ent AS (
		SELECT 
			x.*
		FROM 
			ent,
			json_to_record(COALESCE(dados, j))
			as x(
				id integer,				
				tipo_operacao integer,
				tipo_documento integer,
				tipo_transporte integer,
				modal integer,
				frete_cif_fob integer,
				remetente_id integer,
				destinatario_id integer,
				consignatario_id integer,
				natureza_carga character(40),
				filial_emitente character(3),
				empresa_emitente character(3),
				consumidor_final integer,
				calculado_de_id_cidade integer,
				calculado_ate_id_cidade integer,
				redespachador_id integer,
				par_tipo_imposto integer,
				par_tipo_contribuinte text,
				par_st integer
			)
	),	
	parametros AS (
		SELECT 
			ent.id,
			ent.tipo_operacao, 
			ent.tipo_documento,
			ent.tipo_transporte,
			ent.modal,
			ent.frete_cif_fob,
			ent.par_tipo_imposto,
			pag.codigo_cliente,
			pag.repasse_credito_presumido,
			ent.natureza_carga,
			pag.optante_simples,
			filial.aliq_inter_cif,
			origem.uf as uf_origem_calculo,
			destino.uf as uf_destino_calculo,
			origem_filial.uf as filial_uf,
			CASE 	WHEN ent.tipo_operacao = 1 
				THEN origem_filial.uf  	--Transporte
				ELSE red_cid.uf 	--Embarcador 
			END::character(2) as uf_emitente,
			COALESCE(dp.valor_parametro,dest.tipo_contribuinte) as tipo_contribuinte,
			COALESCE(pag.classificacao_fiscal,'COMERCIO')::text as pagador_classificacao_fiscal,
			CASE 
				WHEN origem.uf IN ('MG') AND destino.uf IN ('MG') 
					AND pag.optante_simples = 1 
				THEN 'S' 
				ELSE NULL 
			END::character(1) as cont_mg,	
			CASE 
				WHEN 
					ent.frete_cif_fob = 2 
					AND ent.consumidor_final = 1
					AND COALESCE(par_tipo_contribuinte, pp.valor_parametro, pag.tipo_contribuinte) = 'N'
					AND origem.uf <> destino.uf
					AND filial.recolhe_difal = 1

					
				THEN
					1
				WHEN 
					filial.aliq_inter_cif = 1 
					AND ent.frete_cif_fob = 1
					AND ent.consumidor_final = 1
					AND COALESCE(par_tipo_contribuinte, pp.valor_parametro, pag.tipo_contribuinte) = 'N'
					AND origem.uf <> destino.uf
					AND filial.recolhe_difal = 1
				THEN 
					1
				ELSE
					0
			END::integer tem_difal,				
			CASE
				WHEN    pag.substituto_tributario = 1 
					AND ent.frete_cif_fob = 1 THEN 1
				ELSE 0
			END AS st,
			f_get_aliq_inter(origem.uf, destino.uf,modal) as aliquota_inter,
			ufo.aliquota_interna as aliquota_interna_o,
			CASE 
				WHEN origem.uf IN ('MG') AND destino.uf IN ('MG') 
					AND pag.optante_simples = 1 
				THEN ufo.aliquota_interna_simples
				ELSE NULL 
			END::numeric(12,2) as aliquota_interna_simples,
			ufd.aliquota_interna as aliquota_interna_d,
			ufd.aliquota_fcp,
			filial.perc_credito_presumido_icms,
			ent.par_tipo_contribuinte,
			ent.par_st											
		FROM
			row_ent ent
			LEFT JOIN cidades origem 
				ON origem.id_cidade = ent.calculado_de_id_cidade
			LEFT JOIN estado ufo 
				ON ufo.id_estado = origem.uf

			LEFT JOIN cidades destino 
				ON destino.id_cidade = ent.calculado_ate_id_cidade
			LEFT JOIN estado ufd
				ON ufd.id_estado = destino.uf
			LEFT JOIN filial 
				ON filial.codigo_empresa = ent.empresa_emitente 
				AND filial.codigo_filial = ent.filial_emitente
			LEFT JOIN cidades origem_filial 
				ON origem_filial.id_cidade = filial.id_cidade
			LEFT JOIN cliente red 
				ON red.codigo_cliente = ent.redespachador_id
			LEFT JOIN cidades red_cid 
				ON red_cid.id_cidade = red.id_cidade
			LEFT JOIN cliente pag 
				ON pag.codigo_cliente = ent.consignatario_id
			LEFT JOIN cliente_parametros pp
				ON pag.codigo_cliente = pp.codigo_cliente 
					AND pp.id_tipo_parametro = 220
			LEFT JOIN cliente dest 
				ON dest.codigo_cliente = ent.destinatario_id				
			LEFT JOIN cliente_parametros dp
				ON dest.codigo_cliente = dp.codigo_cliente 
					AND dp.id_tipo_parametro = 220
	)
	, parametros_2 AS (
		SELECT 
			p.*,
			COALESCE(par_tipo_imposto,f_scr_tipo_imposto_cst(
				p.uf_origem_calculo,
				p.uf_destino_calculo,
				p.uf_emitente,
				p.modal,
				COALESCE(p.par_st, p.st),
				p.natureza_carga,
				COALESCE(p.par_tipo_contribuinte, p.cont_mg, p.tipo_contribuinte),
				p.tipo_transporte,
				p.tipo_documento,
				p.frete_cif_fob
			)) as tipo_imposto,
			f_scr_caso_operacao_frete(p.uf_origem_calculo,
						  p.uf_destino_calculo,
						  p.uf_emitente
			) as ind_operacao			
			
		FROM 
			parametros p			
	),
	config_icms AS (
		SELECT 			
			p.*,			
			COALESCE(aliquota_interna_simples, 
				f_scr_aliquota_icms_uf(
					1,
					p.ind_operacao,
					p.aliquota_interna_o,
					p.aliquota_interna_simples,
					p.aliquota_inter,
					p.tipo_imposto,
					COALESCE(p.par_tipo_contribuinte, p.tipo_contribuinte),
					p.tem_difal,
					p.aliq_inter_cif)
			)::numeric(6,2) as aliquota_icms,
			
			f_scr_aliquota_icms_uf(
				2,
				p.ind_operacao,
				p.aliquota_interna_o,
				p.aliquota_interna_simples,
				p.aliquota_inter,
				p.tipo_imposto,
				COALESCE(p.par_tipo_contribuinte,p.tipo_contribuinte),
				p.tem_difal,
				p.aliq_inter_cif)::numeric(6,2)
			as aliquota_icms_st,
			f_scr_get_perc_reducao_bc(
				p.tipo_imposto,
				0.00,
				p.natureza_carga)::numeric(12,2)
			as perc_base_calculo,
			f_scr_cfop_frete(
				p.uf_origem_calculo,
				CASE WHEN p.tipo_transporte = 24 THEN 'EX' ELSE p.uf_destino_calculo END,
				p.uf_emitente,
				p.pagador_classificacao_fiscal,
				p.tipo_imposto)::character(4)
			as cfop
		FROM 
			parametros_2 p
	)
	SELECT 
		id,
		tipo_imposto,
		aliquota_icms::numeric(5,2) as aliquota,
		aliquota_icms_st::numeric(5,2) as aliquota_icms_st,
		tem_difal as calcula_difal,
		COALESCE(aliquota_inter,0.00)::numeric(5,2) as aliq_icms_inter,
		COALESCE(aliquota_interna_d,0.00)::numeric(5,2) as aliq_icms_interna,
		aliquota_fcp,
		perc_base_calculo::numeric(5,2),
		CASE 	WHEN tipo_imposto IN (6,7,8) AND repasse_credito_presumido = 1
			THEN perc_credito_presumido_icms 
			ELSE 0.00 
		END::numeric(5,2) as perc_credito_presumido_icms,
		cfop,
		''::text as msg
	FROM 
		config_icms;	
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
