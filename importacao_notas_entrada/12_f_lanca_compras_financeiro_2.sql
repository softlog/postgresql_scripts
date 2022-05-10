-- Function: public.f_lanca_compras_financeiro()
-- DROP FUNCTION public.f_lanca_compras_financeiro();
-- SELECT f_lanca_compras_financeiro_2('2341', '2022-02-15',  78) as id_conta_pagar
-- SELECT codigo as tipo_documento, codigo || '-' || descricao as documento FROM efd_mod_doc_fiscal ORDER BY codigo
-- SELECT * FROM com_compras ORDER BY 1 DESC LIMIT 10



-- DROP FUNCTION public.f_lanca_compras_financeiro_2(p_lista_id text, p_data_vencimento date,  p_id_centro_custo integer);
CREATE OR REPLACE FUNCTION public.f_lanca_compras_financeiro_2(p_lista_id text, p_data_vencimento date,  p_id_centro_custo integer, p_id_fornecedor integer, p_historico text)
  RETURNS text AS
$BODY$
DECLARE
	vCursor refcursor;
	vTabela text;	
	vCampo text;
	vCommand text;	
	vEmpresa character(3);
	vFilial character(3);
	vHistorico text;
	vCnpjFornecedor character(18);
	vIdFornecedor integer;
	vDataEmissao timestamp;
	vNumeroDocumento character(13);
	vIdContaPagar integer;
	vNumeroChave integer;
	vNumeroOrdemPagamento character(13);	
	vLancamentoContaPagar integer;	
	vNumeroCompra character(13);	
	vUpdate boolean;
	vIdCompra integer;	
	vAguardandoBoleto integer;
	vTotalCompra numeric(12,2);
BEGIN	

	vEmpresa = fp_get_session('pst_cod_empresa');
	vFilial = fp_get_session('pst_filial');

	
	SELECT proximo_numero_sequencia('scf_contas_pagar_' || vEmpresa || '_' || vFilial || '_seq') INTO vNumeroChave;	
	vNumeroOrdemPagamento = vEmpresa || vFilial || TRIM(to_char(vNumeroChave,'0000000'));

	IF p_historico = '' THEN 
		vHistorico = 'AGRUPAMENTO DE COMPRAS OU CONTRATACAO DE SERVICO';
	ELSE
		vHistorico = p_historico;
	END IF;
	

	vIdFornecedor = p_id_fornecedor;
	--SELECT * FROM com_compras LIMIT 1

	WITH compras AS (
		SELECT (unnest(string_to_array(p_lista_id, ',')))::integer id_compra

	)
	SELECT		
		SUM(vl_total) as vl_total		
	INTO
		vTotalCompra
	FROM
		compras
		LEFT JOIN com_compras ON com_compras.id_compra = compras.id_compra;
		
	


	OPEN vCursor FOR 
	INSERT INTO scf_contas_pagar 	(	
		numero_ordem_pagamento,
		filial,
		empresa,
		id_fornecedor,
		numero_documento,
		emissao_documento,
		data_registro,
		historico_conta,
		data_vencimento,
		valor_previsto,								
		data_referencia,
		status_conta
	)
	SELECT
		vNumeroOrdemPagamento,
		vFilial,
		vEmpresa,
		vIdFornecedor,
		RIGHT(vNumeroOrdemPagamento,7),
		current_date,
		current_timestamp,
		vHistorico,
		p_data_vencimento,
		vTotalCompra,
		p_data_vencimento,
		4
	RETURNING id_conta_pagar;
	
	FETCH vCursor INTO vIdContaPagar;

	CLOSE vCursor;
		
		
	INSERT INTO scf_contas_pagar_centro_custos (id_conta_pagar, id_centro_custo, valor) 
	VALUES (vIdContaPagar, p_id_centro_custo, vTotalCompra);

	
	--Log de atividades da Ordem de Pagamento
	INSERT INTO scf_contas_pagar_workflow (data_transacao, id_usuario, texto_justificativo, id_contas_pagar)
	VALUES (now(), COALESCE(fp_get_session('pst_usuario')::integer,1)::integer, 'DOCUMENTO GERADO AUTOMATICO AGRUPAMENTO COMPRAS',vIdContaPagar);


	--Associa documento entrada com a ordem de pagamento
	WITH compras AS (
		SELECT (unnest(string_to_array(p_lista_id, ',')))::integer id_compra

	)
	UPDATE com_compras SET conta_pagar_id = vIdContaPagar FROM compras WHERE compras.id_compra = com_compras.id_compra;


	--Gera log de atividade no documento de entrada
	WITH compras AS (
		SELECT (unnest(string_to_array(p_lista_id, ',')))::integer id_compra

	)
	INSERT INTO com_compras_log_atividades (
		id_compra, 
		data_hora, 
		atividade_executada, 
		usuario
	) 
	SELECT
		compras.id_compra,
		now(),
		'INCLUIDO EM ORDEM PAGTO ' || vNumeroOrdemPagamento,
		COALESCE(fp_get_session('pst_login'),'suporte')
	FROM 
		compras;
	
	

	RETURN vNumeroOrdemPagamento;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
