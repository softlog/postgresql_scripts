ALTER TABLE scr_romaneios ADD COLUMN data_emissao timestamp;

CREATE OR REPLACE FUNCTION f_tgg_set_data_emissao()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN
	IF COALESCE(NEW.emitido,0) = 1 AND COALESCE(OLD.emitido, 0) = 0 THEN 
		NEW.data_emissao = now();
	END IF;
	
     RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



CREATE TRIGGER tgg_romaneio_data_emissao
BEFORE INSERT OR UPDATE 
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_set_data_emissao();


