/*

SELECT * FROM scr_romaneios ORDER BY 1 DESC;
SELECT * FROM scr_romaneio_nf WHERE id_nota_fiscal_imp = 19052
SELECT id_romaneio, id_nota_fiscal_imp FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::integer = 1762469
UPDATE scr_romaneios SET emitido = 0 WHERE id_romaneio = 78;

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 19052 ORDER BY data_registro;
SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp = 19052;
UPDATE scr_romaneios SET emitido = 1 WHERE id_romaneio = 78;


				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp,
						fila.id
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
						LEFT JOIN fila_pedidos_vtex fila
							ON fila.numero_pedido = scr_notas_fiscais_imp.numero_pedido_nf

					WHERE 
						rnf.id_romaneio = 444
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)	
						AND scr_notas_fiscais_imp.id_nota_fiscal_imp = 19052					
				)
				SELECT 
					t.id,
					t.id_nota_fiscal_imp,
					NEW.id_romaneio,					
					NULL,
					303,
					1,
					NEW.id_origem
				FROM 
					t;
						

*/

CREATE OR REPLACE FUNCTION f_tgg_eventos_sistema()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN

	

	

	IF TG_TABLE_NAME = 'scr_romaneios' THEN 		

		IF TG_OP = 'INSERT' THEN 
			RETURN NEW;
		END IF;

		IF NEW.emitido = 1 AND OLD.emitido = 0 THEN 
		
			IF NEW.tipo_destino = 'T' THEN 
				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)
						
				)
				UPDATE scr_notas_fiscais_imp SET 
					id_ocorrencia = 300,
					data_ocorrencia = now()
				FROM 
					t
				WHERE 
					EXISTS (SELECT 1 FROM t WHERE t.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp);		


				
				INSERT INTO fila_ocorrencias_pedido_vtex (
					id_fila_pedido, 						
					id_nota_fiscal_imp,
					id_romaneio,
					id_manifesto,
					id_ocorrencia,					
					operacao_por_nota,
					id_cidade
				) 
				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp,
						fila.id
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
						LEFT JOIN fila_pedidos_vtex fila
							ON fila.numero_pedido = scr_notas_fiscais_imp.numero_pedido_nf
					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)						
				)
				SELECT 
					t.id,
					t.id_nota_fiscal_imp,
					NEW.id_romaneio,					
					NULL,
					300,
					1,
					NEW.id_origem
				FROM 
					t;
					
			END IF;

			IF NEW.tipo_destino = 'D' THEN 

				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)
						
				)
				UPDATE scr_notas_fiscais_imp SET 
					id_ocorrencia = 303,
					data_ocorrencia = now()
				FROM 
					t
				WHERE 
					EXISTS (SELECT 1 FROM t WHERE t.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp);	


				INSERT INTO fila_ocorrencias_pedido_vtex (
					id_fila_pedido, 						
					id_nota_fiscal_imp,
					id_romaneio,
					id_manifesto,
					id_ocorrencia,					
					operacao_por_nota,
					id_cidade
				) 
				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp,
						fila.id
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
						LEFT JOIN fila_pedidos_vtex fila
							ON fila.numero_pedido = scr_notas_fiscais_imp.numero_pedido_nf

					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)						
				)
				SELECT 
					t.id,
					t.id_nota_fiscal_imp,
					NEW.id_romaneio,					
					NULL,
					303,
					1,
					NEW.id_origem
				FROM 
					t;
									
			END IF;	



					
		END IF;

		
		IF NEW.baixa = 0 AND OLD.baixa = 1 THEN 	

			IF NEW.tipo_destino = 'T' THEN 
				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)
												
				)
				UPDATE scr_notas_fiscais_imp SET 
					id_ocorrencia = 301,
					data_ocorrencia = now()
				FROM 
					t
				WHERE 
					EXISTS (SELECT 1 FROM t WHERE t.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp);



				INSERT INTO fila_ocorrencias_pedido_vtex (
					id_fila_pedido, 						
					id_nota_fiscal_imp,
					id_romaneio,
					id_manifesto,
					id_ocorrencia,					
					operacao_por_nota,
					id_cidade
				) 
				WITH t AS (
					SELECT 
						rnf.id_nota_fiscal_imp,
						fila.id
					FROM
						scr_romaneio_nf rnf
						LEFT JOIN scr_notas_fiscais_imp
							ON scr_notas_fiscais_imp.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
						LEFT JOIN fila_pedidos_vtex fila
							ON fila.numero_pedido = scr_notas_fiscais_imp.numero_pedido_nf
						
					WHERE 
						rnf.id_romaneio = NEW.id_romaneio
						AND scr_notas_fiscais_imp.id_ocorrencia NOT IN (1,2)						
				)
				SELECT 
					t.id,
					t.id_nota_fiscal_imp,
					NEW.id_romaneio,					
					NULL,
					301,
					1,
					NEW.id_origem
				FROM 
					t;
			END IF;			
		END IF;							
	END IF;

	
	IF TG_TABLE_NAME = 'scr_manifesto' THEN 

		IF TG_OP = 'INSERT' THEN 
			RETURN NEW;
		END IF;		

		IF NEW.status = 2 AND OLD.status <> 2 THEN 		
			
			WITH t AS (
			
				SELECT 
					nf.id_nota_fiscal_imp
				FROM
					scr_conhecimento c
					LEFT JOIN scr_conhecimento_notas_fiscais nf
						ON nf.id_conhecimento = c.id_conhecimento
					LEFT JOIN scr_notas_fiscais_imp nf2
						ON nf2.id_nota_fiscal_imp = nf.id_nota_fiscal_imp						
				WHERE 
					id_manifesto = NEW.id_manifesto
					AND nf2.id_ocorrencia NOT IN (1,2)
					
			)
			UPDATE scr_notas_fiscais_imp SET 
				id_ocorrencia = 300,
				data_ocorrencia = now()
			FROM 
				t
			WHERE 
				EXISTS (SELECT 1 FROM t WHERE t.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp);		

			
			INSERT INTO fila_ocorrencias_pedido_vtex (
				id_fila_pedido, 						
				id_nota_fiscal_imp,
				id_romaneio,
				id_manifesto,
				id_ocorrencia,					
				operacao_por_nota,
				id_cidade
			) 
			WITH t AS (
				SELECT 
					nf2.id_nota_fiscal_imp,
					fila.id
				FROM
					scr_conhecimento c
					LEFT JOIN scr_conhecimento_notas_fiscais nf
						ON nf.id_conhecimento = c.id_conhecimento
					LEFT JOIN scr_notas_fiscais_imp nf2
						ON nf2.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
					LEFT JOIN fila_pedidos_vtex fila
						ON fila.numero_pedido = nf2.numero_pedido_nf
				WHERE 
					c.id_manifesto = NEW.id_manifesto
					AND nf2.id_ocorrencia NOT IN (1,2)
			)
			SELECT 
				t.id,
				t.id_nota_fiscal_imp,
				NULL,					
				NEW.id_manifesto,
				300,
				1,
				NEW.id_cidade_origem
			FROM 
				t;	

			
				
		END IF;

		
		IF NEW.status = 3 AND OLD.status <> 3  THEN 	

			WITH t AS (
			
				SELECT 
					nf.id_nota_fiscal_imp
				FROM
					scr_conhecimento c
					LEFT JOIN scr_conhecimento_notas_fiscais nf
						ON nf.id_conhecimento = c.id_conhecimento
					LEFT JOIN scr_notas_fiscais_imp nf2
						ON nf2.id_nota_fiscal_imp = nf.id_nota_fiscal_imp						
				WHERE 
					id_manifesto = NEW.id_manifesto
					AND nf2.id_ocorrencia NOT IN (1,2)
					
			)
			UPDATE scr_notas_fiscais_imp SET 
				id_ocorrencia = 301,
				data_ocorrencia = now()
			FROM 
				t
			WHERE 
				EXISTS (SELECT 1 FROM t WHERE t.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp);		


			INSERT INTO fila_ocorrencias_pedido_vtex (
				id_fila_pedido, 						
				id_nota_fiscal_imp,
				id_romaneio,
				id_manifesto,
				id_ocorrencia,					
				operacao_por_nota,
				id_cidade
			) 
			WITH t AS (
				SELECT 
					nf2.id_nota_fiscal_imp,
					fila.id
				FROM
					scr_conhecimento c
					LEFT JOIN scr_conhecimento_notas_fiscais nf
						ON nf.id_conhecimento = c.id_conhecimento
					LEFT JOIN scr_notas_fiscais_imp nf2
						ON nf2.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
					LEFT JOIN fila_pedidos_vtex fila
						ON fila.numero_pedido = nf2.numero_pedido_nf
				WHERE 
					c.id_manifesto = NEW.id_manifesto
					AND nf2.id_ocorrencia NOT IN (1,2)
					
			)
			SELECT 
				t.id,
				t.id_nota_fiscal_imp,
				NULL,					
				NEW.id_manifesto,
				301,
				1,
				NEW.id_cidade_origem
			FROM 
				t;		

		END IF;

	END IF;	
         
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;


--SELECT * FROM scr_ocorrencia_edi ORDER BY 1 DESC 
--DELETE FROM scr_ocorrencia_edi WHERE codigo_edi = 302

/*
SELECT * FROm fila_ocorrencias_pedido_vtex 

DELETE FROM fila_ocorrencias_pedido_vtex WHERE data_registro::date < current_date

SELECT string_agg(id_ocorrencia_nf::text,',') FROM scr_notas_fiscais_imp_ocorrencias WHERE id_ocorrencia = 302 ORDER BY 1 DESC LIMIT 100

SELECT * FROM scr_notas_fiscais_imp_ocorrencias ORDER BY 1 DESC LIMIT 100;

UPDATE scr_notas_fiscais_imp_ocorrencias SET id_ocorrencia_nf = id_ocorrencia_nf WHERE id_ocorrencia_nf IN (11414,11416,11418,11420,11422,11424,11426,11428,11430,11432,11434,11436,11438,11440,11442,11444,11446,11448,11450,11452,11454,11456,11458,11460,11462,11464,11466,11468,11470)

SELECT * FROM msg_subscricao

SELECT * FROM msg_fila_envio WHERE id_notificacao = 4

INSERT INTO scr_ocorrencia_edi (codigo_edi, ocorrencia, pendencia, gera_acerto, gera_notificacao, publica)
VALUES (302, 'Pedidos com a transportadora', 0, 0, 1,1);

- Pedidos com a transportadora - Quando recebe o documento
- Pedido em transporte - Está em transferência Romaneio/Manifesto
- Pedido em rota final de entrega - Está no romaneio de distribuição.
- Pedido entregue 
- Pedido não pode ser entregue (motivo)

*/