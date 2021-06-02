-- Function: public.f_tgg_enfileira_nf_app()

-- DROP FUNCTION public.f_tgg_enfileira_nf_app();

CREATE OR REPLACE FUNCTION public.f_tgg_enfileira_nf_app()
  RETURNS trigger AS
$BODY$
DECLARE
	v_cpf text;
	v_data_romaneio text;
	v_id_romaneio integer;
	v_data_alteracao timestamp;
	v_id_fila integer;	
	v_data_ult timestamp;
	
BEGIN

	IF TG_TABLE_NAME = 'scr_romaneio_nf' THEN 	

		IF TG_OP = 'DELETE' THEN 
			v_id_romaneio = OLD.id_romaneio;
		ELSE
			v_id_romaneio = NEW.id_romaneio;
		END IF;
	END IF;

	
	IF TG_TABLE_NAME = 'scr_conhecimento_entrega' THEN 	

		IF TG_OP = 'DELETE' THEN 
			v_id_romaneio = OLD.id_romaneios;
		ELSE
			v_id_romaneio = NEW.id_romaneios;
		END IF;

		IF TG_OP = 'INSERT' THEN 

			
			INSERT INTO scr_conhecimento_ocorrencias_nf (
				id_conhecimento,
				id_conhecimento_notas_fiscais,
				id_ocorrencia,
				data_ocorrencia,
				hora_ocorrencia,
				canhoto
			) 
			SELECT 
				NEW.id_conhecimento,
				nf.id_conhecimento_notas_fiscais,
				0,
				current_date,
				to_char(now(),'HH24:MI'),
				0
			FROM 
				scr_conhecimento_notas_fiscais nf
			WHERE 
				nf.id_conhecimento = NEW.id_conhecimento;				
		END IF;
		

		
	END IF;
	
	
	
	v_cpf = fp_get_session('motorista_romaneio_' || v_id_romaneio::text);
	v_data_romaneio = fp_get_session('data_romaneio_' || v_id_romaneio::text);

	IF v_cpf IS NULL THEN 
		--Grava as informacoes para proxima nota fiscal da transacao.
		SELECT cpf_motorista, data_saida::text
		INTO v_cpf, v_data_romaneio
		FROM scr_romaneios 
		WHERE id_romaneio = v_id_romaneio;

		PERFORM fp_set_session('motorista_romaneio_' || v_id_romaneio::text,v_cpf);
		PERFORM fp_set_session('data_romaneio_' || v_id_romaneio::text, v_data_romaneio);
		
	END IF;

	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN 

		SELECT id
		INTO v_id_fila
		FROM fila_envio_app
		WHERE id_romaneio = v_id_romaneio AND tipo_documento = 1;

		
		IF v_data_romaneio::timestamp > now() THEN
			v_data_ult = v_data_romaneio::timestamp;
		ELSE 
			v_data_ult = now();
		END IF;
	
		IF v_id_fila IS NULL THEN 
			INSERT INTO fila_envio_app (id_romaneio, tipo_documento, cpf, data_romaneio, data_alteracao)
			VALUES (v_id_romaneio, 1, v_cpf, v_data_romaneio::date, v_data_ult);
		ELSE
			UPDATE fila_envio_app SET 
				data_alteracao = v_data_ult,
				cpf = v_cpf
			WHERE id = v_id_fila;
		END IF;		
	END IF;

	
	--SELECT data_previsao_entrega FROM scr_notas_fiscais_imp 

	--SELECT * FROM regiao_cidades
	--SELECT id_romaneio, id_origem, id_destino, id_setor FROM scr_romaneios ORDER BY 1 DESC

	--SELECT * FROM cidades WHERE id_cidade = 3400
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
