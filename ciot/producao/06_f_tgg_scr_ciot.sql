
--UPDATE scr_ciot SET id_ciot = id_ciot WHERE id_ciot = 3;

CREATE OR REPLACE FUNCTION f_tgg_scr_ciot()
  RETURNS trigger AS
$BODY$
DECLARE
	v_integra_proprietario integer;
	v_integra_motorista integer;
	vExiste integer;
	
BEGIN




	IF TG_TABLE_NAME = 'scr_ciot' THEN 

		IF NEW.gerar_viagem_efrete = 1  THEN 
		
			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_ciot = NEW.id_ciot
				AND id_manifesto = NEW.id_manifesto
				AND tipo_integracao = 6
				AND tipo_documento = 9;


			IF vExiste = 0 THEN 
				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_ciot,
					id_manifesto					
				) VALUES (
					6,
					9,
					NEW.id_ciot,
					NEW.id_manifesto
				);
			END IF;
		END IF;


		IF NEW.cancelar_viagem_efrete = 1  THEN 
		
			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_ciot = NEW.id_ciot				
				AND tipo_integracao = 6
				AND tipo_documento = 15;


			IF vExiste = 0 THEN
			 
				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_ciot
				) VALUES (
					6,
					15,
					NEW.id_ciot
				);
				
			END IF;
			
		END IF;

		IF NEW.encerrar_viagem_efrete = 1  THEN 
		
			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_ciot = NEW.id_ciot				
				AND tipo_integracao = 6
				AND tipo_documento = 16;


			IF vExiste = 0 THEN
			 
				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_ciot
				) VALUES (
					6,
					16,
					NEW.id_ciot
				);				
			END IF;			
		END IF;		
	END IF;


	IF TG_TABLE_NAME = 'scr_ciot_pagamentos' THEN
	 
		IF NEW.lancar_efrete = 1  THEN 
		
			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_ciot = NEW.id_ciot
				AND id_pagamento = NEW.id_ciot_pagamento
				AND tipo_integracao = 6
				AND tipo_documento = 11;


			IF vExiste = 0 THEN 
				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_pagamento					
				) VALUES (
					6,
					11,
					NEW.id_ciot_pagamento
				);
			END IF;
		END IF;
	END IF;

	IF TG_TABLE_NAME = 'fornecedores' THEN 


		SELECT COALESCE(valor_parametro::integer,0) 
		INTO v_integra_motorista 
		FROM fornecedor_parametros 
		WHERE id_tipo_parametro = 11 AND id_fornecedor = NEW.id_fornecedor ;

		v_integra_motorista = COALESCE(v_integra_motorista,0);

		RAISE NOTICE 'Integra Motorista %', v_integra_motorista;
		IF v_integra_motorista = 1 AND NEW.efrete_motorista = 0 THEN 

			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_fornecedor = NEW.id_fornecedor
				AND tipo_integracao = 6
				AND tipo_documento = 7;

			RAISE NOTICE 'Motorista já enfileirado %', vExiste;

			IF vExiste = 0 THEN 
				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_fornecedor
				) VALUES (
					6,
					7,
					NEW.id_fornecedor
				);
			END IF;
		END IF;	


		SELECT COALESCE(valor_parametro::integer,0) 
		INTO v_integra_proprietario 
		FROM fornecedor_parametros 
		WHERE id_tipo_parametro = 10
			AND id_fornecedor = NEW.id_fornecedor;

		v_integra_proprietario = COALESCE(v_integra_proprietario,0);

		IF v_integra_proprietario = 1 AND NEW.efrete_proprietario = 0 THEN 

					SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE id_fornecedor = NEW.id_fornecedor
				AND tipo_integracao = 6
				AND tipo_documento = 6;

			IF vExiste = 0 THEN 

				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_fornecedor
				) VALUES (
					6,
					6,
					NEW.id_fornecedor
				);
			END IF;
		END IF;	

	END IF;

	IF TG_TABLE_NAME = 'veiculos' THEN 
		IF NEW.efrete_veiculo = 0 AND NEW.integra_efrete = 1 THEN 

			SELECT count(*) 
			INTO vExiste
			FROM fila_documentos_integracoes
			WHERE placa_veiculo = NEW.placa_veiculo
				AND tipo_integracao = 6
				AND tipo_documento = 8;

			IF vExiste = 0 THEN 

				INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					placa_veiculo
				) VALUES (
					6,
					8,
					NEW.placa_veiculo
				);
			END IF;
		END IF;
	END IF;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

/*
SELECT * FROM fornecedor_parametros WHERE id_tipo_parametro IN (10,11)




UPDATE fornecedores SET celular_ciot = '62996507825' WHERE id_fornecedor IN (1211,1211,2080)

SELECT * FROM fila_documentos_integracoes;

SELECT * FROM fila_documentos_integracoes_retorno;

*/ 