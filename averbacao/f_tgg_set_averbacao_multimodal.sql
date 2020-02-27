/*
-- Function: public.f_tgg_set_averbacao()
--SELECT * FROM empresa
SELECT string_agg(id_conhecimento::text,',') FROM scr_conhecimento WHERE empresa_emitente = '002' AND tipo_documento = 1 AND cstat = '100'
-- DROP FUNCTION public.f_tgg_set_averbacao();

UPDATE scr_conhecimento SET cstat = '000' WHERE id_conhecimento IN (263666,111189,113386,115488,118536,106926,129931,171327,129926,129929,129933,174595,175846,177263,178948,178966,180092,181312,182900,182897,183324,182918,181313,182899,171323,171326,171328,172792,177003,186481,188976,194659,190601,193191,193192,197965,197966);
UPDATE scr_conhecimento SET cstat = '100' WHERE id_conhecimento IN (263666,111189,113386,115488,118536,106926,129931,171327,129926,129929,129933,174595,175846,177263,178948,178966,180092,181312,182900,182897,183324,182918,181313,182899,171323,171326,171328,172792,177003,186481,188976,194659,190601,193191,193192,197965,197966);

SELECT * FROM scr_conhecimento_averbacao WHERE id_conhecimento IN (263666,111189,113386,115488,118536,106926,129931,171327,129926,129929,129933,174595,175846,177263,178948,178966,180092,181312,182900,182897,183324,182918,181313,182899,171323,171326,171328,172792,177003,186481,188976,194659,190601,193191,193192,197965,197966);
BEGIN;
DELETE FROM scr_conhecimento_averbacao WHERE id_conhecimento IN (263666,111189,113386,115488,118536,106926,129931,171327,129926,129929,129933,174595,175846,177263,178948,178966,180092,181312,182900,182897,183324,182918,181313,182899,171323,171326,171328,172792,177003,186481,188976,194659,190601,193191,193192,197965,197966)
COMMIT;
*/

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao()
  RETURNS trigger AS
$BODY$
DECLARE	
	vIdAverbacao integer;
	vLinha 	empresa_acesso_servicos%ROWTYPE; 
	vAverba integer;
BEGIN		

	IF TG_TABLE_NAME = 'scr_conhecimento' AND TG_OP = 'UPDATE' THEN 
		IF NEW.tipo_transporte IN (4,20,12) THEN 
			RETURN NULL;
		END IF ;

		IF NEW.responsavel_seguro <> 5 THEN
			RETURN NULL;
		END IF;
		
		IF NEW.tipo_documento = 1 AND NEW.modal IN (1, 2) THEN

			
			--Se houve emissao de cte
			IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '100' OR
				OLD.responsavel_seguro = 0
			THEN 

				--Para cada apolice de seguro, cria um registro
				FOR vLinha IN 
					SELECT 
						s.* 
					FROM 
						empresa_acesso_servicos s 
						LEFT JOIN empresa e
							ON e.id_empresa = s.id_empresa
					WHERE 
						id_servico_integracao = 1 
						AND e.codigo_empresa = NEW.empresa_emitente
						ORDER BY id 
				LOOP
					vAverba = 1;

					RAISE NOTICE 'Averbacao % ',vLinha.descricao;
					IF NEW.modal = 1 THEN 
						IF vLinha.averba_rodo = 0 THEN
							vAverba = 0;				
						END IF;
					END IF;

					
					IF NEW.modal = 2 THEN 
						IF vLinha.averba_aereo = 0 THEN 
							vAverba = 0;
						END IF;
					END IF;

					RAISE NOTICE 'Averba %', vAverba;
					IF vAverba = 1 THEN
						SELECT 
							id 
						INTO 
							vIdAverbacao 
						FROM 
							scr_conhecimento_averbacao 
						WHERE 
							id_conhecimento = NEW.id_conhecimento
							AND id_acesso_servico = vLinha.id;
	-- 						AND CASE 
	-- 							WHEN NEW.modal = 1 THEN vLinha.averba_rodo::boolean 
	-- 							WHEN NEW.modal = 2 THEN vLinha.averba_aereo::boolean
	-- 									   ELSE false
	-- 						END;

						RAISE NOTICE 'Averbacao % %',vLinha.descricao, vIdAverbacao;

						IF vIdAverbacao IS NULL THEN					
							INSERT INTO public.scr_conhecimento_averbacao(id_conhecimento, id_acesso_servico)
							VALUES (NEW.id_conhecimento, vLinha.id);
						END IF;
					END IF;
				END LOOP;
				
			END IF;		

			--Se houve cancelamento de cte
			IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '135'  THEN 
				UPDATE scr_conhecimento_averbacao SET cancelado = 1 WHERE id_conhecimento = NEW.id_conhecimento;			
			END IF;	
		END IF;


		
		IF NEW.tipo_documento = 2 THEN 
			RETURN NULL;
			--Se houve emissao de minuta
			IF COALESCE(OLD.status,0) <> COALESCE(NEW.status,0) AND COALESCE(NEW.status,0) = 1  THEN 
				SELECT id INTO vIdAverbacao FROM scr_conhecimento_averbacao WHERE id_conhecimento = NEW.id_conhecimento;

				IF vIdAverbacao IS NULL THEN 
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
