-- Function: public.f_tgg_set_averbacao_manifesto()

-- DROP FUNCTION public.f_tgg_set_averbacao_manifesto();

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao_manifesto()
  RETURNS trigger AS
$BODY$
DECLARE	
	vIdAverbacao integer;
	vLinha 	empresa_acesso_servicos%ROWTYPE; 
	vAverba integer;
BEGIN		

	
	IF TG_TABLE_NAME = 'scr_manifesto' AND TG_OP = 'UPDATE' THEN 

		--RAISE NOTICE 'Disparando Trigger';
	
		BEGIN 
			--Se houve emissao do manifesto
			IF COALESCE(OLD.cstat,'') <> COALESCE(NEW.cstat,'') AND COALESCE(NEW.cstat,'') = '100' 
			THEN 
			--Para cada apolice de seguro, cria um registro
			
				FOR vLinha IN 	SELECT empresa_acesso_servicos.* 
						FROM empresa_acesso_servicos 
							LEFT JOIN empresa ON empresa.id_empresa = empresa_acesso_servicos.id_empresa 
						WHERE 
							empresa_acesso_servicos.id_servico_integracao = 1 
							AND empresa.codigo_empresa = NEW.empresa_manifesto							
						ORDER BY empresa_acesso_servicos.id LOOP
					vAverba = 1;

					RAISE NOTICE 'Dados de Averbacao % ',vLinha.descricao;
					
					IF vLinha.averba_manifesto = 0 THEN 
						RAISE NOTICE 'Não Averba';
						vAverba = 0;
					END IF;


					IF vAverba = 1 THEN
						SELECT 
							id 
						INTO 
							vIdAverbacao 
						FROM 
							scr_manifesto_averbacao 
						WHERE 
							id_manifesto = NEW.id_manifesto
							AND id_acesso_servico = vLinha.id;


						RAISE NOTICE 'Averbacao % %',vLinha.descricao, vIdAverbacao;

						IF vIdAverbacao IS NULL THEN					
							INSERT INTO public.scr_manifesto_averbacao(id_manifesto, id_acesso_servico)
							VALUES (NEW.id_manifesto, vLinha.id);
						END IF;
					END IF;
				END LOOP;
					
			END IF;		

			
			--Se houve cancelamento de cte			
			IF COALESCE(OLD.status,0) <> COALESCE(NEW.status,0) AND COALESCE(NEW.status,0) = 4  THEN 
				UPDATE scr_manifesto_averbacao SET cancelado = 1 WHERE id_manifesto = NEW.id_manifesto;
			END IF;	

			--Se houve encerramento
			IF OLD.data_chegada IS NULL AND NEW.data_chegada IS NOT NULL  THEN 
				UPDATE scr_manifesto_averbacao SET encerrado = 1, data_registro_encerramento = NOW() WHERE id_manifesto = NEW.id_manifesto;
			END IF;	
		EXCEPTION WHEN OTHERS THEN 
			RAISE NOTICE 'Ocorreu um erro ao tentar enfileira averbacao';
			RETURN NEW;
		END;			
	END IF;



	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

