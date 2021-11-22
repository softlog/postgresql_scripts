
CREATE OR REPLACE FUNCTION f_tgg_fila_documentos_integracoes()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN
        IF NEW.tipo_integracao = 11 AND TG_OP = 'UPDATE' THEN 

		
		--SELECT ('{"Protocolo":"5020561"}'::json)->>'Protocolo'
		IF (NEW.mensagens)->>'Protocolo' IS NOT NULL THEN 
		
			INSERT INTO scr_romaneio_log_atividades (id_romaneio, data_transacao, usuario, acao_executada)
			VALUES (NEW.id_romaneio, now(), 'suporte', 'Krona:' || (NEW.mensagens->>'Protocolo')::text );
			
		ELSE
		
			INSERT INTO scr_romaneio_log_atividades (id_romaneio, data_transacao, usuario, acao_executada)
			VALUES (NEW.id_romaneio, now(), 'suporte', 'PROBLEMA INTEG.KRONA');

			-- UPDATE fila_documentos_integracoes SET id = id WHERE id = 1588
			
			--SELECT mensagens->>'Protocolo', * FROM fila_documentos_integracoes WHERE tipo_integracao = 11
			--SELECT * FROM scr_romaneios WHERE id_romaneio = 43106
			
			UPDATE scr_romaneios SET 
				msg_integracao = COALESCE(msg_integracao,'') || '/Problema Integracao Krona ' || NEW.mensagens::text,
				problema_integracao = 1
			WHERE id_romaneio = NEW.id_romaneio;
			
			
		END IF;

		
        END IF;

        IF NEW.tipo_integracao = 11 AND TG_OP = 'INSERT' THEN         
        
		INSERT INTO scr_romaneio_log_atividades (id_romaneio, data_transacao, usuario, acao_executada)
		VALUES (NEW.id_romaneio, now(), COALESCE(fp_get_session('pst_login'),'suporte'), 'Enviado p/fila Integ.Krona');
			
        END IF;



        
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_fila_documentos_integracoes ON fila_documentos_integracoes;

CREATE TRIGGER tgg_fila_documentos_integracoes
  AFTER INSERT OR UPDATE
  ON public.fila_documentos_integracoes
  FOR EACH ROW  
  EXECUTE PROCEDURE public.f_tgg_fila_documentos_integracoes();

