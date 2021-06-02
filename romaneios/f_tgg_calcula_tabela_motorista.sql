/*
-- Function: public.f_tgg_calcula_tabela_motorista()

-- DROP FUNCTION public.f_tgg_calcula_tabela_motorista();
SELECT * FROM scr_romaneio_fechamentos

SELECT * FROM scr_romaneios LIMIT 1
BEGIN;
UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE numero_tabela_motorista = '0010010000003' AND data_saida > '2021-01-15';
COMMIT;

SELECT numero_romaneio as numero_viagem, cnpj_cpf_proprietario, numero_tabela_motorista, placa_veiculo FROM scr_romaneios WHERE vl_pagar_for = 0.00 AND tipo_frota = 2  

SELECT numero_romaneio, fechamento, vl_pagar_for FROM scr_romaneios WHERE tipo_frota = 2 ORDER BY  2 

UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE numero_romaneio = '0010010000975';

SELECT * FROM scr_tabela_motorista_regioes WHERE 

*/

CREATE OR REPLACE FUNCTION f_tgg_calcula_tabela_motorista()
  RETURNS trigger AS
$BODY$
DECLARE
	
	cursor_fechamento refcursor;
	
	vResultado t_fechamento_romaneio%rowtype;	
	msg refcursor;
	
	v_tabela text;
	v_id_romaneio_vinculado integer;
	v_parametros json;
	
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
	v_total_frete numeric(12,2);

	v_id_tipo_calculo integer;

BEGIN


	--Operacao por nota

	
	cursor_fechamento = TG_ARGV[0];
	msg		  = TG_ARGV[1];

	
	IF NEW.cancelado = 1 THEN 
		RETURN NEW;
	END IF;
	
	--NEW.numero_tabela_motorista = NULL;	
	
	--Busca tabela de motorista pela placa e proprietario
	IF NEW.numero_tabela_motorista IS NULL THEN 
	
		SELECT t.numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista t
			LEFT JOIN scr_tabela_motorista_regioes r
				ON t.id_tabela_motorista = r.id_tabela_motorista			
		WHERE 
			r.placa_veiculo = NEW.placa_veiculo
			AND cpf_motorista = NEW.cnpj_cpf_proprietario
			AND ativa = 1;
						
		NEW.numero_tabela_motorista = v_tabela;


		RAISE NOTICE 'Veiculo %', NEW.placa_veiculo;
		RAISE NOTICE 'Proprietario %', NEW.cnpj_cpf_proprietario;
		RAISE NOTICE 'Tabela Proprietario %', v_tabela;
		
	END IF;

	--Busca tabela de motorista pelo CPF do motorista
	IF NEW.numero_tabela_motorista IS NULL THEN 
	
		SELECT numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista
		WHERE cpf_motorista = NEW.cpf_motorista
			AND ativa = 1
		ORDER BY 
			vigencia_tabela 
			DESC LIMIT 1;	
			
		NEW.numero_tabela_motorista = v_tabela;		

		RAISE NOTICE 'Tabela Motorista %', v_tabela;
	END IF;		

	--Busca tabela de motorista pelo proprietario
	IF NEW.numero_tabela_motorista IS NULL THEN 
		SELECT numero_tabela_motorista 
		INTO v_tabela
		FROM scr_tabela_motorista
		WHERE cpf_motorista = NEW.cnpj_cpf_proprietario
			AND ativa = 1
		ORDER BY 
			vigencia_tabela 
			DESC LIMIT 1;	
			
		NEW.numero_tabela_motorista = v_tabela;
	END IF;

	RAISE NOTICE 'Tabela Motorista %', NEW.numero_tabela_motorista;

	IF NEW.numero_tabela_motorista IS NULL THEN 
		RETURN NEW;
	END IF;


	--Verifica se tem diaria no dia
-- 	SELECT 
-- 		r.id_romaneio
-- 	INTO
-- 		v_id_romaneio_vinculado
-- 	FROM 
-- 		scr_romaneios r
-- 		LEFT JOIN scr_romaneio_nf rnf
-- 			ON rnf.id_romaneio = r.id_romaneio
-- 	WHERE
-- 		cpf_motorista = NEW.cpf_motorista
-- 		--AND data_saida <= NEW.data_saida
-- 		AND data_saida::date = NEW.data_saida::date
-- 		AND cancelado = 0
-- 		AND r.id_romaneio < NEW.id_romaneio
-- 		AND rnf.id_nota_fiscal_imp IS NOT NULL
-- 	ORDER BY 
-- 		id_romaneio	
-- 	LIMIT 1;

-- 	RAISE NOTICE 'Id Romaneio Vinculado %',v_id_romaneio_vinculado;

-- 	--Por padrao, existe pelo menos 1 diaria
-- 	IF NEW.diarias = 0 THEN
-- 		NEW.diarias = 1;
-- 	END IF;
-- 
-- 	--Se o motorista ja tem romaneio no dia, entao não soma mais diaria
-- 	IF v_id_romaneio_vinculado IS NOT NULL THEN
-- 		NEW.id_romaneio_vinculado = v_id_romaneio_vinculado;
-- 		NEW.diarias = 0;
-- 	ELSE
-- 		NEW.id_romaneio_vinculado = NULL;
-- 	END IF;

	
	--Gera parametros em json
	IF NEW.tipo_romaneio = 1 THEN  	
		WITH t AS (
			SELECT 
				NEW.id_romaneio,
				NEW.numero_tabela_motorista, 
				NEW.id_origem, 
				NEW.id_destino,								 
				NEW.diarias, 
				NEW.km_rodados, 
				SUM(totais.peso_presumido) as total_pedagio, 
				trim(NEW.placa_veiculo) as placa_veiculo, 
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
				scr_romaneios.id_romaneio = NEW.id_romaneio
			GROUP BY 
				scr_romaneios.id_romaneio
		) SELECT row_to_json(t) INTO v_parametros FROM t;
	ELSE 

		

		SELECT 	tipo_calculo 
		INTO 	v_id_tipo_calculo 
		FROM 	scr_romaneio_fechamentos 
		WHERE   id_romaneio = NEW.id_romaneio;

		
		IF v_id_tipo_calculo = 16 THEN 
			RETURN NEW;
		END IF;
			
		
		
		WITH t AS (
			
			SELECT 
				NEW.id_romaneio,
				NEW.numero_tabela_motorista,
				NEW.id_origem, 
				NEW.id_destino,			 
				NEW.diarias, 
				NEW.km_rodados, 
				SUM(totais.peso_total) as total_pedagio, 
				trim(NEW.placa_veiculo) as placa_veiculo, 
				0::integer as total_ajudantes, 
				SUM(totais.qtd_volumes)::integer as total_volume, 
				SUM(totais.peso_total) as total_peso, 
				SUM(totais.volume_cubado) as total_cubagem, 
				COUNT(*) as total_servicos, 
				SUM(totais.total_frete) as total_frete 
			FROM 					
				scr_viagens_docs totais
			WHERE	
				totais.id_romaneio = NEW.id_romaneio
			GROUP BY 
				totais.id_romaneio
		) SELECT row_to_json(t) INTO v_parametros FROM t;

		
		SELECT SUM(scr_viagens_docs.total_frete)
		INTO v_total_frete
		FROM scr_viagens_docs
		WHERE id_romaneio = NEW.id_romaneio
		GROUP BY scr_viagens_docs.id_romaneio;
			

	END IF;

	RAISE NOTICE 'Parametros %', v_parametros;
	
	PERFORM f_acerto_motorista_2(v_parametros, cursor_fechamento, msg);

	
	IF cursor_fechamento IS NULL THEN 
		RAISE NOTICE 'Sem resultado';
		RETURN NEW;
	END IF;

	
	DELETE FROM scr_romaneio_fechamentos WHERE id_romaneio = NEW.id_romaneio AND programado = 1;	

	SELECT array_agg(tipo_calculo) INTO va_combinados FROM scr_romaneio_fechamentos WHERE id_romaneio = NEW.id_romaneio AND programado = 0;
	
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
					NEW.id_romaneio,
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
		RAISE NOTICE 'Romaneio % teve problemas', NEW.numero_romaneio;
		CLOSE cursor_fechamento;
		CLOSE msg;
		RETURN NEW;
	END;

	CLOSE cursor_fechamento;
	CLOSE msg;

	SELECT SUM(valor_pagar) INTO v_total_valor_pagar 
	FROM scr_romaneio_fechamentos
	WHERE id_romaneio = NEW.id_romaneio;

	RAISE NOTICE 'Valor Total Servico %', v_total_valor_pagar;
	
	NEW.vl_servico_for = COALESCE(v_total_valor_pagar,0.00);

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
		id_romaneio = NEW.id_romaneio;

	
	NEW.vl_adiantamentos_for = v_adiantamentos;
	NEW.vl_acrescimos_for = v_acrescimos;
	NEW.vl_pagar_for = NEW.vl_servico_for - NEW.vl_adiantamentos_for + NEW.vl_acrescimos_for;

 	RAISE NOTICE 'Total Pagar %', v_total_valor_pagar;
 	RAISE NOTICE 'Adiantamentos %', v_adiantamentos;
 	RAISE NOTICE 'Acrescimos %', v_acrescimos;
 	RAISE NOTICE 'vl_pagar_for %', NEW.vl_pagar_for;


	NEW.vl_despesas_viagem = v_despesas_avista + v_despesas_aprazo;
	NEW.vl_despesas_a_vista = v_despesas_avista;
	NEW.vl_despesas_a_prazo = v_despesas_aprazo;
	NEW.vl_provisao_viagem = v_provisao;
	NEW.vl_provisao_saldo = v_provisao - v_despesas_avista + v_reembolso - v_devolucao;
	NEW.total_frete = COALESCE(v_total_frete,0.00);	

	IF NEW.vl_pagar_for > 0 THEN 
		NEW.fechamento = 1;
		NEW.vl_despesas_diretas = v_total_despesas  + NEW.vl_pagar_for  - v_acrescimos;
	ELSE 
		NEW.vl_despesas_diretas = v_total_despesas;
	END IF;
	
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
