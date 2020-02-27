CREATE OR REPLACE VIEW v_com_nf_cubo AS
SELECT 
	nf.codigo_empresa,
	nf.codigo_filial,
	nf.modelo_doc_fiscal,
	nf.numero_documento,
	nf.data_emissao,
	nf.cstat,
	COALESCE(nfi.id_produto,0) as id_produto,
	COALESCE(nfi.quantidade,0.00) as quantidade,
	COALESCE(nfi.vl_item,0.00) as vl_item,
	COALESCE(nfi.vl_desconto,0.00) as vl_desconto,
	(COALESCE(nfi.vl_total,0.00) - COALESCE(nfi.vl_desconto,0.00)) as vl_total,
	COALESCE(nfi.vl_total,0.00) as vl_total_produto,
	nfi.cst_icms,
	nfi.cfop,
	date_part('month'::text, nf.data_emissao)::integer AS mes, 
	date_part('year'::text, nf.data_emissao)::integer AS ano, 
	date_part('week'::text, nf.data_emissao)::integer AS semana, 
	date_part('quarter'::text, nf.data_emissao)::integer AS trimestre, 
	date_part('day'::text, nf.data_emissao)::integer AS dia,
	nf.data_emissao::date as data,
	mes_ano_chave(data_emissao::date) as mes_ano,
	filial.id_filial,
	filial.cnpj,
	nf.chave_eletronica,
	nfi.codigo_prod_digisat
FROM
	com_nf nf 
	LEFT JOIN com_nf_itens nfi
		ON nf.id_nf = nfi.id_nf
	LEFT JOIN filial
		ON filial.codigo_empresa = nf.codigo_empresa
			AND filial.codigo_filial = nf.codigo_filial	
WHERE cstat = 100
	AND entrada_saida = 'S';

--SELECT * FROM com_nf ORDER BY 1 DESC LIMIT 10

--SELECT * FROM v_com_nf_cubo


--SELECT * FROM com_nf_itens ORDER BY 1 DESC LIMIT 10


CREATE OR REPLACE VIEW v_com_nf_produtos_cubo AS 
SELECT 
	nf.id_produto,
	COALESCE(com_produtos.descr_item,'PRODUTO DESCONHECIDO') as produto
FROM 
	v_com_nf_cubo nf
	LEFT JOIN com_produtos 
		ON nf.id_produto = com_produtos.id_produto
GROUP BY 
	nf.id_produto,
	com_produtos.descr_item;


CREATE OR REPLACE VIEW v_filial_cubo AS 
SELECT 
	id_filial,
	codigo_empresa,
	codigo_filial,
	CASE WHEN position('-' in nome_descritivo) > 0 THEN trim((string_to_array(nome_descritivo,'-'))[2]) ELSE trim(nome_descritivo) END as filial	
FROM
	filial;
