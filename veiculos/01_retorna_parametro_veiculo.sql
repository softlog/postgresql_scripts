CREATE OR REPLACE FUNCTION f_retorna_parametro_veiculo(p_placa_veiculo text, p_id_tipo_parametro integer)
  RETURNS text AS
$BODY$
DECLARE
        v_retorno text;
BEGIN

	SELECT veiculo_parametros.valor_parametro 
	INTO v_retorno	
	FROM veiculos
		LEFT JOIN veiculo_parametros
			ON veiculos.id_veiculo = veiculo_parametros.id_veiculo
	WHERE
		veiculos.placa_veiculo = p_placa_veiculo AND id_tipo_parametro = p_id_tipo_parametro;
		
        
	RETURN v_retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;