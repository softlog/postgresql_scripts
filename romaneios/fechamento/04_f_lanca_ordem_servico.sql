CREATE OR REPLACE FUNCTION f_lanca_os_relatorio_viagem(p_id_relatorio_viagem integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_data_inicial date;
        v_data_final date;
        v_placa_veiculo text;
        v_id integer;
        v_cursor refcursor;
        
BEGIN

        SELECT fechamento_inicial, fechamento_final, placa_veiculo
        INTO v_data_inicial, v_data_final, v_placa_veiculo
        FROM scr_relatorio_viagem
        WHERE id_relatorio_viagem = p_id_relatorio_viagem;

	OPEN v_cursor FOR
        INSERT INTO scr_relatorio_viagem_os(id_relatorio_viagem, id_os, descontar)
        SELECT 
		p_id_relatorio_viagem,
		os.id_os,
		0
	FROM
		frt_os os
	WHERE 
		os.os_abertura <= v_data_final
		AND NOT EXISTS (SELECT 1
				FROM scr_relatorio_viagem_os srvos
				WHERE srvos.id_os = os.id_os
				      AND srvos.id_relatorio_viagem = p_id_relatorio_viagem
				)
		AND NOT EXISTS (SELECT 1
				FROM scr_relatorio_viagem_os 
				WHERE scr_relatorio_viagem_os .id_os = os.id_os
				      AND scr_relatorio_viagem_os.id_relatorio_viagem <> p_id_relatorio_viagem
				      AND scr_relatorio_viagem_os.descontar = 1
				)
		AND os.os_placa = v_placa_veiculo
	RETURNING v_cursor;

	FETCH v_cursor INTO v_id;

	CLOSE v_cursor;
	
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT * FROM f_lanca_os_relatorio_viagem(97);
--SELECT rv_cp.id, rv_cp.id_relatorio_viagem, cp.numero_ordem_pagamento, cp.emissao_documento, cc.valor, rv_cp.descontar FROM scr_relatorio_viagem_contas_pagar rv_cp LEFT JOIN scf_contas_pagar_centro_custos cc ON cc.id_cpagar_custo = rv_cp.id_conta_pagar_cc LEFT JOIN scf_contas_pagar cp ON cp.id_conta_pagar = cc.id_conta_pagar  WHERE scr_relatorio_viagem_contas_pagar.id_relatorio_viagem = 48 
--SELECT * FROM scr_relatorio_viagem_contas_pagar
--SELECT * FROM scf_contas_pagar_centro_custos LIMIT 1 WHERE placa_veiculo IS NOT NULL
--SELECT * FROM scr_relatorio_viagem_os
-- SELECT * FROM frt_os.i
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