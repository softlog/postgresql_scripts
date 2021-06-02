-- Function: public.f_scr_nf_imp_processamento(integer)

-- DROP FUNCTION public.f_scr_nf_imp_processamento(integer);

CREATE OR REPLACE FUNCTION public.f_scr_nf_imp_processamento(p_id_nota_fiscal_imp integer)
  RETURNS integer AS
$BODY$
DECLARE

	-- Variaveis de Entrada
	v_chave_nfe 		character(44);
	v_modo_frete		character(1);
	v_emit_cnpj_cpf 	character(14);
	v_emit_cod_mun		character(8);
	v_dest_cnpj_cpf		character(14);
	v_dest_cod_mun		character(8);
	v_data_emissao		date;
	

	-- Variadas Processadas
	v_volume_cubico 	numeric(12,4);
	vCidadeFilial		integer;
	vCidadeOrigem		integer;
	vCidadeDestino		integer;
	vCifFob			integer;
	vCodigoRemetente	integer;
	vCodigoDestinatario	integer;
	vCodigoPagador		integer;
	vTabelaFrete		text;
	vTipoDocumento		integer;
	vTipoCtrcCte		integer;
	vTipoTransporte		integer;
	vNaturezaCarga		text;
	vIdNotaFiscalImp	integer;
	vCodigoModelo		integer;
	vAvista			integer;
	v_cobrar_tx_coleta	integer;
	v_cobrar_tx_entrega	integer;
	v_cobrar_tx_dc		integer;	
	v_cobrar_tx_de		integer;	

	

	-- Variaveis de ambiente
	vEmpresa		character(3);
	vFilial			character(3);
	vLogin			text;
	vUsuario		integer;
	vModuloCte		text;
	v_modal			integer;
	vOrigemFilial		integer;
	vSerieCte		integer;

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
	
	
BEGIN	
	
	SELECT 
		CASE WHEN COALESCE(frete_cif_fob,1) = 1 THEN '0' ELSE '1' END::text as modo_frete,
		remetente_id,
		remetente_id_cidade,
		destinatario_id, 
		destinatario_id_cidade		
	INTO 
		v_modo_frete,		
		vCodigoRemetente,
		vCidadeOrigem,
		vCodigoDestinatario,
		vCidadeDestino
	FROM 
		v_mgr_notas_fiscais
	WHERE
		id_nota_fiscal_imp = p_id_nota_fiscal_imp;
	
		
-- 	RECUPERA variaveis de ambiente
	vEmpresa 		= fp_get_session('pst_cod_empresa');
	vFilial  		= fp_get_session('pst_filial');
	vModuloCte 		= fp_get_session('pst_modulo_cte');
	vLogin			= fp_get_session('pst_login');
	vUsuario		= fp_get_session('pst_usuario');
	v_modal			= fp_get_session('pst_modal');
	vOrigemFilial 	= fp_get_session('pst_usar_origem_de_filial');
	vSerieCte		= fp_get_session('pst_serie_cte');
	

-- 	PROCESSO DE TRANSFORMAÇÃO DE DADOS
	
	-- 1 - Se Modelo for 04, mudar para 01
	vCodigoModelo = 1;
	
	-- 5 - Get cidade da filial caso o padrão seja origem da filial
	IF vOrigemFilial = 1 THEN 
		SELECT 	id_cidade 
		INTO 	vCidadeOrigem
		FROM 	filial 
		WHERE 	codigo_filial = vFilial 
			AND codigo_empresa = vEmpresa;
	END IF;

	-- 6 - Recuperar informações sobre taxas de coleta e entrega
	--Coleta
	SELECT	
		cobrar_tx_coleta,
		cobrar_tx_dce
	INTO	
		v_cobrar_tx_coleta,
		v_cobrar_tx_dc
	FROM	
		cliente c
	WHERE	
		c.codigo_cliente = vCodigoRemetente;

	--Entrega
	SELECT	
		cobrar_tx_entrega,
		cobrar_tx_dce
	INTO	
		v_cobrar_tx_entrega,
		v_cobrar_tx_de
	FROM	
		cliente c
	WHERE	
		c.codigo_cliente = vCodigoDestinatario;


	-- 8 - Set Cif Fob e Cliente Pagador (Remetente, Destinatario ou Terceiro)
	IF v_modo_frete = '0' THEN 
		vCifFob = 1;
		
		SELECT	
			pag.codigo_cliente,
			pag.formas_pgto
		INTO	
			vCodigoPagador,
			vFormaPagamento
		FROM	
			cliente c
			LEFT JOIN cliente pag 
				ON c.cnpj_cpf_responsavel = pag.cnpj_cpf			
		WHERE	
			c.codigo_cliente = vCodigoRemetente;
	ELSE
		vCifFob = 2;

		SELECT	pag.codigo_cliente,
			pag.formas_pgto
		INTO	vCodigoPagador,
			vFormaPagamento		
		FROM	cliente c
			LEFT JOIN cliente pag 
			ON c.cnpj_cpf_responsavel = pag.cnpj_cpf		
		WHERE	
			c.codigo_cliente = vCodigoDestinatario;
	END IF;
	
	IF vFormaPagamento = 'A VISTA' THEN 
		vAvista = 1;
	ELSE
		vAvista = 2;
	END IF;
	
	-- 9 - Set Tabela de Frete	
	SELECT 	tabela_padrao 
	INTO	vTabelaFrete
	FROM 	cliente 
	WHERE 	codigo_cliente = vCodigoPagador;

	IF vTabelaFrete IS NULL THEN 
		SELECT 	numero_tabela_frete
		INTO	vTabelaFrete
		FROM 	scr_tabelas
			LEFT JOIN cliente ON cliente.cnpj_cpf = scr_tabelas.cnpj_cliente
		WHERE 	cliente.codigo_cliente = vCodigoPagador AND scr_tabelas.ativa = 1;		
	END IF;

	-- 11 - Set tipo do documento
	IF vCidadeOrigem = vCidadeDestino THEN 
		vTipoDocumento = 2;
		vTipoCtrcCte = NULL;
	ELSE 
		vTipoDocumento = 1;
		vTipoCtrcCte   = 2;
	END IF;

	-- 12 - Set tipo do transporte
--	vTipoTransporte = 1;

		
	
--- 	PERSISTÊNCIA dos Dados 
	UPDATE scr_notas_fiscais_imp SET 
		tipo_documento 			= vTipoDocumento, 
		modal 				= v_modal, 
		tipo_ctrc_cte 			= vTipoCtrcCte, 
		-- tipo_transporte 		= vTipoTransporte,
		frete_cif_fob			= vCifFob, 
		calculado_de_id_cidade		= vCidadeOrigem, 
		calculado_ate_id_cidade		= vCidadeDestino, 
		--consignatario_id		= vCodigoPagador, 
		classificacao_fiscal		= 'COMERCIO', 
		avista				= vAvista, 
		numero_tabela_frete		= vTabelaFrete, 
		modelo_nf			= vCodigoModelo, 
		tipo_nota			= 2, 		
		id_usuario 			= vUsuario, 
		empresa_emitente		= vEmpresa,
		filial_emitente 		= vFilial,
		coleta_normal			= v_cobrar_tx_coleta, 
		coleta_dificuldade		= v_cobrar_tx_dc, --66
		entrega_normal			= v_cobrar_tx_entrega, --67
		entrega_dificuldade 		= v_cobrar_tx_de--68
        WHERE
		id_nota_fiscal_imp 		= p_id_nota_fiscal_imp;


	RETURN p_id_nota_fiscal_imp;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_scr_nf_imp_processamento(integer)
  OWNER TO softlog_dng;
