-- Function: public.dia_util(date, integer)
-- 
-- DROP FUNCTION public.dia_util(date, integer);
/*

SELECT f_prazo_dias_entrega('2021-09-02'::date, 3, 3454)

*/

CREATE OR REPLACE FUNCTION public.f_prazo_dias_entrega(p_data date, p_prazo_ini integer, p_id_cidade integer) 
     RETURNS integer AS
$BODY$
DECLARE
	
	cont_dia_util integer;
	cont integer;	
	p_dt_aux date;
	v_previsao_data_hora integer;
	
BEGIN
	--Determina data da páscoa

	/*Rotina que calcula o prazo de entrega e retorna o mesmo em dias*/

	
	cont = 0;
	cont_dia_util = 0;
	p_dt_aux = p_data + 1;
	
	--RAISE NOTICE 'DATA %', p_data;
	--RAISE NOTICE 'PRAZO INICIAL %', p_prazo_ini;
	
	LOOP
		--RAISE NOTICE 'DATA Aux %', p_dt_aux;
				
		IF (is_feriado(p_dt_aux, p_id_cidade)) THEN 
			--RAISE NOTICE 'FERIADO';
			cont = cont + 1;
			p_dt_aux = p_dt_aux + 1;		
			CONTINUE;
		ELSIF (dia_util(p_dt_aux) > p_dt_aux) THEN 
			--RAISE NOTICE 'NAO E DIA UTIL';
			cont = cont + 1;
			p_dt_aux = p_dt_aux + 1;
			CONTINUE;
		ELSE 
			--RAISE NOTICE 'E DIA UTIL';
			cont = cont + 1;			
		END IF;
		
		cont_dia_util = cont_dia_util + 1;

		--RAISE NOTICE 'CONT DIA UTIL %', cont_dia_util;
		
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



CREATE OR REPLACE FUNCTION public.f_prazo_dias_entrega_dh(p_data timestamp, p_prazo_dias_ini integer, p_prazo_horas integer, p_prazo_minutos integer, p_id_cidade integer) 
     RETURNS integer AS
$BODY$
DECLARE
	/*Rotina que calcula o prazo de entrega e retorna o mesmo em minutos*/
	
	cont_dia_util integer;
	cont integer;	
	p_dt_aux date;
	v_previsao_data_hora integer;	
	v_minutos integer;
	
BEGIN
	--Determina data da páscoa

	
	IF p_prazo_dias_ini > 0 THEN 
		cont = 0;
		cont_dia_util = 0;
		p_dt_aux = p_data::date + 1;
		
		--RAISE NOTICE 'DATA %', p_data;
		--RAISE NOTICE 'PRAZO INICIAL %', p_prazo_ini;
		
		LOOP
			--RAISE NOTICE 'DATA Aux %', p_dt_aux;
					
			IF (is_feriado(p_dt_aux, p_id_cidade)) THEN 
				--RAISE NOTICE 'FERIADO';
				cont = cont + 1;
				p_dt_aux = p_dt_aux + 1;		
				CONTINUE;
			ELSIF (dia_util(p_dt_aux) > p_dt_aux) THEN 
				--RAISE NOTICE 'NAO E DIA UTIL';
				cont = cont + 1;
				p_dt_aux = p_dt_aux + 1;
				CONTINUE;
			ELSE 
				--RAISE NOTICE 'E DIA UTIL';
				cont = cont + 1;			
			END IF;
			
			cont_dia_util = cont_dia_util + 1;

			--RAISE NOTICE 'CONT DIA UTIL %', cont_dia_util;
			
			IF cont_dia_util = p_prazo_ini THEN 
				EXIT;
			END IF;
			
			p_dt_aux = p_dt_aux + 1;
				
		END LOOP;
		
	ELSE 
		cont = 0;
	END IF;

	IF cont > 0 THEN 
		v_minutos = cont * 24 * 60;
	ELSE
		v_minutos = 0;
	END IF;

	v_minutos = v_minutos + (p_prazo_horas * 60) + p_prazo_minutos;
	
	RETURN v_minutos;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
