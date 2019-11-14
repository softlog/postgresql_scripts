-- DROP FUNCTION public.f_insere_nf(json);
CREATE OR REPLACE FUNCTION public.f_insere_nf_saida(dadosNf json)
  RETURNS integer AS
$BODY$
DECLARE

	

	-- Variaveis de Entrada
	v_chave_nfe 		character(44);
	v_modo_frete		character(1);
	v_emit_cnpj_cpf 	character(14);
	v_emit_cod_mun		character(8);
	v_dest_cnpj_cpf		character(14);
	v_transportador_cnpj_cpf character(14);
	v_dest_cod_mun		character(8);
	v_data_emissao		date;
	v_numero_doc		character(9);
	v_modelo		character(2);
	v_serie			character(3);
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
	

	v_placa_veiculo_eng	character(8);
	v_placa_reboque1_eng	character(8);
	v_placa_reboque2_eng	character(8);
	
	v_placa_veiculo		character(8);
	v_placa_reboque1	character(8);
	v_placa_reboque2	character(8);
	
	v_inf 			text;
	v_ind_final		integer;
	v_ie_dest		text;
	v_tp_nf			integer;

	--Integracao Softlog
	v_pagador_cnpj_cpf	character(14);	
	v_id_doc_parceiro	integer;
	v_id_rom_parceiro	integer;
	v_id_nf_cte_parceiro	integer;
	v_id_cte_parceiro	integer;
	v_codigo_integracao	integer;
	v_codigo_parceiro	integer;
	
	v_data_emissao_hr	timestamp;

	v_volume_cubico_edi	numeric(16,6);
	v_numero_pedido_edi	text;
	v_numero_romaneio_edi	text;

	-- Variadas Processadas
	v_cnpj_cpf_aux		character(14);
	v_volume_cubico 	numeric(16,6);	
	vCidadeFilial		integer;
	vCidadeRemetente	integer;
	vCidadeOrigem		integer;
	vCidadeDestino		integer;
	vCidadeAgentePadrao	integer;
	vCidadeOrigemCte	text;
	vCifFob			integer;
	vCodigoRemetente	integer;
	vCodigoDestinatario	integer;
	vCodigoConsignatario 	integer;
	vCodigoPagador		integer;	
	vTabelaFrete		text;	
	vCodigoTransportador	integer;
	vTipoDocumento		integer;
	vTipoCtrcCte		integer;
	vTipoTransporte		integer;
	vNaturezaCarga		text;
	vIdNotaFiscalImp	integer;
	vCodigoModelo		integer;
	vAvista			integer;
	

	-- Variaveis de ambiente
	vEmpresa		character(3);
	vFilial			character(3);
	vFilialFixa		character(3);
	vLogin			text;
	vUsuario		integer;
	vModuloCte		text;
	v_modal			integer;
	vOrigemFilial		integer;
	vSerieCte		integer;
	vUsaFilialResponsavel   integer;
	

	-- Variaveis de Processamento
	vCursor 		refcursor;
	vExiste 		integer;
	vCancelado		integer;
	vIdConhecimento		integer;
	vCmd			text;	
	vLstLog			text;
	vArrayLog		text[];
	vQtLog			integer;
	vFormaPagamento		text;
	vEmiteCte		integer;
	vModoFretePadrao	integer;
	vVolumeNoItemNota	integer;
	vFobDirigido		integer;
	vTermo			text;
	vCodInternoFrete	text;
	vParametros		json;
	v_filial_responsavel    character(3);
	v_cod_vendedor		text;
	v_cobrar_tx_coleta	integer;
	v_cobrar_tx_entrega	integer;
	v_cobrar_tx_dc		integer;	
	v_cobrar_tx_de		integer;	
	v_tipo_transporte 	integer;
	v_tag_codigo_segmento 	text;
	v_codigo_segmento	text;
	v_contribuinte		integer;
	v_tipo_contribuinte_dest text;	
	v_imposto_incluso	integer;
	v_imposto_por_conta	integer;
	v_imposto_incluso_tabela integer;
	vUnidadeTonelada	text;
	v_is_tonelada		boolean;
	v_captcha_img		text;
	v_captcha_txt		text;
	v_tabela_redespacho	text;
	v_id_cidade_origem_redespacho integer;
	vCidadeConsignatario	integer;
	v_usa_primeira_tag_vol  integer;
	v_exp_vol_pres		text;
	v_exp_pes_pres		text;
	v_exp_pes_liq		text;
	v_array_vol		text[];
	v_array_pesB		text[];
	v_array_pesL		text[];
	vCodigoPedido		text;
	vOrigemCalculo		integer;
	v_chave_cte		text;	
	v_tipo_transporte_par	integer;
	v_forca_importacao	integer;
	v_uf_rem		text;
	v_modo_frete_rem 	text;
	v_placas_reboque	text;
	v_array_placas_reboque  text[];
	v_forca_fob		integer;
	v_parametros_dest	json;
	v_expedidor_cnpj 	text;
	v_viagem_automatica 	integer;
	v_cidade_subcontrato_par integer;
	v_valor_cte_origem	numeric(12,2);

BEGIN	

	
--SELECT * FROM com_nf ORDER BY 1 DESC LIMIT 100
	
------------------------------------------------------------------------------------------------------------------
--                             DESERIALIZAÇÃO dos dados de estrutura json	
------------------------------------------------------------------------------------------------------------------	
	--RAISE NOTICE 'Dados Nf: %', dadosNf;
	
	v_chave_nfe 		= dadosNf->>'nfe_chave_nfe';
	v_modo_frete		= dadosNf->>'nfe_modo_frete';
	v_emit_cnpj_cpf 	= dadosNf->>'nfe_emit_cnpj_cpf';
	v_emit_cod_mun		= dadosNf->>'nfe_emit_cod_mun';
	v_dest_cnpj_cpf		= dadosNf->>'nfe_dest_cnpj_cpf';
	v_dest_cod_mun		= dadosNf->>'nfe_dest_cod_mun';
	v_transportador_cnpj_cpf= dadosNf->>'nfe_dest_cod_mun';
	v_data_emissao		= dadosNf->>'nfe_data_emissao';
	v_data_emissao_hr	= COALESCE((dadosNf->>'nfe_data_emissao_hr')::text,NULL)::timestamp;
	v_numero_doc		= dadosNf->>'nfe_numero_doc';
	v_modelo		= dadosNf->>'nfe_modelo';
	v_serie			= dadosNf->>'nfe_serie';	
	v_cfop_predominante   	= dadosNf->>'nfe_cfop_predominante';	

	BEGIN 
		v_valor			= ((dadosNf->>'nfe_valor')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_valor 		= 0.00;
	END;

	BEGIN 
		v_desconto		= ((dadosNf->>'nfe_valor_desc')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_desconto		= 0.00;
	END;


	BEGIN
		v_valor_bc	= ((dadosNf->>'nfe_valor_bc')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_bc = 0.00;
	END;

	BEGIN
		v_valor_icms = ((dadosNf->>'nfe_valor_icms')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_icms = 0.00;
	END;

	BEGIN
		v_valor_bc_st	= ((dadosNf->>'nfe_valor_bc_st')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_bc_st = 0.00;
	END;

	BEGIN
		v_valor_icms_st	= ((dadosNf->>'nfe_valor_icms_st')::text)::numeric(12,2);	
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_icms_st = 0.00;
	END;
	
	v_unidade		= dadosNf->>'nfe_unidade';

	BEGIN 
		v_valor_produtos	= ((dadosNf->>'nfe_valor_produtos')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_produtos	= 0.00;
	END;


		


	--RAISE NOTICE 'dados: %', dadosNf;	
	
	v_inf			= dadosNf->>'nfe_informacoes';
	v_ind_final		= COALESCE(((dadosNf->>'nfe_ind_final')::text)::integer,0);
	v_ie_dest		= COALESCE(((dadosNf->>'nfe_ie_dest')::text),'1');
	v_tp_nf			= COALESCE(((dadosNf->>'nfe_tp_nf')::text)::integer,1);

	v_forca_importacao	= COALESCE(((dadosNf->>'forca_importacao')::text)::integer,0);


------------------------------------------------------------------------------------------------------------------
--                                    RECUPERA variaveis de ambiente
------------------------------------------------------------------------------------------------------------------	
	vEmpresa 	= fp_get_session('pst_cod_empresa');
	vFilial  	= fp_get_session('pst_filial');
	vLogin		= fp_get_session('pst_login');
	vUsuario	= fp_get_session('pst_usuario');



------------------------------------------------------------------------------------------------------------------
--                                     VERIFICA SE NFE JA EXISTE
------------------------------------------------------------------------------------------------------------------
	--SELECT * FROM com_nf ORDER BY 1 DESC LIMIT 100
	IF v_chave_nfe = '' THEN 
		v_chave_nfe = NULL;
	END IF;
	
	IF v_forca_importacao = 0 THEN 
		
		-- Verifica se a nota já não está importada
		BEGIN 
			SELECT	
				COUNT(*) as qt
			INTO 	
				vExiste
			FROM 
				com_nf nf
			WHERE 
				chave_eletronica = v_chave_nfe;
				
		EXCEPTION WHEN OTHERS  THEN
			vExiste = 0;
		END;
		
	END IF;	


------------------------------------------------------------------------------------------------------------------
--                                          PESO E VOLUMES
------------------------------------------------------------------------------------------------------------------	
	
	v_exp_vol_pres = COALESCE((dadosNf->>'nfe_volume_presumido')::text,'0.00'::text);
	IF trim(v_exp_vol_pres) = '' THEN 
		v_exp_vol_pres = '0.00';
	END IF; 

	v_exp_pes_liq  = COALESCE((dadosNf->>'nfe_peso_liquido')::text,'0.00'::text);
	IF trim(v_exp_pes_liq) = '' THEN 
		v_exp_pes_liq = '0.00';
	END IF;

	v_exp_pes_pres = COALESCE((dadosNf->>'nfe_peso_presumido')::text,'0.00'::text); 	
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
	IF trim((dadosNf->>'nfe_volume_produtos')::text) = '' THEN
		vCmd = 'SELECT 0 as volume_produtos ' ;
	ELSE	
		vCmd = '';
		vCmd = vCmd || 'SELECT ' ;
		vCmd = vCmd || COALESCE((dadosNf->>'nfe_volume_produtos')::text,'0'::text) || ' as volume_produtos ';
	END IF;

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN 
		FETCH vCursor INTO v_volume_produtos;
	EXCEPTION WHEN OTHERS THEN 
		v_volume_produtos = 0;
	END;

	
	CLOSE vCursor;

	IF trim((dadosNf->>'nfe_peso_produtos')::text) = '' THEN 
		vCmd = 'SELECT 0.00 as peso_produtos';
	ELSE
		vCmd = '';
		vCmd = vCmd || 'SELECT ' ;
		vCmd = vCmd || COALESCE((dadosNf->>'nfe_peso_produtos')::text,'0.00'::text) || ' as peso_produtos ';
	END IF;

	OPEN vCursor FOR EXECUTE vCmd;

	BEGIN 
		FETCH vCursor INTO v_peso_produtos;
	EXCEPTION WHEN OTHERS THEN 
		v_peso_produtos = 0.00;
	END;

	CLOSE vCursor;


	IF v_volume_cubico IS NULL THEN
		v_volume_cubico = 0.0000;
	END IF;


-----------------------------------------------------------------------------------------------------------------
--- 					GRAVACAO DOS DADOS  
-----------------------------------------------------------------------------------------------------------------
	SET datestyle = "ISO, DMY";

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
		    indpres --62
	     ) VALUES (
			'S',--1
			v_cfop_predominante,--2
			1,--3
			1,--4
			NULL,--5
			1,--6
			1,--7
			vEmpresa || vFilial || RIGHT(lpad(trim(v_numero_doc),7,'0'),7),--8
			1,--9
			vEmpresa,--10
			vFilial,--11
			v_dest_cnpj_cpf,--12
			NULL,--13
			NULL,--14
			v_modelo,--15
			v_serie, --16
			NULL,--17
			lpad(trim(v_numero_doc),9,'0'),--18
			v_chave_nfe,--19
			v_data_emissao_hr,--20
			v_data_emissao_hr,--21
			0,--22
			v_desconto,--23
			0.00,--24
			v_valor_produtos,--25
			9,--26
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
			v_inf,--39
			v_data_emissao_hr,--40
			0.00,--41
			0,--42
			NULL,--43
			0,--44
			100,--45
			'Autorizado o uso da NF-e',--46
			NULL,--47
			NULL,--48
			NULL,--49
			NULL,--50
			v_data_emissao_hr,--51
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
			1--62
		)
		RETURNING id_nf;
	
		FETCH vCursor INTO vIdNotaFiscalImp;
		
		CLOSE vCursor;
	
	EXCEPTION WHEN OTHERS  THEN 
	
		RAISE NOTICE 'OCORREU UM ERRO';
	END;
	
	RAISE NOTICE 'Nota Fiscal de Saida Importada %',vIdNotaFiscalImp;
	RETURN vIdNotaFiscalImp;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

