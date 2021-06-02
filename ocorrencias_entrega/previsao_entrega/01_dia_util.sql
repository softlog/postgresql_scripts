-- Function: public.dia_util(date, integer)

-- DROP FUNCTION public.dia_util(date, integer);

CREATE OR REPLACE FUNCTION public.is_dia_util(
    date,
    integer)
  RETURNS date AS
$BODY$
DECLARE
	--Com id da cidade
	dt ALIAS FOR $1;
	id_cidade ALIAS FOR $2;
	dt_pascoa date;
	dt_carnaval date;
BEGIN
	--Determina data da páscoa
	dt_pascoa = dia_pascoa(extract('year' from dt)::integer);
	dt_carnaval = dt_pascoa - 47;

	IF ((dt >= dt_carnaval - 3) AND (dt <= dt_carnaval)) THEN 
		-- Feriado do Carnaval
		RETURN dt_carnaval + 1;
	ELSIF (dt >= dt_pascoa - 2 AND dt <= dt_pascoa) THEN 
		-- Feriado da Páscoa
		RETURN dt_pascoa + 1;
	ELSIF (dt = dt_pascoa + 60) THEN 
		-- Feriado de Corpus Christi
		IF (extract('dow' from dt) = 5) THEN  
			-- Se cair na sexta
			RETURN dt + 3;
		ELSIF (extract('dow' from dt) = 6) THEN 
			-- Se cair no sábado
			RETURN dt + 2;	
		ELSE --Se cair noutros dias da semana
			RETURN dt + 1;
		END IF; 
	ELSIF (extract('dow' from dt) = 0) THEN -- Data é Domingo
		RETURN dt + 1;
	ELSIF (extract('dow' from dt) = 6) THEN -- Data é Sábado	
		RETURN dt + 2;	
	ELSE
		RETURN dt;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

