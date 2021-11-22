-- Function: public.f_scr_cfop_frete(character, character, character, text, integer)

-- DROP FUNCTION public.f_scr_cfop_frete(character, character, character, text, integer);

CREATE OR REPLACE FUNCTION public.f_scr_cfop_frete(
    puforigem character,
    pufdestino character,
    puftransportadora character,
    pclassificacao text,
    ptipoimposto integer)
  RETURNS text AS
$BODY$
DECLARE
	vGrupo 		character(1);
	vOperacao 	character(3);
	vCfop		character(4);
	vCaso		integer;
	checaParametros	text;

BEGIN	

	IF pUfOrigem IS NULL OR pUfDestino IS NULL OR pUfTransportadora IS NULL OR pClassificacao IS NULL OR pTipoImposto IS NULL THEN
		RETURN '';
	END IF;

	
--*********************************************************************************************************
	-- Parte 1	- Busca dos dados necessários no banco de dados
--*********************************************************************************************************	
	-------------------------
	-- Parte 1	- Determina o caso da operação de frete entre estados, com os possíveis retornos:
	--	 	1 = 'Frete Estadual, com Transportadora no Estado'
	--		2 = 'Frete Interestadual, com Transportadora no Estado de Origem'
	-- 		3 = 'Frete Interestadual, com Transportadora fora do estado de Origem'
	--		4 = 'Frete Estadual, com Transportadora fora do estado de Origem'
	vCaso = f_scr_caso_operacao_frete(pUfOrigem,pUfDestino,pUfTransportadora);	

--*********************************************************************************************************
	-- Parte 2	- Seta o grupo do CFOP
--*********************************************************************************************************	
	
	CASE 	
		-- Operação de Frete no Exterior
		WHEN pUfDestino = 'EX'					THEN 
			vGrupo = '7';
			
		-- Operação de Frete Interestadual
		WHEN vCaso IN (2,3)					THEN
			vGrupo = '6';		

		-- Operação de Frete Estadual
		WHEN vCaso IN (1,4) 					THEN
			vGrupo = '5';
		ELSE 
		
	END CASE;


--*********************************************************************************************************
	-- Parte 3	- Seta o código da operação
--*********************************************************************************************************	
	CASE
		-- Tipo de Imposto Exportação
		WHEN vGrupo = '7'	 	THEN
			vOperacao = '358';
		-- Tipo de Imposto com Imposto devido em outro estado
		WHEN vCaso IN (3,4) 		THEN
			vOperacao = '932';
		WHEN pTipoImposto = 9		THEN
			vOperacao = '932';		
		-- Tipo de Imposto por St
		WHEN pTipoImposto IN (6,7,8)	THEN
			vOperacao = '360';
		-- Tipo de Imposto Normal ou Insento
		WHEN pTipoImposto IN (1,2,3,4,10,11, 13, 14) 	THEN
			CASE 
				WHEN pClassificacao = 'OUTRAS' 		THEN
					vOperacao = '949';
				WHEN pClassificacao = 'TRANSPORTE' 	THEN
					vOperacao = '351';
				WHEN pClassificacao = 'INDUSTRIA' 	THEN
					vOperacao = '352';
				WHEN pClassificacao = 'COMERCIO' 	THEN
					vOperacao = '353';
				WHEN pClassificacao = 'COMUNICACAO' 	THEN
					vOperacao = '354';
				WHEN pClassificacao = 'ENERGIA' 	THEN
					vOperacao = '355';
				WHEN pClassificacao = 'PRODUTOR RURAL' 	THEN
					vOperacao = '356';
				WHEN pClassificacao = 'NAO CONTRIBUINT' THEN
					
					IF current_database() = 'softlog_saocarlos' THEN
						vOperacao = '353';
					ELSE
						vOperacao = '357';
					END IF;
				ELSE
					vOperacao = '949';
			END CASE;
		ELSE
	END CASE;

--*********************************************************************************************************
	-- Parte 3	- Monta CFOP e retorna
--*********************************************************************************************************	
	vCfop = vGrupo || vOperacao;
	
	RETURN vCfop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
