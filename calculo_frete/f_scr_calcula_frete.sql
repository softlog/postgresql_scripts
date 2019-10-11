-- Function: public.f_scr_calcula_frete(json, refcursor, refcursor)

-- DROP FUNCTION public.f_scr_calcula_frete(json, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_scr_calcula_frete(
    parametros json,
    cf refcursor,
    msg refcursor)
  RETURNS SETOF refcursor AS
$BODY$
DECLARE
	vCursor 		refcursor;
	msg2			refcursor;
	vTotalFrete 		numeric(12,2);
	vBaseCalculo 		numeric(12,2);
	vImposto 		numeric(12,2);
	vRetorno 		json;
	vResultadoImposto 	json;
	vRows 			integer;
	vCtrcTeste 		json;
	vQuantRotasCidade 	integer;
	vTabelaFrete 		text;
	vCombinado 		integer;
	vDensidade 		integer;
	vTipoRota 		integer; 
	vIdTabelaFrete 		integer;
	vCidadeOrigem 		integer;
	vCidadeDestino 		integer;
	vRegioes		json;
	vRegiaoOrigem 		integer;
	vRegiaoDestino 		integer;	
	vQtCf			integer;
	vResultadoFrete		t_scr_conhecimento_cf%rowtype;
	vEntregaNormal		boolean;
	vEntregaExpresso	boolean;
	vEntregaEmergencia	boolean;
	vColetaNormal		boolean;
	vColetaExpresso		boolean;
	vColetaEmergencia	boolean;
	v_tipo_combinado 	integer;	
	v_quantidade_comb	numeric;
	v_valor_item_comb	numeric;
	v_valor_total_comb	numeric;
	v_valor_pagar_comb	numeric;
	v_qt_cf			integer;
	dados_icms		json;
	
BEGIN
	--Calculo do Frete por meio de tabelas 

	--Verifica se e  frete combinado
	vTabelaFrete = (parametros->>'tabela_frete')::text;

	--Verifica se ha problemas entre as taxas.
	vEntregaExpresso 	= (parametros->>'entrega_expresso')::text::integer::boolean;
	vEntregaEmergencia 	= (parametros->>'entrega_emergencia')::text::integer::boolean;
		

	vColetaExpresso 	= (parametros->>'coleta_expresso')::text::integer::boolean;
	vColetaEmergencia	= (parametros->>'coleta_emergencia')::text::integer::boolean;
	

	IF (vColetaExpresso AND vColetaEmergencia) THEN 
		vRetorno = ('{"codigo":20, "Mensagem":"NAO e admitido taxa de Expresso e Emergencia na origem. Selecione apenas uma."}')::json;
	END IF;

	IF (vEntregaExpresso AND vEntregaEmergencia) THEN 
		vRetorno = ('{"codigo":21, "Nao e admitido taxa de Expresso + Emergencia no destino. Selecione apenas uma."}')::json;
	END IF; 

	

	IF vRetorno IS NOT NULL THEN 
		OPEN msg FOR SELECT vRetorno as msg;

		RETURN NEXT msg;

		OPEN cf FOR SELECT 1;
		
		RETURN NEXT cf;	

		RETURN ;
	END IF;

	IF RIGHT(trim(vTabelaFrete),10) <> '9999999999' AND  vTabelaFrete IS NOT NULL THEN 

		OPEN cf FOR				
 		WITH
		-- Entrada dos parametros da estrutura Json 
      		json AS (
     		SELECT 
		'{"tabela_frete":"0010010000009",
		 "calculado_de_id_cidade":3324,
		 "calculado_ate_id_cidade":3292,
		 "total_frete_origem":0.00,
		 "natureza_carga":"MEDICAMENTOS/HIGIENE/PERFUMARIA",
		 "qtd_nf":1,
		 "peso":0.000,
		 "qtd_volumes":2,
		 "volume_cubico":0.0000,
		 "valor_nota_fiscal":869.13,
		 "valor_total_produtos":869.13,
		 "aliquota":12.00,
		 "perc_desconto":0.00,
		 "isento_imposto":0,
		 "imposto_incluso":1,
		 "perc_credito_icms_st":0.00,
		 "escolta_horas_entrega":0,
		 "coleta_escolta":0,
		 "coleta_expresso":0,
		 "coleta_emergencia":0,
		 "coleta_normal":0,
		 "entrega_escolta":0,
		 "entrega_expresso":0,
		 "entrega_emergencia":0,
		 "entrega_normal":0,
		 "taxa_dce":0,
		 "taxa_exclusivo":0,
		 "coleta_dificuldade":0,
		 "entrega_dificuldade":0,
		 "entrega_exclusiva":0,
		 "coleta_exclusiva":0,
		 "modo_calculo":1,
		 "perc_desc_calculo":0.00,
		 "id_tipo_veiculo":null,
		 "data_coleta":"2017-07-31T00:00:00",
		 "data_entrega":null,
		 "tipo_carga":null,
		 "tipo_transporte":1,
		 "vl_combinado":0.00,
		 "vl_tonelada":0.00000000,
		 "vl_percentual_nf":0.00000000,
		 "vl_frete_peso":0.00}'::json as parametros)				
		--Extracao dos dados de uma estrutura JSON que contem os parametros de entrada para o calculo do frete		
		,ent AS (
			SELECT 
				(parametros->>'calculado_ate_id_cidade')::text::integer as calculado_ate_id_cidade,
				(parametros->>'calculado_de_id_cidade')::text::integer as calculado_de_id_cidade,
				(parametros->>'natureza_carga')::text as natureza_carga,
				(parametros->>'tabela_frete')::text as tabela_frete,
				(parametros->>'qtd_nf')::text::integer as qtde_nf,
				(parametros->>'qtd_volumes')::text::numeric as total_volume,
				(parametros->>'peso')::text::numeric as tp,
				(parametros->>'volume_cubico')::text::numeric as tc,
				(parametros->>'valor_total_produtos')::text::numeric as total_valor_produtos,
				(parametros->>'valor_nota_fiscal')::text::numeric as total_nf,
				(parametros->>'qtd_volumes')::text::integer as total_unidades,
				(parametros->>'total_frete_origem')::text::numeric as total_frete_origem,
				(parametros->>'imposto_incluso')::text::integer as imposto_incluso,
				f_scr_retorna_regioes_origem_destino(
								(parametros->>'calculado_de_id_cidade')::text::integer,
								(parametros->>'calculado_ate_id_cidade')::text::integer,
								(parametros->>'tabela_frete')::text
								) as regioes,
				(parametros->>'escolta_horas_entrega')::text::integer as escolta_horas_entrega,
				(parametros->>'coleta_escolta')::text::integer::boolean as coleta_escolta,
				(parametros->>'coleta_expresso')::text::integer::boolean as coleta_expresso,
				(parametros->>'coleta_emergencia')::text::integer::boolean as coleta_emergencia,
				(parametros->>'coleta_normal')::text::integer::boolean as coleta_normal,
				(parametros->>'entrega_escolta')::text::integer::boolean as entrega_escolta,
				(parametros->>'entrega_expresso')::text::integer::boolean as entrega_expresso,
				(parametros->>'entrega_emergencia')::text::integer::boolean as entrega_emergencia,
				(parametros->>'entrega_normal')::text::integer::boolean as entrega_normal,
				(parametros->>'taxa_dce')::text::integer::boolean as taxa_dce,
				(parametros->>'taxa_exclusivo')::text::integer::boolean as taxa_exclusivo,
				(parametros->>'coleta_dificuldade')::text::integer::boolean as coleta_dificuldade,
				(parametros->>'entrega_dificuldade')::text::integer::boolean as entrega_dificuldade,
				(parametros->>'entrega_exclusiva')::text::integer::boolean as entrega_exclusiva,
				(parametros->>'coleta_exclusiva')::text::integer::boolean as coleta_exclusiva,
				(parametros->>'modo_calculo')::text::integer as modo_calculo,
				(parametros->>'perc_desc_calculo')::text::numeric as perc_desc_calculo,
				(parametros->>'perc_credito_icms_st')::text::numeric as perc_credito_icms_st,
				COALESCE((parametros->>'vl_frete_peso')::text::numeric,0.00) as vl_frete_peso,			
				COALESCE((parametros->>'id_tipo_veiculo')::text::integer,0)::integer as id_tipo_veiculo,
				COALESCE((parametros->>'data_coleta')::text::timestamp,NULL)::timestamp as data_coleta,			 	
			 	COALESCE((parametros->>'data_entrega')::text::timestamp,NULL)::timestamp as data_entrega,
			 	COALESCE((parametros->>'tipo_carga')::text::integer,0)::integer as tipo_carga,
			 	COALESCE((parametros->>'tipo_transporte')::text::integer,0)::integer as tipo_transporte,
			 	COALESCE((parametros->>'remetente_id')::text::integer,0)::integer as remetente_id,
			 	COALESCE((parametros->>'destinatario_id')::text::integer,0)::integer as destinatario_id,
			 	COALESCE((parametros->>'km_rodado')::text::integer,0)::integer as km_rodados	 	
		--FROM json
 		),
		destinatario AS (
			SELECT 
				ent.destinatario_id, 
				id_bairro 
			FROM 
				ent 
				LEFT JOIN cliente 
					ON cliente.codigo_cliente = ent.destinatario_id
				
		),
		rb AS (
			SELECT 
				destinatario.id_bairro,
				f_scr_retorna_regioes_origem_destino_bairros(ent.calculado_de_id_cidade, destinatario.id_bairro,ent.tabela_frete) as regioes_bairro
			FROM 
				ent, destinatario
		),
 		--Extracao dos dados de uma estrutura JSON que contem o retorno da funcao que determina qual a regiao de origem e destino
		ent_reg AS (
			SELECT 
				calculado_de_id_cidade,
				calculado_ate_id_cidade,				
				(ent.regioes->'id_regiao_origem')::text::integer as id_regiao_origem,
				(ent.regioes->'id_regiao_destino')::text::integer as id_regiao_destino,
				(rb.regioes_bairro->'id_regiao_origem')::text::integer as id_regiao_origem_bairro,
				(rb.regioes_bairro->'id_regiao_destino')::text::integer as id_regiao_destino_bairro,
				rb.id_bairro				
			FROM 
				ent, rb
	
		),

		--Busca distancia da cidade de entrega
		dist_cid_dest AS (
			SELECT 
				distancia_cidade_polo as km_entrega
			FROM 
				ent_reg
				LEFT JOIN regiao_cidades 
					ON ent_reg.id_regiao_destino = regiao_cidades.id_regiao
					AND ent_reg.calculado_ate_id_cidade = regiao_cidades.id_cidade
		),
		--Definicao do Conjunto de dados contendo os totais dos valores utilizados no calculo
		totais AS (		
			SELECT 							
				1::integer as id_conhecimento,
				ent.qtde_nf,
				ent.total_volume,
				ent.tp,
				ent.tc,
				ent.total_valor_produtos,
				ent.total_nf,
				ent.total_unidades,
				ent.vl_frete_peso,
				--Verifica se tem pre-calculo de frete peso
				CASE 	WHEN COALESCE(ent.vl_frete_peso,0.00) > 0
					THEN true
					ELSE false
				END::boolean as tem_pre_calculo
			FROM 
				ent
		),		
		--Definicao do Conjunto de dados com os parametros do calculo do frete acrescido de parametros extras
		--    recuperados em tabelas no banco de dados
		parametros AS (
			SELECT 
				totais.id_conhecimento,
				--c.pagador_id,
				--c.numero_ctrc_filial,
				tabela_frete as numero_tabela_frete,
				ent.tipo_carga,

				ent_reg.calculado_de_id_cidade as id_cidade_origem,
				ent_reg.calculado_ate_id_cidade as id_cidade_destino,
				ent_reg.id_regiao_origem,
				ent_reg.id_regiao_destino,
				ent_reg.id_regiao_origem_bairro,
				ent_reg.id_regiao_destino_bairro,
				ent_reg.id_bairro,
				ent.id_tipo_veiculo,				
				ent.tipo_transporte,
				ent.escolta_horas_entrega,
				ent.coleta_escolta,
				ent.coleta_expresso,
				ent.coleta_emergencia,
				ent.coleta_normal,
				ent.entrega_escolta,
				ent.entrega_expresso,
				ent.entrega_emergencia,
				ent.entrega_normal,
				ent.taxa_dce,
				ent.taxa_exclusivo,
				ent.coleta_dificuldade,
				ent.entrega_dificuldade,
				ent.entrega_exclusiva,				
				ent.coleta_exclusiva,
				CASE 	WHEN COALESCE(ent.km_rodados,0) > 0 
					THEN ent.km_rodados
					ELSE dist_cid_dest.km_entrega
				END as km_entrega,														
				reg.capital::boolean as capital_polo_coleta, 
				reg.cidade_satelite::boolean as satelite_coleta,  
				reg.interior_redespacho::boolean as interior_coleta, 
				reg.percurso_fluvial::boolean as fluvial_coleta,			
				reg.distancia_cidade_polo as km_percorridos_coleta,

				dest.capital::boolean as capital_polo_entrega, 
				dest.cidade_satelite::boolean as satelite_entrega,  
				dest.interior_redespacho::boolean as interior_entrega, 
				dest.percurso_fluvial::boolean as fluvial_entrega,			
				dest.distancia_cidade_polo as km_percorridos_entrega,
				
				
				totais.qtde_nf,
				totais.total_volume,
				totais.tp,
				totais.tc,
				totais.total_valor_produtos,
				totais.total_nf,	
				totais.total_unidades,		
				totais.tem_pre_calculo,				

				ent.total_frete_origem,
				0::integer as diarias,
				ent.km_rodados,		
				ent.imposto_incluso,		
				nc.id_natureza_carga,
				nc.densidade as densidade_nc,

				ent.data_coleta,		
				CASE 	WHEN ent.data_coleta IS NOT NULL 
					THEN to_char(ent.data_coleta,'HH24MI')::integer 
					ELSE NULL 
				END::integer as hr_coleta,
				
				CASE 	WHEN ent.data_coleta IS NOT NULL 
					THEN extract('dow' from ent.data_coleta) + 1
					ELSE NULL 
				END::integer as dia_coleta,
				
				
				ent.data_entrega,				
				CASE 	WHEN ent.data_entrega IS NOT NULL 
					THEN to_char(ent.data_entrega,'HH24MI') 
					ELSE NULL 
				END::numeric as hr_entrega,
				
				CASE 	WHEN ent.data_entrega IS NOT NULL 
					THEN extract('dow' from ent.data_entrega) + 1
					ELSE NULL 
				END::numeric as dia_entrega,
				ent.destinatario_id,
				ent.remetente_id

				

			FROM 		
				dist_cid_dest,
				totais,
				ent				
				LEFT JOIN scr_natureza_carga nc 
						ON trim(nc.natureza_carga) = trim(ent.natureza_carga),
				ent_reg
				LEFT JOIN v_regiao_cidades reg 
						ON reg.id_regiao = ent_reg.id_regiao_origem
							AND reg.id_cidade = ent_reg.calculado_de_id_cidade
				LEFT JOIN v_regiao_cidades dest 
					ON dest.id_regiao = ent_reg.id_regiao_destino
						AND dest.id_cidade = ent_reg.calculado_ate_id_cidade
								
		),
		-------------------------------------------------------------
		-- Busca as regras de calculo de frete na base de dados
		--      de acordo com os parametros coletados anteriormente
		-- Legenda para ALIAS das tabelas
		-- t 	= scr_tabelas
		-- tod	= scr_tabelas_origem_destino
		-- tc  =  scr_tabelas_calculos
		-- ttc =  scr_tabelas_tipo_calculo
		-------------------------------------------------------------		
		parametros_tabela_frete AS ( 
			SELECT 	
								
				p.id_conhecimento,

				------------------------------------------------------------------------------------------------------------------------------
				--Processamento do valor total_nf que serve de base para calculos percentuais baseados
				-- no valor da nota fiscal (1,2) ou no valor total dos produtos (3).
				CASE WHEN COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) IN  (1,2) THEN 
					CASE WHEN p.total_nf % (tc.fracao::numeric(12,2)/100::numeric(12,2)) = 0 
									THEN  p.total_nf
									ELSE  (p.total_nf - (p.total_nf % tc.fracao)) + tc.fracao
					END 
				ELSE
					CASE WHEN p.total_valor_produtos % (tc.fracao::numeric(12,2)/100::numeric(12,2)) = 0 
									THEN  p.total_valor_produtos
									ELSE  (p.total_valor_produtos - (p.total_valor_produtos % tc.fracao)) + tc.fracao
					END 
				END AS total_nf,
					
				------------------------------------------------------------------------------------------------------------------------------
				--Definicao do valor origem do calculo do frete valor
				-- 1 - Valor total da Nota
				-- 2 - Valor total do Frete de Origem (Para redespacho)
				-- 3 - Valor total do Produto
				CASE 	WHEN COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) = 1 
						THEN 	CASE WHEN p.total_nf % (tc.fracao::numeric(12,2)/100::numeric(12,2)) = 0 
								THEN  p.total_nf
								ELSE  (p.total_nf - (p.total_nf % tc.fracao)) + tc.fracao
							END 
					WHEN COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) = 2 
						THEN 	CASE WHEN p.total_frete_origem  % (tc.fracao::numeric(12,2)/100::numeric(12,2)) = 0 
								THEN  p.total_frete_origem 
								ELSE  (p.total_frete_origem  - (p.total_nf % tc.fracao)) + tc.fracao
							END 						
					ELSE 	CASE WHEN p.total_valor_produtos % (tc.fracao::numeric(12,2)/100::numeric(12,2)) = 0 
							THEN  p.total_valor_produtos
							ELSE  (p.total_valor_produtos - (p.total_valor_produtos % tc.fracao)) + tc.fracao 
						END 
				END as total_valor,
				------------------------------------------------------------------------------------------------------------------------------
				-- Obs.: f_get_peso e utilizada para determinar a base do peso, cubado ou nao, para calculo do frete
				------------------------------------------------------------------------------------------------------------------------------
				-- Definicao do valor do peso (cubado ou nao) utilizado para calculo de pedagio
				CASE WHEN f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) % tc.fracao = 0 	OR tc.fracao  =  1
						THEN f_get_peso(tp,tc,COALESCE(densidade_nc,densidade))/tc.fracao 
						ELSE ((f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) - (f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) % tc.fracao)) + tc.fracao)/tc.fracao
				END as unidade_pedagio,
				------------------------------------------------------------------------------------------------------------------------------
				-- Definicao do valor do peso (nao cubado) utilizado para calculo do pedagio sobre o peso nao cubado.
				CASE WHEN tp % tc.fracao = 0 	OR tc.fracao  =  1
						THEN tp/tc.fracao 
						ELSE ((tp - tp % tc.fracao) + tc.fracao)/tc.fracao
				END as unidade_pedagio_peso_bruto,
				------------------------------------------------------------------------------------------------------------------------------
				-- Definicao do valor do peso (nao cubado ou cubado) utilizao
				CASE WHEN f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) % tc.fracao = 0 OR tc.fracao = 1
						THEN  f_get_peso(tp,tc,COALESCE(densidade_nc,densidade))
						ELSE  (f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) - (f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) % tc.fracao)) + tc.fracao
				END as total_peso,
				------------------------------------------------------------------------------------------------------------------------------
				
				p.total_unidades,
				p.id_natureza_carga as id_natureza_carga_ctrc,
				
				p.total_frete_origem,

				CASE WHEN tp <> f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) THEN true ELSE false END as peso_cubado,


				-- Dados vindos da tabela scr_tabelas_frete				
				t.numero_tabela_frete,	
				t.usar_descontos,					
				t.tipo_tabela,								

				CASE --transferido
					WHEN t.percentual_devolucao > 0 AND p.tipo_transporte = 2 
					THEN t.percentual_devolucao/100 
					ELSE 0.00 
				END::numeric(12,2) as  percentual_devolucao,
				
				CASE 
					WHEN t.percentual_reentrega > 0 AND p.tipo_transporte = 3
					THEN t.percentual_reentrega/100 
					ELSE 0.00 
				END::numeric(12,2) as percentual_reentrega,

				COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) AS calcular_a_partir_de,

								
				-- Dados Vindos da tabela scr_tabelas_cf -- Componentes do frete
				tcf.id_origem_destino, 
				tcf.compoe_bc,				
				tcf.isento_minimo::boolean,
				tcf.cond_ctrc::boolean,
				tcf.id_faixa,

				-- Dados Vindos da tabela de scr_tabelas_calculo
				tc.id_natureza_carga,
				tc.id_calculo, 
				tcf.id_tipo_calculo, 			
				tc.unidade_divisao as unidade,
				tc.medida_inicial,
				tc.medida_final,
				tc.id_tipo_veiculo as id_tipo_veiculo_tc,
				COALESCE(tc.tipo_transporte,0) as tipo_transporte,

				-- Dados vindos da tabela scr_tabelas_tipo_calculo
				ttc.descricao as tipo_calculo,
				ttc.dividir_por,
				-- Dados vindos da tabela scr_tabelas_origem_destino
				tod.id_origem,
				tod.id_destino,
				COALESCE(densidade_nc,tod.densidade) as densidade,
				tod.ida_volta,
				tod.cumulativa,
				tod.tipo_rota,

				p.coleta_exclusiva,
				p.id_regiao_origem,
				p.id_cidade_origem,
				p.capital_polo_coleta, 
				p.satelite_coleta,  
				p.interior_coleta, 
				p.fluvial_coleta,			
				p.km_percorridos_coleta,
				p.data_coleta,
				p.dia_coleta,
				p.hr_coleta,

				p.entrega_exclusiva,
				p.id_regiao_destino,
				p.id_cidade_destino,
				p.capital_polo_entrega, 
				p.satelite_entrega,  
				p.interior_entrega, 
				p.fluvial_entrega,			
				p.km_percorridos_entrega,
				p.data_entrega,				
				p.dia_entrega,
				p.hr_entrega,
				p.km_entrega,

				--Divide o valor variavel pelo fator de divisao
				tc.valor_variavel/ttc.dividir_por as valor_unitario,

				CASE    WHEN tc.valor_variavel_excedido > 0 	THEN true 
										ELSE false 	
				END as tem_excedente,				
														
				tc.valor_variavel/ttc.dividir_por as valor_variavel,
				tc.valor_fixo,
				tc.valor_variavel_excedido/ttc.dividir_por as valor_variavel_excedido,
				tc.valor_fixo_excedido,	
				tc.fracao,
				CASE WHEN tc.adicional_frete > 0 THEN tc.adicional_frete/100 ELSE 0.00 END::numeric(12,4) as adicional_frete,
				CASE WHEN tc.adicional_frete > 0 THEN tc.valor_fixo ELSE 0.00 END::numeric(12,4) as adicional_frete_minimo,
				
				
				(CASE WHEN true IS NOT NULL THEN 1 ELSE t.isento_imposto END)::boolean as isento_imposto,
				p.imposto_incluso::integer,

				COALESCE(NULLIF(tod.limite_peso_isento,0.00),t.limite_peso_isento)   as limite_peso,
				COALESCE(NULLIF(tod.limite_valor_isento,0.00),t.limite_valor_isento) as limite_valor,

				CASE WHEN tod.limite_peso_isento > 0.00 THEN tod.limite_peso_isento::integer::boolean 
									ELSE t.limite_peso_isento::integer::boolean  	
				END as tem_limite_peso,

				CASE WHEN tod.limite_valor_isento > 0.00 THEN tod.limite_valor_isento::integer::boolean
									 ELSE t.limite_valor_isento::integer::boolean
				END as tem_limite_valor,



				(f_get_peso(tp,tc,COALESCE(densidade_nc,densidade)) <= COALESCE(NULLIF(tod.limite_peso_isento,0.00),t.limite_peso_isento))   AS dentro_limite_peso,

				CASE 	WHEN COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) = 1 
						THEN 
							(p.total_nf <= 	COALESCE(NULLIF(tod.limite_valor_isento,0.00),t.limite_valor_isento))   

					WHEN COALESCE(tod.calcular_a_partir_de, t.calcular_a_partir_de) = 2 
						THEN 
							(p.total_frete_origem <= COALESCE(NULLIF(tod.limite_valor_isento,0.00),t.limite_valor_isento))
					ELSE 
						(p.total_valor_produtos <= COALESCE(NULLIF(tod.limite_valor_isento,0.00),t.limite_valor_isento))
				END AS dentro_limite_valor,
				p.tem_pre_calculo				
			FROM 
				parametros p
				LEFT JOIN scr_tabelas t
					ON p.numero_tabela_frete = t.numero_tabela_frete
				LEFT JOIN scr_tabelas_origem_destino tod
					ON t.id_tabela_frete = tod.id_tabela_frete
				LEFT JOIN scr_tabelas_cf tcf
					ON (tod.id_origem_destino = tcf.id_origem_destino)
				LEFT JOIN scr_tabelas_calculos as tc
					ON tcf.id_cf = tc.id_cf				
				LEFT JOIN scr_tabelas_tipo_calculo as ttc
					ON ttc.id_tipo_calculo = tcf.id_tipo_calculo
				
			WHERE 
				t.numero_tabela_frete = p.numero_tabela_frete
				AND t.ativa = 1				
				--FILTRA TIPO DE TRANSPORTE
				AND 	CASE 
						WHEN tc.tipo_transporte IS NULL THEN true -- Se estiver nulo na tabela, seleciona
						ELSE tc.tipo_transporte = p.tipo_transporte
					END 
					
				-- FILTRA TIPO VEICULO
				-- Quando o valor na tabela (tc) for nulo, ignora o que vem do frete
			 	AND 	CASE
						WHEN tc.id_tipo_veiculo IS NOT NULL THEN 
							COALESCE(tc.id_tipo_veiculo,-1) = p.id_tipo_veiculo
						ELSE
							true
					END 
					
				-- FILTRA TIPO DE CARGA
  				-- Quando o valor na tabela (tc) for nulo, ignora o que vem do frete								
				AND	CASE
						WHEN tc.tipo_carga IS NOT NULL THEN
							COALESCE(tc.tipo_carga,-1) = p.tipo_carga
						ELSE
							true
					END
				
				-- FILTRA NATUREZA DA CARGA
				AND	CASE	
						WHEN tc.id_natureza_carga IS NOT NULL THEN
							(p.id_natureza_carga = tc.id_natureza_carga)
						ELSE	
							true
					END
							
				AND 	CASE 	WHEN tod.tipo_rota = 3 THEN 
							true				
						WHEN tod.ida_volta = 1 AND tod.tipo_rota = 2 THEN 
							((tod.id_origem = p.id_regiao_origem AND tod.id_destino = p.id_regiao_destino) 
								OR 
							(tod.id_origem = p.id_regiao_destino AND tod.id_destino = p.id_regiao_origem)
							        OR
							 (tod.id_origem = p.id_regiao_origem_bairro AND tod.id_destino = p.id_regiao_destino_bairro))
							
						WHEN tod.ida_volta = 0 AND tod.tipo_rota = 2 THEN
							(tod.id_origem = p.id_regiao_origem AND tod.id_destino = p.id_regiao_destino)

						WHEN tod.ida_volta = 1 AND tod.tipo_rota = 1 THEN
							((tod.id_origem = p.id_cidade_origem AND tod.id_destino = p.id_cidade_destino) 
								OR 
							(tod.id_origem = p.id_cidade_destino AND tod.id_destino = p.id_cidade_origem))							
							
						WHEN tod.ida_volta = 0 AND tod.tipo_rota = 1 THEN 
							(tod.id_origem = p.id_cidade_origem AND tod.id_destino = p.id_cidade_destino)

						WHEN tod.tipo_rota = 0 THEN 
							tod.id_destino = p.destinatario_id
							
						WHEN tod.tipo_rota = -1 THEN 
							tod.id_origem = p.remetente_id
						ELSE
							true
					END
				
				--Filtra taxas de coleta normal de acordo com o status na regiao de origem				
				AND 	CASE WHEN tcf.id_tipo_calculo IN (25) 	THEN COALESCE(p.satelite_coleta, false) AND (coleta_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END									
				AND 	CASE WHEN tcf.id_tipo_calculo IN (26) 	THEN COALESCE(p.interior_coleta, false) AND (coleta_normal OR NOT tcf.cond_ctrc::boolean)	
										ELSE true 
					END
				AND 	CASE WHEN tcf.id_tipo_calculo IN (24) 	THEN COALESCE(p.capital_polo_coleta, false) AND (coleta_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END
				AND 	CASE WHEN tcf.id_tipo_calculo IN (28) 	THEN COALESCE(p.fluvial_coleta) AND (coleta_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END

				--Filtra taxas de entrega normal de acordo com o status na regiao de origem
				AND 	CASE WHEN tcf.id_tipo_calculo IN (30) 	THEN COALESCE(p.satelite_entrega, false) AND (entrega_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END
				AND 	CASE WHEN tcf.id_tipo_calculo IN (31) 	THEN COALESCE(p.interior_entrega, false) AND (entrega_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END
				AND 	CASE WHEN tcf.id_tipo_calculo IN (29) 	THEN COALESCE(p.capital_polo_entrega, false) AND (entrega_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END
				AND 	CASE WHEN tcf.id_tipo_calculo IN (36) 	THEN COALESCE(p.fluvial_coleta) AND (entrega_normal OR NOT tcf.cond_ctrc::boolean)
										ELSE true 
					END				
				--Filtra Ad Valorem de acordo com a configuracao das cidades.			
					
				AND 	CASE WHEN tcf.id_tipo_calculo IN (19,20)THEN 	(COALESCE(p.satelite_entrega, false) 
											OR COALESCE(p.capital_polo_entrega, false)
											OR tod.tipo_rota IN (1,3))											 
										ELSE true 
					END
					
				AND 	CASE WHEN tcf.id_tipo_calculo IN (21) 	THEN COALESCE(p.interior_entrega, false) 
										ELSE true 
					END				
				AND 	CASE WHEN tcf.id_tipo_calculo IN (23) 	THEN COALESCE(p.fluvial_entrega,false) 
										ELSE true 
					END

				--Verifica se tem taxa expresso
				AND 
					CASE 	WHEN tcf.id_tipo_calculo = 37  AND (entrega_expresso OR NOT tcf.cond_ctrc::boolean)
						THEN 
							CASE 	WHEN interior_entrega 	THEN false ELSE true END
						WHEN tcf.id_tipo_calculo = 37  AND (coleta_expresso OR NOT tcf.cond_ctrc::boolean)	
						THEN 
							CASE 	WHEN interior_coleta 	THEN false ELSE true END
						WHEN tcf.id_tipo_calculo = 37 	--Se nao tem nem entrega ou coleta expresso, nao calcula.			
						THEN false ELSE	true
					END
					
				--Verifica se tem taxa emergencia
				AND 
					CASE 	WHEN tcf.id_tipo_calculo = 38 
						THEN CASE WHEN (entrega_emergencia OR coleta_emergencia OR NOT tcf.cond_ctrc::boolean)  THEN true ELSE false END
						ELSE true
					END
					
				--Verifica as taxas de redespacho
				AND 
					CASE 	WHEN tcf.id_tipo_calculo = 34 AND (NOT p.interior_entrega) THEN false ELSE true END
				AND
					CASE 	WHEN tcf.id_tipo_calculo = 36 AND (NOT p.fluvial_entrega) THEN false ELSE true END
					
				--Verifica taxas de dificuldade de coleta e entrega
				AND 
					CASE 	WHEN tcf.id_tipo_calculo = 43 AND (NOT p.coleta_dificuldade OR NOT tcf.cond_ctrc::boolean) THEN false ELSE true END
				AND 
					CASE 	WHEN tcf.id_tipo_calculo IN (77,44)  AND (NOT p.entrega_dificuldade OR NOT tcf.cond_ctrc::boolean) THEN false ELSE true END	
					
				--Verifica taxa de exclusividade de veiculo
				AND 
					CASE 	WHEN tcf.id_tipo_calculo = 45 THEN 
							CASE WHEN NOT (p.entrega_exclusiva OR p.coleta_exclusiva OR NOT tcf.cond_ctrc::boolean) THEN  false ELSE true END	
						ELSE
							true
					END 
					
				--Verifica se tem pre-calculo de frete peso
				AND 
					CASE	WHEN p.tem_pre_calculo AND tcf.id_tipo_calculo = 1 THEN
							false
						ELSE
							true
					END
				--Filtra Coleta por horario				
				AND
					CASE 	WHEN tcf.id_tipo_calculo IN (54,79) THEN 							
							CASE WHEN dia_coleta IS NOT NULL THEN
								CASE 	WHEN dia_coleta = 1 AND tc.s1 = 1 THEN true
									WHEN dia_coleta = 2 AND tc.s2 = 1 THEN true
									WHEN dia_coleta = 3 AND tc.s3 = 1 THEN true
									WHEN dia_coleta = 4 AND tc.s4 = 1 THEN true
									WHEN dia_coleta = 5 AND tc.s5 = 1 THEN true
									WHEN dia_coleta = 6 AND tc.s6 = 1 THEN true
									WHEN dia_coleta = 7 AND tc.s7 = 1 THEN true 
									ELSE false
								END
							ELSE
								false
							END
						ELSE
							true
					END
				--Filtra entrega por horario
				AND
					CASE 	WHEN tcf.id_tipo_calculo = 55 THEN 							
							CASE WHEN dia_entrega IS NOT NULL THEN
								CASE 	WHEN dia_entrega = 1 AND tc.s1 = 1 THEN true
									WHEN dia_entrega = 2 AND tc.s2 = 1 THEN true
									WHEN dia_entrega = 3 AND tc.s3 = 1 THEN true
									WHEN dia_entrega = 4 AND tc.s4 = 1 THEN true
									WHEN dia_entrega = 5 AND tc.s5 = 1 THEN true
									WHEN dia_entrega = 6 AND tc.s6 = 1 THEN true
									WHEN dia_entrega = 7 AND tc.s7 = 1 THEN true 
									ELSE false
								END
							ELSE
								false
							END
						ELSE
							true
					END
				--Descarta frete peso do tipo m3, codigo 13
				AND tcf.id_tipo_calculo <> 13
								
		),
		--- Verifica se aplica isencao
		isencao AS (
			SELECT 
	-- 			A = tem_limite_valor, B = tem_limite_peso, C = dentro_limite_valor, D = dentro_limite_peso
	-- 			Y = A*|B*C + B*C*D + |A*B*D
	--			MAPA DE KARNAUGH
	--				"00"	"01"	"11"	"10"
	-- 			"00" 	 0	 0	 0	 0
	-- 			"01"	 0	 1	 1	 0
	-- 			"11"	 0	 0	 1	 0
	-- 			"10"	 0	 0	 1	 1
				id_conhecimento,
				--quantidade_calculo,
				--tipo_calculo,
				--limite_peso,
				--limite_valor,			
				(
					(ptf.tem_limite_valor  AND ptf.dentro_limite_valor AND (NOT ptf.tem_limite_peso))
									OR
					(ptf.tem_limite_peso   AND ptf.dentro_limite_peso  AND (NOT ptf.tem_limite_valor))
									OR
					(ptf.tem_limite_peso   AND ptf.dentro_limite_valor AND ptf.dentro_limite_peso)
				)
				as aplica_isencao		
			FROM
				parametros_tabela_frete ptf
			GROUP BY 			
				id_conhecimento, 
				tem_limite_valor, 
				tem_limite_peso, 
				dentro_limite_valor, 
				dentro_limite_peso
		),
		--Determina tipo de rota prioritaria (1 - Cidade, 2 - Regiao, 3 - Sem Rota)
		rota_prioritaria AS (
			SELECT min(tipo_rota)::integer as tipo_rota FROM parametros_tabela_frete
		),			
		--Percentuais de Devolucao e Reentrega
		percentuais AS (
			SELECT percentual_reentrega, percentual_devolucao 
			FROM parametros_tabela_frete 
			GROUP BY percentual_reentrega, percentual_devolucao
		),
				
		---Faz descarte das faixas de regras de calculos que nao se aplicam no calculo do frete
		parametros_faixa_calculo AS (
		SELECT 
			ptf.*,
			max(tipo_transporte) over (partition by id_tipo_calculo) as tipo_transporte_selecionado,
			isencao.aplica_isencao,
			CASE	WHEN ptf.id_tipo_calculo IN (15,19,20,21,22,23,53,74) AND calcular_a_partir_de = 2 THEN total_nf
				WHEN ptf.id_tipo_calculo IN (15,19,20,21,22,23,53,74) AND calcular_a_partir_de IN(1,3) 	THEN total_valor
				--WHEN ptf.id_tipo_calculo IN (13) THEN null --total_peso_cubad				
				WHEN ptf.id_tipo_calculo IN (8)  THEN total_unidades -- total_unidades
				WHEN ptf.id_tipo_calculo IN (12,46) THEN km_entrega -- total_km
				WHEN ptf.id_tipo_calculo IN (45) THEN 
					CASE 	WHEN coleta_exclusiva THEN  km_percorridos_coleta --total km 					
						WHEN entrega_exclusiva THEN km_percorridos_entrega --total km 					
						ELSE null
					END					
				--WHEN ptf.id_tipo_calculo IN (12,45,46) THEN null --total_dias 					
				WHEN ptf.id_tipo_calculo IN (2,3,79) THEN total_valor 			
				WHEN ptf.id_tipo_calculo IN (6) THEN null --total_eixo 					
				WHEN ptf.id_tipo_calculo IN (14,40) THEN null --total_horas 
				WHEN ptf.id_tipo_calculo IN (5,47) THEN unidade_pedagio
				WHEN ptf.id_tipo_calculo IN (75) THEN unidade_pedagio_peso_bruto
				WHEN ptf.id_tipo_calculo IN (1,5,9,10,11,16,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,77,78) THEN total_peso
				WHEN ptf.id_tipo_calculo IN (4,17,18,41,42,43,44,48,49,50,52,54,55,70,71, 80) THEN 1 -- Sem parametro, entao 1 por padrao
			END as quantidade_calculo			
		FROM 
			parametros_tabela_frete ptf, isencao, rota_prioritaria
		WHERE
			NOT (ptf.isento_minimo AND isencao.aplica_isencao)
			-- Se for cumulativa adiciona aos componentes de frete.			
			AND (ptf.tipo_rota = rota_prioritaria.tipo_rota OR ptf.cumulativa = 1)
			AND
				-- Se medida inicial e final for 0, ent�o ignora filtro de medida				
			CASE	WHEN ptf.medida_inicial = 0 AND ptf.medida_final = 0 	THEN 
					true
				-- Se medida final for 0, filtra trazendo somente se o valor da medida for maior ou igual a medida inicial
				WHEN 	ptf.medida_final = 0 THEN
					CASE	WHEN ptf.id_tipo_calculo IN (15,19,20,21,22,23,74) THEN ptf.total_nf >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (13) THEN false --total_peso_cubado					
						WHEN ptf.id_tipo_calculo IN (8, 46)  THEN ptf.total_unidades >= ptf.medida_inicial -- total_unidades
						WHEN ptf.id_tipo_calculo IN (12) THEN ptf.km_entrega >= ptf.medida_inicial -- total_km
						WHEN ptf.id_tipo_calculo IN (45) THEN-- Verifica se � coleta ou entrega
							CASE WHEN coleta_exclusiva 	THEN ptf.km_percorridos_coleta >= ptf.medida_inicial 
							     WHEN entrega_exclusiva 	THEN ptf.km_percorridos_entrega >= ptf.medida_inicial 
											ELSE false
							END
						WHEN ptf.id_tipo_calculo IN (45) AND coleta_exclusiva	THEN ptf.km_percorridos_entrega >= ptf.medida_inicial -- total km entrega	
						WHEN ptf.id_tipo_calculo IN (7,51) THEN true --total_dias 					
						WHEN ptf.id_tipo_calculo IN (2,3) THEN ptf.total_valor >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (6) THEN true --total_eixo 					
						WHEN ptf.id_tipo_calculo IN (5,47) THEN ptf.unidade_pedagio >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (14,40) THEN true --total_horas 
						WHEN ptf.id_tipo_calculo IN (75) THEN ptf.unidade_pedagio_peso_bruto >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (54, 79) THEN COALESCE(ptf.hr_coleta,-1) >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (55) THEN COALESCE(ptf.hr_entrega,-1) >= ptf.medida_inicial						
						WHEN ptf.id_tipo_calculo IN (1,9,10,11,16,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,53) THEN ptf.total_peso >= ptf.medida_inicial
						WHEN ptf.id_tipo_calculo IN (4,17,18,41,42,43,44,48,49,50,52,70,71,77,78, 80) THEN true -- Sem parametro, entao 1 por padrao 
					END 
					
				-- Se a medida final for diferente de 0, verifica se esta dentro da faixa, ou se tem valor para excedido
				ELSE	
					CASE	WHEN ptf.id_tipo_calculo IN (15,19,20,21,22,23,74) THEN 
							ptf.total_nf >= ptf.medida_inicial 
							AND (ptf.total_nf <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)
									
						WHEN ptf.id_tipo_calculo IN (13) THEN false --total_peso_cubado					
						
						WHEN ptf.id_tipo_calculo IN (8)  THEN 
							ptf.total_unidades >= ptf.medida_inicial 
							AND (ptf.total_unidades <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)

						WHEN ptf.id_tipo_calculo IN (12, 46) THEN 							
							ptf.km_entrega >= ptf.medida_inicial 
							AND (ptf.km_entrega <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)					
						
						WHEN ptf.id_tipo_calculo IN (45) THEN 
							CASE 	WHEN coleta_exclusiva THEN 
									ptf.km_percorridos_coleta >= ptf.medida_inicial 
									AND (ptf.km_percorridos_coleta <= ptf.medida_final 
									OR ptf.valor_variavel_excedido > 0 
									OR ptf.valor_fixo_excedido > 0)
								WHEN entrega_exclusiva	THEN 
									ptf.km_percorridos_entrega >= ptf.medida_inicial 
									AND (ptf.km_percorridos_entrega <= ptf.medida_final 
									OR ptf.valor_variavel_excedido > 0 
									OR ptf.valor_fixo_excedido > 0)
								ELSE 
									false
							END								
																				
						WHEN ptf.id_tipo_calculo IN (7,51) THEN true --total_dias 					

						WHEN ptf.id_tipo_calculo IN (2,3) THEN 
							ptf.total_valor >= ptf.medida_inicial 
							AND (ptf.total_valor <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)

						WHEN ptf.id_tipo_calculo IN (6) THEN true --total_eixo 					

						WHEN ptf.id_tipo_calculo IN (5,47) THEN 
							ptf.unidade_pedagio >= ptf.medida_inicial 
							AND (ptf.unidade_pedagio <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)

						WHEN ptf.id_tipo_calculo IN (75) THEN 
							ptf.unidade_pedagio_peso_bruto >= ptf.medida_inicial 
							AND (ptf.unidade_pedagio_peso_bruto <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)
						
						WHEN ptf.id_tipo_calculo IN (14,40) THEN true --total_horas 

						WHEN ptf.id_tipo_calculo IN (54, 79) THEN 
							ptf.hr_coleta >= ptf.medida_inicial 
							AND (ptf.hr_coleta <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)		

						WHEN ptf.id_tipo_calculo IN (55) THEN 
							ptf.hr_entrega >= ptf.medida_inicial 
 							AND (ptf.hr_entrega <= ptf.medida_final 
 							OR ptf.valor_variavel_excedido > 0 
 							OR ptf.valor_fixo_excedido > 0)		
							
						
						WHEN ptf.id_tipo_calculo IN (1,9,10,11,16,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,53) THEN 
							ptf.total_peso >= ptf.medida_inicial 
							AND (ptf.total_peso <= ptf.medida_final 
							OR ptf.valor_variavel_excedido > 0 
							OR ptf.valor_fixo_excedido > 0)			
								
						WHEN ptf.id_tipo_calculo IN (4,17,18,41,42,43,44,48,49,50,52,70,71,77, 78, 80) THEN 
							true 
					END 								
					
			END
			
		),		
		preparacao_dados AS (
		SELECT 
			id_conhecimento,
			tem_pre_calculo,
			peso_cubado,
			id_calculo,
			id_tipo_calculo,
			tipo_calculo, 
			id_cidade_origem,
			pfc.id_cidade_destino,
			id_regiao_origem,
			id_regiao_destino,
			total_nf,
			total_valor,
			unidade,
			medida_inicial,
			medida_final,
			valor_unitario::numeric(12,5),
			tem_excedente,	
			valor_fixo,					
			quantidade_calculo,
			imposto_incluso,
			id_faixa,

			CASE 	WHEN isento_imposto 
				THEN 0.00		
				ELSE 12.00 --v_aliquota
			END as aliquota,

			valor_fixo as frete_minimo,

			valor_fixo_excedido,	


			CASE 	WHEN tem_excedente AND quantidade_calculo > medida_final 	
				THEN medida_final 
				ELSE quantidade_calculo 
			END quantidade_faixa,
			
			valor_variavel::numeric(12,8),
			
			CASE 	WHEN tem_excedente AND quantidade_calculo > medida_final 	
				THEN (medida_final/unidade) * valor_variavel 
				ELSE (quantidade_calculo/unidade) * valor_variavel 
			END::numeric(12,5) as valor_pagar_faixa,

			CASE 	WHEN tem_excedente AND quantidade_calculo > medida_final 	
				THEN quantidade_calculo - medida_final 
				ELSE 0 
			END as quantidade_excedente,

			valor_variavel_excedido::numeric(12,8),				
			
			CASE 	WHEN tem_excedente AND quantidade_calculo > medida_final 	
				THEN ((quantidade_calculo - medida_final)/unidade) * valor_variavel_excedido 
				ELSE 0 
			END::numeric(12,5) as valor_pagar_excedente,
			valor_fixo_excedido as valor_minimo_excedente
		FROM	
			parametros_faixa_calculo pfc
		WHERE
			pfc.tipo_transporte = pfc.tipo_transporte_selecionado
			--Tipo de Calculo TDE sobre Percentual do Frete nao calcula aqui
			AND pfc.id_tipo_calculo <> 77 
			AND pfc.id_tipo_calculo <> 78
			AND pfc.id_tipo_calculo <> 80
			
		), 
		valores_cf AS (
		SELECT 
			totais.id_conhecimento,
			1::integer as id_tipo_calculo,
			0::integer as excedente,
			1::integer as quantidade,
			totais.vl_frete_peso as valor_item,
			totais.vl_frete_peso as total_itens,
			0::numeric(12,2) as valor_minimo,
			totais.vl_frete_peso as valor_pagar,
			1::integer as id_faixa
		FROM
			totais
		WHERE
			totais.tem_pre_calculo
		UNION
		SELECT 	
			id_conhecimento,
			id_tipo_calculo,
			0::integer as excedente,
			(quantidade_faixa/unidade)::numeric(12,3) as quantidade, 
			valor_variavel as valor_item,
			valor_pagar_faixa as total_itens,
			frete_minimo as valor_minimo,
			f_maior(valor_pagar_faixa, frete_minimo) as valor_pagar,
			id_faixa
		FROM 
			preparacao_dados					
		UNION 
		SELECT 			
			id_conhecimento,
			id_tipo_calculo,
			1::integer as excedente,
			(quantidade_excedente/unidade)::numeric(12,3) as quantidade, 
			valor_variavel_excedido as valor_item,
			valor_pagar_excedente as total_itens,
			valor_minimo_excedente as valor_minimo,
			f_maior(valor_pagar_excedente, valor_minimo_excedente) as valor_pagar,
			id_faixa
		FROM 
			preparacao_dados
		WHERE 
			(valor_pagar_excedente > 0 OR valor_minimo_excedente > 0)
		ORDER BY 
			1,
			3
		),
		totais_faixa_grupo AS (
			SELECT 
				id_faixa, 
				SUM(valor_pagar) as total_valor
			FROM 
				valores_cf
			WHERE 
				id_faixa IN (2,3)
			GROUP BY
				id_faixa
		),
		grupo_maior AS (
			SELECT 
				id_faixa
			FROM 
				totais_faixa_grupo
			ORDER BY 
				total_valor				
				DESC 
			LIMIT 1
		),
		grupo_selecionado AS (
			SELECT 1::integer AS id_faixa
				UNION
			SELECT id_faixa FROM grupo_maior
		),
		frete_sem_desconto AS (
			SELECT 	
				NULL::integer as id_conhecimento_cf,
				id_conhecimento,
				valores_cf.id_tipo_calculo,
				scr_tabelas_tipo_calculo.descricao,
				SUM(excedente) as excedente,
				SUM(quantidade) as quantidade,
				SUM(valor_item) as valor_item,
				SUM(total_itens) as valor_total,
				SUM(valor_minimo) as valor_minimo,				
				SUM(valor_pagar) as valor_pagar_sdesconto,
				0.00::numeric(12,2) as desconto,				
				0.00::numeric(12,2) as valor_pagar,
				'C'::character(1) as operacao,
				valores_cf.id_faixa,
				0::integer as combinado		
			FROM 	
				valores_cf
					RIGHT JOIN grupo_selecionado ON valores_cf.id_faixa = grupo_selecionado.id_faixa
					LEFT JOIN scr_tabelas_tipo_calculo ON valores_cf.id_tipo_calculo = scr_tabelas_tipo_calculo.id_tipo_calculo
			WHERE 
				valor_pagar IS NOT NULL			
			GROUP BY 
				id_conhecimento,
				valores_cf.id_tipo_calculo,
				scr_tabelas_tipo_calculo.descricao,
				valores_cf.id_faixa

			ORDER BY 
				id_tipo_calculo,
				excedente
		),
		frete_sem_adicional AS ( 
			SELECT 
				id_conhecimento_cf,
				id_conhecimento,
				id_tipo_calculo,
				descricao,
				excedente::integer as excedente,
				quantidade,
				valor_item,
				valor_total::numeric(12,2) as valor_total,
				valor_minimo,				
				CASE 	WHEN ent.perc_desc_calculo > 0.00 
					THEN valor_pagar_sdesconto - (valor_pagar_sdesconto * perc_desc_calculo / 100)
					ELSE valor_pagar_sdesconto
				END::numeric(12,2) as valor_pagar,
				operacao,
				id_faixa,
				combinado,
				ent.modo_calculo::integer modo_calculo,
				ent.perc_desc_calculo as perc_desconto,
				valor_pagar_sdesconto::numeric(12,2) as valor_pagar_sdesconto,
				CASE 	WHEN ent.perc_desc_calculo > 0.00 
					THEN valor_pagar_sdesconto * perc_desc_calculo / 100
					ELSE 0.00
				END::numeric(12,2) as desconto
			FROM 
				frete_sem_desconto,ent
		),
		frete_com_adicional AS (
			WITH 
			a AS (
				
				SELECT	
					adicional_frete as adicional, 
					adicional_frete_minimo as adicional_minimo,
					parametros_faixa_calculo.id_tipo_calculo,
					scr_tabelas_tipo_calculo.descricao 
				FROM 	
					parametros_faixa_calculo
					LEFT JOIN scr_tabelas_tipo_calculo 
						ON parametros_faixa_calculo.id_tipo_calculo = scr_tabelas_tipo_calculo.id_tipo_calculo 
				WHERE 	
					parametros_faixa_calculo.id_tipo_calculo IN (56,77,78,80)
				
			), 			
			v AS
			(
				SELECT SUM(valor_pagar) as total_valor_pagar FROM frete_sem_adicional 
			),
			valor_adicional AS 
			(
				SELECT 
					adicional,
					id_tipo_calculo,
					descricao,
					total_valor_pagar,
					adicional_minimo,
					f_maior(CASE 	WHEN adicional > 0 AND total_valor_pagar > 0 
						THEN total_valor_pagar * adicional
						ELSE 0.00
					END, adicional_minimo) as valor_adicional
				FROM a,v
			)
			SELECT 
				NULL::integer as id_conhecimento_cf,
				1::integer as id_conhecimento,
				id_tipo_calculo as id_tipo_calculo,
				descricao,
				0.00::integer as excedente,
				adicional::numeric(12,2) as quantidade,
				total_valor_pagar::numeric(12,6) as valor_item,
				valor_adicional::numeric(12,2) as valor_total,
				0.00::numeric(12,2) as valor_minimo,
				valor_adicional::numeric(12,2) as valor_pagar,
				'C'::character(1) as operacao,
				1::integer as id_faixa,
				0::integer as combinado,
				1::integer as modo_calculo,
				0.00::numeric(5,2) as perc_desconto,
				valor_adicional::numeric(12,2) as valor_pagar_sdesconto,
				0.00::numeric(12,2) as desconto
			FROM valor_adicional WHERE valor_adicional > 0		
			
		),
		frete_com_reentrega AS (
			WITH 
			v AS
			(
				SELECT SUM(valor_pagar) as total_valor_pagar FROM frete_sem_adicional 
			),
			valor_adicional AS 
			(
				SELECT 
					percentual_reentrega,
					total_valor_pagar,
					CASE 	WHEN percentual_reentrega > 0 AND total_valor_pagar > 0 
						THEN total_valor_pagar * percentual_reentrega
						ELSE 0.00
					END as valor_adicional
				FROM percentuais,v
			)
			SELECT 
				NULL::integer as id_conhecimento_cf,
				1::integer as id_conhecimento,
				57::integer as id_tipo_calculo,
				'Adicional Reentrega'::character(50) as descricao,
				0.00::integer as excedente,
				percentual_reentrega::numeric(12,2) as quantidade,
				total_valor_pagar::numeric(12,6) as valor_item,
				valor_adicional::numeric(12,2) as valor_total,
				0.00::numeric(12,2) as valor_minimo,
				valor_adicional::numeric(12,2) as valor_pagar,
				'C'::character(1) as operacao,
				1::integer as id_faixa,
				0::integer as combinado,
				1::integer as modo_calculo,
				0.00::numeric(5,2) as perc_desconto,
				valor_adicional::numeric(12,2) as valor_pagar_sdesconto,
				0.00::numeric(12,2) as desconto
			FROM valor_adicional WHERE valor_adicional > 0		
			
		),
		frete_com_devolucao AS (
			WITH 
			v AS
			(
				SELECT SUM(valor_pagar) as total_valor_pagar FROM frete_sem_adicional 
			),
			valor_adicional AS 
			(
				SELECT 
					percentual_devolucao,
					total_valor_pagar,
					CASE 	WHEN percentual_devolucao > 0 AND total_valor_pagar > 0 
						THEN total_valor_pagar * percentual_devolucao
						ELSE 0.00
					END as valor_adicional
				FROM percentuais,v
			)
			SELECT 
				NULL::integer as id_conhecimento_cf,
				1::integer as id_conhecimento,
				58::integer as id_tipo_calculo,
				'Adicional Devolucao'::character(50) as descricao,
				0.00::integer as excedente,
				percentual_devolucao::numeric(12,2) as quantidade,
				total_valor_pagar::numeric(12,6) as valor_item,
				valor_adicional::numeric(12,2) as valor_total,
				0.00::numeric(12,2) as valor_minimo,
				valor_adicional::numeric(12,2) as valor_pagar,
				'C'::character(1) as operacao,
				1::integer as id_faixa,
				0::integer as combinado,
				1::integer as modo_calculo,
				0.00::numeric(5,2) as perc_desconto,
				valor_adicional::numeric(12,2) as valor_pagar_sdesconto,
				0.00::numeric(12,2) as desconto
			FROM valor_adicional WHERE valor_adicional > 0		
			
		)
		---------------------------------------------------------------------------------------------------------------------------------------------------
		--- FIM DO WITH
		---------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT * FROM frete_sem_adicional
			UNION 
		SELECT * FROM frete_com_adicional
			UNION 
		SELECT * FROM frete_com_reentrega
			UNION 
		SELECT * FROM frete_com_devolucao		
		ORDER BY 
			id_tipo_calculo;


		-- Verifica se foi calculado o frete
		v_qt_cf = 0;
		vTotalFrete = 0.00;		
		
		LOOP
			FETCH IN cf INTO vResultadoFrete;
			EXIT 		WHEN NOT FOUND;
			
			--CONTINUE 	WHEN FOUND;
			
			IF vResultadoFrete.id_tipo_calculo < 1000 THEN 
				v_qt_cf = v_qt_cf + 1;
			END IF;
			
			vTotalFrete = vTotalFrete + vResultadoFrete.valor_pagar;
		END LOOP;

		--RAISE NOTICE 'Total Frete %', vTotalFrete;
		--Se nao foi identificada nenhuma faixa de calculo alem da do imposto.
		IF v_qt_cf = 0 THEN 

			SELECT 
				MAX(tipo_rota) as tipo_rota,
				scr_tabelas.id_tabela_frete	
			INTO 
				vTipoRota, 
				vIdTabelaFrete			
			FROM	
				scr_tabelas
				LEFT JOIN scr_tabelas_origem_destino 
					ON scr_tabelas_origem_destino.id_tabela_frete = scr_tabelas.id_tabela_frete
			WHERE	
				numero_tabela_frete = parametros->>'tabela_frete'
			GROUP BY 
				scr_tabelas.id_tabela_frete;
			
			
			IF vTipoRota IS NULL THEN -- O conhecimento nao existe
				vRetorno = ('{"codigo":2, "Mensagem":"Tabela de Frete nao existe!"}')::json;
				
			ELSE -- Se o conhecimento existe, entao verifica se tem tabela frete 
				CASE 
				
				WHEN vTipoRota = 2 THEN -- Se a tabela tem origem e destino por regiao
					
					vRegioes = f_scr_retorna_regioes_origem_destino(
								(parametros->>'calculado_de_id_cidade')::text::integer,
								(parametros->>'calculado_ate_id_cidade')::text::integer,
								(parametros->>'tabela_frete')::text
								);

					vRegiaoOrigem = (vRegioes->'id_regiao_origem')::text::integer;
					vRegiaoDestino = (vRegioes->'id_regiao_destino')::text::integer;
								
					IF vRegiaoOrigem = -1 THEN  -- Se regiao origem for -1, cidade origem nao configurada
												
						vRetorno = ('{"codigo":3, "Mensagem":"Origem/Destino nao encontrado."}')::json;
			
					ELSE --
						IF vRegiaoDestino = -1 THEN  -- Verifica se a cidade destino esta em alguma regiao
							vRetorno = ('{"codigo":4, "Mensagem":"Origem/destino nao encontrado."}')::json;
							
						ELSE
							vRetorno = ('{"codigo":16, "Mensagem":"Nao foi identificada nenhuma faixa de calculo de componentes de frete!"}')::json;
							
						END IF;
					END IF;
				
				WHEN vTipoRota = 1 THEN 

					SELECT count(*) as quantidade
					INTO vQuantRotasCidade
					FROM 	scr_tabelas_origem_destino				
					WHERE 	
						CASE 
							WHEN ida_volta = 1 THEN 
								id_origem = vCidadeOrigem
								AND id_destino = vCidadeDestino							
							ELSE
								id_origem = vCidadeDestino
								AND id_origem = vCidadeOrigem
							
						END
						AND scr_tabelas_origem_destino.id_tabela_frete = vIdTabelaFrete;

					IF vQuantRotasCidade = 0 THEN 
						vRetorno = ('{"codigo":5, "Mensagem":"Nao foi encontrado Origem/Destino das cidades do conhecimento!"}')::json;
					
					ELSE
						vRetorno = ('{"codigo":16, "Mensagem":"Nao foi identificada nenhuma faixa de calculo de componentes de frete!"}')::json;
					
					END IF;
				ELSE 
					vRetorno = ('{"codigo":16, "Mensagem":"Nao foi identificada nenhuma faixa de calculo de componentes de frete!"}')::json;
				END CASE;									
			END IF;			
			
		ELSE
			MOVE BACKWARD ALL FROM cf;
			vRetorno = ('{"codigo":0, "Mensagem":"Frete Calculado"}')::json;			
		END IF;
		
		
		RETURN NEXT cf;

		OPEN msg FOR SELECT vRetorno as msg;

		RETURN NEXT msg;
					
		
	ELSE --- Se for frete combinado;

		CASE 	WHEN (parametros->>'vl_combinado')::text::numeric 	> 0.00 	THEN 
				v_quantidade_comb = 1;
				v_valor_item_comb = (parametros->>'vl_combinado')::text::numeric;
				v_valor_total_comb	= v_quantidade_comb * v_valor_item_comb;
				v_valor_pagar_comb	= v_valor_total_comb;
				v_tipo_combinado = 1;
				
			WHEN (parametros->>'vl_tonelada')::text::numeric 	> 0.00 	THEN 
			
				v_quantidade_comb = ((parametros->>'peso')::text::numeric)/1000;
				v_valor_item_comb 	= (parametros->>'vl_tonelada')::text::numeric;
				v_valor_total_comb	= v_quantidade_comb * v_valor_item_comb;
				v_valor_pagar_comb	= v_valor_total_comb;
				v_tipo_combinado = 1;				
				
			WHEN (parametros->>'vl_percentual_nf')::text::numeric 	> 0.00	THEN 

				v_quantidade_comb = (parametros->>'valor_nota_fiscal')::text::numeric;
				v_valor_item_comb 	= ((parametros->>'vl_percentual_nf')::text::numeric)/100;
				v_valor_total_comb	= v_quantidade_comb * v_valor_item_comb;
				v_valor_pagar_comb	= v_valor_total_comb;
				v_tipo_combinado 	= 2;							
				
			ELSE 
				v_tipo_combinado = NULL;
		END CASE;
	
		-- Deleta se o valor e 0.00
		OPEN cf FOR 
		SELECT 	
			NULL::integer as id_conhecimento_cf,
			NULL::integer as id_conhecimento,			
			CASE 
				WHEN tcf.id_tipo_calculo = v_tipo_combinado THEN 
					COALESCE(v_tipo_combinado,tcf.id_tipo_calculo)
				ELSE
					tcf.id_tipo_calculo
			END as id_tipo_calculo,
			ttc.descricao,
			0::integer as excedente,
			CASE 
				WHEN tcf.id_tipo_calculo = v_tipo_combinado THEN 
					COALESCE(v_quantidade_comb,0.00)
				ELSE
					0.00
			END::numeric as quantidade,
			CASE 
				WHEN tcf.id_tipo_calculo = v_tipo_combinado THEN 
					COALESCE(v_valor_item_comb,0.00)
				ELSE
					0.00
			END::numeric as valor_item,
			CASE 
				WHEN tcf.id_tipo_calculo = v_tipo_combinado THEN 
					COALESCE(v_valor_total_comb,0.00)
				ELSE
					0.00
			END::numeric(12,2) as valor_total,
			0.00::numeric(12,2) as valor_minimo,
			CASE 
				WHEN tcf.id_tipo_calculo = v_tipo_combinado THEN 
					COALESCE(v_valor_pagar_comb,0.00)
				ELSE
					0.00
			END::numeric(12,2) as valor_pagar,
			'C'::character(1) as operacao,
			1::integer as id_faixa,
			1::integer as combinado,
			1::integer as modo_calculo,
			0.00::numeric(5,2) as perc_desconto,
			0.00::numeric(12,2) as valor_pagar_sdesconto,
			0.00::numeric(12,2) as desconto
		FROM			
			scr_tabelas_cf tcf
			LEFT JOIN scr_tabelas_origem_destino tod ON tcf.id_origem_destino = tod.id_origem_destino
			LEFT JOIN scr_tabelas t ON t.id_tabela_frete = tod.id_tabela_frete
			LEFT JOIN scr_tabelas_tipo_calculo ttc ON tcf.id_tipo_calculo = ttc.id_tipo_calculo
		WHERE
			numero_tabela_frete = vTabelaFrete
		ORDER BY 
			ttc.id_tipo_calculo;
		
		
		RETURN NEXT cf;
		vRetorno = ('{"codigo":0, "Mensagem":"Frete Calculado"}')::json;	
 		OPEN msg FOR SELECT vRetorno as msg;
 		
		RETURN NEXT msg;
		
	END IF;	

	RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
