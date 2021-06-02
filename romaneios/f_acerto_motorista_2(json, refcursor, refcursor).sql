-- Function: public.f_acerto_motorista_2(json, refcursor, refcursor)
-- 
-- DROP FUNCTION public.f_acerto_motorista_2(json, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_acerto_motorista_2(
    vparametros json,
    cfechamento refcursor,
    msg refcursor)
  RETURNS SETOF refcursor AS
$BODY$
DECLARE
		
BEGIN	

	--SELECT * FROM scr_tabela_motorista_tipo_calculo;
	--DELETE FROM scr_romaneio_fechamentos WHERE id_romaneio = v_id_romaneios AND programado = 1;
	

	--SELECT * FROM scr_romaneios WHERE numero_romaneio = '0010010000357'

	
	OPEN cFechamento FOR 
	WITH 
		parametros AS (
			SELECT 
				1::integer as id_romaneio,
				((vParametros->>'total_servicos')::text)::integer as total_servicos,
				((vParametros->>'total_servicos')::text)::integer as total_volume,
				((vParametros->>'total_peso')::text)::numeric(12,2) as total_peso,
				((vParametros->>'total_pedagio')::text)::numeric(12,2) as peso_pedagio,
				((vParametros->>'total_cubagem')::text)::numeric(12,2) as total_cubagem,
				((vParametros->>'qt_viagens')::text)::numeric(12,2) as qt_viagens,
				((vParametros->>'total_frete')::text)::numeric(12,2) as total_frete,
				((vParametros->>'total_ajudantes')::text)::integer as total_ajudantes, 				
				(vParametros->>'numero_tabela_motorista')::text as numero_tabela_motorista,
				((vParametros->>'id_origem')::text)::integer as id_origem,

				retorna_regiao_origem_motorista(((vParametros->>'id_origem')::text)::integer, 
								(vParametros->>'numero_tabela_motorista'::text)
				) as id_regiao_origem,

				((vParametros->>'id_destino')::text)::integer,

				retorna_regiao_destino_motorista(retorna_regiao_origem_motorista(((vParametros->>'id_origem')::text)::integer, 
								(vParametros->>'numero_tabela_motorista')::text),
								((vParametros->>'id_destino')::text)::integer, 
								(vParametros->>'numero_tabela_motorista'::text)
				) as id_regiao_destino,
				
				((vParametros->>'diarias')::text)::numeric(12,1) as diarias,
				((vParametros->>'km_rodados')::text)::numeric(12,2) as km_rodados, 
				v_veiculos_romaneio.numero_eixos,			
				v_veiculos_romaneio.classificacao,
				v_veiculos_romaneio.tipo_veiculo,
				((vParametros->>'totais_ajudante')::text)::numeric(12,2) as totais_ajudante
			FROM 
				v_veiculos_romaneio 
			WHERE
				placa_veiculo = (vParametros->>'placa_veiculo')::text
		),
		regras_calculo AS ( 
			SELECT 	
				parametros.id_romaneio,
				--numero_romaneio,
				id_calculo,
				scr_tabela_motorista_tipo_calculo.descricao,
				scr_tabela_motorista.numero_tabela_motorista, 	
				scr_tabela_motorista_regioes.id_tabela_motorista_regiao, 
				id_calculo, 
				tipo_calculo, 
				scr_tabela_motorista_regioes.id_regiao_origem,
				regiao_origem.descricao as regiao_origem,
				scr_tabela_motorista_regioes.id_regiao_destino,
				regiao_destino.descricao as regiao_destino, 	
				unidade_multiplicacao as unidade,
				medida_inicial,
				medida_final,
				valor_variavel/dividir_por as valor_unitario,
				CASE    WHEN valor_variavel_excedido > 0 THEN true ELSE false END as tem_excedente,						
				CASE 	WHEN tipo_calculo = 1	THEN total_peso
					WHEN tipo_calculo = 2	THEN total_cubagem
					WHEN tipo_calculo = 3 	THEN km_rodados
					WHEN tipo_calculo = 4	THEN total_volume
					WHEN tipo_calculo = 5 	THEN diarias
					WHEN tipo_calculo = 6 	THEN total_servicos 
					WHEN tipo_calculo = 7 	THEN numero_eixos
					WHEN tipo_calculo = 8 	THEN (CASE WHEN peso_pedagio % unidade_multiplicacao = 0 
									  THEN peso_pedagio 
									  ELSE (peso_pedagio - (peso_pedagio % unidade_multiplicacao)) + unidade_multiplicacao
								      END)
					WHEN tipo_calculo = 10 	THEN total_ajudantes
					WHEN tipo_calculo = 11 	THEN total_frete
					WHEN tipo_calculo = 12 	THEN diarias * 2
					WHEN tipo_calculo = 26 	THEN qt_viagens
								ELSE 0.00 
								
				END as quantidade_calculo,
				valor_variavel/dividir_por as valor_variavel,
				valor_fixo,
				valor_variavel_excedido/dividir_por as valor_variavel_excedido,
				valor_fixo_excedido						
			FROM 
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
				AND (
					(scr_tabela_motorista_regioes.id_regiao_origem IN (parametros.id_regiao_origem,-1)
						AND scr_tabela_motorista_regioes.id_regiao_destino IN (parametros.id_regiao_destino,-1)
					)
					OR 
					(scr_tabela_motorista_regioes.id_regiao_destino IN (parametros.id_regiao_origem,-1)
						AND scr_tabela_motorista_regioes.id_regiao_origem IN (parametros.id_regiao_destino,-1)
					)
				)
				--AND  (scr_tabela_motorista_regiao_calculos.tipo_veiculo = parametros.tipo_veiculo OR scr_tabela_motorista_regiao_calculos.tipo_veiculo IS NULL)
				AND -- Filtrar Faixa de Valores de Acordo com o tipo de calculo... 
					CASE WHEN medida_final = 0 THEN -- Se medida final = 0 então postula-se um valor máximo inatingível...
									CASE 	WHEN tipo_calculo = 1 THEN total_peso >= medida_inicial AND total_peso <= 999999999 
										WHEN tipo_calculo = 2 THEN total_cubagem >= medida_inicial AND total_peso <= 999999999
										WHEN tipo_calculo = 3 THEN km_rodados >= medida_inicial AND km_rodados <= 999999999
										WHEN tipo_calculo = 4 THEN total_volume >= medida_inicial AND total_volume <= 999999999
										WHEN tipo_calculo = 5 THEN diarias >= medida_inicial AND diarias <= 9999999999
										WHEN tipo_calculo = 6 THEN total_servicos >= medida_inicial AND total_servicos <= 999999999
										WHEN tipo_calculo = 7 THEN numero_eixos >= medida_inicial AND numero_eixos <= 999999999
										WHEN tipo_calculo = 8 THEN total_peso >= medida_inicial AND total_peso <= 999999999 									
										WHEN tipo_calculo = 9 THEN true 									
										WHEN tipo_calculo = 10 THEN total_ajudantes >= medida_inicial AND total_ajudantes <= 999999999 									
										WHEN tipo_calculo = 11 THEN total_frete >= medida_inicial AND total_frete <= 999999999 																			
										WHEN tipo_calculo = 12 THEN (diarias*2) >= medida_inicial AND diarias * 2 <= 999999999 									
										WHEN tipo_calculo = 26 THEN qt_viagens >= medida_inicial AND qt_viagens <= 999999999 	
												      ELSE false 
									END
								   ELSE 
									CASE 	WHEN tipo_calculo = 1 THEN total_peso >= medida_inicial 
														AND (total_peso <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 2 THEN total_cubagem >= medida_inicial 
														AND (total_peso <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0) 	
										WHEN tipo_calculo = 3 THEN km_rodados >= medida_inicial 
														AND (km_rodados <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 4 THEN total_volume >= medida_inicial 
														AND (total_volume <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)								
										WHEN tipo_calculo = 5 THEN diarias >= medida_inicial 
														AND (diarias <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)												
										WHEN tipo_calculo = 6 THEN total_servicos >= medida_inicial 
														AND (total_servicos <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 7 THEN numero_eixos >= medida_inicial 
														AND (numero_eixos <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 8 THEN total_peso >= medida_inicial 
														AND (total_peso <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 9 THEN true
										WHEN tipo_calculo = 10 THEN total_ajudantes >= medida_inicial 
														AND (total_ajudantes <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 11 THEN total_frete >= medida_inicial 
														AND (total_frete <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 12 THEN (diarias*2) >= medida_inicial 
														AND ((diarias*2) <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
										WHEN tipo_calculo = 26 THEN (qt_viagens) >= medida_inicial 
														AND ((qt_viagens) <= medida_final OR valor_variavel_excedido > 0 OR valor_fixo_excedido > 0)
														
												      ELSE false 
									END
					END
		),
		valores_calculo AS (
			SELECT 
				regras_calculo.id_romaneio,
				--numero_romaneio,
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
			FROM 
				regras_calculo 
			ORDER BY 
				id_regiao_origem
			DESC LIMIT 1
		),
		resultado_final AS (
			SELECT 			
				id_romaneio,
				tipo_calculo,
				descricao,
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
				id_romaneio,
				tipo_calculo,
				descricao,
				1::integer as excedente,
				(quantidade_excedente/unidade)::numeric(12,3) as quantidade, 
				valor_variavel_excedido as valor_item,
				valor_pagar_excedente as total_itens,
				valor_minimo_excedente as valor_minimo,
				f_maior(valores_calculo.valor_pagar_excedente, valores_calculo.valor_minimo_excedente) as valor_pagar,
				1::integer as programado 
			FROM 
				valores_calculo
			WHERE valor_pagar_excedente > 0 OR valor_minimo_excedente > 0
			ORDER BY 1,3
		)
		SELECT 
			NULL::integer as id_fechamento,
			NULL::integer as id_romaneio,
			tipo_calculo,
			--descricao,
			excedente,
			quantidade as base_calculo,
			valor_item,
			total_itens,
			valor_minimo,
			valor_pagar,
			programado
		
		FROM 
			resultado_final
		ORDER BY 1,3;
		

	RETURN NEXT cFechamento;

	OPEN msg FOR SELECT '1-Ok' as resultado;

	RETURN NEXT msg;
	
	RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;