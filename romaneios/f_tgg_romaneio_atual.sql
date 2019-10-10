-- Function: public.f_tgg_romaneio_atual()

-- DROP FUNCTION public.f_tgg_romaneio_atual();

CREATE OR REPLACE FUNCTION public.f_tgg_romaneio_atual()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_romaneio_nf integer;
BEGIN
	IF TG_OP = 'INSERT' THEN 
		UPDATE scr_notas_fiscais_imp 
			SET id_romaneio = NEW.id_romaneio 
		WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

		RETURN NEW;
	END IF;

	IF TG_OP = 'DELETE' THEN 
		
		SELECT id_romaneio 
		INTO v_id_romaneio_nf
		FROM scr_notas_fiscais_imp
		WHERE id_nota_fiscal_imp = OLD.id_nota_fiscal_imp;

		IF v_id_romaneio_nf = OLD.id_romaneio THEN 
			UPDATE scr_notas_fiscais_imp 
				SET id_romaneio = NULL
			WHERE id_nota_fiscal_imp = OLD.id_nota_fiscal_imp;
		END IF;

		RETURN OLD;
			
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE TRIGGER tgg_delete_romaneio_nf
AFTER DELETE
ON scr_romaneio_nf
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_romaneio_atual();



--SELECT * FROM scr_romaneio_nf ORDER BY 1 DESC LIMIT 10

--DELETE FROM scr_romaneio_nf WHERE id_romaneio_nf = 88433
--SELECT id_romaneio FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 4228226;