-- Function: public.f_edi_sped_fiscal(date, date, text, text, text, integer, json)
-- DROP FUNCTION public.f_edi_sped_fiscal(date, date, text, text, text, integer, json);
--SELECT f_edi_sped_fiscal('2019-08-01','2019-08-31','001','001','0',0,null)
CREATE OR REPLACE FUNCTION f_edi_sped_fiscal(
    p_inicio date,
    p_fim date,
    p_empresa text,
    p_filial text,
    p_cod_fin text,
    p_inventario integer,
    blocos json)
  RETURNS json AS
$BODY$
DECLARE
	v_dados json;
BEGIN
	--EXPLAIN ANALYSE	
	WITH 
 	sped_fiscal AS (
	SELECT 
			p_inicio as inicio,
			p_fim as fim,
			f_edi_sped_versao(p_inicio, 'EFD-ICMS-IPI') as versao,
			p_cod_fin as cod_fin,
			p_empresa as codigo_empresa,
			p_filial as codigo_filial,
			p_inventario::integer as tem_inventario
				
	)
-- 	SELECT 
--  			'2017-10-01'::date as inicio,
--  			'2017-10-31'::date as fim,
--  			f_edi_sped_versao('2017-10-01'::date, 'EFD-ICMS-IPI') as versao,
--  			'0'::text as cod_fin,
--  			'001'::text as codigo_empresa,
--  			'001'::text as codigo_filial,
--  			0::integer as tem_inventario
-- 	)	
	-------------------------------------------------------------------------------------------------
	--- Coleta e Processamento dos Dados do SPED                                                   --
	-------------------------------------------------------------------------------------------------
	,f AS (
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
			COALESCE(empresa.perfil_empresa,filial.perfil_empresa::text) as perfil_empresa, 	
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
			filial.id_contador,
			1::integer as inf_estoque
		FROM 	
			sped_fiscal,
			filial	
			LEFT JOIN cidades  
				ON filial.id_cidade = cidades.id_cidade 
			LEFT JOIN empresa ON filial.codigo_empresa = empresa.codigo_empresa
		WHERE 
			filial.codigo_empresa = sped_fiscal.codigo_empresa AND filial.codigo_filial = sped_fiscal.codigo_filial
	),
	contador AS (
		SELECT 	
			fornecedores.nome_razao, 	
			fornecedores.cnpj_cpf, 	
			COALESCE(fornecedores.conselho_regional,'') as conselho_regional, 	
			COALESCE(fornecedores.cep,'') as cep, 	
			COALESCE(fornecedores.endereco,'') as endereco, 	
			COALESCE(fornecedores.numero,'') as numero, 	
			COALESCE(fornecedores.bairro,'') as bairro, 	
			COALESCE(fornecedores.ddd,'') as ddd, 	
			COALESCE(fornecedores.telefone1,'') as telefone1, 	
			COALESCE(fornecedores.fax,'') as fax, 	
			TRIM(COALESCE(crm_contatos_detalhes.detalhe,fornecedores.email,'')) as email, 	
			cidades.cod_ibge			
		FROM 	
			f
			LEFT JOIN fornecedores  
				ON f.id_contador = fornecedores.id_fornecedor
			LEFT JOIN cidades 	
				ON fornecedores.id_cidade = cidades.id_cidade 
			LEFT JOIN crm_cont_relacoes 
				ON crm_cont_relacoes.id_estrangeiro = fornecedores.id_fornecedor				
			LEFT JOIN crm_contatos_detalhes
				ON crm_cont_relacoes.id_contato = crm_contatos_detalhes.id_contato AND 
				tp_detalhe = 'Email'
		LIMIT 1
			
	),
	c AS (
		SELECT 	
			1::integer as ind_oper, 	
			0::integer as ind_emit, 	
			'57'::character(2) as cod_mod, 	
			TRIM(COALESCE(serie_doc,'')) as serie_doc, 	
			''::character(5) as sub_serie, 	
			f_scr_get_cst(c.tipo_imposto) as cst,
			modal, 	
			id_conhecimento,	
			pagador_id as codigo_participante,
			pagador_cnpj as cnpj_cpf,
			cidades.cod_ibge,     
			data_emissao::date as data_emissao, 	 
			data_emissao::date as data_entrada, 	 
			cancelado,     
			CASE 
				WHEN pagador_id = remetente_id 		THEN '1'
				WHEN pagador_id = destinatario_id 	THEN '2'
									ELSE '0'
			END as ind_frt,			
			substr(numero_ctrc_filial,8,7)::character(6) AS numero_documento,			
			cod_operacao_fiscal,     
			CASE    WHEN c.cstat = '100' 			THEN '00'     	 
				WHEN c.cstat IN ('101','135') 		THEN '02'      	 
				WHEN c.cstat = '102' 			THEN '05'     	 
				ELSE '00'     
			END::character(2) AS cod_sit,     			 
			COALESCE(frete_valor,0.00)::numeric(12,2) as frete_valor,     
			0.00::numeric(12,2) as vl_desc,
			COALESCE(total_frete,0.00)::numeric(12,2) as total_frete,     
			CASE 	WHEN tipo_imposto < 6 
				THEN COALESCE(imposto,0.00)
				ELSE COALESCE(icms_st,0.00) 
			END::numeric(12,2) as imposto,
			CASE 
				WHEN tipo_imposto < 6 
				THEN COALESCE(base_calculo,0.00)
				ELSE COALESCE(base_calculo_st_reduzida,0.00) 
			END::numeric(12,2) as base_calculo,     
			CASE 	WHEN tipo_imposto < 6 
				THEN COALESCE(aliquota,0.00)
				ELSE COALESCE(aliquota_icms_st,0.00) 
			END::numeric(12,2) as aliquota,     			
			tipo_imposto,     
			0.00::numeric(12,2) as vl_nt,
			chave_cte,     
			status_cte,
			'0'::text as tipo_cte,
			cidades.cod_ibge as cod_ibge_origem,
			cd.cod_ibge as cod_ibge_destino,
			cidades.uf as uf_origem
		FROM 	
			sped_fiscal,
			f
			LEFT JOIN scr_conhecimento  c
				ON c.empresa_emitente = f.codigo_empresa
				   AND c.filial_emitente = f.codigo_filial			
			LEFT JOIN cidades 
				ON c.calculado_de_id_cidade = cidades.id_cidade 
			LEFT JOIN cidades cd
				ON c.calculado_ate_id_cidade = cd.id_cidade 
			
		WHERE 	
			c.data_emissao IS NOT NULL
			AND c.data_emissao::date >= sped_fiscal.inicio
			AND c.data_emissao::date <= sped_fiscal.fim
			AND c.tipo_documento = 1 
			AND c.cstat = '100'
	UNION 
	--Documentos Cancelados/Inutilizados
	SELECT 	
			1::integer as ind_oper, 	
			0::integer as ind_emit, 	
			'57'::character(2) as cod_mod, 	
			TRIM(COALESCE(serie_doc,'')) as serie_doc, 	
			''::character(5) as sub_serie, 	
			f_scr_get_cst(c.tipo_imposto) as cst,
			modal, 	
			id_conhecimento,	
			NULL as codigo_participante,
			pagador_cnpj as cnpj_cpf,			
			null::text as cod_ibge,     
			NULL::date, 	 
			NULL::date as data_entrada, 	 
			cancelado,     
			''::character(1) as ind_frt,
			substr(numero_ctrc_filial,8,7)::character(6) AS numero_documento,
			''::text as cod_operacao_fiscal,     
			CASE    WHEN c.cstat IN ('101','135') 	THEN '02'      	 
				WHEN c.cstat = '102' 		THEN '05'     	 
				ELSE '00'     
			END::character(2) AS cod_sit,     			
			NULL::numeric(12,2) as frete_valor,
			NULL::numeric(12,2) as vl_desc,   
			NULL::numeric(12,2) as total_frete,     
			NULL::numeric(12,2) as imposto,
			NULL::numeric(12,2) as base_calculo,     
			NULL::numeric(12,2) as aliquota,     
			NULL::integer as tipo_imposto,     
			NULL::numeric(12,2) as vl_nt,
			CASE WHEN c.cstat = '102' THEN '' ELSE COALESCE(chave_cte,'') END::character(44) as chave_cte,  
			status_cte,
			''::text as tipo_cte,
			''::character(7) as cod_ibge_origem,
			''::character(7) as cod_ibge_destino,
			''::character(2) as uf_origem
		FROM 	
			sped_fiscal,
			f
			LEFT JOIN scr_conhecimento  c
				ON c.empresa_emitente = f.codigo_empresa
				   AND c.filial_emitente = f.codigo_filial
		WHERE 	
			c.data_emissao IS NOT NULL
			AND c.data_emissao::date >= sped_fiscal.inicio
			AND c.data_emissao::date <= sped_fiscal.fim
			AND c.tipo_documento = 1 
			AND c.cstat IN ('101','102','135')  
	UNION 
	--Documentos Inutilizados que não estão no sistema
	SELECT 	
			1::integer as ind_oper, 	
			0::integer as ind_emit, 	
			'57'::character(2) as cod_mod, 	
			TRIM(COALESCE(serie::text,'')) as serie_doc, 	
			''::character(5) as sub_serie, 	
			f_scr_get_cst(1) as cst,
			NULL::integer as modal,
			id_anulacao as id_conhecimento,	
			NULL::integer as codigo_participante,
			NULL::text as cnpj_cpf,			
			null::text as cod_ibge,     
			NULL::date as cnpj_cpf, 	 
			NULL::date as data_entrada, 	 
			1::integer as cancelado,     
			''::character(1) as ind_frt,
			numero_documento::text AS numero_documento,
			''::text as cod_operacao_fiscal,     
			CASE    WHEN c.cstat IN ('101','135') 	THEN '02'      	 
				WHEN c.cstat = '102' 		THEN '05'     	 
				ELSE '00'     
			END::character(2) AS cod_sit,   			
			NULL::numeric(12,2) as frete_valor,
			NULL::numeric(12,2) as vl_desc,   
			NULL::numeric(12,2) as total_frete,     
			NULL::numeric(12,2) as imposto,
			NULL::numeric(12,2) as base_calculo,     
			NULL::numeric(12,2) as aliquota,     
			NULL::integer as tipo_imposto,     
			NULL::numeric(12,2) as vl_nt,
			''::text as chave_cte,  
			NULL::integer as status_cte,
			''::text as tipo_cte,
			''::character(7) as cod_ibge_origem,
			''::character(7) as cod_ibge_destino,
			''::character(2) as uf_origem

		FROM 	
			sped_fiscal,
			f
			LEFT JOIN scr_doc_anulado  c
				ON c.codigo_empresa = f.codigo_empresa
				   AND c.codigo_filial = f.codigo_filial
		WHERE 	
			c.data_hora IS NOT NULL
			AND c.data_hora::date >= sped_fiscal.inicio
			AND c.data_hora::date <= sped_fiscal.fim	
	UNION 
		SELECT 	
			0::integer as ind_oper, 	
			1::integer as ind_emit, 	
			c.modelo_doc_fiscal as cod_mod, 	
			TRIM(COALESCE(c.serie_doc,'')) as serie_doc, 	
			TRIM(COALESCE(c.sub_serie,'')) as sub_serie,
			COALESCE(com_compras_itens.cst_icms,'') as cst, 
			null::integer as modal, 	
			c.id_compra as id_conhecimento,
			fornecedores.id_fornecedor as codigo_participante, 	
			c.cnpj_fornecedor as cnpj_cpf, 	
			cidades.cod_ibge, 	
			c.data_emissao, 	
			c.data_entrada, 	
			null::integer as cancelado, 
			c.tipo_frete as ind_frt, 	
			c.numero_documento, 	
			com_compras_itens.cfop as cod_operacao_fiscal, 	
			'00' as cod_sit,    				
			COALESCE(c.vl_mercadoria,0.00)::numeric(12,2)  as frete_valor, 	
			0.00::numeric(12,2) as vl_desc,
			COALESCE(c.vl_total,0.00)::numeric(12,2) as total_frete, 	
			COALESCE(c.vl_icms,0.00)::numeric(12,2) as imposto, 	
			COALESCE(c.vl_base_calculo,0.00)::numeric(12,2) as base_calculo, 	
			COALESCE(com_compras_itens.aliquota_icms,0.00)::numeric(12,2) as aliquota, 	
			1::integer as tipo_imposto, 	
			0.00::numeric(12,2) as vl_nt,
			COALESCE(c.chave_nfe,'') as chave_cte,
			1::integer as status_cte,
			'0'::text as tipo_cte,
			--Verificar onde extrair informacao
			f.cod_ibge as cod_ibge_origem,
			cidades.cod_ibge as cod_ibge_destino,
			''::character(2) as uf_origem		
		FROM 
			sped_fiscal,
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
			c.modelo_doc_fiscal IN ('10','07','57') 			
			AND data_entrada IS NOT NULL 
			AND data_entrada::date >= sped_fiscal.inicio
			AND data_entrada::date <= sped_fiscal.fim
		ORDER BY 
			ind_oper, numero_documento 
	) 
	,c_analitico AS (
		SELECT  
			c.id_conhecimento,
			c.cst, 
			c.cod_operacao_fiscal as cfop, 
			c.aliquota::numeric(12,2) as aliquota, 
			SUM(c.total_frete)::numeric(12,2) as total_valor_operacao, 
			SUM(c.base_calculo)::numeric(12,2) as total_vl_base_icms, 
			SUM(c.imposto)::numeric(12,2) as total_valor_icms 
		FROM 
			c
		WHERE 
			cod_sit = '00'
		--WHERE 	c.id_conhecimento = lnIdConhecimento AND dados_ctr.ind_oper = lnIdInd_Oper ;
		GROUP BY 
			c.id_conhecimento,
			c.cst, 
			c.cod_operacao_fiscal, 
			c.aliquota 		
	)
	,c_aereo AS (
		SELECT 
			COUNT(*) as qt_aereo 
		FROM 
			c
		WHERE 
			modal = 2  
			AND ind_oper = '1'
	)
	,ecf_todos_produtos AS (
		SELECT 
			replace(codigo_produto,'P','')::integer as codigo_produto,
			descricao_produto,
			id_produto_softlog
		FROM 
			efd_fiscal_produtos_ecf
	)			
	,c_ecf AS (
		SELECT 
			CASE WHEN trim(ecf.bloco) = '' THEN NULL ELSE ecf.bloco END as bloco,
			string_to_array(ecf.lista_produtos,',') as lista_produtos,
			string_to_array(ecf.lista_unidades,',') as lista_unidades,
			ecf.qt_linhas,
			bloco_9
		FROM
			sped_fiscal
			LEFT JOIN filial
				ON sped_fiscal.codigo_filial = filial.codigo_filial
				AND sped_fiscal.codigo_empresa = filial.codigo_empresa
			LEFT JOIN efd_fiscal_bloco_ecf ecf
				ON filial.cnpj = ecf.cnpj
		WHERE
			to_char(sped_fiscal.inicio,'DDMMYYYY') = ecf.periodo
			
	)	
	,c_ecf_b9 AS (
		WITH t AS (
			SELECT string_to_array(bloco_9,	'@') as bloco_9	FROM c_ecf		
		),
		t2 AS (
			SELECT 
				string_to_array(trim(unnest(bloco_9),'|'),'|') as bloco_9 
			FROM 
				t
		)
		SELECT 
			4::integer as k,
			bloco_9[1] as reg,
			bloco_9[2] as reg_blc,
			bloco_9[3]::integer as qt
		FROM 
			t2
		ORDER BY reg_blc
	)
	,c_ecf_itens AS (
		WITH t AS (
			SELECT unnest(c_ecf.lista_produtos)::integer as id_produto FROM c_ecf
		)
		SELECT 
			COALESCE(ecf.codigo_produto, p.id_produto) as id_produto,
			p.id_produto as id_produto_softlog
		FROM
			t
			LEFT JOIN ecf_todos_produtos ecf
				ON t.id_produto = ecf.codigo_produto
			LEFT JOIN com_produtos p
				ON p.id_produto = ecf.id_produto_softlog
			
	)			
	,c_ecf_und AS (
		SELECT unnest(lista_unidades) as unidade FROM c_ecf
	)		
	,registro_1400 AS (
		SELECT 
			c.cod_ibge, 
			f.cod_item_1400_sped_fiscal,
			SUM(c.total_frete)::numeric(12,2) as total_mun			
		FROM 
			c,
			f
		WHERE 
			c.cod_ibge IS NOT NULL
			AND c.cod_sit = '00'
			AND c.ind_oper = '1'
			AND f.uf = c.uf_origem
		GROUP BY 
			c.cod_ibge,
			f.cod_item_1400_sped_fiscal	
		ORDER BY 
			c.cod_ibge 
	)
	,registro_1800 AS (
		SELECT  
			cst, 
			frete_valor,
			total_frete,
			base_calculo, 
			imposto  
		FROM 
			c,
			c_aereo
		WHERE 
			ind_oper = '0' 
			AND cod_mod IN ('10','57')
			AND c_aereo.qt_aereo > 0
	)
	,nfe as (
		SELECT 	
			nfe.id_nf, 
			nfe.status, 
			nfe.codigo_empresa, 
			nfe.codigo_filial, 
			nfe.cnpj_cpf_cliente as cnpj_cliente,
			cliente.codigo_cliente,
			nfe.modelo_doc_fiscal, 
			nfe.serie_doc,
			COALESCE(nfe.sub_serie,'') as sub_serie,
			nfe.numero_documento,
			nfe.chave_eletronica as chave_nfe,
			nfe.data_emissao::date as data_emissao, 
			nfe.data_saida_entrada::date as data_saida,
			nfe.data_cancelamento,
			nfe.motivo_cancelamento,
			nfe.tipo_pagamento,
			COALESCE(nfe.vl_desconto,0.00) AS vl_desconto, 
			COALESCE(nfe.vl_abatimento_nt,0.00) AS vl_abatimento_nt, 
			COALESCE(nfe.vl_mercadoria,0.00) AS vl_mercadoria, 
			COALESCE(nfe.tipo_frete,'') AS tipo_frete, 
			COALESCE(nfe.vl_frete,0.00) AS vl_frete, 
			COALESCE(nfe.vl_seguro,0.00) AS vl_seguro, 
			COALESCE(nfe.vl_outras_despesas,0.00) AS vl_outras_despesas, 
			COALESCE(nfe.vl_base_calculo,0.00) as vl_base_calculo, 
			COALESCE(nfe.vl_icms,0.00) as vl_icms, 
			COALESCE(nfe.vl_base_calculo_st,0.00) as vl_base_calculo_st, 
			COALESCE(nfe.vl_icms_st,0.00) as vl_icms_st, 
			COALESCE(nfe.vl_ipi,0.00) vl_ipi, 
			COALESCE(nfe.vl_pis,0.00) as vl_pis, 
			COALESCE(nfe.vl_cofins,0.00) as vl_cofins, 
			COALESCE(nfe.vl_pis_st,0.00) as vl_pis_st, 
			COALESCE(nfe.vl_cofins_st,0.00) as vl_cofins_st, 
			COALESCE(nfe.vl_total,0.00) as vl_total, 	
			(
				COALESCE(nfe.vl_outras_despesas,0) + 
				COALESCE(nfe.vl_frete,0) +
				COALESCE(nfe.vl_seguro,0) + 
				COALESCE(nfe.vl_ipi,0) + 
				COALESCE(nfe.vl_icms_st,0)
			) as vl_para_rateio,
			nfe.id_natureza_operacao, 
			nfe.id_tipo_emissao, 
			nfe.id_tipo_ambiente, 
			nfe.id_transportador, 
			nfe.id_finalidade_emissao, 
			nfe.consumidor, 
			nfe.indfinal, 
			nfe.indpres, 
			nfe.iss_dcompet,
			CASE    WHEN nfe.cstat = '100' 		THEN '00'     	 
				WHEN nfe.cstat IN ('101','135') THEN '02'      	 
				WHEN nfe.cstat = '102' 		THEN '05'     	 
				ELSE '00'     
			END::character(2) AS cod_sit    
		FROM 
			sped_fiscal,
			f
			LEFT JOIN com_nf nfe
				ON nfe.codigo_filial = f.codigo_filial 
					AND nfe.codigo_empresa = f.codigo_empresa
			LEFT JOIN cliente 
				ON cliente.cnpj_cpf = nfe.cnpj_cpf_cliente
			
		WHERE 			
			nfe.data_emissao::date >= f.inicio
			AND nfe.data_emissao::date <= f.fim	
			AND nfe.cstat = '100'
		UNION 
		SELECT 	
			nfe.id_nf, 
			nfe.status, 
			nfe.codigo_empresa, 
			nfe.codigo_filial, 
			NULL as cnpj_cliente,
			NULL as codigo_cliente,
			nfe.modelo_doc_fiscal, 
			nfe.serie_doc,
			COALESCE(nfe.sub_serie,'') as sub_serie,
			nfe.numero_documento,
			CASE WHEN nfe.cstat = '102' THEN '' ELSE COALESCE(chave_eletronica,'') END::character(44) as chave_cte, 			
			null::date as data_emissao, 
			null::date as data_saida,
			nfe.data_cancelamento,
			nfe.motivo_cancelamento,
			NULL as tipo_pagamento,
			NULL::numeric(12,2) AS vl_desconto, 
			NULL::numeric(12,2) AS vl_abatimento_nt, 
			NULL::numeric(12,2) AS vl_mercadoria, 
			COALESCE(NULL,'') AS tipo_frete, 
			NULL::numeric(12,2) AS vl_frete, 
			NULL::numeric(12,2) AS vl_seguro, 
			NULL::numeric(12,2) AS vl_outras_despesas, 
			NULL::numeric(12,2) as vl_base_calculo, 
			NULL::numeric(12,2) as vl_icms, 
			NULL::numeric(12,2) as vl_base_calculo_st, 
			NULL::numeric(12,2) as vl_icms_st, 
			NULL::numeric(12,2) vl_ipi, 
			NULL::numeric(12,2) as vl_pis, 
			NULL::numeric(12,2) as vl_cofins, 
			NULL::numeric(12,2) as vl_pis_st, 
			NULL::numeric(12,2) as vl_cofins_st, 
			NULL::numeric(12,2) as vl_total, 	
			NULL::numeric(12,2) as vl_para_rateio,
			null::character(4) as id_natureza_operacao, 
			nfe.id_tipo_emissao, 
			nfe.id_tipo_ambiente, 
			nfe.id_transportador, 
			nfe.id_finalidade_emissao, 
			nfe.consumidor, 
			nfe.indfinal, 
			nfe.indpres, 
			nfe.iss_dcompet,
			CASE    WHEN nfe.cstat = '100' 		THEN '00'     	 
				WHEN nfe.cstat IN ('101','135') THEN '02'      	 
				WHEN nfe.cstat = '102' 		THEN '05'     	 
				ELSE '00'     
			END::character(2) AS cod_sit    
		FROM 
			sped_fiscal,
			f
			LEFT JOIN com_nf nfe
				ON nfe.codigo_filial = f.codigo_filial 
					AND nfe.codigo_empresa = f.codigo_empresa
			LEFT JOIN cliente 
				ON cliente.cnpj_cpf = nfe.cnpj_cpf_cliente			
		WHERE 			
			nfe.data_emissao::date >= f.inicio
			AND nfe.data_emissao::date <= f.fim	
			AND nfe.cstat IN ('101','102','135')  			
	)
	,nfe_itens AS (
		SELECT 
			i.id_nf_item, 
			i.id_nf, 
			i.descricao_complementar, 
			i.quantidade::integer as quantidade, 
			i.unidade as unidade, 
			COALESCE(i.vl_item,0.00) as vl_item, 
			COALESCE(i.vl_desconto,0.00) as vl_desconto, 
			i.movimentacao_fisica, 
			COALESCE(i.cst_icms,'') as cst_icms, 
			COALESCE(i.cfop,'') as cfop, 
			COALESCE(i.cod_natureza, '') as cod_natureza, 
			COALESCE(i.vl_base_icms,0.00) as vl_base_icms, 
			COALESCE(i.aliquota_icms,0.00) as aliquota_icms, 
			COALESCE(i.valor_icms,0.00) as valor_icms, 
			COALESCE(i.valor_base_icms_st,0.00) as valor_base_icms_st, 
			COALESCE(i.aliquota_icms_st,0.00) as aliquota_icms_st, 
			COALESCE(i.valor_icms_st,0.00) as valor_icms_st, 
			i.cst_ipi,
			COALESCE(i.cod_enq,'') as cod_enq, 
			COALESCE(i.vl_base_ipi,0.00) as vl_base_ipi, 
			COALESCE(i.aliquota_ipi,0.00) as aliquota_ipi, 
			COALESCE(i.vl_ipi,0.00) as vl_ipi, 			
			i.cst_pis as cst_pis, 			
			COALESCE(i.vl_base_pis,0.00) as vl_base_pis, 
			COALESCE(i.aliquota_pis_perc,0.00) as aliquota_pis_perc, 
			COALESCE(i.quantidade_base_pis,0) as quantidade_base_pis, 
			COALESCE(i.vl_aliquota_pis, 0.00) as vl_aliquota_pis,
			COALESCE(i.valor_pis,0.00) as valor_pis,			
			i.cst_cofins, 
			COALESCE(i.valor_base_cofins,0.00) as valor_base_cofins, 
			COALESCE(i.aliquota_cofins_perc,0.00) as aliquota_cofins_perc, 
			COALESCE(i.quantidade_base_cofins,0) as quantidade_base_cofins,
			COALESCE(i.vl_aliquota_cofins,0.00) as vl_aliquota_cofins, 
			COALESCE(i.vl_cofins,0.00) as vl_cofins, 
			COALESCE(i.vl_total,0.00) as vl_total, 
			COALESCE(i.vl_frete,0.00) as vl_frete, 			
			--Se tiver produto compartilhado por softwares de terceiros, uso o código do terceiro
			COALESCE(ecf_i.codigo_produto::integer, i.id_produto) as id_produto,
			COALESCE(ecf_i.id_produto_softlog,i.id_produto) as id_produto_softlog,
			nfe.vl_para_rateio,
			nfe.vl_mercadoria 
		FROM 
			nfe 
			LEFT JOIN com_nf_itens i
				ON nfe.id_nf = i.id_nf
			LEFT JOIN com_produtos 
				ON i.id_produto = com_produtos.id_produto 
			LEFT JOIN ecf_todos_produtos ecf_i 
				ON ecf_i.id_produto_softlog = i.id_produto
		WHERE
			nfe.cod_sit = '00'
			
		ORDER BY 
			id_nf, 
			id_nf_item
	)		
	-------------------------------------------------------------------------------------------------
	--- Valores NFe analitico
	-------------------------------------------------------------------------------------------------
	,nfe_analitico AS (
		WITH t AS (
			SELECT 
				id_nf,
				vl_para_rateio,
				vl_mercadoria,
				cst_icms, 
				cfop, 
				aliquota_icms, 
				SUM(vl_total) as total_valor_produto,
				SUM(vl_desconto) as total_valor_desconto, 															
				SUM(vl_base_icms) as total_vl_base_icms, 
				SUM(valor_icms) as total_valor_icms, 
				SUM(valor_base_icms_st) as total_valor_base_icms_st, 
				SUM(valor_icms_st) as total_valor_icms_st, 
				SUM(vl_ipi) as total_ipi 
			FROM 
				nfe_itens 			
			GROUP BY 
				id_nf,
				vl_para_rateio,
				vl_mercadoria,
				cst_icms, 
				cfop, 
				aliquota_icms 
			ORDER BY 
				id_nf,				
				cst_icms, 
				cfop, 
				aliquota_icms				
		)		
		SELECT 
			*,
			CASE
				WHEN total_valor_produto = 0 THEN 
					vl_para_rateio
				ELSE
					CASE 
						WHEN vl_para_rateio = 0 THEN 
							0
						ELSE
							(vl_para_rateio * (total_valor_produto*100)/vl_mercadoria)/100
					END
			END::numeric(12,2) as valor_ratear				
		FROM 
			t
		
	)	
	-------------------------------------------------------------------------------------------------
	--- Valores NFC 
	-------------------------------------------------------------------------------------------------
	,nfc AS (
		SELECT 
			nfc_100.* 
		FROM
			sped_fiscal
			LEFT JOIN filial
				ON sped_fiscal.codigo_filial = filial.codigo_filial
				AND sped_fiscal.codigo_empresa = filial.codigo_empresa
			LEFT JOIN efd_fiscal_bloco_ecf ecf
				ON filial.cnpj = ecf.cnpj
			LEFT JOIN v_efd_fiscal_bloco_c100 nfc_100
				ON nfc_100.id = ecf.id
				
		WHERE
			to_char(sped_fiscal.inicio,'DDMMYYYY') = ecf.periodo

		
	)
	-------------------------------------------------------------------------------------------------
	--- ANALITICO da NFC 
	-------------------------------------------------------------------------------------------------
	,nfc_analitico AS (
		SELECT 
			nfc_190.* 
		FROM
			sped_fiscal
			LEFT JOIN filial
				ON sped_fiscal.codigo_filial = filial.codigo_filial
				AND sped_fiscal.codigo_empresa = filial.codigo_empresa
			LEFT JOIN efd_fiscal_bloco_ecf ecf
				ON filial.cnpj = ecf.cnpj
			LEFT JOIN v_efd_fiscal_bloco_c100 nfc_100
				ON nfc_100.id = ecf.id
			LEFT JOIN v_efd_fiscal_bloco_c190 nfc_190
				ON nfc_190.id = nfc_100.id AND nfc_190.id_tb_100 = nfc_100.id_ord
				
		WHERE
			to_char(sped_fiscal.inicio,'DDMMYYYY') = ecf.periodo

		
	)	
	-------------------------------------------------------------------------------------------------
	--- Notas de Compra
	-------------------------------------------------------------------------------------------------
	,compras as (
		SELECT 			
			com_compras.id_compra, 
			com_compras.numero_compra, 
			com_compras.id_centro_custo, 
			com_compras.status, 
			com_compras.codigo_empresa, 
			com_compras.codigo_filial, 
			com_compras.cnpj_fornecedor, 
			fornecedores.id_fornecedor, 
			com_compras.tipo_documento, 
			com_compras.modelo_doc_fiscal, 
			coalesce(trim(com_compras.serie_doc,'')) as serie_doc, 
			trim(com_compras.numero_documento) as numero_documento, 
			COALESCE(com_compras.chave_nfe,'') as chave_nfe, 
			com_compras.data_emissao, 
			com_compras.data_entrada, 
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
			COALESCE(com_compras.vl_pis,0.00) as vl_pis, 
			COALESCE(com_compras.vl_confins,0.00) as vl_confins, 
			COALESCE(com_compras.vl_pis_st,0.00) as vl_pis_st, 
			COALESCE(com_compras.vl_cofins_st,0.00) as vl_cofins_st, 
			COALESCE(com_compras.vl_total,0.00) as vl_total, 
			COALESCE(trim(com_compras.sub_serie,'')) AS sub_serie,
			(
				COALESCE(com_compras.vl_outras_despesas,0) + 
				COALESCE(com_compras.vl_frete,0) +
				COALESCE(com_compras.vl_seguro,0) + 
				COALESCE(com_compras.vl_ipi,0) + 
				COALESCE(com_compras.vl_icms_st,0)
			) as vl_para_rateio
		FROM
			sped_fiscal,
			f
			LEFT JOIN com_compras 
				ON com_compras.codigo_filial = f.codigo_filial 
				AND com_compras.codigo_empresa = f.codigo_empresa				
			LEFT JOIN fornecedores 
				ON com_compras.cnpj_fornecedor = fornecedores.cnpj_cpf 
		WHERE 			
			data_entrada >= sped_fiscal.inicio
			AND data_entrada <= sped_fiscal.fim
			AND numero_compra IS NOT NULL
			AND modelo_doc_fiscal NOT IN ('00','06','10', '07', '57', '21', '22','28','29','02')
		ORDER BY 
			numero_compra 

	),	
	compras_itens AS (
		SELECT 
			ci.id_compra_item, 
			ci.id_compra, 
			ci.codigo_produto,			 
			ci.descricao_complementar, 
			ci.quantidade, 
			COALESCE(efd_unidades_medida.unidade, ci.unidade,'UN') as unidade, 
			COALESCE(ci.vl_item,0.00) as vl_item, 
			COALESCE(ci.vl_desconto,0.00) as vl_desconto, 
			ci.movimentacao_fisica, 
			COALESCE(ci.cst_icms,'') as cst_icms, 
			COALESCE(ci.cfop,'') as cfop, 
			COALESCE(ci.cod_natureza, '') as cod_natureza, 
			COALESCE(ci.vl_base_icms,0.00) as vl_base_icms, 
			COALESCE(ci.aliquota_icms,0.00) as aliquota_icms, 
			COALESCE(ci.valor_icms,0.00) as valor_icms, 
			COALESCE(ci.valor_base_icms_st,0.00) as valor_base_icms_st, 
			COALESCE(ci.aliquota_icms_st,0.00) as aliquota_icms_st, 
			COALESCE(ci.valor_icms_st,0.00) as valor_icms_st, 
			COALESCE('02','02') as cst_ipi,
			COALESCE(ci.cod_enq,'') as cod_enq, 
			COALESCE(ci.vl_base_ipi,0.00) as vl_base_ipi, 
			COALESCE(ci.aliquota_ipi,0.00) as aliquota_ipi, 
			COALESCE(ci.vl_ipi,0.00) as vl_ipi, 
			
			COALESCE(ci.cst_pis,'70') as cst_pis, 			
			COALESCE(ci.vl_base_pis,0.00) as vl_base_pis, 
			COALESCE(ci.aliquota_pis_perc,0.00) as aliquota_pis_perc, 
			COALESCE(ci.quantidade_base_pis,0) as quantidade_base_pis, 
			COALESCE(ci.vl_aliquota_pis, 0.00) as vl_aliquota_pis,
			COALESCE(ci.valor_pis,0.00) as valor_pis,
			
			COALESCE(ci.cst_cofins,'70') as cst_cofins, 
			COALESCE(ci.vl_base_cofins,0.00) as valor_base_cofins, 
			COALESCE(ci.aliquota_cofins_perc,0.00) as aliquota_cofins_perc, 
			COALESCE(ci.quantidade_base_cofins,0) as quantidade_base_cofins,
			COALESCE(ci.vl_aliquota_cofins,0.00) as vl_aliquota_cofins, 
			COALESCE(ci.valor_cofins,0.00) as vl_cofins, 
			COALESCE(ci.vl_total,0.00) as vl_total, 
			COALESCE(ci.observacao,'') as observacao, 
			--Se tiver produto compartilhado por softwares de terceiros, uso o código do terceiro
			COALESCE(ecf_i.codigo_produto::integer, ci.id_produto) as id_produto,
			COALESCE(ecf_i.id_produto_softlog,ci.id_produto) as id_produto_softlog,
			c.vl_para_rateio,
			c.vl_mercadoria 
		FROM 
			compras c 
			LEFT JOIN v_com_compras_itens ci
				ON c.id_compra = ci.id_compra
			LEFT JOIN com_produtos 
				ON ci.id_produto = com_produtos.id_produto 
			LEFT JOIN efd_unidades_medida 
				ON com_produtos.id_unidade  = efd_unidades_medida.id_unidade 
			LEFT JOIN ecf_todos_produtos ecf_i 
				ON ecf_i.id_produto_softlog = ci.id_produto
		ORDER BY 
			id_compra, 
			id_compra_item
	)
	-------------------------------------------------------------------------------------------------
	--- Valor do PIS e do COFINS por compra
	-------------------------------------------------------------------------------------------------
	,nfes_pis_cofins AS (
		SELECT 
			id_compra,
			SUM(valor_pis) 	as valor_pis,
			SUM(vl_cofins)	as valor_cofins
		FROM 
			compras_itens
		GROUP BY
			id_compra
		ORDER BY
			id_compra
	)
	-------------------------------------------------------------------------------------------------
	--- Valores compras analitico
	-------------------------------------------------------------------------------------------------
	,compras_analitico AS (
		WITH t AS (
			SELECT 
				id_compra,
				vl_para_rateio,
				vl_mercadoria,
				cst_icms, 
				cfop, 
				aliquota_icms, 
				SUM(vl_total) as total_valor_produto,
				SUM(vl_desconto) as total_valor_desconto, 															
				SUM(vl_base_icms) as total_vl_base_icms, 
				SUM(valor_icms) as total_valor_icms, 
				SUM(valor_base_icms_st) as total_valor_base_icms_st, 
				SUM(valor_icms_st) as total_valor_icms_st, 
				SUM(vl_ipi) as total_ipi 
			FROM 
				compras_itens 			
			GROUP BY 
				id_compra,
				vl_para_rateio,
				vl_mercadoria,
				cst_icms, 
				cfop, 
				aliquota_icms 
			ORDER BY 
				id_compra,				
				cst_icms, 
				cfop, 
				aliquota_icms				
		)		
		SELECT 
			*,
			CASE
				WHEN total_valor_produto = 0 THEN 
					vl_para_rateio
				ELSE
					CASE 
						WHEN vl_para_rateio = 0 THEN 
							0
						ELSE
							(vl_para_rateio * (total_valor_produto*100)/vl_mercadoria)/100
					END
			END::numeric(12,2) as valor_ratear				
		FROM 
			t
		
	)
	-------------------------------------------------------------------------------------------------
	--- Contas de Energia, Agua, Gas
	-------------------------------------------------------------------------------------------------
	,contas_consumo as (
		SELECT 			
			com_compras.id_compra, 
			com_compras.numero_compra, 			
			com_compras.codigo_empresa, 
			com_compras.codigo_filial, 
			com_compras.cnpj_fornecedor, 
			fornecedores.id_fornecedor, 
			com_compras.modelo_doc_fiscal, 
			coalesce(trim(com_compras.serie_doc,'')) as serie_doc, 			
			COALESCE(trim(com_compras.sub_serie,'')) AS sub_serie,
			trim(com_compras.numero_documento) as numero_documento, 
			com_compras.data_emissao, 
			com_compras.data_entrada,			
			COALESCE(cod_consumo_energia,'')::text as cod_consumo_energia,
			COALESCE(cod_grupo_tensao,'')::text as cod_grupo_tensao,
			COALESCE(cod_consumo_agua,'')::text as cod_consumo_agua,
			COALESCE(tp_ligacao,'')::text as tp_ligacao,
			COALESCE(tp_assinante,'')::text as tp_assinante,
			COALESCE(com_compras.vl_desconto,0.00) AS vl_desconto, 
			COALESCE(com_compras.vl_abatimento_nt,0.00) AS vl_abatimento_nt, 
			COALESCE(com_compras.vl_mercadoria,0.00) AS vl_mercadoria, 
			COALESCE(com_compras.vl_serv_nt,0.00) AS vl_serv_nt, 
			COALESCE(com_compras.vl_terc,0.00) AS vl_terc, 		
			COALESCE(com_compras.tipo_frete,'') AS tipo_frete, 
			COALESCE(com_compras.vl_frete,0.00) AS vl_frete, 
			COALESCE(com_compras.vl_seguro,0.00) AS vl_seguro, 
			COALESCE(com_compras.vl_outras_despesas,0.00) AS vl_outras_despesas, 
			COALESCE(com_compras.vl_base_calculo,0.00) as vl_base_calculo, 
			COALESCE(com_compras.vl_icms,0.00) as vl_icms, 
			COALESCE(com_compras.vl_base_calculo_st,0.00) as vl_base_calculo_st, 
			COALESCE(com_compras.vl_icms_st,0.00) as vl_icms_st, 
			COALESCE(com_compras.vl_ipi,0.00) vl_ipi, 
			COALESCE(com_compras.vl_pis,0.00) as vl_pis, 
			COALESCE(com_compras.vl_confins,0.00) as vl_confins, 
			COALESCE(com_compras.vl_pis_st,0.00) as vl_pis_st, 
			COALESCE(com_compras.vl_cofins_st,0.00) as vl_cofins_st, 
			COALESCE(com_compras.vl_total,0.00) as vl_total, 		
			(
				COALESCE(com_compras.vl_outras_despesas,0) +  								
				COALESCE(com_compras.vl_icms_st,0)
			) as vl_para_rateio
		FROM
			sped_fiscal,
			f
			LEFT JOIN com_compras 
				ON com_compras.codigo_filial = f.codigo_filial 
				AND com_compras.codigo_empresa = f.codigo_empresa				
			LEFT JOIN fornecedores 
				ON com_compras.cnpj_fornecedor = fornecedores.cnpj_cpf 
		WHERE 			
			data_entrada >= sped_fiscal.inicio
			AND data_entrada <= sped_fiscal.fim
			AND numero_compra IS NOT NULL
			AND modelo_doc_fiscal IN ('06','28','29')
		ORDER BY 
			numero_compra 
	) 
	-------------------------------------------------------------------------------------------------
	--- Valor PIS COFINS Contas de Energia, Agua, Gas
	-------------------------------------------------------------------------------------------------
	,contas_consumo_pis_cofins AS (
		SELECT
			contas_consumo.id_compra,
			SUM(ci.valor_pis) as vl_pis,
			SUM(ci.valor_cofins) as vl_cofins
		FROM
			contas_consumo
			LEFT JOIN v_com_compras_itens ci 
				ON ci.id_compra = contas_consumo.id_compra
		GROUP BY 
			contas_consumo.id_compra
	) 
	-------------------------------------------------------------------------------------------------
	--- Valores compras analitico
	-------------------------------------------------------------------------------------------------
	,contas_consumo_analitico AS (
		WITH t AS (
			SELECT 
				cc.id_compra,
				cc.vl_para_rateio,
				cc.vl_mercadoria,
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms, 
				SUM(ci.vl_total) as total_valor_produto,
				SUM(ci.vl_desconto) as total_valor_desconto, 															
				SUM(ci.vl_base_icms) as total_vl_base_icms, 
				SUM(ci.valor_icms) as total_valor_icms, 
				SUM(ci.valor_base_icms_st) as total_valor_base_icms_st, 
				SUM(ci.valor_icms_st) as total_valor_icms_st, 
				SUM(ci.vl_ipi) as total_ipi 
			FROM 
				contas_consumo cc
				LEFT JOIN v_com_compras_itens ci
					ON ci.id_compra = cc.id_compra
			GROUP BY 
				cc.id_compra,
				cc.vl_para_rateio,
				cc.vl_mercadoria,
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms 
			ORDER BY 
				cc.id_compra,				
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms				
		)		
		SELECT 
			*,
			CASE
				WHEN total_valor_produto = 0 THEN 
					vl_para_rateio
				ELSE
					CASE 
						WHEN vl_para_rateio = 0 THEN 
							0
						ELSE
							(vl_para_rateio * (total_valor_produto*100)/vl_mercadoria)/100
					END
			END::numeric(12,2) as valor_ratear				
		FROM 
			t
		
	)	
	-------------------------------------------------------------------------------------------------
	--- Contas de Telefone
	-------------------------------------------------------------------------------------------------	
	,telefone AS (
		SELECT 	
			0::integer as ind_oper, 	
			1::integer as ind_emit,
			com_compras.modelo_doc_fiscal, 	
			TRIM(COALESCE(com_compras.serie_doc,'')) as serie_doc,
			TRIM(COALESCE(com_compras.sub_serie,'')) as sub_serie, 	
			com_compras.numero_compra,
			null::integer as modal, 	
			com_compras.id_compra, 	
			com_compras.cnpj_fornecedor as cnpj_cpf, 	
			fornecedores.id_fornecedor, 
			com_compras.tp_assinante,
			null::integer as id_endereco_tomador, 	
			cidades.cod_ibge,
			com_compras.data_emissao,
			com_compras.data_entrada, 	
			null::integer as cancelado,
			com_compras.numero_documento,
			COALESCE(com_compras_itens.cfop,'') as cod_operacao_fiscal,
			COALESCE(com_compras_itens.cst_icms,'') as cst_icms,
			'00' as cod_sit,
			COALESCE(com_compras.vl_desconto,0.00) as vl_desconto,
			COALESCE(com_compras.vl_abatimento_nt,0.00) as vl_abatimento_nt,
			COALESCE(com_compras.vl_mercadoria,0.00) as vl_mercadoria,    
			COALESCE(com_compras.vl_serv_nt,0.00) AS vl_serv_nt, 
			COALESCE(com_compras.vl_terc,0.00) AS vl_terc, 		
			COALESCE(com_compras_itens.cst_icms,'') as cst, 	
			COALESCE(com_compras.vl_seguro,0.00) as vl_seguro, 	
			COALESCE(com_compras.vl_outras_despesas,0.00) as vl_outras_despesas, 	
			COALESCE(com_compras.vl_base_calculo,0.00) as vl_base_calculo, 	
			COALESCE(com_compras.vl_icms,0.00) as vl_icms, 	
			COALESCE(com_compras.vl_base_calculo_st, 0.00) as vl_base_calculo_st, 	
			COALESCE(com_compras.vl_icms_st,0.00) as vl_icms_st, 	
			COALESCE(com_compras.vl_ipi,0.00) as vl_ipi, 	
			COALESCE(com_compras.vl_pis,0.00) as vl_pis, 	
			COALESCE(com_compras.vl_confins,0.00) as vl_confins, 	
			COALESCE(com_compras.vl_pis_st,0.00) as vl_pis_st, 	
			COALESCE(com_compras.vl_cofins_st,0.00) as vl_cofins_st, 	
			COALESCE(com_compras.vl_total,0.00) as vl_total, 					
			COALESCE(com_compras_itens.aliquota_icms,0.00)::numeric(12,2) as aliquota, 				
			(
				COALESCE(com_compras.vl_outras_despesas,0) +  								
				COALESCE(com_compras.vl_icms_st,0)
			) as vl_para_rateio
		FROM 	
			sped_fiscal,
			f
			LEFT JOIN com_compras 	
				ON com_compras.codigo_empresa = f.codigo_empresa AND
					com_compras.codigo_filial = f.codigo_filial
			LEFT JOIN fornecedores 
				ON com_compras.cnpj_fornecedor = fornecedores.cnpj_cpf 	
			LEFT JOIN cidades 
				ON fornecedores.id_cidade::integer = cidades.id_cidade::integer 	
			LEFT JOIN com_compras_itens 
				ON com_compras_itens.id_compra = com_compras.id_compra 
		WHERE 	
			com_compras.modelo_doc_fiscal IN ('21','22') 	
			AND data_entrada IS NOT NULL 	
			AND ((data_entrada::date >= sped_fiscal.inicio AND data_entrada::date <= sped_fiscal.fim)) 
		ORDER BY 
			numero_documento 
	) 
	-------------------------------------------------------------------------------------------------
	--- Valor PIS COFINS Contas de Telefone
	-------------------------------------------------------------------------------------------------
	,telefone_pis_cofins AS (
		SELECT
			telefone.id_compra,
			SUM(ci.valor_pis) as vl_pis,
			SUM(ci.valor_cofins) as vl_cofins
		FROM
			telefone
			LEFT JOIN v_com_compras_itens ci 
				ON ci.id_compra = telefone.id_compra
		GROUP BY 
			telefone.id_compra
	) 
	-------------------------------------------------------------------------------------------------
	--- Valores telefone analitico
	-------------------------------------------------------------------------------------------------
	,telefone_analitico AS (
		WITH t AS (
			SELECT 
				t.id_compra,
				t.vl_para_rateio,
				t.vl_mercadoria,
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms, 
				SUM(ci.vl_total) as total_valor_produto,
				SUM(ci.vl_desconto) as total_valor_desconto, 															
				SUM(ci.vl_base_icms) as total_vl_base_icms, 
				SUM(ci.valor_icms) as total_valor_icms, 
				SUM(ci.valor_base_icms_st) as total_valor_base_icms_st, 
				SUM(ci.valor_icms_st) as total_valor_icms_st	
			FROM 
				telefone t
				LEFT JOIN v_com_compras_itens ci
					ON ci.id_compra = t.id_compra
			GROUP BY 
				t.id_compra,
				t.vl_para_rateio,
				t.vl_mercadoria,
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms 
			ORDER BY 
				t.id_compra,				
				ci.cst_icms, 
				ci.cfop, 
				ci.aliquota_icms				
		)		
		SELECT 
			*,
			CASE
				WHEN total_valor_produto = 0 THEN 
					vl_para_rateio
				ELSE
					CASE 
						WHEN vl_para_rateio = 0 THEN 
							0
						ELSE
							(vl_para_rateio * (total_valor_produto*100)/vl_mercadoria)/100
					END
			END::numeric(12,2) as valor_ratear				
		FROM 
			t
		
	)
	-------------------------------------------------------------------------------------------------
	--- Dados para o Bloco H - Inventário                                                          --	
	-------------------------------------------------------------------------------------------------
	--- Relação para trazer inventario                                                             --
	-------------------------------------------------------------------------------------------------
	,inf_inventario AS (
		SELECT 
			codigo_empresa,
			codigo_filial,
			fim as data_inventario
		FROM 
			sped_fiscal
		WHERE 
			tem_inventario = 1
			
	)
	-------------------------------------------------------------------------------------------------
	--- Processamento do Estoque na data do Inventário                                
	-------------------------------------------------------------------------------------------------
	,estoque_atual AS (
		SELECT 
			com_produtos.id_produto,
			com_produtos.descr_item,
			com_produtos.id_unidade,
			sum(CASE 
					WHEN com_op_estoque.credito_debito = 1
						THEN COALESCE(estoque_movimentacao.quantidade_mov, 0::NUMERIC)
					ELSE 0::NUMERIC
					END
			)::NUMERIC(12, 3) AS qtd_entrada,
			sum(CASE 
					WHEN com_op_estoque.credito_debito = 2
						THEN COALESCE(estoque_movimentacao.quantidade_mov, 0::NUMERIC)
					ELSE 0::NUMERIC
					END
			)::NUMERIC(12, 3) AS qtd_saida,
			COALESCE(com_produtos.valor_custo, 0.00)::NUMERIC(12, 2) AS valor_produto
		FROM 	
			com_produtos					
			LEFT JOIN estoque_movimentacao USING (id_produto)
			LEFT JOIN com_op_estoque
				ON estoque_movimentacao.id_operacao = com_op_estoque.id_operacao
			LEFT JOIN almoxarifado a
				ON a.id_almoxarifado = estoque_movimentacao.id_almoxarifado	
			RIGHT JOIN inf_inventario i
				ON i.codigo_empresa = a.cod_empresa AND i.codigo_filial = a.cod_filial
		WHERE
			data_mov::date <= i.data_inventario
			AND com_produtos.tipo_item <> '09'
		GROUP BY 
			com_produtos.id_produto
		ORDER BY 
			com_produtos.id_produto		
	)
	,estoque_calculo AS (
		SELECT 
			COALESCE(ecf_i.codigo_produto::integer, estoque_atual.id_produto) as id_produto,
			COALESCE(ecf_i.id_produto_softlog,estoque_atual.id_produto) as id_produto_softlog,
			estoque_atual.descr_item,
			efd_unidades_medida.id_unidade,		
			efd_unidades_medida.unidade,
			(estoque_atual.qtd_entrada - estoque_atual.qtd_saida)::NUMERIC(12, 3) AS qtd_estoque_atual,
			estoque_atual.valor_produto		
		FROM 
			estoque_atual
			LEFT JOIN efd_unidades_medida USING (id_unidade)		
			LEFT JOIN ecf_todos_produtos ecf_i 
				ON ecf_i.id_produto_softlog = estoque_atual.id_produto
			
	)	
	,estoque AS (
		SELECT 
			*,
			(valor_produto * qtd_estoque_atual)::numeric(12,2) as valor_estoque
		FROM 
			estoque_calculo
		WHERE qtd_estoque_atual > 0
	)
	,total_estoque AS (
		SELECT 
			inf_inventario.codigo_empresa,
			inf_inventario.codigo_filial,
			inf_inventario.data_inventario,
			SUM(valor_estoque)::numeric(12,2) as total_estoque
		FROM 
			inf_inventario,
			estoque
		GROUP BY
			inf_inventario.codigo_empresa,
			inf_inventario.codigo_filial,
			inf_inventario.data_inventario
			
	)
	,participantes AS (
		--Servicos de transportes prestados
		SELECT 
			'C' || lpad(cliente.codigo_cliente::text,7,'0') as cod_part, 
			cliente.nome_cliente as nome, 
			cliente.cnpj_cpf, 
			CASE 
				WHEN char_length(cliente.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(cliente.inscricao_estadual) = 'ISENTO' 
				THEN '' 
				ELSE cliente.inscricao_estadual 
			END::character(15)  as inscricao_estadual, 
			cidades.cod_ibge, 
			cliente.endereco, 
			cliente.numero, 
			cliente.bairro 
		FROM 	
			cliente
			LEFT JOIN cidades 
				ON cliente.id_cidade = cidades.id_cidade 
			WHERE
				EXISTS(	SELECT 1
					FROM c
					WHERE c.codigo_participante = cliente.codigo_cliente
						AND c.ind_oper = '1'
				)
			GROUP BY
				cliente.codigo_cliente,
				cidades.id_cidade		
						
		UNION 
		--Servicos de Transportes Adiquiridos 
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
				EXISTS(	SELECT 1
					FROM c
					WHERE c.codigo_participante = fornecedores.id_fornecedor
						AND c.ind_oper = '0'
				)
			GROUP BY
				fornecedores.id_fornecedor,
				cidades.id_cidade		
						
		UNION 
		--Fornecedores de Produtos
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
				WHERE fornecedores.id_fornecedor = compras.id_fornecedor
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		--Fornecedores de Telefonia
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
				WHERE fornecedores.id_fornecedor = telefone.id_fornecedor
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		--Fornecedores de Contas de Consumo
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
				WHERE fornecedores.id_fornecedor = contas_consumo.id_fornecedor
				)
		GROUP BY
			fornecedores.id_fornecedor,
			cidades.id_cidade		
		UNION 
		SELECT 
			'C' || lpad(cliente.codigo_cliente::text,7,'0') as cod_part, 
			cliente.nome_cliente as nome, 
			cliente.cnpj_cpf, 
			CASE 
				WHEN char_length(cliente.cnpj_cpf) = 14 
				THEN 1 ELSE 2 
			END as tipo_pessoa, 
			CASE 
				WHEN TRIM(cliente.inscricao_estadual) = 'ISENTO' 
				THEN '' 
				ELSE cliente.inscricao_estadual 
			END::character(15)  as inscricao_estadual, 
			cidades.cod_ibge, 
			cliente.endereco, 
			cliente.numero, 
			cliente.bairro 
		FROM 	
			cliente
			LEFT JOIN cidades 
				ON cliente.id_cidade = cidades.id_cidade 
			WHERE
				EXISTS(	SELECT 1
					FROM nfe
					WHERE nfe.codigo_cliente = cliente.codigo_cliente
				)
			GROUP BY
				cliente.codigo_cliente,
				cidades.id_cidade				

		
	) 
	,unidades AS (
		SELECT 	
			upper(compras_itens.unidade) as unidade, 	
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
			upper(compras_itens.unidade)
		UNION 
		SELECT 	
			upper(efd_unidades_medida.unidade) as unidade, 	
			upper(efd_unidades_medida.descricao) as descricao
		FROM 	
			f, efd_unidades_medida
		WHERE
			f.cod_item_1400_sped_fiscal IS NOT NULL AND efd_unidades_medida.unidade = 'UN'		
		
-- 		UNION 
-- 		SELECT 	
-- 			upper(nfe_itens.unidade) as unidade, 	
-- 			MAX(
-- 				CASE WHEN TRIM(UPPER(descricao)) = TRIM(UPPER(nfe_itens.unidade)) 
-- 					THEN descricao || ' Desc' 
-- 					ELSE descricao 
-- 				END
-- 			)::text as descricao
-- 		FROM 	
-- 			nfe_itens
-- 				LEFT JOIN efd_unidades_medida
-- 					ON efd_unidades_medida.unidade = nfe_itens.unidade			
-- 		GROUP BY 	
-- 			upper(nfe_itens.unidade)
		UNION 		
		SELECT 	
			upper(estoque.unidade) as unidade, 	
			MAX(
				CASE WHEN TRIM(UPPER(descricao)) = TRIM(UPPER(estoque.unidade)) 
					THEN descricao || ' Desc' 
					ELSE descricao 
				END
			)::text as descricao 
		FROM 	
			estoque
				LEFT JOIN efd_unidades_medida
					ON efd_unidades_medida.unidade = estoque.unidade			
		GROUP BY 	
			upper(estoque.unidade)
		UNION
		SELECT 	
			upper(c_ecf_und.unidade) as unidade, 	
			(CASE 	WHEN TRIM(UPPER(descricao)) = TRIM(UPPER(c_ecf_und.unidade)) 
				THEN descricao || ' Desc' 
					ELSE descricao 
				END
			)::text as descricao 
		FROM 	
			c_ecf_und
				LEFT JOIN efd_unidades_medida
					ON efd_unidades_medida.unidade = c_ecf_und.unidade			

	) 
	,produtos AS (
		WITH t AS (
			SELECT 
				id_produto_softlog as id_produto
			FROM
				compras_itens
			GROUP BY 
				id_produto_softlog
--			UNION
-- 			SELECT 
-- 				id_produto_softlog as id_produto
-- 			FROM
-- 				nfe_itens
-- 			GROUP BY 
-- 				id_produto_softlog
			UNION 
			SELECT 
				cod_item_1400_sped_fiscal as id_produto
			FROM 
				f
			WHERE
				f.cod_item_1400_sped_fiscal IS NOT NULL
			UNION 
			SELECT
				id_produto_softlog as id_produto
			FROM 
				estoque
			GROUP BY 
				id_produto_softlog
			UNION 				
			SELECT 
				id_produto_softlog as id_produto
			FROM
				c_ecf_itens			
				
		)
		SELECT 	
			'P' || lpad(COALESCE(ecf_i.codigo_produto::text,com_produtos.id_produto::text),7,'0') as id_produto,	
			COALESCE(trim(descr_item),'') as descr_item, 	
			COALESCE(trim(cod_barra),'') as cod_barra, 	
			COALESCE(trim(efd_unidades_medida.unidade),'') as unidade, 	
			COALESCE(trim(tipo_item),'07')::character(2) as tipo_item, 	
			COALESCE(aliquota_icms,0.00) as aliquota_icms, 	
			COALESCE(trim(codigo_mercosul),'') as codigo_mercosul, 	
			COALESCE(trim(codigo_ex),'') as codigo_ex, 	
			COALESCE(trim(codigo_genero),'') as codigo_genero, 	
			COALESCE(trim(codigo_servico),'') as codigo_servico,
			''::text as cest 
		FROM 	
			com_produtos 	
			LEFT JOIN efd_unidades_medida 
				ON com_produtos.id_unidade = efd_unidades_medida.id_unidade 
			LEFT JOIN ecf_todos_produtos ecf_i 
				ON ecf_i.id_produto_softlog = com_produtos.id_produto

		WHERE 	
			EXISTS (SELECT 	1
				FROM 	t
				WHERE 	t.id_produto = com_produtos.id_produto)
			
			
	)
	,totais_bloco_1000 AS (
		WITH t AS (
			SELECT 0, 1 as qt FROM c_aereo WHERE c_aereo.qt_aereo > 0 UNION 
			SELECT 1, 3 as qt UNION 
			SELECT 2, count(*) as qt FROM registro_1400 			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_h000 AS (
		WITH t AS (
			SELECT 1,2 as qt UNION 
			SELECT 2,count(*) as qt FROM total_estoque UNION 
			SELECT 3,count(*) as qt FROM estoque 
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_e000 AS (
		WITH t AS (
			SELECT 1, 6 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_d000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM c UNION
			SELECT 2, count(*) as qt FROM c_analitico UNION
			SELECT 3, count(*) as qt FROM telefone UNION
			SELECT 4, count(*) as qt FROM telefone_analitico UNION 
			SELECT 5, 2 as qt
		)
		SELECT sum(qt) as total FROM t
	)
	,totais_bloco_c000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM compras UNION
			SELECT 2, count(*) as qt FROM compras_itens UNION
			SELECT 3, count(*) as qt FROM compras_analitico UNION 	
			SELECT 4, count(*) as qt FROM contas_consumo UNION
			SELECT 5, count(*) as qt FROM contas_consumo_analitico UNION 		
			SELECT 6, count(*) as qt FROM nfe UNION
			--SELECT 7, count(*) as qt FROM nfe_itens UNION
			SELECT 8, count(*) as qt FROM nfe_analitico UNION 	
			SELECT 9, COALESCE(qt_linhas,0) as qt FROM c_ecf UNION
			SELECT 10, 2 as qt UNION 
			SELECT 11, count(*) as qt FROM nfc UNION 	
			SELECT 12, count(*) as qt FROM nfc_analitico 
		)
		SELECT sum(qt) as total FROM t
	)	
	,totais_bloco_0000 AS (
		WITH t AS (
			SELECT 1, count(*) as qt FROM f UNION
			SELECT 2, count(*) as qt FROM contador UNION
			SELECT 3, count(*) as qt FROM participantes UNION 
			SELECT 4, count(*) as qt FROM unidades UNION 
			SELECT 5, count(*) as qt FROM produtos UNION
			SELECT 6, 3 as qt	   			
		)
		SELECT sum(qt) as total FROM t
	)	
	-------------------------------------------------------------------------------------------------
	--- Montagem dados do SPED em um valor do tipo JSON                                                           
	-------------------------------------------------------------------------------------------------

	
	-------------------------------------------------------------------------------------------------
	--- BLOCO 1
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
	,reg_1800 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1800' as reg,
					0::numeric(12,2) as vl_carga,
					0::numeric(12,2) as vl_pass,
					0::numeric(12,2) as vl_fat,
					0::numeric(12,2) as ind_rateio,
					0::numeric(12,2) as vl_icms_ant,
					0::numeric(12,2) as vl_bc_icms,
					0::numeric(12,2) as vl_icms_apur,
					0::numeric(12,2) as vl_bc_icms_apur,
					0::numeric(12,2) as vl_dif									
				FROM 
					c_aereo
				WHERE
					c_aereo.qt_aereo > 0 
				) row
		)
		SELECT array_agg(json) as reg_1800 from temp
	)	
	,reg_1400 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1400' as reg,
					'P' || lpad(cod_item_1400_sped_fiscal::text,7,'0') as cod_item_ipm,
					cod_ibge as mun,
					total_mun as valor					
				FROM 
					registro_1400
				) row
		)
		SELECT array_agg(json) as reg_1400 from temp
	)
	,reg_1010 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1010' AS reg,
					'N'::text as ind_exp,
					'N'::text as ind_ccrf,
					'N'::text as ind_comb,
					'N'::text as ind_usina,
					CASE 	WHEN f.flg_item_1400_sped_fiscal = 0 
						THEN 'N'
						ELSE 'S'
					END::text as ind_va,
					'N'::text as ind_ee,
					'N'::text as ind_cart,
					'N'::text as ind_form,
					CASE 	WHEN c_aereo.qt_aereo > 0 
						THEN 'S' 
						ELSE 'N' 
					END::text as ind_aer						
				FROM
					f, c_aereo
			) row
		)
		SELECT array_agg(json) as reg_1010 from temp
	)
	,reg_1001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'1001' as reg,
					'0' as ind_mov,
					reg_1010.reg_1010,
					reg_1400.reg_1400,
					reg_1800.reg_1800,
					reg_1990.reg_1990										
				FROM					
					reg_1990,
					reg_1010,
					reg_1400,
					reg_1800
				) row
		)
		SELECT array_agg(json) as reg_1001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO B
	-------------------------------------------------------------------------------------------------	
	,reg_b990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'B990' as reg,
					2 as qtd_li_b
				) row
		)
		SELECT array_agg(json) as reg_b990 from temp
	)
	,reg_b001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'B001' as reg,
					'1' as ind_mov,
					reg_b990.reg_b990
				FROM					
					reg_b990
				) row
		)
		SELECT array_agg(json) as reg_b001 from temp
	) 
	-------------------------------------------------------------------------------------------------
	--- BLOCO K
	-------------------------------------------------------------------------------------------------	
	,reg_k990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'K990' as reg,
					2 as qtd_li_k				
				) row
		)
		SELECT array_agg(json) as reg_k990 from temp
	)
	,reg_k001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'K001' as reg,
					'1' as ind_mov,
					reg_k990.reg_k990
				FROM					
					reg_k990
				) row
		)
		SELECT array_agg(json) as reg_k001 from temp
	) 
	-------------------------------------------------------------------------------------------------
	--- BLOCO H
	-------------------------------------------------------------------------------------------------	
	,reg_h990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'H990' as reg,
					totais_bloco_h000.total as qtd_li_h
				FROM 
					totais_bloco_h000
				) row
		)
		SELECT array_agg(json) as reg_h990 from temp
	)
	,reg_h010 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'H010' as reg,
					'P' || lpad(id_produto::text,7,'0') as cod_item,
					trim(unidade) as unid,
					qtd_estoque_atual::numeric(12,3) as qtd,
					valor_produto::numeric(12,6) as vl_unit,
					valor_estoque::numeric(12,2) as vl_item,
					'0'::text as ind_prod,
					''::text as cod_part,
					''::text as txt_compl,
					''::text as cod_cta,
					valor_estoque as vl_item_ir					
				FROM					
					estoque
				) row
		)
		SELECT array_agg(json) as reg_h010 from temp
	) 
	,reg_h005 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'H005' as reg,
					to_char(data_inventario,'DDMMYYYY') as dt_inv,
					total_estoque as vl_inv,
					'01' as mot_inv,
					reg_h010.reg_h010
				FROM	
					total_estoque,
					reg_h010
					
				) row
		)
		SELECT array_agg(json) as reg_h005 from temp
	)
	,reg_h001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'H001' as reg,
					CASE 	WHEN COALESCE(reg_h005.reg_h005, NULL) IS NULL 
						THEN '1'
						ELSE '0'
					END::text as ind_mov,					
					reg_h005.reg_h005,
					reg_h990.reg_h990
				FROM
					reg_h005,
					reg_h990
				) row
		)
		SELECT array_agg(json) as reg_h001 from temp
	) 
	-------------------------------------------------------------------------------------------------
	--- BLOCO G
	-------------------------------------------------------------------------------------------------	
	,reg_g990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'G990' as reg,
					2 as qtd_li_g				
				) row
		)
		SELECT array_agg(json) as reg_g990 from temp
	)
	,reg_g001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'G001' as reg,
					'1' as ind_mov,
					reg_g990.reg_g990
				FROM					
					reg_g990
				) row
		)
		SELECT array_agg(json) as reg_g001 from temp
	)
	-------------------------------------------------------------------------------------------------
	--- BLOCO E
	-------------------------------------------------------------------------------------------------	
	,reg_e990 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E990' as reg,
					totais_bloco_e000.total as qtd_li_e
				FROM 
					totais_bloco_e000
				) row
		)
		SELECT array_agg(json) as reg_e990 from temp
	)
	,reg_e210 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E210' AS reg,
					'0'::character(1) as ind_mov_st,
					0::numeric(12,2) as vl_sld_cred_ant_st,
					0::numeric(12,2) as vl_devol_st,
					0::numeric(12,2) as vl_ressarc_st,
					0::numeric(12,2) as vl_out_cred_st,
					0::numeric(12,2) as vl_aj_creditos_st,
					0::numeric(12,2) as vl_retencao_st,
					0::numeric(12,2) as vl_out_deb_st,
					0::numeric(12,2) as vl_aj_debitos_st,
					0::numeric(12,2) as vl_sld_dev_ant_st,
					0::numeric(12,2) as vl_deducoes_st,
					0::numeric(12,2) as vl_icms_recol_st,
					0::numeric(12,2) as vl_sld_cred_st_transportar,					
					0::numeric(12,2) as deb_esp		
				
			) row
		)
		SELECT array_agg(json) as reg_e210 from temp
	)
	,reg_e200 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E200' AS reg,
					f.uf as uf,
					to_char(sped_fiscal.inicio,'DDMMYYYY') as dt_ini,
					to_char(sped_fiscal.fim,'DDMMYYYY') as dt_fin,
					reg_e210.reg_e210
				FROM		
					f,
					reg_e210,
					sped_fiscal									
				
			) row
		)
		SELECT array_agg(json) as reg_e200 from temp
	)
	,reg_e110 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E110' AS reg,
					0::numeric(12,2) as vl_tot_debitos,
					0::numeric(12,2) as vl_aj_debitos,
					0::numeric(12,2) as vl_tot_aj_debitos,
					0::numeric(12,2) as vl_estorno_cred,
					0::numeric(12,2) as vl_tot_creditos,
					0::numeric(12,2) as vl_tot_aj_creditos,
					0::numeric(12,2) as vl_estornos_deb,
					0::numeric(12,2) as vl_sld_apurado,
					0::numeric(12,2) as vl_sld_credor_ant,
					0::numeric(12,2) as vl_tot_ded,
					0::numeric(12,2) as vl_icms_recolher,
					0::numeric(12,2) as vl_tod_debitos,
					0::numeric(12,2) as vl_sld_credor_transportar,
					0::numeric(12,2) as deb_esp					
				
			) row
		)
		SELECT array_agg(json) as reg_e110 from temp
	)
	,reg_e100 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E100' AS reg,
					to_char(sped_fiscal.inicio,'DDMMYYYY') as dt_ini,
					to_char(sped_fiscal.fim,'DDMMYYYY') as dt_fin,
					reg_e110.reg_e110
				FROM					
					reg_e110,
					sped_fiscal										
				
			) row
		)
		SELECT array_agg(json) as reg_e100 from temp
	)
	,reg_e001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'E001' as reg,
					'0' as ind_mov,
					reg_e100.reg_e100,
					reg_e200.reg_e200,
					reg_e990.reg_e990
				FROM
					reg_e100,
					reg_e200,
					reg_e990
				) row
		)
		SELECT array_agg(json) as reg_e001 from temp
	)	
	-------------------------------------------------------------------------------------------------
	--- BLOCO D 
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
	,reg_d590 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'D590' AS reg,		
					trim(cst_icms) as cst_icms,
					trim(cfop) as cfop,
					aliquota_icms as aliq_icms,
					(
						total_valor_produto +
						valor_ratear -
						total_valor_desconto
					) as vl_opr,
					total_vl_base_icms as vl_bc_icms,
					total_valor_icms as vl_icms,
					COALESCE(total_valor_base_icms_st,0.00) as vl_bc_icms_st,
					COALESCE(total_valor_icms_st,0.00) as vl_icms_st,
					0::numeric(12,2) as vl_red_bc,
					''::text as cod_obs,
					id_compra
				FROM
					telefone_analitico
				ORDER BY
					id_compra
			) row
		)
		SELECT id_compra, array_agg(json) as reg_d590 FROM temp GROUP BY id_compra
	)
	,reg_d500 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'D500' AS reg,
					'0' as ind_oper,
					'1' as ind_emit,
					'F' || lpad(id_fornecedor::text,7,'0') as cod_part,
					trim(modelo_doc_fiscal) as cod_mod,
					'00' as cod_sit,
					COALESCE(trim(serie_doc),'')::text as ser,
					COALESCE(trim(sub_serie),'')::text as sub,					
					trim(numero_documento) as num_doc,				
					to_char(data_emissao,'DDMMYYYY') as dt_doc,
					to_char(data_entrada,'DDMMYYYY') as dt_a_p,
					vl_total::numeric(12,2) as vl_doc,
					vl_desconto::numeric(12,2) as vl_desc,
					vl_mercadoria::numeric(12,2) as vl_serv,
					vl_serv_nt::numeric(12,2) as vl_serv_nt,
					vl_outras_despesas::numeric(12,2) as vl_da,					
					vl_base_calculo::numeric(12,2) as vl_bc_icms,
					vl_icms::numeric(12,2) as vl_icms,	
					''::text as cod_inf,																
					totais.vl_pis::numeric(12,2) as vl_pis,
					totais.vl_cofins::numeric(12,2) as vl_cofins,
					''::text as cod_cta,
					COALESCE(tp_assinante,'') as tp_assinante,
					reg_d590.reg_d590
				FROM
					telefone
					LEFT JOIN telefone_pis_cofins totais
						ON totais.id_compra = telefone.id_compra					
					LEFT JOIN reg_d590
						ON telefone.id_compra = reg_d590.id_compra
				ORDER BY
					numero_compra
			) row
		)
		SELECT array_agg(json) as reg_d500 from temp
	) 
	,reg_d190 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_conhecimento FROM (
				SELECT 
					'D190' AS reg,					
					trim(cst) as cst_icms,
					trim(cfop) as cfop,
					aliquota as aliq_icms,
					total_valor_operacao as vl_opr,
					total_vl_base_icms as vl_bc_icms,
					total_valor_icms as vl_icms,
					0::numeric(12,2) as vl_red_bc,					
					''::text as cod_obs,
					id_conhecimento
				FROM
					c_analitico
				ORDER BY
					id_conhecimento
			) row
		)
		SELECT id_conhecimento, array_agg(json) as reg_d190 FROM temp GROUP BY id_conhecimento
	)		
	,reg_d100 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'D100' AS reg,
					ind_oper,
					ind_emit,
					COALESCE(
						CASE WHEN ind_oper = '1' THEN 
							'C' || lpad(codigo_participante::text,7,'0')
						ELSE
							'F' || lpad(codigo_participante::text,7,'0')
						END::text
					,'') as cod_part,					
					cod_mod,
					cod_sit,
					serie_doc as ser,
					sub_serie::text as sub,
					numero_documento as num_doc,
					trim(chave_cte) as chave_cte,
					COALESCE(to_char(data_emissao,'DDMMYYYY'),'')::text as dt_doc,
					COALESCE(to_char(data_entrada,'DDMMYYYY'),'')::text as dt_a_p,
					tipo_cte,
					''::text as chv_cte_ref,
					total_frete::numeric(12,2) as vl_doc,
					vl_desc::numeric(12,2) as vl_desc,
					ind_frt,
					total_frete::numeric(12,2) as vl_serv,
					base_calculo::numeric(12,2) as vl_bc_icms,
					imposto::numeric(12,2) as vl_icms,
					vl_nt::numeric(12,2) as vl_nt,
					''::text as cod_inf,
					''::text as cod_cta,
					trim(cod_ibge_origem,'') as cod_ibge_origem,
					trim(cod_ibge_destino,'') as cod_ibge_destino,
					reg_d190.reg_d190
				FROM
					c
					LEFT JOIN reg_d190
						ON reg_d190.id_conhecimento = c.id_conhecimento
						
				ORDER BY
					ind_oper, numero_documento
			) row
		)
		SELECT array_agg(json) as reg_d100 from temp
	)
	,reg_d001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'D001' as reg,
					CASE 	WHEN COALESCE(reg_d100.reg_d100,reg_d500.reg_d500,NULL) IS NULL 
						THEN '1'
						ELSE '0'
					END::text as ind_mov,					
					reg_d100.reg_d100,
					reg_d500.reg_d500,
					reg_d990.reg_d990
				FROM
					reg_d100,
					reg_d500,
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
	,reg_c590 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C590' AS reg,					
					trim(cst_icms) as cst_icms,
					trim(cfop) as cfop,
					aliquota_icms as aliq_icms,
					(
						total_valor_produto +
						valor_ratear -
						total_valor_desconto
					) as vl_opr,
					total_vl_base_icms as vl_bc_icms,
					total_valor_icms as vl_icms,
					total_valor_base_icms_st as vl_bc_icms_st,
					total_valor_icms_st as vl_icms_st,
					0::numeric(12,2) as vl_red_bc,
					''::text as cod_obs,
					id_compra
				FROM
					contas_consumo_analitico
				ORDER BY
					id_compra
			) row
		)
		SELECT id_compra, array_agg(json) as reg_c590 FROM temp GROUP BY id_compra
	)	
	,reg_c500 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'C500' AS reg,
					'0' as ind_oper,
					'1' as ind_emit,
					'F' || lpad(id_fornecedor::text,7,'0') as cod_part,
					trim(modelo_doc_fiscal) as cod_mod,
					'00' as cod_sit,
					COALESCE(trim(serie_doc),'')::text as ser,
					COALESCE(trim(sub_serie),'')::text as sub,
					(trim(cod_consumo_energia) || trim(cod_consumo_agua)) as cod_cons,
					trim(numero_documento) as num_doc,					
					to_char(data_emissao,'DDMMYYYY') as dt_doc,
					to_char(data_entrada,'DDMMYYYY') as dt_e_s,
					vl_total::numeric(12,2) as vl_doc,
					vl_desconto::numeric(12,2) as vl_desc,
					vl_mercadoria::numeric(12,2) as vl_forn,
					vl_serv_nt::numeric(12,2) as vl_serv_nt,
					vl_outras_despesas::numeric(12,2) as vl_da,					
					vl_base_calculo as vl_bc_icms,
					vl_icms as vl_icms,					
					--Estudar o caso de Substituição Tributário 					
					COALESCE(0.00,vl_base_calculo_st)::numeric(12,2) as vl_bc_icms_st,
					COALESCE(0.00,vl_icms_st)::numeric(12,2) as vl_icms_st,					
					totais.vl_pis::numeric(12,2) as vl_pis,
					totais.vl_cofins::numeric(12,2) as vl_cofins,
					tp_ligacao,
					cod_grupo_tensao,
					reg_c590.reg_c590
				FROM
					contas_consumo
					LEFT JOIN contas_consumo_pis_cofins totais
						ON totais.id_compra = contas_consumo.id_compra					
					LEFT JOIN reg_c590
						ON contas_consumo.id_compra = reg_c590.id_compra
				ORDER BY
					numero_compra
			) row
		)
		SELECT array_agg(json) as reg_c500 from temp
	) 
	,reg_ecf AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					trim(c_ecf.bloco) as regs 
				FROM 
					c_ecf
				WHERE c_ecf.bloco IS NOT NULL
			) row
		)				
		SELECT array_agg(json) as reg_ecf FROM temp 
	)
	,reg_c190 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C190' AS reg,					
					trim(cst_icms) as cst_icms,
					trim(cfop) as cfop,
					aliquota_icms as aliq_icms,
					(
						total_valor_produto +
						valor_ratear -
						total_valor_desconto
					) as vl_opr,
					total_vl_base_icms as vl_bc_icms,
					total_valor_icms as vl_icms,
					total_valor_base_icms_st as vl_bc_icms_st,
					total_valor_icms_st as vl_icms_st,
					0::numeric(12,2) as vl_red_bc,
					total_ipi as vl_ipi,
					''::text as cod_obs,
					id_compra
				FROM
					compras_analitico
				ORDER BY
					id_compra
			) row
		)
		SELECT id_compra, array_agg(json) as reg_c190 FROM temp GROUP BY id_compra
	)		
	,reg_c190_s AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_nf FROM (
				SELECT 
					'C190' AS reg,					
					trim(cst_icms) as cst_icms,
					trim(cfop) as cfop,
					aliquota_icms as aliq_icms,
					(
						total_valor_produto +
						valor_ratear -
						total_valor_desconto
					) as vl_opr,
					total_vl_base_icms as vl_bc_icms,
					total_valor_icms as vl_icms,
					total_valor_base_icms_st as vl_bc_icms_st,
					total_valor_icms_st as vl_icms_st,
					0::numeric(12,2) as vl_red_bc,
					total_ipi as vl_ipi,
					''::text as cod_obs,
					id_nf
				FROM
					nfe_analitico
				ORDER BY
					id_nf
			) row
		)
		SELECT id_nf, array_agg(json) as reg_c190 FROM temp GROUP BY id_nf
	)
	,reg_c190_nfc AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_nf FROM (
				SELECT 
					'C190' AS reg,					
					cst_icms,
					cfop,
					aliq_icms,
					vl_opr,
					vl_bc_icms,
					vl_icms,
					vl_bc_icms_st,
					vl_icms_st,
					vl_red_bc,
					vl_ipi,
					cod_obs,
					id,
					id_tb_100 as id_nf
				FROM
					nfc_analitico
				ORDER BY
					id_tb_100
			) row
		)
		SELECT id_nf, array_agg(json) as reg_c190_nfc FROM temp GROUP BY id_nf
	)			
	,reg_c170 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json, id_compra FROM (
				SELECT 
					'C170' AS reg,
					row_number() over (partition by id_compra) as num_item,
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
					quantidade_base_pis as quant_bc_pis,
					vl_aliquota_pis as aliq_pis_2,
					valor_pis as vl_pis,
					cst_cofins,
					valor_base_cofins as vl_bc_cofins,
					aliquota_cofins_perc as aliq_cofins,
					quantidade_base_cofins as quant_bc_cofins,
					vl_aliquota_cofins as aliq_cofins_2,
					vl_cofins,
					''::text as cod_cta,
					0.00::numeric(12,2) as vl_abat_nt,
					id_compra
				FROM
					compras_itens
				ORDER BY
					id_compra, id_compra_item
			) row
		)
		SELECT id_compra, array_agg(json) as reg_C170 FROM temp GROUP BY id_compra
	)		
-- 	,reg_c170_s AS (		
-- 		WITH temp AS (
-- 			SELECT (row_to_json(row,true))::json as json, id_nf FROM (
-- 				SELECT 
-- 					'C170' AS reg,
-- 					row_number() over (partition by id_nf) as num_item,
-- 					'P' || lpad(id_produto::text,7,'0') as cod_item,
-- 					''::text as descr_compl,
-- 					quantidade as qtd,
-- 					trim(unidade) as unid,
-- 					vl_total as vl_item,
-- 					vl_desconto as vl_desc,
-- 					movimentacao_fisica::text as ind_mov,
-- 					cst_icms as cst_icms,
-- 					trim(cfop) as cfop,
-- 					''::text as cod_nat,
-- 					vl_base_icms as vl_bc_icms,
-- 					aliquota_icms as aliq_icms,
-- 					valor_icms as vl_icms,				
-- 			
-- 					--Estudar o caso de Substituição Tributário 
-- 					-- para o Lucro Real
-- 					COALESCE(0.00,valor_base_icms_st) as vl_bc_icms_st,
-- 					COALESCE(0.00, aliquota_icms_st) as aliq_st,
-- 					COALESCE(0.00, valor_icms_st) as vl_icms_st,
-- 					
-- 					''::text as ind_apur,
-- 					cst_ipi,
-- 					''::text as cod_enq,
-- 					vl_base_ipi as vl_bc_ipi,
-- 					aliquota_ipi as aliq_ipi,
-- 					vl_ipi as vl_ipi,
-- 					cst_pis,
-- 					vl_base_pis as vl_bc_pis,
-- 					aliquota_pis_perc as aliq_pis,
-- 					quantidade_base_pis as quant_bc_pis,
-- 					vl_aliquota_pis as aliq_pis_2,
-- 					valor_pis as vl_pis,
-- 					cst_cofins,
-- 					valor_base_cofins as vl_bc_cofins,
-- 					aliquota_cofins_perc as aliq_cofins,
-- 					quantidade_base_cofins as quant_bc_cofins,
-- 					vl_aliquota_cofins as aliq_cofins_2,
-- 					vl_cofins,
-- 					''::text as cod_cta,
-- 					id_nf
-- 				FROM					
-- 					nfe_itens
-- 				ORDER BY
-- 					id_nf, id_nf_item
-- 			) row
-- 		)
-- 		SELECT id_nf, array_agg(json) as reg_C170 FROM temp GROUP BY id_nf
-- 	)		
	,reg_c100 AS (		
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				WITH t AS (
					SELECT 
						'C100' AS reg,
						'0' as ind_oper,
						'1' as ind_emit,
						'F' || lpad(id_fornecedor::text,7,'0') as cod_part,
						trim(modelo_doc_fiscal) as cod_mod,
						'00' as cod_sit,
						COALESCE(trim(serie_doc),'')::text as ser,
						trim(numero_documento) as num_doc,
						COALESCE(chave_nfe,'') as chave_nfe,
						to_char(data_emissao,'DDMMYYYY') as dt_doc,
						to_char(data_entrada,'DDMMYYYY') as dt_e_s,
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
						nfes.valor_pis as vl_pis,
						nfes.valor_cofins as vl_cofins,
						vl_pis_st as vl_pis_st,
						vl_cofins_st as vl_cofins_st,
						compras.id_compra,
						null::integer as id_nf					
					FROM
						compras
						LEFT JOIN nfes_pis_cofins nfes
							ON nfes.id_compra = compras.id_compra
					UNION 
					SELECT 
						'C100' AS reg,
						'1' as ind_oper,
						'0' as ind_emit,
						COALESCE('C' || lpad(codigo_cliente::text,7,'0'),'') as cod_part,
						trim(modelo_doc_fiscal) as cod_mod,
						cod_sit,
						COALESCE(trim(serie_doc),'')::text as ser,
						trim(numero_documento) as num_doc,
						COALESCE(chave_nfe,'') as chave_nfe,
						COALESCE(to_char(data_emissao,'DDMMYYYY'),'') as dt_doc,
						COALESCE(to_char(data_saida,'DDMMYYYY'),'') as dt_e_s,
						vl_total as vl_doc,
						COALESCE(tipo_pagamento,'') as ind_pgto,
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
						vl_base_calculo_st as vl_bc_icms_st,
						vl_icms_st as vl_icms_st,					
						vl_ipi,
						vl_pis as vl_pis,
						vl_cofins as vl_cofins,
						vl_pis_st as vl_pis_st,
						vl_cofins_st as vl_cofins_st,
						null::integer id_compra,
						id_nf						
					FROM
						nfe					
					UNION 
					SELECT 
						'C100' AS reg,
						ind_oper,
						ind_emit,
						cod_part,
						cod_mod,
						cod_sit,
						ser,
						num_doc,
						chv_nfe as chave_nfe,
						dt_doc,
						dt_e_s,
						vl_doc,
						ind_pgto,
						vl_desc,
						vl_abat_nt,
						vl_merc,
						ind_frt,
						vl_frt,
						vl_seg,
						vl_out_da,
						vl_bc_icms,
						vl_icms,					
						--Estudar o caso de Substituição Tributário 
						-- para o Lucro Real
						vl_bc_icms_st,
						vl_icms_st,					
						vl_ipi,
						vl_pis,
						vl_cofins,
						vl_pis_st,
						vl_cofins_st,
						id as id_compra,
						id_ord	as id_nf					
					FROM
						nfc				

				)
				SELECT 
					t.*,
					reg_c170.reg_c170 as reg_c170,
					COALESCE(reg_c190.reg_c190, reg_c190_s.reg_c190, reg_c190_nfc) as reg_c190
				FROM 
					t 					
 					LEFT JOIN reg_c190_nfc
 						ON t.id_nf = reg_c190_nfc.id_nf 							
 					LEFT JOIN reg_c190_s
 						ON t.id_nf = reg_c190_s.id_nf
 					LEFT JOIN reg_c170 
						ON t.id_compra = reg_c170.id_compra
 					LEFT JOIN reg_c190
 						ON t.id_compra = reg_c190.id_compra
			) row
		)
		SELECT array_agg(json) as reg_C100 from temp
	)	
	,reg_c001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'C001' as reg,
					CASE 	WHEN COALESCE(reg_c100.reg_c100, reg_c500.reg_c500,reg_ecf,NULL) IS NULL 
						THEN '1'
						ELSE '0'
					END::text as ind_mov,
					reg_c100.reg_c100,
					reg_ecf.reg_ecf,	
					reg_c500.reg_c500,
					reg_c990.reg_c990
				FROM
					reg_c100,
					reg_ecf,
					reg_c500,
					reg_c990
				) row
		)
		SELECT array_agg(json) as reg_C001 from temp
	)	
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
					aliquota_icms as aliq_icms,
					cest					
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
					TRIM((ddd || telefone1)) as telefone,
					COALESCE(trim(fax),'') as fax,
					trim(email) as email,
					cod_ibge as cod_mun
				FROM 
					contador
				) row
		)
		SELECT array_agg(json) as reg_0100 from temp
	) 
	,reg_0005 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0005' as reg,
					nome_descritivo as fantasia,
					cep,
					endereco as end,
					numero as num,
					''::text as compl,
					bairro as bairro,
					(ddd || telefone) as telefone,
					fax as fax,
					email_principal as email					
				FROM 
					f
				) row
		)
		SELECT array_agg(json) as reg_0005 from temp
	)
	,reg_0001 AS (
		WITH temp AS (
			SELECT (row_to_json(row,true))::json as json FROM (
				SELECT 
					'0001' as reg,
					'0' as ind_mov,
					reg_0005.reg_0005,
					reg_0100.reg_0100,
					reg_0150.reg_0150,
					reg_0190.reg_0190,
					reg_0200.reg_0200,
					reg_0990.reg_0990
				FROM 
					f,
					reg_0005,
					reg_0100,
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
					reg_c001.reg_c001,
					--Bloco Existente a partir da versão 013.
					CASE 	WHEN sped_fiscal.versao::integer < 13 
						THEN NULL
						ELSE reg_b001.reg_b001
					END as reg_b001,
					reg_d001.reg_d001,
					reg_e001.reg_e001,
					reg_g001.reg_g001,
					reg_h001.reg_h001,
					--Bloco Existente a partir da versão 010.
					CASE 	WHEN sped_fiscal.versao::integer < 10 
						THEN NULL
						ELSE reg_k001.reg_k001
					END as reg_K001,
					reg_1001.reg_1001					
				FROM 
					f,
					reg_0001,
					reg_b001,
					reg_c001,
					reg_d001,
					reg_e001,
					reg_g001,
					reg_h001,					
					reg_k001,					
					reg_1001,
					sped_fiscal									
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
			UNION 
			SELECT 
				reg_blc as registro,
				qt
			FROM 
				c_ecf_b9
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
					sped_fiscal.versao as cod_ver,
					sped_fiscal.cod_fin as cod_fin,
					to_char(sped_fiscal.inicio,'DDMMYYYY') as dt_ini,
					to_char(sped_fiscal.fim,'DDMMYYYY') as dt_fin,
					razao_social as nome,
					cnpj,
					''::text as cpf,
					inscricao_estadual as ie,
					uf,
					cod_ibge as cod_mun,
					''::text as im,
					''::text as suframa,
					perfil_empresa as ind_perfil,
					'1' as ind_ativ,
					reg_0001.reg_0001,
					--Bloco Existente a partir da versão 013.
					CASE 	WHEN sped_fiscal.versao::integer < 13 
						THEN NULL
						ELSE reg_b001.reg_b001
					END as reg_b001,
					reg_c001.reg_c001,
					reg_d001.reg_d001,
					reg_e001.reg_e001,
					reg_g001.reg_g001,
					reg_h001.reg_h001,					
					--Bloco Existente a partir da versão 010.
					CASE 	WHEN sped_fiscal.versao::integer < 10 
						THEN NULL
						ELSE reg_k001.reg_k001
					END as reg_k001,										
					reg_1001.reg_1001,
					reg_9001.reg_9001
				FROM 
					sped_fiscal,
					f,
					reg_0001,
					reg_b001,
					reg_c001,
					reg_d001,
					reg_e001,
					reg_g001,
					reg_h001,
					reg_k001,					
					reg_1001,
					reg_9001
					
				) row
		)
		SELECT array_agg(json_0000) as reg_0000 from temp
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

	RAISE NOTICE '%s', v_dados::text;
	
	RETURN v_dados;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
