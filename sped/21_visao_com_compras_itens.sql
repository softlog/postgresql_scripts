--SELECT * FROM v_com_compras_itens;
CREATE OR REPLACE VIEW v_com_compras_itens AS
WITH t AS (
	SELECT 
		ci.id_compra_item,
		ci.id_compra, 
		ci.codigo_produto, 
		ci.descricao_complementar, 
		ci.quantidade, 
		ci.unidade, 
		ci.vl_item, 
		ci.vl_desconto, 
		ci.movimentacao_fisica, 
		ci.cst_icms, 
		ci.cfop, 
		ci.cod_natureza, 
		ci.vl_base_icms, 
		ci.aliquota_icms, 
		ci.valor_icms, 
		ci.valor_base_icms_st, 
		ci.aliquota_icms_st,
		ci.valor_icms_st, 
		ci.cst_ipi, 
		ci.cod_enq, 
		ci.vl_base_ipi, 
		ci.aliquota_ipi, 
		ci.vl_ipi, 		
		COALESCE(ci.cst_pis,'70') as cst_pis, 
		CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56') 		THEN  
				ci.vl_total
			ELSE
				0.00
		END as vl_base_pis,		
		CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56') 		THEN
				CASE WHEN rt.regime_tributario = 3 THEN 1.65 ELSE 0 END
			ELSE
				0.00
		END::numeric(12,2) as aliquota_pis_perc,
		ci.quantidade_base_pis,
		ci.vl_aliquota_pis,
		CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56')		THEN  
				CASE	WHEN rt.regime_tributario = 3 
					THEN ci.vl_total * 0.0165 
					ELSE ci.vl_total * 0.00
				END
			ELSE
				0.00
		END::numeric(12,2) as valor_pis,
		COALESCE(ci.cst_cofins,'70') as cst_cofins,
		CASE 	WHEN COALESCE(ci.cst_cofins,'70') IN ('50','51','52','53','54','55','56')	THEN  
				ci.vl_total
			ELSE
				0.00
		END as vl_base_cofins,
		CASE 	WHEN COALESCE(ci.cst_cofins,'70') IN ('50','51','52','53','54','55','56') 	THEN  
				CASE  WHEN rt.regime_tributario = 3 THEN 7.6 ELSE 0 END
			ELSE
				0.00
		END::numeric(12,2) as aliquota_cofins_perc,
		ci.quantidade_base_cofins, 
		ci.vl_aliquota_cofins, 
		CASE 	WHEN COALESCE(ci.cst_cofins,'70') IN ('50','51','52','53','54','55','56') 	THEN  
				CASE	WHEN rt.regime_tributario = 3 
					THEN ci.vl_total * 0.076
					ELSE ci.vl_total * 0.00
				END 
			ELSE
				0.00
		END::numeric(12,2) as valor_cofins,
		ci.vl_total,
		ci.observacao,
		ci.id_produto, 
		ci.vl_frete,
		ci.lote_numero,
		ci.lote_data_fabricacao,
		ci.lote_data_validade,
		ci.id_almoxarifado,
		ci.nat_bc_cred,
		ci.ind_orig_cred,
		ci.id_cta
	FROM
		com_compras_itens ci
		LEFT JOIN com_compras c 
			ON ci.id_compra = c.id_compra
		LEFT JOIN v_empresa_regime_tributario rt
			ON rt.codigo_empresa = c.codigo_empresa
				AND c.data_emissao >= rt.inicio AND c.data_emissao < fim
)
,t1 AS (
	SELECT 
		* 
	FROM 
		t 		
)
SELECT * FROM t1 ORDER BY id_compra_item;


--ALTER  VIEW v_com_compras_itens OWNER TO softlog_solar
--SELECT * FROM v_empresa_regime_tributario ORDER BY id_empresa, inicio
