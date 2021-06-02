-- Function: public.f_emite_conhecimento_automatico_normal(integer[], integer, integer, refcursor, refcursor, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_emite_conhecimento_automatico_normal(integer[], integer, integer, refcursor, refcursor, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_recupera_conhecimento_automatico_normal(
    p_id_nf integer,
    pidconhecimento integer,
    p_dh_emissao timestamp,
    p_numero_conhecimento character(7), 
    p_chave_cte text,
    cf refcursor,    
    msg refcursor,    
    imposto_cf refcursor,
    imposto refcursor,
    msg_imposto refcursor)
  RETURNS integer AS
$BODY$
DECLARE
	vIdConhecimento 		integer;
	vCursor 			refcursor;
	vPeso 				numeric(12,2);
	vVolume 			numeric(12,2);
	nf 				integer;
	vTotalFrete 			numeric(12,2);
	vResultadoFrete			t_scr_conhecimento_cf%rowtype;
	vResultadoImposto 		t_scr_conhecimento_cf%rowtype;		

	vNumeroConhecimento 		character(13);
	vNumeroDocumento  		character(13);	
	vTipoDocumento 			integer;
	vSerieDoc 			integer;
	vModal 				integer;
	vAmbienteCte 			integer;
	vTipoImposto 			integer;
	vTotalDesconto 			numeric(12,2);	
	vGrupoRemetente 		text;
	v_dados_icms 			json;

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
	v_json_imposto			json;

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

	v_empresa 			character(3);
	v_filial			character(3);
	

BEGIN	
	-- Alterações: 30/04/2015
	-- 1 - Correcao de vGrupoRemetente 
	-- Alterações: 03/03/2015
	-- 2 - Calculo do DIFAL
	
	
	--Gera o registro de conhecimento e adiciona as notas fiscais
	vIdConhecimento = pidconhecimento;
		
	
	vIdConhecimento = f_cria_nota_fiscal_conhecimento(p_id_nf,vIdConhecimento,0);
	

	IF vIdConhecimento = 0 THEN 
		RETURN 0;
	END IF;

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
		calculo_difal, --14
		empresa_emitente, 
		filial_emitente
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
		v_calculo_difal, --14
		v_empresa, 
		v_filial
	FROM 
		scr_conhecimento
	WHERE 
		id_conhecimento = vIdConhecimento;

	--Calcular o frete
	--Prepara os dados para calcular o frete
	PERFORM f_scr_calcula_frete(f_scr_parametros_calculo_frete(vIdConhecimento),'cf','msg');
	
	vTotalFrete 	= 0.00;
	vTotalDesconto 	= 0.00;	
	
	--Grava componentes de frete
	LOOP
		
		FETCH IN cf INTO vResultadoFrete;

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
			vIdConhecimento,
			vResultadoFrete.id_tipo_calculo,
			vResultadoFrete.excedente,
			vResultadoFrete.quantidade,
			vResultadoFrete.valor_item,
			vResultadoFrete.valor_total,
			vResultadoFrete.valor_minimo,
			vResultadoFrete.valor_pagar,
			vResultadoFrete.operacao,
			vResultadoFrete.id_faixa,
			vResultadoFrete.combinado,
			vResultadoFrete.modo_calculo,
			vResultadoFrete.perc_desconto,
			vResultadoFrete.desconto,
			vResultadoFrete.valor_pagar_sdesconto
		);				
		vTotalFrete = vTotalFrete + vResultadoFrete.valor_pagar;
		vTotalDesconto = vTotalDesconto + vResultadoFrete.desconto;
	END LOOP;

	CLOSE cf;
	CLOSE msg;

	
	--Calculado o valor da operacao, calcula-se o imposto
	v_valor_operacao = vTotalFrete;
	
	SELECT row_to_json(row) INTO v_json_imposto FROM (
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

	PERFORM f_debug('Imposto Json',v_json_imposto::text);
	
	PERFORM f_scr_get_icms(v_json_imposto,'imposto_cf', 'imposto','msg_imposto');

	
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
			vIdConhecimento,
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
	

--	vNumeroConhecimento 	= f_scr_get_numero_conhecimento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
--	vNumeroDocumento 	= f_scr_get_numero_documento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);	

	vNumeroConhecimento 	= v_empresa || v_filial || p_numero_conhecimento;
	vNumeroDocumento 	= vNumeroConhecimento;

	-- Grava totais e dados consolidados na tabela de conhecimento
	WITH tbl AS 
	(
		SELECT 
			id_conhecimento,
			SUM(valor) as total_valor, 
			SUM(qtd_volumes) as total_qtd_volumes, 
			SUM(volume_cubico) as total_volume_cubico, 
			SUM(peso) as total_peso,
			SUM(peso_transportado) as total_peso_transportado
		FROM 
			scr_conhecimento_notas_fiscais 
		WHERE
 			id_conhecimento = vIdConhecimento
		GROUP BY 
			id_conhecimento
	)
	UPDATE 	scr_conhecimento SET
			valor_nota_fiscal 	= tbl.total_valor,
			qtd_volumes 		= tbl.total_qtd_volumes,
			volume_cubico 		= tbl.total_volume_cubico,
			peso 			= tbl.total_peso,
			peso_transportado	= tbl.total_peso_transportado,
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
			flg_viagem		= 1,
			data_emissao 		= p_dh_emissao,
			cstat			= '000',
			status 			= 2,
			chave_cte		= p_chave_cte					
								
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
		vIdConhecimento, 
		now(), 
		'CALCULO FRETE AUTOMATICO', 
		fp_get_session('pst_login'),
		NULL 
	);	
	
	
-- 	IF vTipoImposto IN (6,7,8,9,10) THEN 
-- 		vImposto = 0.00;
-- 		vBc = 0.00;
-- 		vImpostoSt = vResultadoImposto.valor_pagar;
-- 		vBcSt = vResultadoImposto.quantidade;
-- 		
-- 		IF vResultadoImposto.id_tipo_calculo = 1000 AND vTipoImposto IN (6,7,8) THEN 
-- 			vTotalFrete = vTotalFrete - vResultadoImposto.valor_pagar;
-- 		END IF;
-- 
-- 		-- PERFORM f_debug('antes do remetente', vGrupoRemetente);
-- 		
-- 		IF vResultadoImposto.id_tipo_calculo = 1000 AND vTipoImposto = 9 AND vGrupoRemetente = '33337122' THEN 
-- 			vTotalFrete = vTotalFrete - vResultadoImposto.valor_pagar;
-- 			-- PERFORM f_debug('dentro do grupo', vTotalFrete::text);
-- 		END IF;
-- 	ELSE
-- 		vImposto = vResultadoImposto.valor_pagar;
-- 		vBc = vResultadoImposto.quantidade;
-- 		vImpostoSt = 0.00;
-- 		vBcSt = 0.00;
-- 	END IF ;		

	
	RETURN vIdConhecimento;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
