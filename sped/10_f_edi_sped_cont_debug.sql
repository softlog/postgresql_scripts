-- Function: public.f_edi_sped_cont(date, date, text, text, json)

-- DROP FUNCTION public.f_edi_sped_cont(date, date, text, text, json);

CREATE OR REPLACE FUNCTION public.f_edi_sped_cont(
    p_inicio date,
    p_fim date,
    p_empresa text,
    p_cod_fin text,
    blocos json)
  RETURNS json AS
$BODY$
DECLARE
	v_dados json;
BEGIN
	--EXPLAIN ANALYSE	
	WITH 
	/*
 	sped_cont AS (
		SELECT 
			p_inicio as inicio,
			p_fim as fim,
			f_edi_sped_versao(p_inicio, 'EFD-PIS-COFINS') as versao,
			p_cod_fin as cod_fin,
			p_empresa as cod_empresa			
							
	),
	*/
 	sped_cont AS (
 		SELECT 
			'2020-02-01'::date as inicio,
			'2020-02-29'::date as fim,
 			f_edi_sped_versao('2020-02-01'::date, 'EFD-PIS-COFINS') as versao,
			'0'::text as cod_fin,
 			'001'::text as cod_empresa
 	),	
	-------------------------------------------------------------------------------------------------
	--- Coleta e Processamento dos Dados do SPED                                                   --
	-------------------------------------------------------------------------------------------------	
	-- Dados da Matriz
	e AS (
		SELECT 	
			user as user_db, 
			inicio,
			fim,				
			empresa.codigo_empresa,
			trim(empresa.cnpj) as cnpj, 				
			trim(empresa.razao_social) as razao_social, 	
			trim(cidades.nome_cidade) as nome_cidade, 	
			trim(cidades.uf) as uf, 	
			COALESCE(trim(cidades.cod_ibge)) as cod_ibge,
			COALESCE(trim(filial.suframa)) as suframa,			 	
			filial.id_contador,
			'1'::text as cod_inc_trib,
			'1'::text as ind_apro_cred,
			'1'::text as cod_tipo_cont,
			''::text as ind_reg_cum
		FROM 			
			sped_cont,
			empresa	
			LEFT JOIN cidades  
				ON empresa.cidade 	= cidades.id_cidade
			LEFT JOIN filial ON filial.cnpj = empresa.cnpj
		WHERE
			empresa.codigo_empresa = sped_cont.cod_empresa
	),
	--Dados da Filial
	f AS (
		SELECT 	
			user as user_db, 
			inicio,
			fim,	
			filial.codigo_filial,
			filial.codigo_empresa,
			trim(filial.cnpj) as cnpj, 	
			COALESCE(trim(filial.inscricao_estadual),'') as inscricao_estadual, 	
			trim(filial.razao_social) as razao_social, 	
			trim(cidades.nome_cidade) as nome_cidade, 	
			trim(cidades.uf) as uf, 	
			COALESCE(trim(cidades.cod_ibge)) as cod_ibge, 					
			COALESCE(filial.estado,'') as estado, 	
			COALESCE(trim(filial.ddd),'') as ddd, 	
			COALESCE(trim(filial.fax),'') as fax, 	
			COALESCE(trim(filial.telefone),'') as telefone, 	
			COALESCE(trim(filial.endereco),'') as endereco, 	
			COALESCE(trim(filial.nome_descritivo),'') as nome_descritivo, 	
			COALESCE(trim(filial.email_principal),'') as email_principal, 	
			COALESCE(rpad(regexp_replace(trim(filial.numero),'[^0-9]','','g'),5,'0'),'')  as numero, 	
			COALESCE(trim(filial.bairro),'') as bairro, 	
			regexp_replace(trim(filial.cep),'[^0-9]','','g')::character(8) as cep, 	
			filial.flg_item_1400_sped_fiscal, 	
			filial.cod_item_1400_sped_fiscal,
			COALESCE(filial.suframa,'')::text as suframa
		FROM 				
			e
			LEFT JOIN filial	
				ON filial.codigo_empresa = e.codigo_empresa
			LEFT JOIN cidades  
				ON filial.id_cidade = cidades.id_cidade 
	)
	--Definição de Aliquotas - SIGLA 'i'
	,i AS (
		SELECT 
			CASE  	WHEN
					e.cod_inc_trib = '1' 
				THEN  
					1.65
				ELSE
					0.65
			END::numeric(5,2) as aliq_pis,
			CASE  	WHEN
					e.cod_inc_trib = '1' 
				THEN  
					7.6
				ELSE
					3
			END::numeric(5,2) as aliq_cofins
		FROM 
			e
	)
	,contador AS (
		SELECT 	
			fornecedores.nome_razao, 	
			fornecedores.cnpj_cpf, 	
			COALESCE(fornecedores.conselho_regional,'') as conselho_regional, 	
			COALESCE(fornecedores.cep,'') as cep, 	
			COALESCE(fornecedores.endereco,'') as endereco, 	
			COALESCE(fornecedores.numero,'') as numero, 	
			COALESCE(fornecedores.bairro,'') as bairro, 	
			COALESCE(fornecedores.ddd,'') as ddd, 	
			COALESCE(fornecedores.telefone1,'') as telefone, 	
			COALESCE(fornecedores.fax,'') as fax, 	
			COALESCE(fornecedores.email,'') as email, 	
			cidades.cod_ibge 
		FROM 	
			e
			LEFT JOIN fornecedores  ON e.id_contador = fornecedores.id_fornecedor
			LEFT JOIN cidades 	ON fornecedores.id_cidade = cidades.id_cidade 					
	)
	--Itens dos serviços - SIGLA 'si'
	,si AS (
		SELECT 
			si.id_compra_item, 
			si.id_compra,			
			si.id_produto as codigo_produto,
			COALESCE(si.descricao_complementar,'') as descricao_complementar,
			si.quantidade, 
			COALESCE(efd_unidades_medida.unidade, si.unidade,'UN') as unidade, 
			COALESCE(si.vl_item,0.00) as vl_item, 
			COALESCE(si.vl_desconto,0.00) as vl_desconto, 
			si.movimentacao_fisica, 
			COALESCE(si.cst_icms,'') as cst_icms, 
			COALESCE(si.cfop,'') as cfop,
			COALESCE(si.cod_natureza, '') as cod_natureza,
			COALESCE(si.nat_bc_cred,'') as nat_bc_cred,
			COALESCE(si.ind_orig_cred::text,'')::text as ind_orig_cred,			
			COALESCE(si.cst_pis,'70') as cst_pis,
			vl_base_pis,
			aliquota_pis_perc,
			COALESCE(si.quantidade_base_pis,0) as quantidade_base_pis, 
			COALESCE(si.vl_aliquota_pis, 0.00) as vl_aliquota_pis, 
			valor_pis as vl_pis,						
			COALESCE(si.cst_cofins,'70') as cst_cofins, 			
			vl_base_cofins as valor_base_cofins,			
			aliquota_cofins_perc,						
			COALESCE(si.quantidade_base_cofins,0) as quantidade_base_cofins,			
			COALESCE(si.vl_aliquota_cofins,0.00) as vl_aliquota_cofins, 			
			valor_cofins as vl_cofins,
			COALESCE(si.vl_total,0.00) as vl_total, 
			COALESCE(si.observacao,'') as observacao, 
			si.id_produto
		FROM 
			sped_cont,
			com_compras s
			LEFT JOIN v_com_compras_itens si
				ON s.id_compra = si.id_compra
			LEFT JOIN com_produtos 
				ON si.id_produto = com_produtos.id_produto 
			LEFT JOIN efd_unidades_medida 
				ON com_produtos.id_unidade  = efd_unidades_medida.id_unidade 
		WHERE			
			data_entrada >= sped_cont.inicio
			AND data_entrada <= sped_cont.fim
			AND numero_compra IS NOT NULL 
			AND modelo_doc_fiscal IN ('00') 
			AND s.codigo_empresa = sped_cont.cod_empresa
		ORDER BY 
			id_compra, 
			id_compra_item
	) 
	--PIS e COFINS dos Serviços
	,s_cred as (
		SELECT 
			id_compra,
			SUM(vl_pis)::numeric(12,2) as vl_pis,
			SUM(vl_base_pis)::numeric(12,2) as vl_bc_pis,
			SUM(vl_cofins)::numeric(12,2) as vl_cofins,
			SUM(valor_base_cofins)::numeric(12,2) as vl_bc_cofins
		FROM 
			si
		GROUP BY 
			id_compra
	)
	--Dados de Serviços - SIGLA 's'
	,s as (
		SELECT 			
			com_compras.id_compra, 						 
			f.cnpj,
			'0'::character(1) as ind_oper,
			'1'::character(1) as ind_emit,
			fornecedores.id_fornecedor as codigo_participante, 
			com_compras.numero_compra,
			com_compras.status, 
			com_compras.codigo_empresa, 
			com_compras.codigo_filial, 
			com_compras.cnpj_fornecedor, 			
			com_compras.tipo_documento, 
			com_compras.modelo_doc_fiscal, 
			coalesce(trim(com_compras.serie_doc),'') as serie_doc, 
			COALESCE(trim(com_compras.sub_serie),'') AS sub_serie,
			trim(com_compras.numero_documento) as numero_documento, 
			COALESCE(com_compras.chave_nfe,'') as chave_nfse, 
			to_char(com_compras.data_emissao,'DDMMYYYY') as data_emissao, 
			to_char(com_compras.data_entrada,'DDMMYYYY') as data_entrada, 
			com_compras.data_cancelamento, 
			com_compras.motivo_cancelamento, 
			COALESCE(com_compras.tipo_pagamento,'') AS tipo_pagamento, 
			COALESCE(com_compras.vl_servico,0.00) as vl_servico,
			COALESCE(com_compras.vl_desconto,0.00) AS vl_desconto, 
			COALESCE(com_compras.vl_abatimento_nt,0.00) AS vl_abatimento_nt, 						
			COALESCE(com_compras.vl_outras_despesas,0.00) AS vl_outras_despesas, 
			COALESCE(com_compras.vl_base_calculo,0.00) as vl_base_calculo, 
			COALESCE(s_cred.vl_bc_pis,0.00) as vl_bc_pis, 
			COALESCE(s_cred.vl_pis,0.00) as vl_pis, 
			COALESCE(s_cred.vl_bc_cofins,0.00) as vl_bc_cofins, 
			COALESCE(s_cred.vl_cofins,0.00) as vl_confins, 
			COALESCE(com_compras.vl_pis_ret,0.00) as vl_pis_ret, 
			COALESCE(com_compras.vl_cofins_ret,0.00) as vl_cofins_ret, 
			COALESCE(com_compras.vl_total,0.00) as vl_total, 
			COALESCE(com_compras.vl_iss,0.00) as vl_iss			
		FROM
			sped_cont,
			s_cred			
			LEFT JOIN com_compras 
				ON s_cred.id_compra = com_compras.id_compra
			RIGHT JOIN f
				ON com_compras.codigo_filial = f.codigo_filial
				AND com_compras.codigo_empresa = f.codigo_empresa				
			LEFT JOIN fornecedores 
				ON com_compras.cnpj_fornecedor = fornecedores.cnpj_cpf 
		WHERE
			com_compras.codigo_empresa = sped_cont.cod_empresa
		ORDER BY 
			numero_compra
	) 
	-------------------------------------------------------------------------------------------------
	--- Dados dos Itens de Compra - SIGLA 'compras_itens'                                          --
	-------------------------------------------------------------------------------------------------
	,compras_itens AS (
		SELECT 
			ci.id_compra_item,
			c.modelo_doc_fiscal,			
			c.numero_compra,
			c.chave_nfe,
			ci.id_compra, 
			ci.codigo_produto, 
			ci.descricao_complementar, 
			ci.quantidade, 
			COALESCE(efd_unidades_medida.unidade, ci.unidade,'UN') as unidade, 
			COALESCE(ci.vl_item,0.00) as vl_item, 
			COALESCE(ci.vl_desconto,0.00) as vl_desconto, 
			ci.movimentacao_fisica, 
			COALESCE(ci.cst_icms,'') as cst_icms, 			
			COALESCE(ci.cod_natureza, '') as cod_natureza, 
			COALESCE(ci.vl_base_icms,0.00) as vl_base_icms, 
			COALESCE(ci.aliquota_icms,0.00) as aliquota_icms, 
			COALESCE(ci.valor_icms,0.00) as valor_icms, 
			COALESCE(ci.valor_base_icms_st,0.00) as valor_base_icms_st, 
			COALESCE(ci.aliquota_icms_st,0.00) as aliquota_icms_st, 
			COALESCE(ci.valor_icms_st,0.00) as valor_icms_st, 
			COALESCE('','') as cst_ipi,
			COALESCE(ci.cod_enq,'') as cod_enq, 
			COALESCE(ci.vl_base_ipi,0.00) as vl_base_ipi, 
			COALESCE(ci.aliquota_ipi,0.00) as aliquota_ipi, 
			COALESCE(ci.vl_ipi,0.00) as vl_ipi, 
			com_produtos.descr_item,
			COALESCE(ci.cfop,'') as cfop, 
			com_produtos.cst_pis as cst_pis_produto,
			COALESCE(ci.cst_pis,'70') as cst_pis, 			
			CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56') 		THEN  
					ci.vl_total
				ELSE
					0.00
			END as vl_base_pis,
			CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56') 		THEN  
					1.65
				ELSE
					0.00
			END::numeric(12,2) as aliquota_pis_perc,	
			COALESCE(ci.quantidade_base_pis,0) as quantidade_base_pis, 
			COALESCE(ci.vl_aliquota_pis, 0.00) as vl_aliquota_pis, 
			valor_pis,						
			COALESCE(ci.cst_cofins,'70') as cst_cofins, 
			vl_base_cofins,
			aliquota_cofins_perc,			
			COALESCE(ci.quantidade_base_cofins,0) as quantidade_base_cofins,
			COALESCE(ci.vl_aliquota_cofins,0.00) as vl_aliquota_cofins,
			valor_cofins,
			COALESCE(ci.vl_total,0.00) as vl_total, 
			COALESCE(ci.observacao,'') as observacao, 
			ci.id_produto,
			CASE 	WHEN COALESCE(ci.cst_pis,'70') IN ('50','51','52','53','54','55','56') 		THEN  
					1
				ELSE
					0
			END as  credito_pis,
			CASE 	WHEN COALESCE(ci.cst_cofins,'70') IN ('50','51','52','53','54','55','56') 	THEN  
					1
				ELSE
					0
			END as  credito_cofins			
		FROM 		
			sped_cont,
			f			
			LEFT JOIN com_compras c
				ON c.codigo_filial = f.codigo_filial 
					AND c.codigo_empresa = f.codigo_empresa				
			LEFT JOIN v_com_compras_itens ci
				ON c.id_compra = ci.id_compra
			LEFT JOIN com_produtos 
				ON ci.id_produto = com_produtos.id_produto 
			LEFT JOIN efd_unidades_medida 
				ON com_produtos.id_unidade  = efd_unidades_medida.id_unidade			
		WHERE
			c.data_entrada >= sped_cont.inicio
			AND c.data_entrada <= sped_cont.fim
			AND numero_compra IS NOT NULL
			--AND modelo_doc_fiscal NOT IN ('00','06','10', '07', '57', '21','22','28','29')
			AND modelo_doc_fiscal NOT IN ('00','10', '07', '57')
			AND c.codigo_empresa = sped_cont.cod_empresa
		ORDER BY 
			id_compra, 
			id_compra_item
	) 
	SELECT * FROM compras_itens
	-------------------------------------------------------------------------------------------------
	--- NFes que dão direito a crédito - Sigla 'nfes_cred'                                         --
	-------------------------------------------------------------------------------------------------
	,nfes_cred AS (
		SELECT 
			id_compra,
			SUM(valor_pis) 		as valor_pis,
			SUM(valor_cofins)	as valor_cofins
		FROM 
			compras_itens 
		WHERE 
			1 IN (compras_itens.credito_pis, compras_itens.credito_cofins)		
			AND modelo_doc_fiscal NOT IN ('00','06','10', '07', '57', '21','22','28','29')	
		GROUP BY
			id_compra
		ORDER BY
			id_compra
	)		
	-------------------------------------------------------------------------------------------------
	--- Contas de consumo que dão direito a crédito - Sigla 'nfes_cred'                            --
	-------------------------------------------------------------------------------------------------
	,contas_cred AS (
		SELECT 
			id_compra,
			SUM(valor_pis) 		as valor_pis,
			SUM(valor_cofins)	as valor_cofins
		FROM 
			compras_itens
		WHERE 
			1 IN (compras_itens.credito_pis, compras_itens.credito_cofins)		
			AND modelo_doc_fiscal IN ('06','28','29')	
		GROUP BY
			id_compra
		ORDER BY
			id_compra
	)
	-------------------------------------------------------------------------------------------------
	--- Contas de telefone que dão direito a crédito - Sigla 'telefone_cred'                       --
	-------------------------------------------------------------------------------------------------
	,telefone_cred AS (
		SELECT 
			id_compra,
			SUM(valor_pis) 		as valor_pis,
			SUM(valor_cofins)	as valor_cofins
		FROM 
			compras_itens
		WHERE 
			1 IN (compras_itens.credito_pis, compras_itens.credito_cofins)		
			AND modelo_doc_fiscal IN ('21','22')	
		GROUP BY
			id_compra
		ORDER BY
			id_compra
	)		
	-------------------------------------------------------------------------------------------------
	--- Dados das Compras - SIGLA 'compras'                                                        --
	-------------------------------------------------------------------------------------------------	
	,compras as (
		SELECT 			
			com_compras.id_compra, 
			f.cnpj,
			com_compras.numero_compra, 
			com_compras.id_centro_custo, 
			com_compras.status, 
			com_compras.codigo_empresa, 
			com_compras.codigo_filial, 
			com_compras.cnpj_fornecedor, 
			fornecedores.id_fornecedor as codigo_participante, 
			com_compras.tipo_documento, 
			com_compras.modelo_doc_fiscal, 
			coalesce(trim(com_compras.serie_doc),'') as serie_doc, 
			trim(com_compras.numero_documento) as numero_documento, 
			COALESCE(com_compras.chave_nfe,'') as chave_nfe, 
			to_char(com_compras.data_emissao, 'DDMMYYYY') as data_emissao, 
			to_char(com_compras.data_entrada, 'DDMMYYYY') as data_entrada, 
			com_compras.data_cancelamento, 
			com_compras.motivo_cancelamento, 
			COALESCE(com_compras.tipo_pagamento,'') AS tipo_pagamento, 
			COALESCE(com_compras.vl_desconto,0.00) AS vl_desconto, 
			COALESCE(com_compras.vl_abatimento_nt,0.00) AS vl_abatimento_nt, 
			COALESCE(com_compras.vl_mercadoria,0.00) AS vl_mercadoria, 
			COALESCE(com_compras.tipo_frete,'') AS tipo_frete, 
			COALESCE(com_compras.vl_frete,0.00) AS vl_frete, 
			COALESCE(com_compras.vl_seguro,0.00) AS vl_seguro, 
			COALESCE(com_compras.vl_outras_despesas,0.00) AS vl_outras_despesas, 
			COALESCE(com_compras.vl_base_calculo,0.00) as vl_base_calculo, 
			COALESCE(com_compras.vl_icms,0.00) as vl_icms, 
			COALESCE(com_compras.vl_base_calculo_st,0.00) as vl_base_calculo_st, 
			COALESCE(com_compras.vl_icms_st,0.00) as vl_icms_st, 
			COALESCE(com_compras.vl_ipi,0.00) vl_ipi, 
			nfes_cred.valor_pis as vl_pis, 
			nfes_cred.valor_cofins as vl_cofins, 			
			COALESCE(com_compras.vl_pis_st,0.00) as vl_pis_st, 
			COALESCE(com_compras.vl_cofins_st,0.00) as vl_cofins_st, 
			COALESCE(com_compras.vl_total,0.00) as vl_total, 
			COALESCE(trim(com_compras.sub_serie,'')) AS sub_serie
		FROM
			sped_cont,
			nfes_cred
			LEFT JOIN com_compras
				ON com_compras.id_compra = nfes_cred.id_compra
			LEFT JOIN fornecedores
				ON fornecedores.cnpj_cpf = com_compras.cnpj_fornecedor	
			LEFT JOIN f
				ON com_compras.codigo_filial = f.codigo_filial 
				AND com_compras.codigo_empresa = f.codigo_empresa
		WHERE
			com_compras.codigo_empresa = sped_cont.cod_empresa
	)	
	-------------------------------------------------------------------------------------------------
	--- Dados e Apuração de PIS/COFINS das Compras de Energia Eletrica/Agua/Gas                    --
	-------------------------------------------------------------------------------------------------
	,contas_consumo as (
		SELECT 			
			com_compras.id_compra, 
			f.cnpj,
			fornecedores.id_fornecedor as codigo_participante,
			com_compras.modelo_doc_fiscal, 
			CASE WHEN com_compras.modelo_doc_fiscal = '06' THEN 
				'04'
			ELSE
				'13'
			END::text as nat_bc_cred,			
			'00'::text as cod_sit,
			coalesce(trim(com_compras.serie_doc),'') as serie_doc, 
			COALESCE(trim(com_compras.sub_serie),'') AS sub_serie,
			trim(com_compras.numero_documento) as numero_documento,
			to_char(com_compras.data_emissao,'DDMMYYYY') as data_emissao, 
			to_char(com_compras.data_entrada,'DDMMYYYY') as data_entrada,
			COALESCE(com_compras.vl_total,0.00) as vl_total, 
			COALESCE(com_compras.vl_icms,0.00) as vl_icms, 
			contas_cred.valor_pis as vl_pis, 
			contas_cred.valor_cofins as vl_cofins			
		FROM
			sped_cont,
			contas_cred
			LEFT JOIN com_compras
				ON com_compras.id_compra = contas_cred.id_compra
			LEFT JOIN fornecedores
				ON fornecedores.cnpj_cpf = com_compras.cnpj_fornecedor	
			LEFT JOIN f
				ON com_compras.codigo_filial = f.codigo_filial 
				AND com_compras.codigo_empresa = f.codigo_empresa	
		WHERE
			com_compras.codigo_empresa = sped_cont.cod_empresa
	) 
	,pis_contas_consumo as (
		SELECT
			cc.id_compra,
			cst_pis,
			sum(ci.vl_total)::numeric(12,2) as vl_item,
			nat_bc_cred,
			sum(ci.vl_total)::numeric(12,2) as vl_bc_pis,
			aliquota_pis_perc as aliq_pis,
			sum(ci.valor_pis)::numeric(12,2) as vl_pis		
		FROM
			contas_consumo cc
			LEFT JOIN compras_itens ci
				ON ci.id_compra = cc.id_compra	
		GROUP BY
			cc.id_compra,
			ci.cst_pis,
			cc.nat_bc_cred,
			ci.aliquota_pis_perc
	)
	,cofins_contas_consumo as (
		SELECT
			cc.id_compra,
			cst_cofins,
			sum(ci.vl_total)::numeric(12,2) as vl_item,
			nat_bc_cred,
			sum(ci.vl_total)::numeric(12,2) as vl_bc_cofins,
			aliquota_cofins_perc as aliq_cofins,
			sum(ci.valor_cofins)::numeric(12,2) as vl_cofins
		FROM
			contas_consumo cc
			LEFT JOIN compras_itens ci
				ON ci.id_compra = cc.id_compra	
		GROUP BY
			cc.id_compra,
			ci.cst_cofins,
			cc.nat_bc_cred,
			ci.aliquota_cofins_perc
	)
	-------------------------------------------------------------------------------------------------
	--- Dados e Apuração de PIS/COFINS das Contas de Telefone                                      --
	-------------------------------------------------------------------------------------------------
	,telefone as (
		SELECT 	
			com_compras.id_compra, 
			f.cnpj,
			'03'::text as nat_bc_cred,	
			'0'::text as ind_oper,
			'1'::text as ind_emit,			
			com_compras.codigo_empresa, 
			com_compras.codigo_filial, 
			com_compras.cnpj_fornecedor, 
			fornecedores.id_fornecedor as codigo_participante, 
			com_compras.tipo_documento, 
			com_compras.modelo_doc_fiscal as cod_mod, 
			'00'::text as cod_sit,			
			coalesce(trim(com_compras.serie_doc),'') as ser, 
			coalesce(trim(com_compras.sub_serie),'') as sub, 
			trim(com_compras.numero_documento) as num_doc, 
			to_char(com_compras.data_emissao,'DDMMYYYY') as dt_doc, 
			to_char(com_compras.data_entrada,'DDMMYYYY') as dt_a_p, 
			COALESCE(com_compras.vl_total,0.00)::numeric(12,2) as vl_doc, 
			COALESCE(com_compras.vl_desconto,0.00)::numeric(12,2) AS vl_desc, 
			COALESCE(com_compras.vl_mercadoria,0.00)::numeric(12,2) AS vl_serv, 
			COALESCE(com_compras.vl_serv_nt,0.00)::numeric(12,2) AS vl_serv_nt, 
			COALESCE(com_compras.vl_terc,0.00)::numeric(12,2) AS vl_terc, 
			COALESCE(com_compras.vl_outras_despesas,0.00)::numeric(12,2) AS vl_da, 
			COALESCE(com_compras.vl_base_calculo,0.00)::numeric(12,2) as vl_bc_icms, 
			COALESCE(com_compras.vl_icms,0.00)::numeric(12,2) as vl_icms, 
			''::text as cod_inf,
			telefone_cred.valor_pis::numeric(12,2) as vl_pis,
			telefone_cred.valor_cofins::numeric(12,2) as vl_cofins
		FROM
			sped_cont,
			telefone_cred
			LEFT JOIN com_compras
				ON com_compras.id_compra = telefone_cred.id_compra
			LEFT JOIN fornecedores
				ON fornecedores.cnpj_cpf = com_compras.cnpj_fornecedor	
			LEFT JOIN f
				ON com_compras.codigo_filial = f.codigo_filial 
				AND com_compras.codigo_empresa = f.codigo_empresa
		WHERE
			com_compras.codigo_empresa = sped_cont.cod_empresa
		
	) 	
	,pis_telefone as (
		SELECT
			ct.id_compra,
			cst_pis,
			sum(ci.vl_total)::numeric(12,2) as vl_item,
			nat_bc_cred,
			sum(ci.vl_total)::numeric(12,2) as vl_bc_pis,
			aliquota_pis_perc as aliq_pis,
			sum(ci.valor_pis)::numeric(12,2) as vl_pis		
		FROM
			telefone ct
			LEFT JOIN compras_itens ci
				ON ci.id_compra = ct.id_compra	
		GROUP BY
			ct.id_compra,
			ci.cst_pis,
			ct.nat_bc_cred,
			ci.aliquota_pis_perc
	)
	,cofins_telefone as (
		SELECT
			ct.id_compra,
			cst_cofins,
			sum(ci.vl_total)::numeric(12,2) as vl_item,
			nat_bc_cred,
			sum(ci.vl_total)::numeric(12,2) as vl_bc_cofins,
			aliquota_cofins_perc as aliq_cofins,
			sum(ci.valor_cofins)::numeric(12,2) as vl_cofins		
		FROM
			telefone ct
			LEFT JOIN compras_itens ci
				ON ci.id_compra = ct.id_compra	
		GROUP BY
			ct.id_compra,
			ci.cst_cofins,
			ct.nat_bc_cred,
			ci.aliquota_cofins_perc
	)
	-------------------------------------------------------------------------------------------------
	--- Conhecimentos de Entrada - sigla 'c_e'                                                     --
	-------------------------------------------------------------------------------------------------
	,c_e AS (
		SELECT 	
			0::integer as ind_oper, 	
			1::integer as ind_emit, 	
			c.modelo_doc_fiscal as cod_mod, 	
			TRIM(c.serie_doc) as serie_doc, 	
			TRIM(c.sub_serie) as sub_serie,
			COALESCE(com_compras_itens.cst_icms,'') as cst, 
			null::integer as modal, 	
			c.id_compra as id_conhecimento,
			fornecedores.id_fornecedor as codigo_participante, 	
			c.cnpj_fornecedor as cnpj_cpf, 	
			cidades.cod_ibge, 	
			to_char(c.data_emissao,'DDMMYYYY') as data_emissao, 	
			to_char(c.data_entrada,'DDMMYYYY') as data_entrada, 	
			null::integer as cancelado, 
			c.tipo_frete as ind_frt, 	
			c.numero_documento, 	
			com_compras_itens.cfop as cod_operacao_fiscal, 	
			'00' as cod_sit,    				
			COALESCE(c.vl_mercadoria,0.00)::numeric(12,2)  as frete_valor, 	
			COALESCE(c.vl_total,0.00)::numeric(12,2) as total_frete, 	
			COALESCE(c.vl_icms,0.00)::numeric(12,2) as imposto, 	
			COALESCE(c.vl_base_calculo,0.00)::numeric(12,2) as base_calculo, 	
			COALESCE(com_compras_itens.aliquota_icms,0.00)::numeric(12,2) as aliquota, 	
			1::integer as tipo_imposto, 	
			c.chave_nfe as chave_cte, 	
			1::integer as status_cte 
		FROM 
			sped_cont,
			f
			LEFT JOIN com_compras c
				ON c.codigo_empresa = f.codigo_empresa
					AND c.codigo_filial = f.codigo_filial
			LEFT JOIN fornecedores 
				ON c.cnpj_fornecedor = fornecedores.cnpj_cpf 	
			LEFT JOIN cidades 
				ON fornecedores.id_cidade::integer = cidades.id_cidade::integer
			LEFT JOIN com_compras_itens
				ON com_compras_itens.id_compra = c.id_compra
		WHERE 			
			c.modelo_doc_fiscal IN ('57') 			
			AND data_entrada IS NOT NULL 
			AND data_entrada::date >= sped_cont.inicio
			AND data_entrada::date <= sped_cont.fim
			AND c.codigo_empresa = sped_cont.cod_empresa

		ORDER BY 
			numero_documento 
	) 
	-------------------------------------------------------------------------------------------------
	--- Conhecimentos de Saída - sigla 'c'                                                         --
	-------------------------------------------------------------------------------------------------		
	,c AS (
		SELECT 			
			(row_number(*) over (partition by 1))::integer as ind,
			f.cnpj,
			filial_emitente,
			1::integer as ind_oper, 	
			0::integer as ind_emit, 	
			'57'::character(2) as cod_mod, 
			f_get_cst_cte(c.cstat) as cod_sit,
			--c.cstat,			
			TRIM(COALESCE(serie_doc,'')) as serie_doc, 	
			''::text as sub_serie, 	
			MIN(numero_ctrc_filial) as numero_inicial,
			MAX(numero_ctrc_filial) as numero_final,
			trim(cod_operacao_fiscal) as cfop,
			to_char(data_emissao::date,'DDMMYYYY') as data_emissao,
			SUM(total_frete) as total_frete
		FROM 	
			sped_cont,
			f
			LEFT JOIN scr_conhecimento  c
				ON c.empresa_emitente = f.codigo_empresa
				 AND c.filial_emitente = f.codigo_filial			
			
		WHERE 	
			c.data_emissao IS NOT NULL
			AND c.data_emissao::date >= sped_cont.inicio
			AND c.data_emissao::date <= sped_cont.fim
			AND c.tipo_documento = 1 
			AND c.cstat = '100'
			AND c.empresa_emitente = sped_cont.cod_empresa

		GROUP BY 
			filial_emitente,
			f.cnpj,
			f_get_cst_cte(c.cstat),
			cod_operacao_fiscal,
			serie_doc,
			sub_serie,
			data_emissao::date
		ORDER BY
			f.cnpj,
			data_emissao,
			cfop
	)
	--Apuração dos Impostos PIS e COFINS
	,apur_imp AS (
		SELECT 
			ind,
			'01'::character(2) as cst_pis,
			total_frete as vl_item_pis,
			total_frete as vl_bc_pis,
			i.aliq_pis,
			(total_frete * (i.aliq_pis/100))::numeric(12,2) as vl_pis,
			'01'::character(2) as cst_cofins,
			total_frete as vl_item_cofins,
			total_frete as vl_bc_cofins,
			i.aliq_cofins,
			(total_frete * (i.aliq_cofins/100))::numeric(12,2) as vl_cofins
		FROM 
			i,
			c
	) 
	,filiais_d AS (
		SELECT cnpj FROM c GROUP BY cnpj
	)
	,participantes AS (
		SELECT 
			'F' || lpad(fornecedores.id_fornecedor::text,7,'0') as cod_part,
			trim(fornecedores.nome_razao) as nome, 
			trim(fornecedores.cnpj_cpf) as cnpj_cpf, 
			CASE 
				WHEN char_length(fornecedores.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(fornecedores.iest) = 'ISENTO' 
				THEN '' ELSE trim(fornecedores.iest)
			END::character(15) as inscricao_estadual, 
			cidades.cod_ibge, 
			fornecedores.endereco, 
			fornecedores.numero, 
			fornecedores.bairro 
		FROM 
			fornecedores
			LEFT JOIN cidades 
				ON fornecedores.id_cidade = cidades.id_cidade 
		WHERE
			EXISTS (SELECT 1
				FROM compras
				WHERE fornecedores.id_fornecedor = compras.codigo_participante
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		SELECT 
			'F' || lpad(fornecedores.id_fornecedor::text,7,'0') as cod_part,
			trim(fornecedores.nome_razao) as nome, 
			trim(fornecedores.cnpj_cpf) as cnpj_cpf, 
			CASE 
				WHEN char_length(fornecedores.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(fornecedores.iest) = 'ISENTO' 
				THEN '' ELSE trim(fornecedores.iest)
			END::character(15) as inscricao_estadual, 
			cidades.cod_ibge, 
			fornecedores.endereco, 
			fornecedores.numero, 
			fornecedores.bairro 
		FROM 
			fornecedores
			LEFT JOIN cidades 
				ON fornecedores.id_cidade = cidades.id_cidade 
		WHERE
			EXISTS (SELECT 1
				FROM telefone
				WHERE fornecedores.id_fornecedor = telefone.codigo_participante
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		SELECT 
			'F' || lpad(fornecedores.id_fornecedor::text,7,'0') as cod_part,
			trim(fornecedores.nome_razao) as nome, 
			trim(fornecedores.cnpj_cpf) as cnpj_cpf, 
			CASE 
				WHEN char_length(fornecedores.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(fornecedores.iest) = 'ISENTO' 
				THEN '' ELSE trim(fornecedores.iest)
			END::character(15) as inscricao_estadual, 
			cidades.cod_ibge, 
			fornecedores.endereco, 
			fornecedores.numero, 
			fornecedores.bairro 
		FROM 
			fornecedores
			LEFT JOIN cidades 
				ON fornecedores.id_cidade = cidades.id_cidade 
		WHERE
			EXISTS (SELECT 1
				FROM contas_consumo
				WHERE fornecedores.id_fornecedor = contas_consumo.codigo_participante
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		SELECT 
			'F' || lpad(fornecedores.id_fornecedor::text,7,'0') as cod_part,
			trim(fornecedores.nome_razao) as nome, 
			trim(fornecedores.cnpj_cpf) as cnpj_cpf, 
			CASE 
				WHEN char_length(fornecedores.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(fornecedores.iest) = 'ISENTO' 
				THEN '' ELSE trim(fornecedores.iest)
			END::character(15) as inscricao_estadual, 
			cidades.cod_ibge, 
			fornecedores.endereco, 
			fornecedores.numero, 
			fornecedores.bairro 
		FROM 
			fornecedores
			LEFT JOIN cidades 
				ON fornecedores.id_cidade = cidades.id_cidade 
		WHERE
			EXISTS (SELECT 1
				FROM s
				WHERE fornecedores.id_fornecedor = s.codigo_participante
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade			
	)
	,unidades AS (
		SELECT 	
			compras_itens.unidade, 	
			MAX(
				CASE WHEN TRIM(UPPER(descricao)) = TRIM(UPPER(compras_itens.unidade)) 
					THEN descricao || ' Desc' 
					ELSE descricao 
				END
			)::text as descricao 
		FROM 	
			compras_itens
				LEFT JOIN efd_unidades_medida
					ON efd_unidades_medida.unidade = compras_itens.unidade
			
		GROUP BY 	
			compras_itens.unidade 	
		UNION		
		SELECT 	
			si.unidade, 	
			MAX(
				CASE WHEN TRIM(UPPER(descricao)) = TRIM(UPPER(si.unidade)) 
					THEN descricao || ' Desc' 
					ELSE descricao 
				END
			)::text as descricao 
		FROM 	
			si
				LEFT JOIN efd_unidades_medida
					ON efd_unidades_medida.unidade = si.unidade
			
		GROUP BY 	
			si.unidade 	

	) 	
	,produtos AS (
		WITH t AS (
			SELECT 
				id_produto
			FROM
				compras_itens
			GROUP BY 
				id_produto
			UNION
			SELECT 
				id_produto
			FROM
				si
			GROUP BY 
				id_produto
			
				
		)
		SELECT 	
			'P' || lpad(id_produto::text,7,'0') as id_produto,	
			COALESCE(trim(descr_item),'') as descr_item, 	
			COALESCE(trim(cod_barra),'') as cod_barra, 	
			COALESCE(trim(efd_unidades_medida.unidade),'') as unidade, 	
			COALESCE(trim(tipo_item),'07')::character(2) as tipo_item, 	
			COALESCE(aliquota_icms,0.00) as aliquota_icms, 	
			COALESCE(lpad(left(trim(codigo_mercosul),8),8,'0'),'') as codigo_mercosul, 	
			COALESCE(trim(codigo_ex),'') as codigo_ex, 	
			COALESCE(trim(codigo_genero),'') as codigo_genero, 	
			COALESCE(trim(codigo_servico),'') as codigo_servico 
		FROM 	
			com_produtos 	
			LEFT JOIN efd_unidades_medida 
				ON com_produtos.id_unidade = efd_unidades_medida.id_unidade 
		WHERE 	
			EXISTS (SELECT 	1
				FROM 	t
				WHERE 	t.id_produto = com_produtos.id_produto)
			
			
	)
	-------------------------------------------------------------------------------------------------	
	--- Identifica Filiais com Movimento no Período                                                --
	-------------------------------------------------------------------------------------------------	
	--Filiais do Bloco A	
	,fa AS (
		SELECT cnpj FROM s GROUP BY cnpj
	)
	--Filiais do Bloco C
	,fc AS (
		SELECT cnpj FROM compras GROUP BY cnpj
		UNION 
		SELECT cnpj FROM contas_consumo GROUP BY cnpj
	)
	--Filiais do Bloco D
	,fd AS (
		SELECT cnpj FROM c GROUP BY cnpj
		UNION 
		SELECT cnpj FROM telefone GROUP BY cnpj
	)
	--Filiais que movimentaram no periodo
	,fm AS (
		SELECT cnpj FROM fa
		UNION 
		SELECT cnpj FROM fc
		UNION 
		SELECT cnpj FROM fd
	)	
	-------------------------------------------------------------------------------------------------	
	--- Calcula Totais dos Blocos                                                                  --
	-------------------------------------------------------------------------------------------------
	,totais_bloco_1000 AS (
		WITH t AS (
			SELECT 1, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_p000 AS (
		WITH t AS (
			SELECT 1, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_m000 AS (
		WITH t AS (
			SELECT 1, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_i000 AS (
		WITH t AS (
			SELECT 1, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_f000 AS (
		WITH t AS (
			SELECT 1, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_d000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM c UNION
			SELECT 2, count(*) as qt FROM apur_imp UNION
			SELECT 3, count(*) as qt FROM apur_imp UNION
			SELECT 4, count(*) as qt FROM telefone UNION			
			SELECT 5, count(*) as qt FROM pis_telefone UNION
			SELECT 6, count(*) as qt FROM cofins_telefone UNION
			SELECT 7, count(*) as qt FROM fd UNION
			SELECT 8, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_c000 AS (
		WITH t AS (			
			SELECT 1, count(*) as qt FROM compras UNION
			SELECT 
				2, count(*) as qt 
			FROM 	nfes_cred 
				LEFT JOIN compras_itens
					ON nfes_cred.id_compra = compras_itens.id_compra 
			UNION	
			SELECT 3, count(*) as qt FROM contas_consumo UNION 
			SELECT 4, count(*) as qt FROM pis_contas_consumo UNION 
			SELECT 5, count(*) as qt FROM cofins_contas_consumo UNION 						
			SELECT 7, count(*) as qt FROM fc UNION 			
			SELECT 8, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	) 
	,totais_bloco_a000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM s UNION
			SELECT 2, count(*) as qt FROM si UNION			
			SELECT 3, count(*) as qt FROM fa UNION 			
			SELECT 5, 2 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_0000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM fm 		UNION
			SELECT 2, count(*) as qt FROM contador 		UNION
			SELECT 3, count(*) as qt FROM participantes 	UNION 
			SELECT 4, count(*) as qt FROM unidades 		UNION 
			SELECT 5, count(*) as qt FROM produtos 		UNION			
			SELECT 7, count(*) as qt FROM e 		UNION
			SELECT 8, 3 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	) 
	-------------------------------------------------------------------------------------------------
	--- Montagem dos blocos SPED                                                                   --
	-------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------	
	--- BLOCO 1                                                                                    --
	-------------------------------------------------------------------------------------------------
	,reg_1990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1990' as reg,
					totais_bloco_1000.total as qtd_li_1
				FROM 
					totais_bloco_1000
				) row
		)
		SELECT array_agg(json) as reg_1990 from temp
	)
	,reg_1001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1001' as reg,
					'1' as ind_mov,
					reg_1990.reg_1990
				FROM					
					reg_1990
				) row
		)
		SELECT array_agg(json) as reg_1001 from temp
	)	
	-------------------------------------------------------------------------------------------------	
	--- BLOCO P                                                                                    --
	-------------------------------------------------------------------------------------------------	
	,reg_p990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'P990' as reg,
					totais_bloco_p000.total as qtd_li_p
				FROM 
					totais_bloco_p000
				) row
		)
		SELECT array_agg(json) as reg_p990 from temp
	)
	,reg_p001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'P001' as reg,
					'1' as ind_mov,
					reg_p990.reg_p990
				FROM					
					reg_p990
				) row
		)
		SELECT array_agg(json) as reg_p001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO M                                                                                    --
	-------------------------------------------------------------------------------------------------	
	,reg_m990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'M990' as reg,
					totais_bloco_m000.total as qtd_li_m
				FROM 
					totais_bloco_m000
				) row
		)
		SELECT array_agg(json) as reg_m990 from temp
	)
	,reg_m001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'M001' as reg,
					'1' as ind_mov,
					reg_m990.reg_m990
				FROM					
					reg_m990
				) row
		)
		SELECT array_agg(json) as reg_m001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO F                                                                                    --
	-------------------------------------------------------------------------------------------------	
	,reg_f990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'F990' as reg,
					totais_bloco_f000.total as qtd_li_f
				FROM 
					totais_bloco_f000
				) row
		)
		SELECT array_agg(json) as reg_f990 from temp
	)
	,reg_f001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'F001' as reg,
					'1' as ind_mov,
					reg_f990.reg_f990
				FROM					
					reg_f990
				) row
		)
		SELECT array_agg(json) as reg_f001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO D                                                                                    --
	-------------------------------------------------------------------------------------------------	
	,reg_d990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'D990' as reg,
					totais_bloco_d000.total as qtd_li_d
				FROM 
					totais_bloco_d000
				) row
		)
		SELECT array_agg(json) as reg_d990 from temp
	)
	,reg_d505 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'D505' AS reg,
					id_compra,
					cst_cofins,
					vl_item,
					nat_bc_cred,
					vl_bc_cofins,
					aliq_cofins,
					vl_cofins,
					''::text as cod_cta				
				FROM
					cofins_telefone
				
			) row
		)
		SELECT id_compra, array_agg(json) as reg_d505 FROM temp GROUP BY id_compra
	)
	,reg_d501 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'D501' AS reg,
					id_compra,
					cst_pis,
					vl_item,
					nat_bc_cred,
					vl_bc_pis,
					aliq_pis,
					vl_pis,
					''::text as cod_cta				
				FROM
					pis_telefone
				
			) row
		)
		SELECT id_compra, array_agg(json) as reg_d501 FROM temp GROUP BY id_compra
	)
	,reg_d500 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'D500' AS reg,
					'F' || lpad(codigo_participante::text,7,'0') as cod_part,
					'0'::text as ind_oper,
					'1'::text as ind_emit,
					cod_mod,
					cod_sit,
					ser,
					sub,
					num_doc,
					dt_doc,
					dt_a_p,
					vl_doc,
					vl_desc,
					vl_serv,
					vl_serv_nt,
					vl_terc,
					vl_da,
					vl_bc_icms,
					vl_icms,
					cod_inf,
					vl_pis,
					vl_cofins,
					cnpj,
					telefone.id_compra,
					reg_d501.reg_d501,
					reg_d505.reg_d505
				FROM
					telefone
					LEFT JOIN reg_d501 ON 
						reg_d501.id_compra = telefone.id_compra
					LEFT JOIN reg_d505 ON 
						reg_d505.id_compra = telefone.id_compra
				ORDER BY
					cnpj, dt_doc
			) row
		)
		SELECT cnpj, array_agg(json) as reg_d500 FROM temp GROUP BY cnpj
	)
	,reg_d201 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, ind FROM (
				SELECT 
					'D201' AS reg,
					ind,					
					cst_pis,
					vl_item_pis as vl_item,
					vl_bc_pis,
					aliq_pis,
					vl_pis,
					''::text cod_cta					
				FROM
					apur_imp
				
			) row
		)
		SELECT array_agg(json) as reg_d201, ind
		FROM temp 			
		GROUP BY ind	
	)
	,reg_d205 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, ind FROM (
				SELECT 
					'D205' AS reg,
					ind,					
					cst_cofins,
					vl_item_cofins as vl_item,
					vl_bc_cofins,
					aliq_cofins,
					vl_cofins,
					''::text cod_cta					
				FROM
					apur_imp
				
			) row
		)
		SELECT array_agg(json) as reg_d205, ind
		FROM temp 			
		GROUP BY ind	
	)		
	,reg_d200 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'D200' AS reg,
					cnpj,
					cod_mod,
					cod_sit,
					serie_doc as ser,
					sub_serie as sub,
					right(numero_inicial,7) as num_doc_ini,
					right(numero_final,7) as num_doc_fim,
					cfop,
					data_emissao as dt_ref,
					total_frete as vl_doc,
					0.00::numeric(12,2) as vl_desc,
					reg_d201.reg_d201,
					reg_d205.reg_d205
					--reg_c170.reg_c170					
				FROM
					c
 					LEFT JOIN reg_d201 
 						ON c.ind = reg_d201.ind
 					LEFT JOIN reg_d205 
 						ON c.ind = reg_d205.ind
				
			) row
		)
		SELECT array_agg(json) as reg_d200, cnpj 
		FROM temp 
		GROUP BY cnpj
	)
	,reg_d010 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'D010' as reg,
					fd.cnpj,
					reg_d200.reg_d200,
					reg_d500.reg_d500					
				FROM 	
					fd
					LEFT JOIN reg_d200 ON reg_d200.cnpj = fd.cnpj
					LEFT JOIN reg_d500 ON reg_d500.cnpj = fd.cnpj			
				) row
		)
		SELECT array_agg(json) as reg_d010
		FROM temp 				
	)
	,reg_d001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'D001' as reg,
					CASE 	WHEN reg_d010.reg_d010 IS NULL 
						THEN '1' 
						ELSE '0'
					END::character(1) as ind_mov,
					reg_d010.reg_d010,
					reg_d990.reg_d990
				FROM
					reg_d010,
					reg_d990
				) row
		)
		SELECT array_agg(json) as reg_d001 from temp
	)	
	-------------------------------------------------------------------------------------------------
	--- BLOCO C                                                                                    --
	-------------------------------------------------------------------------------------------------
	,reg_c990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'C990' as reg,
					totais_bloco_c000.total as qtd_li_c
				FROM 
					totais_bloco_c000
				) row
		)
		SELECT array_agg(json) as reg_c990 from temp
	)
	,reg_c505 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C505' AS reg,
					id_compra,
					cst_cofins,
					vl_item,
					nat_bc_cred,
					vl_bc_cofins,
					aliq_cofins,
					vl_cofins,
					''::text as cod_cta				
				FROM
					cofins_contas_consumo
				
			) row
		)
		SELECT id_compra, array_agg(json) as reg_c505 FROM temp GROUP BY id_compra
	)
	,reg_c501 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C501' AS reg,
					id_compra,
					cst_pis,
					vl_item,
					nat_bc_cred,
					vl_bc_pis,
					aliq_pis,
					vl_pis,
					''::text as cod_cta				
				FROM
					pis_contas_consumo
				
			) row
		)
		SELECT id_compra, array_agg(json) as reg_c501 FROM temp GROUP BY id_compra
	)	
	,reg_c500 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'C500' AS reg,
					'F' || lpad(codigo_participante::text,7,'0') as cod_part,
					modelo_doc_fiscal as cod_mod,
					cod_sit,
					serie_doc as ser,
					sub_serie as sub,
					numero_documento as num_doc,
					data_emissao as dt_doc,
					data_entrada as dt_ent,
					vl_total as vl_doc,
					vl_icms,
					vl_pis,
					vl_cofins,
					cnpj,
					contas_consumo.id_compra,
					reg_c501.reg_c501,
					reg_c505.reg_c505	
				FROM
					contas_consumo
					LEFT JOIN reg_c501 ON 
						reg_c501.id_compra = contas_consumo.id_compra
					LEFT JOIN reg_c505 ON 
						reg_c505.id_compra = contas_consumo.id_compra
				ORDER BY
					cnpj, data_emissao
			) row
		)
		SELECT cnpj, array_agg(json) as reg_c500 FROM temp GROUP BY cnpj
	)
	,reg_c170 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C170' AS reg,
					row_number() over (partition by compras_itens.id_compra) as num_item,
					'P' || lpad(id_produto::text,7,'0') as cod_item,
					''::text as descr_compl,
					quantidade as qtd,
					trim(unidade) as unid,
					vl_total as vl_item,
					vl_desconto as vl_desc,
					movimentacao_fisica::text as ind_mov,
					cst_icms as cst_icms,
					trim(cfop) as cfop,
					''::text as cod_nat,
					vl_base_icms as vl_bc_icms,
					aliquota_icms as aliq_icms,
					valor_icms as vl_icms,				
			
					--Estudar o caso de Substituição Tributário 
					-- para o Lucro Real
					COALESCE(0.00,valor_base_icms_st) as vl_bc_icms_st,
					COALESCE(0.00, aliquota_icms_st) as aliq_st,
					COALESCE(0.00, valor_icms_st) as vl_icms_st,
					
					''::text as ind_apur,
					cst_ipi,
					''::text as cod_enq,
					vl_base_ipi as vl_bc_ipi,
					aliquota_ipi as aliq_ipi,
					vl_ipi as vl_ipi,
					cst_pis,					
					vl_base_pis as vl_bc_pis,
					aliquota_pis_perc as aliq_pis,					
					CASE	WHEN quantidade_base_pis = 0
						THEN '' 
						ELSE replace(quantidade_base_pis::text,'.',',') 
					END::text as quant_bc_pis,
					CASE 	WHEN vl_aliquota_pis  = 0 
						THEN '' 
						ELSE replace(vl_aliquota_pis::text,'.',',') 
					END::text as aliq_pis_quant,
					
					compras_itens.valor_pis as vl_pis,
					cst_cofins,
					vl_base_cofins as vl_bc_cofins,
					aliquota_cofins_perc as aliq_cofins,
					CASE 	WHEN quantidade_base_cofins  = 0 
						THEN '' 
						ELSE replace(quantidade_base_cofins::text,'.',',') 
					END::text as quant_bc_cofins,
					CASE 	WHEN vl_aliquota_cofins  = 0 
						THEN '' 
						ELSE replace(vl_aliquota_cofins::text,'.',',') 
					END::text as aliq_cofins_quant,
					compras_itens.valor_cofins as vl_cofins,
					''::text as cod_cta,
					compras_itens.id_compra
				FROM
					nfes_cred
					LEFT JOIN compras_itens ON 
						compras_itens.id_compra = nfes_cred.id_compra
				ORDER BY
					id_compra, id_compra_item
			) row
		)
		SELECT id_compra, array_agg(json) as reg_c170 FROM temp GROUP BY id_compra
	)
	,reg_c100 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'C100' AS reg,
					cnpj,
					'0' as ind_oper,
					'1' as ind_emit,
					'F' || lpad(codigo_participante::text,7,'0') as cod_part,
					trim(modelo_doc_fiscal) as cod_mod,
					'00' as cod_sit,
					trim(serie_doc) as ser,
					trim(numero_documento) as num_doc,
					COALESCE(chave_nfe,'') as chave_nfe,
					data_emissao as dt_doc,
					data_entrada as dt_e_s,
					vl_total as vl_doc,
					tipo_pagamento as ind_pgto,
					vl_desconto as vl_desc,
					vl_abatimento_nt as vl_abat_nt,
					vl_mercadoria as vl_merc,
					tipo_frete as ind_frt,
					vl_frete as vl_frt,
					vl_seguro as vl_seg,
					vl_outras_despesas as vl_out_da,
					vl_base_calculo as vl_bc_icms,
					vl_icms as vl_icms,
					
					--Estudar o caso de Substituição Tributário 
					-- para o Lucro Real
					COALESCE(0.00,vl_base_calculo_st) as vl_bc_icms_st,
					COALESCE(0.00,vl_icms_st) as vl_icms_st,
					
					vl_ipi,
					vl_pis,
					vl_cofins,
					vl_pis_st as vl_pis_st,
					vl_cofins_st as vl_cofins_st,
					reg_c170.reg_c170					
				FROM
					compras
					LEFT JOIN reg_c170 
						ON compras.id_compra = reg_c170.id_compra
				ORDER BY
					numero_compra
			) row
		)
		SELECT array_agg(json) as reg_C100, cnpj 
		FROM temp 
		GROUP BY cnpj
	)	
	,reg_c010 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'C010' as reg,
					fc.cnpj,
					'2'::text as ind_escri,
					reg_c100.reg_c100,
					reg_c500.reg_c500					
				FROM 	
					fc
					LEFT JOIN reg_c100 ON reg_c100.cnpj = fc.cnpj
					LEFT JOIN reg_c500 ON reg_c500.cnpj = fc.cnpj			
				) row
		)
		SELECT array_agg(json) as reg_c010
		FROM temp 				
	)	
	,reg_c001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'C001' as reg,
					CASE 	WHEN reg_c010.reg_c010 IS NULL 
						THEN '1' 
						ELSE '0'
					END::character(1) as ind_mov,
					reg_c010.reg_c010,
					reg_c990.reg_c990
				FROM
					reg_c010,
					reg_c990
				) row
		)
		SELECT array_agg(json) as reg_C001 from temp
	)
	
	-------------------------------------------------------------------------------------------------
	--- BLOCO A                                                                                    --
	-------------------------------------------------------------------------------------------------
	,reg_a990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'A990' as reg,
					totais_bloco_a000.total as qtd_li_a
				FROM 
					totais_bloco_a000
				) row
		)
		SELECT array_agg(json) as reg_a990 from temp
	)
	,reg_a170 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'A170' as reg,
					id_compra,
					row_number() over (partition by id_compra) as num_item,
					'P' || lpad(codigo_produto::text,7,'0') as cod_item,
					COALESCE(descricao_complementar,'') as descr_compl,
					vl_total as vl_item,
					vl_desconto as vl_desc,
					nat_bc_cred,					
					COALESCE(ind_orig_cred::text,'') as ind_orig_cred,
					cst_pis,
					vl_base_pis as vl_bc_pis,
					aliquota_pis_perc as aliq_pis,
					vl_pis,
					cst_cofins,
					valor_base_cofins as vl_bc_cofins,
					aliquota_cofins_perc as aliq_cofins,
					vl_cofins,
					''::text as cod_cta,
					''::text as cod_ccus
				FROM 
					si
					
				) row
		)
		SELECT array_agg(json) as reg_a170, id_compra 
		FROM temp 
		GROUP BY id_compra
	) 
	,reg_a100 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'A100' as reg,
					cnpj,
					ind_oper,
					ind_emit,
					'F' || lpad(codigo_participante::text,7,'0') as cod_part,
					'00'::text as cod_sit,
					serie_doc as ser,
					sub_serie as sub,
					numero_documento as num_doc,
					chave_nfse,
					data_emissao as dt_doc,
					data_entrada as dt_exe_serv,
					vl_total as vl_doc,
					vl_desconto as vl_desc,
					tipo_pagamento as ind_pgto,
					vl_bc_pis,
					vl_pis,
					vl_bc_cofins,
					vl_confins as vl_cofins,
					vl_pis_ret,
					vl_cofins_ret,
					vl_iss,
					reg_a170.reg_a170														
				FROM 
					s
					LEFT JOIN reg_a170
						ON reg_a170.id_compra = s.id_compra				
					
				) row
		)
		SELECT array_agg(json) as reg_a100, cnpj 
		FROM temp 
		GROUP BY cnpj
	) 
	,reg_a010 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, cnpj FROM (
				SELECT 
					'A010' as reg,
					fa.cnpj,
					reg_a100.reg_a100
				FROM 	
					fa
					LEFT JOIN reg_a100 ON reg_a100.cnpj = fa.cnpj
					
				) row
		)
		SELECT array_agg(json) as reg_a010
		FROM temp 				
	)	
	,reg_a001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'A001' as reg,
					CASE 	WHEN reg_a010.reg_a010 IS NULL 
						THEN '1' 
						ELSE '0'
					END::character(1) as ind_mov,
					reg_a010.reg_a010,
					reg_a990.reg_a990
				FROM 
					reg_a010,
					reg_a990
				) row
		)
		SELECT array_agg(json) as reg_a001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO 0                                                                                    --
	-------------------------------------------------------------------------------------------------
	,reg_0990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0990' as reg,
					totais_bloco_0000.total as qtd_li_0
				FROM 
					totais_bloco_0000				
				) row
		)
		SELECT array_agg(json) as reg_0990 from temp
	)
	,reg_0200 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0200' as reg,
					id_produto as cod_item,
					descr_item,
					cod_barra,
					''::text as cod_ant_item,
					unidade as unid_inv,
					tipo_item,
					codigo_mercosul as cod_ncm,
					codigo_ex as ex_ipi,
					codigo_genero as cod_gen,
					codigo_servico as cod_lst,
					aliquota_icms as aliq_icms					
				FROM 
					produtos
				ORDER BY 
					id_produto
				) row
		)
		SELECT array_agg(json) as reg_0200 from temp
	) 
	,reg_0190 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0190' as reg,
					trim(unidade) as unid,
					trim(descricao) as descr
				FROM 
					unidades
				ORDER BY unidade
				) row
		)
		SELECT array_agg(json) as reg_0190 from temp
	) 
	,reg_0150 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0150' as reg,
					cod_part,
					trim(nome) as nome,
					'1058'::text as cod_pais,
					CASE WHEN tipo_pessoa = 1 THEN trim(cnpj_cpf) ELSE '' END as cnpj,
					CASE WHEN tipo_pessoa = 1 THEN '' ELSE trim(cnpj_cpf) END as cpf,
					COALESCE(trim(inscricao_estadual),'') as ie,
					cod_ibge as cod_mun,
					''::text as suframa,
					trim(endereco) as end,
					trim(numero) as num,
					''::text as compl,
					trim(bairro) as bairro					
				FROM 
					participantes
				ORDER BY cod_part
				) row
		)
		SELECT array_agg(json) as reg_0150 from temp
	)
	,reg_0140 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0140' as reg,
					codigo_filial as cod_est,
					razao_social as nome,
					f.cnpj,
					uf,
					inscricao_estadual as ie,
					cod_ibge as cod_mun,
					''::text as im,
					suframa					
				FROM 
					fm
					LEFT JOIN f ON f.cnpj = fm.cnpj
				) row
		)
		SELECT array_agg(json) as reg_0140 from temp
	)
	,reg_0110 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0110' as reg,					
					cod_inc_trib,
					ind_apro_cred,
					cod_tipo_cont,
					ind_reg_cum
				FROM 
					e
				) row
		)
		SELECT array_agg(json) as reg_0110 from temp
	)
	,reg_0100 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0100' as reg,
					trim(nome_razao) as nome,
					trim(cnpj_cpf) as cpf,
					trim(conselho_regional) as crc,
					''::text as cnpj,
					trim(cep) as cep,
					trim(endereco) as end,
					trim(numero) as num,
					''::text as compl,
					trim(bairro) as bairro,
					TRIM((ddd || telefone)) as telefone,
					COALESCE(trim(fax),'') as fax,
					trim(email) as email,
					cod_ibge as cod_mun
				FROM 
					contador
				) row
		)
		SELECT array_agg(json) as reg_0100 from temp
	) 
	,reg_0001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0001' as reg,
					'0' as ind_mov,					
					reg_0100.reg_0100,
					reg_0110.reg_0110,
					reg_0140.reg_0140,
					reg_0150.reg_0150,
					reg_0190.reg_0190,
					reg_0200.reg_0200,
					reg_0990.reg_0990
				FROM 
					
					reg_0100,
					reg_0110,
					reg_0140,
					reg_0150,
					reg_0190,
					reg_0200,
					reg_0990
				) row
		)
		SELECT array_agg(json) as reg_0001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- Processamento do Bloco 9000                                                                --
	-------------------------------------------------------------------------------------------------
	,reg_0000_tmp AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_0000 FROM (
				SELECT 
					'0000' as reg,
					reg_0001.reg_0001,
					reg_a001.reg_a001,
 					reg_c001.reg_c001,
 					reg_d001.reg_d001,
 					reg_f001.reg_f001,
 					reg_m001.reg_m001,
 					reg_p001.reg_p001,
 					reg_1001.reg_1001
				FROM 
					sped_cont,
					e,
					reg_0001,
					reg_a001,
 					reg_c001,
 					reg_d001,
 					reg_f001,
 					reg_m001,
 					reg_p001,
 					reg_1001
				) row
		)
		SELECT array_agg(json_0000) as reg_0000 from temp
	),
	regs_9900 AS (
		WITH t AS (
				SELECT row_to_json(row, true) as json 
				FROM 
				(
					SELECT 
						reg_0000_tmp.reg_0000 as reg_0000
					FROM 
						reg_0000_tmp
				) row
		),
		t1 AS (
			SELECT 
				unnest(fpy_get_regs_sped(json::text)) as registro
			FROM
				t 
		),
		t2 AS (
			SELECT 
				registro, 
				count(*)::integer as qt 
			FROM 
				t1
			GROUP BY 
				registro
			ORDER BY 
				registro		
		),
		t3 AS (
			SELECT 
				1 as k,
				registro,
				qt
			FROM 
				t2
			UNION 
			SELECT 
				2 as k,
				'9001'::text as registro,
				1::integer as qt
			UNION 
			SELECT 
				3 as k,
				'9900'::text as registro,
				(count(*)::integer) + 4 as qt
			FROM 
				t2
			UNION 
			SELECT 
				4 as k,
				'9990'::text as registro,
				1::integer as qt 
			UNION 
			SELECT
				5 as k,
				'9999' as registro, 
				1::integer as qt 
		)
		SELECT 
			k,
			registro,
			qt
		FROM 
			t3
	)	
	,reg_9999 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'9999' as reg,
					sum(qt)::integer  as qtd_li
				FROM
					regs_9900
			) row
		)
		SELECT array_agg(json) as reg_9999 from temp
	)	
	,reg_9990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'9990' as reg,
					count(*)::integer + 3 as qtd_li_9
				FROM
					regs_9900
			) row
		)
		SELECT array_agg(json) as reg_9990 from temp
	)	
	,reg_9900 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'9900' as reg,
					registro as reg_blc,
					qt as qtd_reg_blc
				FROM
					regs_9900
				ORDER BY 
					k, 
					registro					
			) row
		)
		SELECT array_agg(json) as reg_9900 from temp
	)
	,reg_9001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'9001' as reg,
					'0' as ind_mov,
					reg_9900.reg_9900,
					reg_9990.reg_9990,
					reg_9999.reg_9999
				FROM					
					reg_9990,
					reg_9900,
					reg_9999
				) row
		)
		SELECT array_agg(json) as reg_9001 from temp
	)		
	,reg_0000 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json_0000 FROM (
				SELECT 
					'0000' as reg,
					sped_cont.versao as cod_ver,
					sped_cont.cod_fin as tipo_escrit,
					''::text as ind_sit_esp,
					''::text as num_rec_anterior,
					to_char(sped_cont.inicio,'DDMMYYYY') as dt_ini,
					to_char(sped_cont.fim,'DDMMYYYY') as dt_fin,
					razao_social as nome,
					cnpj,								
					uf,
					cod_ibge as cod_mun,					
					''::text as suframa,
					'00'::text as ind_nat_pj,					
					'1' as ind_ativ,
					reg_0001.reg_0001,
					reg_a001.reg_a001,
 					reg_c001.reg_c001,
 					reg_d001.reg_d001,
 					reg_f001.reg_f001,
 					reg_m001.reg_m001,
 					reg_p001.reg_p001,
 					reg_1001.reg_1001,
 					reg_9001.reg_9001
				FROM 
					sped_cont,
					e,
					reg_0001,
					reg_a001,
 					reg_c001,
 					reg_d001,
 					reg_f001,
 					reg_m001,
 					reg_p001,
 					reg_1001,
 					reg_9001
				) row
		)
		SELECT array_agg(json_0000) as reg_0000 
		FROM temp
		
	)
	SELECT row_to_json(row, true) as json 
		FROM 
		(
			SELECT 
				reg_0000.reg_0000 as reg_0000
			FROM 
				reg_0000
		) row
	INTO 
		v_dados;




	RETURN v_dados;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_edi_sped_cont(date, date, text, text, json)
  OWNER TO softlog_bsb;
