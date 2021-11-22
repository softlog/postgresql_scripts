/*
	SELECT f_relatorio_viagem_automatico(
		'005', 
		'001', 
		'2110', 
		0, 
		NULL,  
		'2019-07-01', 
		'2019-07-30', 
		4620, 
		11, 
		'112478,113444,113692,112878,112724,113003,113226,113555,113124,113314,112599'
	) as relatorio_viagem



SELECT * FROM scr_relatorio_viagem
	DELETE FROM scr_relatorio_viagem CASCADE

	SELECT * FROM scr_relatorio_viagem_romaneios 
*/


CREATE OR REPLACE FUNCTION f_relatorio_viagem_automatico(p_cod_empresa text, p_cod_filial text, p_chave text, por_veiculo integer, p_placa_veiculo text,  p_data_inicio date, p_data_fim date, p_valor_pagar numeric(12,2), qt_diarias integer, p_lista_romaneios text, p_id_centro_custo integer)
  RETURNS text AS
$BODY$
DECLARE
     qt integer;          
     v_categoria_acerto integer;
     v_id_fornecedor integer;
     v_id_relatorio_viagem integer;
     vCursor refcursor;
     i integer;
     str_sql text;
     v_valor_pagar numeric(12,2);
     v_numero_relatorio character(13);
BEGIN

	--SELECT * FROM scr_relatorio_viagem 

	v_numero_relatorio = p_cod_empresa || p_cod_filial 
		|| lpad(trim(proximo_numero_sequencia('scr_relatorio_viagens_' || p_cod_empresa || '_' || p_cod_filial)::text), 7, '0');
	
	SELECT 
		id_fornecedor,
		CASE WHEN tipo_funcionario = 1 THEN 3 ELSE 1 END 
	INTO 
		v_id_fornecedor,
		v_categoria_acerto 
	FROM 
		fornecedores
	WHERE 
		id_fornecedor = p_chave::integer;


	
	OPEN vCursor FOR
	INSERT INTO PUBLIC.scr_relatorio_viagem (
		categoria_acerto
		,filial
		,empresa
		,id_fornecedor
		,numero_relatorio
		,fechamento_inicial
		,fechamento_final
		,data_relatorio
		,historico
		,vl_servico_for	
		,qtde_diarias
		,parcelas
		,periodicidade
	) VALUES (
		v_categoria_acerto
		,p_cod_filial
		,p_cod_empresa
		,p_chave::integer
		,v_numero_relatorio
		,p_data_inicio
		,p_data_fim
		,current_date
		,'ACERTO RELATÓRIO DE VIAGEM Nº' || v_numero_relatorio
		,p_valor_pagar
		,qt_diarias
		,1
		,1
	)
	RETURNING id_relatorio_viagem;

	FETCH vCursor INTO v_id_relatorio_viagem;

	CLOSE vCursor;

	--Associa romaneios ao relatorio de viagem;
	str_sql = 'INSERT INTO scr_relatorio_viagem_romaneios(id_relatorio_viagem, id_romaneio) 
		   SELECT  ' || v_id_relatorio_viagem::text 
		   || ', id_romaneio FROM scr_romaneios WHERE id_romaneio IN (' 
		   || p_lista_romaneios || '); 
		   UPDATE scr_romaneios SET id_acerto = ' || v_id_relatorio_viagem::text 
		   || ' WHERE id_romaneio IN (' || p_lista_romaneios || ')';

	EXECUTE str_sql;

	OPEN vCursor FOR
	WITH t AS ( 
		SELECT id_romaneio_despesa
			,id_acerto
			,cod_empresa
			,cod_filial
			,a.id_romaneio
			,v_scr_romaneio_despesas.id_unidade
			,unidade
			,v_scr_romaneio_despesas.id_fornecedor
			,nome_razao
			,v_scr_romaneio_despesas.id_despesa
			,tipo_controle
			,valor_despesa
			,CASE 
				WHEN credito_debito = 1
					THEN valor_despesa
				ELSE 0.00
				END::NUMERIC(12, 2) AS valor_credito
			,CASE 
				WHEN credito_debito = 2
					THEN valor_despesa
				ELSE 0.00
				END::NUMERIC(12, 2) AS valor_debito
			,observacao
			,descricao_despesa
			,data_referencia
			,v_scr_romaneio_despesas.descricao
			,credito_debito
			,forma_pagamento
			,quantidade
			,vl_unitario
			,tipo_operacao	
		FROM 
			scr_relatorio_viagem_romaneios a
			LEFT JOIN v_scr_romaneio_despesas 
				ON  a.id_romaneio = v_scr_romaneio_despesas.id_romaneio
			LEFT JOIN v_scr_despesas_viagem 
				ON v_scr_romaneio_despesas.id_despesa = v_scr_despesas_viagem.id_despesa
			LEFT JOIN efd_unidades_medida 
				ON v_scr_romaneio_despesas.id_unidade = efd_unidades_medida.id_unidade
			LEFT JOIN fornecedores 
				ON v_scr_romaneio_despesas.id_fornecedor = fornecedores.id_fornecedor
		WHERE 
			a.id_relatorio_viagem = v_id_relatorio_viagem
		
	)
	, t1 AS (
		SELECT 
			SUM (CASE WHEN tipo_operacao = 1 THEN valor_despesa ELSE 0.00 END) as total_acrescimos,
			SUM (CASE WHEN tipo_operacao = 3 THEN valor_despesa ELSE 0.00 END) as total_descontos,		
			SUM (CASE WHEN id_despesa = -1 OR id_despesa = -2 OR (tipo_controle = 5 AND forma_pagamento = 2 AND tipo_operacao = 1) THEN valor_despesa ELSE 0.00 END) as total_pagar,
			SUM (CASE WHEN id_despesa <> -2 AND credito_debito = 2 THEN valor_despesa ELSE 0.00 END) as total_despesas_diretas,
			SUM (CASE WHEN id_despesa <> -2 AND credito_debito = 2 AND forma_pagamento = 1 AND tipo_controle NOT IN (3,5,6) THEN valor_despesa ELSE 0.00 END) as total_a_vista,
			SUM (CASE WHEN id_despesa <> -2 AND credito_debito = 2 AND forma_pagamento = 2 AND tipo_controle NOT IN (3,5,6) THEN valor_despesa ELSE 0.00 END) as total_a_prazo,
			SUM (CASE WHEN id_despesa <> -2 AND credito_debito = 2 AND tipo_controle NOT IN (3,5,6) THEN valor_despesa ELSE 0.00 END) as total_despesas_viagem,
			SUM (CASE WHEN credito_debito = 1 AND tipo_controle = 4 THEN valor_despesa ELSE 0.00 END) as total_provisao_viagem,
			SUM (CASE WHEN credito_debito = 1 AND tipo_controle = 5 THEN valor_despesa ELSE 0.00 END) as total_provisao_reembolso,
			SUM (CASE WHEN tipo_controle = 6 THEN valor_despesa ELSE 0.00 END) as total_provisao_devolucao,
			SUM (CASE WHEN id_despesa = -2 THEn valor_despesa ELSE 0.00 END) as total_despesas_indiretas
		FROM t
	)
	, t2 AS (
		SELECT f_total_frete_relatorio_viagem(v_id_relatorio_viagem) as total_frete
	)
	UPDATE scr_relatorio_viagem SET 
		total_despesas_diretas = t1.total_despesas_diretas - t1.total_provisao_devolucao,
		vl_provisao_viagem = t1.total_provisao_viagem,
		vl_provisao_reembolsar = t1.total_provisao_reembolso,
		vl_provisao_devolucao = t1.total_provisao_devolucao,
		vl_despesas_viagem = t1.total_despesas_diretas - t1.total_provisao_devolucao,
		vl_despesas_a_vista = t1.total_a_vista,
		vl_despesas_a_prazo = t1.total_a_prazo,
		vl_adiantamentos_for = t1.total_descontos,
		vl_acrescimos_for = t1.total_acrescimos,
		vl_pagar_for = t1.total_pagar,
		total_frete = t2.total_frete
	FROM 
		t1, t2
	WHERE 
		id_relatorio_viagem = v_id_relatorio_viagem
	RETURNING vl_pagar_for;
	
	FETCH vCursor INTO v_valor_pagar;

	CLOSE vCursor;
	
	PERFORM f_lanca_cc_relatorio_viagem(v_id_relatorio_viagem,v_valor_pagar,p_id_centro_custo);


	PERFORM f_calc_parc_relatorio_viagem(v_id_relatorio_viagem, 1);

	RETURN v_id_relatorio_viagem::text || ',' || v_numero_relatorio;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


  


