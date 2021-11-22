-- Function: public.f_tgg_scr_romaneios_envio()

-- DROP FUNCTION public.f_tgg_scr_romaneios_envio();

CREATE OR REPLACE FUNCTION public.f_tgg_scr_romaneios_envio()
  RETURNS trigger AS
$BODY$
DECLARE
	v_lista_cnpj text;
	v_tem_parametro integer;
	has_comprovei integer;
	has_itrack integer;
	has_vuupt integer;
	has_notrexo integer;
	has_alper integer;
	vEmpresa text;
	vEmitido integer;
	vExiste integer;
	vExecuta boolean;
BEGIN

	vEmpresa = fp_get_session('pst_cod_empresa');
	RAISE NOTICE 'EMPRESA %s',vEmpresa;
	
	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_comprovei
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_COMPROVEI';	 

	RAISE NOTICE 'Comprovei %', has_comprovei;

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_itrack
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_ITRACK';	 

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_vuupt
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_VUUPT';	 

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_notrexo
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_NOTREXO';

	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_n
	FROM 	parametros 
	WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_INTEGRACAO_ALPER';



	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_alper,0) = 1   THEN 

		RAISE NOTICE 'Integracao Alper';
		--RAISE NOTICE 'Scr Romaneios';
		vExecuta = true;
		IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
			vExecuta = false;
		END IF;

		IF NEW.emitido = 0 THEN 
			vExecuta = false;
		END IF;

		IF NEW.dispara_integracao = 1 THEN
			vExecuta = true;
		END IF;

		IF vExecuta THEN 
			RAISE NOTICE 'Tem notificacao';

			SELECT 
				string_agg(cliente.cnpj_cpf,',') as lst_cnpj
			INTO 
				v_lista_cnpj
			FROM 		
				scr_romaneios r
				LEFT JOIN scr_romaneio_nf rnf
					ON rnf.id_romaneio = r.id_romaneio
				LEFT JOIN scr_notas_fiscais_imp nf
					ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
				RIGHT JOIN msg_subscricao sub
					ON sub.codigo_cliente = nf.remetente_id AND sub.id_notificacao = 1000
				LEFT JOIN cliente
					ON cliente.codigo_cliente = sub.codigo_cliente
			WHERE
				r.id_romaneio = NEW.id_romaneio
				AND sub.ativo = 1;

			
			
			IF v_lista_cnpj IS NOT NULL THEN 
				--Grava as informações na Fila
				INSERT INTO fila_envio_romaneios(id_notificacao, id_romaneio, cnpjs_subscritos)
				VALUES (1000, NEW.id_romaneio, v_lista_cnpj);
			END IF;		 
		END IF;
	END IF; 

	-- Tabela de scr_romaneios 
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_comprovei,0) = 1   THEN 

		RAISE NOTICE 'Integracao Comprovei';
		--RAISE NOTICE 'Scr Romaneios';
		vExecuta = true;
		IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
			vExecuta = false;
		END IF;

		IF NEW.emitido = 0 THEN 
			vExecuta = false;
		END IF;

		IF NEW.dispara_integracao = 1 THEN
			vExecuta = true;
		END IF;

		IF vExecuta THEN 
			RAISE NOTICE 'Tem notificacao';

			SELECT 
				string_agg(cliente.cnpj_cpf,',') as lst_cnpj
			INTO 
				v_lista_cnpj
			FROM 		
				scr_romaneios r
				LEFT JOIN scr_romaneio_nf rnf
					ON rnf.id_romaneio = r.id_romaneio
				LEFT JOIN scr_notas_fiscais_imp nf
					ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
				RIGHT JOIN msg_subscricao sub
					ON sub.codigo_cliente = nf.remetente_id AND sub.id_notificacao = 1000
				LEFT JOIN cliente
					ON cliente.codigo_cliente = sub.codigo_cliente
			WHERE
				r.id_romaneio = NEW.id_romaneio
				AND sub.ativo = 1;

			
			
			IF v_lista_cnpj IS NOT NULL THEN 
				--Grava as informações na Fila
				INSERT INTO fila_envio_romaneios(id_notificacao, id_romaneio, cnpjs_subscritos)
				VALUES (1000, NEW.id_romaneio, v_lista_cnpj);
			END IF;		 
		END IF;
	END IF; 
	
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND NEW.tipo_destino = 'D' AND COALESCE(has_itrack,0) = 1 THEN 

	
		RAISE NOTICE 'Verifica ITrack';
		BEGIN 
			vExecuta = true;
			
			IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
				vExecuta = false;
			END IF;

			IF NEW.emitido = 0 THEN 
				vExecuta = false;
			END IF;

			IF vExecuta THEN 
				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista
					AND trim(fp.valor_parametro) = '1'
					AND fp.id_tipo_parametro = 2;

				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Motorista autorizado';

				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				SELECT 
					3,
					1,
					rnf.id_nota_fiscal_imp,
					r.id_romaneio
				FROM 		
					scr_romaneios r
					LEFT JOIN scr_romaneio_nf rnf
						ON rnf.id_romaneio = r.id_romaneio			
					LEFT JOIN scr_notas_fiscais_imp nf
						ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp			
				WHERE
					r.id_romaneio = NEW.id_romaneio
					AND rnf.id_nota_fiscal_imp IS NOT NULL;
			END IF;

		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos ITrack';
			RETURN NEW;
		END;			
	END IF; 

	--SELECT * FROM fornecedor_parametros
	--RAISE NOTICE 'Tem VUUPT %', has_vuupt;
	--RAISE NOTICE 'Redespacho %', COALESCE(NEW.id_transportador_redespacho,0);
	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND COALESCE(has_vuupt,0) = 1 THEN 

	
		RAISE NOTICE 'INTEGRACAO VUUPT';
 		BEGIN 

			

		
			IF NEW.emitido = 1 THEN 

				IF OLD.emitido = 1 THEN 
					RETURN NULL;
				END IF;

				RAISE NOTICE 'Romaneio Emitido';

				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista				
					AND fp.id_tipo_parametro = 5;

				RAISE NOTICE 'Parametro %', v_tem_parametro;
				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;

				--SELECT * FROM fornecedor_tipo_parametros
				RAISE NOTICE 'Motorista autorizado';
				--SELECT * FROM cliente_parametros


				SELECT 	count(*) 
				INTO 	vExiste
				FROM 	fila_documentos_integracoes
				WHERE 	id_romaneio = NEW.id_romaneio AND tipo_documento = 4;

				IF vExiste > 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Enfileirando';

				--Servicos
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				SELECT 
					5,
					1,
					nf.id_nota_fiscal_imp,
					r.id_romaneio
				FROM 		
					scr_romaneios r				
					LEFT JOIN scr_notas_fiscais_imp nf
						ON nf.id_romaneio = r.id_romaneio
				WHERE
					r.id_romaneio = NEW.id_romaneio;

				--Agrupamento Entrega
				WITH t AS (
				
					SELECT 
						MIN(fd.id) as nf_principal,					
						fd.id_romaneio
					FROM 		
						fila_documentos_integracoes fd										
						LEFT JOIN scr_notas_fiscais_imp nf
							ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
					WHERE
						fd.id_romaneio = NEW.id_romaneio
						AND fd.tipo_documento = 1
						AND fd.tipo_integracao = 5
					GROUP BY 
						nf.destinatario_id,
						fd.id_romaneio
				) 
				UPDATE fila_documentos_integracoes SET 
					principal = 1 
				FROM t
				WHERE t.nf_principal = fila_documentos_integracoes.id;

				--Romaneios
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_romaneio)
				VALUES (5,4,NEW.id_romaneio);
				
			END IF;

		 EXCEPTION WHEN OTHERS THEN 
 			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
 			RETURN NEW;
 		END;			
	END IF;     

	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp' AND TG_OP = 'UPDATE' AND COALESCE(NEW.id_transportador_redespacho,0) = 0 AND COALESCE(has_vuupt,0) = 1 THEN 

		
			RAISE NOTICE 'INTEGRACAO VUUPT';
			BEGIN 

				IF NEW.id_romaneio IS NULL AND OLD.id_romaneio IS NOT NULL THEN 
				
					INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_integracao, id_nota_fiscal_imp, id_romaneio)
					SELECT 
						5,
						-1,
						fdi.id_integracao,
						fdi.id_nota_fiscal_imp,
						fdi.id_romaneio
					FROM 		
						fila_documentos_integracoes fdi					
					WHERE
						id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
						AND id_romaneio = OLD.id_romaneio
						AND tipo_documento = 1;				

				END IF;

			 EXCEPTION WHEN OTHERS THEN 
				RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
				RETURN NEW;
			END;			
	END IF; 

	RAISE NOTICE 'Tem NOTREXO %', has_notrexo;			
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' AND COALESCE(has_notrexo,0) = 1 THEN 

	
		RAISE NOTICE 'INTEGRACAO NOTREXO';
 		BEGIN 

			
	
			IF NEW.dispara_integracao = 1 THEN 


				RAISE NOTICE 'Romaneio Emitido';

				--TODO 

				SELECT COUNT(*) INTO v_tem_parametro 
				FROM fornecedores f
					LEFT JOIN fornecedor_parametros fp
						ON fp.id_fornecedor = f.id_fornecedor
				WHERE
					f.cnpj_cpf = NEW.cpf_motorista				
					AND fp.id_tipo_parametro = 6;

				RAISE NOTICE 'Parametro %', v_tem_parametro;
				IF v_tem_parametro = 0 THEN 
					RETURN NEW;
				END IF;

				--SELECT * FROM fornecedor_tipo_parametros
				RAISE NOTICE 'Motorista autorizado';
				--SELECT * FROM cliente_parametros


				SELECT 	count(*) 
				INTO 	vExiste
				FROM 	fila_documentos_integracoes
				WHERE 	id_romaneio = NEW.id_romaneio AND tipo_documento = 6;

				IF vExiste > 0 THEN 
					RETURN NEW;
				END IF;

				RAISE NOTICE 'Enfileirando';

				
				INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
				VALUES (6,4,NULL, NEW.id_romaneio);

			END IF;

		 EXCEPTION WHEN OTHERS THEN 
 			RAISE NOTICE 'Ocorreu um erro ao tentar enfileirar documentos VUUPT';
 			RETURN NEW;
 		END;			
	END IF; 
	    
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

