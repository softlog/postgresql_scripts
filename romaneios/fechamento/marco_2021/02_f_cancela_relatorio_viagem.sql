
CREATE OR REPLACE FUNCTION f_cancela_relatorio_viagem(p_id integer, p_obs text)
  RETURNS text AS
$BODY$
DECLARE
        v_usuario text;
        v_qt_op_baixa integer;        
        v_ordem_pagamento text;
BEGIN

	SELECT count(*) as qt, string_agg(scf_contas_pagar.numero_ordem_pagamento,',')
	INTO v_qt_op_baixa, v_ordem_pagamento
	FROM scr_relatorio_viagem_parcelas
		LEFT JOIN scf_contas_pagar
			ON scf_contas_pagar.id_conta_pagar = scr_relatorio_viagem_parcelas.id_conta_pagar
	WHERE 
		scr_relatorio_viagem_parcelas.id_relatorio_viagem = p_id
		AND scf_contas_pagar.status_pagamento = 1;

	IF v_qt_op_baixa > 1 THEN 
		RETURN 'Não foi possível cancelar, pois tem ordem de pagamento com baixa: ' || v_ordem_pagamento;
	END IF;

	
	v_usuario = fp_get_session('pst_login');
	v_usuario = COALESCE(v_usuario, 'suporte');
	RAISE NOTICE 'Usuario %', v_usuario;

        --Excluir lan
        RAISE NOTICE 'Excluindo Documentos Acerto';
	DELETE FROM scr_relatorio_viagem_romaneios WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Excluindo Redespachos do Acerto';
	DELETE FROM scr_relatorio_viagem_redespachos WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Excluindo Abastecimentos Acerto';
	DELETE FROM scr_relatorio_viagem_ab WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Excluindo Contas Pagar';
	DELETE FROM scr_relatorio_viagem_contas_pagar WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Excluindo OS';
	DELETE FROM scr_relatorio_viagem_os WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Excluindo Requisicoes';
	DELETE FROM scr_relatorio_viagem_req WHERE id_relatorio_viagem = p_id;


	RAISE NOTICE 'Excluindo Despesas';
	DELETE FROM scr_romaneio_despesas WHERE id_relatorio_viagem = p_id;


	RAISE NOTICE 'Excluindo Parcelas';
	DELETE FROM scr_relatorio_viagem_parcelas WHERE id_relatorio_viagem = p_id;

	RAISE NOTICE 'Cancelamento do Relatorio Viagem';		
	UPDATE scr_relatorio_viagem SET cancelado = 1, motivo_cancelamento = p_obs WHERE id_relatorio_viagem = p_id;

	INSERT INTO scr_relatorio_viagem_log_atividades (id_relatorio_viagem, data_transacao, usuario, acao_executada)
	VALUES (p_id, now(), v_usuario, 'CANCELAMENTO');
        
	RETURN 'Relatório de Viagem cancelado com sucesso';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

  ALTER FUNCTION f_cancela_relatorio_viagem(p_id integer, p_obs text) OWNER TO softlog_transrumo;

  