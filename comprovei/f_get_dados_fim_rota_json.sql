-- Function: public.f_get_dados_romaneio_json(integer, text)
/*
SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 36076

UPDATE fila_envio_romaneios SET  status_envio = 4  WHERE id = 24374
UPDATE fila_envio_romaneios SET
                                status_envio = 4,
                                status_fim_rota = 1,
                                data_fim_rota = now(),
                                protocolo_fim_rota = '2021061119G6IKPS8A53W',                                
                                mensagem3 = '{"protocol":"2021061119G6IKPS8A53W"}'
                            WHERE id_romaneio = 36076
*/                          
--SELECT * FROM f_get_dados_fim_rota_json('53210606234797000178550010011811891100294504#35830 - 2021-06-10 - 90721837549/53210606234797000178550010011811901100088441#35830 - 2021-06-10 - 90721837549')
-- DROP FUNCTION public.f_get_dados_romaneio_json(integer, text);

CREATE OR REPLACE FUNCTION public.f_get_dados_fim_rota_json(p_dados_rota text)
  RETURNS text AS
$BODY$
DECLARE
	v_resultado text;
BEGIN

	

	WITH t1 AS (
		SELECT 			
			unnest(string_to_array(p_dados_rota,'/')) as dados_rota
	)
	, t2 AS (
		SELECT 			
			string_to_array(t1.dados_rota,'#') as dados_rota
		FROM 
			t1
			
	)
	, t3 AS (
		
		SELECT 
			dados_rota[1] as chave_nfe, 
			string_to_array(dados_rota[2],'-') as a_dados_rota
		FROM 
			t2
	)
	, t4 AS (
		SELECT 
			
			chave_nfe, 
			trim(a_dados_rota[1]) as codigo_rota,  
			(a_dados_rota[2] || '-' || a_dados_rota[3] || '-' || a_dados_rota[4])::date as data_rota,
			trim(a_dados_rota[5]) as motorista_cpf
		FROM t3
	)
	, t5 AS (
		SELECT 
			codigo_rota, 
			data_rota,
			motorista_cpf,
			to_char(now(), 'YYYY-MM-DD HH24:MI:SS') as data_fim
		FROM 
			t4
		GROUP BY 1,2,3
	)	
	
	, rotas_fim AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					*
				FROM
					t5
			) row
		)
		SELECT array_agg(json) as lista_rotas FROM temp 
	)
	
	SELECT row_to_json(row, true) as json 
	INTO v_resultado
	FROM 
	(
		SELECT 
			rotas_fim.lista_rotas as rotas
		FROM 
			rotas_fim
	) row;

	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
