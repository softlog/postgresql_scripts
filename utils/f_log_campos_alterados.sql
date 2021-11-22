-- Function: public.f_log_campos_alterados(integer)

-- DROP FUNCTION public.f_log_campos_alterados(integer);

CREATE OR REPLACE FUNCTION public.f_log_campos_alterados(IN p_id_log integer)
  RETURNS TABLE(id_log integer, campo_alterado character varying, valor_old character varying, valor_new character varying) AS
$BODY$
DECLARE
	v_historico text :=(SELECT COALESCE(historico,'('''','''','''')') FROM log_atividades WHERE log_atividades.id_log = $1);
BEGIN
	IF TRIM(v_historico)='' THEN
		v_historico = '('''','''','''')';
	END IF;

	IF LEFT(TRIM(v_historico),1)='<' THEN
		v_historico = '(''' || v_historico || ''','''','''')';
	END IF;

	
	RETURN QUERY
	EXECUTE 'SELECT '||$1||', column_name::varchar, old_value::varchar, new_value::varchar FROM unnest(array['|| v_historico||
		']) AS log_historico(column_name unknown, old_value unknown, new_value unknown)';
	-- unknown
END;
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100
  ROWS 1000;
