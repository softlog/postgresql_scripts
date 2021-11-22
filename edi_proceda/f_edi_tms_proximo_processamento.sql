-- Function: public.f_edi_tms_proximo_processamento(integer, integer, text, timestamp without time zone)

-- DROP FUNCTION public.f_edi_tms_proximo_processamento(integer, integer, text, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.f_edi_tms_proximo_processamento(
    tipo_evento integer,
    periodo integer,
    horario text,
    data_referencia timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
DECLARE
	v_data_ref timestamp;
	v_horas integer;
	v_minutos integer;
	v_dia_semana integer;
	v_inicio timestamp;	
	v_qt_meses integer;
	v_qt_dias_semana integer;
	v_ultimo_processamento timestamp;
	v_proximo_processamento timestamp;
	v_aux integer;   	
BEGIN

	IF data_referencia IS NULL THEN 
		v_data_ref = now();
	ELSE
		v_data_ref = data_referencia;
	END IF;
	--v_data_ref = '2015-01-31 15:01:00';			
	--Se processamento for mensal;
	IF tipo_evento = 1 THEN 
		v_inicio = (extract(year from v_data_ref)::text || 
		'-01-' || 
		trim(to_char(periodo,'00')) ||
		' ' ||
		trim(to_char(horario::integer,'00:00')) ||
		':00')::timestamp;		

		--Se a data de hoje é menor que o dia programado no mes,
		--Então ultimo processamento deve ser o dia do mês anterior
		v_qt_meses = extract(month from v_data_ref);
			
		v_proximo_processamento = v_inicio + make_interval(months := v_qt_meses-1);

		IF v_proximo_processamento <= v_data_ref THEN
			v_proximo_processamento = v_proximo_processamento + make_interval(months := 1);
		END IF;	
	END IF;	

	--Se processamento for semanal;
	IF tipo_evento = 2 THEN 
		v_dia_semana 	= extract(dow from v_data_ref);
		v_horas 	= (left(horario,2))::integer;
		v_minutos	= (right(horario,2))::integer;
	
		v_proximo_processamento	= v_data_ref - make_interval(days := v_dia_semana);

		v_proximo_processamento	= (v_proximo_processamento::date::text || ' 00:00:00')::timestamp;

		v_proximo_processamento	= v_proximo_processamento + make_interval(	days 	:= periodo-1, 
											hours 	:= v_horas,
											mins 	:= v_minutos									
									);

		IF v_proximo_processamento <= v_data_ref THEN 		
			v_proximo_processamento	= v_proximo_processamento + make_interval(weeks := 1);
		END IF;
								
	END IF;	


	--Se processamento for diario;
	IF tipo_evento = 3 THEN 
		
		v_horas 	= (left(horario,2))::integer;
		v_minutos	= (right(horario,2))::integer;
	
		
		v_proximo_processamento	= (v_data_ref::date::text || ' 00:00:00')::timestamp;

		v_proximo_processamento	= v_proximo_processamento + make_interval(hours := v_horas,
										  mins 	:= v_minutos									
									);

		IF v_proximo_processamento <= v_data_ref THEN 		
			v_proximo_processamento	= v_proximo_processamento + make_interval(days := 1);
		END IF;
								
	END IF;	

	--Se processamento for por minutos;
	IF tipo_evento = 6 THEN 

		
		v_minutos	= periodo;
	
		
		v_proximo_processamento	= v_data_ref;

		v_proximo_processamento	= v_proximo_processamento + make_interval(mins 	:= v_minutos);


		IF v_proximo_processamento <= v_data_ref THEN 		
			v_proximo_processamento	= v_proximo_processamento + make_interval(mins := v_minutos);
		END IF;
								
	END IF;	


	RETURN v_proximo_processamento;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
--ALTER FUNCTION public.f_edi_tms_proximo_processamento(integer, integer, text, timestamp without time zone)
--  OWNER TO softlog_dng;
