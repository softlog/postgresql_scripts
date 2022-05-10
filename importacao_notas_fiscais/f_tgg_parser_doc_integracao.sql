-- Function: public.f_tgg_parser_doc_integracao()
--SELECT * FROM com_nf WHERE modelo_doc_fiscal = '65'
--UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao WHERE id_doc_integracao = 2991985
-- SELECT * FROM scr_doc_integracao WHERE chave_doc = '52211003834913000282550010000080711708780714'
-- ORDER BY 1 DESC LIMIT 100
-- SELECT * FROM scr_doc_integracao WHERE tipo_doc = 15
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
	v_produtos json;
	v_produto integer;	
	v_notas_fiscais json;	
	
	t integer;
	i integer;
	var_aux text;
	identificar boolean;
	v_tpevento text;
	r boolean;
	log text;
	log_original text;
	v_id_edi integer;

	vCursor refcursor;
	v_cmd text;
	crsemitente 	refcursor;
	vFornecedor 	t_xml_pessoas%rowtype;
	vIdFornecedor integer;
	vIdCidade integer;

	v_importa_para_crm integer;
	vEmpresa text;
	v_id_contato integer;
	v_id_doc_anterior integer;


BEGIN

	log_original = COALESCE(fp_get_session('pst_tipo_especifico_importacao'),'');
	log = REPLACE(log_original, 'UPLOAD/XML','UPLOAD');

	IF NEW.tipo_doc = 1000 THEN 
		NEW.doc_xml = fpy_decode_base64(NEW.doc_xml);
		i = fpy_read_epta_sga(NEW.doc_xml);
		RETURN NEW;		
	END IF;

	IF NEW.tipo_doc = 1001 THEN 
		NEW.doc_xml = fpy_decode_base64(NEW.doc_xml);
		i = fpy_read_portal_ctf(NEW.doc_xml);
		RETURN NEW;		
	END IF;




	IF NEW.tipo_doc = 300 THEN 

		NEW.doc_xml = fpy_decode_base64(NEW.doc_xml);

		v_cmd = f_py_get_cmd_bloco_nfe_2(NEW.doc_xml);		
		
		OPEN crsemitente FOR EXECUTE v_cmd;
		FETCH crsemitente INTO vFornecedor;
		CLOSE crsemitente;


		SELECT 	id_fornecedor
		INTO vIdFornecedor
		FROM 	fornecedores 
		WHERE 	cnpj_cpf = vFornecedor.cnpjcpf;

		
		IF vIdFornecedor IS NULL THEN 

			SELECT id_cidade
			INTO vIdCidade
			FROM cidades
			WHERE cod_ibge = trim(vFornecedor.codmunicipio);

			
			INSERT INTO fornecedores (
				cnpj_cpf, --1
				nome_razao, --2
				fantasia, --3
				endereco, --4
				numero, --5
				bairro, --6
				id_cidade, --7
				cep, --9
				telefone1, --10
				iest
				

			) VALUES (
				trim(vFornecedor.cnpjcpf), --1
				upper(trim(left(vFornecedor.nomerazao,50))), --2
				upper(trim(left(vFornecedor.nomerazao,40))), --3
				upper(trim(vFornecedor.endereco)), --4
				trim(vFornecedor.numero), --5
				upper(trim(left(vFornecedor.bairro,30))), --6
				vIdCidade,				
				trim(vFornecedor.cep), --9
				trim(left(vFornecedor.telefone,8)), --10
				trim(LEFT(vFornecedor.iestadual,15))--11
				
			);			
			
			vEmpresa 	= fp_get_session('pst_cod_empresa');

			SELECT COALESCE(valor_parametro::integer,0)::integer
			INTO v_importa_para_crm
			FROM parametros 
			WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_IMPORTA_DADOS_CRM';

			IF (v_importa_para_crm = 1) AND COALESCE(vFornecedor.telefone,'') <> '' THEN 

				OPEN vCursor FOR
				INSERT INTO public.crm_contatos(
					nome_razao, --1 			    				
					endereco, --3
					numero, --4				
					bairro, --6
					id_cidade, --7
					cep, --8								
					cnpj_cpf, --9
					dt_cadastro --14			    
				) VALUES (
					upper(trim(left(vFornecedor.nomerazao,50))), --1
					upper(trim(vFornecedor.endereco)), --3
					trim(vFornecedor.numero), --4
					upper(trim(left(vFornecedor.bairro,30))), --6
					vIdCidade, --7
					trim(vFornecedor.cep), --8
					trim(vFornecedor.cnpjcpf), --9
					current_date --14				
				)
				RETURNING id_contato;

				
				FETCH vCursor INTO v_id_contato;				

				CLOSE vCursor;

				INSERT INTO public.crm_cont_relacoes(
				    id_contato, id_estrangeiro, flg_estrangeiro, 
				    atual_em)
				VALUES (v_id_contato, vCodigoCliente, 'C');

				INSERT INTO crm_contatos_detalhes (
					id_contato,
					tp_detalhe, 
					detalhe
				) VALUES (
					v_id_contato,
					'Fone Comercial',
					trim(left(vFornecedor.telefone,8))
				);				
	
			END IF;


			
		END IF;
		RETURN NEW;
	END IF;

		
	identificar = True;

	
	IF NEW.tipo_doc= -2 THEN 

		NEW.doc_xml = fpy_decode_base64(NEW.doc_xml);
		
		--RAISE NOTICE '%', NEW.doc_xml;
		NEW.tipo_doc = 2;
	END IF;

	IF substr(NEW.doc_xml,1,1) = E'\xEF\xBB\xBF' THEN 
		NEW.doc_xml = replace(NEW.doc_xml, E'\xEF\xBB\xBF','');
	END IF;

        --RAISE NOTICE '%', NEW.doc_xml;
	
	--Verifica se eh EDI tipo Farmix
	IF position('CHAVENFE' in NEW.doc_xml) > 0 THEN 
		RAISE NOTICE 'FARMIX';
		NEW.doc_xml = replace(NEW.doc_xml, '''', ' ');
		NEW.tipo_doc = 15;
		identificar =  False;
	END IF;

	--Verifica se eh EDI tipo VTEX
	IF NEW.tipo_doc = 14 THEN 
		identificar = False;
	END IF;
	
	--Verifica se eh EDI tipo A451
	IF NEW.tipo_doc = 10 THEN 		
		identificar = False;
	END IF;

	
	IF identificar THEN 	
		BEGIN 
			
			--RAISE NOTICE 'Verificando se eh NOTFIS';
			var_aux = LEFT(NEW.doc_xml,3);
			IF var_aux = '000' THEN 
				IF position((chr(13) || chr(10) || '500') in NEW.doc_xml) > 0 THEN 
					NEW.tipo_doc = 7;
				ELSIF position((chr(13) || chr(10) || '340') in NEW.doc_xml) > 0 THEN 
					NEW.tipo_doc = 30;
				ELSE
					NEW.tipo_doc = 4;
				END IF;
				identificar = False;
			END IF;
			
		EXCEPTION WHEN others THEN
			--RAISE NOTICE 'Ocorreu um erro';
		END;
	END IF;

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
			IF LEFT(NEW.doc_xml,5) <> '<?xml' THEN 
				NEW.tipo_doc = 8;		
			END IF;

		END IF;		
	END IF;

	RAISE NOTICE 'Tipo Documento Identificado: %', NEW.tipo_doc;

	-- 2) Documento tipo XML da NFe
	IF NEW.tipo_doc = 2 THEN 
		log = log || ' XML NFe';
		RAISE NOTICE 'Log %', log;
                r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
		v_dados = fpy_parse_xml_nfe(NEW.doc_xml);	        
	
		--RAISE NOTICE 'Dados %', v_dados;
		
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
					UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao 
					WHERE chave_doc = NEW.chave_doc AND id_doc_integracao <> NEW.id_doc_integracao; 
					RETURN NULL;
				END IF;
				
				IF TG_OP = 'INSERT' AND ((v_dados->>'dados_nota')::json)->>'nfe_pagador_cnpj_cpf' IS NULL THEN
					--RAISE NOTICE 'Não grava o registro, pois já existe e não é subcontrato';

					SELECT count(*) 
					INTO v_qt 
					FROM scr_doc_integracao 
					WHERE chave_doc = NEW.chave_doc;

					RAISE NOTICE 'Qt de Notas %', v_qt;

					IF v_qt > 0 THEN 
						--UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao WHERE chave_doc = NEW.chave_doc;
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
						--UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao WHERE chave_doc = NEW.chave_doc;
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
	-- 10) Planilha Excell a451
	-- 14) Json NFe VTEX
	-- 15) Farmix

	IF NEW.tipo_doc IN (4, 5, 6, 7, 1, 8, 10, 14, 15) THEN

		RAISE NOTICE 'Entrando para gravar arquivos';

		IF NEW.tipo_doc = 1 THEN 
			log = log || ' XML CTe';		
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_parse_xml_cte(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;						
		END IF;

		IF NEW.tipo_doc = 4 THEN 
			log = log || ' NOTFIS 3.1';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			--RAISE NOTICE 'Log %', log;
			--RAISE NOTICE '%', NEW.doc_xml;			
			v_dados = fpy_get_doc_notfis(NEW.doc_xml);
			RAISE NOTICE '%', v_dados;
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
			--RAISE NOTICE 'Dados: %', v_dados;			
		END IF;


		IF NEW.tipo_doc = 10 THEN 		
			log = log || ' A451';
			
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_a451(NEW.doc_xml);
			RAISE NOTICE 'Dados %', v_dados;
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;


		IF NEW.tipo_doc = 14 THEN 		
			log = log || ' FIKBELLA VTEX';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_vtex(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;

		IF NEW.tipo_doc = 15 THEN 		
			log = log || ' FARMIX';
			r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
			v_dados = fpy_get_doc_farmix(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;			
		END IF;		
		
		--RAISE NOTICE '%', v_dados;
		v_participantes = (v_dados->>'participantes')::json;
		t = json_array_length(v_participantes)-1;
		
		FOR i IN 0..t LOOP	
			--RAISE NOTICE 'Participante %', (v_participantes->>i)::json;
			v_destinatario = f_insere_cliente((v_participantes->>i)::json);			
		END LOOP;

		
		v_notas_fiscais = (v_dados->>'nfs')::json;

		--INSERT INTO debug (descricao, valor) VALUES ('Notas Fiscais ' || NEW.id_doc_integracao::text, v_notas_fiscais::text);

		t = json_array_length(v_notas_fiscais)-1;
				
		FOR i IN 0..t LOOP				

			NEW.chave_doc = (((v_notas_fiscais->>i)::json)::json)->>'nfe_chave_nfe';

			--SELECT count(*) FROM scr_doc_integracao_nfe 
			--SELECT * FROM debug ORDER BY 1 DESC 
			SELECT id_nota_fiscal_imp, id_doc_integracao
 			INTO v_nf, v_id_doc_anterior
 			FROM 
 				scr_doc_integracao_nfe
 			WHERE chave_doc = NEW.chave_doc
 			ORDER BY 1 LIMIT 1;

			IF v_nf IS NULL THEN 
			
				v_nf = f_insere_nf((v_notas_fiscais->>i)::json);
				--INSERT INTO debug (descricao, valor) VALUES ('NF ' || NEW.id_doc_integracao, v_nf::text);
				IF NEW.tipo_doc = 14 THEN 
					UPDATE scr_notas_fiscais_imp SET 
						id_ocorrencia = 302,
						data_ocorrencia = now()
					WHERE id_nota_fiscal_imp = v_nf;
				END IF;

				--RAISE NOTICE 'Nota Fiscal %', NEW.chave_doc;			
				
			ELSE
				RAISE NOTICE 'NFe ja existe %',NEW.chave_doc;
			END IF;

			INSERT INTO scr_doc_integracao_nfe (id_doc_integracao, id_nota_fiscal_imp, chave_doc, id_doc_integracao_anterior)
			VALUES (NEW.id_doc_integracao, v_nf, (((v_notas_fiscais->>i)::json)::json)->>'nfe_chave_nfe', v_id_doc_anterior);
			

		
		END LOOP;
		
	END IF;

	IF NEW.tipo_doc IN (20) THEN

		
		log = log || ' XML NFc';		
		r = fp_set_session('pst_tipo_especifico_importacao',LEFT(log,50));
		v_dados = fpy_parse_xml_nfc(NEW.doc_xml);
			--RAISE NOTICE 'Dados: %s', v_dados;						


		--SELECT * FROM scr_doc_integracao LIMIT 1
		PERFORM fp_set_session('pst_cod_empresa',NEW.codigo_empresa);
		PERFORM fp_set_session('pst_filial', NEW.codigo_filial);
		
		v_nf = f_insere_nf_saida((v_dados->>'dados_nota')::json);


		IF v_nf = 0 THEN 
			RETURN NEW;
		END IF;
		
		--RAISE NOTICE '%', v_dados;
		v_produtos = (v_dados->>'produtos')::json;
				
		t = json_array_length(v_produtos)-1;
		
		FOR i IN 0..t LOOP	
			--RAISE NOTICE 'Participante %', v_participantes::text;
			v_produto = f_insere_nf_itens_saida(v_nf, (v_produtos->>i)::json);	
		END LOOP;			
		
	END IF;

	IF NEW.tipo_doc IN (-20) THEN
		UPDATE com_nf SET cstat = 135, status = 4, data_cancelamento = now() WHERE chave_eletronica = NEW.chave_doc;
	END IF;


	IF NEW.tipo_doc IN (30) THEN

		
		v_dados = fpy_get_doc_ocoren(NEW.doc_xml);
		--RAISE NOTICE 'Dados: %s', v_dados;						
		
		--RAISE NOTICE '%', v_dados;
		v_notas_fiscais = (v_dados->>'ocorrencias')::json;
		t = json_array_length(v_notas_fiscais)-1;
		
		FOR i IN 0..t LOOP				
			v_id_edi = f_insere_ocorrencia_entrega((v_notas_fiscais->>i)::json);
		END LOOP;			
		
	END IF;

	
	r = fp_set_session('pst_tipo_especifico_importacao',log_original);
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
--ALTER FUNCTIOn f_tgg_parser_doc_integracao() OWNER TO softlog_3glog