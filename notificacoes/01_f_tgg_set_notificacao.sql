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
	/*
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
	*/

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


	IF TG_TABLE_NAME = 'scr_conhecimento' AND TG_OP = 'UPDATE' THEN 

		--Obtem o id do banco de dados
		SELECT id_string_conexao 
		INTO vIdBancoDados 
		FROM string_conexoes 
		WHERE trim(banco_dados) = current_database();


		--Se houve emissao de cte
		IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '100'  THEN 
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
			VALUES (210, NEW.id_conhecimento, vIdBancoDados, 0, NOW());	


			--Envio de XML por CTe Emitido	
			SELECT COUNT(*) 
			INTO vTemNotificacao 
			FROM msg_subscricao 
				LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao				
			WHERE 
				msg_subscricao.id_notificacao = 402
				AND msg_subscricao.ativo = 1
				AND msg_subscricao.email IS NOT NULL 
				AND msg_subscricao.id_fornecedor = NEW.redespachador_id
				AND msg_notificacao.ativo = 1;
			

			IF vTemNotificacao > 0 THEN 
				--Obtem o id do banco de dados
				

				--Grava as informações na Fila
				INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, id_parceiro)
				SELECT
					402,
					id_conhecimento_notas_fiscais,
					vIdBancoDados,
					0,
					NEW.redespachador_id
				FROM 
					scr_conhecimento_notas_fiscais
				WHERE 
					id_conhecimento = NEW.id_conhecimento;				
			END IF;	

			
		END IF;



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
			--Grava as informações no Pool 
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
			VALUES (10, NEW.id_conhecimento, vIdBancoDados, 0, NOW());				
		END IF;	
			
	END IF; 


	-- Tabela de Faturamento (Momento em que a fatura é criada no sistema)
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' THEN 

		RAISE NOTICE 'Scr Romaneios';
		
 		IF COALESCE(NEW.emitido,0) =  COALESCE(OLD.emitido,0) AND OLD.emitido = 1 THEN 
			RAISE NOTICE 'Não Enfileira';
			RETURN NULL;
 		END IF;

		IF NEW.emitido = 0 THEN 
			RAISE NOTICE 'Não Enfileira';
			RETURN NULL;
		END IF;
		
		RAISE NOTICE 'Tem notificacao?';

		--Envio de XML por CTe Romaneado	
		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 401
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.id_fornecedor = NEW.id_transportador_redespacho
			AND msg_notificacao.ativo = 1;
		

		IF vTemNotificacao > 0 THEN 
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE banco_dados = user;

			--Grava as informações na Fila
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, id_parceiro)
			SELECT
				401,
				nf.id_conhecimento_notas_fiscais,
				vIdBancoDados,
				0,
				NEW.id_transportador_redespacho
			FROM 
				scr_conhecimento_entrega e
				LEFT JOIN scr_conhecimento_notas_fiscais nf
					ON nf.id_conhecimento = e.id_conhecimento
			WHERE 
				id_romaneios = NEW.id_romaneio;				
		END IF;		 


		--Envio de XML por NFe Romaneado	
		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 400
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.id_fornecedor = NEW.id_transportador_redespacho
			AND msg_notificacao.ativo = 1;
		

		IF vTemNotificacao > 0 THEN 
			RAISE NOTICE 'ENVIO 400';
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE banco_dados = user;

			--Grava as informações na Fila
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, id_parceiro)
			SELECT
				400,
				rnf.id_nota_fiscal_imp,
				vIdBancoDados,
				0,
				NEW.id_transportador_redespacho
			FROM 
				scr_romaneio_nf rnf				
			WHERE 
				id_romaneio = NEW.id_romaneio;				
		END IF;	

		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 205
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.id_fornecedor = NEW.id_transportador_redespacho
			AND msg_notificacao.ativo = 1;
		

		IF vTemNotificacao > 0 THEN 
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE banco_dados = user;

			--Grava as informações na Fila
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, id_parceiro)
			SELECT
				205,
				e.id_conhecimento,
				vIdBancoDados,
				0,
				NEW.id_transportador_redespacho
			FROM 
				scr_conhecimento_entrega e
			WHERE 
				id_romaneios = NEW.id_romaneio;				
		END IF;		 

		SELECT COUNT(*) 
		INTO vTemNotificacao 
		FROM msg_subscricao 
			LEFT JOIN msg_notificacao ON msg_subscricao.id_notificacao = msg_notificacao.id_notificacao
		WHERE 
			msg_subscricao.id_notificacao = 206
			AND msg_subscricao.ativo = 1
			AND msg_subscricao.email IS NOT NULL 
			AND msg_subscricao.id_fornecedor = NEW.id_transportador_redespacho
			AND msg_notificacao.ativo = 1;
		

		IF vTemNotificacao > 0 THEN 
			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO vIdBancoDados 
			FROM string_conexoes 
			WHERE banco_dados = user;

			--Grava as informações na Fila
			INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, id_parceiro)
			SELECT
				206,
				nf.id_conhecimento,
				vIdBancoDados,
				0,
				NEW.id_transportador_redespacho
			FROM 
				scr_romaneio_nf e
				LEFT JOIN scr_notas_fiscais_imp nf
					ON nf.id_nota_fiscal_imp = e.id_nota_fiscal_imp								
			WHERE 
				e.id_romaneio = NEW.id_romaneio;				
		END IF;		 
				
	END IF; 


	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp_ocorrencias'  THEN 

		
		IF TG_OP = 'UPDATE' THEN
		--	RETURN NEW;
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
				--RAISE NOTICE 'Tem notificacao';
				--Grava as informações no Pool 
				INSERT INTO msg_fila_envio(id_notificacao, id_chave_notificacao, id_banco_dados, status, data_envio)
				VALUES (4, NEW.id_ocorrencia_nf, vIdBancoDados, 0, NOW());
			END IF;
		END IF;
		 
	END IF; 
	

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
