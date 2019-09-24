-- DROP FUNCTION public.f_insere_nf(json);
CREATE OR REPLACE FUNCTION public.f_insere_nf(dadosNf json)
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

	-- Alterações: 26/03/2015
	-- 1 - Reconstrução do código que captura os dados das informações da nfe.
	-- 1.1 Gravação do código interno de frete, recuperado na nfe do cliente.
	-- 1.2 Tratamento do volume_no_item presumido.
	-- 1.3 Tratamento do fob dirigido. Quando o pagador não tem tabela frete, 
	--     pega a tabela do remetente.
	
	-- Alterações: 01/04/2015
	-- 1 - Correção da extração do VALOR_CUBICO da inf da nfe, 
	--     quando retorna uma string vazia

	-- Alterações: 28/04/2015
	-- 1 - Verificar campo filial_responsavel do cadastro do remetente e 
	-- 	importar a nota para a filial correta. A Pedido da Jetlog.

	-- Alterações: 01/06/2015
	-- 1 - Atualização de dois novos campos
	--	1.1 - peso_liquido
	--	1.2 - especie_mercadoria (lista das ucom das nfes)

	-- Alterações: 10/06/2015
	-- 1 - Adicionado variável para definir se usa filial responsável na
	--	importação da nota.

	-- Alterações: 28/07/2015
	-- 1 - Extração do código do vendedor

	-- Alterações: 14/09/2015
	-- 1 - Setar informações sobre parametros de taxas de coletas e entregas

	-- Alterações: 30/09/2015	
	-- 1 - Identificar se o tipo de transporte é Transferência

	-- Alteracoes: 15/10/2015
	-- 1 - Extração do código de segmento para gravar natureza da carga correspondente


	-- Alteracoes: 28/01/2016
	-- 1 - Extração de informação da nfe das tags infFinal e indIEDest 
	-- 2 - Determinacao do Calculo de Difal v_contribuinte e v_calcula_difal

	-- Alteracoes: 13/03/2016
	-- 1 - Correcao da extracao do peso liquido e peso bruto 
	--    quando o mesmo vem em mais de um item vol da nfe
	-- 2 - Extrai informacao para saber se a unidade do produto é indicado por tonelada

	-- Alteracoes: 08/04/2016
	-- 1 - Inversão de Remetente quando for nota de entrada

	-- Alteracoes: 11/07/2016
	-- 1 - Extração da tag de informações dados referentes a quebra de captcha 
	---     no processo de importação automática

	-- Alteracoes: 29/07/2016
	-- 1 - Definir o peso líquido com o peso bruto quando o peso líquido estiver vazio e o bruto não.
	-- 2 - Definir o peso bruto com o peso líquido quando o peso líquido estiver vazio e o bruto não.

	-- Alteracoes: 04/08/2016
	-- 1 - Definir tabela de redespacho caso houver
	-- 2 - Setar cidade origem do redespacho

	-- Alteracoes: 07/10/2016
	-- 1 - Inserção de dados do consignatario da carga para redespacho


	-- Alteracoes: 25/10/2016	
	-- 1 - Alteracao da Regra Especial da Jetlog para definir filial responsavel: 
	--     Para mudar filial, uf de origem tem que ser Distrito Federal

	-- Alteracoes: 26/10/2016
	-- 1 - Acrescentado chave_cte nos parametros de entrada

	-- Alteracoes: 16/11/2016
	-- 1 - Importa nota duplicada se esta for do tipo reentrega ou devolução no parceiro


	-- Alteracoes: 28/11/2016
	-- 1 - Implementação de parametro forca_importacao, se for 1, importa mesmo que a nota já exista
	-- 2 - Grava log de nota não importada

	-- Alteracoes: 04/04/2017
	-- 1 - Verificar nos parametros de cliente se é para usar apenas uma tag de volumes.

	-- Alteracoes: 19/04/2017
	-- 1 - Tratamento de erros dos valores numéricos

	-- Alteracoes: 24/05/2017
	-- 1 - Seta Dificuldade de Entrega para clientes associados a fornecedores. 
		-- Recurso utilizado no modulo Embarcador

	-- Alteracoes: 05/07/2017
	-- 1 - Extracao da tag de informacoes codigo do pedido da NFe

	-- Alteracoes: 20/07/2017
	-- 1 - Importacao da data de emissao como timestamp
	-- 2 - Extracao da tag de informacoes Natureza da Carga
	-- 3 - Leitura do Parametro do Cliente Tipo Documento
	-- 4 - Extração da tag de cnpj do transportador
	-- 5 - Leitura do parametro do Cliente Cidade Origem Calculo

	-- Alteracaoes: 11/09/2017
	-- 1 - Alinhamento das placas de veiculos de acordo com os engates no sistema
		
	-- Alteracaoes: 28/09/2017
	-- 1 - Cria uma conta financeira para o remetente

	-- Alteracaoes: 25/10/2017
	-- 1 - Correção do modo de frete fob, de 2 para 1

	-- Alteracoes: 30/10/2017
	-- 1 - Tratamento de erro, quando violar regra de não duplicar a nota

	-- Alteracoes: 09/01/2018
	-- 1 - Alteracao da precisao volume cubico
	-- 2 - Importacao de volume cubico quando vier de edi
	-- 3 - Importacao do numero do pedido polishop
	-- 4 - Importacao do numero de romaneio polishop

	-- Alteracoes: 03/07/2018
	-- 1 - Leitura de parametro no Destinatario, para ver se ele é pagador

	-- Alteracoes: 17/08/2018
	-- 1 - Coleta de campos de integração Softlog. id_conhecimento_notas_fiscais, id_conhecimento,
	--     id_nota_fiscal_imp, codigo_integracao e codigo_parceiro_softlog

	-- Alteracoes: 14/12/2018
	-- 1 - Extracao do parametro cnpj do expedidor

	-- Alteracoes: 16/01/2018
	-- 1 - Gravar peso na coluna peso_transportado, para poder distinguir o peso utilizado 
	-- no calculo do frete com o peso realmente transportado nas operacoes com carga liquida
	-- 2 - Verificar parametro viagem automatica e gravar flag na nota fiscal


	-- Alteracoes: 07/03/2019
	-- 1 - Setar subcontrato somente quando remetente for diferente de pagador

	-- Alteracoes: 26/03/2019
	-- 1 - Nova coluna na nota fiscal: total_frete_origem

	-- Alteracoes: 10/05/2019
	-- 1 - Valor Padrao para Modal - Valor 1

	-- Alteracoes: 19/09/2019
	-- A partir de agora, estas observações estarão no controle de versão do GIT.
	

	
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
	v_placa_veiculo		= dadosNf->>'nfe_placa_veiculo';
	v_placa_reboque1	= dadosNf->>'nfe_placa_reboque1';
	v_placa_reboque2	= dadosNf->>'nfe_placa_reboque2';
	vCodigoPedido		= dadosNf->>'nfe_numero_pedido';

	BEGIN 
		v_valor			= ((dadosNf->>'nfe_valor')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_valor = 0.00;
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

	v_especie_mercadoria	= dadosNf->>'nfe_especie_mercadoria';
	v_unidade		= dadosNf->>'nfe_unidade';

	BEGIN 
		v_valor_produtos	= ((dadosNf->>'nfe_valor_produtos')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS  THEN 
		v_valor_produtos	= 0.00;
	END;


	BEGIN 
		v_volume_cubico_edi	= ((dadosNf->>'nfe_volume_cubico')::text)::numeric(16,6);
	EXCEPTION WHEN OTHERS  THEN 
		v_volume_cubico_edi	= NULL;
	END;

	


	--RAISE NOTICE 'dados: %', dadosNf;
	
	v_cfop_predominante	= dadosNf->>'nfe_cfop_predominante';
	v_inf			= dadosNf->>'nfe_informacoes';
	v_ind_final		= COALESCE(((dadosNf->>'nfe_ind_final')::text)::integer,0);
	v_ie_dest		= COALESCE(((dadosNf->>'nfe_ie_dest')::text),'1');
	v_tp_nf			= COALESCE(((dadosNf->>'nfe_tp_nf')::text)::integer,1);

	--Dados de Integracao Softlog
	v_pagador_cnpj_cpf	= dadosNf->>'nfe_pagador_cnpj_cpf';
	v_id_doc_parceiro	= COALESCE(((dadosNf->>'nfe_id_nota_fiscal_parceiro')::text)::integer,1);
	v_id_rom_parceiro	= COALESCE(((dadosNf->>'nfe_id_romaneio_parceiro')::text)::integer,1);
	v_id_nf_cte_parceiro	= COALESCE(((dadosNf->>'nfe_id_conhecimento_notas_fiscais')::text)::integer,1);
	v_id_cte_parceiro	= COALESCE(((dadosNf->>'nfe_id_conhecimento_parceiro')::text)::integer,1);
	v_codigo_integracao 	= COALESCE(((dadosNf->>'nfe_codigo_integracao')::text)::integer,1);
	v_codigo_parceiro	= COALESCE(((dadosNf->>'nfe_codigo_softlog_parceiro')::text)::integer,1);
	
	
	v_chave_cte		= dadosNf->>'chave_cte';
	BEGIN 
		v_valor_cte_origem = ((dadosNf->>'nfe_valor_cte_origem')::text)::numeric(12,2);
	EXCEPTION WHEN OTHERS THEN 
		v_valor_cte_origem = 0.00;
	END;
	
	v_tipo_transporte_par	= COALESCE(((dadosNf->>'tipo_transporte')::text)::integer,1);
	v_forca_importacao	= COALESCE(((dadosNf->>'forca_importacao')::text)::integer,0);


------------------------------------------------------------------------------------------------------------------
--                                    RECUPERA variaveis de ambiente
------------------------------------------------------------------------------------------------------------------	
	vEmpresa 	= fp_get_session('pst_cod_empresa');
	vFilial  	= fp_get_session('pst_filial');
	vModuloCte 	= fp_get_session('pst_modulo_cte');
	vLogin		= fp_get_session('pst_login');
	vUsuario	= fp_get_session('pst_usuario');
	v_modal		= fp_get_session('pst_modal');

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	vOrigemFilial 
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_USAR_ORIGEM_DE_FILIAL';	 	


	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	v_viagem_automatica 
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_VIAGEM_AUTOMATICA';	 	


------------------------------------------------------------------------------------------------------------------
--                                     VERIFICA SE NFE JA EXISTE
------------------------------------------------------------------------------------------------------------------
	--RAISE NOTICE 'Tipo Transporte Par %', v_tipo_transporte_par;
	IF v_pagador_cnpj_cpf IS NOT NULL THEN 
		--RAISE NOTICE 'TEM PAGADOR';
		IF trim(v_pagador_cnpj_cpf) <> trim(v_emit_cnpj_cpf) THEN 
			--RAISE NOTICE 'SUBCONTRATO';
			v_tipo_transporte_par = 18;
		END IF;
		
	END IF;

		
	IF v_tipo_transporte_par = 18 THEN	
	
		SELECT count(*)
		INTO   v_forca_importacao
		FROM   filial
		WHERE  cnpj = v_pagador_cnpj_cpf;

		IF v_forca_importacao > 1 THEN 
			v_forca_importacao = 1;
		END IF;
	END IF;

	IF v_chave_nfe = '' THEN 
		v_chave_nfe = NULL;
	END IF;
	
	IF v_tipo_transporte_par NOT IN (2,3) AND v_forca_importacao = 0 THEN 

		SELECT 	codigo_cliente
		INTO 	vCodigoRemetente
		FROM 	cliente
		WHERE   cnpj_cpf = v_emit_cnpj_cpf;


		--Verifica quantos conhecimentos não cancelados existem para a nota
		IF v_chave_nfe IS NULL THEN 
				
			SELECT 
				count(*)
			INTO 
				vExiste
			FROM 
				scr_conhecimento_notas_fiscais nf
				LEFT JOIN scr_conhecimento c
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE 
				remetente_id = vCodigoRemetente
				AND ltrim(nf.serie_nota_fiscal,'0')  = ltrim(v_serie,'0')
				AND nf.numero_nota_fiscal::integer = v_numero_doc::integer;
		ELSE

			SELECT	
				COUNT(*) as qt		
			INTO 	
				vExiste
			FROM 
				scr_conhecimento_notas_fiscais nf
				LEFT JOIN scr_conhecimento c ON c.id_conhecimento = nf.id_conhecimento				
			WHERE 			
				c.cancelado = 0
				AND c.tipo_documento IN (1,2)
				AND nf.chave_nfe = v_chave_nfe;	
		END IF;
			
		IF vExiste IS NOT NULL THEN 
			
			IF vExiste > 0 THEN 
				RAISE NOTICE 'Já existe conhecimento com a chave desta NFe. %',v_chave_cte;
				INSERT INTO scr_notas_fiscais_nao_imp (
					dados_parametros,
					numero_nota_fiscal,
					serie_nota_fiscal,
					remetente_id,
					observacao
				) VALUES (
					(dadosNf::jsonb || '{"forca_importacao":"1"}'::jsonb)::text,
					v_numero_doc,
					v_serie,					
					vCodigoRemetente,
					'Já existe conhecimento com a chave desta NFe.'
				);			
				RETURN 0;
			END IF;
		END IF;


		-- Verifica se a nota já não está importada
		BEGIN 
			SELECT	
				COUNT(*) as qt		
			INTO 	
				vExiste
			FROM 
				scr_notas_fiscais_imp nf
			WHERE 
				nf.id_conhecimento IS NULL
				--AND nf.chave_nfe = v_chave_nfe;	
	-- 			AND ltrim(nf.numero_nota_fiscal,'0') = ltrim(v_numero_doc,'0')
	-- 			AND ltrim(nf.serie_nota_fiscal,'0')  = ltrim(v_serie,'0')
				AND nf.numero_nota_fiscal::integer = v_numero_doc::integer
				AND ltrim(nf.serie_nota_fiscal,'0')  = ltrim(v_serie,'0')
				AND nf.remetente_id = vCodigoRemetente;
		EXCEPTION WHEN OTHERS  THEN
			vExiste = 0;
		END;

		IF COALESCE(vExiste,0) > 0 THEN 
			
			IF vExiste > 0 THEN 
				RAISE NOTICE 'Nota Fiscal já importada. Quantidade: % ', vExiste;
				INSERT INTO scr_notas_fiscais_nao_imp (
					dados_parametros,
					numero_nota_fiscal,
					serie_nota_fiscal,
					remetente_id,
					observacao
				) VALUES (
					(dadosNf::jsonb || '{"forca_importacao":"1"}'::jsonb)::text,
					v_numero_doc,
					v_serie,					
					vCodigoRemetente,
					'Nota Fiscal já importada. ' || COALESCE(v_chave_cte,'')
				);			
				RETURN 0;
			END IF;
			
		--v_pagador_cnpj_cpf			
		END IF;	
	END IF;	

	--RAISE NOTICE 'NOTA NAO EXISTE';
------------------------------------------------------------------------------------------------------------------
--          	                       DADOS de quebra de Captcha automático
------------------------------------------------------------------------------------------------------------------	
	vTermo = '#Captcha_img:';	
	v_captcha_img = fpy_extrai_valor(v_inf,TRIM(vTermo));

	vTermo = '#Captcha_txt:';
	v_captcha_txt = fpy_extrai_valor(v_inf,TRIM(vTermo));
	
	IF v_captcha_img IS NOT NULL AND COALESCE(trim(v_captcha_img),'') <> '' THEN 
		INSERT INTO captcha_log (
			login_name,
			data_transacao,
			chave_nfe,
			imagem_captcha,
			banco_dados
		)
		VALUES (
			vLogin,
			now(),
			v_chave_nfe,
			v_captcha_img,
			current_database()
		);
	END IF;
		
	
	--PERFORM f_debug('dados NFe ' || v_chave_nfe, dadosNf::text);

	--PERFORM f_debug('Parametros NF',dadosNf::text);

------------------------------------------------------------------------------------------------------------------
--          	                       Inverte Remetente/Destinatario
------------------------------------------------------------------------------------------------------------------	
	-- Inversao do Remetente quando nota fiscal for de entrada
	IF v_tp_nf = 0 THEN 
		v_cnpj_cpf_aux 	= v_emit_cnpj_cpf;
		v_emit_cnpj_cpf = v_dest_cnpj_cpf;
		v_dest_cnpj_cpf = v_cnpj_cpf_aux;
	END IF;


------------------------------------------------------------------------------------------------------------------
--          	                       Dados do Destinatario
------------------------------------------------------------------------------------------------------------------	
	-- Recupera dados do destinatario
	SELECT 	
		c.codigo_cliente,
		c.id_cidade,
		c.cobrar_tx_entrega,
		c.cobrar_tx_dce,
		c.tipo_contribuinte,
		('{' || COALESCE(string_agg('"' || nome_parametro 
		     || '":"' || valor_parametro || '"',',')
		,'"Parametros":"Inexistente"') || '}')::json as parametros		
	INTO 	
		vCodigoDestinatario,
		vCidadeDestino,		
		v_cobrar_tx_entrega,
		v_cobrar_tx_de,
		v_tipo_contribuinte_dest,
		v_parametros_dest
	FROM 	
		cliente c
		LEFT JOIN cliente_parametros cc 
			ON c.codigo_cliente = cc.codigo_cliente 
		LEFT JOIN cliente_tipo_parametros t 
			ON cc.id_tipo_parametro = t.id_tipo_parametro
	WHERE 	
		cnpj_cpf = v_dest_cnpj_cpf
	GROUP BY 
		c.codigo_cliente;
	
	IF v_tipo_contribuinte_dest = 'N' THEN
		v_ind_final = 1;
	END IF;

	v_forca_fob = COALESCE(((v_parametros_dest->>'FORCAR_FRETE_FOB')::text)::integer,0);
------------------------------------------------------------------------------------------------------------------
--          	                       Dados do Pagador Subcontrato
------------------------------------------------------------------------------------------------------------------	
	IF v_pagador_cnpj_cpf IS NOT NULL THEN 
		--RAISE NOTICE 'Dados do Pagador Subcontrato do cnpj = %',v_pagador_cnpj_cpf; 
		SELECT 	codigo_cliente, id_cidade
		INTO 	vCodigoConsignatario, vCidadeConsignatario
		FROM	cliente
		WHERE 	cnpj_cpf = v_pagador_cnpj_cpf;

	

	END IF;
	
------------------------------------------------------------------------------------------------------------------
--          	                          Dados do Remetente
------------------------------------------------------------------------------------------------------------------	
	SELECT 	
		c.codigo_cliente, 
		c.id_cidade,
		c.volume_no_item_nota,
		c.fob_dirigido,
		c.filial_responsavel,
		c.cobrar_tx_coleta,
		c.cobrar_tx_dce,
		('{' || COALESCE(string_agg('"' || nome_parametro 
		     || '":"' || valor_parametro || '"',',')
		,'"Parametros":"Inexistente"') || '}')::json as parametros,
		c.tipo_frete,
		cidades.uf
	INTO 	
		vCodigoRemetente, 
		vCidadeRemetente,
		vVolumeNoItemNota,
		vFobDirigido,
		v_filial_responsavel,
		v_cobrar_tx_coleta,
		v_cobrar_tx_dc,
		vParametros,
		v_modo_frete_rem,
		v_uf_rem
	FROM 	
		cliente c
		LEFT JOIN cliente_parametros cc 
			ON c.codigo_cliente = cc.codigo_cliente 
		LEFT JOIN cliente_tipo_parametros t 
			ON cc.id_tipo_parametro = t.id_tipo_parametro
		LEFT JOIN cidades 
			ON cidades.id_cidade = c.id_cidade
	WHERE 	
		cnpj_cpf = v_emit_cnpj_cpf
	GROUP BY 
		c.codigo_cliente,
		cidades.id_cidade;	

	--Se o destinatario for o pagador, usar parametros do mesmo;
	IF v_forca_fob = 1 THEN 
		vParametros = v_parametros_dest;
	END IF;
	
	-- Pega o Tipo do Documento 
	vOrigemCalculo = ((vParametros->>'ORIGEM_CALCULO')::text)::integer;
	--RAISE NOTICE 'Origem Calculo %', vOrigemCalculo;

	-- Pega o Tipo do Documento 
	vTipoDocumento = COALESCE(((vParametros->>'TIPO_DOCUMENTO')::text)::integer,0);
	--RAISE NOTICE 'Tipo Documento Parametrizado %', vTipoDocumento;

	-- Pega o cnpj do expedidor padrao
	v_expedidor_cnpj = COALESCE((vParametros->>'CNPJ_EXPEDIDOR')::text,NULL);
		
	-- Pega a Natureza da Carga
	vTermo = vParametros->>'NATUREZA_CARGA';	
	
	IF vTermo IS NOT NULL THEN 
		vNaturezaCarga = fpy_extrai_valor(v_inf,TRIM(vTermo));
		--RAISE NOTICE 'Natureza da Carga %', vTermo;
	END IF;
	-- Pega o código do pedido da NFE
	vTermo = vParametros->>'CODIGO_PEDIDO';	
	
	IF vTermo IS NOT NULL THEN 
		vCodigoPedido = fpy_extrai_valor(v_inf,TRIM(vTermo));
	END IF;

	-- Pega o código interno do frete se ele existir
	vTermo = vParametros->>'COD_INTERNO_FRETE';	
	
	IF vTermo IS NOT NULL THEN 
		vCodInternoFrete = fpy_extrai_valor(v_inf,TRIM(vTermo));
	END IF;

	-- Pega o volume cúbico da mercadoria se ala existir;
	vTermo = NULL;
	vTermo = vParametros->>'VOLUME_CUBICO';
	IF vTermo IS NOT NULL THEN 
		v_volume_cubico = replace(
					CASE 	WHEN fpy_extrai_valor(v_inf,TRIM(vTermo)) = '' 
						THEN '0' 
						ELSE fpy_extrai_valor(v_inf,TRIM(vTermo))
					END,
					',',
					'.')::numeric(16,6);
	END IF;

	-- Pega a Unidade de Medida que indica que o peso do produto é por tonelada;
	vUnidadeTonelada = NULL;
	vUnidadeTonelada = vParametros->>'UNIDADE TONELADA NFE';
	v_is_tonelada = false;
	IF vUnidadeTonelada IS NOT NULL THEN 
		IF trim(v_unidade) = trim(vUnidadeTonelada) THEN 
			v_is_tonelada = true;
		END IF;		
	END IF;

	-- Set Natureza Carga
	-- Pega o segmento na observação da nfe e associa a uma natureza carga
	v_tag_codigo_segmento = vParametros->>'COD_SEGMENTO_NFE';
	IF v_tag_codigo_segmento IS NOT NULL THEN 
		v_codigo_segmento = fpy_extrai_valor(v_inf,TRIM(v_tag_codigo_segmento));

		--Se algum outro cliente usar, passar a utilizar no filtro o código do cliente
		SELECT 	natureza_carga 
		INTO 	vNaturezaCarga
		FROM	scr_notas_fiscais_segmento s
			LEFT JOIN scr_natureza_carga nc 
				ON (trim(s.segmento) || '-' || trim(s.codigo_segmento)) = trim(nc.natureza_carga)
		WHERE 	
			codigo_segmento = v_codigo_segmento;		
	END IF;

	--Se não tem natureza carga por segmento, verifia se tem pre-cadastrado no cliente	
	IF vNaturezaCarga IS NULL THEN 
		SELECT 	natureza_da_carga 
		INTO 	vNaturezaCarga 
		FROM	cliente
		WHERE 	codigo_cliente = vCodigoRemetente;
	END IF;

	--Se natureza carga ainda está nulo, define com DIVERSOS
	IF vNaturezaCarga IS NULL THEN 
		vNaturezaCarga = 'DIVERSOS';
	END IF;	

	--Extrai codigo do vendedor 
	v_cod_vendedor =  fpy_extrai_codigo_vendedor(v_inf,'#Vendedor: ');
	
------------------------------------------------------------------------------------------------------------------
-- 				           Codigo do Transportador
------------------------------------------------------------------------------------------------------------------	
	
	SELECT 	id_filial
	INTO	vCodigoTransportador
	FROM	filial
	WHERE 	filial.cnpj = v_transportador_cnpj_cpf;



------------------------------------------------------------------------------------------------------------------
--                                          PESO E VOLUMES
------------------------------------------------------------------------------------------------------------------	
	v_usa_primeira_tag_vol = COALESCE(((vParametros->>'IGNORAR_MULTIPLOS_VOL')::text)::integer,0);
	
	--SELECT (string_to_array('0  + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000 + 100.000',' + '))[2]

	IF v_usa_primeira_tag_vol = 1 THEN 
		v_exp_vol_pres = COALESCE((dadosNf->>'nfe_volume_presumido')::text,'0.00'::text);		
		v_exp_pes_pres = COALESCE((dadosNf->>'nfe_peso_presumido')::text,'0.00'::text); 
		v_exp_pes_liq  = COALESCE((dadosNf->>'nfe_peso_liquido')::text,'0.00'::text);

		v_array_vol = string_to_array(v_exp_vol_pres,' + ');
		v_array_pesB = string_to_array(v_exp_pes_pres,' + ');
		v_array_pesL = string_to_array(v_exp_pes_liq,' + ');

		IF array_length(v_array_vol,1) > 1 THEN
			v_exp_vol_pres = v_array_vol[2];
		END IF;

		IF array_length(v_array_pesB,1) > 1 THEN 
			v_exp_pes_pres = v_array_pesB[2];
		END IF;
			
		IF array_length(v_array_pesL,1) > 1 THEN 
			v_exp_pes_liq = v_array_pesL[2];
		END IF;
		
	ELSE
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

	--Se quem utiliza peso presumido padrão tem cliente com peso não presumido
	IF vVolumeNoItemNota = 1 THEN 
		v_volume_presumido =  v_volume_produtos;
	END IF;

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
------------------------------------------------------------------------------------------------------------------
-- 						Filial Responssavel
------------------------------------------------------------------------------------------------------------------
	SELECT 	valor_parametro::integer
	INTO 	vUsaFilialResponsavel
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_FILIAL_RESPONSAVEL_IMP_NFE';

	vUsaFilialResponsavel = COALESCE(vUsaFilialResponsavel,0);

	--Operação Especial para Jetlog
	--Alterado em 25/10/2016
	IF 	trim(v_dest_cnpj_cpf) = '02060549000105' 
		AND ltrim(trim(v_serie),'0') = '4' 
		AND v_tp_nf = 0 
		AND v_uf_rem = 'DF' THEN 
		
		vUsaFilialResponsavel = 0;
		vFilialFixa = '003';
		
	ELSE
		vFilialFixa = NULL;
	END IF;

	--RAISE NOTICE '------------------------------------------------------';
	-- RAISE NOTICE 'v_tp_nf: %', v_tp_nf;
-- 	RAISE NOTICE 'v_dest_cnpj_cpf: %', v_dest_cnpj_cpf;
-- 	RAISE NOTICE 'v_uf_rem: %', v_uf_rem;
-- 	RAISE NOTICE 'vFilialFixa: %', vFilialFixa;
-- 	RAISE NOTICE '------------------------------------------------------';


	--Se não usa filial responsavel na importação, então coloca NULL na variavel
	IF vUsaFilialResponsavel = 0 THEN 
		v_filial_responsavel = NULL;
	END IF;
	
	--Se tiver Filial Responsavel faz uso da mesma
	vFilial	= COALESCE(vFilialFixa,v_filial_responsavel, vFilial);

------------------------------------------------------------------------------------------------------------------
--                                         Verifica se emite CTE
------------------------------------------------------------------------------------------------------------------
	SELECT 	valor_parametro::integer
	INTO 	vEmiteCte
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_EMITE_CONHECIMENTO';


------------------------------------------------------------------------------------------------------------------	
-- 					Outras Informacoes
------------------------------------------------------------------------------------------------------------------

	-- Serie do Cte
	SELECT 	cte_serie 
	INTO 	vSerieCte
	FROM 	scr_cte_parametros
	WHERE 	codigo_empresa = vEmpresa AND codigo_filial = vFilial;	

	-- 1 - Se Modelo for 04, mudar para 01	
	IF v_modelo = '04' THEN 
		vCodigoModelo = 4;
	ELSE
		vCodigoModelo = 1;
	END IF;

	-- 2 - Se a unidade for Litro 
	IF v_unidade IN ('L','LT', 'LTS', 'LITRO') THEN 
		v_volume_cubico = v_volume_produtos / 1000;
	END IF;

	IF v_volume_cubico IS NULL THEN
		v_volume_cubico = 0.0000;
	END IF;

	v_volume_cubico = COALESCE(v_volume_cubico_edi,v_volume_cubico);

------------------------------------------------------------------------------------------------------------------
---                                       ORIGEM E DO DESTINO                                                  ---
------------------------------------------------------------------------------------------------------------------
	vCidadeOrigem = vCidadeRemetente;
	
	--RAISE NOTICE 'Cidade Consignatario Antes %', vCidadeConsignatario;	
	-- Cidade da filial de acordo com parametrizacao global
	IF vOrigemFilial = 1 AND vCidadeConsignatario IS NULL THEN 		
		SELECT 	id_cidade 
		INTO 	vCidadeOrigem
		FROM 	filial 
		WHERE 	codigo_filial = vFilial 
			AND codigo_empresa = vEmpresa;
		--RAISE NOTICE 'Cidade de Origem Filial  %', vCidadeOrigem;
	END IF;

	-- Ignorar cidade da filial ou do remetente se origem do calculo esta parametrizado direto no cliente
	vCidadeOrigem = COALESCE(vOrigemCalculo,vCidadeOrigem);

	-- Se for subcontrato utiliza origens parametrizadas no pagador
	--RAISE NOTICE 'Cidade de Origem Pagador %', vCidadeConsignatario;
	IF vCidadeConsignatario IS NOT NULL THEN 

		--RAISE NOTICE 'Cidade de Origem Pagador %', vCidadeConsignatario;	

		vOrigemCalculo = NULL;
		vCidadeOrigemCte = dadosNf->>'nfe_origem_cod_mun';
		
		IF vCidadeOrigemCte IS NULL THEN 		
			SELECT 	COALESCE(valor_parametro::integer,vCidadeConsignatario)
			INTO 	v_cidade_subcontrato_par
			FROM 	cliente_parametros 
			WHERE	codigo_cliente = vCodigoConsignatario AND id_tipo_parametro = 110;
		ELSE
			SELECT 	id_cidade 
			INTO 	vCidadeConsignatario
			FROM 	cidades
			WHERE 	cod_ibge = vCidadeOrigemCte;
		END IF;
					
		vCidadeOrigem = COALESCE(v_cidade_subcontrato_par, vCidadeConsignatario,vOrigemCalculo);
		
	END IF;	

	--RAISE NOTICE 'Cidade Consignatario %', vCidadeConsignatario;	
	--RAISE NOTICE 'Cidade de Origem Remetente %', vCidadeRemetente;
	--RAISE NOTICE 'Origem %', vCidadeOrigem;
	--RAISE NOTICE 'Destino %', vCidadeDestino;
	--RAISE NOTICE 'Origem Filial %', vOrigemFilial;
	--RAISE NOTICE 'Tipo Documento Cliente %', vTipoDocumento;
------------------------------------------------------------------------------------------------------------------
--                                    Agente/redespacho destino padrão
------------------------------------------------------------------------------------------------------------------
	SELECT 	id_agente_redespacho_padrao
	INTO 	vCidadeAgentePadrao
	FROM 	cidades
	WHERE 	id_cidade = vCidadeDestino;

	-- Cidade e Tabela do agente/redespacho padrão 
	IF  vCidadeAgentePadrao IS NOT NULL THEN 
		SELECT 	f.id_cidade::integer, t.numero_tabela_frete
		INTO 	v_id_cidade_origem_redespacho, v_tabela_redespacho
		FROM 	fornecedores f
			LEFT JOIN scr_tabelas t
				ON t.cnpj_transportador = f.cnpj_cpf
		WHERE 	id_fornecedor = vCidadeAgentePadrao;
	END IF;

------------------------------------------------------------------------------------------------------------------
--                                             FRETE CIF/FOB
------------------------------------------------------------------------------------------------------------------
	-- 8 - Set Cif Fob e Cliente Pagador (Remetente, Destinatario ou Terceiro)
	--Verifica a configuração padrão de modo de frete
	-- 0 - Utiliza o que vem da nota
	-- 1 - CIF
	-- 2 - FOB
	
	SELECT valor_parametro::integer 
	INTO vModoFretePadrao
	FROM parametros 
	WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_MODO_FRETE_PADRAO';

	--RAISE NOTICE 'Modo Frete Padrao %', vModoFretePadrao;

	IF vModoFretePadrao IS NULL THEN 
		vModoFretePadrao = 0;
	END IF;

	IF vModoFretePadrao = 1 THEN 
		v_modo_frete = '0';
	END IF;

	IF vModoFretePadrao = 2 THEN
		v_modo_frete = '1';
	END IF;

	IF v_forca_fob = 1 THEN 
		v_modo_frete = '1';
	END IF;
	
	--RAISE NOTICE 'Modo Frete %', v_modo_frete;
	IF v_modo_frete IN ('0','2','9')  THEN 
		--RAISE NOTICE 'CIF';
		vCifFob = 1;
		
		SELECT	pag.codigo_cliente,
			pag.formas_pgto,
			pag.imposto_por_conta
		INTO	vCodigoPagador,
			vFormaPagamento,
			v_imposto_por_conta
		FROM	cliente c
			LEFT JOIN cliente pag 
			ON c.cnpj_cpf_responsavel = pag.cnpj_cpf			
		WHERE	
			c.codigo_cliente = vCodigoRemetente;
	ELSE
		--RAISE NOTICE 'FOB';
		vCifFob = 2;

		SELECT	pag.codigo_cliente,
			pag.formas_pgto,
			pag.imposto_por_conta
		INTO	vCodigoPagador,
			vFormaPagamento,
			v_imposto_por_conta
		FROM	cliente c
			LEFT JOIN cliente pag 
			ON c.cnpj_cpf_responsavel = pag.cnpj_cpf		
		WHERE	
			c.codigo_cliente = vCodigoDestinatario;
	END IF;

------------------------------------------------------------------------------------------------------------------
--                                         Tipo de Transporte
------------------------------------------------------------------------------------------------------------------	
	-- Por Padrão tipo de transporte é Normal
	vTipoTransporte = 1;

	--Se emitente e destinatario da nfe for do mesmo grupo de empresa, 
	--Definir tipo de transporte como Transferência
	IF char_length(trim(v_dest_cnpj_cpf)) > 11 THEN 
		IF left(v_emit_cnpj_cpf,8) = left(v_dest_cnpj_cpf,8) THEN 
			v_tipo_transporte_par = 6;
		END IF;	
	END IF; 

	-- Define tipo de Transporte se for subcontrato
	-- IF v_pagador_cnpj_cpf IS NOT NULL THEN 
-- 		vTipoTransporte = 18;
-- 	END IF;

-----------------------------------------------------------------------------------------------------------------
---                                    DADOS do consignatario no Subcontrato
-----------------------------------------------------------------------------------------------------------------
	--RAISE NOTICE 'Codigo Consignatario %',vCodigoConsignatario;
	IF vCodigoConsignatario IS NOT NULL THEN 

	--	RAISE NOTICE 'Buscando Pagador';
		SELECT	pag.codigo_cliente,
			pag.formas_pgto,
			pag.imposto_por_conta
		INTO	vCodigoPagador,
			vFormaPagamento,
			v_imposto_por_conta
		FROM	cliente c
			LEFT JOIN cliente pag 
			ON c.cnpj_cpf_responsavel = pag.cnpj_cpf		
		WHERE	
			c.codigo_cliente = vCodigoConsignatario;
	END IF;
	
-----------------------------------------------------------------------------------------------------------------
-- 					Tipo Imposto
-----------------------------------------------------------------------------------------------------------------
	--Determina se o imposto é incluso ou não
	IF v_imposto_por_conta = 0 THEN 
		v_imposto_incluso = 1;
	ELSE
		v_imposto_incluso = 2;
	END IF; 

-----------------------------------------------------------------------------------------------------------------
--                                       Forma de Pagamento
------------------------------------------------------------------------------------------------------------------	
	IF vFormaPagamento = 'A VISTA' THEN 
		vAvista = 1;
	ELSE
		vAvista = 2;
	END IF;


-----------------------------------------------------------------------------------------------------------------
-- 					Tabela de Frete
-----------------------------------------------------------------------------------------------------------------
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

	--Se for fob e o pagador não tem tabela procura pela tabela do remetente
	IF vTabelaFrete IS NULL AND vFobDirigido = 1 THEN 
		SELECT 	tabela_padrao 
		INTO	vTabelaFrete
		FROM 	cliente 
		WHERE 	codigo_cliente = vCodigoRemetente;

		IF vTabelaFrete IS NULL THEN 
			SELECT 	numero_tabela_frete
			INTO	vTabelaFrete
			FROM 	scr_tabelas
				LEFT JOIN cliente ON cliente.cnpj_cpf = scr_tabelas.cnpj_cliente
			WHERE 	cliente.codigo_cliente = vCodigoRemetente AND scr_tabelas.ativa = 1;		
		END IF;		
	END IF;

	
	IF vTabelaFrete IS NOT NULL THEN
		SELECT 	imposto_incluso
		INTO 	v_imposto_incluso_tabela 
		FROM 	scr_tabelas 
		WHERE   numero_tabela_frete = vTabelaFrete;

		IF v_imposto_incluso_tabela = 1 THEN
			v_imposto_incluso = 1;
		ELSE
			v_imposto_incluso = 2;
		END IF;
		
		--Verifica se tem taxa de dificuldade de entrega associada com o fornecedor		
	END IF;
------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- 						Tipo do documento
-----------------------------------------------------------------------------------------------------------------	
	IF vTipoDocumento = 0 THEN 
		
		IF vCidadeOrigem = vCidadeDestino THEN 
			vTipoDocumento = 2;
	
		ELSE 
			vTipoDocumento = 1;
	
		END IF;
	END IF;

	IF vTipoDocumento = 1 THEN 
		vTipoCtrcCte   = 2;
	END IF;

	IF vTipoDocumento = 2 THEN 
		vTipoCtrcCte = NULL;
	END IF;

	IF vEmiteCte IS NOT NULL THEN 
		IF vEmiteCte = 0 THEN 
			vTipoDocumento = 2;
			vTipoCtrcCte = NULL;
		END IF;		
	END IF;

	--RAISE NOTICE 'Tipo Documento %', vTipoDocumento;

	
------------------------------------------------------------------------------------------------------------------	
----                                       Determina se é contribuinte
-----------------------------------------------------------------------------------------------------------------
	IF trim(v_ie_dest) = '9' THEN
		v_contribuinte = 0;
	ELSE
		v_contribuinte = 1;
	END IF;
------------------------------------------------------------------------------------------------------------------
-- 					Alinhamento das placas de veiculos
-----------------------------------------------------------------------------------------------------------------
	
	
	--RAISE NOTICE 'Placa Veiculo %', v_placa_veiculo;
	
	IF v_placa_veiculo IS NOT NULL THEN 
	
		SELECT 
			placa_veiculo_tracao			
		INTO 
			v_placa_veiculo_eng
		FROM 
			frt_mov_eng_deseng 
		WHERE
			placa_veiculo_reboque IN (v_placa_veiculo)
			AND flag_acao = 1
			ORDER BY 
			data_mov 
		DESC 
			LIMIT 1;		

		
		--RAISE NOTICE 'Placa Veiculo Eng %', v_placa_veiculo_eng;
		
		IF v_placa_veiculo_eng IS NOT NULL THEN 
			v_placa_reboque1 = v_placa_veiculo;
			v_placa_veiculo  = v_placa_veiculo_eng;					
		END IF;		
		
		SELECT 
			string_agg(placa_veiculo_reboque, ',' order by id_mov)
		INTO 
			v_placas_reboque
		FROM 
			frt_mov_eng_deseng 
		WHERE
			placa_veiculo_tracao IN (v_placa_veiculo)
			AND flag_acao = 1;

		IF v_placas_reboque IS NOT NULL THEN 
		
			v_array_placas_reboque = string_to_array(v_placas_reboque,',');
			
			BEGIN 
				v_placa_reboque1 = v_array_placas_reboque[1];
			EXCEPTION WHEN OTHERS THEN 
				v_placa_reboque1 = NULL;
			END;


			BEGIN 
				v_placa_reboque2 = v_array_placas_reboque[2];
			EXCEPTION WHEN OTHERS THEN 
				v_placa_reboque2 = NULL;
			END;			
		END IF;				
	END IF;

	
	
	--RAISE NOTICE 'Placa Veiculo Apos %', v_placa_veiculo;
	--RAISE NOTICE 'Placa Reboque 1 Apos %', v_placa_reboque1;
	--RAISE NOTICE 'Placa Reboque 2 Apos %', v_placa_reboque2;

	
-----------------------------------------------------------------------------------------------------------------
--- 					GRAVACAO DOS DADOS  
-----------------------------------------------------------------------------------------------------------------
	SET datestyle = "ISO, DMY";

	BEGIN 
		OPEN vCursor FOR 		
		INSERT INTO scr_notas_fiscais_imp(
			tipo_documento, --5
			modal, --6
			tipo_ctrc_cte, --7
			tipo_transporte, --8
			natureza_carga, --9
			empresa_emitente, --12
			filial_emitente, --13
			frete_cif_fob, --14
			remetente_id, --15
			calculado_de_id_cidade, --16
			destinatario_id, --17
			calculado_ate_id_cidade, --18
			consignatario_id, --19
			classificacao_fiscal, --20
			avista, --22
			numero_tabela_frete, --31
			data_emissao, --34
			numero_nota_fiscal,--36 
			modelo_nf, --37
			serie_nota_fiscal, --38
			qtd_volumes, --39
			peso, --41
			peso_presumido, --42
			valor, --43
			volume_cubico, --44
			volume_presumido, --45
			tipo_nota, --46
			valor_base_calculo, --48
			valor_icms_nf, --49
			valor_base_calculo_icms_st, --50
			valor_icms_nf_st, --51
			cfop_pred_nf, --52
			valor_total_produtos, --53            
			chave_nfe, --55                        
			id_usuario, -- 56		
			redespachador_id, --57		
			placa_veiculo, --58
			placa_carreta1, --59
			placa_carreta2, --60
			cod_interno_frete, --61
			peso_liquido, --62
			especie_mercadoria, -- 63
			codigo_vendedor, -- 64
			coleta_normal, --65
			coleta_dificuldade, --66
			entrega_normal, --67
			entrega_dificuldade,--68
			consumidor_final, --69		
			imposto_incluso, --70		
			tabela_redespacho, --71
			id_cidade_origem_redespacho, --72
			id_nota_fiscal_parceiro, --73
			id_romaneio_parceiro, --74
			numero_pedido_nf, --75
			data_emissao_hr, --76
			id_transportador_nfe, --77
			dt_agenda_coleta, --78
			chave_cte, --79
			id_conhecimento_notas_fiscais_parceiro, --80
			id_conhecimento_parceiro, --81
			codigo_integracao, --82
			codigo_softlog_parceiro, --83
			peso_transportado, --84
			flg_viagem_automatica,--85			
			expedidor_cnpj, --86			
			total_frete_origem --87
		)
		VALUES 
		(
			vTipoDocumento, --5
			COALESCE(v_modal,1), --6
			vTipoCtrcCte, -- 7
			v_tipo_transporte_par, --8
			vNaturezaCarga, --9
			vEmpresa, --12
			vFilial, --13
			vCifFob, --14
			vCodigoRemetente, --15
			COALESCE(vCidadeOrigem), --16
			vCodigoDestinatario, --17
			vCidadeDestino, --18
			vCodigoPagador, --19
			'COMERCIO', --20
			2, --22 A VISTA
			vTabelaFrete, --31
			v_data_emissao, --34
			v_numero_doc, -- 36
			vCodigoModelo, --37
			v_serie, --38
			CASE WHEN v_is_tonelada THEN v_volume_produtos * 1000 ELSE v_volume_produtos END, --39
			CASE WHEN v_is_tonelada THEN v_peso_produtos * 1000 ELSE v_peso_produtos END, --41
			COALESCE(v_peso_presumido,0.00), --42
			v_valor, --43
			v_volume_cubico::numeric(12,6), --44
			COALESCE(v_volume_presumido,0.00), --45
			2, --46 tipo nota = nfe
			v_valor_bc, --48
			v_valor_icms, --49
			v_valor_bc_st, --50
			v_valor_icms_st, --51
			v_cfop_predominante, --52
			v_valor_produtos, --53
			v_chave_nfe,  --55		
			vUsuario, -- 56
			vCidadeAgentePadrao, --57
			v_placa_veiculo, --58
			v_placa_reboque1, --59
			v_placa_reboque2, --60
			vCodInternoFrete, --(61)
			COALESCE(v_peso_liquido,0.0000), --(62)
			v_especie_mercadoria, --(63)
			v_cod_vendedor, --(64)
			v_cobrar_tx_coleta, --65
			v_cobrar_tx_dc, --66
			v_cobrar_tx_entrega, --67
			v_cobrar_tx_de, --68
			v_ind_final, --69
			v_imposto_incluso, --70
			v_tabela_redespacho, --71
			v_id_cidade_origem_redespacho, --72	
			v_id_doc_parceiro, --73
			v_id_rom_parceiro, --74
			left(vCodigoPedido,15), --75
			v_data_emissao_hr, --76
			vCodigoTransportador, --77
			COALESCE(v_data_emissao_hr,v_data_emissao),--78
			v_chave_cte, --79
			v_id_nf_cte_parceiro, --80
			v_id_cte_parceiro, --81
			v_codigo_integracao, --82
			v_codigo_parceiro, --83
			CASE 	WHEN v_peso_liquido = 0 THEN 
					CASE WHEN v_is_tonelada THEN v_peso_produtos * 1000 ELSE v_peso_produtos END
				ELSE v_peso_liquido 
			END, --84
			v_viagem_automatica, --85
			v_expedidor_cnpj, --86			
			v_valor_cte_origem --87

		) RETURNING id_nota_fiscal_imp;
	
		FETCH vCursor INTO vIdNotaFiscalImp;
		
		CLOSE vCursor;
	
	EXCEPTION WHEN OTHERS  THEN 
	
		INSERT INTO scr_notas_fiscais_nao_imp (
			dados_parametros,
			numero_nota_fiscal,
			serie_nota_fiscal,
			remetente_id,
			observacao
		) VALUES (
			(dadosNf::jsonb || '{"forca_importacao":"1"}'::jsonb)::text,
			v_numero_doc,
			v_serie,					
			vCodigoRemetente,
			'Erro SQL ao inserir nota'
		);			
		vIdNotaFiscalImp = 0;
	END;
	
	RAISE NOTICE 'Nota Fiscal Importada %',vIdNotaFiscalImp;
	RETURN vIdNotaFiscalImp;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

