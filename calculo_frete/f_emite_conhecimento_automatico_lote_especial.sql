-- Function: public.f_emite_conhecimento_automatico_lote_especial(integer[], date, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_emite_conhecimento_automatico_lote_especial(integer[], date, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_emite_conhecimento_automatico_lote_especial(
    lst_min_re integer[],
    p_data_cte_re date,
    imposto_cf refcursor,
    imposto refcursor,
    msg_imposto refcursor)
  RETURNS text AS
$BODY$
DECLARE
	vIdConhecimento integer;
	vCursor refcursor;
	vaLstNf integer[];	
	vaConhecimentos integer[];
	i integer;
	vIdConhecimentoAgrupado integer;
	nf integer;
	vTotalFrete numeric(12,2);
	vImposto numeric(12,2);
	vBc numeric(12,2);	
	vImpostoSt numeric(12,2);
	vBcSt numeric(12,2);	
	vNumeroConhecimento character(13);
	vNumeroDocumento  character(13);	
	vTipoDocumento integer;
	vSerieDoc integer;
	vModal integer;
	vAmbienteCte integer;
	vTipoImposto integer;
	vTotalDesconto numeric(12,2);	
	vCteRegimeEspecial integer;
	vCnpjRemetente text;
	vDataCteRe date;
	vPrimeiraNota integer;
	vQtNf integer;
	lstnf integer[];
	minuta integer;
	lst_cte_re integer[];	
	vExiste integer;
	vExisteCte integer;

	--Parametros Para Calculo do Imposto		
	v_aliquota			numeric(5,2);
	v_aliquota_icms_st		numeric(5,2);
	v_aliq_icms_inter		numeric(5,2);
	v_aliq_icms_interna 		numeric(5,2);
	v_aliquota_fcp			numeric(5,2);
	v_perc_base_calculo		numeric(12,2);
	v_perc_cred_st			numeric(12,2);
	v_base_calculo_difal		numeric(12,2);
	v_tipo_imposto			integer;
	v_imposto_incluso		integer;
	v_calculo_difal			integer;	
	v_par_imposto			json;	
	vResultadoImposto 		t_scr_conhecimento_cf%rowtype;		
	

	--Parametros Para Receber Calculo do Impsoto
	v_id_aux			integer;
	v_base_calculo 			numeric(12,2);
	v_imposto			numeric(12,2);
	v_base_calculo_st_reduzida	numeric(12,2);
	v_icms_st			numeric(12,2);
	v_difal_icms_origem		numeric(12,2);
	v_difal_icms_destino		numeric(12,2);
	v_valor_fcp			numeric(12,2);
	v_cf_frete			numeric(12,2);

	inf				integer;
	cte				integer;

	v_qt_destinatario		integer;
	
BEGIN	

-- 	SELECT count(*) 
-- 	INTO v_qt_destinatario
-- 	FROM scr_conhecimento
-- 	WHERE ARRAY[id_conhecimento] <@ lst_min_re;	
	
	inf = 0;
	
	--Se a quantidade de minutas re for maior que cinco, gera cte regime especial
	--Caso contrário converte as minutas em ctes normal	
	--IF v_qt_destinatario >= 5 THEN 	
	IF  1=1 THEN 	
		FOREACH minuta IN ARRAY lst_min_re LOOP		
			RAISE NOTICE 'Minuta % ', minuta;
			--Lista das notas
			SELECT 	array_agg(id_nota_fiscal_imp) 
			INTO 	lstnf
			FROM 	scr_conhecimento_notas_fiscais 
			WHERE 	id_conhecimento = minuta;
		
			--Busca dados do documento
			IF vCnpjRemetente IS NULL THEN  
				SELECT 
					CASE WHEN tipo_transporte = 18 THEN consig_red_cnpj ELSE remetente_cnpj END as remetente_cnpj, 
					data_cte_re
				INTO 
					vCnpjRemetente
				FROM 
					scr_conhecimento 
				WHERE
					id_conhecimento = minuta;


				--Verifica se existe cte em regime especial naquele dia. 
				SELECT 
					id_conhecimento 
				INTO 
					vCteRegimeEspecial 
				FROM 
					scr_conhecimento 
				WHERE 
					CASE WHEN tipo_transporte = 18 THEN 
						consig_red_cnpj = vCnpjRemetente
					ELSE
						remetente_cnpj = vCnpjRemetente
					END
					AND data_cte_re = p_data_cte_re
					AND regime_especial_mg = 1
					AND cancelado = 0
					AND tipo_documento = 1
					AND COALESCE(cstat,'') <> '100';

				--Se nao existe cte especial na data, 
				-- Fica id = 0
				
				IF vCteRegimeEspecial IS NOT NULL THEN 						
					RAISE NOTICE 'Ja existe cte %',vCteRegimeEspecial;
					vExisteCte = 0;
					IF array_length(lst_cte_re,1) > 1 THEN 
						FOREACH cte IN ARRAY lst_cte_re LOOP
						
							IF cte = vCteRegimeEspecial THEN 
								vExisteCte = 1;
							END IF;
						END LOOP;
					END IF;
					IF vExisteCte = 0 THEN 	
						lst_cte_re = lst_cte_re || vCteRegimeEspecial;
					END IF;
					vPrimeiraNota = 0;
				ELSE
					RAISE NOTICE 'Primeira Nota';
				
					vCteRegimeEspecial = 0;
					vPrimeiraNota = 1;				
				END IF;	
			END IF;

			--Verifica se nao excede o limite de 2000 nfes por cte
			SELECT count(*) 
			INTO vQtNf
			FROM scr_conhecimento_notas_fiscais 
			WHERE id_conhecimento = vCteRegimeEspecial;		

			IF vQtNf + array_length(lstnf,1) > 2000 THEN 
				vPrimeiraNota = 1;			
				vCteRegimeEspecial = 0;
			END IF;

			IF vPrimeiraNota = 1 THEN 
				WITH t AS (
					SELECT
						id,
						tipo_imposto,
						aliquota,
						aliquota_icms_st,
						calcula_difal,
						aliq_icms_inter,
						aliq_icms_interna,
						aliquota_fcp,
						perc_base_calculo,
						perc_credito_presumido_icms,
						cfop
					FROM
						f_scr_get_dados_fiscais_nfs(lstnf[1]::text)
				)
				UPDATE scr_notas_fiscais_imp SET
					tipo_imposto 	= t.tipo_imposto,
					aliquota 	= t.aliquota,
					aliquota_st 	= t.aliquota_icms_st,
					calculo_difal 	= t.calcula_difal,
					aliq_icms_inter = t.aliq_icms_inter,
					aliq_icms_interna = t.aliq_icms_interna,
					aliquota_fcp 	= t.aliquota_fcp,
					perc_base_calculo = t.perc_base_calculo,
					cfop = t.cfop,
				    modal = COALESCE(modal,1)
				FROM
					t
				WHERE
					t.id = scr_notas_fiscais_imp.id_nota_fiscal_imp;			
				RAISE NOTICE 'NFe %',lstnf[1];
			END IF;
			
			--Adiciona todas as notas no conhecimento independente do destinatario.	
			--Codigo especial 3 para indicar que o regime especial eh de SP	
			CONTINUE WHEN lstnf IS NULL;
			RAISE NOTICE 'Cte %', vCteRegimeEspecial;			
			IF lstnf IS NOT NULL THEN
				FOREACH nf IN ARRAY lstnf LOOP	
					inf = inf + 1;
					vCteRegimeEspecial = f_lanca_nota_fiscal_conhecimento(nf,vCteRegimeEspecial,3);				
				END LOOP;
			END IF;

			RAISE NOTICE 'Cte %', vCteRegimeEspecial;
			--Associa o cte re com a minuta re
			UPDATE scr_conhecimento SET id_conhecimento_principal = vCteRegimeEspecial WHERE id_conhecimento = minuta;



			--Se não tem número de cte gera um.
			IF vPrimeiraNota = 1 THEN 
				RAISE NOTICE 'Primeira Nota do CTe ';
				lst_cte_re = lst_cte_re || vCteRegimeEspecial;
				RAISE NOTICE 'Lista Cte %',lst_cte_re;
				RAISE NOTICE 'Lista de CTe %',lst_cte_re;
				SELECT 
					modal, --1
					tipo_documento, --2
					serie_doc, --3
					tipo_imposto, --4
					cte_ambiente --5
				INTO 
					vModal, --1
					vTipoDocumento, --2
					vSerieDoc, --3
					vTipoImposto, --4
					vAmbienteCte --5
				FROM 
					scr_conhecimento
				WHERE 
					id_conhecimento = vCteRegimeEspecial;	

				RAISE NOTICE '%,%,%,%,%', vCteRegimeEspecial, vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text;
						
				vNumeroConhecimento 	= f_scr_get_numero_conhecimento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
				vNumeroDocumento 	= f_scr_get_numero_documento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);	


				UPDATE scr_conhecimento SET 
					numero_ctrc_filial = vNumeroConhecimento,
					numero_documento = vNumeroDocumento,
					data_cte_re = p_data_cte_re
				WHERE 
					id_conhecimento = vCteRegimeEspecial;	

				vPrimeiraNota = 0;
			END IF;
			
		END LOOP;

		RAISE NOTICE 'Finalizando criacao dos CTes';
		
		FOREACH vCteRegimeEspecial IN ARRAY lst_cte_re LOOP	
					
			-- Pega dados do cte regime especial
			SELECT 
				modal, --1
				tipo_documento, --2
				serie_doc, --3
				tipo_imposto, --4
				cte_ambiente, --5			
				aliquota, --7
				aliquota_icms_st, --8
				aliq_icms_inter, --9
				aliq_icms_interna, --10
				aliquota_fcp, --11
				perc_reducao_base_calculo, --12		
				imposto_incluso, --13
				calculo_difal --14
			INTO 
				vModal, --1
				vTipoDocumento, --2
				vSerieDoc, --3
				vTipoImposto, --4
				vAmbienteCte, --5	
				v_aliquota, --7
				v_aliquota_icms_st, --8
				v_aliq_icms_inter, --9
				v_aliq_icms_interna, --10
				v_aliquota_fcp, --11
				v_perc_base_calculo, --12
				v_imposto_incluso, --13
				v_calculo_difal --14
			FROM 
				scr_conhecimento
			WHERE 
				id_conhecimento = vCteRegimeEspecial;

			
			SELECT 
				modal,
				tipo_documento,
				serie_doc,		
				tipo_imposto,
				cte_ambiente
			INTO 
				vModal,
				vTipoDocumento,
				vSerieDoc,
				vTipoImposto,
				vAmbienteCte 
			FROM 
				scr_conhecimento 
			WHERE 
				id_conhecimento = vCteRegimeEspecial;

					
			UPDATE scr_conhecimento_notas_fiscais SET numero_nota_fiscal = numero_nota_fiscal 
				WHERE 
					id_conhecimento = vCteRegimeEspecial 
					AND total_frete_nf = 0.00;
				
			--GROUP BY
			--	id_tipo_calculo;
			
			--- Recupera os totais das minutas de re
			SELECT
				SUM(c.total_frete),
				SUM(c.desconto)			
			INTO 	
				vTotalFrete, 
				vTotalDesconto
			FROM 	
				scr_conhecimento c		
			WHERE	
				c.id_conhecimento_principal = vCteRegimeEspecial		
				AND cancelado = 0 ;
			
			
			
			--Calcula o imposto imposto
			SELECT row_to_json(row) INTO v_par_imposto FROM (
				SELECT  
					vTotalFrete as valor_operacao, 
					v_aliquota as aliquota,
					v_aliquota_icms_st as aliquota_icms_st, 
					v_aliq_icms_inter as aliq_icms_inter, 
					v_aliq_icms_interna as aliq_icms_interna, 
					v_aliquota_fcp as aliquota_fcp, 
					v_perc_base_calculo as perc_base_calculo, 
					0.00 as perc_cred_st,
					vTipoImposto as tipo_imposto,
					v_imposto_incluso as imposto_incluso,
					v_calculo_difal as calculo_difal
			) row;
			
			RAISE NOTICE '%', v_par_imposto;
			
			PERFORM f_scr_get_icms(v_par_imposto,'imposto_cf', 'imposto','msg_imposto');
			
			LOOP
				FETCH IN imposto_cf INTO vResultadoImposto;

				EXIT 	WHEN NOT FOUND;

				INSERT INTO scr_conhecimento_cf 
				(
					id_conhecimento,
					id_tipo_calculo,
					excedente,
					quantidade,
					valor_item,
					valor_total,
					valor_minimo,
					valor_pagar,
					operacao,
					id_faixa,
					combinado,
					modo_calculo,
					perc_desconto,
					desconto,
					valor_pagar_sdesconto
				) VALUES (
					vCteRegimeEspecial,
					vResultadoImposto.id_tipo_calculo,
					vResultadoImposto.excedente,
					vResultadoImposto.quantidade,
					vResultadoImposto.valor_item,
					vResultadoImposto.valor_total,
					vResultadoImposto.valor_minimo,
					vResultadoImposto.valor_pagar,
					vResultadoImposto.operacao,
					vResultadoImposto.id_faixa,
					vResultadoImposto.combinado,
					vResultadoImposto.modo_calculo,
					vResultadoImposto.perc_desconto,
					vResultadoImposto.desconto,
					vResultadoImposto.valor_pagar_sdesconto
				);
			END LOOP;

			CLOSE imposto_cf;

			--Recupera dados consolidados do imposto
			FETCH imposto INTO 
					v_id_aux
					,v_base_calculo 
					,v_imposto
					,v_base_calculo_st_reduzida
					,v_icms_st
					,v_base_calculo_difal
					,v_difal_icms_origem
					,v_difal_icms_destino
					,v_valor_fcp
					,v_cf_frete;

			CLOSE imposto;
			CLOSE msg_imposto;

			vTotalFrete 	= vTotalFrete + COALESCE(v_cf_frete,0.00);

			-- Grava totais das notas na tabela de conhecimento
			WITH tbl AS 
			(
				SELECT 
					id_conhecimento,
					SUM(valor) as total_valor, 
					SUM(qtd_volumes) as total_qtd_volumes, 
					SUM(volume_cubico) as total_volume_cubico, 
					SUM(peso) as total_peso
				FROM 
					scr_conhecimento_notas_fiscais 
				WHERE
					id_conhecimento = vCteRegimeEspecial
				GROUP BY 
					id_conhecimento
			)
			UPDATE 	scr_conhecimento SET
					valor_nota_fiscal = tbl.total_valor,
					qtd_volumes = tbl.total_qtd_volumes,
					volume_cubico = tbl.total_volume_cubico,
					peso = tbl.total_peso			
			FROM	
				tbl 
			WHERE 
				tbl.id_conhecimento = scr_conhecimento.id_conhecimento;
			
			-- Grava dados finais de total de frete, imposto e número de emissão documento
			UPDATE scr_conhecimento SET 
				total_frete = vTotalFrete, 
				desconto = vTotalDesconto,
				imposto = v_imposto,
				base_calculo = v_base_calculo,
				icms_st = v_icms_st,
				base_calculo_st_reduzida = v_base_calculo_st_reduzida		
			WHERE 
				id_conhecimento = vCteRegimeEspecial;				


			--Grava o log
			INSERT INTO scr_conhecimento_log_atividades(
				id_conhecimento, 
				data_hora, 
				atividade_executada, 
				usuario, 
				historico)
			VALUES (
				vIdConhecimentoAgrupado, 
				now(), 
				'CALCULO FRETE AUTOMATICO', 
				fp_get_session('pst_login'),
				NULL 
				);		
			
		END LOOP;

		RAISE NOTICE 'Qt Notas % ', inf;
		RETURN array_to_string(lst_cte_re,',');
----------------------------------------------------------------------------------------------------
--- CONVERSAO MINUTA RE PARA CTE
----------------------------------------------------------------------------------------------------
	ELSE


		FOREACH minuta IN ARRAY lst_min_re LOOP	
		
			RAISE NOTICE 'Minuta % ', minuta;

			--Lista das notas
			SELECT 	array_agg(id_nota_fiscal_imp) 
			INTO 	lstnf
			FROM 	scr_conhecimento_notas_fiscais 
			WHERE 	id_conhecimento = minuta;
			
			--Configura definições para calculo de imposto na primeira nota
			WITH t AS (
				SELECT
					id,
					tipo_imposto,
					aliquota,
					aliquota_icms_st,
					calcula_difal,
					aliq_icms_inter,
					aliq_icms_interna,
					aliquota_fcp,
					perc_base_calculo,
					perc_credito_presumido_icms,
					cfop
				FROM
					f_scr_get_dados_fiscais_nfs(lstnf[1]::text)
			)
			UPDATE scr_notas_fiscais_imp SET
				tipo_imposto 	= t.tipo_imposto,
				aliquota 	= t.aliquota,
				aliquota_st 	= t.aliquota_icms_st,
				calculo_difal 	= t.calcula_difal,
				aliq_icms_inter = t.aliq_icms_inter,
				aliq_icms_interna = t.aliq_icms_interna,
				aliquota_fcp 	= t.aliquota_fcp,
				perc_base_calculo = t.perc_base_calculo,
				cfop = t.cfop,
				modal = COALESCE(nf.modal,1)
			FROM
				t
			WHERE
				t.id = scr_notas_fiscais_imp.id_nota_fiscal_imp;			
			RAISE NOTICE 'NFe %',lstnf[1];

			

			--Converte Minuta em Cte
			UPDATE scr_conhecimento SET
				tipo_documento = 1,
				regime_especial_mg = 0,
				data_cte_re = NULL,
				tipo_ctrc_cte = 2,
				tipo_imposto = nf.tipo_imposto,
				aliquota = nf.aliquota,
				aliquota_icms_st = nf.aliquota_st,
				calculo_difal = nf.calculo_difal,
				aliq_icms_inter = nf.aliq_icms_inter,
				aliq_icms_interna = nf.aliq_icms_inter,
				aliquota_fcp = nf.aliq_fcp,
				perc_reducao_base_calculo = nf.perc_base_calculo,
				cod_operacao_fiscal = nf.cfop
			FROM 				
				scr_notas_fiscais_imp				
			WHERE 
				id_conhecimento = minuta
				AND scr_notas_fiscais_imp.id_nota_fiscal_imp = lstnf[1];


			--Recalculo do imposto e total frete
			-- Pega dados do cte 
			SELECT 
				modal, --1
				tipo_documento, --2
				serie_doc, --3
				tipo_imposto, --4
				cte_ambiente, --5			
				aliquota, --7
				aliquota_icms_st, --8
				aliq_icms_inter, --9
				aliq_icms_interna, --10
				aliquota_fcp, --11
				perc_reducao_base_calculo, --12		
				imposto_incluso, --13
				calculo_difal, --14
				c.total_frete, --15
				c.desconto --16
				
			INTO 
				vModal, --1
				vTipoDocumento, --2
				vSerieDoc, --3
				vTipoImposto, --4
				vAmbienteCte, --5	
				v_aliquota, --7
				v_aliquota_icms_st, --8
				v_aliq_icms_inter, --9
				v_aliq_icms_interna, --10
				v_aliquota_fcp, --11
				v_perc_base_calculo, --12
				v_imposto_incluso, --13
				v_calculo_difal, --14
				vTotalFrete, --15
				vTotalDesconto --16
			FROM 
				scr_conhecimento
			WHERE 
				id_conhecimento = minuta;
		
				
			vNumeroConhecimento 	= f_scr_get_numero_conhecimento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
			vNumeroDocumento 	= f_scr_get_numero_documento(vTipoDocumento, vModal, vSerieDoc::text, vAmbienteCte::text);
					
			
			--Calcula o imposto imposto
			SELECT row_to_json(row) INTO v_par_imposto FROM (
				SELECT  
					vTotalFrete as valor_operacao, 
					v_aliquota as aliquota,
					v_aliquota_icms_st as aliquota_icms_st, 
					v_aliq_icms_inter as aliq_icms_inter, 
					v_aliq_icms_interna as aliq_icms_interna, 
					v_aliquota_fcp as aliquota_fcp, 
					v_perc_base_calculo as perc_base_calculo, 
					0.00 as perc_cred_st,
					vTipoImposto as tipo_imposto,
					v_imposto_incluso as imposto_incluso,
					v_calculo_difal as calculo_difal
			) row;
			
			RAISE NOTICE '%', v_par_imposto;
			
			PERFORM f_scr_get_icms(v_par_imposto,'imposto_cf', 'imposto','msg_imposto');
			
			LOOP
				FETCH IN imposto_cf INTO vResultadoImposto;

				EXIT 	WHEN NOT FOUND;

				INSERT INTO scr_conhecimento_cf 
				(
					id_conhecimento,
					id_tipo_calculo,
					excedente,
					quantidade,
					valor_item,
					valor_total,
					valor_minimo,
					valor_pagar,
					operacao,
					id_faixa,
					combinado,
					modo_calculo,
					perc_desconto,
					desconto,
					valor_pagar_sdesconto
				) VALUES (
					minuta,
					vResultadoImposto.id_tipo_calculo,
					vResultadoImposto.excedente,
					vResultadoImposto.quantidade,
					vResultadoImposto.valor_item,
					vResultadoImposto.valor_total,
					vResultadoImposto.valor_minimo,
					vResultadoImposto.valor_pagar,
					vResultadoImposto.operacao,
					vResultadoImposto.id_faixa,
					vResultadoImposto.combinado,
					vResultadoImposto.modo_calculo,
					vResultadoImposto.perc_desconto,
					vResultadoImposto.desconto,
					vResultadoImposto.valor_pagar_sdesconto
				);
			END LOOP;

			CLOSE imposto_cf;

			--Recupera dados consolidados do imposto
			FETCH imposto INTO 
					v_id_aux
					,v_base_calculo 
					,v_imposto
					,v_base_calculo_st_reduzida
					,v_icms_st
					,v_base_calculo_difal
					,v_difal_icms_origem
					,v_difal_icms_destino
					,v_valor_fcp
					,v_cf_frete;

			CLOSE imposto;
			CLOSE msg_imposto;

			vTotalFrete 	= vTotalFrete + COALESCE(v_cf_frete,0.00);

			-- Grava totais das notas na tabela de conhecimento
			WITH tbl AS 
			(
				SELECT 
					id_conhecimento,
					SUM(valor) as total_valor, 
					SUM(qtd_volumes) as total_qtd_volumes, 
					SUM(volume_cubico) as total_volume_cubico, 
					SUM(peso) as total_peso
				FROM 
					scr_conhecimento_notas_fiscais 
				WHERE
					id_conhecimento = minuta
				GROUP BY 
					id_conhecimento
			)
			UPDATE 	scr_conhecimento SET
					valor_nota_fiscal = tbl.total_valor,
					qtd_volumes = tbl.total_qtd_volumes,
					volume_cubico = tbl.total_volume_cubico,
					peso = tbl.total_peso			
			FROM	
				tbl 
			WHERE 
				tbl.id_conhecimento = scr_conhecimento.id_conhecimento;
			
			-- Grava dados finais de total de frete, imposto e número de emissão documento
			UPDATE scr_conhecimento SET 
				total_frete = vTotalFrete, 
				desconto = vTotalDesconto,
				imposto = v_imposto,
				base_calculo = v_base_calculo,
				icms_st = v_icms_st,
				base_calculo_st_reduzida = v_base_calculo_st_reduzida,
				numero_ctrc_filial = vNumeroConhecimento,
				numero_documento = vNumeroDocumento
			WHERE 
				id_conhecimento = minuta;				


			--Grava o log
			INSERT INTO scr_conhecimento_log_atividades(
				id_conhecimento, 
				data_hora, 
				atividade_executada, 
				usuario, 
				historico)
			VALUES (
				vIdConhecimentoAgrupado, 
				now(), 
				'CONVERSAO DE MINUTA PRA CTE', 
				fp_get_session('pst_login'),
				NULL 
				);				
				
		END LOOP;
		RETURN array_to_string(lst_min_re,',');
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

