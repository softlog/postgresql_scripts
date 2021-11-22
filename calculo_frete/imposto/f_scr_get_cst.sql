-- Function: public.f_scr_get_cst(integer)
SELECT * FROM scr_tipo_imposto ORDER BY 1 
-- DROP FUNCTION public.f_scr_get_cst(integer);

CREATE OR REPLACE FUNCTION public.f_scr_get_cst(tipo_imposto integer)
  RETURNS text AS
$BODY$
DECLARE
        lc_cst text;
BEGIN

	
	CASE 

	WHEN tipo_imposto = 0 	THEN 
		lc_cst = '040';
	WHEN tipo_imposto = 1 	THEN 
		lc_cst = '000';
	WHEN tipo_imposto = 2 	THEN 
		lc_cst = '040';
	WHEN tipo_imposto = 3 	THEN 
		lc_cst = '040';
	WHEN tipo_imposto = 4  	THEN 
		lc_cst = '040';
	WHEN tipo_imposto = 5 	THEN 
		lc_cst = '040';
	WHEN tipo_imposto = 6 	THEN 
		lc_cst = '060';
	WHEN tipo_imposto = 7 	THEN 
		lc_cst = '060';
	WHEN tipo_imposto = 8 	THEN 
		lc_cst = '060';
	WHEN tipo_imposto = 9 	THEN 
		lc_cst = '090';
	WHEN tipo_imposto = 10 	THEN 
		lc_cst = '020';
	WHEN tipo_imposto = 12 	THEN 
		lc_cst = '041';
	WHEN tipo_imposto = 13 	THEN 
		lc_cst = '051';
	WHEN tipo_imposto = 14 	THEN 
		lc_cst = '090';
	ELSE
		lc_cst = '090';
	END CASE;
        
	RETURN lc_cst;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_scr_get_cst(integer)
  OWNER TO softlog_sanlorenzo2;
