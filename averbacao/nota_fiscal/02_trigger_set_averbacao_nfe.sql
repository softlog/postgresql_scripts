-- Function: public.f_tgg_set_averbacao_manifesto()
--SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 10
-- DROP FUNCTION public.f_tgg_set_averbacao_manifesto();
/*

SELECT * FROM scr_doc_integracao WHERE chave_doc = '35211034274233010167550000011107101752948804'

UPDATE scr_notas_fiscais_imp SET id_nota_fiscal_imp = id_nota_fiscal_imp WHERE chave_nfe= '35211034274233010167550000011107101752948804';

SELECT chave_nfe, empresa_emitente FROM v_mgr_notas_fiscais WHERE empresa_emitente = '003' ORDER BY data_registro DESC LIMIT 1000

SELECT * FROM scr_nfe_averbacao

SELECT id_nota_fiscal_imp, empresa_emitente FROM scr_notas_fiscais_imp WHERE chave_nfe IN ('35211134274233010167550000011175871845295975','35211134274233010167550000011175881845327319')

UPDATE scr_notas_fiscais_imp SET id_nota_fiscal_imp = id_nota_fiscal_imp WHERE chave_nfe IN ('35211134274233010167550000011175871845295975','35211134274233010167550000011175881845327319')

SELECT * FROM msg_fila_averb_atm WHERE is_nfe = 1

SELECT * FROM scr_nfe_averbacao 

*/

CREATE OR REPLACE FUNCTION public.f_tgg_set_averbacao_nfe()
  RETURNS trigger AS
$BODY$
DECLARE	
	vIdAverbacao integer;
	vLinha 	empresa_acesso_servicos%ROWTYPE; 
	vAverba integer;
	vTemXml integer;
BEGIN		

	
	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp' THEN 

		RAISE NOTICE 'Disparando Trigger AVERBACAO';
	
		BEGIN 
			--Se houve emissao do manifesto
			IF 1=1 THEN 
			--Para cada apolice de seguro, cria um registro
				RAISE NOTICE 'empresa %', NEW.empresa_emitente;
				
				FOR vLinha IN 	SELECT empresa_acesso_servicos.* 
						FROM empresa_acesso_servicos 
							LEFT JOIN empresa ON empresa.id_empresa = empresa_acesso_servicos.id_empresa 
						WHERE 
							empresa_acesso_servicos.id_servico_integracao = 1 
							AND empresa.codigo_empresa = NEW.empresa_emitente							
						ORDER BY empresa_acesso_servicos.id LOOP
						
					vAverba = 1;

					RAISE NOTICE 'Dados de Averbacao % ',vLinha.descricao;
					
					IF vLinha.averba_nfe = 0 THEN 
						RAISE NOTICE 'Não Averba';
						vAverba = 0;
					END IF;


					IF vAverba = 1 THEN

						SELECT count(*)
						INTO vTemXml
						FROM scr_doc_integracao 
						WHERE chave_doc = NEW.chave_nfe AND tipo_doc = 2;

						IF vTemXml = 0 THEN 
							RETURN NEW;
						END IF;						
					
						SELECT 
							id 
						INTO 
							vIdAverbacao 
						FROM 
							scr_nfe_averbacao 
						WHERE 
							id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
							AND id_acesso_servico = vLinha.id;


						RAISE NOTICE 'Averbacao % %',vLinha.descricao, vIdAverbacao;

						IF vIdAverbacao IS NULL THEN					
							INSERT INTO public.scr_nfe_averbacao(id_nota_fiscal_imp, id_acesso_servico)
							VALUES (NEW.id_nota_fiscal_imp, vLinha.id);
						END IF;
						
					END IF;
				END LOOP;
					
			END IF;		

			/*

			--Se houve cancelamento de cte			
			IF COALESCE(OLD.status,0) <> COALESCE(NEW.status,0) AND COALESCE(NEW.status,0) = 4  THEN 
				UPDATE scr_nfe_averbacao SET cancelado = 1 WHERE id_ = NEW.id_manifesto;
			END IF;	
			
			*/

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

--SELECT numero_ctrc_filial FROM scr_conhecimento WHERE id_conhecimento = 8186
--SELECT * FROM scr_conhecimento_averbacao ORDER BY 1 DESC LIMIT 1

DROP TRIGGER tgg_set_averbacao_nfe  ON scr_notas_fiscais_imp;

CREATE TRIGGER tgg_set_averbacao_nfe 
  AFTER INSERT OR UPDATE
  ON public.scr_notas_fiscais_imp
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_set_averbacao_nfe();


ALTER TABLE scr_notas_fiscais_imp DISABLE TRIGGER tgg_set_averbacao_nfe;

  
