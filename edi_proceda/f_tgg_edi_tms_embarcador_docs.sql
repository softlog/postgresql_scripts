-- Function: public.f_tgg_edi_tms_embarcador_docs()

-- DROP FUNCTION public.f_tgg_edi_tms_embarcador_docs();

CREATE OR REPLACE FUNCTION public.f_tgg_edi_tms_embarcador_docs()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_bd integer;
	v_qt integer;
BEGIN

	SELECT 	id_string_conexao 
	INTO 	v_id_bd
	FROM 	string_conexoes
	WHERE 	banco_dados = current_database();

	IF TG_OP = 'DELETE' THEN 
		v_qt = 1;
	ELSE
		SELECT 	count(*) as qt
		INTO  	v_qt
		FROM 	edi_tms_agenda_envio 
		WHERE 	id_subscricao = NEW.id_embarcador_doc
			AND id_banco_dados = v_id_bd;
	END IF;

--	RAISE NOTICE 'Quantidade %',v_qt::text;
	--Se nao existe lancamento na agenda, faz um lancamento
	IF v_qt = 0 THEN 		
		--Insere na agenda central
		IF TG_OP IN ('INSERT','UPDATE') THEN					
			IF NEW.tipo_evento IN (1,2,3,6) THEN 
				INSERT INTO edi_tms_agenda_envio 
					(
						id_banco_dados,
						id_subscricao,
						tipo_evento,
						periodo,
						horario
					)
				VALUES
					(
						v_id_bd,
						NEW.id_embarcador_doc,
						NEW.tipo_evento,
						COALESCE(NEW.periodo,0),
						COALESCE(NEW.horario,0)
					);
			END IF;
		END IF;
	ELSE 
	

		--Atualiza agenda central
		IF TG_OP = 'UPDATE' THEN 
			IF NEW.tipo_evento IN (1,2,3,6) THEN 

			RAISE NOTICE 'Proximo % ', f_edi_tms_proximo_processamento(
							NEW.tipo_evento,
							COALESCE(NEW.periodo,0),
							COALESCE(NEW.horario,0),
							NULL::timestamp)::text;
							
				UPDATE edi_tms_agenda_envio SET
					tipo_evento 		= NEW.tipo_evento,
					periodo 		= NEW.periodo,
					horario			= NEW.horario,
					proximo_processamento 	= f_edi_tms_proximo_processamento(
							NEW.tipo_evento,
							COALESCE(NEW.periodo,0),
							COALESCE(NEW.horario,0),
							NULL::timestamp
						)
				WHERE
					id_subscricao = NEW.id_embarcador_doc 
					AND id_banco_dados = v_id_bd;
			ELSE
				IF OLD.tipo_evento IN (1,2,3,6) THEN 
					DELETE FROM 
						edi_tms_agenda_envio 
					WHERE 
						id_subscricao = NEW.id_embarcador_doc 
						AND id_banco_dados = v_id_bd;
				END IF;
			END IF;
		END IF;

		--Exclui da agenda central
		IF TG_OP = 'DELETE' THEN 
			DELETE FROM 
				edi_tms_agenda_envio 
			WHERE 
				id_subscricao = OLD.id_embarcador_doc 
				AND id_banco_dados = v_id_bd;
		END IF;
	END IF;
	
	
        RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

 --ALTER FUNCTION public.f_tgg_edi_tms_embarcador_docs() OWNER TO softlog_dng
