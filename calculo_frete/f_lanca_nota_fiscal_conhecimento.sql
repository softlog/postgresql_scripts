-- Function: public.f_lanca_nota_fiscal_conhecimento(integer, integer, integer)

-- DROP FUNCTION public.f_lanca_nota_fiscal_conhecimento(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.f_lanca_nota_fiscal_conhecimento(
    pidnf integer,
    pidconhecimento integer,
    p_cte_regime_especial integer)
  RETURNS integer AS
$BODY$
DECLARE
	vIdConhecimento integer;
	vCursor refcursor;	
	vPeso numeric(12,2);	
	vVolume numeric(12,2);
	vCteAmbiente integer;
	vCteSerie integer;
	vTipoCtrcCte integer;
	vUsarValorPresumido integer;
	vRegimeEspecial integer;	
	v_parametro_frete_aprovado text;
	v_aprovado integer;
	v_empresa text;
	v_usuario text;
	v_codigo_emitente integer;
	v_cnpj_emitente text;
	v_existe integer;	
	v_tipo_documento integer;
	v_id_conhecimento_notas_fiscais integer;
BEGIN	
	-- ULTIMA ALTERACAO: 03-04-2018
	-- Inclusao dos campos com prefixo sap_ para integracao com o sistema da Milenio
	-- Alteracao feita por Nilton Paulino

	vCteAmbiente		= COALESCE(fp_get_session('pst_tipo_ambiente'),'0')::integer;
	vCteSerie		= COALESCE(fp_get_session('pst_cte_serie'),'0')::integer;
	vUsarValorPresumido 	= COALESCE(fp_get_session('pst_usar_valor_presumido'),'0')::integer;
	v_empresa		= COALESCE(fp_get_session('pst_cod_empresa'),'')::text;		
	

	
	IF current_database() = 'softlog_saocarlos2' THEN 
		vCteSerie 	= '999';
	END IF;

-- 	IF v_empresa IS NULL THEN 
-- 		SELECT empresa_emitente 
-- 		INTO v_empresa
-- 		FROM v_mgr_notas_fiscais
-- 		WHERE id_nota_fiscal_imp = pidnf;
-- 	END IF;

-- 	PERFORM fp_set_session('pst_cod_empresa',v_empresa);

-- 	IF pidconhecimento <> 0 THEN 
-- 		SELECT count(*) 
-- 		INTO vExiste
-- 		FROM scr_conhecimento_notas_fiscais 
-- 		WHERE id_conhecimento = pidconhecimento
-- 			AND id_nota_fiscal_imp = pidnf;
-- 	ELSE 
-- 		SELECT * FROM scr_notas_fiscais_imp ORDER BY 1 LIMIT 10
-- 	END IF;
--vRegimeEspecial 	= fp_get_session('pst_regime_especial')::integer;	
	

	--Codigo do Emitente do CTe no Regime Especial SP
	IF p_cte_regime_especial IN (1,2,3,4) THEN
		SELECT 
			codigo_cliente,
			cnpj_cpf
		INTO 
			v_codigo_emitente,
			v_cnpj_emitente
		FROM
			cliente
			LEFT JOIN empresa ON empresa.cnpj = cliente.cnpj_cpf
		WHERE
			codigo_empresa = v_empresa;
	END IF;


	--Percentual de Devolucao
	SELECT 	COALESCE(valor_parametro,'0')
	INTO 	v_parametro_frete_aprovado 
	FROM 	parametros 
	WHERE 	cod_empresa = v_empresa AND upper(cod_parametro) = 'PST_CONTROLAR_FRETE_COMBINADO';

	IF trim(v_parametro_frete_aprovado) = '1' THEN
		v_aprovado = 0;
	ELSE
		v_aprovado = 1;
	END IF;
		 
	--Verifica se gerar cte ou ctrc.
	IF COALESCE(fp_get_session('pst_modulo_cte'),'0')::integer = 1 THEN 
		vTipoCtrcCte = 2;
	ELSE
		vTipoCtrcCte = 1;
	END IF;	
	

	SET datestyle = "ISO, DMY";
			
	IF pidconhecimento = 0 THEN 
		RAISE NOTICE 'Criando registro de Conhecimento';
		
		OPEN vCursor FOR 
		INSERT INTO scr_conhecimento (
			---- EMISSAO DO DOCUMENTO -------
			flg_importado, --(1)
			status, --(2)
			tipo_transporte, --(3)
			empresa_emitente, --(4)
			filial_emitente, --(5)
			tipo_documento, --(6)
			modal, --(7)
			tipo_ctrc_cte, --(8)
			serie_doc, --(8.1)
			cte_ambiente, -- (8.2)			
			----- PARTICIPANTES DO FRETE ---- 			
			frete_cif_fob, --(10)
			remetente_id,--(11)
			remetente_cnpj, --(11.1)
			destinatario_id,--(12) 
			destinatario_cnpj, --(12.1)
			consig_red_id,--(13)	
			consig_red_cnpj, --(13.1)		
			redespachador_id,--(15)
			redespachador_cnpj, --(15.1) 
			avista,--(16)
			tabele_frete,--(17) 		
			-----------  ROTA ---------------
			calculado_de_id_cidade, --(18)
			calculado_ate_id_cidade, --(19)			
			-------- MERCADORIA  ------------
			natureza_carga, --(25)
			--especie, 
			----------- ICMS ----------------
			cod_operacao_fiscal, --(29)
			imposto_incluso, --(30)
			tipo_imposto,--(31) 
			aliquota,--(32)
			aliquota_icms_st, --(34)
			perc_reducao_base_calculo, --(35)			
			--id_conhecimento_principal, --(36)
			regime_especial_mg, --(37)
			data_cte_re, --(38)
-- 			----------- VIAGEM  -------------
 			placa_veiculo,--(39)
 			placa_reboque1, --(40)
 			placa_reboque2,--(41) 
 			id_motorista,--(42)
 			cod_interno_frete, --(43)
 			id_tipo_veiculo, --(44)
			peso_agregado_nf,--(45)
			volume_cubico_agregado_nf,--(46)
			total_entregas, --(47)			
			vl_combinado, --(48)
			vl_tonelada, --(49)
			vl_percentual_nf, --(50)
			codigo_vendedor, --(51)	
			dt_agenda_entrega, --(52)		
			data_previsao_entrega, --(53)
			id_pre_fatura_entrega, --(54)
			vl_frete_peso, --(55)			
			consumidor_final, --(57)
			aliq_icms_interna,--(58)
			aliquota_fcp,--(59)
			valor_fcp,--(60)
			calculo_difal,--(61)
			aliq_icms_inter,--(62)
			observacoes_conhecimento, --(63)
			placa_coleta, --(64)
			aprovado, --(65) 
			conhecimento_origem, --(66)
			tipo_doc_referenciado, --(67)
			dt_agenda_coleta, --68					
			regime_especial_combinado, --69
			flg_viagem, --(70)			
			data_viagem, --(71)
			odometro_inicial, --(72)			
			expedidor_cnpj, --73			
			total_frete_origem, --74
			km_rodado, --75
			qtd_ajudantes, --76
			coleta_escolta, --77
			coleta_expresso, --78
			coleta_emergencia, --79
			coleta_normal, --80
			entrega_escolta, --81
			entrega_expresso, --82
			entrega_emergencia, --83
			entrega_normal, --84
			taxa_dce, --85
			taxa_exclusivo, --86
			coleta_dificuldade, --87
			entrega_dificuldade, --88
			entrega_exclusiva, --89
			coleta_exclusiva, --90			
			desagrupa_destino_viagem --91
			
-- 			redespachador_id
-- 			flg_viagem, --(43)
-- 			responsavel_seguro --(44)
		)
		SELECT 
			--- deixa para disparar a trigger somente depois 
			--- A trigger f_tgg_operacoes_* só será disparada se flg_importado for diferente
			--- de -1			
			-1, --(1)
			0, --(2)
			nf.tipo_transporte, --(3)
			nf.empresa_emitente, --(4)
			nf.filial_emitente, --(5)
			CASE 
				WHEN p_cte_regime_especial IN (2,3,4) 			 THEN 1 --Cte em Regime Especial SP
				WHEN p_cte_regime_especial IN (-2) 			 THEN 2 --Minuta Global
				WHEN p_cte_regime_especial = 1 AND nf.tipo_documento = 1 THEN 1 --Cte em Regime Especial
				WHEN p_cte_regime_especial = 1 AND nf.tipo_documento = 2 THEN 2 --Minuta em Regime Especial				
				WHEN nf.regime_especial_sp = 1 				 THEN 3 --Minuta em Regime Especial
				WHEN nf.regime_especial_mg = 1 				 THEN 3 --Minutas que compoe regime especial.
				ELSE nf.tipo_documento 
			END, --(6)
			nf.modal, --(7)			
			CASE  	WHEN 
					nf.tipo_documento = 1 
					OR (nf.regime_especial_mg = 1 AND (nf.tipo_documento = 1 OR current_database() = 'softlog_dng')) 
					OR p_cte_regime_especial IN (2,3,4) 
				THEN 
					vTipoCtrcCte 
				ELSE 
					NULL 
			END, --(8)
			CASE WHEN vTipoCtrcCte = 2 THEN vCteSerie ELSE NULL END, --(8.1)
			CASE WHEN vTipoCtrcCte = 2 THEN vCteAmbiente ELSE NULL END, --(8.2)
			----- PARTICIPANTES DO FRETE ---- 
			nf.frete_cif_fob, --(10)
			--REMETENTE			
			CASE 	WHEN p_cte_regime_especial = 1 AND tipo_transporte = 18 
				THEN nf.consignatario_id 
				ELSE nf.remetente_id
			END, --(11)
			CASE 	WHEN p_cte_regime_especial = 1 AND tipo_transporte = 18 
				THEN nf.pagador_cnpj 
				ELSE nf.remetente_cnpj
			END, --(11.1)
			--DESTINATARIO
			CASE	
				WHEN p_cte_regime_especial IN (-2,1,2,3,4)
				THEN v_codigo_emitente
				WHEN p_cte_regime_especial = 1 AND tipo_transporte = 18
				THEN v_codigo_emitente
				ELSE nf.destinatario_id
			END,			
			CASE 	
				WHEN p_cte_regime_especial IN (-2,1,2,3,4)
				THEN v_cnpj_emitente			
				WHEN p_cte_regime_especial = 1 AND tipo_transporte = 18
				THEN v_cnpj_emitente
				ELSE nf.destinatario_cnpj
			END,--(12.1) 			
			--PAGADOR
			nf.consignatario_id, --(13)
			nf.pagador_cnpj, --(13.1)
			--REDESPACHADORA
			nf.redespachador_id, --(15)
			nf.transportadora_cnpj, --(15.1)
			nf.avista, --(16)
			CASE 	WHEN p_cte_regime_especial IN (-2,2,3) 
				THEN v_empresa || '0019999999' 
				ELSE COALESCE(trim(cp.valor_parametro),nf.numero_tabela_frete)
			END,--(17)
			-----------  ROTA ---------------	
			nf.calculado_de_id_cidade, --(18)
			nf.calculado_ate_id_cidade, --(19)
			-- CASE 	WHEN p_cte_regime_especial = 1
-- 				THEN nf.calculado_de_id_cidade
-- 				ELSE nf.calculado_ate_id_cidade
-- 			END,--(19)					
			-------- MERCADORIA  ------------
			nf.natureza_carga, --(25)
			--especie, 
			----------- ICMS ----------------
			nf.cfop, --(29)
			nf.imposto_incluso, --(30)
			COALESCE(nf.tipo_imposto,2), --(31)
			nf.aliquota,--(32)
			nf.aliquota_st, --(34)
			nf.perc_base_calculo, --(35)					
			--p_id_conhecimento_principal, --(36)
			CASE WHEN p_cte_regime_especial IN (-2,2,3,4) THEN 1 ELSE nf.regime_especial_mg END, --(37)
			--Parametrizar isto por criterios a serem definidos
			CASE 
				WHEN nf.data_cte_re IS NOT NULL THEN nf.data_cte_re
				WHEN nf.tipo_data = 1 THEN nf.data_expedicao 
				WHEN nf.tipo_data = 2 THEN nf.data_emissao
				ELSE nf.data_emissao
			END::date, --(38)
			--COALESCE(nf.data_cte_re,nf.data_emissao), --(38)
			nf.placa_veiculo, --(39)
			nf.placa_carreta1, --(40)
			nf.placa_carreta2, --(41)
			nf.id_motorista, --(42)			
			nf.cod_interno_frete, --(43)
			nf.id_tipo_veiculo,--(44)
			ca.total_peso,--(45)
			ca.total_volume_cubico,--(46)
			ca.qt_entregas, --(47)	
			nf.vl_combinado, --(48)
			nf.vl_tonelada, --(49)
			nf.vl_percentual_nf, --(50)
			nf.codigo_vendedor, --(51)
			nf.dt_agenda_entrega, --(52)
			nf.data_previsao_entrega, --(53)
			nf.id_pre_fatura_entrega, --(54)
			nf.vl_frete_peso, --(55)
			nf.consumidor_final, --(57)
			nf.aliq_icms_interna,--(58)
			nf.aliquota_fcp,--(59)
			nf.valor_fcp,--(60)
			nf.calculo_difal,--(61)
			nf.aliq_icms_inter,--(62)
			nf.obs, --(65)
			nf.placa_coleta, --(64)			
			CASE WHEN right(trim(nf.numero_tabela_frete),10) = '9999999999' THEN 
				v_aprovado
			ELSE 
				1
			END::integer, --(65)
			nf.chave_cte, --(66)
			CASE WHEN nf.tipo_transporte = 18 THEN 2 ELSE NULL END, --(67)
			--Parametrizar isto por criterios a serem definidos
			CASE 
				WHEN nf.data_cte_re IS NOT NULL THEN nf.data_cte_re
				WHEN nf.tipo_data = 1 THEN nf.data_expedicao 
				WHEN nf.tipo_data = 2 THEN nf.data_emissao
				ELSE nf.data_emissao
			END::timestamp, --(68)
			CASE WHEN p_cte_regime_especial IN (-2, 2,3,4) THEN 1 ELSE regime_especial_combinado END, --69
			nf.flg_viagem_automatica, --70
			nf.data_viagem, --(71)
			nf.odometro_inicial, --(72)				
			nf.expedidor_cnpj, --73
			nf.total_frete_origem, --74
			nf.km_rodado,--75
			nf.qtd_ajudantes, --76
			nf.coleta_escolta, --77
			nf.coleta_expresso, --78
			nf.coleta_emergencia, --79
			nf.coleta_normal, --80
			nf.entrega_escolta, --81
			nf.entrega_expresso, --82
			nf.entrega_emergencia, --83
			nf.entrega_normal, --84
			nf.taxa_dce, --85
			nf.taxa_exclusivo, --86
			nf.coleta_dificuldade, --87
			nf.entrega_dificuldade, --88
			nf.entrega_exclusiva, --89
			nf.coleta_exclusiva, --90			
			nf.desagrupa_destino_viagem --91
						
		FROM 			
			v_mgr_notas_fiscais nf
			LEFT JOIN v_scr_notas_fiscais_carregamento ca
					ON ca.cnpj_cod_interno_frete = nf.cnpj_cod_interno_frete
						AND ca.cod_interno_frete = nf.cod_interno_frete	
			LEFT JOIN cliente_parametros cp
					ON cp.codigo_cliente = nf.remetente_id 
						AND cp.id_tipo_parametro = 160
		WHERE 
			id_nota_fiscal_imp = pidnf
			AND id_conhecimento IS NULL
		LIMIT 1
		RETURNING id_conhecimento, tipo_documento;

		FETCH vCursor INTO vIdConhecimento, v_tipo_documento;

		
		CLOSE vCursor;		
		RAISE NOTICE 'COnhecimento %',vIdConhecimento;
		IF vIdConhecimento IS NULL THEN 
			RETURN 0;
		END IF;
		
		PERFORM fp_set_session('tipo_documento_' || vIdConhecimento::text,v_tipo_documento::text);
	ELSE 

		RAISE NOTICE 'Atualizando Registro de Conhecimento %', pidconhecimento;
		v_tipo_documento = fp_get_session('tipo_documento_' || pidconhecimento::text);
		vIdConhecimento = pidconhecimento;

	END IF;

	-- Insere a Nota Fiscal;
	OPEN vCursor FOR 
	INSERT INTO scr_conhecimento_notas_fiscais (			
			id_conhecimento,
			data_nota_fiscal,
			numero_nota_fiscal,
			modelo_nf,
			serie_nota_fiscal,
			qtd_volumes,
			peso,
			valor,
			volume_cubico,
			tipo_nota,
			numero_pedido_nf,
			valor_base_calculo,
			valor_icms_nf,
			valor_base_calculo_icms_st,
			valor_icms_nf_st,
			cfop_pred_nf,
			valor_total_produtos,
			pin,
			chave_nfe,
			especie_mercadoria,
			peso_liquido,
			tipo_transporte,
			sap_docentry,
			sap_serial,
			sap_tipoobjeto,
			sap_supervisor,
			id_nota_fiscal_imp,
			peso_transportado,
			obs_medidas
		)
		SELECT 	
			vIdConhecimento,
			data_emissao, 
			numero_nota_fiscal, 
			modelo_nf, 
			serie_nota_fiscal, 
			CASE WHEN vUsarValorPresumido = 1 THEN volume_presumido::integer ELSE qtd_volumes END,  
			CASE WHEN vUsarValorPresumido = 1 THEN peso_presumido ELSE peso END, 
			valor, 
			volume_cubico, 
			tipo_nota, 
			numero_pedido_nf, 
			valor_base_calculo, 
			valor_icms_nf, 
			valor_base_calculo_icms_st, 
			valor_icms_nf_st, 
			cfop_pred_nf, 
			valor_total_produtos, 
			pin, 
			chave_nfe,
			especie_mercadoria,
			peso_liquido,
			tipo_transporte,
			sap_docentry,
			sap_serial,
			sap_tipoobjeto,
			sap_supervisor,
			pidnf, 
			peso_transportado,
			obs_medidas
		FROM
			scr_notas_fiscais_imp			
		WHERE
			id_nota_fiscal_imp = pidnf
			AND id_conhecimento IS NULL
		LIMIT 1			
		RETURNING id_conhecimento_notas_fiscais ;

		FETCH vCursor INTO v_id_conhecimento_notas_fiscais;

		CLOSE vCursor;

	IF v_id_conhecimento_notas_fiscais IS NULL THEN 
		IF pidconhecimento = 0 THEN 
			DELETE FROM scr_conhecimento WHERE id_conhecimento = vIdConhecimento;
			vIdConhecimento = 0;
		END IF;
		
		RETURN vIdConhecimento;
	END IF;

	--Se for minuta de frete
	IF v_tipo_documento = 3 THEN 
		UPDATE 
			scr_notas_fiscais_imp 
		SET 
			status = 1, 
			id_minuta_re = vIdConhecimento 
		WHERE id_nota_fiscal_imp = pidnf;		
	ELSE --Documentos Fiscais
		UPDATE 
			scr_notas_fiscais_imp 
		SET 
			status = 1, 
			id_conhecimento = vIdConhecimento 
		WHERE id_nota_fiscal_imp = pidnf;
	END IF;
	
	RETURN vIdConhecimento;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

--SELECT obs_medidas FROM scr_notas_fiscais_imp WHERE obs_medidas IS NOT NULL