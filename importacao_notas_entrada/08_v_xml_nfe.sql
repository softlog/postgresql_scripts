CREATE OR REPLACE VIEW v_xml_nfe AS 
SELECT 
	xml_nfe.id, 
	xml_nfe.chave_nfe, 
	xml_nfe.data_emissao, 
	xml_nfe.inscr_estadual, 
	xml_nfe.codigo_empresa, 
	xml_nfe.codigo_filial, 
	xml_nfe.status, 
	xml_nfe.data_registro, 
	xml_nfe.id_compra, 
	xml_nfe.cfop_entrada, 
	xml_nfe.cfop_saida, 
	xml_nfe.cst_icms,
	xml_nfe.data_entrada,
	xml_nfe.valor_total,
	xml_nfe.tipo_documento,
	xml_nfe.gera_escrituracao,
	xml_nfe.fornecedor_id, 
	null::integer as conta_pagar_id,
	fornecedores.nome_razao,
	fornecedores.cnpj_cpf,
	CASE WHEN xml_nfe.status = 1 THEN 'SEM ESCRITURACAO' WHEN xml_nfe.status = 2 THEN 'ESCRITURADA' END::text as status_descricao,
	CASE WHEN xml_nfe.tipo_documento = 1 THEN 'NFE' WHEN xml_nfe.tipo_documento = 2 THEN 'CTE' END::text as tipo_documento_descricao,
	com_compras.numero_compra,
	xml_nfe.xml_nfe,
	xml_nfe.numero,
	xml_nfe.serie,
 	produtos.itens_cadastrados,
 	produtos.itens_parametrizados,
 	produtos.parametro_cfop,
	0::integer as indicador_cor,	
	cidades.nome_cidade,
	cidades.uf,
	xml_nfe.data_escrituracao
FROM 
	xml_nfe
	LEFT JOIN fornecedores
		ON fornecedores.id_fornecedor = xml_nfe.fornecedor_id
	LEFT JOIN com_compras
		On com_compras.id_compra = xml_nfe.id_compra
	LEFT JOIN cidades
		ON cidades.id_cidade = fornecedores.id_cidade
	LEFT JOIN LATERAL (
		SELECT 
			com_produtos_temp.xml_nfe_id,
			COALESCE(MIN(cadastrado),0) as itens_cadastrados,  
			COALESCE(MIN(parametrizado),0) as itens_parametrizados,
			COALESCE(MIN(parametro_cfop),0) as parametro_cfop		
		FROM 
			com_produtos_temp 
		WHERE 
			xml_nfe.id = com_produtos_temp.xml_nfe_id
		GROUP BY 
			com_produtos_temp.xml_nfe_id
	) AS produtos ON xml_nfe.id = produtos.xml_nfe_id
WHERE xml_nfe.status <> -1;


/*

SELECT * FROM xml_nfe

BEGIN;
SELECT * FROM v_xml_nfe WHERE status = 2
UPDATE xml_nfe SET status = 0, id_compra = NULL WHERE id = 4247;
ROLLBACK;



UPDATE xml_nfe SET id = id, status = 0, id_compra = NULL, codigo_empresa = NULL, codigo_filial = NULL WHERE status = 0

chave_nfe = '31220105076962000148550010001345931001718017'


status <> -1 

SELECT * FROM com_produtos_temp WHERE xml_nfe_id = 4509
SELECT * FROM v_xml_nfe WHERE tipo_documento = 1

SELECT id_compra, numero_compra, data_registro FROM com_compras WHERE data_registro >= '2022-01-01 00:00:00';

DELETE FROM com_compras WHERE data_registro >= '2022-01-01 00:00:00';

SELECT id_fornecedor, dt_cadastro FROM fornecedores  ORDER BY id_fornecedor DESC LIMIT 1000

WITH t AS (
	SELECT * FROM com_produtos_empresa_fornecedor WHERE codigo_produto_fornecedor = '53519820000'
) 
DELETE FROM com_produtos_sugestao_cfop_cst WHERE EXISTS (SELECT 1 FROM t WHERE t.id = fk_com_produtos_empresa_fornecedor_id )

DELETE FROM com_produtos_empresa_fornecedor WHERE codigo_produto_fornecedor = '53519820000'

SELECT * FROM com_produtos_empresa_fornecedor WHERE codigo_produto_fornecedor = '53519820000'

SELECT * FROM xml_nfe WHERE tipo_documento = 2

SELECT id_compra, numero_compra FROM com_compras ORDER BY 1



SELECT '72835'::character(10) as numeronf,'1'::character(3) as serie,'2021-10-18T08:57:00-03:00'::date as data_emissao,NULL::character(1) as indpag,0.00::numeric(12,2) as vlr_bc,0.00::numeric(12,2) as vlr_icms,0.00::numeric(12,2) as vlr_bcst,0.00::numeric(12,2) as vlr_st,35.00::numeric(12,2) as vlr_prod,0.00::numeric(12,2) as vlr_frete,0.00::numeric(12,2) as vlr_seg,0.00::numeric(12,2) as vlr_desc,0.00::numeric(12,2) as vlr_ipi,0.00::numeric(12,2) as vlr_pis,0.00::numeric(12,2) as vlr_cofins,0.00::numeric(12,2) as vlr_outro,35.00::numeric(12,2) as vlr_nf,NULL::character(3) as tpag,NULL::character(1) as modfrete,NULL::text as obs,NULL::text as transportador_cnpj,NULL::text as transportador_cnpj,'5121100142122300019557001000072835100000000'::character(44) as chave;

SELECT * FROm com_compras WHERE chave_nfe = '31220105076962000148550010001345931001718017'
SELECT 
	0::integer as selecionar,
	id,
	chave_nfe,
	numero,
	serie,
	data_emissao,
	inscr_estadual,
	codigo_empresa,
	codigo_filial,
	status,
	status_descricao,
	data_registro,
	id_compra,
	numero_compra,
	cfop_entrada,
	cfop_saida,
	cst_icms,
	data_entrada,
	valor_total,
	tipo_documento,
	gera_escrituracao,
	fornecedor_id,
	nome_razao,
	cnpj_cpf,	
	tipo_documento_descricao
FROM 
	v_xml_nfe
WHERE 1=1
	
*/