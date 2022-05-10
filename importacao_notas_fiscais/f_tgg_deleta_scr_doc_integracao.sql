-- Function: public.f_tgg_deleta_scr_doc_integracao()

-- DROP FUNCTION public.f_tgg_deleta_scr_doc_integracao();

CREATE OR REPLACE FUNCTION public.f_tgg_deleta_scr_doc_integracao()
  RETURNS trigger AS
$BODY$
BEGIN
	--NAO EXECUTA TRIGGER
	IF fp_get_session('nao_executa_trigger') IS NOT NULL AND TG_OP = 'UPDATE' THEN 
	
		IF TG_WHEN = 'AFTER' THEN 
			RETURN NULL;
		END IF;

		IF TG_WHEN = 'BEFORE' THEN 
			RETURN NEW;
		END IF;

	END IF;
	
	IF TG_OP = 'DELETE' THEN
		DELETE FROM scr_doc_integracao WHERE chave_doc = OLD.chave_nfe;
		DELETE FROM scr_doc_integracao_nfe WHERE chave_doc = OLD.chave_nfe;
	END IF;
	
	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

