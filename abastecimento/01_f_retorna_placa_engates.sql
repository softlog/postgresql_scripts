/*
	SELECT * FROM f_retorna_placas_engates('IPH6914','2019-01-10 11:26:19');
*/

CREATE OR REPLACE FUNCTION f_retorna_placas_engates(p_placa_veiculo character(8), p_data timestamp)
  RETURNS text AS
$BODY$
DECLARE
       v_resultado text; 
BEGIN

	WITH 
	engates_anteriores AS (
	
		SELECT 
			*			
		FROM 
			frt_mov_eng_deseng 
		WHERE
			1=1
			AND placa_veiculo_tracao = p_placa_veiculo
			AND (data_mov <= p_data  AND flag_acao = 1)			
		ORDER BY data_mov DESC		
		
	)
	, desengates_anteriores AS (
	
		SELECT 
			*			
		FROM 
			frt_mov_eng_deseng 
		WHERE
			1=1
			AND placa_veiculo_tracao = p_placa_veiculo
			AND (data_mov <= p_data  AND flag_acao = 2)			
		ORDER BY data_mov DESC		
		
	), engatados AS (
		SELECT 
			*
		FROM
			engates_anteriores
		WHERE 
			1=1
			AND NOT EXISTS (SELECT 1
					FROM desengates_anteriores
					WHERE desengates_anteriores.placa_veiculo_reboque = engates_anteriores.placa_veiculo_reboque
			)
	)
	SELECT 
		string_agg(placa_veiculo_reboque,', ' order by id_mov) 
	INTO 
		v_resultado 
	FROM 
		engatados;
        
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

/*
Dado uma data de abastecimento, verificar na movimentação de engates as carretas engatadas naquela data.

1 - Data de abastecimento tem que ser maior que data de movimentacao do último engate;
2 - Data de abastecimento tem que ser menor que data de movimentacao do último desengate ou data atual;

*/