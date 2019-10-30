-- Function: public.f_tgg_easydocs_integracao_ocorrencias()
/*

SELECT * FROM scr_integracao_easydoc WHERE id_integracao IN (453570,449507);

UPDATE scr_integracao_easydoc SET id_integracao = id_integracao WHERE id_integracao IN (332104,332186,273236,335131,335132,277456,277658,339745,245416,338404,282687,250112,254157,254158,262057,295882,299383,303821,305160,307532,353478,353694,314714,314729,364542,330319,434207,434835,389757,391231,443238,453647,453688,453690,443476,443477,445076,449507,454744,454823,460245,461577,461894,453570)

*/
-- DROP FUNCTION public.f_tgg_easydocs_integracao_ocorrencias();

CREATE OR REPLACE FUNCTION public.f_tgg_easydocs_integracao_ocorrencias()
  RETURNS trigger AS
$BODY$
DECLARE 
	vId_nf integer;
	vaId_nf integer[];
	vLink text; 
	vCursor refcursor;
	vId_oco integer;
BEGIN

	raise notice 'trigger disparada';
	
	BEGIN 
		
		/*
		Objetivo: realizar a baixa de notas recebidas através de integração com o EasyDocs
		Autor: Nilton Paulino
		Histórico:
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		- 13-06-2019 - nova versão da trigger para realizar a baixa incluindo o link 
		-              para o anexo do canhoto, compatibilizando com os demais apps integrados
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		*/
		IF NEW.remetente_cnpj IS NULL OR NEW.serie_nota_fiscal IS NULL OR NEW.numero_nota_fiscal IS NULL THEN
			-- Se quiser escrever um log para identificar inconsistências, pode ser aqui
			RETURN NEW;
		END IF;
		
		SELECT array_agg(id_nota_fiscal_imp)
		INTO vaId_nf
		FROM scr_notas_fiscais_imp
		LEFT JOIN cliente c ON c.codigo_cliente = scr_notas_fiscais_imp.remetente_id
		WHERE c.cnpj_cpf = NEW.remetente_cnpj
			AND scr_notas_fiscais_imp.numero_nota_fiscal = NEW.numero_nota_fiscal
			AND scr_notas_fiscais_imp.serie_nota_fiscal = NEW.serie_nota_fiscal
		-- WHERE c.cnpj_cpf = '73856593001057'
			-- AND scr_notas_fiscais_imp.numero_nota_fiscal = '000340814'
			-- AND scr_notas_fiscais_imp.serie_nota_fiscal = '001'
		ORDER BY 1;

		raise notice ' entrou na triger %', vaId_nf;

		
		IF vaId_nf IS NOT NULL AND COALESCE(array_length(vaId_nf, 1),0) > 0 THEN

			
			FOREACH vId_nf IN ARRAY vaId_nf LOOP
				raise notice 'Nota Fiscal ... %', vId_nf;
				PERFORM fp_set_session('ATIVIDADE_EXECUTADA','EASYDOCS');
				
				vLink = 'http://dng.easydocs.com.br/document/search?user=1&hash=loEpJjNct8eSvxp&documentType=CANHOTO&NUMERO NF=' 
					|| NEW.numero_nota_fiscal::INTEGER::TEXT 
					|| '&SERIE NF=' || NEW.serie_nota_fiscal::INTEGER::TEXT 
					|| '&CNPJ REMETENTE=' || NEW.remetente_cnpj;

				raise notice ' conteúdo do link:  %', vLInk;
				
				OPEN vCursor FOR 
				INSERT INTO scr_notas_fiscais_imp_ocorrencias(
					id_nota_fiscal_imp, 
					id_ocorrencia,
					data_ocorrencia,
					data_registro,
					canhoto,
					obs_ocorrencia)
				 VALUES(
					vId_nf,
					302,	-- Ocorrencia cadastrada na base de dados da DNG. O ideal é ter isso numa tabela de parâmetros, mas para o momento vai ficar fixo.
					NEW.data_entrega,
					now(),
					1, -- diz que está com o canhoto
					'OCORRENCIA VIA EASYDOCS')
				RETURNING 	id_ocorrencia_nf;

				raise notice ' após o insert  %', vId_nf;
				
				FETCH vCursor INTO vId_oco;
				CLOSE vCursor;

				INSERT INTO scr_docs_digitalizados(
					tipo_doc,
					data_registro,
					id_nota_fiscal_imp,
					id_ocorrencia_nota_fiscal_imp,
					link_img
				) VALUES (
					3,	-- EasyDocs
					now(),
					vId_nf,
					vId_oco,
					vLink
				);

				UPDATE scr_notas_fiscais_imp
					SET
						id_ocorrencia 			= 1,
						canhoto 				= 1,
						entrega_realizada 		= 1,
						data_ocorrencia 		= new.data_entrega,
						nome_recebedor 			= new.nome_recebedor,
						cpf_recebedor 			= left(new.cpf_recebedor,11)
					WHERE id_nota_fiscal_imp 	= vId_nf ;
			END LOOP;
			NEW.processado = 1;
			
		END IF;

	EXCEPTION WHEN OTHERS THEN 
		/*
		Lança informações de Debug para verificação de baixas não efetivadas
		*/

		raise notice '% %', SQLERRM, SQLSTATE;
		
-- 		INSERT INTO debug (
-- 			descricao,
-- 			valor,
-- 			data_hora)
-- 		VALUES (
-- 			'ERRO NA BAIXA VIA EASYDOCS',
-- 			'ID DA TABELA DE INTEGRAÇÃO: '||NEW.id_integracao::text,
-- 			now());
			
	END;

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

