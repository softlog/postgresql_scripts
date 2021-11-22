-- Function: public.f_get_parametro_sistema(text, character)

-- DROP FUNCTION public.f_get_parametro_sistema(text, character);

CREATE OR REPLACE FUNCTION public.f_get_parametro_sistema(
    p_parametro text,
    p_empresa character(3))
  RETURNS text AS
$BODY$
DECLARE
     p_valor text;   
BEGIN
	SELECT valor_parametro
	INTO p_valor
	FROM parametros 
	WHERE cod_empresa = p_empresa AND upper(cod_parametro) = upper(p_parametro) LIMIT 1;

	RETURN p_valor;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
