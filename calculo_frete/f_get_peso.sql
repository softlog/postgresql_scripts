-- Function: public.f_get_peso(numeric, numeric, integer)

-- DROP FUNCTION public.f_get_peso(numeric, numeric, integer);

CREATE OR REPLACE FUNCTION public.f_get_peso(
    ptotalpeso numeric,
    ptotalcubico numeric,
    pdensidade integer)
  RETURNS numeric AS
$BODY$
 DECLARE  	
 	vResultado numeric(20,8);
 	vValorCubado numeric(20,8);
 	--vRegistro t_calculo_frete%ROWTYPE; 
 BEGIN	
	--- Cálculo do Imposto
	--vValorCubado = round(ptotalcubico * pdensidade);
	vValorCubado = ptotalcubico * pdensidade;
	--RAISE NOTICE 'Cubagem %',ptotalcubico;
	--RAISE NOTICE 'Peso %',ptotalpeso;
	--RAISE NOTICE 'Peso Cubado %',vValorCubado;
	IF vValorCubado > ptotalpeso THEN 
		RETURN vValorCubado;
	ELSE
		RETURN ptotalpeso;
	END IF;	
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

--ALTER FUNCTION public.f_get_peso(  ptotalpeso numeric,  ptotalcubico numeric,  pdensidade integer) OWNER TO softlog_ses