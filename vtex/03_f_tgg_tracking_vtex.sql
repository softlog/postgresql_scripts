CREATE OR REPLACE FUNCTION f_tgg_tracking_vtex()
  RETURNS trigger AS
$BODY$
DECLARE
	integra_vtex integer;
	v_numero_pedido text;
	v_id_fila_pedido integer;	
	v_id_cliente integer;
	v_empresa text;
	
BEGIN

	
	--SELECT * FROM v_mgr_notas_fiscais WHERE numero_pedido_nf = '104170103948701'
	--SELECT * FROM v_mgr_notas_fiscais WHERE chave_nfe = '35200605889907000177550020002000101619413660'
	--SELECT * FROM scr_conhecimento_ocorrencias_nf

	IF NEW.id_ocorrencia = 0 THEN 
		RETURN NEW;
	END IF;
	
	IF TG_TABLE_NAME = 'scr_conhecimento_ocorrencias_nf' THEN 

		RETURN NEW;
		
		SELECT remetente_id
		INTO v_id_cliente
		FROM scr_conhecimento
		WHERE id_conhecimento = NEW.id_conhecimento;

		--UPDATE scr_conhecimento_ocorrencias_nf SET id_conhecimento = id_conhecimento WHERE id_conhecimento_ocorrencia_nf = 3
		--SELECT * FROM fila_ocorrencias_pedido_vtex
		

		SELECT count(*)
		INTO integra_vtex
		FROM cliente_parametros
		WHERE codigo_cliente = v_id_cliente;


		

		--RAISE NOTICE 'Integra Vtex %', integra_vtex;
		IF integra_vtex = 1 THEN 
		
			INSERT INTO fila_ocorrencias_pedido_vtex (
				id_fila_pedido, 			
				id_conhecimento_notas_fiscais,
				id_nota_fiscal_imp,
				id_ocorrencia,
				id_ocorrencia_nf
			) 
			SELECT 
				fila.id,
				NEW.id_conhecimento_notas_fiscais,
				nf.id_nota_fiscal_imp,
				NEW.id_ocorrencia,
				NEW.id_conhecimento_ocorrencia_nf
			FROM 
				scr_conhecimento_notas_fiscais nf
				LEFT JOIN fila_pedidos_vtex fila
					ON fila.numero_pedido = nf.numero_pedido_nf
			WHERE
				nf.id_conhecimento_notas_fiscais = NEW.id_conhecimento_notas_fiscais;
				
		END IF;	
	END IF;

	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp_ocorrencias' THEN 

		IF NEW.id_ocorrencia IN (301,302,303) THEN 
			RETURN NEW;
		END IF;
	
		SELECT remetente_id
		INTO v_id_cliente
		FROM v_mgr_notas_fiscais
		WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

		--UPDATE scr_conhecimento_ocorrencias_nf SET id_conhecimento = id_conhecimento WHERE id_conhecimento_ocorrencia_nf = 3
		--SELECT * FROM fila_ocorrencias_pedido_vtex
		

		SELECT count(*)
		INTO integra_vtex
		FROM cliente_parametros
		WHERE codigo_cliente = v_id_cliente
		AND id_tipo_parametro = 31;
	

		
		--RAISE NOTICE 'Integra Vtex %', integra_vtex;
		IF integra_vtex = 1 THEN 		
			INSERT INTO fila_ocorrencias_pedido_vtex (
				id_fila_pedido, 			
				id_conhecimento_notas_fiscais,
				id_nota_fiscal_imp,
				id_ocorrencia,
				id_ocorrencia_nf,
				id_cidade,
				operacao_por_nota
			) 
			SELECT 
				fila.id,
				NULL,
				NEW.id_nota_fiscal_imp,
				NEW.id_ocorrencia,
				NEW.id_ocorrencia_nf,
				CASE WHEN NEW.id_ocorrencia = 300 THEN nf.calculado_de_id_cidade ELSE nf.calculado_ate_id_cidade END,
				1
			FROM 
				scr_notas_fiscais_imp nf
				LEFT JOIN fila_pedidos_vtex fila
					ON fila.numero_pedido = nf.numero_pedido_nf				
				
			WHERE
				nf.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;				
		END IF;	
	END IF;

         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
