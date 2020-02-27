/*

SELECT * FROM scr_manifesto WHERE numero_manifesto = '0010010001880'
SELECT * FROM f_cria_ciot(2413,1)
--SELECT * FROM scr_ciot
TRUNCATE scr_ciot;

*/
CREATE OR REPLACE FUNCTION f_cria_ciot(p_id_documento integer, p_origem integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_id integer;        
        v_id_documento integer;        
        curCiot refcursor;

        
	v_id_proprietario integer;
	v_id_origem integer;
	v_op_municipal integer;
	v_data_ref date;
	v_frete_pago_terceiro integer;

	
BEGIN

	-- RAISE NOTICE 'Origem %', p_origem;

	IF p_origem = 1 THEN 

		--RAISE NOTICE 'Criando registro de CIOT';

		SELECT 
			id_ciot
		FROM 
			scr_ciot
		INTO 
			v_id
		WHERE 
			id_manifesto = p_id_documento;

	

		--RAISE NOTICE 'Id manifesto %', v_id_documento;
		
		IF v_id IS NULL THEN 


			SELECT 
				id_manifesto,
				id_proprietario,
				id_cidade_origem, 
				CASE WHEN id_cidade_origem = id_cidade_destino THEN 1 ELSE 0 END::integer as op_municipal,
				current_date,
				frete_pago_terceiro			
			INTO 
				v_id_documento,
				v_id_proprietario,
				v_id_origem,
				v_op_municipal,
				v_data_ref,
				v_frete_pago_terceiro
			FROM 
				scr_manifesto		
			WHERE 
				id_manifesto = p_id_documento;

			
			OPEN curCiot FOR
			INSERT INTO scr_ciot (
				data_abertura,
				id_manifesto				
			)				
			SELECT 
				data_viagem,
				p_id_documento
			FROM 
				scr_manifesto
			WHERE
				id_manifesto = p_id_documento
			RETURNING id_ciot;

			FETCH curCiot INTO v_id;

			--RAISE NOTICE 'Id Ciot %', v_id;
			
			CLOSE curCiot;

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
				automatico
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
				automatico_ as automatico
			FROM 	
				f_get_impostos_ciot(v_id_proprietario, v_id_origem, v_op_municipal, v_data_ref, v_frete_pago_terceiro, 0, null, 1);
				
		END IF;
		
		
	END IF;
	
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;