-- Function: public.f_get_link_img(integer, integer)

-- DROP FUNCTION public.f_get_link_img(integer, integer);



CREATE OR REPLACE FUNCTION public.f_get_link_img(
    id_doc integer,
    tipo_doc integer)
  RETURNS text AS
$BODY$
DECLARE
        url text;
        link_img text;
        str_sql text;
        vCursor refcursor;
        urls text;
        resultado text;
BEGIN
	resultado = NULL;
	--Por Digitalizacao na tabela de scr_conhecimento_digitalizado
	--RAISE NOTICE 'Lista ids %', lista_ids;
	
        IF tipo_doc = 1 THEN 
		IF fp_get_session('pst_cod_empresa') IS NULL THEN 
			PERFORM fp_set_session('pst_cod_empresa',empresa_emitente) 
			FROM scr_conhecimento 
			WHERE id_conhecimento = id_doc;			
		END IF;
		
		url = f_get_parametro_sistema('pST_url_servicos',fp_get_session('pst_cod_empresa'));

		SELECT url || trim(caminho_arquivo) 
		INTO link_img
		FROM scr_conhecimento_digitalizado 
		WHERE id_conhecimento = id_doc ORDER BY id_ctrc_digitalizado DESC LIMIT 1;
		 
		IF link_img IS NOT NULL THEN 			
			RETURN link_img;
		END IF;        	
        
		SELECT trim(scr_docs_digitalizados.link_img)
		INTO link_img
		FROM scr_docs_digitalizados 
		WHERE id_conhecimento = id_doc 
		ORDER BY id ASC LIMIT 1;


		RETURN link_img;		
        END IF;


	IF tipo_doc = 2 THEN 
		SELECT trim(scr_docs_digitalizados.link_img)
		INTO link_img
		FROM scr_docs_digitalizados 
		WHERE id_nota_fiscal_imp = id_doc 
		ORDER BY id ASC LIMIT 1;


		RETURN link_img;		
	END IF;
	
        
	RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
