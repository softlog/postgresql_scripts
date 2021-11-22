-- Function: f_identifica_viagem_abastecimento(text, timestamp without time zone, character)

-- DROP FUNCTION f_identifica_viagem_abastecimento(text, timestamp without time zone, character);
-- WITH t AS (
-- 	SELECT * FROM frt_abastecimento_ecofrotas GROUP BY placa_veiculo
-- 	EXCEPT 
-- 	SELECT placa_veiculo FROM veiculos 
-- 	SELECT placa_veiculo FROM scr_romaneios GROUP BY placa_veiculo
-- 	)

--SELECT * FROM frt_abastecimento_ecofrotas
--SELECT * FROM v_romaneio_veiculos
-- UPDATE frt_abastecimento_ecofrotas SET id_romaneio = f_identifica_viagem(placa_veiculo,data_hora,'A');
-- 
--SELECT * FROM frt_tmp_sem_parar  ORDER BY data_hora;
--UPDATE frt_tmp_sem_parar SET id_romaneio = f_identifica_viagem(placa_veiculo,data_hora,'A') 
-- 
-- SELECT * FROM frt_tmp_sem_parar LIMIT 1
--SELECT f_identifica_viagem(placa_veiculo,data_hora,'A'), * FROM frt_tmp_sem_parar WHERE data_hora::date >= '2016-08-01'::date
-- SELECT  SUM(valor) FROM frt_tmp_sem_parar WHERE data_hora::date >= '2016-08-01'::date
-- SELECT * INTO v_romaneio_veiculos FROM v_romaneio_veiculos_aux;

-- SELECT 
-- 	f_identifica_viagem(placa_veiculo,data_hora,'A'), 
-- 	* 
-- FROM 
-- 	frt_abastecimento_ecofrotas;
--SELECT * FROM frt_ab 
--SELECT count(*) FROM scr_romaneios
-- 


--UPDATE frt_ab SET ab_id_romaneio = f_identifica_viagem(ab_placa,ab_data,'A') 

--DROP VIEW v_romaneio_veiculos_aux;
CREATE OR REPLACE VIEW v_romaneio_veiculos_aux AS 
SELECT 
	id_romaneio, 
	placa_veiculo,		
	data_saida,
	COALESCE(
		lead(data_saida) OVER (PARTITION BY placa_veiculo ORDER BY data_saida)- INTERVAL'1 SECOND'
		,now()- INTERVAL'1 SECOND'
		) as proxima_saida,
	odometro_inicial,
	odometro_final,
	km_rodados
FROM 
	scr_romaneios
WHERE 
	placa_veiculo IS NOT NULL 
	AND data_saida IS NOT NULL
	AND trim(placa_veiculo) <> ''
	AND cancelado = 0
	--AND placa_veiculo = 'NGU3587'
	--AND data_saida >= ('2016-08-17 23:31:12'::timestamp)
ORDER BY 
	placa_veiculo,
	data_saida;


CREATE OR REPLACE FUNCTION f_identifica_viagem(
    p_veiculo text,
    p_data timestamp without time zone,
    p_ind_viagem character)
  RETURNS integer AS
$BODY$
DECLARE
    v_id_romaneio integer;  
    v_id_romaneio_anterior integer;  
    v_data_saida date;
BEGIN
	
	WITH tbl AS (
		SELECT 
			id_romaneio,
			data_saida,
			proxima_saida
		FROM 
			v_romaneio_veiculos_aux r
		WHERE
			--r.placa_veiculo = 'OOA2999'
			r.placa_veiculo = REPLACE(p_veiculo,'-','')
			AND r.data_saida >= (p_data - INTERVAL'30 DAYS')
		ORDER BY 
			data_saida 				
	)
	SELECT 
		id_romaneio,
		data_saida
	INTO
		v_id_romaneio,
		v_data_saida
	FROM 
		tbl
	WHERE 
		p_data >= data_saida AND p_data < proxima_saida;

	RETURN v_id_romaneio;       
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
