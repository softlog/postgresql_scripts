CREATE OR REPLACE FUNCTION f_insere_ocorrencia_entrega(ocorrencias json)
  RETURNS integer AS
$BODY$
DECLARE
	v_id integer;
	v_id_ocorrencia integer;   
	v_data_ocorrencia text;
	v_hora_ocorrencia text;
	v_data_hora_ocorrencia timestamp;
	v_remetente text;
	v_chave_nfe character(44);
	v_numero_nota_fiscal character(9);
	v_serie_nota_fiscal character(3);

	vCursor refcursor;
	
BEGIN


	
	v_id_ocorrencia 	= COALESCE(((ocorrencias->>'id_ocorrencia')::text)::integer,0);
	v_data_ocorrencia	= ocorrencias->>'data_ocorrencia';
	v_hora_ocorrencia	= ocorrencias->>'hora_ocorrencia';
	v_data_hora_ocorrencia  = (v_data_ocorrencia || ' ' || v_hora_ocorrencia)::timestamp; 
	v_chave_nfe 		= ocorrencias->>'chave_nfe';
	v_remetente		= substr(v_chave_nfe,7,14);
	v_numero_nota_fiscal	= substr(v_chave_nfe,26,9);
	v_serie_nota_fiscal	= substr(v_chave_nfe,23,3);


	IF v_chave_nfe IS NULL THEN 
		RETURN 0;
	END IF;
	
	OPEN vCursor FOR
	INSERT INTO edi_ocorrencias_entrega (
		servico_integracao,
		numero_nfe,
		serie_nfe,
		cnpj_emitente,
		chave_nfe,
		numero_ocorrencia,
		data_ocorrencia
		
	) VALUES (
		30,
		v_numero_nota_fiscal,
		v_serie_nota_fiscal,
		v_remetente,
		v_chave_nfe,
		v_id_ocorrencia,
		v_data_hora_ocorrencia
	) RETURNING id;

	FETCH vCursor INTO v_id;

	CLOSE vCursor;
	        
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


