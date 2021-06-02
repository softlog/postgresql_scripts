-- Function: public.f_acerto_periodo_motorista(integer)
-- SELECT * FROM scr_relatorio_viagem WHERE numero_relatorio = '0010010000046'
-- DROP FUNCTION public.f_acerto_periodo_motorista(integer);
--SELECT * FROm f_acerto_periodo_motorista *=

--ALTER TABLE scr_relatorio_viagem_fechamentos ALTER COLUMN valor_item TYPE numeric(20,6);
CREATE OR REPLACE FUNCTION public.f_acerto_periodo_motorista(vIdRelatorioViagem integer)
  RETURNS integer AS
$BODY$
DECLARE
	vIdRelatorioViagem ALIAS FOR $1;
	v_tabela_motorista text;
	
BEGIN	
	DELETE FROM scr_relatorio_viagem_fechamentos WHERE id_relatorio_viagem = vIdRelatorioViagem AND programado = 1;

	SELECT numero_tabela_motorista 
	INTO v_tabela_motorista
	FROM scr_romaneios r
	LEFT JOIN scr_relatorio_viagem_romaneios rv
		ON r.id_romaneio = rv.id_romaneio
	WHERE 
		rv.id_relatorio_viagem = vIdRelatorioViagem
		AND r.numero_tabela_motorista IS NOT NULL		
	LIMIT 1;


	INSERT INTO scr_relatorio_viagem_fechamentos(
	id_relatorio_viagem, 
	tipo_calculo,
	excedente,
	base_calculo,
	valor_item,
	total_itens,
	valor_minimo,
	valor_pagar,
	programado,
	desconto)
	--SELECT com as colunas a serem inseridas		
	WITH 	
		itens AS
		(
			WITH lista_conhecimento AS (
				SELECT scr_conhecimento.id_conhecimento
				FROM scr_relatorio_viagem
					LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
					RIGHT JOIN scr_conhecimento_entrega ON scr_romaneios.id_romaneio = scr_conhecimento_entrega.id_romaneios
					LEFT JOIN scr_conhecimento ON scr_conhecimento_entrega.id_conhecimento = scr_conhecimento.id_conhecimento
				WHERE scr_relatorio_viagem.id_relatorio_viagem = vIdRelatorioViagem
				--WHERE scr_relatorio_viagem.id_relatorio_viagem = 21

				UNION 

				--Seleciona id_documento que tipo 1 é o id_conhecimento
				SELECT scr_viagens_docs.id_documento as id_conhecimento 
				FROM scr_relatorio_viagem
					LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
					RIGHT JOIN scr_viagens_docs ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio
				WHERE scr_relatorio_viagem.id_relatorio_viagem = vIdRelatorioViagem 
				--WHERE scr_relatorio_viagem.id_relatorio_viagem = 21
				AND tipo_documento = 1

				UNION 

				--Seleciona id_documento que tipo 2 é o id_manifesto, gravado no conhecimento
				SELECT scr_conhecimento.id_conhecimento
				FROM scr_relatorio_viagem
					LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
					RIGHT JOIN scr_viagens_docs ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio
					LEFT JOIN scr_manifesto ON scr_manifesto.id_manifesto = scr_viagens_docs.id_documento 
					LEFT JOIN scr_conhecimento ON scr_conhecimento.id_manifesto = scr_manifesto.id_manifesto
				WHERE scr_relatorio_viagem.id_relatorio_viagem = vIdRelatorioViagem
				--WHERE scr_relatorio_viagem.id_relatorio_viagem = 21
				AND scr_viagens_docs.tipo_documento = 2
			)
			SELECT 
				vIdRelatorioViagem as id_relatorio_viagem,
				--21 as id_relatorio_viagem,
				sum(total_frete) as total_frete,
				sum(valor_nota_fiscal) as total_nf,
				0.00 as total_servico		
			FROM scr_conhecimento 
			WHERE 	EXISTS( SELECT 	1
					FROM	lista_conhecimento
					WHERE 	lista_conhecimento.id_conhecimento = scr_conhecimento.id_conhecimento
				)
			UNION 
			SELECT 	
				scr_relatorio_viagem.id_relatorio_viagem, 
				0.00 as total_frete,
				0.00 as total_nf,
				SUM(scr_romaneio_fechamentos.valor_pagar) as total_servico
			FROM 	scr_relatorio_viagem
				LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
				LEFT JOIN scr_romaneio_fechamentos ON scr_romaneios.id_romaneio = scr_romaneio_fechamentos.id_romaneio
			WHERE 	id_relatorio_viagem = vIdRelatorioViagem
			GROUP BY scr_relatorio_viagem.id_relatorio_viagem
			
		),
		totais AS (
			SELECT 
				id_relatorio_viagem,
				SUM(total_frete) as total_frete,
				SUM(total_nf) as total_nf,
				SUM(total_servico) as total_servico			 
			FROM itens
			GROUP BY id_relatorio_viagem
		),
		parametros AS (
			SELECT 
				scr_relatorio_viagem.id_relatorio_viagem,
				scr_relatorio_viagem.numero_relatorio,
				COALESCE(					
					CASE 	WHEN trim(scr_relatorio_viagem.numero_tabela_motorista) = '' 
						THEN NULL 
						ELSE scr_relatorio_viagem.numero_tabela_motorista 
					END,
					v_tabela_motorista
				)::character(13) as numero_tabela_motorista,
				scr_relatorio_viagem.qtde_diarias,
				scr_relatorio_viagem.qtde_dias_parados,
				scr_relatorio_viagem.qtde_horas_extras				
			FROM 
				scr_relatorio_viagem				
			WHERE scr_relatorio_viagem.id_relatorio_viagem = vIdRelatorioViagem
			--WHERE scr_relatorio_viagem.id_relatorio_viagem = 21
		),
		regras_calculo AS ( 
			SELECT 	
				parametros.id_relatorio_viagem,
				numero_relatorio,
				scr_tabela_motorista.numero_tabela_motorista, 	
				scr_tabela_motorista_regioes.id_tabela_motorista_regiao, 
				id_calculo, 
				tipo_calculo, 
				scr_tabela_motorista_regioes.id_regiao_origem,
				regiao_origem.descricao as regiao_origem,
				scr_tabela_motorista_regioes.id_regiao_destino,
				regiao_destino.descricao as regiao_destino, 	
				scr_tabela_motorista_tipo_calculo.descricao,
				unidade_multiplicacao as unidade,
				medida_inicial,
				medida_final,
				valor_variavel/dividir_por as valor_unitario,
				negativo,
				CASE    WHEN valor_variavel_excedido > 0 THEN true ELSE false END as tem_excedente,						
				CASE 	WHEN tipo_calculo = 5	THEN qtde_diarias 
					WHEN tipo_calculo = 12	THEN qtde_horas_extras 
					WHEN tipo_calculo = 13	THEN qtde_dias_parados 
					WHEN tipo_calculo = 14	THEN qtde_dias_parados 
					WHEN tipo_calculo = 15	THEN 1	
					--WHEN tipo_calculo = 18  THEN totais.total_servico 
					WHEN tipo_calculo = 19  THEN totais.total_nf 
					WHEN tipo_calculo = 20  THEN totais.total_nf 
					WHEN tipo_calculo = 21  THEN 1 
					WHEN tipo_calculo = 22	THEN totais.total_servico 
					WHEN tipo_calculo = 23  THEN totais.total_nf 
					WHEN tipo_calculo = 24  THEN totais.total_frete 
					WHEN tipo_calculo = 25  THEN totais.total_frete 
								ELSE 0.00 
				END as quantidade_calculo,
				valor_variavel/dividir_por as valor_variavel,
				valor_fixo,
				valor_variavel_excedido/dividir_por as valor_variavel_excedido,
				valor_fixo_excedido			
			FROM 
				totais,
				parametros
				LEFT JOIN scr_tabela_motorista 
					ON parametros.numero_tabela_motorista = scr_tabela_motorista.numero_tabela_motorista
				LEFT JOIN scr_tabela_motorista_regioes 
					ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
				LEFT JOIN regiao regiao_origem 
					ON scr_tabela_motorista_regioes.id_regiao_origem = regiao_origem.id_regiao
				LEFT JOIN regiao regiao_destino 
					ON scr_tabela_motorista_regioes.id_regiao_destino = regiao_destino.id_regiao
				LEFT JOIN scr_tabela_motorista_regiao_calculos 
					ON scr_tabela_motorista_regioes.id_tabela_motorista_regiao = scr_tabela_motorista_regiao_calculos.id_tabela_motorista_regiao
				LEFT JOIN scr_tabela_motorista_tipo_calculo 
					ON scr_tabela_motorista_regiao_calculos.tipo_calculo = scr_tabela_motorista_tipo_calculo.id_tipo_calculo
			WHERE 
				scr_tabela_motorista.numero_tabela_motorista = parametros.numero_tabela_motorista
				AND scr_tabela_motorista_regioes.id_regiao_origem = -1
				AND scr_tabela_motorista_regioes.id_regiao_destino = -1
				AND -- Filtrar Faixa de Valores de Acordo com o tipo de calculo... 
					CASE WHEN medida_final = 0 THEN -- Se medida final = 0 então postula-se um valor máximo inatingível...
									CASE 	WHEN tipo_calculo = 5  THEN qtde_diarias >= medida_inicial AND qtde_horas_extras <= 999999999 
										WHEN tipo_calculo = 12 THEN qtde_horas_extras >= medida_inicial AND qtde_horas_extras <= 999999999 
										WHEN tipo_calculo = 13 THEN qtde_dias_parados >= medida_inicial AND qtde_dias_parados <= 999999999
										WHEN tipo_calculo = 14 THEN qtde_dias_parados >= medida_inicial AND qtde_dias_parados <= 999999999
										WHEN tipo_calculo = 15 THEN 1 >= medida_inicial AND 1 <= 999999999
										-- WHEN tipo_calculo = 18 THEN totais.total_servico >= medida_inicial AND totais.total_servico <= 999999999
										WHEN tipo_calculo = 19 THEN totais.total_nf >= medida_inicial AND totais.total_nf <= 999999999
										WHEN tipo_calculo = 20 THEN totais.total_nf >= medida_inicial AND totais.total_nf <= 999999999
										WHEN tipo_calculo = 21 THEN 1 >= medida_inicial AND 1 <= 999999999
										WHEN tipo_calculo = 22 THEN totais.total_servico >= medida_inicial AND totais.total_servico <= 999999999
										WHEN tipo_calculo = 23 THEN totais.total_nf >= medida_inicial AND totais.total_nf <= 999999999
										WHEN tipo_calculo = 24 THEN totais.total_frete  >= medida_inicial AND totais.total_frete  <= 999999999
										WHEN tipo_calculo = 25 THEN totais.total_frete >= medida_inicial AND totais.total_frete <= 999999999
									END
								   ELSE 
									CASE 	
										WHEN tipo_calculo = 5 THEN qtde_diarias >= medida_inicial 
														AND (qtde_diarias <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 12 THEN qtde_horas_extras >= medida_inicial 
														AND (qtde_horas_extras <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 13 THEN qtde_dias_parados >= medida_inicial 
														AND (qtde_dias_parados <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0) 	
										WHEN tipo_calculo = 14 THEN qtde_dias_parados >= medida_inicial 
														AND (qtde_dias_parados <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 15 THEN 1 >= medida_inicial 
														AND (totais.total_servico <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)								
-- 										WHEN tipo_calculo = 18 THEN totais.total_servico >= medida_inicial 
-- 														AND (totais.total_servico <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)	
										WHEN tipo_calculo = 19 THEN totais.total_nf >= medida_inicial 
														AND (totais.total_nf <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)											
										WHEN tipo_calculo = 20 THEN totais.total_nf >= medida_inicial 
														AND (totais.total_nf <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)											
										WHEN tipo_calculo = 21 THEN 1 >= medida_inicial 
														AND (1 <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)											
										WHEN tipo_calculo = 22 THEN totais.total_servico  >= medida_inicial 
														AND (totais.total_servico <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)	
										WHEN tipo_calculo = 23 THEN totais.total_nf >= medida_inicial 
														AND (totais.total_nf <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 24 THEN totais.total_frete  >= medida_inicial 
														AND (totais.total_nf <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 25 THEN totais.total_frete >= medida_inicial 
														AND (totais.total_frete <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
									END
					END
		),
		sinal_tipo_calculo AS
		(
			SELECT DISTINCT tipo_calculo, negativo FROM regras_calculo 
		),		
		valores_calculo AS (
			SELECT 
				regras_calculo.id_relatorio_viagem,
				numero_relatorio,
				tipo_calculo,
				descricao,
				unidade,
				CASE WHEN tem_excedente AND quantidade_calculo > medida_final THEN medida_final ELSE quantidade_calculo END quantidade_faixa,
				valor_variavel,
				CASE WHEN tem_excedente AND quantidade_calculo > medida_final THEN (medida_final/unidade) * valor_variavel 
											       ELSE (quantidade_calculo/unidade) * valor_variavel 
				END::numeric(12,2) valor_pagar_faixa,
				CASE WHEN tem_excedente AND quantidade_calculo > medida_final THEN quantidade_calculo - medida_final ELSE 0 END quantidade_excedente,
				valor_variavel_excedido,
				
				CASE WHEN tem_excedente AND quantidade_calculo > medida_final THEN ((quantidade_calculo - medida_final)/unidade) * valor_variavel_excedido 
											       ELSE 0 
				END::numeric(12,2) as valor_pagar_excedente,			
				valor_fixo as valor_minimo,			
				valor_fixo_excedido as valor_minimo_excedente
			FROM regras_calculo 
		),
		--Tratamento de Alguns Calculos que precisam de Dados de Outros Cálculos
		pre_valores AS 
		(
			WITH 
				calculos AS (
					SELECT 	
						id_relatorio_viagem,
						tipo_calculo,
						0::integer as excedente,
						(quantidade_faixa/unidade)::numeric(12,3) as quantidade, 
						valor_variavel as valor_item,
						valor_pagar_faixa as total_itens,
						valor_minimo,
						f_maior(valor_pagar_faixa, valores_calculo.valor_minimo) as valor_pagar,
						1::integer as programado
					FROM 
						valores_calculo					
					UNION 
					SELECT 	
						id_relatorio_viagem,
						tipo_calculo,
						1::integer as excedente,
						(quantidade_excedente/unidade)::numeric(12,3) as quantidade, 
						valor_variavel_excedido as valor_item,
						valor_pagar_excedente as total_itens,
						valor_minimo_excedente as valor_minimo,
						f_maior(valores_calculo.valor_pagar_excedente, valores_calculo.valor_minimo_excedente) as valor_pagar,
						1::integer as programado 
					FROM 
						valores_calculo
					WHERE (valor_pagar_excedente > 0 OR valor_minimo_excedente > 0)
					ORDER BY 1,3	
				),
				--Encontra valor do seguro
				base_iof_seguro as (
					SELECT 	valor_pagar as base_calculo
					FROM 	calculos
					WHERE	tipo_calculo = 19
				)
			--Seleciona todos menos o iof seguro
			SELECT * FROM calculos WHERE tipo_calculo <> 20
			UNION 
			--Seleciona somente iof seguro, caso houver
			SELECT			
				id_relatorio_viagem,
				tipo_calculo,
				excedente,
				base_iof_seguro.base_calculo as quantidade,
				valor_item,
					(base_iof_seguro.base_calculo * valor_item)::numeric(12,2) as total_itens,
					valor_minimo,
					(base_iof_seguro.base_calculo * valor_item)::numeric(12,2) as valor_pagar,
					programado			
				FROM 
					calculos,  base_iof_seguro
				WHERE
					tipo_calculo = 20
				ORDER BY tipo_calculo, excedente				
		),
		base_calculo_imposto AS (
					SELECT 	totais.total_frete - SUM(valor_pagar) as base_calculo
					FROM	pre_valores, totais			
					WHERE 	pre_valores.tipo_calculo IN (18,19,20,21)			
					GROUP BY totais.total_frete
					
		) 
	---------------------------------------------------------------------------------------------------------------------------------------------------
	--- FIM DO WITH
	---------------------------------------------------------------------------------------------------------------------------------------------------
	--Seleciona todos menos o imposto, se houver
	SELECT 
		id_relatorio_viagem,
		pre_valores.tipo_calculo,
		excedente,
		quantidade,
		valor_item,
		total_itens,
		valor_minimo,
		valor_pagar as valor_pagar,
		programado,
		negativo		
	FROM 	pre_valores 
		LEFT JOIN sinal_tipo_calculo ON pre_valores.tipo_calculo = sinal_tipo_calculo.tipo_calculo
	WHERE pre_valores.tipo_calculo <> 22 
	UNION 
	--Seleciona somente o imposto, se houver
	SELECT			
		id_relatorio_viagem,
		pre_valores.tipo_calculo,
		excedente,
		base_calculo_imposto.base_calculo as quantidade,
		valor_item,
		(base_calculo_imposto.base_calculo * valor_item)::numeric(12,2) as total_itens,
		valor_minimo,
		((base_calculo_imposto.base_calculo * valor_item)) ::numeric(12,2) as valor_pagar,
		programado,
		negativo
	FROM 
		base_calculo_imposto, pre_valores
		LEFT JOIN sinal_tipo_calculo ON pre_valores.tipo_calculo = sinal_tipo_calculo.tipo_calculo
	WHERE
		pre_valores.tipo_calculo = 22	
	ORDER BY 2, 3;
RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
