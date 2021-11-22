/*
-- UPDATE fila_envio_romaneios SET id = id WHERE id_tipo_servico = 301 AND mensagem2 IS NOT NULL
SELECT * FROM fila_envio_romaneios WHERE mensagem2 IS NOT NULL AND id_tipo_servico = 301;
--SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE atividade_executada = 'OCORREN. ENVAIDA P/FILA COMPROVEI' ORDER BY 1 DESC LIMIT 200

SELECT
DELETE FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp_log_atividade IN (38675436,38675373,38675371),
DELETE FROM fila_envio_romaneios WHERE id = 9350

*/
CREATE OR REPLACE FUNCTION f_tgg_fila_envio_romaneios()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_nf integer;
	v_usuario text;
	v_mensagem text;
	v_codigo text;
	resposta json;
BEGIN
	--SELECT * FROM fila_envio_romaneios LIMIT 1


	BEGIN

		
		IF NEW.id_notificacao = 1000 AND NEW.id_tipo_servico = 301 AND TG_OP = 'INSERT' AND 1=2 THEN         

			IF NEW.link_img_pendente = 0 THEN 
				RETURN NEW;
			END IF;
			
			SELECT id_nota_fiscal_imp
			INTO v_id_nf
			FROM scr_ocorrencias_notas_fiscais_imp
			WHERE id_ocorrencia_nf = NEW.id_ocorrencia_nf;

			INSERT INTO scr_notas_fiscais_imp_log_atividades (id_nota_fiscal_imp, data_hora, atividade_executada, usuario)
			VALUES (v_id_nf, now(), 'OCORREN. P/FILA COMPROVEI',COALESCE(fp_get_session('pst_login'),'suporte')) ;		
				
		END IF;
			

			

		IF NEW.id_notificacao = 1000 AND NEW.id_tipo_servico = 301 AND TG_OP = 'UPDATE' AND NEW.mensagem2 IS NOT NULL THEN 

			IF NEW.link_img_pendente = 0 THEN 
				RETURN NEW;
			END IF;


			SELECT id_nota_fiscal_imp
			INTO v_id_nf
			FROM scr_notas_fiscais_imp_ocorrencias
			WHERE id_ocorrencia_nf = NEW.id_ocorrencia_nf;

			--RAISE NOTICE '%', NEW.mensagem2;
			resposta = NEW.mensagem2::json;
			
			v_mensagem  = ((((((resposta->>'details')::json)->0)::json)->>'response')::json)->>'message';
			v_codigo  = ((((((resposta->>'details')::json)->0)::json)->>'response')::json)->>'code';

			--RAISE NOTICE 'Codigo %', v_codigo;
			
			
			IF trim(v_codigo) = '200' THEN
				INSERT INTO scr_notas_fiscais_imp_log_atividades (id_nota_fiscal_imp, data_hora, atividade_executada, usuario)
				VALUES (v_id_nf, now(), 'OCORREN. ENVIADA P/COMPROVEI COM SUCESSO',COALESCE(fp_get_session('pst_login'),'suporte')) ;		
			ELSE
				INSERT INTO scr_notas_fiscais_imp_log_atividades (id_nota_fiscal_imp, data_hora, atividade_executada, usuario)
				VALUES (v_id_nf, now(), 'OCORREN. ENVIADA P/COMPROVEI SEM SUCESSO',COALESCE(fp_get_session('pst_login'),'suporte')) ;	

				UPDATE scr_notas_fiscais_imp SET 
					obs = COALESCE(obs,'') 
						|| chr(13) 
						|| 'ENVIO DE OCORRENCIA PARA COMPROVEI COM ERRO: ' 
						|| COALESCE(v_codigo || '-' || v_mensagem,'ERRO NAO IDENTIFICADO')
						
				WHERE id_nota_fiscal_imp = v_id_nf;
			END IF;
		
		END IF;
		
	EXCEPTION WHEN OTHERS THEN 
		RAISE NOTICE 'ERRO ****************************************%', SQLERRM;
		RETURN NEW;
	END;


        
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_fila_envio_romaneios ON fila_envio_romaneios;

CREATE TRIGGER tgg_fila_envio_romaneios
  AFTER INSERT OR UPDATE
  ON public.fila_envio_romaneios
  FOR EACH ROW  
  EXECUTE PROCEDURE public.f_tgg_fila_envio_romaneios();
