-- Function: public.f_tgg_edi_tms_agenda_envio()

-- DROP FUNCTION public.f_tgg_edi_tms_agenda_envio();

CREATE OR REPLACE FUNCTION public.f_tgg_edi_tms_agenda_envio()
  RETURNS trigger AS
$BODY$
DECLARE	
BEGIN
	IF NEW.tipo_evento IN (1,2,3,6) THEN
	
		--RAISE NOTICE 'Recalcula data de processamento';
		--NEW.proximo_processamento = NULL;
		/*
		RAISE NOTICE 'Tipo Evento %', NEW.tipo_evento;
		RAISE NOTICE 'Periodo %', NEW.periodo;
		RAISE NOTICE 'Horario %', NEW.horario;
		*/
				
		IF NEW.proximo_processamento IS NULL THEN 
			NEW.proximo_processamento = f_edi_tms_proximo_processamento(
							NEW.tipo_evento::integer,
							NEW.periodo::integer,
							NEW.horario::text,
							NULL::timestamp without time zone
						);
		END IF;
	ELSE
		NEW.proximo_processamento = NULL;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
--ALTER FUNCTION public.f_tgg_edi_tms_agenda_envio()
--  OWNER TO softlog_dng;
