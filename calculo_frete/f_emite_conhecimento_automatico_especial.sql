-- Function: public.f_emite_conhecimento_automatico_especial(integer[], integer, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_emite_conhecimento_automatico_especial(integer[], integer, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_emite_conhecimento_automatico_especial(
    lstnf integer[],
    pidconhecimento integer,
    cf refcursor,
    imposto refcursor,
    msg refcursor)
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
	vSerieDoc integer;
	vModal integer;
	vAmbienteCte integer;
	vTipoImposto integer;
	vTotalDesconto numeric(12,2);	
	vCteRegimeEspecial integer;
	vCnpjRemetente text;
	vDataCteRe date;
	vPrimeiraNota integer;

BEGIN	
	--Alteração 22/04/15
	-- 1.0 - Verificaçao se o cte re está autorizado, se estiver cria outro na mesma data.


	--Gera o registro de conhecimento e adiciona as notas fiscais	
	vIdConhecimento = pidconhecimento;

	--Busca dados do documento 
	SELECT 
		remetente_cnpj, 
		data_cte_re
	INTO 
		vCnpjRemetente,
		vDataCteRe
	FROM 
		scr_conhecimento 
	WHERE
		id_conhecimento = vIdConhecimento;

	--Verifica se existe cte em regime especial naquele dia. 
	SELECT 
		id_conhecimento 
	INTO 
		vCteRegimeEspecial 
	FROM 
		scr_conhecimento 
	WHERE 
		remetente_cnpj = vCnpjRemetente
		AND data_cte_re = vDataCteRe
		AND cancelado = 0
		AND tipo_documento = 1
		AND COALESCE(cstat,'') NOT IN ('000','100');

	--Se não existe cte especial na data, 
	--Fica id = 0
	IF vCteRegimeEspecial IS NULL THEN 
		vCteRegimeEspecial = 0;
		vPrimeiraNota = 1;
	ELSE
		vPrimeiraNota = 0;
	END IF;
	
	--vCteRegimeEspecial
	--Verifica se existe cte de regime especial para o remetente naquele dia

	--Adiciona todas as notas no conhecimento independente do destinatario.		
	FOREACH nf IN ARRAY lstnf LOOP
		vCteRegimeEspecial = f_lanca_nota_fiscal_conhecimento(nf,vCteRegimeEspecial,1);
	END LOOP;

	IF vCteRegimeEspecial = 0 THEN 
		RETURN 0;
	END IF;
	
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

	--RAISE NOTICE 'Tipo Imposto %', vTipoImposto;
	
	UPDATE scr_conhecimento SET id_conhecimento_principal = vIdConhecimentoAgrupado WHERE id_conhecimento = vIdConhecimento;
	
		
	--GROUP BY
	--	id_tipo_calculo;
	
	--- Recupera os totais das minutas de re
	SELECT
		SUM(c.total_frete),
		SUM(c.desconto),
		SUM(	CASE 	WHEN c.tipo_imposto NOT IN (6,7,8,9,10)
				THEN c.imposto 
				ELSE 0.00
			END),
		SUM(	CASE 	WHEN c.tipo_imposto NOT IN (6,7,8,9,10)
				THEN c.base_calculo 
				ELSE 0.00
			END),
		SUM(	CASE 	WHEN c.tipo_imposto IN (6,7,8,9,10)
				THEN 0.00 
				ELSE icms_st
			END),
		SUM(	CASE 	WHEN c.tipo_imposto IN (6,7,8,9,10)
				THEN 0.00
				ELSE c.base_calculo_st_reduzida
			END)		
	
	INTO 	
		vTotalFrete, 
		vTotalDesconto,
		vImposto,
		vBc,
		vImpostoSt,
		vBcSt
	FROM 	
		scr_conhecimento c		
	WHERE	
		c.id_conhecimento_principal = vIdConhecimentoAgrupado		
		AND cancelado = 0 ;


	--RAISE NOTICE 'Total Frete %', vTotalFrete;
	--RAISE NOTICE 'Imposto %', vImposto;
	--RAISE NOTICE 'Base Calculo %', vBc;
	--RAISE NOTICE 'Impsto ST %', vImpostoSt;
	--RAISE NOTICE 'Base ST %', vBcSt;
	
	--Grava imposto

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
			imposto = vImposto,
			base_calculo = vBc,
			icms_st = vImpostoSt,
			base_calculo_st_reduzida = vBcSt,
			numero_ctrc_filial = vNumeroConhecimento,
			numero_documento = vNumeroDocumento
		WHERE 
			id_conhecimento = vIdConhecimentoAgrupado;	
	ELSE
		UPDATE scr_conhecimento SET 
			total_frete = vTotalFrete, 
			desconto = vTotalDesconto,
			imposto = vImposto,
			base_calculo = vBc,
			icms_st = vImpostoSt,
			base_calculo_st_reduzida = vBcSt		
		WHERE 
			id_conhecimento = vIdConhecimentoAgrupado;	
	END IF;
		


	--Grava o log
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
	
	RETURN vIdConhecimentoAgrupado;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

