-- Function: public.f_tgg_atualiza_cte_re()

-- DROP FUNCTION public.f_tgg_atualiza_cte_re();

CREATE OR REPLACE FUNCTION public.f_tgg_atualiza_cte_re()
  RETURNS trigger AS
$BODY$
DECLARE
	vTotalFrete 	numeric(12,2);
	vTotalDesconto	numeric(12,2);
	vImposto	numeric(12,2);
	vBc		numeric(12,2);
	vImpostoSt	numeric(12,2);
	vBcSt		numeric(12,2);	
	vStatusCte	integer;
BEGIN

	--perform f_debug('teste', 'antes do braço NEW.tipo_documento = 3');	
	
	IF  NEW.tipo_documento = 3 THEN 

		--perform f_debug('teste', 'Entrou no braço NEW.tipo_documento = 3');
		
		--Se o conhecimento principal estiver cancelado nao faz atualizacao.
		SELECT 	cancelado 
		INTO 	vStatusCte
		FROM 	scr_conhecimento
		WHERE 	id_conhecimento = NEW.id_conhecimento_principal;

		IF vStatusCte = 1 THEN 
			RETURN NEW;
		END IF;
	
		--Exclui notas fiscais que fazem parte da minuta re
		WITH t AS (
			SELECT
				nf.numero_nota_fiscal,
				fp_set_get_session('v_nao_excluir_nota_'||TRIM(nf.id_nota_fiscal_imp::text),'1') as sessao
			FROM scr_conhecimento_notas_fiscais nf
			WHERE nf.id_conhecimento = NEW.id_conhecimento
		),
		seta AS (
			select sessao from t
		)
		DELETE FROM scr_conhecimento_notas_fiscais 
		USING t 
		WHERE 	id_conhecimento = NEW.id_conhecimento_principal
			AND scr_conhecimento_notas_fiscais.numero_nota_fiscal = t.numero_nota_fiscal;


		IF NEW.cancelado = 0 THEN 

			--Insere as notas fiscais 
			INSERT INTO scr_conhecimento_notas_fiscais(
				id_conhecimento, 
				data_nota_fiscal, 
				numero_nota_fiscal, 
				serie_nota_fiscal, 
				qtd_volumes, 
				peso, 
				valor, 
				volume_cubico, 
				tipo_nota, 
				numero_romaneio_nf, 
				numero_pedido_nf, 
				valor_base_calculo, 
				valor_icms_nf, 
				valor_base_calculo_icms_st, 
				valor_icms_nf_st, 
				cfop_pred_nf, 
				valor_total_produtos, 
				pin, 
				chave_nfe, 
				id_inclusao, 
				id_ocorrencia, 
				data_ocorrencia, 
				hora_ocorrencia, 
				id_ocorrencia_obs, 
				canhoto, 
				incidencia, 
				id_natureza_carga, 
				modelo_nf, 
				total_frete_nf,
				total_frete_prod,
				id_nota_fiscal_imp
			)
			SELECT 			
				NEW.id_conhecimento_principal, 
				nf.data_nota_fiscal, 
				nf.numero_nota_fiscal, 
				nf.serie_nota_fiscal, 
				nf.qtd_volumes, 
				nf.peso, 
				nf.valor, 
				nf.volume_cubico, 
				nf.tipo_nota, 
				nf.numero_romaneio_nf, 
				nf.numero_pedido_nf, 
				nf.valor_base_calculo, 
				nf.valor_icms_nf, 
				nf.valor_base_calculo_icms_st, 
				nf.valor_icms_nf_st, 
				nf.cfop_pred_nf, 
				nf.valor_total_produtos, 
				nf.pin, 
				nf.chave_nfe, 
				nf.id_inclusao, 
				nf.id_ocorrencia, 
				nf.data_ocorrencia, 
				nf.hora_ocorrencia, 
				nf.id_ocorrencia_obs, 
				nf.canhoto, 
				nf.incidencia, 
				nf.id_natureza_carga, 
				nf.modelo_nf,
				nf.total_frete_nf,
				nf.total_frete_prod,
				nf.id_nota_fiscal_imp
			FROM 
				scr_conhecimento_notas_fiscais nf
				LEFT JOIN scr_conhecimento c ON c.id_conhecimento = nf.id_conhecimento
			WHERE 
				c.id_conhecimento = NEW.id_conhecimento;
		END IF;
		
		--Totais 
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
			c.id_conhecimento_principal = NEW.id_conhecimento_principal
			and c.cancelado = 0 ;

		--perform f_debug('total frete', vTotalFrete::text);
		
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
				id_conhecimento = NEW.id_conhecimento_principal
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
		
		-- Grava dados finais de total de frete, imposto e numero de emissao documento
		UPDATE scr_conhecimento SET 
			total_frete = vTotalFrete, 
			desconto = vTotalDesconto,
			imposto = vImposto,
			base_calculo = vBc,
			icms_st = vImpostoSt,
			base_calculo_st_reduzida = vBcSt			
		WHERE 
			id_conhecimento = NEW.id_conhecimento_principal;	
	END IF;
     
     RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
