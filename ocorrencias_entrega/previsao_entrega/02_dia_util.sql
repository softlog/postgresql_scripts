-- Function: public.dia_util(date, integer)
-- 
-- DROP FUNCTION public.dia_util(date, integer);
/*

	SELECT f_prazo_dias_entrega('2021-02-12'::date, 2, 5355)

*/

CREATE OR REPLACE FUNCTION public.f_prazo_dias_entrega(p_data date, p_prazo_ini integer, p_id_cidade integer) 
     RETURNS integer AS
$BODY$
DECLARE
	
	cont_dia_util integer;
	cont integer;	
	p_dt_aux date;
	
BEGIN
	--Determina data da páscoa

	cont = 0;
	cont_dia_util = 0;
	p_dt_aux = p_data;
	
	LOOP
		
		IF (is_feriado(p_dt_aux, p_id_cidade)) THEN 
			cont = cont + 1;
			p_dt_aux = p_dt_aux + 1;			
			CONTINUE;
		ELSIF (dia_util(p_dt_aux) > p_dt_aux) THEN 
			cont = cont + 1;
			p_dt_aux = p_dt_aux + 1;
			CONTINUE;
		ELSE 
			cont = cont + 1;			
		END IF;
		
		cont_dia_util = cont_dia_util + 1;
		
		IF cont_dia_util = p_prazo_ini THEN 		
			EXIT;
		END IF;
		
		p_dt_aux = p_dt_aux + 1;
			
	END LOOP;

	RETURN cont;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

