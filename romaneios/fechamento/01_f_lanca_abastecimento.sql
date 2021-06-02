/*
 SELECT id_relatorio_viagem, fechamento_inicial, fechamento_final, placa_veiculo
 FROM scr_relatorio_viagem WHERE numero_relatorio = '0010010000066'



SELECT * FROM frt_ab WHERE ab_nr = '0010010000429'

SELECT * FROM scr_relatorio_viagem_ab WHERE id_ab = 720

	SELECT 
		110,
		id_ab
	FROM
		frt_ab
	WHERE 
		frt_ab.ab_data >= '2021-01-01'::timestamp 
		AND frt_ab.ab_data <= ('2021-02-15'::text  || ' 23:59:59')::timestamp
		AND NOT EXISTS (SELECT 1
				FROM scr_relatorio_viagem_ab
				WHERE scr_relatorio_viagem_ab.id_ab = frt_ab.id_ab
					AND scr_relatorio_viagem_ab.id_relatorio_viagem = 110
				)
		AND ab_placa = 'PQP2429 '
		AND ab_cancelado = 0;		


		SELECT * FROM scr_romaneios WHERE numero_tabela_motorista IS NULL AND tipo_frota = 2 AND cancelado = 0
		

*/


CREATE OR REPLACE FUNCTION f_lanca_ab_relatorio_viagem(p_id_relatorio_viagem integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_data_inicial date;
        v_data_final date;
        v_placa_veiculo text;
BEGIN

        SELECT fechamento_inicial, fechamento_final, placa_veiculo
        INTO v_data_inicial, v_data_final, v_placa_veiculo
        FROM scr_relatorio_viagem
        WHERE id_relatorio_viagem = p_id_relatorio_viagem;

        INSERT INTO scr_relatorio_viagem_ab(id_relatorio_viagem, id_ab)
        SELECT 
		p_id_relatorio_viagem,
		id_ab
	FROM
		frt_ab
	WHERE 
		1=1
		--frt_ab.ab_data >= v_data_inicial::timestamp 
		--AND frt_ab.ab_data <= (v_data_final::text  || ' 23:59:59')::timestamp
		AND NOT EXISTS (SELECT 1
				FROM scr_relatorio_viagem_ab
				WHERE scr_relatorio_viagem_ab.id_ab = frt_ab.id_ab					
				)
		
		AND ab_placa = v_placa_veiculo
		AND ab_cancelado = 0;

	
	
	RETURN p_id_relatorio_viagem;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

-- 
--         SELECT 
-- 		35,
-- 		id_ab
-- 	FROM
-- 		frt_ab
-- 	WHERE 
-- 		frt_ab.ab_data >= '2021-01-01'::timestamp 
-- 		AND frt_ab.ab_data <= ('2021-01-15'::date::text  || ' 23:59:59')::timestamp
-- -- 		AND NOT EXISTS (SELECT 1
-- -- 				FROM scr_relatorio_viagem_ab
-- -- 				WHERE scr_relatorio_viagem_ab.id_ab = frt_ab.id_ab
-- -- 					AND scr_relatorio_viagem_ab.id_relatorio_viagem = 35
-- -- 				)
-- 		AND ab_placa = 'KYI8125';