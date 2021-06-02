-- Function: public.f_tgg_tipo_contribuinte()

-- DROP FUNCTION public.f_tgg_tipo_contribuinte();

CREATE OR REPLACE FUNCTION public.f_tgg_tipo_contribuinte()
  RETURNS trigger AS
$BODY$
DECLARE
	-- Função que recebe o código do destinatário do frete e retorna o tipo de contribuinte do mesmo
	vCnpjCpf text;
	vClassificacaoFiscal text;
	vInscricaoEstadual text;
	vTipoContribuinte text;
	vOptanteSimples integer;	
BEGIN	

	-- Verifica o tipo do contribuinte
	IF NEW.cnpj_cpf IS NULL THEN
		NEW.tipo_contribuinte = '';
	END IF;	

	-- Determina o tipo do contribuinte
	CASE 	
		-- WHEN vOptanteSimples = 1 THEN
			-- vTipoContribuinte = 'S';
		WHEN
			trim(NEW.inscricao_estadual) <> '' AND upper(NEW.inscricao_estadual) <> 'ISENTO' 
		THEN 
			NEW.tipo_contribuinte = 'C';			
		WHEN				
			char_length(NEW.cnpj_cpf) = 11 
			OR	NEW.classificacao_fiscal = 'NAO CONTRIBUINT'
			OR	upper(NEW.inscricao_estadual) = 'ISENTO'
			OR	trim(NEW.inscricao_estadual) = '' 
			OR 	NEW.inscricao_estadual IS NULL
		THEN
			NEW.tipo_contribuinte = 'N';
		WHEN 	
			NEW.classificacao_fiscal = 'ORGAO PUBLICO' 
		THEN 
			NEW.tipo_contribuinte = 'N';
		ELSE
			NEW.tipo_contribuinte = 'C';
	END CASE;

	RETURN NEW;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
