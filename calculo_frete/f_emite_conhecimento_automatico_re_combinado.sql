-- Function: public.f_emite_conhecimento_automatico_re_combinado(integer[])

-- DROP FUNCTION public.f_emite_conhecimento_automatico_re_combinado(integer[]);

CREATE OR REPLACE FUNCTION public.f_emite_conhecimento_automatico_re_combinado(lstnf integer[])
  RETURNS integer AS
$BODY$
DECLARE
	vIdConhecimento integer;
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
	vSerieDoc text;
	vModal integer;
	vAmbienteCte integer;
	vTipoImposto integer;
	vTotalDesconto numeric(12,2);	
	vCteRegimeEspecial integer;
	vCnpjRemetente text;
	vDataCteRe date;
	vPrimeiraNota integer;
	vTipoTransporte integer;
	vValorCombinado numeric(12,2);		
	vValorCombinadoMinuta numeric(12,2);
	vClienteId integer;
BEGIN	
	
	--Gera o registro de conhecimento e adiciona as notas fiscais	
	
	--Busca dados do documento 
	SELECT 
		CASE WHEN tipo_transporte = 18 THEN pagador.cnpj_cpf ELSE rem.cnpj_cpf END as remetente_cnpj, 
		CASE WHEN tipo_transporte = 18 THEN consignatario_id ELSE remetente_id END as remetente_id, 
		data_cte_re,
		tipo_documento, 
		valor_combinado_re,
		valor_combinado_minuta_re
	INTO 
		vCnpjRemetente,
		vClienteId,
		vDataCteRe,
		vTipoDocumento,
		vValorCombinado,
		vValorCombinadoMinuta
	FROM 
		scr_notas_fiscais_imp
		LEFT JOIN cliente pagador ON pagador.codigo_cliente = consignatario_id
		LEFT JOIN cliente rem ON rem.codigo_cliente = remetente_id
	WHERE
		id_nota_fiscal_imp = lstnf[1];


	--Verifica se existe documento de regime especial naquele dia. 
	SELECT 
		id_conhecimento,
		total_frete 
	INTO 
		vCteRegimeEspecial,
		vTotalFrete
	FROM 
		scr_conhecimento 
	WHERE 
		CASE WHEN tipo_transporte = 18 THEN 
			consig_red_cnpj = trim(vCnpjRemetente)
		ELSE
			remetente_cnpj = trim(vCnpjRemetente)
		END
		AND data_cte_re = vDataCteRe
		AND cancelado = 0
		AND tipo_documento = vTipoDocumento
		AND COALESCE(cstat,'') <> '100';

-- 
-- 	PERFORM f_debug('CNPJ',vCnpjRemetente::text);
-- 	PERFORM f_debug('DATA RE',vDataCteRe::text);
-- 	PERFORM f_debug('Tipo Documento',vTipoDocumento::text);
-- 	PERFORM f_debug('Id Nota',lstnf[1]::text);
	
	--Se não existe cte especial na data, 
	--Fica id = 0
	IF vCteRegimeEspecial IS NULL THEN 
		vCteRegimeEspecial = 0;
		vPrimeiraNota = 1;
	ELSE
		vPrimeiraNota = 0;
	END IF;

-- 	PERFORM f_debug('Id Conhecimento RE',vCteRegimeEspecial::text);
	--vCteRegimeEspecial
	--Verifica se existe cte de regime especial para o remetente naquele dia

	--Adiciona todas as notas no conhecimento independente do destinatario.		
	FOREACH nf IN ARRAY lstnf LOOP
		vCteRegimeEspecial = f_lanca_nota_fiscal_conhecimento(nf,vCteRegimeEspecial,1);
	END LOOP;


	--Insere o valor do frete
	IF vTipoDocumento = 1 THEN 
		vTotalFrete = vValorCombinado;
	ELSE
		vTotalFrete = vValorCombinadoMinuta;
	END IF;

	DELETE FROM scr_conhecimento_cf  WHERE id_conhecimento = vCteRegimeEspecial;
	
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
			vCteRegimeEspecial,
			2,
			0,
			1,
			vTotalFrete,
			vTotalFrete,
			0.00,
			vTotalFrete,
			'C',
			1,
			1,
			1,
			0,
			0,
			vTotalFrete
		);
	
	
	vIdConhecimentoAgrupado = vCteRegimeEspecial;
	
	-- Pega dados do cte regime especial
	SELECT 
		modal,
		tipo_documento,
		serie_doc,		
		tipo_imposto,
		cte_ambiente
	INTO 
		vModal,
		vTipoDocumento,
		vSerieDoc,
		vTipoImposto,
		vAmbienteCte 
	FROM 
		scr_conhecimento 
	WHERE 
		id_conhecimento = vIdConhecimentoAgrupado;

	
	--UPDATE scr_conhecimento SET id_conhecimento_principal = vIdConhecimentoAgrupado WHERE id_conhecimento = vIdConhecimento;
	
		
	--GROUP BY
	--	id_tipo_calculo;
	
	--- Recupera os totais das minutas de re	
	vTipoImposto = 2;
	vTotalDesconto = 0.00;
	vImposto = 0.00;
	vBc = 0.00;
	vImpostoSt = 0.00;
	vBcSt = 0.00;	
	

	--Se não tem número de cte gera um.
	IF vPrimeiraNota = 1 THEN 
		vNumeroConhecimento 	= f_scr_get_numero_conhecimento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
		vNumeroDocumento 	= f_scr_get_numero_documento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);	
	END IF;

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
 			id_conhecimento = vIdConhecimentoAgrupado
		GROUP BY 
			id_conhecimento
	)
	UPDATE 	scr_conhecimento SET
			valor_nota_fiscal = tbl.total_valor,
			qtd_volumes = tbl.total_qtd_volumes,
			volume_cubico = tbl.total_volume_cubico,
			peso = tbl.total_peso			
	FROM	
		tbl 
	WHERE 
		tbl.id_conhecimento = scr_conhecimento.id_conhecimento;

	
	-- Grava dados finais de total de frete, imposto e número de emissão documento
	IF vPrimeiraNota = 1 THEN 
		UPDATE scr_conhecimento SET 
			total_frete = vTotalFrete, 
			desconto = vTotalDesconto,
			tipo_imposto = vTipoImposto,
			imposto = vImposto,
			base_calculo = vBc,
			icms_st = vImpostoSt,
			base_calculo_st_reduzida = vBcSt,
			numero_ctrc_filial = vNumeroConhecimento,
			numero_documento = vNumeroDocumento,
			regime_especial_combinado = 1			
		WHERE 
			id_conhecimento = vIdConhecimentoAgrupado;	
	ELSE
		UPDATE scr_conhecimento SET 
			total_frete = vTotalFrete, 
			desconto = vTotalDesconto,
			tipo_imposto = vTipoImposto,
			imposto = vImposto,
			base_calculo = vBc,
			icms_st = vImpostoSt,
			base_calculo_st_reduzida = vBcSt		
		WHERE 
			id_conhecimento = vIdConhecimentoAgrupado;	
	END IF;
		

	--Grava o log
	IF vPrimeiraNota = 1 THEN 
		INSERT INTO scr_conhecimento_log_atividades(
			id_conhecimento, 
			data_hora, 
			atividade_executada, 
			usuario, 
			historico)
		VALUES (
			vIdConhecimentoAgrupado, 
			now(), 
			'CALCULO FRETE AUTOMATICO', 
			fp_get_session('pst_login'),
			NULL 
			);
	END IF;
	
	
	RETURN vIdConhecimentoAgrupado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

