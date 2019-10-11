-- Function: public.f_scr_parametros_cotacao_frete(integer)

-- DROP FUNCTION public.f_scr_parametros_cotacao_frete(integer);

CREATE OR REPLACE FUNCTION public.f_scr_parametros_cotacao_frete(pIdCotacaoTabela integer)
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
				c.numero_tabela_frete as tabela_frete,
				c.calculado_de_id_cidade,
				c.calculado_ate_id_cidade,
				c.total_frete_origem,
				c.natureza_carga, 
				c.qtd_nf,
				c.peso,
				c.qtd_volumes,
				c.valor_cubico as volume_cubico,
				c.valor_nota_fiscal,
				c.valor_total_produtos, 
				c.aliquota,
				c.perc_desconto,
				c.isento_imposto,
				CASE WHEN c.imposto_incluso = 1 THEN 1 ELSE 0 END as imposto_incluso,
				c.escolta_horas_entrega,
				c.escolta_horas_coleta,
				c.coleta_escolta::integer as coleta_escolta, 
				c.coleta_expresso::integer as coleta_expresso, 
				c.coleta_emergencia::integer as coleta_emergencia, 
				c.coleta_normal::integer as coleta_normal, 
				c.entrega_escolta::integer as entrega_escolta, 
				c.entrega_expresso::integer as entrega_expresso, 
				c.entrega_emergencia::integer as entrega_emergencia, 
				c.entrega_normal::integer as entrega_normal, 
				c.taxa_dce::integer as taxa_dce, 
				c.taxa_exclusivo::integer as taxa_exclusivo, 
				c.coleta_dificuldade::integer as coleta_dificuldade, 
				c.entrega_dificuldade::integer as entrega_dificuldade, 
				c.entrega_exclusiva::integer as entrega_exclusiva, 
				c.coleta_exclusiva::integer as coleta_exclusiva,
				1::integer as modo_calculo,
				0.00::numeric(5,2) as perc_desc_calculo,
				c.tipo_veiculo as id_tipo_veiculo,
				c.km_rodado
			FROM 
				scr_cotacao_tabela_frete c				
			WHERE 
				c.id_cotacao_tabela_frete = pIdCotacaoTabela
				--c.id_conhecimento = 49
						
		) row 
	) SELECT parametros INTO vParametros FROM t1;

	RETURN vParametros;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

