-- Function: public.f_tgg_send_averbacao_fila_manifesto()

-- DROP FUNCTION public.f_tgg_send_averbacao_fila_manifesto();

CREATE OR REPLACE FUNCTION public.f_tgg_send_averbacao_fila_romaneio()
  RETURNS trigger AS
$BODY$
DECLARE
	vIdBancoDados integer;
	v_count integer;
BEGIN	

	IF TG_OP = 'DELETE' THEN 
		RETURN NULL;
	END IF;
	
	IF TG_OP = 'UPDATE' THEN 
		--Não envia para averbacao novamente
		IF NEW.reenvia = 0 AND NEW.cancelado = 0 THEN 
			RETURN NULL;
		END IF;

	 	IF OLD.cancelado = 1 AND NEW.cancelado = 1 AND NEW.reenvia = 0 THEN 
	 		RETURN NULL;
	 	END IF;

	 	
	END IF;

--	SELECT * FROM string_conexoes

	IF current_database() = 'softlog_dng' THEN 
		vIdBancoDados = 53;
	ELSE 
	--Obtem o id do banco de dados
		SELECT id_string_conexao 
		INTO vIdBancoDados 
		FROM string_conexoes 
		WHERE trim(banco_dados) = trim(current_database());
	END IF;
	RAISE NOTICE 'Enfileirando ROMANEIO';
	
	INSERT INTO msg_fila_averb_atm(id_doc, id_banco_dados, status, data_fila, id_averbacao, is_manifesto, is_romaneio)
	VALUES (NEW.id_romaneio, vIdBancoDados, 0, NOW(), NEW.id, 0, 1);				

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
