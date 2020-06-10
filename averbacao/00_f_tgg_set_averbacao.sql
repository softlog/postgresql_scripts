-- Function: public.f_tgg_set_averbacao()

-- DROP FUNCTION public.f_tgg_set_averbacao();

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao()
  RETURNS trigger AS
$BODY$
DECLARE	
	vIdAverbacao integer;
	vTemAverbacao integer;
BEGIN		


	
	IF TG_TABLE_NAME = 'scr_conhecimento' AND TG_OP = 'UPDATE' THEN 

		

		IF NEW.empresa_emitente = '003' THEN
			RETURN NULL;
		END IF;
		
		IF NEW.tipo_transporte IN (4,20,12) THEN 
			RETURN NULL;
		END IF ;

		SELECT 	count(*) 
		INTO 	vTemAverbacao 
		FROM 	empresa_acesso_servicos
			LEFT JOIN empresa
				ON empresa.id_empresa = empresa_acesso_servicos.id_empresa			
		WHERE
			id_servico_integracao IN (1,100)
			AND empresa.codigo_empresa = NEW.empresa_emitente;

		IF vTemAverbacao = 0 THEN 
			RETURN NULL;
		END IF;

-- 		IF NEW.responsavel_seguro <> 5 THEN
-- 			RETURN NULL;
-- 		END IF;

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
ALTER FUNCTION public.f_tgg_set_averbacao()
  OWNER TO softlog_transribeiro;
