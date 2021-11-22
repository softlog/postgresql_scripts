CREATE OR REPLACE FUNCTION fd_get_integer(p_valor text)
  RETURNS integer AS
$BODY$
DECLARE
      v_codigo integer;  
BEGIN
	BEGIN 
		v_codigo = split_part(p_valor,'-',1)::integer;
	EXCEPTION WHEN OTHERS THEN
		
	END;
		
	RETURN v_codigo;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;