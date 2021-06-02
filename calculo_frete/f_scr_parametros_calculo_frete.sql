-- Function: public.f_scr_parametros_calculo_frete(integer)
--SELECT * FROM cliente_tipo_parametros
--SELECT * FROM f_scr_parametros_calculo_frete(37);
-- DROP FUNCTION public.f_scr_parametros_calculo_frete(256);

CREATE OR REPLACE FUNCTION public.f_scr_parametros_calculo_frete(pidconhecimento integer)
  RETURNS json AS
$BODY$
DECLARE
	vIdConhecimento integer;
	vParametros json;
BEGIN	
	WITH t1 AS (
		SELECT row_to_json(row, true) as parametros
		FROM (	

			SELECT 
				c.tabele_frete as tabela_frete,
				c.calculado_de_id_cidade,
				c.calculado_ate_id_cidade,
				c.total_frete_origem,
				c.natureza_carga, 
				COUNT(*)::integer as qtd_nf,
				SUM(
					CASE 	WHEN COALESCE(cp.valor_parametro::integer,0) = 0 
						THEN nf.peso 
						ELSE nf.peso_liquido 
					END
				) as peso,
				SUM(nf.qtd_volumes) as qtd_volumes,
				SUM(nf.volume_cubico) as volume_cubico,
				SUM(nf.valor) as valor_nota_fiscal,
				SUM(nf.valor_total_produtos) as valor_total_produtos, 
				SUM((CASE WHEN c.tipo_imposto IN (6,7,8,9,10) THEN c.aliquota_icms_st ELSE c.aliquota END)) as aliquota,
				c.perc_reducao_base_calculo as perc_desconto,
				(CASE WHEN COALESCE(c.aliquota,0.00) = 0.00 AND COALESCE(c.aliquota_icms_st,0.00) = 0.00 THEN 1 ELSE 0 END)::integer as isento_imposto,
				(CASE WHEN imposto_incluso = 2 THEN 0 ELSE 1 END)::integer as imposto_incluso,
				(CASE WHEN c.tipo_imposto IN (6,7,8) AND cli.repasse_credito_presumido = 1 
					THEN filial.perc_credito_presumido_icms 
					ELSE 0.00 END) as perc_credito_icms_st,
				0::integer as escolta_horas_entrega,
				coleta_escolta::integer as coleta_escolta, 
				coleta_expresso::integer as coleta_expresso, 
				coleta_emergencia::integer as coleta_emergencia, 
				coleta_normal::integer as coleta_normal, 
				entrega_escolta::integer as entrega_escolta, 
				entrega_expresso::integer as entrega_expresso, 
				entrega_emergencia::integer as entrega_emergencia, 
				entrega_normal::integer as entrega_normal, 
				taxa_dce::integer as taxa_dce, 
				taxa_exclusivo::integer as taxa_exclusivo, 
				coleta_dificuldade::integer as coleta_dificuldade, 
				entrega_dificuldade::integer as entrega_dificuldade, 
				entrega_exclusiva::integer as entrega_exclusiva, 
				coleta_exclusiva::integer as coleta_exclusiva,
				1::integer as modo_calculo,
				COALESCE(c.perc_desconto,0.00) as perc_desc_calculo,
				c.id_tipo_veiculo,				
				c.dt_agenda_coleta as data_coleta,
				c.dt_agenda_entrega as data_entrega,
				pf.tipo_carga::integer as tipo_carga,
				c.tipo_transporte,
				COALESCE(c.vl_combinado,0.00)::numeric(12,2) as vl_combinado,
				COALESCE(c.vl_tonelada,0.00)::numeric as vl_tonelada,
				COALESCE(c.vl_percentual_nf, 0.00)::numeric as vl_percentual_nf,
				COALESCE(c.vl_frete_peso, 0.00)::numeric as vl_frete_peso,
				destinatario_id,
				c.remetente_id,
				c.km_rodado,
				c.qtd_ajudantes
			FROM 				
				scr_conhecimento c
				LEFT JOIN scr_conhecimento_notas_fiscais nf
					ON c.id_conhecimento =  nf.id_conhecimento 
					
				LEFT JOIN filial
					ON filial.codigo_filial = c.filial_emitente 
						AND filial.codigo_empresa = c.empresa_emitente
						
				LEFT JOIN cliente cli 
					ON cli.codigo_cliente = c.consig_red_id	
					
				LEFT JOIN cliente_parametros cp
					ON cli.codigo_cliente = cp.codigo_cliente 
						AND cp.id_tipo_parametro = 101	
										
				LEFT JOIN scr_pre_fatura_entregas pfe
					ON pfe.id_pre_fatura_entrega = c.id_pre_fatura_entrega
					
				LEFT JOIN scr_pre_faturas pf
					ON pf.id_pre_fatura = pfe.id_pre_fatura				
					
			WHERE 
				c.id_conhecimento = pidconhecimento
			--	c.id_conhecimento = 49
			GROUP BY 
				c.tabele_frete, 
				c.calculado_de_id_cidade, 
				c.calculado_ate_id_cidade, 
				c.total_frete_origem, 
				c.natureza_carga,
				c.tipo_imposto,
				c.perc_reducao_base_calculo,
				aliquota,
				aliquota_icms_st,
				imposto_incluso,
				coleta_escolta, 
				coleta_expresso, 
				coleta_emergencia, 
				coleta_normal, 
				entrega_escolta, 
				entrega_expresso, 
				entrega_emergencia, 
				entrega_normal, 
				taxa_dce, 
				taxa_exclusivo, 
				coleta_dificuldade, 
				entrega_dificuldade, 
				entrega_exclusiva, 
				coleta_exclusiva,
				c.perc_desconto,
				cli.repasse_credito_presumido,
				filial.perc_credito_presumido_icms,
				c.dt_agenda_coleta,
				c.dt_agenda_entrega,				
				c.id_tipo_veiculo,
				c.tipo_transporte,
				c.vl_combinado,
				c.vl_tonelada,
				c.vl_percentual_nf,
				c.vl_frete_peso,
				pf.tipo_carga,
				c.destinatario_id,
				c.remetente_id,
				c.km_rodado,
				c.qtd_ajudantes
			
		) row 
	) SELECT parametros INTO vParametros FROM t1;

	

	RETURN vParametros;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
