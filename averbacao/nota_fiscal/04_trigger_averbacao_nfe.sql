-- Function: public.f_tgg_set_averbacao_manifesto()

-- DROP FUNCTION public.f_tgg_set_averbacao_manifesto();

CREATE OR REPLACE FUNCTION public.f_tgg_send_averbacao_fila_nfe()
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
		IF fp_get_session('send_nfe_fila_homologacao') == '1' THEN 
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE trim(banco_dados) = trim(current_database());

			RAISE NOTICE 'Enfileirando NFe';

			INSERT INTO public.msg_fila_averb_atm(id_doc, id_banco_dados, status, data_fila, id_averbacao, is_nfe)
			VALUES (NEW.id_nota_fiscal_imp, vIdBancoDados, 0, NOW(), NEW.id, 1);				

		END IF;
	END IF;
	
	
	--Obtem o id do banco de dados
	SELECT id_string_conexao 
	INTO vIdBancoDados 
	FROM string_conexoes 
	WHERE trim(banco_dados) = trim(current_database());

	RAISE NOTICE 'Enfileirando Manifesto';
	
	INSERT INTO public.msg_fila_averb_atm(id_doc, id_banco_dados, status, data_fila, id_averbacao, is_nfe)
	VALUES (NEW.id_nota_fiscal_imp, vIdBancoDados, 0, NOW(), NEW.id, 1);				

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



CREATE TRIGGER tgg_send_averbacao_nfe_fila
  AFTER INSERT OR UPDATE OF cancelado, reenvia
  ON public.scr_nfe_averbacao
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_send_averbacao_fila_nfe();