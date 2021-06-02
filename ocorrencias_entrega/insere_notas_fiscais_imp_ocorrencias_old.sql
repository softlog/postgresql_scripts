-- Function: public.insere_notas_fiscais_imp_ocorrencias()

-- DROP FUNCTION public.insere_notas_fiscais_imp_ocorrencias();

CREATE OR REPLACE FUNCTION public.insere_notas_fiscais_imp_ocorrencias()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_nota_fiscal_imp integer;
	v_id_db integer;
BEGIN

	
	v_id_nota_fiscal_imp = fp_get_session('id_nota_fiscal_imp')::integer;
	RAISE NOTICE 'id_nota_fiscal_imp %', v_id_nota_fiscal_imp;

	IF v_id_nota_fiscal_imp = NEW.id_nota_fiscal_imp THEN  
		RETURN NULL;
	END IF;
	
	IF TG_OP = 'INSERT' THEN 
		INSERT INTO scr_notas_fiscais_imp_ocorrencias(
			id_nota_fiscal_imp, 
			id_ocorrencia,
			data_ocorrencia,
			data_registro,
			canhoto,
			obs_ocorrencia)
		 VALUES(
			NEW.id_nota_fiscal_imp,
			NEW.id_ocorrencia,
			COALESCE(NEW.data_ocorrencia, NOW()),
			now(),
			NEW.canhoto,
			NEW.obs_ocorrencia);


-- 		IF NEW.codigo_integracao IS NOT NULL AND 1=2 THEN 	
-- 			SELECT id_string_conexao
-- 			INTO v_id_db 
-- 			FROM string_conexoes 
-- 			WHERE banco_dados = current_database();
-- 			
-- 			INSERT INTO msg_fila_edi (id_notificacao, id_chave_notificacao, id_banco_dados)
-- 			VALUES (20,NEW.id_nota_fiscal_imp::text,v_id_db);
-- 		 
-- 		END IF;

	ELSE
		-- Grava ocorrencia no histórico só se tiver alteração de ocorrência
		IF OLD.id_ocorrencia = 1 THEN 
			RETURN NULL;
		END IF;
		
		IF 	COALESCE(OLD.id_ocorrencia,-1) <> COALESCE(NEW.id_ocorrencia, 0) 
			OR COALESCE(OLD.data_ocorrencia,current_date) <> COALESCE(NEW.data_ocorrencia,current_date) 
			OR COALESCE(OLD.canhoto,-1) <> COALESCE(NEW.canhoto, -1)
			OR COALESCE(OLD.obs_ocorrencia,'') <> COALESCE(NEW.obs_ocorrencia,'') 
		THEN 
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto,
				obs_ocorrencia)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				NEW.id_ocorrencia,
				COALESCE(NEW.data_ocorrencia, NOW()),
				now(),
				NEW.canhoto,
				NEW.obs_ocorrencia);	

-- 			IF NEW.codigo_integracao IS NOT NULL AND 1=2 THEN 	
-- 				SELECT id_string_conexao
-- 				INTO v_id_db 
-- 				FROM string_conexoes 
-- 				WHERE banco_dados = current_database();
-- 				
-- 				INSERT INTO msg_fila_edi (id_notificacao, id_chave_notificacao, id_banco_dados)
-- 				VALUES (20,NEW.id_nota_fiscal_imp::text,v_id_db);			 
-- 			END IF;

		END IF;
	END IF;



	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
