-- Function: public.f_scr_get_dados_fiscais_nfs(text)
/*
SELECT * FROM f_scr_get_dados_fiscais_nfs('7876')

SELECT * FROM scr_conhecimento_notas_fiscais ORDER BY 1 DESC LIMIT 1
*/
-- DROP FUNCTION public.f_scr_get_dados_fiscais_nfs('7876');

CREATE OR REPLACE FUNCTION public.f_scr_get_dados_fiscais_nfs(lst_nf text)
  RETURNS SETOF t_dados_fiscais AS
$BODY$
DECLARE
	
BEGIN	

	RETURN QUERY
	WITH nfs AS (
		SELECT regexp_split_to_table('7876',',')::integer as id_nota_fiscal_imp
		--SELECT regexp_split_to_table(lst_nf,',')::integer as id_nota_fiscal_imp
	)	
	,t AS (
		SELECT 	
			row_to_json(row) dados FROM (	
			SELECT 
				nf.id_nota_fiscal_imp as id,
				tipo_operacao,
				tipo_documento,
				tipo_transporte,
				modal,
				frete_cif_fob,
				remetente_id,
				destinatario_id,
				consignatario_id,
				trim(natureza_carga) as natureza_carga,
				filial_emitente,
				COALESCE(cliente.empresa_responsavel,empresa_emitente) as empresa_emitente,
				consumidor_final,
				calculado_de_id_cidade,
				calculado_ate_id_cidade,
				redespachador_id
			FROM 
				nfs
				LEFT JOIN scr_notas_fiscais_imp nf 
					ON nf.id_nota_fiscal_imp = nfs.id_nota_fiscal_imp
				LEFT JOIN cliente
					ON nf.remetente_id = cliente.codigo_cliente			
				
	
			) row
	)	
	SELECT 
		id,
		tipo_imposto,
		aliquota,
		aliquota_icms_st,
		calcula_difal,
		aliq_icms_inter,
		aliq_icms_interna,
		aliquota_fcp,
		perc_base_calculo,
		perc_credito_presumido_icms,
		cfop,
		msg
	FROM 
		t, 
		f_scr_get_dados_fiscais(t.dados);

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
--ALTER FUNCTION public.f_scr_get_dados_fiscais_nfs(text)
--  OWNER TO softlog_seniorlog;
