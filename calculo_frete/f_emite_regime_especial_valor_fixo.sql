-- Function: public.f_emite_regime_especial_valor_fixo(integer[], numeric, date, integer, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_emite_regime_especial_valor_fixo(integer[], numeric, date, integer, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_emite_regime_especial_valor_fixo(
    lstnf integer[],
    p_valor_fixo numeric,
    p_data_cte_re date,
    p_remetente_id integer,
    imposto_cf refcursor,
    imposto refcursor,
    msg_imposto refcursor)
  RETURNS integer AS
$BODY$
DECLARE
	v_id_conhecimento integer;
	vResultadoImposto t_scr_conhecimento_cf%rowtype;	
	
	vCursor refcursor;
	vaLstNf integer[];	
	vaConhecimentos integer[];
	i integer;
	vIdConhecimentoAgrupado integer;
	nf integer;
	vTotalFrete numeric(12,2);
	
	vImposto numeric(12,2);
	vBc numeric(12,2);	
	vImpostoSt numeric(12,2);
	vBcSt numeric(12,2);	
	vNumeroConhecimento character(13);
	vNumeroDocumento  character(13);	
	vTipoDocumento integer;
	vSerieDoc integer;
	vModal integer;
	vAmbienteCte integer;
	vTipoImposto integer;
	vTotalDesconto numeric(12,2);	
	vCteRegimeEspecial integer;
	vCnpjRemetente text;
	vGrupoRemetente text;
	vDataCteRe date;
	vPrimeiraNota integer;
	vTipoTransporte integer;
	vValorCombinado numeric(12,2);		
	vValorCombinadoMinuta numeric(12,2);
	vClienteId integer;


	--Parametros Para Calculo do Imposto	
	v_valor_operacao 		numeric(12,2);
	v_aliquota			numeric(5,2);
	v_aliquota_icms_st		numeric(5,2);
	v_aliq_icms_inter		numeric(5,2);
	v_aliq_icms_interna 		numeric(5,2);
	v_aliquota_fcp			numeric(5,2);
	v_perc_base_calculo		numeric(12,2);
	v_perc_cred_st			numeric(12,2);
	v_base_calculo_difal		numeric(12,2);
	v_tipo_imposto			integer;
	v_imposto_incluso		integer;
	v_calculo_difal			integer;	
	v_par_imposto			json;

	--Parametros Para Receber Calculo do Impsoto
	v_id_aux			integer;
	v_base_calculo 			numeric(12,2);
	v_imposto			numeric(12,2);
	v_base_calculo_st_reduzida	numeric(12,2);
	v_icms_st			numeric(12,2);
	v_difal_icms_origem		numeric(12,2);
	v_difal_icms_destino		numeric(12,2);
	v_valor_fcp			numeric(12,2);
	v_cf_frete			numeric(12,2);
	
BEGIN		
	RAISE NOTICE '%s', lstnf[1];
	
	--Configura parametros de frete da primeira Nota
	WITH t AS (
            	SELECT
            		id,
            		tipo_imposto,
            		aliquota,
            		aliquota_icms_st,
            		calcula_difal,
            		aliq_icms_inter,
            		aliq_icms_interna,
            		aliquota_fcp,
            		perc_base_calculo,
            		perc_credito_presumido_icms,
            		cfop,
            		msg
            	FROM
		f_scr_get_dados_fiscais_nfs(lstnf[1]::text)
	)
	UPDATE scr_notas_fiscais_imp SET
		tipo_imposto 	= COALESCE(t.tipo_imposto,2),
		aliquota 	= t.aliquota,
		aliquota_st 	= t.aliquota_icms_st,
		calculo_difal 	= t.calcula_difal,
		aliq_icms_inter = t.aliq_icms_inter,
		aliq_icms_interna = t.aliq_icms_interna,
		aliquota_fcp 	= t.aliquota_fcp,
		perc_base_calculo = t.perc_base_calculo,
		cfop = t.cfop,
		modal = COALESCE(modal,1)
	FROM
		t
	WHERE
		t.id = scr_notas_fiscais_imp.id_nota_fiscal_imp;


	SELECT valor_parametro::integer
	INTO vTipoDocumento
	FROM cliente_parametros 
	WHERE id_tipo_parametro = 120 AND codigo_cliente = p_remetente_id;

	
	vTipoDocumento = COALESCE(vTipoDocumento,1);
----------------------------------------------------------------------------------------------------------
	-- Gera o registro de conhecimento e adiciona as notas fiscais			
	--Adiciona todas as notas no conhecimento independente do destinatario.	
	v_id_conhecimento = 0;
	FOREACH nf IN ARRAY lstnf LOOP
		RAISE NOTICE 'Lancando Nota % no conhecimento %', nf, v_id_conhecimento;
		IF vTipoDocumento = 2 THEN 		
			v_id_conhecimento = f_lanca_nota_fiscal_conhecimento(nf,v_id_conhecimento,-2);
		ELSE 
			v_id_conhecimento = f_lanca_nota_fiscal_conhecimento(nf,v_id_conhecimento,2);
		END IF;
	END LOOP;
----------------------------------------------------------------------------------------------------------
	-- Faz lancamento de um registro de componente de frete
	
	INSERT INTO scr_conhecimento_cf 
	(
		id_conhecimento,
		id_tipo_calculo,
		excedente,
		quantidade,
		valor_item,
		valor_total,
		valor_minimo,
		valor_pagar,
		operacao,
		id_faixa,
		combinado,
		modo_calculo,
		perc_desconto,
		desconto,
		valor_pagar_sdesconto
	) VALUES (
		v_id_conhecimento,
		2,
		0,
		1,
		p_valor_fixo,
		p_valor_fixo,
		0.00,
		p_valor_fixo,
		'C',
		1,
		1,
		1,
		0,
		0,
		p_valor_fixo
	);	

	vTotalFrete = p_valor_fixo;

----------------------------------------------------------------------------------------------------------
	-- Recupera informacoes para processamento de imposto e outras coisas
	
	SELECT 
		modal, --1
		tipo_documento, --2
		serie_doc, --3
		tipo_imposto, --4
		cte_ambiente, --5
		left(remetente_cnpj,8), --6
		aliquota, --7
		aliquota_icms_st, --8
		aliq_icms_inter, --9
		aliq_icms_interna, --10
		aliquota_fcp, --11
		perc_reducao_base_calculo, --12		
		imposto_incluso, --13
		calculo_difal --14
	INTO 
		vModal, --1
		vTipoDocumento, --2
		vSerieDoc, --3
		vTipoImposto, --4
		vAmbienteCte, --5
		vGrupoRemetente,--6
		v_aliquota, --7
		v_aliquota_icms_st, --8
		v_aliq_icms_inter, --9
		v_aliq_icms_interna, --10
		v_aliquota_fcp, --11
		v_perc_base_calculo, --12
		v_imposto_incluso, --13
		v_calculo_difal --14
	FROM 
		scr_conhecimento
	WHERE 
		id_conhecimento = v_id_conhecimento;	

----------------------------------------------------------------------------------------------------------
	-- Calcula imposto
	
	-- Definicao do Imposto
	v_valor_operacao = vTotalFrete;
	
	SELECT row_to_json(row) INTO v_par_imposto FROM (
		SELECT  
			v_valor_operacao as valor_operacao, 
			v_aliquota as aliquota,
			v_aliquota_icms_st as aliquota_icms_st, 
			v_aliq_icms_inter as aliq_icms_inter, 
			v_aliq_icms_interna as aliq_icms_interna, 
			v_aliquota_fcp as aliquota_fcp, 
			v_perc_base_calculo as perc_base_calculo, 
			0.00 as perc_cred_st,
			vTipoImposto as tipo_imposto,
			v_imposto_incluso as imposto_incluso,
			v_calculo_difal as calculo_difal
	) row;
	
	RAISE NOTICE '%', v_par_imposto;
	
	PERFORM f_scr_get_icms(v_par_imposto,'imposto_cf', 'imposto','msg_imposto');
	
	LOOP
		FETCH IN imposto_cf INTO vResultadoImposto;

		EXIT 	WHEN NOT FOUND;

		INSERT INTO scr_conhecimento_cf 
		(
			id_conhecimento,
			id_tipo_calculo,
			excedente,
			quantidade,
			valor_item,
			valor_total,
			valor_minimo,
			valor_pagar,
			operacao,
			id_faixa,
			combinado,
			modo_calculo,
			perc_desconto,
			desconto,
			valor_pagar_sdesconto
		) VALUES (
			v_id_conhecimento,
			vResultadoImposto.id_tipo_calculo,
			vResultadoImposto.excedente,
			vResultadoImposto.quantidade,
			vResultadoImposto.valor_item,
			vResultadoImposto.valor_total,
			vResultadoImposto.valor_minimo,
			vResultadoImposto.valor_pagar,
			vResultadoImposto.operacao,
			vResultadoImposto.id_faixa,
			vResultadoImposto.combinado,
			vResultadoImposto.modo_calculo,
			vResultadoImposto.perc_desconto,
			vResultadoImposto.desconto,
			vResultadoImposto.valor_pagar_sdesconto
		);
	END LOOP;

	CLOSE imposto_cf;

	--Recupera dados consolidados do imposto
	FETCH imposto INTO 
			v_id_aux
			,v_base_calculo 
			,v_imposto
			,v_base_calculo_st_reduzida
			,v_icms_st
			,v_base_calculo_difal
			,v_difal_icms_origem
			,v_difal_icms_destino
			,v_valor_fcp
			,v_cf_frete;

	CLOSE imposto;
	CLOSE msg_imposto;


	vTotalFrete 	= vTotalFrete + COALESCE(v_cf_frete,0.00);
	
----------------------------------------------------------------------------------------------------------
	-- Gera o Numero do Documento

	vNumeroConhecimento 	= f_scr_get_numero_conhecimento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
	vNumeroDocumento 	= f_scr_get_numero_documento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);	

	--- Recupera os totais das minutas de re	
	-- Grava totais das notas na tabela de conhecimento		
	WITH tbl AS 
	(
		SELECT 
			id_conhecimento,
			SUM(valor) as total_valor, 
			SUM(qtd_volumes) as total_qtd_volumes, 
			SUM(volume_cubico) as total_volume_cubico, 
			SUM(peso) as total_peso
		FROM 
			scr_conhecimento_notas_fiscais 
		WHERE
 			id_conhecimento = v_id_conhecimento
		GROUP BY 
			id_conhecimento
	)
	UPDATE 	scr_conhecimento SET
			valor_nota_fiscal 	= tbl.total_valor,
			qtd_volumes 		= tbl.total_qtd_volumes,
			volume_cubico 		= tbl.total_volume_cubico,
			peso 			= tbl.total_peso,
			numero_ctrc_filial 	= vNumeroConhecimento,
			numero_documento 	= vNumeroDocumento,			
			total_frete 		= vTotalFrete,
			desconto		= vTotalDesconto,
			imposto			= v_imposto,
			base_calculo		= v_base_calculo,
			icms_st			= v_icms_st,
			base_calculo_st_reduzida= v_base_calculo_st_reduzida,
			base_calculo_difal	= v_base_calculo_difal,
			difal_icms_origem	= v_difal_icms_origem,
			difal_icms_destino	= v_difal_icms_destino,
			valor_fcp		= v_valor_fcp,
			flg_viagem		= 1			
								
	FROM	
		tbl 
	WHERE 
		tbl.id_conhecimento = scr_conhecimento.id_conhecimento;
	

	--Grava o log
	INSERT INTO scr_conhecimento_log_atividades(
		id_conhecimento, 
		data_hora, 
		atividade_executada, 
		usuario, 
		historico)
	VALUES (
		v_id_conhecimento, 
		now(), 
		'CALCULO FRETE AUTOMATICO', 
		fp_get_session('pst_login'),
		NULL 
		);
	
	
	
	RETURN v_id_conhecimento;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

