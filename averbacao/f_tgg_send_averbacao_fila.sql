-- Function: public.f_tgg_send_averbacao_fila()

-- DROP FUNCTION public.f_tgg_send_averbacao_fila();

CREATE OR REPLACE FUNCTION public.f_tgg_send_averbacao_fila()
  RETURNS trigger AS
$BODY$
DECLARE
	vIdBancoDados integer;
	v_count integer;
BEGIN	
	IF NEW.reenvia = 0 AND TG_OP = 'UPDATE' AND NEW.cancelado = 0 THEN 
		RAISE NOTICE 'Abortando enfileiramento';
		RETURN NULL;
	END IF;

	RAISE NOTICE 'Enviando pra fila de averbacao';
	
	--Obtem o id do banco de dados
	SELECT id_string_conexao 
	INTO vIdBancoDados 
	FROM string_conexoes 
	WHERE trim(banco_dados) = trim(current_database());


	INSERT INTO public.msg_fila_averb_atm(id_doc, id_banco_dados, status, data_fila)
	VALUES (NEW.id_conhecimento, vIdBancoDados, 0, NOW());				

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
