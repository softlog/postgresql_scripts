

CREATE OR REPLACE FUNCTION f_tgg_frt_dados_aplicativo()
  RETURNS trigger AS
$BODY$
DECLARE
	i integer;
	k integer;
	t integer;
	t1 integer;
	v_checklists json;
	v_checklist json;
	v_inspecoes json;
	v_inspecao json;	
	v_dados json;
	v_id_operacao_diaria integer;
	v_id_inspecao integer;
	vCursor refcursor;
	vSequencia text;
	vCodigoSequencia integer;
	vNumeroOperacaoDiaria text;
	
BEGIN
		v_dados = NEW.dados_aplicativo;

		v_checklists = (v_dados->>'checklists')::json;

		t = json_array_length(v_checklists)-1;
		
		FOR i IN 0..t LOOP	
			--RAISE NOTICE 'Participante %', v_participantes::text;
			v_checklist = (v_checklists->>i)::json;

			vSequencia = 'frt_operacao_diaria_' || 
				(v_checklist->>'codigo_empresa') || 
				'_' ||
				(v_checklist->>'codigo_filial');

			vCodigoSequencia = proximo_numero_sequencia(vSequencia);

			vNumeroOperacaoDiaria = (v_checklist->>'codigo_empresa') ||
					(v_checklist->>'codigo_filial') ||
					lpad(vCodigoSequencia::text,7,'0');

					
					
			
			
			OPEN vCursor FOR
			INSERT INTO frt_operacao_diaria (
				data_inicial, 
				data_final, 
				codigo_empresa, 
				codigo_filial, 
				numero_operacao_diaria, 
				placa_veiculo,
				autorizado
			) VALUES (
				(v_checklist->>'data_inicial')::timestamp,
				(v_checklist->>'data_final')::timestamp,
				(v_checklist->>'codigo_empresa'),
				(v_checklist->>'codigo_filial'),
				vNumeroOperacaoDiaria,
				(v_checklist->>'placa_veiculo')	,
				(v_checklist->>'autorizado')::boolean::integer		
			) RETURNING id_operacao_diaria;

			FETCH vCursor INTO v_id_operacao_diaria;

			CLOSE vCursor;

			--SELECT * FROM frt_operacao_diaria

			NEW.id_operacao_diaria = v_id_operacao_diaria;
			
			v_inspecoes  = (v_checklist->>'inspecoes')::json;
			t1 = json_array_length(v_inspecoes)-1;

			FOR k IN 0..t1 LOOP
				v_inspecao = (v_inspecoes->>k);

				IF  ((v_inspecao)->>'id_check')::text::integer = -1 THEN 
					CONTINUE;
				END IF;
				INSERT INTO frt_operacao_diaria_inspecao (
					id_operacao_diaria, 
					id_check, 
					valor_positivo, 
					valor_negativo					
				) VALUES (
					v_id_operacao_diaria,
					((v_inspecao)->>'id_check')::text::integer,
					((v_inspecao)->>'valor_positivo')::boolean::integer,
					((v_inspecao)->>'valor_negativo')::boolean::integer
				);

			END LOOP;
			 
		END LOOP;

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;