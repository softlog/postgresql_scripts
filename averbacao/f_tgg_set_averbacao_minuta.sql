-- Function: public.f_tgg_set_averbacao()

-- DROP FUNCTION public.f_tgg_set_averbacao();
/*

SELECT id_conhecimento, status, tipo_documento, data_emissao FROM scr_conhecimento WHERE tipo_documento = 2 AND data_emissao >= current_date AND cancelado = 0

SELECT * FROM scr_conhecimento_averbacao WHERE data_registro >= current_date;

UPDATE scr_conhecimento SET status = 0, cstat='100' WHERE tipo_documento = 2 AND data_emissao >= current_date AND cancelado = 0;
UPDATE scr_conhecimento SET status = 1, cstat='100' WHERE tipo_documento = 2 AND data_emissao >= current_date AND cancelado = 0;


*/
-----

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao()
  RETURNS trigger AS
$BODY$
DECLARE	
	vIdAverbacao integer;
BEGIN		

	RAISE NOTICE 'Disparando Averbacao';
	IF TG_TABLE_NAME = 'scr_conhecimento' AND TG_OP = 'UPDATE' THEN 
		IF NEW.tipo_transporte IN (4,20,12) THEN 
			RETURN NULL;
		END IF ;

		IF NEW.responsavel_seguro <> 5 THEN
			RETURN NULL;
		END IF;

		IF NEW.tipo_documento = 1 THEN
			--Se houve emissao de cte
			IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '100' OR
				OLD.responsavel_seguro = 0 
			THEN 
				SELECT id INTO vIdAverbacao FROM scr_conhecimento_averbacao WHERE id_conhecimento = NEW.id_conhecimento;

				IF vIdAverbacao IS NULL THEN 
					INSERT INTO public.scr_conhecimento_averbacao(id_conhecimento)			
					VALUES (NEW.id_conhecimento);
				END IF;
			END IF;		

			--Se houve cancelamento de cte
			IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '135'  THEN 
				UPDATE scr_conhecimento_averbacao SET cancelado = 1 WHERE id_conhecimento = NEW.id_conhecimento;			
			END IF;	
		END IF;
		IF NEW.tipo_documento = 2 THEN 
			
			--Se houve emissao de minuta
			IF COALESCE(OLD.status,0) <> COALESCE(NEW.status,0) AND COALESCE(NEW.status,0) = 1  THEN 
				RAISE NOTICE 'Averba Minuta';


				SELECT 
					s.averba_minuta
				INTO 
					v_averba_minuta
				FROM 
					empresa_acesso_servicos s 
					LEFT JOIN empresa e
						ON e.id_empresa = s.id_empresa
				WHERE 
					id_servico_integracao = 1 
					AND e.codigo_empresa = NEW.empresa_emitente
				ORDER BY 
					id;

				IF v_averba_minuta = 0 THEN 
					RETURN NEW;
				END IF:
				
				SELECT id INTO vIdAverbacao FROM scr_conhecimento_averbacao WHERE id_conhecimento = NEW.id_conhecimento;

				RAISE NOTICE 'Id Averbacao %', vIdAverbacao;

				IF vIdAverbacao IS NULL THEN 
					RAISE NOTICE 'Incluindo na fila';
					INSERT INTO public.scr_conhecimento_averbacao(id_conhecimento)			
					VALUES (NEW.id_conhecimento);
				END IF;
			END IF;

			--Se houve cancelamento de minuta
			IF COALESCE(NEW.cancelado,0) = 1 AND COALESCE(OLD.cancelado,0) <> COALESCE(NEW.cancelado,0)  THEN 
				UPDATE scr_conhecimento_averbacao SET cancelado = 1 WHERE id_conhecimento = NEW.id_conhecimento;			
			END IF;				

		END IF;
		
	END IF; 

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

