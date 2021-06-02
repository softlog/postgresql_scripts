ALTER TABLE scr_romaneios ADD COLUMN dt_emissao timestamp;

CREATE OR REPLACE FUNCTION f_tgg_set_data_emissao()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN
	IF COALESCE(NEW.emitido,0) <> COALESCE(OLD.emitido,0) AND NEW.emitido = 1 THEN 
		NEW.dt_emissao = NOW();
	END IF;    

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_set_data_emissao
BEFORE UPDATE 
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_set_data_emissao();

