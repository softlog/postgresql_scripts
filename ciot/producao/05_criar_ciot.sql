/*
	SELECT f_cria_ciot as id_ciot FROM f_cria_ciot(3032, 1)

UPDATE scr_manifesto SET id_ciot = NULL WHERE id_manifesto = 3032
SELECT * FROM 
SELECT * FROM 2413
SELECT * FROM scr_manifesto WHERE numero_manifesto = '0010010001880'
SELECT * FROM f_cria_ciot(2413,1)
--SELECT * FROM scr_ciot
UPDATE scr_ciot SET viagem_padrao = 0
DELETE FROM scr_ciot;

*/
CREATE OR REPLACE FUNCTION f_cria_ciot(p_id_documento integer, p_origem integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_id integer;        
        v_id_ciot integer;
        v_id_documento integer;        
        curCiot refcursor;
        
	v_id_proprietario integer;
	v_id_origem integer;
	v_op_municipal integer;
	v_data_ref date;
	v_frete_pago_terceiro integer;

	v_placa_veiculo text;
	v_id_motorista integer;
	

	
BEGIN

	-- RAISE NOTICE 'Origem %', p_origem;

	IF p_origem = 1 THEN 


		SELECT 
			id_manifesto,
			id_proprietario,
			id_cidade_origem, 
			CASE WHEN id_cidade_origem = id_cidade_destino THEN 1 ELSE 0 END::integer as op_municipal,
			current_date,
			frete_pago_terceiro,
			id_motorista,
			id_ciot,
			placa_veiculo			
		INTO 
			v_id_documento,
			v_id_proprietario,
			v_id_origem,
			v_op_municipal,
			v_data_ref,
			v_frete_pago_terceiro,
			v_id_motorista,
			v_id_ciot,
			v_placa_veiculo
		FROM 
			scr_manifesto		
		WHERE 
			id_manifesto = p_id_documento;


		--Verifica se ja esta num ciot
		IF v_id_ciot IS NOT NULL THEN
			RETURN v_id_ciot;
		END IF;

		
		--RAISE NOTICE 'Criando registro de CIOT';

		--Verifica se tem CIOT em aberto.
		SELECT 
			id_ciot
		FROM 
			scr_ciot
		INTO 
			v_id
		WHERE 
			placa_veiculo = v_placa_veiculo 
			AND data_encerramento IS NULL
			AND data_cancelamento IS NULL;
			

		--RAISE NOTICE 'Id manifesto %', v_id_documento;
		
		IF v_id IS NULL THEN 

			
			OPEN curCiot FOR
			INSERT INTO scr_ciot (
				data_abertura,				
				id_manifesto,
				id_motorista,
				id_proprietario,
				placa_veiculo			
			)				
			SELECT 
				data_viagem,
				p_id_documento,
				v_id_motorista,
				v_id_proprietario,
				v_placa_veiculo				
			FROM 
				scr_manifesto
			WHERE
				id_manifesto = p_id_documento
			RETURNING id_ciot;


			FETCH curCiot INTO v_id;

			
			--RAISE NOTICE 'Id Ciot %', v_id;
			
			CLOSE curCiot;

			UPDATE scr_manifesto SET id_ciot = v_id WHERE id_manifesto = p_id_documento;

			INSERT INTO impostos_fornecedor (				
				id_fornecedor,
				tipo_imposto,
				mes_ref,
				ano_ref,
				data_ref,				
				valor_operacao,
				percentual_base_calculo,
				base_calculo,
				aliquota,
				valor_imposto,
				deducoes,
				id_ciot,
				qt_dependentes,
				automatico,
				id_manifesto
			)			
			SELECT 				
				id_fornecedor_ as fornecedor,
				tipo_imposto_ as tipo_imposto,
				mes_ref_ as mes_ref,
				ano_ref_ as ano_ref,
				data_ref_ as data_ref,
				valor_operacao_ as valor_operacao,
				percentual_base_calculo_ as percentual_base_calculo,
				base_calculo_ as base_calculo,
				aliquota_ as aliquota,
				valor_imposto_ as valor_imposto,
				deducoes_ as deducoes,
				v_id,
				qt_dependentes_ as qt_dependentes,
				automatico_ as automatico,
				p_id_documento
				
			FROM 	
				f_get_impostos_ciot(v_id_proprietario, v_id_origem, v_op_municipal, v_data_ref, v_frete_pago_terceiro, 0, null, 1);

		ELSE
			UPDATE scr_manifesto SET id_ciot = v_id WHERE id_manifesto = p_id_documento;

			INSERT INTO impostos_fornecedor (				
				id_fornecedor,
				tipo_imposto,
				mes_ref,
				ano_ref,
				data_ref,				
				valor_operacao,
				percentual_base_calculo,
				base_calculo,
				aliquota,
				valor_imposto,
				deducoes,
				id_ciot,
				qt_dependentes,
				automatico,
				id_manifesto
			)			
			SELECT 				
				id_fornecedor_ as fornecedor,
				tipo_imposto_ as tipo_imposto,
				mes_ref_ as mes_ref,
				ano_ref_ as ano_ref,
				data_ref_ as data_ref,
				valor_operacao_ as valor_operacao,
				percentual_base_calculo_ as percentual_base_calculo,
				base_calculo_ as base_calculo,
				aliquota_ as aliquota,
				valor_imposto_ as valor_imposto,
				deducoes_ as deducoes,
				v_id,
				qt_dependentes_ as qt_dependentes,
				automatico_ as automatico,
				p_id_documento
				
			FROM 	
				f_get_impostos_ciot(v_id_proprietario, v_id_origem, v_op_municipal, v_data_ref, v_frete_pago_terceiro, 0, null, 1);

			
			INSERT INTO fila_documentos_integracoes (
					tipo_integracao,
					tipo_documento,
					id_ciot,
					id_manifesto
				) VALUES (
					6,
					10,
					v_id,
					p_id_documento
				);
				
				
		END IF;
		
		
	END IF;
	
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;