-- Function: public.f_get_div_docs_digitalizado(text, integer)

-- DROP FUNCTION public.f_get_div_docs_digitalizado(text, integer);

CREATE OR REPLACE FUNCTION public.f_get_div_docs_digitalizado(
    lista_ids text,
    tipo_doc integer)
  RETURNS text AS
$BODY$
DECLARE
        url text;
        str_sql text;
        vCursor refcursor;
        urls text;
        resultado text;
BEGIN
	resultado = NULL;
	--Por Digitalizacao na tabela de scr_conhecimento_digitalizado
	RAISE NOTICE 'Lista ids %', lista_ids;
	
        IF tipo_doc = 1 THEN 
		IF fp_get_session('pst_cod_empresa') IS NULL THEN 
			PERFORM fp_set_session('pst_cod_empresa',empresa_emitente) 
			FROM scr_conhecimento 
			WHERE id_conhecimento 
			IN (lista_ids::integer);
		END IF;
		
		url = f_get_parametro_sistema('pST_url_servicos',fp_get_session('pst_cod_empresa'));
		str_sql = 'SELECT string_agg(''<p><div><img src="'' || ''' || url || ''' || caminho_arquivo || ''"/></div></p>'','''') as lista_id 
				FROM scr_conhecimento_digitalizado
			    WHERE id_conhecimento IN (' || lista_ids || ') GROUP BY id_ctrc_digitalizado';
		
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;

		RAISE NOTICE '%', str_sql;
		RAISE NOTICE 'URLS %', urls;
		IF urls IS NOT NULL THEN 			
			RETURN urls;
		END IF;        	
        

		str_sql = 'SELECT string_agg(''<p><div><img src="'' || trim(link_img) || ''"/></div></p>'','''')  as lista_id 
				FROM scr_docs_digitalizados
			    WHERE id_conhecimento IN (' || lista_ids || ') GROUP BY id';
			    
		RAISE NOTICE '%', str_sql;
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;
		IF urls IS NOT NULL THEN 
			RETURN urls;
		END IF;        	
		
        END IF;

	--Imagens de baixas em scr_notas_fiscais_imp
        IF tipo_doc = 3 THEN 
	
		str_sql = 'SELECT string_agg(''<p><div><img src="'' || trim(link_img) || ''"/></div></p>'','''')  as lista_id 
				FROM scr_docs_digitalizados
			    WHERE id_nota_fiscal_imp IN (' || lista_ids || ')';
			    
		RAISE NOTICE '%', str_sql;
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;
		IF urls IS NOT NULL THEN 
			RETURN urls;
		END IF;        	
		
        END IF;

        
	RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_get_div_docs_digitalizado(text, integer)
  OWNER TO softlog_medilog;
