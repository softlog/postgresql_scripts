-- Table: public.com_compras_cfop_saida_entrada
--SELECT * FROM com_compras_cfop_saida_entrada
--DROP TABLE public.com_compras_cfop_saida_entrada;

CREATE TABLE public.com_compras_cfop_saida_entrada
(
	id serial,
	fk_codigo_cfop_saida character(4),
	fk_codigo_cfop_entrada character(4),
	codigo_empresa character(3),
	id_fornecedor integer
)
WITH (
  OIDS=FALSE
);


ALTER TABLE com_produtos_temp ADD COLUMN xml_nfe_id integer  REFERENCES xml_nfe (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE com_produtos_temp ADD COLUMN executa_cadastro  integer DEFAULT 0;
ALTER TABLE com_produtos_temp ADD COLUMN executa_parametro integer DEFAULT 0;
ALTER TABLE com_produtos_temp ADD COLUMN parametro_cfop    integer DEFAULT 0;


/*


SELECT cfop.codigo_cfop, cfop.descricao_cfop, com_compras_sugestao_cfop_cst.tipo_item, com_compras_sugestao_cfop_cst.cst_icms, com_compras_sugestao_cfop_cst.cst_pis, com_compras_sugestao_cfop_cst.cst_cofins FROM com_compras_sugestao_cfop_cst  LEFT JOIN cfop on com_compras_sugestao_cfop_cst.fk_codigo_cfop = cfop.codigo_cfop WHERE 1=2
SELECT * FROM com_compras_cfop_saida_entrada ORDER BY 1 
-- SELECT * FROM cidades LIMIT 1

UPDATE com_compras_cfop_saida_entrada SET fk_codigo_cfop_entrada = fk_codigo_cfop_saida, fk_codigo_cfop_saida = NULL WHERE fk_codigo_cfop_entrada IS NULL
SELECT * FROM com_produtos_temp WHERE xml_nfe_id = 1837

SELECT * FROM com_produtos_temp

	ROLLBACK;
	BEGIN;
	SELECT f_relacionamento_produto_lote(13121)

	WITH t AS (
		SELECT 
			id_produto, 
			ncm, 
			id_unidade, 
			cst_icms, 
			cfop, 
			cfop_for, 
			cst_ipi, 
			cst_pis,
			cst_cofins, 
			cod_prod_for, 
			id_fornecedor,
			tipo_item
		FROM 
			com_produtos_temp 
		WHERE 
			id = 13121
	)
		SELECT com_produtos_temp.cadastrado, com_produtos_temp.parametrizado, com_produtos_temp.parametro_cfop FROM t
		LEFT JOIN com_produtos_temp ON t.id_fornecedor = com_produtos_temp.id_fornecedor
						AND t.cod_prod_for = com_produtos_temp.cod_prod_for
		LEFT JOIN xml_nfe ON xml_nfe.id = com_produtos_temp.xml_nfe_id
	WHERE xml_nfe.status = 1 AND xml_nfe.id <> 1837
	ROLLBACK;
	UPDATE com_produtos_temp SET 
		id_produto = t.id_produto,
		ncm = t.ncm,
		id_unidade = t.id_unidade,
		cst_icms = t.cst_icms,
		cfop = t.cfop,
		cfop_for = t.cfop_for,
		cst_ipi = t.cst_ipi,
		cst_pis = t.cst_pis,
		cst_cofins = t.cst_cofins,		
		tipo_item = t.tipo_item,
		parametrizado = 1,
		cadastrado = 1,
		parametro_cfop = 1
	FROM
		t, xml_nfe
	WHERE 
		t.id_fornecedor = com_produtos_temp.id_fornecedor
		AND t.cod_prod_for = com_produtos_temp.cod_prod_for
		AND xml_nfe.id = com_produtos_temp.xml_nfe_id		
		AND xml_nfe.status = 1		
		AND xml_nfe.id <> 1837;
ROLLBACK

	SELECT * FROM t
		LEFT JOIN com_produtos_temp ON t.id_fornecedor = com_produtos_temp.id_fornecedor
						AND t.cod_prod_for = com_produtos_temp.cod_prod_for
		LEFT JOIN xml_nfe ON xml_nfe.id = com_produtos_temp.xml_nfe_id
	WHERE xml_nfe.status = 1 AND xml_nfe.id <> 1838


*/