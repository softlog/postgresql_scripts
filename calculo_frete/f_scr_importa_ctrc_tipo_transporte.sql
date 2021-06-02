-- Function: public.f_scr_importa_ctrc_tipo_transporte(integer, text, text, integer, refcursor, refcursor, refcursor, refcursor)
/*
BEGIN;
SELECT * FROM f_scr_importa_ctrc_tipo_transporte(1,'1','0010010109108', 27, 'cconhecimento'::refcursor, 'cnotafiscal'::refcursor, 'ccf'::refcursor, 'msg'::refcursor);
FETCH IN "cconhecimento";
COMMIT;

*/
-- DROP FUNCTION public.f_scr_importa_ctrc_tipo_transporte(integer, text, text, integer, refcursor, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_scr_importa_ctrc_tipo_transporte(
    ptipodocumento integer,
    pserie text,
    pnumeroctrc text,
    ptt integer,
    cconhecimento refcursor,
    cnotafiscal refcursor,
    ccf refcursor,
    msg refcursor)
  RETURNS SETOF refcursor AS
$BODY$
DECLARE
	rC scr_conhecimento%ROWTYPE; -- registro de COnhecimento
	vRetorno 		text;
	vConhecimentoOrigem 	text;
	vTipoDocReferenciado 	integer;
	vNaturezaOperacao 	text;
	vCFOP 			text;
	vRemetenteCnpj 		text;
	vDestinatarioCnpj	text;	
	vConsignatarioCnpj	text;	
	vOrigem			integer;
	vDestino		integer;
	vPercentual		numeric(12,2);
	vPercentualReentrega	numeric(12,2);
	vPercentualDevolucao	numeric(12,2);
	str_teste		text;
	vCif_Fob		INTEGER;
	
BEGIN
-- ptt pode ser: 1 NORMAL, 2 DEVOLUÇÃO, 3 REENTREGA, 4 CORTESIA, 5 COLETA EM FORNECEDOR, 6 TRANSFERÊNCIA
--		 7 LOCAÇÃO, 8 LASTRO, 9 HOT LINE, 10 FRACIONADO, 11 MUNK, 12 COMPLEMENTAR, 13 CONTAINER
-- 		 14 ESTADIA, 15 LOGÍSTICA, 16 PALETIZAÇÃO, 17 AÉREO, 18 SUBCONTRATAÇÃO, 19 REDESPACHO
-- 		 20 SUBSTITUIÇÃO, 21 ANULAÇÃO DE VALORES

	IF trim(pserie) = '' THEN
		SELECT * INTO rC FROM scr_conhecimento WHERE tipo_documento = ptipodocumento AND numero_ctrc_filial = pnumeroctrc;
	ELSE
		SELECT * INTO rC FROM scr_conhecimento WHERE tipo_documento = ptipodocumento AND serie_doc  = pserie AND numero_ctrc_filial = pnumeroctrc;
	END IF;	

	RAISE NOTICE 'CTe %', rC.id_conhecimento;		
	IF FOUND THEN 

		--Verifica se o documento já está emitido
		IF rC.status = 0 THEN
			--Se não foi emitido retorna cursores vazios, mais mensagem
			OPEN cconhecimento FOR 
				SELECT 1 WHERE 1=2;

			RETURN NEXT cconhecimento;

			OPEN cnotafiscal FOR 
				SELECT 1 WHERE 1=2;

			RETURN NEXT cnotafiscal;

			OPEN ccf FOR
				SELECT 1 WHERE 1=2;
			RETURN NEXT ccf;

			OPEN msg FOR 
				SELECT '0-CTRC/CT-e de origem não foi emitido ainda! Digite outro número.' as mensagem;

			RETURN NEXT msg;

			RETURN ;
		END IF;

		

		--Determina o tipo do documento referenciado
		CASE 
			
			WHEN rC.tipo_documento = 1 AND rC.tipo_ctrc_cte = 1 THEN
				vTipoDocReferenciado 	= 1;
				vConhecimentoOrigem 	= rC.numero_ctrc_filial;
			WHEN  rC.tipo_documento = 1 AND rC.tipo_ctrc_cte = 2 THEN
				vTipoDocReferenciado	= 2;
				vConhecimentoOrigem 	= rC.chave_cte;
				
			ELSE 
				vTipoDocReferenciado 	= Null;
				vConhecimentoOrigem	= rC.numero_ctrc_filial;
		END CASE;

		--Determina a natureza da operaação
		IF ptt = 21	THEN 
			vNaturezaOperacao = 'ANULACAO DE VALORES';
			--* Verifica se o frete foi dentro do ESTADO
			CASE 
				WHEN rC.calculado_de_uf = rC.calculado_ate_uf  THEN
					vCFOP = '1206';		
				WHEN rC.calculado_de_uf <> rC.calculado_ate_uf THEN
					--&& AQUI TEM QUE CHECAR SE HÁ DIFERENÇA DE PAIS
					--* Verifica se o frete foi INTERESTADUAL
					vCFOP = '2206';
				ELSE
					vCFOP = rC.cod_operacao_fiscal;
			END CASE;
			--* NÃO IMPLEMENTADO O TESTE PARA O C.F.O.P INTERNACIONAL
		ELSE
			vNaturezaOperacao 	= rC.natureza_operacao;
			vCFOP 			= rC.cod_operacao_fiscal;		
		END IF; 

		--Determina os participantes
		vRemetenteCnpj 		= rC.remetente_cnpj;
		vDestinatarioCnpj	= rC.destinatario_cnpj;				
		vConsignatarioCnpj	= rC.consig_red_cnpj;
		vOrigem			= rC.calculado_de_id_cidade;
		vDestino		= rC.calculado_ate_id_cidade;
		
		IF  ptt = 2 THEN -- Se for devolução inverte origem / destino
		
			vRemetenteCnpj 		= rC.destinatario_cnpj;
			vDestinatarioCnpj	= rC.remetente_cnpj;
			vOrigem			= 	rC.calculado_ate_id_cidade;
			vDestino		= 	rC.calculado_de_id_cidade;

			IF rC.frete_cif_fob = 1 THEN
				vCif_fob = 2;
			else 
				vCif_fob = 1;
			end if;
			
			CASE 	WHEN vConsignatarioCnpj = rC.remetente_cnpj THEN 
					vConsignatarioCnpj = vDestinatarioCnpj;
				WHEN vConsignatarioCnpj = rC.destinatario_cnpj THEN 
					vConsignatarioCnpj = vRemetenteCnpj;
				ELSE
			END CASE;	
		ELSE
			vCif_fob = rC.frete_cif_fob;
		END IF;


		--Determina percentual do frete
--		SELECT percentual_reentrega, percentual_devolucao FROM cliente LIMIT 1

		SELECT 	percentual_reentrega, percentual_devolucao 
		INTO   	vPercentualReentrega, vPercentualDevolucao 
		FROM   	cliente 
		WHERE  	cnpj_cpf = vConsignatarioCnpj;
		
		CASE 
			WHEN vPercentualReentrega IS NOT NULL  AND ptt = 3 THEN 
				vPercentual = vPercentualReentrega;
				
			WHEN vPercentualDevolucao IS NOT NULL  AND ptt = 2 THEN
				vPercentual = vPercentualDevolucao;
				
			ELSE 
				vPercentual = 100.00;
		END CASE;

		--Grava dados do Conhecimento
		OPEN cconhecimento FOR 
		SELECT 		
			fp_get_session('pst_cod_empresa') as empresa_emitente,
			fp_get_session('pst_filial') as filial_emitente,
			vRemetenteCnpj as remetente_cnpj,
			vDestinatarioCnpj as destinatario_cnpj,		
			vConsignatarioCnpj as consig_red_cnpj,
			vCif_fob as frete_cif_fob,
			rC.consig_red as consig_red,
			vTipoDocReferenciado as tipo_doc_referenciado,
			vConhecimentoOrigem as conhecimento_origem,
			rC.data_emissao as data_conhecimento_origem,
			(rC.total_frete * vPercentual/100) as total_frete_origem, 
			vOrigem as calculado_de_id_cidade,
			vDestino as calculado_ate_id_cidade,
			rC.qtd_volumes as qtd_volumes,
			rC.peso as peso,
			rC.volume_cubico as volume_cubico,
			rC.natureza_carga as natureza_carga,
			rC.especie as especie,
			rC.valor_nota_fiscal as valor_nota_fiscal,
			CASE WHEN ptt = 27 THEN LEFT(rC.tabele_frete,3) || '9999999999' ELSE rC.tabele_frete END as tabele_frete,
			rC.tipo_imposto as tipo_imposto,
			--vNaturezaOperacao as natureza_operacao,	
			vCFOP as cod_operacao_fiscal,
			rC.aliquota as aliquota, --&& OLHAR ESTE
			CASE WHEN ptt = 27 THEN 1 ELSE rC.imposto_incluso END as imposto_incluso,	
			rC.avista as avista,
			(rC.imposto * vPercentual / 100) as imposto,
			(rC.icms_st * vPercentual / 100) as icms_st,
			(rC.base_calculo * vPercentual /100) as base_calculo,
			(rC.base_calculo_st_reduzida * vPercentual /100) as base_calculo_st_reduzida,
			rC.regime_especial_mg;
			--incidencia		= rC.incidencia * vPercentual/ 100
		

		RETURN next cconhecimento;

		OPEN cnotafiscal FOR
		SELECT 
			NULL::integer as id_conhecimento_notas_fiscais,
			NULL::integer as id_conhecimento,
			data_nota_fiscal, 
			numero_nota_fiscal, 
			serie_nota_fiscal, 
			qtd_volumes, 
			peso, 
			valor, 
			volume_cubico, 
			tipo_nota, 
			numero_romaneio_nf, 
			numero_pedido_nf, 
			valor_base_calculo, 
			valor_icms_nf, 
			valor_base_calculo_icms_st, 
			valor_icms_nf_st, 
			cfop_pred_nf, 
			valor_total_produtos, 
			pin, 
			chave_nfe, 
			id_natureza_carga, 
			modelo_nf
		FROM 
			scr_conhecimento_notas_fiscais
		WHERE	
			id_conhecimento = rC.id_conhecimento;


		RETURN NEXT cnotafiscal;
		--Grava informações do componente de frete		
		OPEN ccf FOR 
		SELECT 
			NULL::integer as id_conhecimento_cf,
			NULL::integer as id_conhecimento,
			v_scr_conhecimento_cf .id_tipo_calculo, 
			scr_tabelas_tipo_calculo.descricao,			
			excedente, 
			quantidade, 
			(valor_item 	* vPercentual/100) as valor_item, 
			(valor_total 	* vPercentual/100) as valor_total, 
			(valor_minimo    * vPercentual/100) as valor_minimo, 
			(valor_pagar	* vPercentual/100) as valor_pagar, 
			operacao, 
			id_faixa, 
			combinado
		FROM 
			v_scr_conhecimento_cf  
			LEFT JOIN scr_tabelas_tipo_calculo ON v_scr_conhecimento_cf .id_tipo_calculo = scr_tabelas_tipo_calculo.id_tipo_calculo
		WHERE 
			id_conhecimento =  rC.id_conhecimento
			AND v_scr_conhecimento_cf .id_tipo_calculo < 1000;	
					

		RETURN NEXT ccf;
		-- SELECT string_agg(id_conhecimento_cf::text,'-') INTO str_teste FROM scr_conhecimento_cf WHERE id_conhecimento = rC.id_conhecimento;
		-- PERFORM f_debug('resultado',str_teste);
		OPEN msg FOR 
			SELECT '1-OK' as mensagem;

		RETURN NEXT msg;

		RETURN ;
	
	ELSE
		OPEN cconhecimento FOR 
			SELECT 1 WHERE 1=2;

		RETURN NEXT cconhecimento;

		OPEN cnotafiscal FOR 
			SELECT 1 WHERE 1=2;

		RETURN NEXT cnotafiscal;

		OPEN ccf FOR
			SELECT 1 WHERE 1=2;
		RETURN NEXT ccf;

		OPEN msg FOR 
			SELECT '0-CTRC/CT-e de origem não foi encontrado! Digite outro número.' as mensagem;

		RETURN NEXT msg;
	END IF ;

	RETURN;
 END
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

