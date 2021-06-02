

CREATE OR REPLACE FUNCTION f_lanca_manifesto_automatico(p_id_doc integer, p_tipo_doc integer)
  RETURNS integer AS
$BODY$
DECLARE
	
BEGIN
	--Gera Manifesto a partir da Coleta/Programacao
	IF tipo_doc = 1 THEN 
		
	END IF;
        
	RETURN 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;