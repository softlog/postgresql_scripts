/*
SELECT * FROM  f_get_url_canhoto(1217,3)
SELECT id_nota_fiscal_imp, chave_nfe, * FROM edi_ocorrencias_entrega WHERE id_nota_fiscal_imp IS NOT NULL ORDER BY 1 DESC LIMIT 100
*/


CREATE OR REPLACE FUNCTION public.f_get_url_canhoto(
    p_id_documento integer,
    tipo_doc integer)
  RETURNS text AS
$BODY$
DECLARE
        url text;
        str_sql text;
        vCursor refcursor;
        urls text;
        resultado text;
        v_url text;
BEGIN
	resultado = NULL;
	--Por Digitalizacao na tabela de scr_conhecimento_digitalizado
	--RAISE NOTICE 'Lista ids %', lista_ids;
	
        IF tipo_doc = 1 THEN 
		IF fp_get_session('pst_cod_empresa') IS NULL THEN 
			PERFORM fp_set_session('pst_cod_empresa',empresa_emitente) 
			FROM scr_conhecimento 
			WHERE id_conhecimento =	id_conhecimento;
		END IF;
		
		url = f_get_parametro_sistema('pST_url_servicos',fp_get_session('pst_cod_empresa'));		
		
		SELECT url || caminho_arquivo
		INTO v_url
		FROM scr_conhecimento_digitalizado
		WHERE id_conhecimento = p_id_documento
		LIMIT 1;

		
		IF  v_url IS NOT NULL THEN 			
			RETURN v_url;
		END IF;        	
        

		SELECT link_img 
		INTO v_url		
		FROM scr_docs_digitalizados
		WHERE id_conhecimento = p_id_documento;
		

		RETURN v_url;		
		
        END IF;

	--Imagens de baixas em scr_notas_fiscais_imp
        IF tipo_doc = 3 THEN 
	
	
		SELECT link_img 
		INTO v_url		
		FROM scr_docs_digitalizados
		WHERE id_nota_fiscal_imp = p_id_documento AND link_img IS NOT NULL;

		RETURN v_url;
		
        END IF;
        
	RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  

-- ALTER FUNCTION public.f_get_html_docs_digitalizado(text, integer)
--   OWNER TO softlog_bsb;