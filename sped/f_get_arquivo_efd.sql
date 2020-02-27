-- Function: public.f_get_arquivo_efd(text, text, text, text, text, text, integer)

-- DROP FUNCTION public.f_get_arquivo_efd(text, text, text, text, text, text, integer);

CREATE OR REPLACE FUNCTION public.f_get_arquivo_efd(
    p_empresa text,
    p_filial text,
    p_mes text,
    p_ano text,
    p_cod_fin text,
    p_tipo_efd text,
    p_inventario integer)
  RETURNS text AS
$BODY$
DECLARE
     v_data_inicio 	date;
     v_data_fim   	date;
     v_empresa		text;
     v_dados		json;
     v_leiaute		text;
     v_versao		text;     
     v_funcao		text;
     v_arquivo		text;
BEGIN
	
        v_data_inicio 	= (p_ano || '-' || p_mes::text || '-01')::date;
        v_data_fim	= last_day_month(v_data_inicio);

	v_versao 	= f_edi_sped_versao(v_data_inicio, p_tipo_efd);
	
	SELECT 
		leiaute::text,
		funcao_responsavel		
	INTO 
		v_leiaute,
		v_funcao
	FROM 
		edi_sped_docs
	WHERE
		tipo_sped = p_tipo_efd
		AND versao_leiaute = v_versao;

	IF v_funcao = 'f_edi_sped_cont' THEN
		SELECT 
			f_edi_sped_cont(
					v_data_inicio, 
					v_data_fim,
					p_empresa,
					p_cod_fin,
					NULL::json
			)
		INTO 
			v_dados;
	END IF;

	--RAISE NOTICE '%', v_dados;
	IF v_funcao = 'f_edi_sped_fiscal' THEN 
		SELECT 
			f_edi_sped_fiscal(
					v_data_inicio, 
					v_data_fim,
					p_empresa,
					p_filial,
					p_cod_fin,
					p_inventario,
					NULL::json
			)
		INTO 
			v_dados;		
	END IF;

	--RAISE NOTICE '%', v_leiaute;	
	v_arquivo  = fpy_get_arquivo_efd(v_dados::text,v_leiaute);
	
	RETURN v_arquivo;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

