
CREATE OR REPLACE FUNCTION f_tgg_set_conferencia_protocolo()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN

	BEGIN 
		IF COALESCE(NEW.usuario_conferencia,0) <> COALESCE(OLD.usuario_conferencia,0) THEN 

			INSERT INTO scr_notas_fiscais_imp_log_atividades (
				id_nota_fiscal_imp,
				data_hora,
				atividade_executada,
				usuario
			)
			SELECT 
				id_nota_fiscal_imp,
				NEW.data_conferencia,
				'CONFERENCIA PROTOCOLO ' || NEW.id_nf_protocolo::text,
				trim(usuarios.login_name)
			FROM 
				usuarios,
				scr_nf_protocolo_nf
			WHERE
				usuarios.id_usuario = NEW.usuario_conferencia
				AND 
				scr_nf_protocolo_nf.id_nf_protocolo = NEW.id_nf_protocolo;
		END IF;
		
	EXCEPTION WHEN OTHERS THEN 

	END;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_set_conferencia_protocolo
AFTER UPDATE 
ON scr_nf_protocolo
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_set_conferencia_protocolo()

