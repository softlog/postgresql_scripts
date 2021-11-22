

CREATE OR REPLACE FUNCTION f_tgg_scr_eventos_sistema()
  RETURNS trigger AS
$BODY$
DECLARE
	v_usuario text;	
	v_id_ocorrencia integer;
	v_codigo_cliente integer;
	v_id_fornecedor integer;
	v_codigo_parametro integer;
	v_atividade_executada text;
	v_parametro text;
	
BEGIN

	v_usuario = COALESCE(fp_get_session('pst_login'),'suporte');


	IF TG_TABLE_NAME = 'scr_ocorrencia_edi' THEN 
		--SELECT * FROM scr_ocorrencia_edi
		IF TG_OP = 'INSERT' THEN 
			
			v_atividade_executada = 'OCORRENCIA ENTREGA ' || NEW.codigo_edi::text || ' INCLUIDA NO SISTEMA.' || chr(13) ||
					CASE WHEN  NEW.pendencia::boolean THEN 'COM ' ELSE 'SEM ' END || 'GERA ACERTO.' || chr(13) ||	
					CASE WHEN  NEW.gera_acerto::boolean THEN 'COM ' ELSE 'SEM ' END || 'GERA ACERTO.' || chr(13) ||			
					CASE WHEN  NEW.gera_acerto::boolean THEN 'COM ' ELSE 'SEM ' END || 'GERA ACERTO.' || chr(13) ||			
					CASE WHEN  NEW.ocorrencia_coleta::boolean THEN 'COM ' ELSE 'SEM ' END || 'OCORRENCIA COLETA.' || chr(13) ||			
					CASE WHEN  NEW.publica::boolean THEN 'COM ' ELSE 'SEM ' END || 'STATUS PUBLICA.' || chr(13) ||			
					CASE WHEN  NEW.gera_reentrega::boolean THEN 'COM ' ELSE 'SEM ' END || 'GERACAO DE REENTREGA.' || chr(13) ||
					CASE WHEN  NEW.gera_devolucao::boolean THEN 'COM ' ELSE 'SEM ' END || 'GERACAO DE DEVOLUCAO.' || chr(13) ||
					CASE WHEN  NEW.aplicativo_mobile::boolean THEN 'COM ' ELSE 'SEM ' END || 'INTEGRACAO SCONFIRMEI.' || chr(13) ||
					CASE WHEN  NEW.aplicativo_sconferencia::boolean THEN 'COM ' ELSE 'SEM ' END || 'INTEGRACAO SCONFERENCIA.' || chr(13) ||
					CASE WHEN  NEW.devolucao_direta::boolean THEN 'COM ' ELSE 'SEM ' END || 'COM GERACAO DEVOLUCAO DIRETA.' || chr(13) ||
					CASE WHEN  NEW.id_ocorrencia_proceda::boolean THEN 'COM OCORRENCIA PROCEDA CODIGO ' || NEW.id_ocorrencia_proceda::text END;

			v_id_ocorrencia = NEW.codigo_edi;
			
		END IF;

		IF TG_OP = 'UPDATE' THEN 
			v_atividade_executada = 'OCORRENCIA ' || NEW.codigo_edi::text || ' ALTERADA.' || chr(13);

			
			IF NEW.pendencia <> OLD.pendencia THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.pendencia::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'PENDENCIA.' || chr(13);
			END IF;
			
			IF NEW.gera_acerto <> OLD.gera_acerto THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.gera_acerto::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'GERA ACERTO.' || chr(13);
			END IF;

			IF NEW.ocorrencia_coleta <> OLD.ocorrencia_coleta THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.ocorrencia_coleta::boolean THEN 'COM ' ELSE 'SEM ' END || 'OCORRENCIA COLETA.' || chr(13);
			END IF;
				

			IF NEW.publica <> OLD.publica THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.publica::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'STATUS PUBLICA.' || chr(13);
			END IF;

			IF NEW.gera_reentrega <> OLD.gera_reentrega THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.gera_reentrega::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'GERACAO DE REENTREGA.' || chr(13);
			END IF;

			IF NEW.gera_devolucao <> OLD.gera_devolucao THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.gera_devolucao::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'GERACAO DE DEVOLUCAO.' || chr(13);
			END IF;

			IF NEW.aplicativo_mobile <> OLD.aplicativo_mobile THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.aplicativo_mobile::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'INTEGRACAO SCONFIRMEI.' || chr(13);
			END IF;

			IF NEW.aplicativo_sconferencia <> OLD.aplicativo_sconferencia THEN 				
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.aplicativo_sconferencia::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'INTEGRACAO SCONFERENCIA.' || chr(13);
			END IF;

			IF NEW.devolucao_direta <> OLD.devolucao_direta THEN 
				v_atividade_executada = v_atividade_executada || CASE WHEN  NEW.devolucao_direta::boolean THEN 'DE SEM P/ COM ' ELSE 'DE COM P/ SEM ' END || 'COM GERACAO DEVOLUCAO DIRETA.' || chr(13);
			END IF;

			IF COALESCE(NEW.id_ocorrencia_proceda,-1) <> COALESCE(OLD.id_ocorrencia_proceda,-1) THEN 
				IF NEW.id_ocorrencia_proceda IS NULL THEN 
					v_atividade_executada = v_atividade_executada || 'OCORRENCIA PROCEDA CODIGO ' || OLD.id_ocorrencia_proceda::text || ' RETIRADA' || chr(13);
				ELSE
					v_atividade_executada = v_atividade_executada || 'OCORRENCIA PROCEDA CODIGO ' || OLD.id_ocorrencia_proceda::text || ' ALTERADA P/ CODIGO ' || NEW.id_ocorrencia_proceda::text || chr(13);
				END IF;
			END IF;

			v_id_ocorrencia = NEW.codigo_edi;
		END IF;

		IF TG_OP = 'DELETE' THEN 
			v_atividade_executada = 'OCORRENCIA ' || OLD.codigo_edi::text || ' EXCLUIDA DO SISTEMA.';
		END IF;

	END IF;


	
	IF TG_TABLE_NAME = 'cliente_parametros' THEN 
		--SELECT * FROM cliente_parametros;

		v_codigo_cliente = NEW.codigo_cliente;
		v_codigo_parametro = NEW.id_tipo_parametro;
		
		IF TG_OP = 'INSERT' THEN
			
			SELECT descricao_parametro 
			INTO v_parametro			
			FROM cliente_tipo_parametros
			WHERE id_tipo_parametro = NEW.id_tipo_parametro;

			v_atividade_executada = 'PARAMETRO ' || v_parametro || ' INCLUIDO COM O VALOR ' || NEW.valor_parametro;			
			
		END IF;


		IF TG_OP = 'UPDATE' THEN
			
			SELECT descricao_parametro 
			INTO v_parametro			
			FROM cliente_tipo_parametros
			WHERE id_tipo_parametro = NEW.id_tipo_parametro;


			IF NEW.id_tipo_parametro <> OLD.id_tipo_parametro THEN 
				v_atividade_executada = 'PARAMETRO ' || v_parametro || ' ALTERADO DO VALOR: ' || OLD.valor_parametro || ' PARA O VALOR: ' || NEW.valor_parametro;
			ELSE
				RETURN NEW;
			END IF;

			
			
		END IF;


		IF TG_OP = 'DELETE' THEN 
			SELECT descricao_parametro 
			INTO v_parametro			
			FROM cliente_tipo_parametros
			WHERE id_tipo_parametro = OLD.id_tipo_parametro;

			v_atividade_executada = 'PARAMETRO ' || v_parametro || ' EXCLUIDO DO SISTEMA';
		END IF;

		
	END IF;

	IF TG_TABLE_NAME = 'fornecedor_parametros' THEN 
		--SELECT * FROM fornecedor_parametros;

		v_id_fornecedor = NEW.id_fornecedor;
		v_codigo_parametro = NEW.id_tipo_parametro;
		
		IF TG_OP = 'INSERT' THEN
			
			SELECT descricao_parametro 
			INTO v_parametro
			FROM fornecedor_tipo_parametros
			WHERE id_tipo_parametro = NEW.id_tipo_parametro;

			v_atividade_executada = 'PARAMETRO ' || v_parametro || ' INCLUIDO COM O VALOR ' || NEW.valor_parametro;			
			
		END IF;


		IF TG_OP = 'UPDATE' THEN
			
			SELECT descricao_parametro 
			INTO v_parametro
			FROM fornecedor_tipo_parametros
			WHERE id_tipo_parametro = NEW.id_tipo_parametro;


			IF NEW.id_tipo_parametro <> OLD.id_tipo_parametro THEN 
				v_atividade_executada = 'PARAMETRO ' || v_parametro || ' ALTERADO DO VALOR: ' || OLD.valor_parametro || ' PARA O VALOR: ' || NEW.valor_parametro;
			ELSE
				RETURN NEW;
			END IF;

			
			
		END IF;


		IF TG_OP = 'DELETE' THEN 
			SELECT descricao_parametro 
			INTO v_parametro
			FROM fornecedor_tipo_parametros
			WHERE id_tipo_parametro = OLD.id_tipo_parametro;

			v_atividade_executada = 'PARAMETRO ' || v_parametro || ' EXCLUIDO DO SISTEMA';
		END IF;

		
	END IF;


	INSERT INTO scr_eventos_sistema_log_atividades (
		id_ocorrencia, 
		codigo_cliente, 
		id_fornecedor,
		codigo_parametro,		
		atividade_executada, 
		usuario
	) VALUES (
		v_id_ocorrencia,
		v_codigo_cliente,
		v_id_fornecedor,
		v_codigo_parametro,		
		v_atividade_executada,
		v_usuario
	);
	
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_eventos_sistema_ocorrencias ON public.scr_ocorrencia_edi;
CREATE TRIGGER tgg_eventos_sistema_ocorrencias
AFTER INSERT OR UPDATE OR DELETE
ON scr_ocorrencia_edi
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_eventos_sistema();

DROP TRIGGER tgg_eventos_sistema_cliente ON cliente_parametros;
CREATE TRIGGER tgg_eventos_sistema_cliente
AFTER INSERT OR UPDATE OR DELETE
ON cliente_parametros
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_eventos_sistema();

DROP TRIGGER tgg_eventos_sistema_fornecedor ON fornecedor_parametros;
CREATE TRIGGER tgg_eventos_sistema_fornecedor
AFTER INSERT OR UPDATE OR DELETE
ON fornecedor_parametros
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_eventos_sistema();
