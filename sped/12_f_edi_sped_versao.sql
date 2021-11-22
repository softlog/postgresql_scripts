-- Function: public.f_edi_sped_versao(date, text)

-- DROP FUNCTION public.f_edi_sped_versao(date, text);

CREATE OR REPLACE FUNCTION public.f_edi_sped_versao(
    p_data date,
    p_tipo_sped text)
  RETURNS text AS
$BODY$
DECLARE
        v_versao text;
BEGIN

        SELECT 
		versao_leiaute
	INTO
		v_versao
	FROM
		edi_sped_docs
	WHERE
		p_data >= inicio AND p_data <= COALESCE(fim,current_date)
		AND tipo_sped = p_tipo_sped;
	
		
	RETURN v_versao;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
