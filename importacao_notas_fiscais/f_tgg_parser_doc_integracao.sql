-- Function: public.f_tgg_parser_doc_integracao()

-- DROP FUNCTION public.f_tgg_parser_doc_integracao();

CREATE OR REPLACE FUNCTION f_tgg_parser_doc_integracao()
  RETURNS trigger AS
$BODY$
DECLARE
	v_dados json;
	v_remetente integer;
	v_destinatario integer;
	v_nf integer;
	v_chave text;
	v_qt integer;
	v_participantes json;
	participante json;
	v_notas_fiscais json;	
	t integer;
	i integer;
	var_aux text;
	identificar boolean;
	v_tpevento text;
	r boolean;
	log text;
	log_original text;
	
BEGIN

	log_original = COALESCE(fp_get_session('pst_tipo_especifico_importacao'),'');
	log = REPLACE(log_original, 'UPLOAD/XML','UPLOAD');
		
	identificar = True;

	IF NEW.tipo_doc = -2 THEN 
		NEW.doc_xml = fpy_decode_base64(NEW.doc_xml);
		NEW.tipo_doc = 2;
	END IF;

	IF substr(NEW.doc_xml,1,1) = E'\xEF\xBB\xBF' THEN 
		NEW.doc_xml = replace(NEW.doc_xml, E'\xEF\xBB\xBF','');
	END IF;
	
	--Verifica se eh EDI tipo NOTFIS
	BEGIN 
		--RAISE NOTICE 'Verificando se eh NOTFIS';
		var_aux = LEFT(NEW.doc_xml,3);
		IF var_aux = '000' THEN 
			IF position((chr(13) || chr(10) || '500') in NEW.doc_xml) > 0 THEN 
				NEW.tipo_doc = 7;
			ELSE
				NEW.tipo_doc = 4;
			END IF;
			identificar = False;
		END IF;
	EXCEPTION WHEN others THEN
		--RAISE NOTICE 'Ocorreu um erro';
	END;

	--RAISE NOTICE 'Tipo Documento NOTFIS?: %', NEW.tipo_doc;
	--Verifica se eh EDI DCenter
	IF identificar THEN 
		--RAISE NOTICE 'Verificando se eh Droga Center';
		BEGIN 			
			var_aux = SUBSTR(NEW.doc_xml,7,14);
			IF fd_valida_cnpj_cpf(var_aux) THEN 
				--RAISE NOTICE 'CNPJ validado';
				NEW.tipo_doc = 5;
			END IF;
		EXCEPTION WHEN others THEN
			--RAISE NOTICE 'Ocorreu um erro';
		END;
		--RAISE NOTICE 'Tipo Documento DCENTER?: %', NEW.tipo_doc;
	END IF;

	--Verifica se eh XML da Polishop
	IF NEW.tipo_doc = 2 THEN
		IF position('<expedicao><dt_expedicao>' in NEW.doc_xml) > 0 THEN 
			NEW.tipo_doc = 6;
		END IF;
	END IF;
	

	--Verifica se eh XML de Cte
	IF NEW.tipo_doc = 2 THEN 
		IF position('<infCte' in NEW.doc_xml) > 0 THEN 
			NEW.tipo_doc = 1;
			--RAISE NOTICE 'XML de CTe';
		END IF;
	END IF;


	--Verifica se eh Doria Online
	IF NEW.tipo_doc = 2 THEN

		IF 	f_valida_chave_nfe(substr(NEW.doc_xml,326,44)) = 1 --Doria Com chave
			OR f_valida_chave_nfe(substr(NEW.doc_xml,294,44)) = 1 --Doria com Chave
			OR left(NEW.doc_xml,7) = 'VER0002' --Doria Alterado
			OR left(NEW.doc_xml,6) = 'VER002' --Doria Normal
			OR fd_valida_cnpj_cpf(substr(NEW.doc_xml,275,14)) = 1 --Doria Profarma
		THEN 

			NEW.tipo_doc = 8;		

		END IF;
		
	END IF;



	--RAISE NOTICE 'Tipo Documento: %', NEW.tipo_doc;

	-- 2) Documento tipo XML da NFe
	IF NEW.tipo_doc = 2 THEN 
		log = log || ' XML NFe';
		RAISE NOTICE 'Log %', log;
                r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
		v_dados = fpy_parse_xml_nfe(NEW.doc_xml);	        
	
		
		
		IF v_dados IS NOT NULL THEN 
		
			v_tpevento = v_dados->>'tp_evento';

			IF v_tpevento IS NOT NULL  THEN 	
				--RAISE NOTICE 'Evento %', v_tpevento;			
				IF v_tpevento = '110111' THEN 
					NEW.chave_doc = v_dados->>'chave_nfe';

					UPDATE scr_notas_fiscais_imp SET
						status = 2,
						id_conhecimento = -1
					WHERE
						chave_nfe = NEW.chave_doc
						AND id_conhecimento IS NULL;				
				ELSE
					r = fp_set_session('pst_tipo_especifico_importacao',log_original);
					RETURN NULL;
				END IF;
			ELSE
				--RAISE NOTICE 'Documento XML';
				
				NEW.chave_doc = ((v_dados->>'dados_nota')::json)->>'nfe_chave_nfe';

				--RAISE NOTICE 'Chave %', NEW.chave_doc;
				
				IF NEW.chave_doc IS NULL THEN 
					--RAISE NOTICE 'Não grava o registro, sem chave';
					r = fp_set_session('pst_tipo_especifico_importacao',log_original);
					RETURN NULL;
				END IF;
				
				IF TG_OP = 'INSERT' AND ((v_dados->>'dados_nota')::json)->>'nfe_pagador_cnpj_cpf' IS NULL THEN
					--RAISE NOTICE 'Não grava o registro, pois já existe e não é subcontrato';

					SELECT count(*) 
					INTO v_qt 
					FROM scr_doc_integracao 
					WHERE chave_doc = NEW.chave_doc;

					--RAISE NOTICE 'Qt de Notas %', v_qt;

					IF v_qt > 0 THEN 
						r = fp_set_session('pst_tipo_especifico_importacao',log_original);
						RETURN NULL;
					END IF;
				END IF;


				IF TG_OP = 'INSERT' AND ((v_dados->>'dados_nota')::json)->>'nfe_pagador_cnpj_cpf' IS NOT NULL THEN
					
					SELECT count(*) 
					INTO v_qt 
					FROM scr_doc_integracao 
					WHERE chave_doc = NEW.chave_doc AND entrou_repetida = 1;

					--RAISE NOTICE 'Qt de Notas %', v_qt;

					IF v_qt > 0 THEN 
						r = fp_set_session('pst_tipo_especifico_importacao',log_original);
						RETURN NULL;
					END IF;
					NEW.entrou_repetida = 1;
				END IF;
				

				v_remetente = f_insere_cliente((v_dados->>'remetente')::json);
				v_destinatario = f_insere_cliente((v_dados->>'destinatario')::json);
				v_nf = f_insere_nf((v_dados->>'dados_nota')::json);

				INSERT INTO scr_doc_integracao_nfe (id_doc_integracao, id_nota_fiscal_imp, chave_doc)
				VALUES (NEW.id_doc_integracao, v_nf, NEW.chave_doc);

				--RAISE NOTICE '#### Id Nota Fiscal Imp %', v_nf;
			END IF;
		ELSE
			INSERT INTO debug (descricao,valor) VALUES ('Erro de XML',NEW.doc_xml);
		END IF;       
	END IF;

	-- 4) Documento tipo EDI PADRAO PROCEDA NOTFIS 
	-- 5) Documento tipo EDI Droga Center de Notas Fiscais
	-- 6) Documento tipo EDI POLISHOP
	-- 7) Documento tipo XML de CTe 
	-- 8) Documento tipo Doria
	IF NEW.tipo_doc IN (4, 5, 6, 7, 1, 8) THEN


		IF NEW.tipo_doc = 1 THEN 
			log = log || ' XML CTe';		
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_parse_xml_cte(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;						
		END IF;

		IF NEW.tipo_doc = 4 THEN 
			log = log || ' NOTFIS 3.1';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_notfis(NEW.doc_xml);			
			--RAISE NOTICE '%', v_dados;
		END IF;

		
		IF NEW.tipo_doc = 5 THEN 		
			log = log || ' DCENTER';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_dcenter(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;

		IF NEW.tipo_doc = 6 THEN 		
			log = log || ' POLISHOP';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_polishop(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;

		IF NEW.tipo_doc = 7 THEN 		
			log = log || ' NOTFIS 50';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_notfis_50(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;

		IF NEW.tipo_doc = 8 THEN 		
			log = log || ' DORIA';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_doria(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;


		--RAISE NOTICE '%', v_dados;
		v_participantes = (v_dados->>'participantes')::json;
		t = json_array_length(v_participantes)-1;
		
		FOR i IN 0..t LOOP	
			--RAISE NOTICE 'Participante %', v_participantes::text;
			v_destinatario = f_insere_cliente((v_participantes->>i)::json);			
		END LOOP;

		
		v_notas_fiscais = (v_dados->>'nfs')::json;

		t = json_array_length(v_notas_fiscais)-1;
				
		FOR i IN 0..t LOOP				
			v_nf = f_insere_nf((v_notas_fiscais->>i)::json);
			NEW.chave_doc = (((v_notas_fiscais->>i)::json)::json)->>'chave_cte';
			--RAISE NOTICE 'Nota Fiscal %', v_nf;			
			INSERT INTO scr_doc_integracao_nfe (id_doc_integracao, id_nota_fiscal_imp, chave_doc)
			VALUES (NEW.id_doc_integracao, v_nf, (((v_notas_fiscais->>i)::json)::json)->>'nfe_chave_nfe');
		END LOOP;
		
	END IF;

	
	r = fp_set_session('pst_tipo_especifico_importacao',log_original);
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
