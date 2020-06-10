--SELECT f_get_arquivo_sefaz('ROMANEIO',current_date, 160686)

--SELECT max(id_romaneio) FROM scr_romaneios WHERE emitido = 1

CREATE OR REPLACE FUNCTION f_get_arquivo_sefaz(
					p_tipo_documento text,
					p_data_ref date,
					p_id_doc integer)
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
     v_cursor		refcursor;
     v_command		text;
BEGIN


	
        SELECT 
		leiaute,
		funcao_responsavel
	INTO
		v_leiaute,
		v_funcao
	FROM
		edi_sefaz_docs
	WHERE
		p_data_ref >= inicio AND p_data_ref <= COALESCE(fim, current_date)
		AND tipo_documento = p_tipo_documento;
                
	
	
	v_command = 	'SELECT ' ||
			v_funcao  ||
			'(' || p_id_doc || ')' ||
			' as dados ';

	OPEN v_cursor FOR EXECUTE v_command;

	FETCH v_cursor INTO v_dados;

	CLOSE v_cursor;
			
	RAISE NOTICE '%', v_dados;

		
	v_arquivo  = fpy_get_arquivo(v_dados::text, v_leiaute);
	
	RETURN v_arquivo;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;