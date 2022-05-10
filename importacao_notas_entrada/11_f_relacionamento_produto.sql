-- Function: public.f_relacionamento_produto(integer)

-- DROP FUNCTION public.f_relacionamento_produto(integer);

CREATE OR REPLACE FUNCTION public.f_relacionamento_produto_lote(p_id integer)
  RETURNS integer AS
$BODY$
DECLARE
	vIdTemp ALIAS FOR $1;
	vCursor refcursor;
	vIdRelacao integer;
	vCodigo_Produto character(8);
	vCadastrado integer;
	vParametrizado integer;	
	vIdProduto integer;
	vIdRelacionamento integer;
	v_id_xml_nfe integer;
	
BEGIN

	-- 
	-- Da tabela Com_Produtos_Temp 
	-- 	Grava o Produto -- Campo Código Produto Empresa Vazio --> 
	--	Grava um Novo;
	--		Ou grava um novo
	--		Ou associa com um produto já cadastrado
	-- Se existe Produto, 
	-- 	Grava Relacionamento -- Cadastrado = 0 = Não existe relacionamento
	-- 	Grava Sugestao

	OPEN    vCursor FOR 
			SELECT 	
				id_produto, 
				codigo_produto, 
				cadastrado, 
				parametrizado,
				xml_nfe_id
			FROM 	com_produtos_temp
			WHERE	id = p_id;

	FETCH   vCursor INTO 
                    vIdProduto, 
                    vCodigo_Produto, 
                    vCadastrado, 
                    vParametrizado,
                    v_id_xml_nfe;

	IF NOT FOUND THEN 
		RETURN 0; -- Produto Temporario Não Encontrado;
	END IF;

	CLOSE vCursor;

	--Verifica se o produto está cadastrado, se não cadastra
	IF vIdProduto IS NULL THEN

		vCodigo_Produto = trim(to_char(proximo_numero_sequencia('com_produtos_codigo_produto_seq')::integer,'00000000'));

		OPEN vCursor FOR
		INSERT INTO com_produtos 
			(
				codigo_produto,
				descr_item,
				id_unidade,
				tipo_item,
				codigo_mercosul,
				cst_icms,
				aliquota_icms,
				cfop,
				cst_ipi,
				aliquota_ipi,
				cst_pis,
				aliquota_pis,
				cst_confins,
				aliquota_confins,
				data_cadastro,
				usuario_cadastro,
				valor_custo, --17
				valor_venda --18
			)
		SELECT 
				vCodigo_Produto,
				com_produtos_temp.descricao,
				com_produtos_temp.id_unidade,
				com_produtos_temp.tipo_item,
				com_produtos_temp.ncm,
				com_produtos_temp.cst_icms,
				com_produtos_temp.aliquota_icms,
				com_produtos_temp.cfop,
				com_produtos_temp.cst_ipi,
				com_produtos_temp.aliquota_ipi,
				com_produtos_temp.cst_pis,
				com_produtos_temp.aliquota_pis,
				com_produtos_temp.cst_cofins,
				com_produtos_temp.aliquota_cofins,
				current_timestamp,
				COALESCE(fp_get_session('pst_login'),'suporte'),
				0.00,
				0.00
  		FROM
			com_produtos_temp
		WHERE
			id = p_id
		RETURNING id_produto;

		FETCH vCursor INTO vIdProduto;	

		CLOSE vCursor;

		UPDATE 
			com_produtos_temp 
			SET 
				codigo_produto = vCodigo_Produto,
				id_produto = vIdProduto
		WHERE 
			id = p_id;	

	END IF;

	--Verifica se o produto está relacionado, se não relaciona
	OPEN vCursor FOR
	INSERT INTO com_produtos_empresa_fornecedor
		(
			fk_id_fornecedor, 
			codigo_produto_fornecedor, 
			fk_codigo_produto, 
			fk_id_produto
		)
	SELECT 
			com_produtos_temp.id_fornecedor,
			com_produtos_temp.cod_prod_for,
			vCodigo_Produto,
			vIdProduto
	FROM 	
		com_produtos_temp
	WHERE
		id = p_id
		AND NOT EXISTS (
				SELECT 	1
				FROM com_produtos_empresa_fornecedor 
				WHERE com_produtos_empresa_fornecedor.fk_id_fornecedor = com_produtos_temp.id_fornecedor
				      AND com_produtos_empresa_fornecedor.fk_id_produto = com_produtos_temp.id_produto
				      AND com_produtos_empresa_fornecedor.codigo_produto_fornecedor = com_produtos_temp.cod_prod_for
				)
	RETURNING id;

	FETCH vCursor INTO vIdRelacionamento;

	
	IF FOUND THEN 
	
		INSERT INTO com_produtos_sugestao_cfop_cst
			(
				fk_com_produtos_empresa_fornecedor_id, 
				cfop_fornecedor, 
				cfop_entrada, 
				cst_icms, 
				cst_pis, 
				cst_cofins
			)
		SELECT 
				vIdRelacionamento,
				com_produtos_temp.cfop_for,
				com_produtos_temp.cfop,
				com_produtos_temp.cst_icms,
				com_produtos_temp.cst_pis,
				com_produtos_temp.cst_cofins
		FROM
			com_produtos_temp
		WHERE
			id = p_id;
	END IF;
	
	CLOSE vCursor;


	UPDATE 
		com_produtos_temp 
		SET 
			cadastrado = 1,
			parametrizado = 1,
			parametro_cfop = 1
	WHERE 
		id = p_id;	


	--RAISE NOTICE 'Atualizando outros produtos %', p_id;
	
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
			id = p_id
	)	
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
		AND xml_nfe.id <> v_id_xml_nfe;

	--RAISE NOTICE 'Ok';
	RETURN vIdProduto; -- Bem sucedido
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

