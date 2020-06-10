CREATE OR REPLACE FUNCTION f_edi_sefaz_versao(p_data date, p_tipo_sefaz text)
  RETURNS text AS
$BODY$
DECLARE
        v_versao text;
BEGIN

        SELECT 
		versao_leiaute
	INTO
		v_versao
	FROM
		edi_sefaz_docs
	WHERE
		p_data >= inicio AND p_data <= COALESCE(fim, current_date)
		AND tipo_documento = p_tipo_sefaz;
	
		
	RETURN v_versao;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
/*
--SELECT * FROm edi_sefaz_docs
*/

SELECT * FROM f_edi_sefaz_versao(current_date, 'ROMANEIO')