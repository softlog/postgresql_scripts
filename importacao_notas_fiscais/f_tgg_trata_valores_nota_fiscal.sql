-- Function: public.f_tgg_trata_valores_nota_fiscal()
/*
BEGIN;
DELETE FROM scr_conhecimento WHERE data_digitacao::date = current_date;
COMMIT;
*/
-- DROP FUNCTION public.f_tgg_trata_valores_nota_fiscal();

CREATE OR REPLACE FUNCTION public.f_tgg_trata_valores_nota_fiscal()
  RETURNS trigger AS
$BODY$
DECLARE
	hora_corte_expedicao integer;
BEGIN

	IF NEW.numero_nota_fiscal IS NOT NULL THEN 
		NEW.numero_nota_fiscal = lpad(trim(translate(NEW.numero_nota_fiscal,'"','')),9,'0');
	END IF;
	
	IF NEW.serie_nota_fiscal IS NOT NULL THEN 
		NEW.serie_nota_fiscal = lpad(trim(translate(NEW.serie_nota_fiscal,'"','')),3,'0');    
	END IF;

	hora_corte_expedicao = 8;
	
	IF current_database() = 'softlog_medilog' THEN 
		hora_corte_expedicao = 11;
	END IF;

	IF current_database() = 'softlog_transmed' THEN 
		hora_corte_expedicao = 5;
	END IF;

	
	IF current_database() = 'softlog_dfreire' THEN 
		hora_corte_expedicao = 5;
	END IF;
	
	
	
	IF TG_OP = 'INSERT' THEN
		IF EXTRACT('hour' from NEW.data_registro) < hora_corte_expedicao then 
			NEW.data_expedicao 	= 	(NEW.data_registro - INTERVAL'23 HOURS 59 MINUTES 59 SECONDS')::date;
		ELSE	
			NEW.data_expedicao	=	NEW.data_registro::date;
		END IF;

			
	END IF;

	NEW.codigo_nota = (trim(NEW.remetente_id::text) || '_' ||  
			ltrim(trim(NEW.numero_nota_fiscal),'0') || '_' || 
			ltrim(trim(NEW.serie_nota_fiscal),'0'));

	
	BEGIN
		IF NEW.peso_presumido > 999999 THEN
			NEW.peso_presumido = NEW.peso_presumido / 100;
		END IF;
	EXCEPTION WHEN OTHERS  THEN 
		NEW.peso_presumido = 0.00;
	END;
	
	IF NEW.id_pre_fatura_entrega IS NULL AND NEW.cod_interno_frete IS NOT NULL THEN 
		NEW.vl_frete_peso = 0.00;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

