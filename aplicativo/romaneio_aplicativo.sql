/*
UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE id_romaneio =3928
SELECT * FROM fila_envio_app ORDER BY 1 DESC
*/
CREATE OR REPLACE FUNCTION f_tgg_update_fila_app()
  RETURNS trigger AS
$BODY$
DECLARE
	v_data_ult timestamp;
	v_id_fila integer;
	v_cpf integer;
BEGIN

	
	
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN 

		SELECT id
		INTO v_id_fila
		FROM fila_envio_app
		WHERE id_romaneio = NEW.id_romaneio AND tipo_documento = 1;

		--RAISE NOTICE 'Fila %', v_id_fila;
		--RAISE NOTICE 'Data Saida %', NEW.data_saida;
		IF NEW.data_saida > now() THEN	
			--RAISE NOTICE 'Data Saida maior que agora';			
			v_data_ult = NEW.data_saida::timestamp;
		ELSE 
			v_data_ult = now();
		END IF;

		--RAISE NOTICE 'Data %', v_data_ult;
		IF v_id_fila IS NULL THEN 
			
			INSERT INTO fila_envio_app (id_romaneio, tipo_documento, cpf, data_romaneio, data_alteracao)
			VALUES (NEW.id_romaneio, 1, NEW.cpf_motorista, v_data_ult::date, v_data_ult);
		ELSE
			UPDATE fila_envio_app SET 
				data_alteracao = v_data_ult,
				data_romaneio = NEW.data_saida::date,
				cpf = NEW.cpf_motorista
			WHERE id = v_id_fila;
		END IF;		
	END IF;         
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

