CREATE OR REPLACE FUNCTION f_edi_sped_get_valor(p_valor text)
  RETURNS numeric(12,2) AS
$BODY$
DECLARE
        
BEGIN
	IF trim(p_valor) = '' THEN
		RETURN 0.00;
	END IF;
        
	RETURN replace(p_valor,',','.')::numeric(12,2);
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;