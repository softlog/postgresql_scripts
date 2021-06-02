

CREATE OR REPLACE FUNCTION f_mostra_prazo_entrega_portal(p_codigo_empresa character(3))
  RETURNS integer AS
$BODY$
DECLARE
        v_resultado integer;
BEGIN
	BEGIN 
		SELECT valor_parametro::integer
		INTO v_resultado
		FROM parametros
		WHERE UPPER(cod_parametro) = 'PST_PRAZO_ENTREGA_PORTAL' AND cod_empresa = p_codigo_empresa;
		
	EXCEPTION WHEN OTHERS THEN 
		v_resultado = 1;
	END;
	
	RETURN COALESCE(v_resultado, 1);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;