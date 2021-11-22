-- Function: public.f_get_id_bairro_cep(text)

-- DROP FUNCTION public.f_get_id_bairro_cep(text);

CREATE OR REPLACE FUNCTION public.f_get_id_bairro_cep(cep text)
  RETURNS integer AS
$BODY$
DECLARE
        v_id_bairro integer;        
BEGIN

	
	
	IF char_length(trim(cep)) > 1 THEN 
		BEGIN 
			SELECT 	id_bairro
			INTO 	v_id_bairro
			FROM 	qualocep_faixa_bairros 
			WHERE cep >= cep_inicial AND cep <= cep_final;
		EXCEPTION 
			WHEN others THEN
				v_id_bairro = NULL;
		END;

		RETURN v_id_bairro;
	ELSE
		RETURN NULL;
	END IF;        
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


UPDATE cliente SET codigo_cliente = codigo_cliente WHERE id_bairro IS NULL RETURNING id_bairro;