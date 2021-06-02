-- Function: public.f_scr_atualiza_tabela_frete_2(text, text, date)

-- DROP FUNCTION public.f_scr_atualiza_tabela_frete_2(text, text, date);

CREATE OR REPLACE FUNCTION public.f_scr_atualiza_tabela_frete_2(
    p_lista_id_tabelas text,
    p_lista_reajustes text,
    p_data_vigencia date)
  RETURNS text AS
$BODY$
DECLARE	
	v_usuario 		integer;
	v_tabelas		text[];
	v_empresa		character(3);
	v_filial		character(3);
	va_reajuste		text[];
	v_sequencia 		text;
	v_numero_tabela_frete_antigo   text;
	v_numero_tabela_frete	text;
	v_id_tabela_frete 	integer;
	v_cursor 		integer;
	vCursor 		refcursor;
	i			integer;
	lst_ids			text;
	p_id_tabela_frete	integer;

BEGIN	

	--v_empresa 		= fp_get_session('pst_cod_empresa');
	--v_filial 		= fp_get_session('pst_filial');
	v_usuario 		= COALESCE(fp_get_session('pst_usuario')::integer,1);



	v_tabelas = string_to_array(p_lista_id_tabelas,',');

	lst_ids = '';
	FOR i IN 1..array_length(v_tabelas, 1)
	LOOP
		SELECT numero_tabela_frete INTO v_numero_tabela_frete_antigo FROM scr_tabelas WHERE id_tabela_frete = v_tabelas[i]::integer;

		p_id_tabela_frete = v_tabelas[i]::integer;
		v_empresa = substr(v_numero_tabela_frete_antigo,1,3);
		v_filial = substr(v_numero_tabela_frete_antigo,4,3);
		
		v_sequencia 		= 'scr_tabelas_' || v_empresa || '_' || v_filial || '_seq';
		
		v_numero_tabela_frete 	= v_empresa || v_filial || trim(to_char(proximo_numero_sequencia(v_sequencia),'0000000'));
		
		OPEN vCursor FOR 
		INSERT INTO scr_tabelas(
			numero_tabela_frete, 
			id_tabela_frete_principal,
			is_tabela_vinculada,
			descricao_tabela, 
			informacoes_tabela, 
			cabecalho, 
			observacoes, 
			vigencia_tabela, 
			aplicacao_tabela, 
			validade_dias, 
			usar_descontos, 
			imposto_incluso, 
			isento_imposto, 
			tipo_tabela, 
			a_vista, 
			reajuste_automatico, 
			ativa, 
			limite_peso_isento, 
			limite_valor_isento, 
			calcular_a_partir_de, 		
			cnpj_transportador, 		
			perc_max_desconto,
			nao_cotar,
			percentual_devolucao,
			percentual_reentrega,
			usa_valor_veiculo_maior,
			usa_limite_fracionado_menor,
			cnpj_cliente
		)
		SELECT
			v_numero_tabela_frete, 
			p_id_tabela_frete,
			0,
			descricao_tabela, 
			informacoes_tabela, 
			cabecalho, 
			observacoes, 
			p_data_vigencia, 
			p_data_vigencia, 
			validade_dias, 		
			usar_descontos, 
			imposto_incluso, 
			isento_imposto, 
			tipo_tabela, 
			a_vista, 
			reajuste_automatico, 
			0, 
			limite_peso_isento, 
			limite_valor_isento, 
			calcular_a_partir_de, 		
			cnpj_transportador, 		
			perc_max_desconto,
			nao_cotar,
			percentual_devolucao,
			percentual_reentrega,
			usa_valor_veiculo_maior,
			usa_limite_fracionado_menor,
			cnpj_cliente
		FROM 
			scr_tabelas
		WHERE 	
			id_tabela_frete = p_id_tabela_frete
		RETURNING id_tabela_frete;

		FETCH vCursor INTO v_id_tabela_frete;

		IF i = 1 THEN 
			lst_ids = lst_ids ||  v_id_tabela_frete::text;
		ELSE
			lst_ids = lst_ids ||  ',' || v_id_tabela_frete::text;
		END IF;
		
		CLOSE vCursor;
		
		--Faz uma cópia das rotas da tabela principal
		INSERT INTO scr_tabelas_origem_destino(
			id_origem_destino, 
			id_origem_destino_principal,
			tipo_rota, 
			id_tabela_frete, 
			id_origem, 
			id_destino, 
			prazo_entrega, 
			densidade, 
			limite_peso_isento, 
			limite_valor_isento, 
			calcular_a_partir_de, 
			ida_volta,		
			cumulativa		
		)	
		SELECT 
			fp_set_get_session('origem_destino_' || id_origem_destino::text,
				proximo_numero_sequencia('scr_tabelas_origem_destino_id_origem_destino_seq')::text)::integer,
			id_origem_destino,
			tipo_rota, 
			v_id_tabela_frete, 
			id_origem, 
			id_destino, 
			prazo_entrega, 
			densidade, 
			limite_peso_isento, 
			limite_valor_isento, 
			calcular_a_partir_de, 
			ida_volta,		
			cumulativa		
		FROM 
			scr_tabelas_origem_destino
		WHERE 
			id_tabela_frete = p_id_tabela_frete;
		
		--Copia os componentes de frete da tabela principal
		INSERT INTO scr_tabelas_cf(
			id_cf, 
			id_cf_principal,
			id_origem_destino, 
			id_tipo_calculo, 
			isento_minimo, 
			compoe_bc, 
			id_faixa, 
			cond_ctrc,
			limite_fracao)
		SELECT 
			fp_set_get_session('cf_' || tcf.id_cf::text,
				proximo_numero_sequencia('scr_tabelas_cf_id_cf_seq')::text)::integer,
			tcf.id_cf,
			fp_get_session('origem_destino_' || tod.id_origem_destino::text)::integer, 
			tcf.id_tipo_calculo, 
			tcf.isento_minimo, 
			tcf.compoe_bc, 
			tcf.id_faixa, 
			tcf.cond_ctrc,
			tcf.limite_fracao
		FROM 
			scr_tabelas_cf tcf
			LEFT JOIN 
				scr_tabelas_origem_destino tod ON tod.id_origem_destino = tcf.id_origem_destino
		WHERE
			tod.id_tabela_frete = p_id_tabela_frete;

		
		--Copia as faixas de calculo
		INSERT INTO scr_tabelas_calculos(
			id_calculo_principal,
			id_cf, 
			medida_inicial, 
			medida_final, 
			valor_variavel, 
			valor_fixo, 
			valor_variavel_excedido, 
			valor_fixo_excedido, 
			fracao, 
			id_natureza_carga, 
			unidade_divisao, 
			tipo_veiculo, 
			tipo_carroceria,		
			s1,
			s2,
			s3,
			s4,
			s5,
			s6,
			s7,
			feriado,
			adicional_frete,
			tipo_carga,
			vl_frete_veiculo,
			limite_fracao,
			id_tipo_veiculo,
			tipo_transporte
				
		)
		WITH t AS (
			SELECT unnest(string_to_array(p_lista_reajustes,'|')) as reajustes
		)
		,t1 AS (
			SELECT string_to_array(reajustes,',') as partes FROM t
		)
		,reajustes AS (
			SELECT 
				partes[1]::integer as id_tipo_calculo, 
				partes[2]::numeric(12,2) as percentual 
			FROM t1 
		)		
		SELECT
			tc.id_calculo,
			fp_get_session('cf_' || tc.id_cf::text)::integer, 
			tc.medida_inicial, 
			tc.medida_final, 	
			CASE 	WHEN COALESCE(r.percentual,0.00) = 0 
				THEN tc.valor_variavel
				ELSE tc.valor_variavel + (tc.valor_variavel * r.percentual / 100) 
			END::numeric(14,2) as valor_fixo, 
			
			CASE 	WHEN COALESCE(r.percentual,0.00)  = 0 					
				THEN tc.valor_fixo 
				ELSE tc.valor_fixo + (tc.valor_fixo * r.percentual / 100) 
			END::numeric(12,2) as valor_fixo, 
			
			CASE 	WHEN COALESCE(r.percentual,0.00)  = 0
				THEN tc.valor_variavel_excedido 
				ELSE tc.valor_variavel_excedido + (tc.valor_variavel_excedido * r.percentual / 100) 
			END::numeric(14,2) as valor_variavel_excedido, 
		
			CASE 	WHEN COALESCE(r.percentual,0.00)  = 0
				THEN tc.valor_fixo_excedido 
				ELSE tc.valor_fixo_excedido + (tc.valor_fixo_excedido * r.percentual / 100) 
			END::numeric(12,2) as valor_fixo_excedido, 				
			tc.fracao, 
			tc.id_natureza_carga, 
			tc.unidade_divisao, 
			tc.tipo_veiculo, 
			tc.tipo_carroceria,		
			tc.s1,
			tc.s2,
			tc.s3,
			tc.s4,
			tc.s5,
			tc.s6,
			tc.s7,
			tc.feriado,
			tc.adicional_frete,
			tc.tipo_carga,
			tc.vl_frete_veiculo,
			tc.limite_fracao,
			tc.id_tipo_veiculo,
			tc.tipo_transporte		
		FROM 
			scr_tabelas_calculos tc
			LEFT JOIN scr_tabelas_cf tcf 
				ON tc.id_cf = tcf.id_cf
			LEFT JOIN scr_tabelas_origem_destino tod 
				ON tod.id_origem_destino = tcf.id_origem_destino
			LEFT JOIN reajustes r
				ON r.id_tipo_calculo = tcf.id_tipo_calculo
		WHERE 
			tod.id_tabela_frete = p_id_tabela_frete;



		--GRAVA LOG DE OCORRÊNCIAS DA TABELA DE FRETE ANTIGA	
		INSERT INTO scr_tabelas_workflow(
			data_transacao,
			id_usuario, 
			acao_executada, 
			historico, 
			id_tabelas_frete)
		VALUES (
			now(), 
			1,
			'REAJUSTADA P/ TABELA N.: ' || v_numero_tabela_frete,
			NULL,
			p_id_tabela_frete);


		--GRAVA LOG DE OCORRÊNCIAS DA TABELA DE FRETE NOVA
		INSERT INTO scr_tabelas_workflow(
			data_transacao, 
			id_usuario, 
			acao_executada, 
			historico, 
			id_tabelas_frete
		)
		VALUES (
			now(), 
			1,
			'REAJUSTADA DE TABELA N.: ' || v_numero_tabela_frete_antigo,
			NULL,
			v_id_tabela_frete);


		--Ativa Tabela Frete Criada
		IF  p_data_vigencia <= current_date THEN 
			PERFORM ativa_tabela_frete_2(v_numero_tabela_frete, p_id_tabela_frete);
		END IF;
		
		
	END LOOP;


	
	RETURN lst_ids;
 END
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
