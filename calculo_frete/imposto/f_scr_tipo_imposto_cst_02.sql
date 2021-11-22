-- Function: public.f_scr_tipo_imposto_cst(character, character, character, integer, integer, text, character, integer, integer)
-- DROP FUNCTION public.f_scr_tipo_imposto_cst(character, character, character, integer, integer, text, character, integer, integer);



CREATE OR REPLACE FUNCTION public.f_scr_tipo_imposto_cst(
    puforigem character,
    pufdestino character,
    puftransportadora character,
    pmodal integer,
    st integer,
    pnaturezacarga text,
    ptipocontribuinte character,
    ptipotransporte integer,
    ptipodocumento integer,
    pciffob integer)
  RETURNS integer AS
$BODY$
DECLARE


	vTipoImposto 		integer;
	vAliquotaInterna 	numeric(6,2); 
	vCaso 			integer; 	-- Recebe o caso de operação de frete interestadual
	vReducaoNatCarga 	numeric(5,2); 	-- Valor percentual de redução na natureza da carga
	vIsencaoNatCarga 	integer; 	-- Indica que existe isenção
	vTributacaoNormal	integer;	-- Recebe o código da Tributação Normal CST 000 = 1
	vTributacaoSt 		integer; 	-- Contém o código do tipo de imposto cst para ST = 8
	vTributacaoIsenta 	integer; 	-- Contém o código do tipo de imposto cst para Isento = 2
	vBcReduzido 		integer; 	-- Contém o código do tipo de imposto cst para redução de base de cálculo
	vTributacaoOutraUf 	integer; 	-- Contém o código do tipo de imposto cst para Imposto devido a outra UF = 9
	vOptanteSimples 	integer; 	-- Recebe o código de Tributação Especial do Contribuinte Optante pelo Simples
	vRegimeTributario 	integer;	-- Contém o valor parametrizado por filial que indica se a empresa faz parte do simples
	vEmpresa 		text; 		-- Contém a empresa logada
	vFilial  		text;		-- Contém a filial logada
	vIcmsMinuta 		integer;	-- Indicador de cobrança de icms de minuta
	vTipoContribuinte 	character;	-- Variavel para processamento de parâmetro passado
	vIsenInternoC 		integer;	-- Indica se existe isensão interna para contribuinte
	vIsenInternoN 		integer;	-- Indica se existe isensão interna para não contribuinte
	vTemRegra		integer;	-- Indica se encaixa em regra especifica de uf	
	
BEGIN	

	vEmpresa = fp_get_session('pst_cod_empresa');
	vFilial  = fp_get_session('pst_filial');

	-- Parte 0.0	- Determina o caso da operação de frete entre estados, com os possíveis retornos:		
	--	 	1 = 'Frete Estadual, com Transportadora no Estado'
	--		2 = 'Frete Interestadual, com Transportadora no Estado de Origem'
	-- 		3 = 'Frete Interestadual, com Transportadora fora do estado de Origem'
	--		4 = 'Frete Estadual, com Transportadora fora do estado de Origem'
	
	vCaso = f_scr_caso_operacao_frete(puforigem,pufdestino,puftransportadora);

	--*********************************************************************************************************
		-- Parte 0.05	- Alteracao para verificar regras especificas no estado
	--*********************************************************************************************************	
	-- Isencao Portaria PORTARIA 47/2000
	
	IF vCaso = 1 AND pciffob = 1 THEN 
		SELECT 
			count(*)
		INTO
			vTemRegra
		FROM 
			estado_regras_fiscais erf 
			LEFT JOIN estado 
				ON estado.id_estado_pk = erf.id_estado
			LEFT JOIN scr_natureza_carga_icms nci 
				ON nci.id_estado_regra_fiscal = erf.id
			LEFT JOIN scr_natureza_carga nc
				ON nc.id_natureza_carga = nci.id_natureza_carga
		WHERE 
			erf.id_tipo_imposto = 14
			AND trim(nc.natureza_carga) = trim(pnaturezacarga)
			AND estado.id_estado = puforigem;

		IF vTemRegra = 1 THEN 
			RETURN 14;
		END IF;	
			
			
	END IF;
	
	--Diferimento de ICMS
	IF vCaso = 2  THEN 
	
		SELECT 
			count(*)
		INTO
			vTemRegra
		FROM 
			estado_regras_fiscais erf 
			LEFT JOIN estado 
				ON estado.id_estado_pk = erf.id_estado
			LEFT JOIN scr_natureza_carga_icms nci 
				ON nci.id_estado_regra_fiscal = erf.id
			LEFT JOIN scr_natureza_carga nc
				ON nc.id_natureza_carga = nci.id_natureza_carga		
				
		WHERE 
			erf.id_tipo_imposto = 13
			AND trim(nc.natureza_carga) = trim(pnaturezacarga)
			AND estado.id_estado = puforigem;

		IF vTemRegra = 1 THEN 
			RETURN 13;
		END IF;
		
			
	END IF;


	--*********************************************************************************************************
		-- Parte 0.1	- Alteração para nao cobrar icms de subcontrato
	--*********************************************************************************************************	
	
	
	IF ptipotransporte IN (18, 24, 22, 23) THEN 
		RETURN 2;
	END IF;

	--*********************************************************************************************************
		-- Parte 0.2	- Alteração para isenção de imposto de minuta
	--*********************************************************************************************************	

	--Verifica se isenta minuta
	SELECT 	valor_parametro::integer 
	INTO 	vIcmsMinuta 
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa 
		AND upper(cod_parametro) = 'PST_ICMS_MINUTA';
		

	IF ptipodocumento = 2 AND COALESCE(vIcmsMinuta,1) = 0 THEN 
		RETURN 2;
	END IF;
	

	--*********************************************************************************************************
		-- Parte 0.3	- Alteração para atender as empresas enquadradas no simples
	--*********************************************************************************************************	

	--Regime Tributario
	SELECT 	regime_tributario
	INTO 	vRegimeTributario 
	FROM 	filial
	WHERE 
		codigo_empresa = vEmpresa 
		AND codigo_filial  = vFilial;

	--PERFORM f_debug('valor regime',vRegimeTributario::text);
	IF vRegimeTributario = 1 THEN 
		RETURN 11;
	END IF;


		
	--*********************************************************************************************************
		-- Parte 1	- Busca dos dados necessários no banco de dados
	--*********************************************************************************************************	
	-- Parte 1.01   - Alteração para tratar casos específicos 
	-- Contribuinte optante pelo simples em operação estadual dentro de MG
	vTipoContribuinte = ptipocontribuinte;
	IF vTipoContribuinte = 'S' THEN
		IF NOT (puforigem = 'MG' AND pufdestino = 'MG') THEN
			vTipoContribuinte = 'C';			
		END IF;	
	END IF;	
	
	
	
	-- Parte 1.2	- Verifica se existe isenção por natureza da carga
	SELECT 
		isento_icms, 
		perc_red_bc 
	INTO 
		vIsencaoNatCarga,
		vReducaoNatCarga
	FROM 
		scr_natureza_carga
	WHERE 
		trim(natureza_carga) = trim(pnaturezacarga);


	-- Parte 1.1	- Verifica se tem isencoes em operacoes internas
	IF vCaso IN (1,4) THEN		
		SELECT 
			isen_interno_c,
			isen_interno_n
		INTO 
			vIsenInternoC,
			vIsenInternoN
		FROM
			estado
		WHERE 
			id_estado = puforigem;
	ELSE 
		vIsenInternoC = 0;
		vIsenInternoN = 0;
	END IF;

	
	
	--*********************************************************************************************************	
		-- Parte 2 	- Configuração das variaveis de tipo de Imposto
	--*********************************************************************************************************
	-- Parte 2.1 	- Seta o valor do ICMS com tributação Normal para 1, que é o valor padrão;
	vTributacaoNormal = 1;

		
	-- Parte 2.2 	- Seta o valor do tipo de Tributação por Substituição Tributária
	vTributacaoSt = NULL; 
	IF st = 1 THEN 
		--Se for o caso de Substituição Tributária		
		IF 	(vCaso IN (2,3) AND puforigem = 'GO' AND pmodal = 2) 
			OR (vCaso IN (1,4) AND puforigem = 'GO') 
			OR (vCaso IN (2,3) AND puforigem = 'GO' AND ptipocontribuinte = 'N' AND pmodal = 1) THEN 
			vTributacaoSt = NULL;
		ELSE
			vTributacaoSt = 8; 
		END IF;
	END IF;


	-- Parte 2.3	- Seta o valor do tipo de Tributação Insenta
	vTributacaoIsenta = NULL;
	IF vIsencaoNatCarga = 1 THEN
		vTributacaoIsenta = 2;
	END IF;

	IF vTipoContribuinte IN ('C') AND vIsenInternoC = 1 THEN
		 vTributacaoIsenta = 2;
	END IF;

	IF vTipoContribuinte IN ('N') AND vIsenInternoN = 1 THEN
		 vTributacaoIsenta = 2;
	END IF;

	
	-- Parte 2.4 	- Seta o valor do tipo de Tributação de Imposto Devido em Outra UF
	vTributacaoOutraUf = NULL;
	IF vCaso IN (3,4) THEN 
		vTributacaoOutraUf = 9;
	END IF;

	-- Parte 2.5 	- Seta o valor do tipo de Tributação com Redução de Base de Calculo
	vBcReduzido = NULL;
	IF vCaso IN (2,3) AND vReducaoNatCarga > 0.00 THEN 
		vBcReduzido = 10;
	END IF;
	

	--*********************************************************************************************************	
		-- Parte 3 	- Definição do tipo de imposto e resultado
	--*********************************************************************************************************
	vTipoImposto = COALESCE(vTributacaoIsenta, vBcReduzido, vTributacaoOutraUf, vTributacaoSt, vTributacaoNormal);
	
	RETURN vTipoImposto;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
