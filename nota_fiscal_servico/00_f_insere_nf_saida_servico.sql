-- DROP FUNCTION public.f_insere_nf(json);
/*
SELECT * FROM cidades WHERE id_cidade = 5281
--SELECT id_conhecimento, status, cstat FROM scr_conhecimento;
UPDATE scr_conhecimento SET id_conhecimento = id_conhecimento WHERE id_conhecimento = 23;
SELECT * FROM com_nf_itens ORDER BY 1 DESC LIMIT 100;

SELECT max(id_nf) FROM com_nf
SELECT id_conhecimento, status, empresa_emitente, filial_emitente, total_frete FROM scr_conhecimento;

UPDATE com_nf SET id_nf = proximo_numero_sequencia('com_nf_id_nf_seq') WHERE id_nf = 10
UPDATE scr_conhecimento SET empresa_emitente = '010', filial_emitente = '001'
UPDATE scr_conhecimento SET status = 0 WHERE id_conhecimento = 23;
UPDATE scr_conhecimento SET status = 1 WHERE id_conhecimento = 23;
SELECT * FROM cidades WHERE cod_ibge = '5201405'
SELECT * FROM com_nf_itens WHERE id_nf = 10
SELECT lpad('1',5,'0')
--DELETE FROM com_nf
SELECT serie, id_produto_iss, codigo_servico, filial_parametros_iss.aliquota_iss, natureza_tributacao, tipo_tributacao, exigibilidade 
		FROM filial_parametros_iss
			LEFT JOIN filial 
				ON filial.id_filial = filial_parametros_iss.id_filial				
		WHERE 
			filial.codigo_filial = NEW.filial_emitente AND 
			filial.codigo_empresa = NEW.empresa_emitente AND
			filial_parametros_iss.id_cidade = NEW.calculado_de_id_cidade;

UPDATE filial SET inscricao_municipal = '472250'
UPDATE com_nf SET emite_nfse = 1 WHERE id_nf = 11
SELECT * FROM fila_nfse
DELETE FROM fila_nfse 

UPDATE filial_parametros_iss SET codigo_tributacao = '1601'

SELECT * FROM filial


SELECT * FROM nfse_tmp


SELECT f_emite_conhecimento_automatico('{697741}',0,'cf','msg','imposto_cf', 'imposto', 'msg_imposto') as id_conhecimento;

*/

CREATE OR REPLACE FUNCTION public.f_tgg_insere_nf_servico()
  RETURNS trigger AS
$BODY$
DECLARE


	vCursor refcursor;

	vIdNotaFiscalImp integer;
	v_emit_cnpj_cpf text;	
	v_emit_cod_mun text;
	v_servico_cod_mun text;
	v_dest_cnpj_cpf text;
	v_dest_codigo integer;
	v_dest_cod_mun text;
	v_id_produto integer;
	v_valor numeric(12,2);
	v_desconto numeric(12,2);
	v_valor_bc numeric(12,2);
	v_valor_icms numeric(12,2);
	v_aliquota numeric(5,2);

	v_codigo_mercosul text;
	v_iss_csittrib text;
	v_descricao text;	

	v_numero_doc text;
	v_serie text;
	v_unidade text;
	v_modelo text;
	
	v_natureza_operacao text;
	v_id_tipo_emissao integer;
	v_id_tipo_ambiente integer;
	v_id_finalidade_emissao integer;
	v_consumidor integer;

	v_modo_frete text;
	v_sequencia text;

	v_natureza_tributacao integer;
	v_tipo_tributacao integer;
	v_exigibilidade integer;
	v_codigo_servico text;
	v_observacao text;

	v_gera_nfe integer;

BEGIN	
		
		
------------------------------------------------------------------------------------------------------------------
--                             DESERIALIZAÇÃO dos dados de estrutura json	
------------------------------------------------------------------------------------------------------------------	
	--RAISE NOTICE 'Dados Nf: %', dadosNf;
	
	--v_chave_nfe 		= dadosNf->>'nfe_chave_nfe';
	
	IF TG_OP = 'INSERT' THEN 
		RETURN NEW;
	END IF;	

	IF OLD.data_emissao IS NOT NULL AND NEW.data_emissao IS NOT NULL THEN 
		RETURN NEW;
	END IF;

	IF NEW.data_emissao IS NULL THEN 
		RETURN NEW;
	END IF;
	--Buscar no cadastro de cidades
	v_aliquota = 0.05;

	--Prestacao de servico é para o pagador
	v_dest_cnpj_cpf		= NEW.consig_red_cnpj;

	SELECT 
		cidades.cod_ibge, cliente.codigo_cliente, COALESCE(cliente_parametros.valor_parametro::integer,0)
	INTO 
		v_dest_cod_mun, v_dest_codigo, v_gera_nfe
	FROM 
		cliente
		LEFT JOIN cidades
			ON cidades.id_cidade = cliente.id_cidade
		LEFT JOIN cliente_parametros
			ON cliente_parametros.codigo_cliente = cliente.codigo_cliente AND id_tipo_parametro = 151
	WHERE 
		cliente.codigo_cliente = NEW.consig_red_id;


	IF v_gera_nfe = 0 THEN
		RETURN NEW;
	END IF;

	
	--Dados do Emitente	
	v_modo_frete		= NULL;

	SELECT 
		cnpj, cidades.cod_ibge, flg_item_1400_sped_fiscal
	INTO 
		v_emit_cnpj_cpf, v_emit_cod_mun, v_id_produto
	FROM 
		filial
		LEFT JOIN cidades 
			ON cidades.id_cidade = filial.id_cidade		
	WHERE 
		codigo_empresa = NEW.empresa_emitente 
		AND codigo_filial = NEW.filial_emitente;



	
	--SELECT * FROM com_nf ORDER BY 1 DESC LIMIT 100;


	BEGIN 
		v_valor			= NEW.total_frete;
	EXCEPTION WHEN OTHERS THEN 
		v_valor 		= 0.00;
	END;

	BEGIN 
		v_desconto		= 0.00;
	EXCEPTION WHEN OTHERS THEN 
		v_desconto		= 0.00;
	END;


	BEGIN
		v_valor_bc	= NEW.total_frete;
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_bc = 0.00;
	END;

	BEGIN
		v_valor_icms = NEW.total_frete * 0.05;
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_icms = 0.00;
	END;

	
	v_unidade = 'UN';

-----------------------------------------------------------------------------------------------------------------
--- 					GRAVACAO DOS DADOS  
-----------------------------------------------------------------------------------------------------------------
	SET datestyle = "ISO, DMY";	
	

	SELECT 	cod_ibge
	INTO v_servico_cod_mun
	FROM cidades
	WHERE cidades.id_cidade = NEW.calculado_de_id_cidade;


	v_observacao = 'NFSe/NFe referente a Minuta de Transporte ' || NEW.numero_ctrc_filial;
	
	IF v_emit_cod_mun = '5300108' THEN 

		SELECT valor_parametro::integer
		INTO v_id_produto
		FROM cliente_parametros
		WHERE codigo_cliente = v_dest_codigo AND id_tipo_parametro = 150;
		
		SELECT  nfe_serie, nfe_tipo_emissao, nfe_ambiente, COALESCE(v_id_produto, id_produto_iss), aliquota
		INTO 	v_serie, v_id_tipo_emissao, v_id_tipo_ambiente, v_id_produto, v_aliquota
		FROM 	com_nfe_parametros 
		WHERE	codigo_filial = NEW.filial_emitente 
			AND codigo_empresa = NEW.empresa_emitente;
						
		v_modelo = '55';

		IF v_dest_cod_mun = '5300108' THEN 
			v_natureza_operacao = '5933';
		ELSE
			v_natureza_operacao = '6933';
		END IF;

		v_sequencia = 'com_nf_' || NEW.empresa_emitente ||  '_' || NEW.filial_emitente || '_' || v_serie;
	
		v_numero_doc = NEW.empresa_emitente || NEW.filial_emitente || lpad(proximo_numero_sequencia(v_sequencia)::text,7,'0');		
			
				
	ELSE

		SELECT valor_parametro::integer
		INTO v_id_produto
		FROM cliente_parametros
		WHERE codigo_cliente = v_dest_codigo AND id_tipo_parametro = 150;
	
		SELECT serie, COALESCE(v_id_produto, id_produto_iss), codigo_servico, filial_parametros_iss.aliquota_iss, natureza_tributacao, tipo_tributacao, exigibilidade 
		INTO v_serie, v_id_produto, v_natureza_operacao, v_aliquota, v_natureza_tributacao, v_tipo_tributacao, v_exigibilidade
		FROM filial_parametros_iss
			LEFT JOIN filial 
				ON filial.id_filial = filial_parametros_iss.id_filial				
		WHERE 
			filial.codigo_filial = NEW.filial_emitente AND 
			filial.codigo_empresa = NEW.empresa_emitente AND
			filial_parametros_iss.id_cidade = NEW.calculado_de_id_cidade;

		RAISE NOTICE 'ORIGEM %', NEW.calculado_de_id_cidade;
		RAISE NOTICE 'Cod Municipio % ', v_servico_cod_mun;
		RAISE NOTICE 'Serie %', v_serie;

		v_serie = NULL;		
		v_sequencia = 'com_nfse_' || NEW.empresa_emitente ||  '_' || NEW.filial_emitente || '_' || v_servico_cod_mun || '_' || v_serie;
		--v_numero_doc = NEW.empresa_emitente || NEW.filial_emitente || lpad(proximo_numero_sequencia(v_sequencia)::text,7,'0');
		v_numero_doc = NULL;
		
		v_modelo = '00';		
				
	END IF;

	
	--Dados do Produto
	SELECT descr_item, codigo_mercosul, issqn_csittrib  
	INTO v_descricao, v_codigo_mercosul, v_iss_csittrib--, v_natureza_operacao 
	FROM com_produtos 
	WHERE id_produto = v_id_produto;

	IF v_iss_csittrib = 'R' THEN 
		v_observacao = v_observacao || ' *ISS Retido pelo contratante';
	END IF;


	BEGIN 
		OPEN vCursor FOR 		
		INSERT INTO com_nf(
			entrada_saida, --1
			id_natureza_operacao, --2
			id_tipo_emissao, --3
			id_tipo_ambiente, --4
			id_transportador, --5
			id_finalidade_emissao,--6 
			consumidor, --7
			numero_nota_fiscal, --8
			status, --9
			codigo_empresa, --10
			codigo_filial, --11
			cnpj_cpf_cliente, --12
			cnpj_fornecedor, --13
			numero_pedido_saida, --14
			modelo_doc_fiscal, --15
			serie_doc, --16
			sub_serie, --17
			numero_documento, --18
			chave_eletronica, --19
			data_emissao, --20
			data_saida_entrada, --21                        
			tipo_pagamento, --22
			vl_desconto, --23
			vl_abatimento_nt,--24 
			vl_mercadoria, --25
			tipo_frete, --26
			vl_frete, --27
			vl_seguro, --28
			vl_outras_despesas, --29		    
			vl_base_calculo, --29.1
			vl_icms, --30
			vl_base_calculo_st, --31
			vl_icms_st, --32
			vl_ipi, --33
			vl_pis, --34
			vl_cofins, --35
			vl_pis_st, --36
			vl_cofins_st, --37
			vl_total, --38
			observacao, --39
			data_registro, --40
			valor_centro_custo_pred, --41
			status_financeiro, --42
			ind_emit, --43
			id_nf_referenciada, --44
			cstat, --45
			xmotivo, --46
			prot_autorizacao_nfe, --47
			usuario_cancelamento, --48
			xml_proc_cancelamento, --49
			protocolo_cancelamento,  --50
			data_autorizacao, --51
			numero_lote, --52
			xml_nfe_original,--53 
			xml_nfe_com_assinatura, --54
			xml_proc_nfe, --55
			xml_retorno, --56
			numero_recibo, --57
			nro_fatura, --58
			placa_veiculo, --59
			nro_correcoes, --60
			indfinal, --61
			indpres, --62
			iss_dcompet, --63
			id_conhecimento, --64
			natureza_tributacao, --65
			tipo_tributacao_servico, --66
			exigibilidade, --67
			codigo_servico_mun, --68
			id_cidade_iss --69
			
		) VALUES (
			'S',--1
			v_natureza_operacao,--2
			v_id_tipo_emissao,--3
			v_id_tipo_ambiente,--4
			NULL,--5
			1,--6
			0,--7
			v_numero_doc,--8
			0,--9
			NEW.empresa_emitente,--10
			NEW.filial_emitente,--11
			v_dest_cnpj_cpf,--12
			NULL,--13
			NULL,--14
			v_modelo,--15
			v_serie, --16
			NULL,--17
			lpad(right(trim(v_numero_doc),7),9,'0'),--18
			NULL,--19
			NEW.data_emissao,--20
			NULL,--21
			0,--22
			0.00,--23
			0.00,--24
			v_valor,--25
			0,--26
			0.00,--27
			0.00,--28
			0.00,--29
			0.00,--29.1
			0.00,--30
			0.00,--31
			0.00,--32
			0.00,--33
			0.00,--34
			0.00,--35
			0.00,--36
			0.00,--37
			v_valor,--38
			v_observacao, --39
			now(),--40
			0.00,--41
			0,--42
			NULL,--43
			0,--44
			000,--45
			NULL,--46
			NULL,--47
			NULL,--48
			NULL,--49
			NULL,--50
			NULL,--51
			NULL,--52
			NULL,--53
			NULL,--54
			NULL,--55
			NULL,--56
			NULL,--57
			NULL,--58
			NULL,--59
			NULL,--60
			1,--61
			1,--62
			NEW.data_emissao, --63
			NEW.id_conhecimento, --64
			v_natureza_tributacao, --65
			v_tipo_tributacao, --66
			v_exigibilidade, --67
			v_natureza_operacao, --68
			NEW.calculado_de_id_cidade --69
		)
		RETURNING id_nf;

		FETCH vCursor INTO vIdNotaFiscalImp;
		
		CLOSE vCursor;
	
	EXCEPTION WHEN OTHERS  THEN 
	
		RAISE NOTICE 'ERRO %', SQLERRM;
	END;

-----------------------------------------------------------------------------------------------------------------
--- 					GRAVACAO DOS DADOS  
-----------------------------------------------------------------------------------------------------------------
	SET datestyle = "ISO, DMY";

	BEGIN 
			
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
			icms_orig, --40
			issqn_valor_bc, --41
			issqn_aliquota --42			
			
		) VALUES (
			vIdNotaFiscalImp,--1
			v_id_produto,--2
			v_descricao,--3
			1,--4
			'UN',--5
			v_valor,--6
			0.00,--7
			0,--8
			'040',--9
			v_natureza_operacao,--10
			v_natureza_operacao,--11
			0.00,--12
			0.00,--13
			0.00,--14
			0.00,--15
			0.00,--16
			0.00,--17
			52,--18
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
			NULL,--39
			0,
			v_valor_bc,
			v_aliquota
		);
		
	
	EXCEPTION WHEN OTHERS  THEN 
		RAISE NOTICE 'ERRO %', SQLERRM;		
	END;


	
	RAISE NOTICE 'Nota Fiscal de Servico Criada%',vIdNotaFiscalImp;
	RETURN NEW;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

