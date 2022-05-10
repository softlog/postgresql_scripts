
CREATE OR REPLACE FUNCTION f_tgg_email_uid_imap()
  RETURNS trigger AS
$BODY$
DECLARE
	vQt integer;
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

	SELECT count(*)
	INTO vQt
	FROM email_uid_imap 
	WHERE empresa_acesso_servico_id = NEW.empresa_acesso_servico_id
		AND 
	      uid = NEW.uid
	      AND id <> NEW.id;

	IF vQt > 0 THEN 
		RETURN NULL;
	END IF;
         
	RETURN NEW;

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


DROP TRIGGER tgg_email_uid_imap ON email_uid_imap;
CREATE TRIGGER tgg_email_uid_imap
BEFORE INSERT 
ON email_uid_imap
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_email_uid_imap();
