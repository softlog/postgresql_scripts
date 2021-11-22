-- Function: public.f_scr_aliquota_icms_uf(integer, integer, numeric, numeric, numeric, integer, text, integer, integer)

-- DROP FUNCTION public.f_scr_aliquota_icms_uf(integer, integer, numeric, numeric, numeric, integer, text, integer, integer);

CREATE OR REPLACE FUNCTION public.f_scr_aliquota_icms_uf(
    p_tipo_retorno integer,
    p_ind_operacao integer,
    p_aliq_interna_origem numeric,
    p_aliq_interna_simples numeric,
    p_aliq_interestadual numeric,
    p_tipo_imposto integer,
    p_tipo_contribuinte text,
    p_tem_difal integer,
    p_aliq_inter_cif integer)
  RETURNS numeric AS
$BODY$
DECLARE
	vCaso integer;
	vAliquota numeric(6,2);
	vAliquotaNormal numeric(6,2);
	vAliquotaSt numeric(6,2);
	vTipoContribuinte character;
BEGIN	

	--Se for simples, isento, diferido ou isento 090, retorna aliquota 0
	IF p_tipo_imposto IN (2,11,13,14) THEN 
		RETURN 0.00;
	END IF;
	
	vAliquotaNormal = 0.00;	-- Isento por default;
	vAliquotaSt 	= 0.00;	-- Isento por default;

	--Operacao Estadual InterMunicipal
	IF p_ind_operacao IN (1,4) THEN
		vAliquota = p_aliq_interna_origem;		
	END IF;

	--Operacao Interestadual 
	IF p_ind_operacao IN (2,3) THEN	
		--Com contribuinte
		--IF p_tipo_contribuinte = 'C' THEN 		
		-- http://www.planalto.gov.br/ccivil_03/constituicao/Emendas/Emc/emc87.htm
		-- Retirado por causa do INC. 7
		vAliquota = p_aliq_interestadual;
		--END IF;

		--Com não contribuinte sem difal e recolhimento de frete CIF com aliquota interestadual setada como 
		-- falso.
-- 		IF (p_tipo_contribuinte = 'N' AND p_tem_difal = 0 AND p_aliq_inter_cif = 0) THEN
-- 			vAliquota = p_aliq_interna_origem;
-- 		ELSE --Com contribuinte ou não contribuinte com difal
-- 			vAliquota = p_aliq_interestadual;
-- 		END IF;
	END IF;

	
	-- Destinação da Alíquota por Tipo de Imposto
	-- Imposto por Tributação Normal
	IF p_tipo_imposto IN (1) THEN
		vAliquotaNormal = vAliquota;		
	END IF;

	IF p_tipo_imposto IN (6,7,8,9,10) THEN 
		vAliquotaSt = vAliquota;
	END IF;
		

	-- Retorna alíquota por Tributação Normal
	IF p_tipo_retorno = 1 THEN 
		RETURN vAliquotaNormal;
	END IF;

	-- Retorna alíquota para outros tipos de tributação
	IF p_tipo_retorno = 2 THEN
		RETURN vAliquotaSt;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_scr_aliquota_icms_uf(integer, integer, numeric, numeric, numeric, integer, text, integer, integer)
  OWNER TO softlog_dfreire;
