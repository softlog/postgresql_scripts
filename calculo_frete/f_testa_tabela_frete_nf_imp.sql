-- Function: public.f_testa_tabela_frete_nf_imp(integer, refcursor)
--SELECT id_nota_fiscal_imp, calculado_de_id_cidade, destinatario_id FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::integer = 128297
--SELECT f_testa_tabela_frete_nf_imp(138,'msg')
-- DROP FUNCTION public.f_testa_tabela_frete_nf_imp(integer, refcursor);

CREATE OR REPLACE FUNCTION public.f_testa_tabela_frete_nf_imp(
    idnotafiscalimp integer,
    msg refcursor)
  RETURNS json AS
$BODY$
DECLARE
	vMsg json;	
	cf refcursor;
	imposto refcursor;
	msg2 refcursor;	
	cLocal refcursor;
BEGIN		
	WITH t1 AS (
		SELECT row_to_json(row, true) as parametros
		FROM (		
			SELECT 
				trim(nf.numero_tabela_frete) as tabela_frete, 
				nf.calculado_de_id_cidade, 
				nf.calculado_ate_id_cidade, 
				0.00::numeric(12,2) as total_frete_origem, 
				trim(nf.natureza_carga) as natureza_carga,
				1::integer as qtd_nf,
				(CASE WHEN nf.usa_valor_presumido = 1 THEN nf.peso_presumido ELSE nf.peso END) as peso,
				(CASE WHEN nf.usa_valor_presumido = 1 THEN 0 ELSE nf.qtd_volumes END) as qtd_volumes,
				(nf.volume_cubico) as volume_cubico,
				(nf.valor) as valor_nota_fiscal,
				(nf.valor_total_produtos) as valor_total_produtos,
				0.00::numeric(12,2) as aliquota,
				0.00::numeric(12,2) as perc_base_calculo,
				1::integer as isento_imposto,
				0::integer as imposto_incluso,
				0::integer as escolta_horas_entrega,
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
				1::integer as modo_calculo,
				0.00::numeric(12,2) as perc_desc_calculo,
				dt_agenda_coleta,
				dt_agenda_entrega,												
				nf.tipo_transporte,
				COALESCE(nf.vl_frete_peso, 0.00)::numeric as vl_frete_peso,
				pf.id_tipo_veiculo,
				c.total_peso as peso_agregado_nf,
				c.total_volume_cubico as volume_cubico_agregado_nf,
				c.qt_entregas as total_entregas,
				pf.tipo_carga::integer as tipo_carga, 
				nf.destinatario_id,
				nf.remetente_id
			FROM 
				scr_notas_fiscais_imp nf
				LEFT JOIN cliente r 
					ON r.codigo_cliente = nf.remetente_id
				LEFT JOIN v_scr_notas_fiscais_carregamento c ON 
						r.cnpj_cod_interno_frete = c.cnpj_cod_interno_frete
						AND nf.cod_interno_frete = c.cod_interno_frete
				LEFT JOIN scr_pre_fatura_entregas pfe
					ON pfe.id_pre_fatura_entrega = nf.id_pre_fatura_entrega
					
				LEFT JOIN scr_pre_faturas pf
					ON pf.id_pre_fatura = pfe.id_pre_fatura				
			WHERE 
				id_nota_fiscal_imp = idnotafiscalimp
				-- id_nota_fiscal_imp
-- 				 IN (13706,13703,13696,13698,13699,13701,13694,13702,13695,13697,13700,13693,13684,13692,13685,13691,13687,13686,13688,13689,13690)
				--id_nota_fiscal_imp = 37
			
		) row 
	) SELECT f_scr_calcula_frete(parametros,cf,msg) INTO cLocal FROM t1;

	--select * from scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 50
 	FETCH FIRST FROM "msg" INTO vMsg;

	--CLOSE cLocal;
	CLOSE msg;
	
	BEGIN 
		CLOSE "cf";

	EXCEPTION 
		WHEN  	invalid_cursor_name 	THEN 		
		WHEN    null_value_not_allowed 	THEN 
	END;
	
	BEGIN 
		CLOSE "imposto";
	EXCEPTION 
		WHEN  	invalid_cursor_name 	THEN
		WHEN    null_value_not_allowed 	THEN 
	END;

	RETURN vMsg;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

