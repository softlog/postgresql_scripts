-- Function: public.f_tgg_calcula_tabela_motorista()
/*

SELECT * FROM scr_romaneios WHERE  numero_romaneio = '0020010089872'
BEGIN;
COMMIT;
SELECT f_calcula_tabela_motorista_automatico(137597,'{
	"id_romaneio": 137597,
	"numero_tabela_motorista": "0020010000552",
	"id_origem": 3231,
	"id_destino": null,
	"id_regiao_destino":601,
	"diarias": 1.0,
	"km_rodados": 0.00,
	"total_pedagio": 37.6650,
	"placa_veiculo": "LUW8C76",
	"total_ajudantes": 0,
	"total_volume": 12,
	"total_peso": 37.6650,
	"total_cubagem": 0.000000,
	"total_servicos": 5,
	"total_frete": 0.00
}'::json, 'cursor_fechamento'::refcursor, 'msg'::refcursor)


SELECT f_calcula_tabela_motorista_automatico(137259,'{"numero_tabela_motorista":"0020010000552", "id_origem":3231, "id_destino":null, "id_regiao_destino":612, "diarias":1.0, "km_rodados":0.00, "total_pedagio":535.000000, "placa_veiculo":"LUW8C76", "total_ajudantes":0, "total_volume":535, "total_peso":535.000000, "total_cubagem":0.000000, "total_servicos":2, "total_frete":0.000000}'::json, 'cursor_fechamento'::refcursor, 'msg'::refcursor)

SELECT f_calcula_tabela_motorista_automatico(137259,'{"numero_tabela_motorista":"0020010000552", "id_origem":3231, "id_destino":null, "id_regiao_destino":612, "diarias":1.0, "km_rodados":0.00, "total_pedagio":535.000000, "placa_veiculo":"LUW8C76", "total_ajudantes":0, "total_volume":535, "total_peso":535.000000, "total_cubagem":0.000000, "total_servicos":2, "total_frete":0.000000}'::json, 'cursor_fechamento'::refcursor, 'msg'::refcursor)

*/	
-- DROP FUNCTION public.f_tgg_calcula_tabela_motorista();

CREATE OR REPLACE FUNCTION public.f_calcula_tabela_motorista_automatico(p_id_romaneio integer, v_parametros json, cursor_fechamento refcursor, msg refcursor)
  RETURNS integer AS
$BODY$
DECLARE
	
	
	
	vResultado t_fechamento_romaneio%rowtype;	
	
	
	v_tabela text;
	v_id_romaneio_vinculado integer;	
	
	v_total_valor_pagar numeric(12,2);
	v_total_despesas numeric(12,2);
	v_despesas_avista numeric(12,2);
	v_despesas_aprazo numeric(12,2);
	v_adiantamentos numeric(12,2);
	v_acrescimos numeric(12,2);
	v_provisao numeric(12,2);
	v_reembolso numeric(12,2);
	v_devolucao numeric(12,2);
	va_combinados integer[];

	v_cancelado integer;
	v_placa text;
	v_cpf_motorista text;
	v_cnpj_cpf_proprietario text;
	--cursor_fechamento refcursor;
	--msg refcursor;

BEGIN

	/*
	SELECT 
		cancelado,
		numero_tabela_motorista,
		placa_veiculo,
		cpf_motorista,
		cnpj_cpf_proprietario
		
	INTO
		v_cancelado,
		v_tabela,
		v_placa,
		v_cpf_motorista,
		v_cnpj_cpf_proprietario
		
	FROM 
		scr_romaneios
	WHERE 
		id_romaneio = p_id_romaneio;
	
	
	
	IF v_cancelado = 1 THEN 
		RAISE NOTICE 'Cancelado';
		RETURN 0;
	END IF;
	
		
	IF v_tabela IS NULL THEN 
		SELECT t.numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista t
			LEFT JOIN scr_tabela_motorista_regioes r
				ON t.id_tabela_motorista = r.id_tabela_motorista			
		WHERE 
			r.placa_veiculo = v_placa
			AND ativa = 1;
			
		UPDATE scr_romaneios SET numero_tabela_motorista = v_tabela WHERE id_romaneio = p_id_romaneio;
	END IF;

	
	IF v_tabela IS NULL THEN 
		SELECT numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista
		WHERE cpf_motorista = v_cpf_motorista
			AND ativa = 1
		ORDER BY 
			vigencia_tabela 
			DESC LIMIT 1;	

		
		UPDATE scr_romaneios SET numero_tabela_motorista = v_tabela WHERE id_romaneio = p_id_romaneio;
	END IF;		

	IF v_tabela IS NULL THEN 
		SELECT numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista
		WHERE cpf_motorista = v_cnpj_cpf_proprietario
			AND ativa = 1
		ORDER BY 
			vigencia_tabela 
			DESC LIMIT 1;	
			
		UPDATE scr_romaneios SET numero_tabela_motorista = v_tabela WHERE id_romaneio = p_id_romaneio;
	END IF;

	RAISE NOTICE 'Tabela Motorista %', v_tabela;

	IF v_tabela IS NULL THEN 
		RAISE NOTICE 'Sem Tabela';
		RETURN 0;
	END IF;
	*/

	
	--Gera parametros em json 
	/*
	WITH t AS (
		SELECT 
			scr_romaneios.id_romaneio,
			numero_tabela_motorista, 
			id_origem, 
			id_destino, 
			COALESCE(id_regiao, id_setor) as id_regiao_destino,
			diarias, 
			km_rodados, 
			SUM(totais.peso_presumido) as total_pedagio, 
			trim(v_placa) as placa_veiculo, 
			0::integer as total_ajudantes, 
			SUM(totais.volume_presumido)::integer as total_volume, 
			SUM(totais.peso_presumido) as total_peso, 
			SUM(totais.volume_cubico) as total_cubagem, 
			COUNT(*) as total_servicos, 
			0.00 as total_frete 
		FROM 	
			scr_romaneios 
			LEFT JOIN scr_romaneio_nf rnf
				ON rnf.id_romaneio = scr_romaneios.id_romaneio
			LEFT JOIN scr_notas_fiscais_imp totais 
				ON rnf.id_nota_fiscal_imp = totais.id_nota_fiscal_imp
		WHERE	
			scr_romaneios.id_romaneio = p_id_romaneio
		GROUP BY 
			scr_romaneios.id_romaneio
	) SELECT row_to_json(t) INTO v_parametros FROM t;
	*/

	RAISE NOTICE 'Parametros %', v_parametros;
	
	PERFORM f_acerto_motorista_2(v_parametros, cursor_fechamento, msg);

	
	IF cursor_fechamento IS NULL THEN 
		RAISE NOTICE 'Sem resultado';
		RETURN 0;
	END IF;

	
	DELETE FROM scr_romaneio_fechamentos WHERE id_romaneio = p_id_romaneio AND programado = 1;	


	SELECT array_agg(tipo_calculo) INTO va_combinados FROM scr_romaneio_fechamentos WHERE id_romaneio = p_id_romaneio AND programado = 0;
	
	v_total_valor_pagar = 0.00;
	
	BEGIN 
		
		LOOP
			FETCH IN cursor_fechamento INTO vResultado;

			EXIT 	WHEN NOT FOUND;

			RAISE NOTICE 'Array %', va_combinados;
			IF va_combinados IS NULL THEN 
				va_combinados = '{0}'::integer[];
			END IF;

			RAISE NOTICE 'Tipo Calculo %', vResultado.tipo_calculo;
			IF NOT ARRAY[vResultado.tipo_calculo] <@ va_combinados THEN 	
				INSERT INTO scr_romaneio_fechamentos 
				(
					id_romaneio,
					tipo_calculo,
					excedente,
					base_calculo,
					valor_item,
					total_itens,
					valor_minimo,
					valor_pagar,
					programado
				) VALUES (
					p_id_romaneio,
					vResultado.tipo_calculo,
					vResultado.excedente,
					vResultado.base_calculo,
					vResultado.valor_item,
					vResultado.total_itens,
					vResultado.valor_minimo,
					vResultado.valor_pagar,
					vResultado.programado
				);						
				--v_total_valor_pagar = v_total_valor_pagar + vResultado.valor_pagar;
			END IF;
		END LOOP;
	EXCEPTION WHEN OTHERS THEN 
		--RAISE NOTICE 'Romaneio % teve problemas', NEW.numero_romaneio;
		CLOSE cursor_fechamento;
		CLOSE msg;
		RAISE NOTICE 'Deu erro';
		RETURN 0;
	END;

	CLOSE cursor_fechamento;
	CLOSE msg;

	SELECT SUM(valor_pagar) INTO v_total_valor_pagar 
	FROM scr_romaneio_fechamentos
	WHERE id_romaneio = p_id_romaneio;


	RAISE NOTICE 'Valor Total Servico %', v_total_valor_pagar;

	v_total_valor_pagar = COALESCE(v_total_valor_pagar,0.00);
	
	SELECT 
		COALESCE(SUM(CASE WHEN credito_debito = 2 AND tipo_operacao IN (5,6) THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN credito_debito = 2 AND forma_pagamento = 1 AND tipo_controle IN (3,5,6) THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN credito_debito = 2 AND forma_pagamento = 2 AND tipo_controle IN (3,5,6) THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN tipo_operacao = 3 THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN tipo_operacao = 1 THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN tipo_controle = 4 AND credito_debito = 1 THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN tipo_controle = 5 AND credito_debito = 1 THEN valor_despesa ELSE 0 END),0.00),
		COALESCE(SUM(CASE WHEN tipo_controle = 6 AND credito_debito = 1 THEN valor_despesa ELSE 0 END),0.00)	
	INTO 
		v_total_despesas,
		v_despesas_avista,
		v_despesas_aprazo,
		v_adiantamentos,
		v_acrescimos,
		v_provisao,
		v_reembolso,		
		v_devolucao
	FROM 
		scr_romaneio_despesas 
		LEFT JOIN scr_despesas_viagem 
			ON scr_romaneio_despesas.id_despesa = scr_despesas_viagem.id_despesa 
	WHERE 
		id_romaneio = p_id_romaneio;


	UPDATE scr_romaneios SET 
		vl_servico_for = v_total_valor_pagar,
		vl_adiantamentos_for = v_adiantamentos,
		vl_acrescimos_for = v_acrescimos,
		vl_pagar_for = v_total_valor_pagar - v_adiantamentos + v_acrescimos,
		vl_despesas_viagem = v_despesas_avista + v_despesas_aprazo,
		vl_despesas_a_vista = v_despesas_avista,
		vl_despesas_a_prazo = v_despesas_aprazo,
		vl_provisao_viagem = v_provisao,
		vl_provisao_saldo = v_provisao - v_despesas_avista + v_reembolso - v_devolucao,
		fechamento = 1
	WHERE id_romaneio = p_id_romaneio;

 	RAISE NOTICE 'Total Pagar %', v_total_valor_pagar;
 	RAISE NOTICE 'Adiantamentos %', v_adiantamentos;
 	RAISE NOTICE 'Acrescimos %', v_acrescimos;
 	--RAISE NOTICE 'vl_pagar_for %', NEW.vl_pagar_for;


	
	

	IF v_total_valor_pagar > 0 THEN 
		UPDATE scr_romaneios SET vl_despesas_diretas = v_total_despesas  + v_total_valor_pagar - v_acrescimos WHERE id_romaneio = p_id_romaneio;
	ELSE 
		UPDATE scr_romaneios SET vl_despesas_diretas = v_total_despesas WHERE id_romaneio = p_id_romaneio;
	END IF;
	
         
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
