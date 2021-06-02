-- Function: public.f_scr_replica_tabela_frete(integer, integer, numeric, integer)
/*
SELECT fp_set_session('pst_cod_empresa','001');
SELECT fp_set_session('pst_filial','001');
SELECT fp_set_session('pst_usuario','1');
-- DROP FUNCTION public.f_scr_replica_tabela_frete(integer, integer, numeric, integer);
SELECT * FROM scr_tabelas_tmp ORDER BY 1 


SELECT f_restore_tabela_frete(16,0,0,0)

SELECT * FROM scr_tabelas ORDER BY 1

*/

CREATE OR REPLACE FUNCTION public.f_restore_tabela_frete(
    p_id_tabela_frete_principal integer,
    is_vinculada integer,
    p_percentual numeric,
    p_generalidades integer)
  RETURNS integer AS
$BODY$
DECLARE

	v_empresa 		text;
	v_filial 		text;
	v_numero_tabela_frete 	text;
	v_usuario 		integer;
	v_sequencia 		text;
	v_id_tabela_frete 	integer;
	v_cursor 		integer;
	vCursor 		refcursor;

BEGIN	

	v_empresa 		= fp_get_session('pst_cod_empresa');
	v_filial 		= fp_get_session('pst_filial');
	v_usuario 		= fp_get_session('pst_usuario')::integer;

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
		perc_max_desconto
	)
	SELECT
		numero_tabela_frete, 
		p_id_tabela_frete_principal,
		is_vinculada,
		descricao_tabela, 
		informacoes_tabela, 
		cabecalho, 
		observacoes, 
		current_date, 
		current_date, 
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
		perc_max_desconto
	FROM 
		scr_tabelas_tmp
	WHERE 	
		id_tabela_frete = p_id_tabela_frete_principal
	RETURNING id_tabela_frete;

	FETCH vCursor INTO v_id_tabela_frete;

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
		ida_volta 
		
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
		ida_volta
		
	FROM 
		scr_tabelas_origem_destino_tmp
	WHERE 
		id_tabela_frete = p_id_tabela_frete_principal;


	--Copia os componentes de frete da tabela principal
	INSERT INTO scr_tabelas_cf(
		id_cf, 
		id_cf_principal,
		id_origem_destino, 
		id_tipo_calculo, 
		isento_minimo, 
		compoe_bc, 
		id_faixa, 
		cond_ctrc)
	SELECT 
		fp_set_get_session('cf_' || tcf.id_cf::text,
			proximo_numero_sequencia('scr_tabelas_cf_id_cf_seq')::text)::integer,
		tcf.id_cf,
		fp_get_session('origem_destino_' || tod.id_origem_destino::text)::integer, 
		tcf.id_tipo_calculo, 
		tcf.isento_minimo, 
		tcf.compoe_bc, 
		tcf.id_faixa, 
		tcf.cond_ctrc
	FROM 
		scr_tabelas_cf_tmp tcf
		LEFT JOIN 
			scr_tabelas_origem_destino_tmp tod ON tod.id_origem_destino = tcf.id_origem_destino
	WHERE
		tod.id_tabela_frete = p_id_tabela_frete_principal;

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
		tipo_carroceria	
	)
	SELECT
		tc.id_calculo,
		fp_get_session('cf_' || tc.id_cf::text)::integer, 
		tc.medida_inicial, 
		tc.medida_final, 		
		tc.valor_variavel,
		tc.valor_fixo,
		tc.valor_variavel_excedido,
		tc.valor_fixo_excedido,
		tc.fracao, 
		tc.id_natureza_carga, 
		tc.unidade_divisao, 
		tc.tipo_veiculo, 
		tc.tipo_carroceria
	FROM 
		scr_tabelas_calculos_tmp tc
		LEFT JOIN scr_tabelas_cf_tmp tcf ON tc.id_cf = tcf.id_cf
		LEFT JOIN scr_tabelas_origem_destino_tmp tod ON tod.id_origem_destino = tcf.id_origem_destino
	WHERE 
		tod.id_tabela_frete = p_id_tabela_frete_principal;
	

	INSERT INTO scr_tabelas_workflow(
		id_tabelas_frete,
		data_transacao, 
		id_usuario, 
		acao_executada		
	)
	VALUES (
		v_id_tabela_frete,
		now(),
		v_usuario,
		'INCLUSÃO'	
	);

	 
	RETURN v_id_tabela_frete;
 END
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
