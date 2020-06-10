-- Function: public.f_tgg_set_averbacao_manifesto()
/*
SELECT max(id_romaneio) FROM scr_romaneios WHERE emitido = 1 ;
TRUNCATE scr_romaneio_averbacao;
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 160840;
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 160840;
SELECT * FROM scr_romaneio_averbacao;
SELECT * FROM public.msg_fila_averb_atm WHERE id_banco_dados = 53 AND status = 0 is_romaneio = 1;
SELECT * FROM scr_romaneio_averbacao

DELETE FROM msg_fila_averb_atm WHERE id_banco_dados = 53 AND is_romaneio = 0
UPDATE empresa_acesso_servicos SET averba_romaneio = 1 WHERE id_servico_integracao = 1
*/
-- DROP FUNCTION public.f_tgg_set_averbacao_manifesto();

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao_romaneio()
  RETURNS trigger AS
$BODY$
DECLARE	

	vIdAverbacao integer;
	vLinha 	empresa_acesso_servicos%ROWTYPE; 
	vAverba integer;
	
BEGIN		

	
	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' THEN 

		--RAISE NOTICE 'Disparando Trigger';
	
		BEGIN 
			--Se houve emissao do manifesto
			IF COALESCE(OLD.averbar,-1) <> COALESCE(NEW.averbar,-1) AND COALESCE(NEW.averbar,-1) = 1
			THEN 
			--Para cada apolice de seguro, cria um registro			
				FOR vLinha IN SELECT * FROM empresa_acesso_servicos WHERE id_servico_integracao = 1 ORDER BY id LOOP
								
					vAverba = 1;

					RAISE NOTICE 'Dados de Averbacao % ', vLinha.descricao;
					
					IF vLinha.averba_romaneio = 0 THEN
						RAISE NOTICE 'Não Averba';
						vAverba = 0;
					END IF;


					IF vAverba = 1 THEN
						SELECT 
							id 
						INTO 
							vIdAverbacao 
						FROM 
							scr_romaneio_averbacao 
						WHERE 
							id_romaneio = NEW.id_romaneio
							AND id_acesso_servico = vLinha.id;


						RAISE NOTICE 'Averbacao % %',vLinha.descricao, vIdAverbacao;

						IF vIdAverbacao IS NULL THEN		
							INSERT INTO public.scr_romaneio_averbacao(id_romaneio, id_acesso_servico)
							VALUES (NEW.id_romaneio, vLinha.id);
						END IF;						
					END IF;
					
				END LOOP;
					
			END IF;		
			
			--Se houve cancelamento de cte
			IF COALESCE(OLD.cancelado,-1) <> COALESCE(NEW.cancelado,-1) AND COALESCE(NEW.cancelado,-1) = 1  THEN 
				UPDATE scr_romaneio_averbacao SET cancelado = 1 WHERE id_romaneio = NEW.id_romaneio;
			END IF;	

		EXCEPTION WHEN OTHERS THEN 
		
			RAISE NOTICE '% %', sqlstate, sqlerrm;
			RETURN NEW;
		END;			
	END IF;



	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
