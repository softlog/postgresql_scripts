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

	/* Alimenta variavel v_id_romaneio com o id_romaneio 
	  	que pode vir de colunas de nomes diferentes

	*/	
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

		--Insere ocorrencia de transporte iniciado quando for feito romaneio de conhecimento e entrega
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
	
	
	-- Se o romaneio tem mais de uma nota fiscal busca valores na sessao
	v_cpf = fp_get_session('motorista_romaneio_' || v_id_romaneio::text);
	v_data_romaneio = fp_get_session('data_romaneio_' || v_id_romaneio::text);


	-- Se nao tem variavel de sessao, busca dados no romaneio no registro 
	IF v_cpf IS NULL THEN 
	
		--Grava as informacoes para proxima nota fiscal da transacao.
		SELECT cpf_motorista, data_saida::text
		INTO v_cpf, v_data_romaneio
		FROM scr_romaneios 
		WHERE id_romaneio = v_id_romaneio;

		PERFORM fp_set_session('motorista_romaneio_' || v_id_romaneio::text,v_cpf);
		PERFORM fp_set_session('data_romaneio_' || v_id_romaneio::text, v_data_romaneio);
		
	END IF;


	-- Controla alteracoes na composicao do romaneio
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


	--Enfileira para exclusao
	IF TG_OP = 'DELETE' THEN 

		IF v_data_romaneio::timestamp > now() THEN
			v_data_ult = v_data_romaneio::timestamp;
		ELSE 
			v_data_ult = now();
		END IF;		


		IF TG_TABLE_NAME = 'scr_romaneios_nf' THEN 		 
			INSERT INTO fila_envio_app (id_romaneio, tipo_documento, cpf, data_romaneio, data_alteracao, id_nota_fiscal_imp)
			VALUES (v_id_romaneio, 2, v_cpf, v_data_romaneio::date, v_data_ult, NEW.id_nota_fiscal_imp);
		END IF;

		IF TG_TABLE_NAME = 'scr_conhecimento_entrega' THEN 
			INSERT INTO fila_envio_app (id_romaneio, tipo_documento, cpf, data_romaneio, data_alteracao, id_nota_fiscal_imp)
			VALUES (v_id_romaneio, 3, v_cpf, v_data_romaneio::date, v_data_ult, NEW.id_nota_fiscal_imp);	
		END IF;

	END IF;
		
	
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
