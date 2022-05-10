-- Function: public.f_tgg_set_notificacao()

-- DROP FUNCTION public.f_tgg_set_notificacao();

CREATE OR REPLACE FUNCTION public.f_tgg_set_notificacao()
  RETURNS trigger AS
$BODY$
DECLARE
	vTemNotificacao integer;
	vIdBancoDados integer;
	vRemetente integer;
	vDestinatario integer; 
	vPagador integer;
	vConsigRed integer;
	vGeraNotificacao integer;
BEGIN		
	--Coloca na fila de envio de email

	
	-- Tabela de Faturamento (Momento em que a fatura é criada no sistema)
	IF TG_TABLE_NAME = 'scr_faturamento' AND TG_OP = 'INSERT' THEN 
		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 100 
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.codigo_cliente = NEW.fatura_sacado_id 
			AND msg_notificacao.ativo = 1;		

		

		IF vTemNotificacao > 0 THEN 
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE banco_dados = user;

			--Grava as informações no Pool 
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status)
			VALUES (100, NEW.id_faturamento, vIdBancoDados, 0);
		END IF;
		 
	END IF; 

	IF TG_TABLE_NAME = 'scr_conhecimento_notas_fiscais' AND TG_OP = 'UPDATE' THEN 

		--Se não houve alteração de valor, nada faz.
		IF COALESCE(NEW.id_ocorrencia,0) = COALESCE(OLD.id_ocorrencia,1) THEN 
 			RETURN NULL;
 		END IF;

		--SELECT * FROM cliente WHERE cnpj_cpf = '61512687000139'
		--SELECT * FROM msg_subscricao WHERE codigo_cliente = 34301
		
		SELECT gera_notificacao INTO vGeraNotificacao FROM scr_ocorrencia_edi WHERE codigo_edi = NEW.id_ocorrencia;

		IF vGeraNotificacao = 1 THEN 

			SELECT remetente_id, destinatario_id, pagador_id 
			INTO vRemetente, vDestinatario, vPagador
			FROM scr_conhecimento 
			WHERE id_conhecimento = NEW.id_conhecimento;

			
			SELECT COUNT(*) 
			INTO vTemNotificacao 
			FROM msg_subscricao 
				LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
			WHERE 
				msg_subscricao.id_notificacao = 1 
				AND msg_subscricao.ativo = 1
				AND msg_subscricao.email IS NOT NULL 
				AND msg_subscricao.codigo_cliente IN (vRemetente, COALESCE(vPagador,vRemetente))
				AND msg_notificacao.ativo = 1;		

			--SELECT * FROM msg_notificacao
			--UPDATE msg_notificacao SET ativo = 1 WHERE id_notificacao = 1

			IF vTemNotificacao > 0 THEN 
				--Obtem o id do banco de dados
				SELECT id_string_conexao 
				INTO vIdBancoDados 
				FROM string_conexoes 
				WHERE trim(banco_dados) = trim(user);

				--Grava as informações no Pool 
				INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
				VALUES (1, NEW.id_conhecimento_notas_fiscais, vIdBancoDados, 0, NOW());
			END IF;
		END IF;
		 
	END IF; 


	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp_ocorrencias'  THEN 

		
		IF TG_OP = 'UPDATE' THEN
			RETURN NEW;
		END IF;

		
		
		

		IF NEW.id_ocorrencia = 0 THEN 
			RETURN NEW;
		END IF;
		--SELECT * FROM scr_notas_fiscais_imp_ocorrencias LIMIT 1
		--SELECT * FROM cliente WHERE cnpj_cpf = '61512687000139'
		--SELECT * FROM msg_subscricao WHERE codigo_cliente = 34301
		
		SELECT gera_notificacao INTO vGeraNotificacao FROM scr_ocorrencia_edi WHERE codigo_edi = NEW.id_ocorrencia;

		--RAISE NOTICE 'Gera Notificacao %', vGeraNotificacao;
		
		IF vGeraNotificacao = 1 THEN 

			SELECT remetente_id, destinatario_id
			INTO vRemetente, vDestinatario
			FROM scr_notas_fiscais_imp 
			WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

			
			SELECT COUNT(*) 
			INTO vTemNotificacao 
			FROM msg_subscricao 
				LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
			WHERE 
				msg_subscricao.id_notificacao = 4
				AND msg_subscricao.ativo = 1
				AND msg_subscricao.email IS NOT NULL 
				AND msg_subscricao.codigo_cliente IN (vRemetente, vDestinatario)
				AND msg_notificacao.ativo = 1;		

			--SELECT * FROM msg_notificacao
			--UPDATE msg_notificacao SET ativo = 1 WHERE id_notificacao = 1

			IF vTemNotificacao > 0 THEN 
				--Obtem o id do banco de dados
				SELECT id_string_conexao 
				INTO vIdBancoDados 
				FROM string_conexoes 
				WHERE trim(banco_dados) = trim(current_database());

				--Grava as informações no Pool 
				INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
				VALUES (4, NEW.id_ocorrencia_nf, vIdBancoDados, 0, NOW());
			END IF;
		END IF;
		 
	END IF; 



	IF TG_TABLE_NAME = 'scr_conhecimento' AND TG_OP = 'UPDATE' THEN 

		--Se não houve alteração de valor, nada faz.
		IF COALESCE(NEW.status,0) = COALESCE(OLD.status,0) THEN 
 			RETURN NULL;
 		END IF;


		IF COALESCE(NEW.status,0) <> 5 THEN 
			RETURN NULL;
		END IF;
 		--SELECT * FROM cliente WHERE cnpj_cpf = '61512687000139'
		--SELECT * FROM msg_subscricao WHERE codigo_cliente = 34301
		
		SELECT remetente_id, destinatario_id, pagador_id 
		INTO vRemetente, vDestinatario, vPagador
		FROM scr_conhecimento 
		WHERE id_conhecimento = NEW.id_conhecimento;

			
		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 10
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.codigo_cliente IN (vRemetente, COALESCE(vPagador,vRemetente))
			AND msg_notificacao.ativo = 1;		

		--SELECT * FROM msg_notificacao
		--UPDATE msg_notificacao SET ativo = 1 WHERE id_notificacao = 1
		
		--vTemNotificacao = 1;
		IF vTemNotificacao > 0 THEN 
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE trim(banco_dados) = trim(user);

			--Grava as informações no Pool 
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
			VALUES (10, NEW.id_conhecimento, vIdBancoDados, 0, NOW());
		END IF;		 
	END IF; 

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_tgg_set_notificacao()
  OWNER TO softlog_dfreire;
