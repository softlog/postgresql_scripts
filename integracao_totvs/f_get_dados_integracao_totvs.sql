/*
-- Function: public.f_get_dados_integracao_totvs(integer, integer)

SELECT id_compra FROM com_compras WHERE numero_compra = '0030020000001';
SELECT id_conhecimento FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010012369'
SELECT * FROM totvs_config
SELECT * FROM f_get_dados_integracao_totvs(14520, 1)
-- DROP FUNCTION public.f_get_dados_integracao_totvs(integer, integer);

SELECT * FROM f_tgg_integracao_softlog_totvs(14520, 1)


*/

CREATE OR REPLACE FUNCTION public.f_get_dados_integracao_totvs(
    p_id_doc integer,
    p_tipo_doc integer)
  RETURNS json AS
$BODY$
DECLARE
	v_doc json;
	v_doc_itens json;
        v_dados json;
        
BEGIN

	
	
	IF p_tipo_doc = 1 THEN 
		WITH produtos_presumido AS (
			SELECT 
				pf.empresa,
				pf.filial,
				COALESCE(pf.valor,'5')::integer as id_produto,
				'07'::character(2) as tipo_item
			FROM  
				com_compras
				LEFT JOIN totvs_parametros_filial pf
					ON com_compras.codigo_empresa = pf.empresa
						AND com_compras.codigo_filial = pf.filial
				LEFT JOIN totvs_config
					ON pf.id_parametro_totvs = totvs_config.id_parametro
			WHERE 
				com_compras.id_compra = p_id_doc 
				AND totvs_config.codigo_controle = 8
			UNION 
			SELECT 
				pf.empresa,
				pf.filial,
				COALESCE(pf.valor,'8')::integer as id_produto,
				'09'::character(2) as tipo_item
			FROM  
				com_compras
				LEFT JOIN totvs_parametros_filial pf
					ON com_compras.codigo_empresa = pf.empresa
						AND com_compras.codigo_filial = pf.filial
				LEFT JOIN totvs_config
					ON pf.id_parametro_totvs = totvs_config.id_parametro
			WHERE 
				com_compras.id_compra = p_id_doc 
				AND totvs_config.codigo_controle = 9	
				
		) 
		, localizacao AS (
		
			SELECT 
				lpad(tpf.valor,2,'0') as cod_loc 
			FROM 
				com_compras
				LEFT JOIN totvs_parametros_filial tpf
					ON tpf.empresa = com_compras.codigo_empresa
						AND tpf.filial = com_compras.codigo_filial
				LEFT JOIN totvs_config tc
					ON tc.id_parametro = tpf.id_parametro_totvs
			 WHERE 
				com_compras.id_compra = p_id_doc
				AND tc.codigo_controle = 10			

		)
		,itens AS (
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json FROM (
					SELECT 
						row_number() over (partition by nfi.id_compra) as num_item,
						p.tipo_item,
						trim(p.descr_item) as fantasia,
						CASE WHEN p.tipo_item = '09' THEN '00000000' ELSE p.codigo_mercosul END as codigo_mercosul,
						nfi.quantidade,
						nfi.vl_item,
						nfi.vl_total as valor_bruto,
						nfi.vl_total - nfi.vl_desconto as valor_liquido,
						nfi.cst_icms,
						nfi.vl_base_icms,
						nfi.aliquota_icms,
						nfi.valor_icms as vl_icms,
						nfi.cst_cofins,
						nfi.valor_base_cofins as vl_base_cofins,
						nfi.vl_aliquota_cofins, 
						nfi.vl_cofins,
						nfi.cst_pis,
						nfi.vl_base_pis,
						nfi.vl_aliquota_pis, 
						nfi.valor_pis as vl_pis,
						trim(tp.totvs_idprd) as id_prd,						
						nfi.vl_desconto as valor_desconto,
						trim(COALESCE(nfi.totvs_cod_tb1_flx, tp.totvs_cod_tb1_flx)) as totvs_cod_tb1_flx,
						trim(COALESCE(nfi.totvs_cod_tb2_flx, tp.totvs_cod_tb2_flx)) as totvs_cod_tb2_flx,						
						trim(COALESCE(nfi.totvs_cod_tb3_flx, tp.totvs_cod_tb3_flx)) as totvs_cod_tb3_flx,
						trim(COALESCE(nfi.totvs_cod_tb4_flx, tp.totvs_cod_tb4_flx)) as totvs_cod_tb4_flx,
						trim(totvs_cfop.codigo_totvs) as cod_id_nat,
						localizacao.cod_loc as totvs_cod_loc	
					FROM
						localizacao,
						com_compras_itens nfi
						LEFT JOIN com_compras nf
							ON nf.id_compra = nfi.id_compra
						LEFT JOIN com_produtos p
							ON p.id_produto = nfi.id_produto
						LEFT JOIN totvs_produtos tp
							ON tp.id_produto = p.id_produto
								AND tp.codigo_empresa = '001'
								AND tp.codigo_filial = '001'
						LEFT JOIN totvs_cfop 
							ON totvs_cfop.cfop = nfi.cfop
								AND totvs_cfop.codigo_empresa = nf.codigo_empresa
								AND totvs_cfop.codigo_filial = nf.codigo_filial
						LEFT JOIN filial
							ON filial.codigo_empresa = nf.codigo_empresa
								AND filial.codigo_filial = nf.codigo_filial						
					WHERE
						--nfi.id_compra = 778
						nfi.id_compra = p_id_doc --778
						AND filial.regime_tributario =3
					UNION 
					SELECT 
						row_number() over (partition by nfi.id_compra) as num_item,
						p2.tipo_item,
						trim(p2.descr_item) as fantasia,
						CASE WHEN p2.tipo_item = '09' THEN '00000000' ELSE p2.codigo_mercosul END as codigo_mercosul,
						SUM(nfi.quantidade) as quantidade,
						SUM(nfi.vl_item) as vl_item,
						SUM(nfi.vl_total) as valor_bruto,
						SUM(nfi.vl_total - nfi.vl_desconto) as valor_liquido,
						MAX(nfi.cst_icms) as cst_icms,
						SUM(nfi.vl_base_icms) as vl_base_icms,
						SUM(nfi.aliquota_icms) as aliquota_icms,
						SUM(nfi.valor_icms) as vl_icms,
						MAX(nfi.cst_cofins) as cst_cofins,
						SUM(nfi.valor_base_cofins) as vl_base_cofins,
						SUM(nfi.vl_aliquota_cofins) as vl_aliquota_cofins, 
						SUM(nfi.vl_cofins) as vl_cofins,
						MAX(nfi.cst_pis) as cst_pis,
						SUM(nfi.vl_base_pis) as vl_base_pis,
						SUM(nfi.vl_aliquota_pis) as vl_aliquota_pis, 
						SUM(nfi.valor_pis) as vl_pis,
						trim(tp.totvs_idprd) as id_prd,						
						SUM(nfi.vl_desconto) as valor_desconto,
						trim(tp.totvs_cod_tb1_flx) as totvs_cod_tb1_flx,
						trim(tp.totvs_cod_tb2_flx) as totvs_cod_tb2_flx,						
						trim(tp.totvs_cod_tb3_flx) as totvs_cod_tb3_flx,
						trim(tp.totvs_cod_tb4_flx) as totvs_cod_tb4_flx,
						trim(totvs_cfop.codigo_totvs) as cod_id_nat,
						localizacao.cod_loc as totvs_cod_loc						
					FROM
						localizacao,
						com_compras_itens nfi						
						LEFT JOIN com_compras nf
							ON nf.id_compra = nfi.id_compra							

						LEFT JOIN com_produtos p
							ON p.id_produto = nfi.id_produto
						LEFT JOIN produtos_presumido pp
							ON p.tipo_item = pp.tipo_item
						LEFT JOIN com_produtos p2
							ON p2.id_produto = pp.id_produto
						LEFT JOIN totvs_produtos tp
							ON tp.id_produto = p2.id_produto
								AND tp.codigo_empresa = '001'
								AND tp.codigo_filial = '001'

						LEFT JOIN totvs_cfop 
							ON totvs_cfop.cfop = nfi.cfop
							AND totvs_cfop.codigo_empresa = nf.codigo_empresa
								AND totvs_cfop.codigo_filial = nf.codigo_filial	
-- 
 						LEFT JOIN filial
 							ON filial.codigo_empresa = nf.codigo_empresa
 								AND filial.codigo_filial = nf.codigo_filial	
					WHERE
						nfi.id_compra = p_id_doc--778
						AND filial.regime_tributario =2
						AND p.tipo_item = pp.tipo_item
					GROUP BY 
						localizacao.cod_loc,
						nfi.id_compra,
						p2.descr_item,
						p2.tipo_item,
						p2.codigo_mercosul,
						tp.totvs_idprd,
						tp.totvs_cod_tb1_flx,
						tp.totvs_cod_tb2_flx,
						tp.totvs_cod_tb3_flx,
						tp.totvs_cod_tb4_flx,
						totvs_cfop.codigo_totvs
						--nfi.id_compra = p_id_doc --778
						--AND filial.regime_tributario IN (1,2)
						--nfi.id_compra =  p_id_doc --540
				) row
			)			
			SELECT array_agg(json) as itens FROM temp
		) 
		, rateios AS (

			WITH temp AS (
				SELECT count(*) as qt_item FROM itens 
			)
			, temp2 AS (
			
				SELECT 		
					1::integer as origem,
					cc.id_compra,
					cc.valor_por_centro_custo as valor,
					COALESCE(trim(v.totvs_centro_custo),'01.02.001') as codigo_centro_custo
				FROM 
					temp,	
					com_compras nf
					LEFT JOIN com_compras_centro_custos cc
						ON cc.id_compra = nf.id_compra
					LEFT JOIN totvs_veiculos v
						ON v.placa_veiculo = cc.placa_veiculo
						AND nf.codigo_empresa = v.codigo_empresa
							AND nf.codigo_filial = v.codigo_filial
					
				WHERE 
					temp.qt_item = 1					
					AND cc.id_compra = p_id_doc--778 --p_id_doc
				UNION ALL
				SELECT 		
					2::integer as origem,
					c.id_compra,
					vl_desconto as valor,
					'01.02.001' as codigo_centro_custo					
				FROM 
					temp,	
					com_compras c						
				WHERE 
					temp.qt_item = 1
					AND c.id_compra = p_id_doc -- 778
					AND vl_desconto > 0 --p_id_doc

				
			)
			,temp4 AS (
				SELECT count(*) as qt_cc FROM temp2 WHERE origem =1
			)
			, temp3 AS (
				SELECT row_to_json(row,true)::json as json FROM (
					SELECT 
						((row_number() over (partition by id_compra)) * -1) as id_seq,
						valor,
						codigo_centro_custo
					FROM 
						temp4,
						temp2
					WHERE temp4.qt_cc > 1
				) row

			)
			SELECT array_agg(json) as rateios FROM temp3		
			
		) 
		,faturas AS (
			WITH t1 AS (
				SELECT
					1::integer as origem,
					((row_number() over (partition by id_compra))*-1) as id_seq,
					data_vencimento,
					valor
				FROM 
					com_compras_faturas fat					
				WHERE 
					fat.id_compra = p_id_doc				
					--fat.id_compra = 719	
					AND data_vencimento IS NOT NULL
				UNION 
				SELECT 
					2::integer as faturas,
					-1::integer as id_seq,
					data_emissao as data_vencimento,
					vl_total as valor
				FROM 
					com_compras
				WHERE 
					com_compras.id_compra = p_id_doc
					--com_compras.id_compra = 719
				ORDER BY 
					origem, 
					data_vencimento				
			),
			t_minimo AS (
				SELECT min(origem) origem_padrao FROM t1
			)
			, temp AS (
				SELECT row_to_json(row,true)::json as json FROM (
					SELECT 
						id_seq,
						data_vencimento,
						valor
					FROM 
						t_minimo
						LEFT JOIN t1 
							ON t1.origem = t_minimo.origem_padrao
				) row
			)
			SELECT array_agg(json) as faturas FROM temp	
			
		)
		,config AS (
			SELECT 	
				nf.id_compra,
				fip.*,
				config.*
			FROM 	com_compras nf
				LEFT JOIN totvs_parametros_filial fip
					ON fip.empresa = nf.codigo_empresa
					AND fip.filial = nf.codigo_filial
				LEFT JOIN totvs_config config
					ON config.id_parametro = fip.id_parametro_totvs
			WHERE 
				nf.id_compra = p_id_doc
					
		), 
		filial_cod_col AS (
			SELECT 	
				id_compra,
				config.valor
			FROM 
				config
			WHERE
				config.codigo_controle = 1
		),
		filial_cod_totvs AS (
			SELECT 
				id_compra,
				config.valor
			FROM 
				config
			WHERE
				config.codigo_controle = 7
		)			
		SELECT row_to_json(row) INTO v_dados FROM (
		--SELECT row_to_json(row) FROM (
			SELECT 			
				com_compras.numero_documento,
				trim(com_compras.serie_doc) as serie_doc,
				1::integer as tipo_movimento,
				id_compra as id_documento,
				data_emissao::timestamp as data_emissao,
				data_entrada::timestamp as data_saida,
				vl_mercadoria as valor_bruto,
				vl_total as valor_liquido,
				vl_frete as valor_frete,
				vl_seguro as valor_seguro,
				vl_desconto as valor_desconto,
				vl_outras_despesas as valor_desp,
				data_emissao::timestamp as data_movimento,
				vl_mercadoria as valor_mercadorias,
				CASE WHEN com_compras.modelo_doc_fiscal IN ('55','00') THEN COALESCE(chave_nfe,'') ELSE trim(com_compras.numero_documento) END as chave,
				vl_iss,	
				CASE 
					WHEN tipo_frete = '0' THEN 1 
					WHEN tipo_frete = '1' THEN 2
					WHEN tipo_frete = '9' THEN 9
					ELSE 0
				END as frete_cif_fob,
				CASE WHEN aguardando_boleto > 0 THEN 1 ELSE 0 END::integer as gerou_fatura,				
				COALESCE(trim(historico),'') as historico_curto,
				CASE WHEN com_compras.modelo_doc_fiscal IN ('99') THEN '1.2.22' ELSE '1.2.04' END::text as cod_tmv,				
				CASE WHEN com_compras.modelo_doc_fiscal IN ('99') THEN '1222' ELSE '1204' END::text as codlote,				
				totvs_cod_tb1_flx,
				trim(totvs_formapagamento.parametro) as totvs_cod_tb2_flx,
				totvs_cod_tb3_flx,
				totvs_cod_tb4_flx,
				trim(fp.valor_parametro) as cod_cfo,
				trim(fp2.valor_parametro) as cod_col_cfo,								
				trim(filial_cod_col.valor) as filial_cod_col,
				trim(filial_cod_totvs.valor) as filial_cod_totvs,	
				trim(totvs_condicoespagamento.parametro) as cod_cpg,	
				'INTEGRACAO'::text as usuario_integracao,
				COALESCE(trim(totvs_veiculos.totvs_centro_custo),'01.02.001') as codigo_centro_custo,
				''::text as tipo_venda,
				CASE 	WHEN com_compras.modelo_doc_fiscal IN ('55') THEN 'NF-e' 
					WHEN com_compras.modelo_doc_fiscal IN ('99') THEN 'REC' 
					ELSE 'NFS-e' 
				END as  codtdo,
				CASE WHEN rateios.rateios IS NOT NULL THEN 1 ELSE 0 END::text as tem_rateio,	
				CASE WHEN com_compras.codigo_empresa = '003' 
					THEN trim(COALESCE(totvs_departamentos.totvs_departamento,'003')) 
					ELSE trim(COALESCE(totvs_departamentos.totvs_departamento,'01'))  
				END::text as codigo_depto,				
				--CASE WHEN com_compras.codigo_empresa = '003' THEN '003' ELSE '01' END::text as codigo_depto,			
				now() as data_integracao,
				itens.itens,
				faturas.faturas,
				rateios.rateios,
				localizacao.cod_loc as totvs_cod_loc
			FROM	
				localizacao,
				itens,
				faturas,
				rateios,
				com_compras
				LEFT JOIN fornecedores f
					ON f.cnpj_cpf = com_compras.cnpj_fornecedor
				LEFT JOIN fornecedor_parametros fp 
					ON fp.id_fornecedor = f.id_fornecedor 
						AND  fp.id_tipo_parametro = 10000	
						--AND fp.codigo_empresa = com_compras.codigo_empresa
						--AND fp.codigo_filial = com_compras.codigo_filial
				LEFT JOIN fornecedor_parametros fp2
					ON fp2.id_fornecedor = f.id_fornecedor
						AND fp2.id_tipo_parametro = 10003
						--AND fp2.codigo_empresa = com_compras.codigo_empresa
						--AND fp2.codigo_filial = com_compras.codigo_filial
				LEFT JOIN totvs_condicoespagamento 
					ON totvs_condicoespagamento.id_condicao_pagamento = com_compras.id_condicao_pagamento	
						AND totvs_condicoespagamento.codigo_empresa = com_compras.codigo_empresa
						AND totvs_condicoespagamento.codigo_filial = com_compras.codigo_filial
				LEFT JOIN totvs_formapagamento
					ON totvs_formapagamento.id_pagamento_softlog = com_compras.id_forma_pagamento
						AND totvs_formapagamento.codigo_empresa = com_compras.codigo_empresa
						AND totvs_formapagamento.codigo_filial = com_compras.codigo_filial
 				LEFT JOIN filial_cod_col USING (id_compra)					
 				LEFT JOIN filial_cod_totvs USING (id_compra)
 				LEFT JOIN totvs_veiculos
					ON totvs_veiculos.placa_veiculo = com_compras.placa_veiculo
						AND totvs_veiculos.codigo_empresa = com_compras.codigo_empresa
						AND totvs_veiculos.codigo_filial = com_compras.codigo_filial
				LEFT JOIN totvs_departamentos 
					ON com_compras.id_departamento = totvs_departamentos.id_departamento
						AND totvs_departamentos.codigo_empresa = com_compras.codigo_empresa
						AND totvs_departamentos.codigo_filial = com_compras.codigo_filial
									
			WHERE 
				--id_compra = 540
				id_compra = p_id_doc --540
			
		) row;
	END IF;

	IF p_tipo_doc = 2 THEN 

		WITH 
		localizacao AS (
		
			SELECT 
				lpad(tpf.valor,2,'0') as cod_loc 
			FROM 
				scr_conhecimento
				LEFT JOIN totvs_parametros_filial tpf
					ON tpf.empresa = scr_conhecimento.empresa_emitente
						AND tpf.filial = scr_conhecimento.filial_emitente
				LEFT JOIN totvs_config tc
					ON tc.id_parametro = tpf.id_parametro_totvs
			 WHERE 
				scr_conhecimento.id_conhecimento = p_id_doc
				AND tc.codigo_controle = 10
		)
		, cte AS (
			SELECT 
				id_conhecimento,
				empresa_emitente,
				filial_emitente,
				tipo_documento,
				serie_doc,
				numero_ctrc_filial,
				remetente_id,
				remetente_cnpj,
				destinatario_id,
				destinatario_cnpj,
				consig_red_id,
				consig_red_cnpj,
				redespachador_id, 
				redespachador_cnpj,
				total_frete,
				c.placa_veiculo,
				data_emissao,
				chave_cte,
				trim(natureza_carga) as natureza_carga,	
				destino.uf as uf_destino,
				trim(destino.cod_ibge) as cod_mun_destino,
				origem.uf as uf_origem,
				trim(origem.cod_ibge) as cod_mun_origem,
				remetente_nome,
				remetente_ie,
				remetente_endereco,
				remetente_bairro,
				destinatario_nome,				
				destinatario_ie,
				destinatario_endereco,
				destinatario_bairro,
				recebedor_cnpj,
				recebedor.codigo_cliente as recebedor_id,
				expedidor_cnpj,
				expedidor.codigo_cliente as expedidor_id,
				trim(totvs_cfop.codigo_totvs) as cod_id_nat,
				CASE WHEN empresa_emitente = '003' THEN '003' ELSE '01' END::text as codigo_depto,	
				coalesce(trim(observacoes_conhecimento),'') as historico_curto,
				CASE WHEN consig_red_id NOT IN (remetente_id,destinatario_id) THEN 0 ELSE frete_cif_fob END::integer as frete_cif_fob,
				COALESCE(trim(totvs_veiculos.totvs_centro_custo),'01.02.001') as codigo_centro_custo,				
				CASE 
					WHEN tipo_transporte IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 22, 23, 24, 25) THEN 0
					WHEN tipo_transporte = 12 THEN 1
					WHEN tipo_transporte = 21 THEN 2
					WHEN tipo_transporte = 20 THEN 3
				END::integer as tipo_cte,
				CASE 
					WHEN tipo_transporte IN (1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,19,20,21,22,23,24,25) THEN 0
					WHEN tipo_transporte = 18 THEN 1
					WHEN tipo_transporte = 19 THEN 3					
				END::integer as tipo_servico_cte,
				CASE 
					WHEN consig_red_cnpj NOT IN (remetente_cnpj, destinatario_cnpj) THEN 4
					WHEN frete_cif_fob = 1 THEN 0
					WHEN frete_cif_fob = 2 THEN 3
				END::text as tomador_tipo,
				c.id_motorista,
				COALESCE(trim(fpm.valor_parametro),'') as codigo_motorista
			FROM
				scr_conhecimento c
				LEFT JOIN cidades origem
					ON origem.id_cidade = c.calculado_de_id_cidade
				LEFT JOIN cidades destino
					ON destino.id_cidade = c.calculado_ate_id_cidade
				LEFT JOIN cliente recebedor
					ON recebedor.cnpj_cpf = recebedor_cnpj
				LEFT JOIN cliente expedidor
					ON expedidor.cnpj_cpf = expedidor_cnpj
				LEFT JOIN totvs_cfop 
					ON totvs_cfop.cfop = c.cod_operacao_fiscal 
						AND totvs_cfop.codigo_empresa = c.empresa_emitente
						AND totvs_cfop.codigo_filial = c.filial_emitente
				LEFT JOIN totvs_veiculos
					ON totvs_veiculos.placa_veiculo = c.placa_veiculo
					AND c.empresa_emitente = totvs_veiculos.codigo_empresa
					AND c.filial_emitente = totvs_veiculos.codigo_filial
				LEFT JOIN fornecedor_parametros fpm
					ON fpm.id_fornecedor = c.id_motorista 
						AND id_tipo_parametro = 10002
						AND fpm.codigo_empresa = c.empresa_emitente
						AND fpm.codigo_filial = c.filial_emitente
						
			WHERE 
				--c.id_conhecimento = 1483
				c.id_conhecimento = p_id_doc --1483
		),		
		nfes AS (
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json FROM (
					SELECT 
						(row_number() over (partition by nf.id_conhecimento))*-1 as id_mov,
						row_number() over (partition by nf.id_conhecimento) as num_item,
						cte.id_conhecimento,
						nf.data_nota_fiscal as data_emissao,
						nf.serie_nota_fiscal as serie_nf,
						nf.numero_nota_fiscal as numero_nfe,
						nf.valor as valor_mercadorias,
						natureza_carga,
						nf.chave_nfe				
					FROM
						cte
						LEFT JOIN scr_conhecimento_notas_fiscais nf
							ON nf.id_conhecimento = cte.id_conhecimento
				) row
			)
			SELECT array_agg(json) as nfes FROM temp					
		),
		faturas AS (
			WITH temp AS (
				SELECT row_to_json(row,true)::json as json FROM (
					SELECT 
						-1::integer as id_seq,
						data_vencimento(cte.data_emissao::date, p2.frequencia_faturamento, 'Q',COALESCE(p2.prazo_pagamento::integer,15)) as data_vencimento,
						cte.total_frete as valor
					FROM 
						cte
						LEFT JOIN cliente p
							ON cte.consig_red_id = p.codigo_cliente
						LEFT JOIN cliente p2
							ON p2.cnpj_cpf = p.cnpj_cpf_responsavel
				) row
			)
			SELECT array_agg(json) as faturas FROM temp	
			
		)
		,remetente AS (
			WITH temp AS (
			SELECT 				
				cte.remetente_id as codigo_cliente,
				trim(valor_parametro) as cod_cfo,
				null::text as cod_col_cfo
			FROM
				cte
				LEFT JOIN cliente_parametros cp
					ON cp.codigo_cliente = remetente_id
					AND id_tipo_parametro = 10000				
					--AND cp.codigo_empresa = cte.empresa_emitente
					--AND cp.codigo_filial = cte.filial_emitente
			UNION 
			SELECT 				
				cte.remetente_id as codigo_cliente,
				null::text as cod_cfo,
				trim(valor_parametro) as cod_col_cfo
			FROM
				cte
				LEFT JOIN cliente_parametros cp
					ON cp.codigo_cliente = remetente_id
					AND id_tipo_parametro = 10003
					--AND cp.codigo_empresa = cte.empresa_emitente
					--AND cp.codigo_filial = cte.filial_emitente
			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente
				
		),
		destinatario AS (
			WITH temp AS (
				SELECT 				
					cte.destinatario_id as codigo_cliente,
					trim(valor_parametro) as cod_cfo,
					null::text as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = destinatario_id
						AND id_tipo_parametro = 10000	
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente			
				UNION 
				SELECT 				
					cte.destinatario_id as codigo_cliente,
					null::text as cod_cfo,
					trim(valor_parametro) as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = destinatario_id
						AND id_tipo_parametro = 10003	
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente			

			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente
				
		),		
		pagador AS (
			WITH temp AS (
				SELECT 				
					cte.consig_red_id as codigo_cliente,
					trim(valor_parametro) as cod_cfo,
					null::text as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = consig_red_id
						AND id_tipo_parametro = 10000
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente
				UNION
				SELECT 				
					cte.consig_red_id as codigo_cliente,
					null::text as cod_cfo,
					trim(valor_parametro) as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = consig_red_id
						AND id_tipo_parametro = 10003	
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente		
				
			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente
				
		),
		redespachador AS (
			WITH temp AS (
				SELECT 
					cte.redespachador_id as codigo_cliente,
					trim(valor_parametro) as cod_cfo,
					null::text as cod_col_cfo					
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = redespachador_id
						AND id_tipo_parametro = 10000	
						AND cp.codigo_empresa = cte.empresa_emitente
						AND cp.codigo_filial = cte.filial_emitente			
				UNION 
				SELECT 
					cte.redespachador_id as codigo_cliente,
					null::text as cod_cfo,
					trim(valor_parametro) as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = redespachador_id
						AND id_tipo_parametro = 10003
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente			
					
			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente
				
		),
		recebedor AS (
			WITH temp AS (
				SELECT 				
					cte.recebedor_id as codigo_cliente,
					trim(valor_parametro) as cod_cfo,
					null::text as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = recebedor_id
						AND id_tipo_parametro = 10000	
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente						
				UNION
				SELECT 				
					cte.recebedor_id as codigo_cliente,
					null::text as cod_cfo,
					trim(valor_parametro) as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = recebedor_id
						AND id_tipo_parametro = 10003
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente			
				
			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente
		),
		expedidor AS (
			WITH temp as (
				SELECT
					cte.expedidor_id as codigo_cliente,
					trim(valor_parametro) as cod_cfo,
					null::text as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = expedidor_id
						AND id_tipo_parametro = 10000
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente			
				UNION 
				SELECT
					cte.expedidor_id as codigo_cliente,
					null::text as cod_cfo,
					trim(valor_parametro) as cod_col_cfo
				FROM
					cte
					LEFT JOIN cliente_parametros cp
						ON cp.codigo_cliente = expedidor_id
						AND id_tipo_parametro = 10003	
						--AND cp.codigo_empresa = cte.empresa_emitente
						--AND cp.codigo_filial = cte.filial_emitente						
			)
			SELECT codigo_cliente, max(cod_cfo) as cod_cfo, max(cod_col_cfo) as cod_col_cfo FROM temp GROUP BY codigo_cliente				
		),
		tpf AS (
			WITH temp AS (
			
				SELECT 
					tpf.id_parametro_totvs,
					tpf.valor,
					CASE WHEN tc.codigo_controle = 1 THEN trim(valor) ELSE '' END as filial_cod_col,
					CASE WHEN tc.codigo_controle = 7 THEN trim(valor) ELSE '' END as filial_cod_totvs,
					CASE WHEN tc.codigo_controle = 2 THEN trim(valor) ELSE '' END as totvs_cod_tb1_flx,
					CASE WHEN tc.codigo_controle = 3 THEN trim(valor) ELSE '' END as totvs_cod_tb2_flx,
					CASE WHEN tc.codigo_controle = 4 THEN trim(valor) ELSE '' END as totvs_cod_tb3_flx,
					CASE WHEN tc.codigo_controle = 5 THEN trim(valor) ELSE '' END as totvs_cod_tb4_flx,					
					CASE WHEN tc.codigo_controle = 6 THEN valor::text::integer ELSE null END::integer as id_produto
				FROM 
					cte c
					LEFT JOIN totvs_parametros_filial tpf
						ON tpf.empresa =  c.empresa_emitente AND tpf.filial = c.filial_emitente
					LEFT JOIN totvs_config tc
						ON tc.id_parametro = tpf.id_parametro_totvs			
			)
			SELECT 
				MAX(filial_cod_col) as filial_cod_col,
				MAX(filial_cod_totvs) as filial_cod_totvs,
				MAX(totvs_cod_tb1_flx) as totvs_cod_tb1_flx,
				MAX(totvs_cod_tb2_flx) as totvs_cod_tb2_flx,
				MAX(totvs_cod_tb3_flx) as totvs_cod_tb3_flx,
				MAX(totvs_cod_tb4_flx) as totvs_cod_tb4_flx,
				MAX(id_produto)::integer as id_produto
			FROM temp
		),
		itens AS (
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json FROM (
					SELECT 
						1 num_item,
						trim(p.descr_item) as fantasia,
						p.codigo_mercosul,
						1::integer as quantidade,
						cte.total_frete as vl_item,
						cte.total_frete as valor_bruto,
						''::text as cst_icms,
						0.00::numeric(12,2) as vl_base_icms,
						0.00::numeric(12,2) as aliquota_icms,
						0.00::numeric(12,2) as vl_icms,
						0.00::numeric(12,2) as cst_cofins,
						0.00::numeric(12,2) as vl_base_cofins,
						0.00::numeric(12,2) as vl_aliquota_cofins, 
						0.00::numeric(12,2) as vl_cofins,
						0.00::numeric(12,2) as cst_pis,
						0.00::numeric(12,2) as vl_base_pis,
						0.00::numeric(12,2) as vl_aliquota_pis, 
						0.00::numeric(12,2) as vl_pis,
						trim(tp.totvs_idprd) as id_prd,
						0.00::numeric(12,2) as valor_desconto,
						tp.totvs_idnat,
						trim(tp.totvs_cod_tb1_flx) as totvs_cod_tb1_flx,
						trim(tp.totvs_cod_tb2_flx) as totvs_cod_tb2_flx,		
						trim(tp.totvs_cod_tb3_flx) as totvs_cod_tb3_flx,
						trim(tp.totvs_cod_tb4_flx) as totvs_cod_tb4_flx,
						localizacao.cod_loc as totvs_cod_loc,
						cte.cod_id_nat,
						cte.codigo_depto,
						cte.frete_cif_fob, 
						cte.historico_curto,
						0::integer as tem_rateio,
						p.id_produto
					FROM
						localizacao,
						cte,
						tpf,					
						com_produtos p
						LEFT JOIN totvs_produtos tp
							ON tp.id_produto = p.id_produto
								AND tp.codigo_empresa = '001'
								AND tp.codigo_filial = '001'
								
					WHERE
						p.id_produto = tpf.id_produto							
						--AND tp.codigo_empresa = cte.empresa_emitente
						--AND tp.codigo_filial = cte.filial_emitente
					
				) row
			)
			SELECT array_agg(json) as itens FROM temp
		) 
		SELECT row_to_json(row) INTO v_dados FROM (
			SELECT 
				RIGHT(cte.numero_ctrc_filial,7) as numero_documento,
				trim(cte.serie_doc) as serie_doc,
				2::integer as tipo_movimento,
				cte.id_conhecimento as id_documento,
				cte.data_emissao as data_emissao,
				cte.data_emissao as data_saida,
				cte.total_frete as valor_bruto,
				cte.total_frete as valor_liquido,
				0.00::numeric(12,2) as valor_frete,
				0.00::numeric(12,2) asvalor_seguro,
				0.00::numeric(12,2) as valor_desconto,
				0.00::numeric(12,2) as valor_desp,
				0.00::numeric(12,2) as valor_desconto,
				cte.data_emissao::timestamp as data_movimento,
				cte.total_frete as valor_mercadorias,
				chave_cte as chave,
				0.00::numeric(12,2) as vl_iss,	
				0::integer as tipo_frete,				
				'NF-e'::text as codtdo,
				('CTE: ' || chave_cte)::text as historico_curto,
				'2.2.56' as codtmv,
				'CT-e' as  codtdo,
				tpf.filial_cod_col,
				tpf.filial_cod_totvs,
				trim(tpf.totvs_cod_tb1_flx) as totvs_cod_tb1_flx,
				trim(tpf.totvs_cod_tb2_flx) as totvs_cod_tb2_flx,
				trim(tpf.totvs_cod_tb3_flx) as totvs_cod_tb3_flx,
				trim(tpf.totvs_cod_tb4_flx) as totvs_cod_tb4_flx ,				
				trim(pagador.cod_cfo) as cod_cfo,
				trim(pagador.cod_col_cfo) as cod_col_cfo,
				codigo_centro_custo,
				'2.2.56' as cod_tmv,
				''::text as cod_cpg,
				uf_origem,
				cod_mun_origem,
				uf_destino,				
				cod_mun_destino,
				cod_id_nat,
				remetente.cod_cfo as remetente_cfo,		
				remetente.cod_col_cfo as remetente_col_cfo,
				destinatario.cod_cfo as destinatario_cfo,
				destinatario.cod_col_cfo as destinatario_col_cfo,
				trim(cte.remetente_nome) as nome_razao_coleta,				
				CASE WHEN LEFT(cte.remetente_cnpj,3) = 'EXP' THEN '00000000000000' ELSE trim(cte.remetente_cnpj) END as cnpj_coleta,
				trim(cte.remetente_ie) as ie_coleta,
				trim(cte.remetente_endereco) as end_coleta,
				trim(cte.remetente_bairro) as bairro_coleta,
				trim(cte.destinatario_nome) as nome_razao_entrega,
				CASE WHEN LEFT(cte.destinatario_cnpj,3) = 'EXP' THEN '00000000000000' ELSE trim(cte.destinatario_cnpj) END as cnpj_entrega,
				trim(cte.destinatario_ie) as ie_entrega,
				trim(cte.destinatario_endereco) as end_entrega,
				''::text as complemento_entrega,
				trim(cte.destinatario_bairro) as bairro_entrega,
				trim(COALESCE(expedidor.cod_cfo,'')) as expedidor_cfo,
				trim(COALESCE(expedidor.cod_col_cfo,'')) as expedidor_col_cfo,
				trim(COALESCE(recebedor.cod_cfo,'')) as recebedor_cfo,
				trim(COALESCE(recebedor.cod_col_cfo,'')) as recebedor_col_cfo,				
				'INTEGRACAO' as usuario_integracao,
				tipo_cte,
				tipo_servico_cte,
				tomador_tipo,
				CASE 
					WHEN trim(natureza_carga) = 'INFLAMAVEIS/SAFRA' THEN '001'
					WHEN trim(natureza_carga) = 'INFLAMAVEIS/TRANSPORTES' THEN '002'
					WHEN trim(natureza_carga) = 'INFLAMAVEIS/SERVICOS BR' THEN '005'
					WHEN trim(natureza_carga) = 'QUIMICOS EM GERAL' THEN '002'
					ELSE '002'
				END::CHARACTER(3) AS tipo_venda,
				cte.frete_cif_fob,
				cte.natureza_carga,
				now() as data_integracao,				
				cte.codigo_motorista,
				localizacao.cod_loc as totvs_cod_loc,
				itens.itens,				
				nfes.nfes,
				faturas.faturas
			FROM
				localizacao,
				pagador,
				remetente,
				destinatario,
				redespachador,
				recebedor,
				expedidor,
				faturas,
				itens,	
				tpf,			
				cte,
				nfes
		) row;
	

	END IF ;

	IF p_tipo_doc = 3 THEN


		
		SELECT row_to_json(row) INTO v_dados FROM (
		--SELECT row_to_json(row) FROM (
			SELECT 
				trim(com_produtos.descr_item) as descricao_produto,
				COALESCE(left(codigo_mercosul,2) || '.' || substr(codigo_mercosul,3,3) || '.' || right(codigo_mercosul,3),'') as ncm,
				id_produto as codigo_produto,
				CASE WHEN tipo_item = '09' THEN 'S' ELSE 'P' END::character(1) as tipo_produto,
				lpad(id_produto::text,4,'0') as codigo_produto_2
			FROM	
				com_produtos
			WHERE 
				--id_produto = 602
				id_produto = p_id_doc
		) row;		

	END IF;


        
	RETURN v_dados;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_get_dados_integracao_totvs(integer, integer)
  OWNER TO softlog_aeroprest;
