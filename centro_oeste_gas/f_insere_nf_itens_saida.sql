CREATE OR REPLACE FUNCTION public.f_insere_nf_itens_saida(p_id_nf integer, dadosItens json)
  RETURNS integer AS
$BODY$
DECLARE	
	-- SELECT * FROM com_nf_itens ORDER BY 1 DESC LIMIT 100
	v_id integer;
	-- Variaveis de Entrada
	v_valor			numeric(12,2);
	v_valor_bc		numeric(12,2);
	v_valor_icms		numeric(12,2);
	v_valor_bc_st		numeric(12,2);
	v_desconto		numeric(12,2);
	v_valor_icms_st		numeric(12,2);
	v_volume_presumido	numeric(12,4);
	v_peso_presumido	numeric(20,4);
	v_peso_liquido		numeric(20,4);	
	v_volume_produtos	numeric(20,4);
	v_peso_produtos		numeric(20,4);
	v_unidade		text;
	v_especie_mercadoria	text;
	v_valor_produtos	numeric(12,2);
	v_cfop_predominante	character(4);	
	v_descricao_complementar text;
	v_quantidade		integer;
	v_vl_item		numeric(12,2);
	v_vl_desconto		numeric(12,2);
	v_movimentacao_fisica	integer;
	v_cst_icms		text;
	v_cfop			character(4);
	v_cod_natureza		text;
	v_codigo_produto	text;
	v_inf 			text;

	-- Variadas Processadas
	v_id_produto 		integer;
	
	

	-- Variaveis de ambiente
	vEmpresa		character(3);
	vFilial			character(3);
	vFilialFixa		character(3);
	vLogin			text;
	vUsuario		integer;
	

	-- Variaveis de Processamento
	vCursor 		refcursor;
	vExiste 		integer;
	vCancelado		integer;
	vCmd			text;	
	vLstLog			text;
	vArrayLog		text[];
	vQtLog			integer;
	v_exp_vol_pres		text;
	v_exp_pes_pres		text;
	v_exp_pes_liq		text;
	v_array_vol		text[];
	v_array_pesB		text[];
	v_array_pesL		text[];
	v_uf_rem		text;

BEGIN	

	

	
------------------------------------------------------------------------------------------------------------------
--                             DESERIALIZAÇÃO dos dados de estrutura json	
------------------------------------------------------------------------------------------------------------------	
	--RAISE NOTICE 'Dados Nf: %', dadosItens;

	v_codigo_produto = (dadosItens->>'produto_codigo')::text;
	v_descricao_complementar = (dadosItens->>'produto_xprod')::text;
	v_unidade = (dadosItens->>'produto_unidade')::text;
	

	BEGIN 
		v_valor			= ((dadosItens->>'produto_vl_total')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_valor 		= 0.00;
	END;

	BEGIN 
		v_vl_item		= ((dadosItens->>'produto_vl_item')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_vl_item		= 0.00;
	END;

	BEGIN 
		v_quantidade		= ((dadosItens->>'produto_qtd')::text)::integer;
	EXCEPTION WHEN OTHERS THEN 
		v_quantidade		= 0.00;
	END;

	

	BEGIN 
		v_desconto		= ((dadosItens->>'produto_vl_desc')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_desconto 		= 0.00;
	END;


	BEGIN 
		v_desconto		= ((dadosItens->>'nfe_valor_desc')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_desconto		= 0.00;
	END;


	BEGIN
		v_valor_bc	= ((dadosItens->>'nfe_valor_bc')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_bc = 0.00;
	END;

	BEGIN
		v_valor_icms = ((dadosItens->>'nfe_valor_icms')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_icms = 0.00;
	END;

	BEGIN
		v_valor_bc_st	= ((dadosItens->>'nfe_valor_bc_st')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_bc_st = 0.00;
	END;

	BEGIN
		v_valor_icms_st	= ((dadosItens->>'nfe_valor_icms_st')::text)::numeric(12,2);	
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_icms_st = 0.00;
	END;
	
	v_unidade		= dadosItens->>'nfe_unidade';

	BEGIN 
		v_valor_produtos	= ((dadosItens->>'nfe_valor_produtos')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_produtos	= 0.00;
	END;


		


	--RAISE NOTICE 'dados: %', dadosItens;	
	




------------------------------------------------------------------------------------------------------------------
--                                    PROCESSAMENTO DE VARIAVEIS
------------------------------------------------------------------------------------------------------------------	
	v_movimentacao_fisica = 0;

	SELECT id_produto_softlog
	INTO v_id_produto
	FROM efd_fiscal_produtos_ecf
	WHERE codigo_produto = v_codigo_produto;

	


------------------------------------------------------------------------------------------------------------------
--                                          PESO E VOLUMES
------------------------------------------------------------------------------------------------------------------	
	
	v_exp_vol_pres = COALESCE((dadosItens->>'nfe_volume_presumido')::text,'0.00'::text);
	IF trim(v_exp_vol_pres) = '' THEN 
		v_exp_vol_pres = '0.00';
	END IF; 

	v_exp_pes_liq  = COALESCE((dadosItens->>'nfe_peso_liquido')::text,'0.00'::text);
	IF trim(v_exp_pes_liq) = '' THEN 
		v_exp_pes_liq = '0.00';
	END IF;

	v_exp_pes_pres = COALESCE((dadosItens->>'nfe_peso_presumido')::text,'0.00'::text); 	
	IF trim(v_exp_pes_pres) = '' THEN 
		v_exp_pes_pres = '0.00';
	END IF; 
	


	-- Extrai peso bruto e liquido
	vCmd = '';
	vCmd = vCmd || 'SELECT ' ;
	vCmd = vCmd || COALESCE(v_exp_pes_pres,'0')  || ' as peso_bruto ';

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN
		FETCH vCursor INTO v_peso_presumido;
	EXCEPTION WHEN OTHERS  THEN 
		v_peso_presumido = 0.00;
	END;

	CLOSE vCursor;

	vCmd = '';
	vCmd = vCmd || 'SELECT ' ;
	vCmd = vCmd || COALESCE(v_exp_pes_liq,'0')   || ' as peso_liquido ';

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN
		FETCH vCursor INTO v_peso_liquido;
	EXCEPTION WHEN OTHERS  THEN 
		v_peso_liquido = 0;
	END;

	CLOSE vCursor;

	vCmd = '';
	vCmd = vCmd || 'SELECT ' ;
	vCmd = vCmd || COALESCE(v_exp_vol_pres,'0')  || ' as volume ';

	OPEN vCursor FOR EXECUTE vCmd;
	
	BEGIN
		FETCH vCursor INTO v_volume_presumido;
	EXCEPTION WHEN OTHERS  THEN 
		v_volume_presumido = 0.0000;		
	END;

	CLOSE vCursor;

	
	IF v_peso_presumido = 0 THEN 
		BEGIN
			v_peso_presumido = v_peso_liquido;
		EXCEPTION WHEN OTHERS  THEN 
			v_peso_presumido = 0.0000;
		END;
	END IF;

	IF v_peso_liquido = 0 THEN
		v_peso_liquido = v_peso_presumido;
	END IF;


	-- Extrai peso e volume dos produtos
	IF trim((dadosItens->>'nfe_volume_produtos')::text) = '' THEN
		vCmd = 'SELECT 0 as volume_produtos ' ;
	ELSE	
		vCmd = '';
		vCmd = vCmd || 'SELECT ' ;
		vCmd = vCmd || COALESCE((dadosItens->>'nfe_volume_produtos')::text,'0'::text) || ' as volume_produtos ';
	END IF;

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN 
		FETCH vCursor INTO v_volume_produtos;
	EXCEPTION WHEN OTHERS THEN 
		v_volume_produtos = 0;
	END;

	
	CLOSE vCursor;

	IF trim((dadosItens->>'nfe_peso_produtos')::text) = '' THEN 
		vCmd = 'SELECT 0.00 as peso_produtos';
	ELSE
		vCmd = '';
		vCmd = vCmd || 'SELECT ' ;
		vCmd = vCmd || COALESCE((dadosItens->>'nfe_peso_produtos')::text,'0.00'::text) || ' as peso_produtos ';
	END IF;

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN 
		FETCH vCursor INTO v_peso_produtos;
	EXCEPTION WHEN OTHERS THEN 
		v_peso_produtos = 0.00;
	END;

	CLOSE vCursor;



-----------------------------------------------------------------------------------------------------------------
--- 					GRAVACAO DOS DADOS  
-----------------------------------------------------------------------------------------------------------------
	SET datestyle = "ISO, DMY";

	BEGIN 
		OPEN vCursor FOR 		
		INSERT INTO com_nf_itens(
			id_nf, --1
			id_produto, --2
			descricao_complementar, --3
			quantidade, --4
			unidade, --5
			vl_item, --6
			vl_desconto,--7 
			movimentacao_fisica, --8
			cst_icms, --9
			cfop, --10
			cod_natureza, --11
			vl_base_icms, --12
			aliquota_icms, --13
			valor_icms, --14
			valor_base_icms_st, --15
			aliquota_icms_st, --16
			valor_icms_st, --17
			cst_ipi, --18
			cod_enq, --19
			vl_base_ipi, --20
			aliquota_ipi, --21
			vl_ipi, --22
			cst_pis, --23
			vl_base_pis, --24
			aliquota_pis_perc, --25
			quantidade_base_pis, --26
			vl_aliquota_pis, --27
			valor_pis, --28
			cst_cofins, --29
			valor_base_cofins, --30
			aliquota_cofins_perc, --31
			quantidade_base_cofins, --32
			vl_aliquota_cofins, --33
			vl_cofins, --34
			vl_total, --35
			vl_frete, --36
			comb_pmixcn, --37
			pdevol, --38     
			id_almoxarifado, --39
			icms_orig --40
		) VALUES (
			p_id_nf,--1
			v_id_produto,--2
			v_descricao_complementar,--3
			v_quantidade,--4
			v_unidade,--5
			v_vl_item,--6
			v_desconto,--7
			v_movimentacao_fisica,--8
			'060',--9
			'5656',--10
			NULL,--11
			0.00,--12
			0.00,--13
			0.00,--14
			0.00,--15
			0.00,--16
			0.00,--17
			0,--18
			NULL,--19
			0.00,--20
			0.00,--21
			0.00,--22
			'07',--23
			0.00,--24
			0.00,--25
			0.000,--26
			0.00,--27
			0.00,--28
			'07',--29
			0.00,--30
			0.00,--31
			0.000,--32
			0.00,--33
			0.00,--34
			v_valor,--35
			0.00,--36
			NULL,--37
			0.00,--38
			-1,--39
			0--40;
		)
		RETURNING id_nf_item;
	
		FETCH vCursor INTO v_id;
		
		CLOSE vCursor;
	
	EXCEPTION WHEN OTHERS  THEN 
	
		RAISE NOTICE 'OCORREU UM ERRO';
	END;
	
	RAISE NOTICE 'Item NF Importado %',v_id;
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
