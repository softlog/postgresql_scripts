--			SELECT f_importa_cfop_entrada_saida('6359', '2351','12278657000102', 0) as id
/*
SELECT com_compras_cfop_saida_entrada.id as codigo, com_compras_cfop_saida_entrada.id, com_compras_cfop_saida_entrada.fk_codigo_cfop_saida, com_compras_cfop_saida_entrada.fk_codigo_cfop_entrada, com_compras_cfop_saida_entrada.id_fornecedor, fornecedores.nome_razao, fornecedores.cnpj_cpf FROM com_compras_cfop_saida_entrada LEFT JOIN fornecedores ON fornecedores.id_fornecedor = com_compras_cfop_saida_entrada.id_fornecedor   WHERE com_compras_cfop_saida_entrada. =  ORDER BY fk_codigo_cfop_saida
SELECT * INTO com_compras_cfop_saida_entrada_temp FROM com_compras_cfop_saida_entrada ORDER BY 1
BEGIN;
DELETE FROM com_compras_cfop_saida_entrada WHERE id >= 422 AND id <= 760;
COMMIT;
ROLLBACK;
SELECT * FROM com_compras_cfop_saida_entrada WHERE id = 1052
SELECT * FROM com_compras_cfop_saida_entrada ORDER BY 1 DESC LIMIT 10

--DELETE FROM com_compras_cfop_saida_entrada WHERE id = 1105
*/
-- SELECT * FROM com_compras_cfop_saida_entrada ORDER BY 1

CREATE OR REPLACE FUNCTION f_importa_cfop_entrada_saida(p_cfop_saida character(4), p_cfop_entrada character(4), p_cnpj text, p_codigo integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_id_fornecedor integer;
        vCursor refcursor;
        vId integer;        
        
BEGIN	
	
	IF p_cnpj <> '' THEN 
		SELECT id_fornecedor
		INTO v_id_fornecedor
		FROM fornecedores 
		WHERE cnpj_cpf = p_cnpj;

		IF v_id_fornecedor IS NULL THEN 
			RETURN 0;
		END IF;
	END IF;	
	
	IF p_codigo = 0 THEN 
		OPEN vCursor FOR
		INSERT INTO com_compras_cfop_saida_entrada (
			fk_codigo_cfop_saida,
			fk_codigo_cfop_entrada,
			id_fornecedor
		)
		SELECT 
			CASE WHEN p_cfop_saida = '' THEN NULL ELSE p_cfop_saida END,
			CASE WHEN p_cfop_entrada = '' THEN NULL ELSE p_cfop_entrada END ,
			v_id_fornecedor
		WHERE
			NOT EXISTS (SELECT 1 FROM com_compras_cfop_saida_entrada t 
				   WHERE t.fk_codigo_cfop_saida = p_cfop_saida 
					AND t.fk_codigo_cfop_entrada = p_cfop_entrada 
					AND t.id_fornecedor = v_id_fornecedor)
		RETURNING id;


		FETCH vCursor INTO vId;

		CLOSE vCursor;
	ELSE
		
		UPDATE com_compras_cfop_saida_entrada SET 
			fk_codigo_cfop_saida = CASE WHEN p_cfop_saida = '' THEN NULL ELSE p_cfop_saida END,
			fk_codigo_cfop_entrada = CASE WHEN p_cfop_entrada = '' THEN NULL ELSE p_cfop_entrada END,
			id_fornecedor = v_id_fornecedor
		WHERE 
			id = p_codigo;

		vId = p_codigo;
			
	END IF;

        
	RETURN COALESCE(vId,0);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


  /*
	SELECT string_agg(id_compra::text, ',') FROM xml_nfe WHERE id_compra IS NOT NULL
	BEGIN;
	DELETE FROM xml_nfe;
	COMMIT;

	DELETE FROm com_compras WHERE id_compra IN (20798,20798,20792,20793,20794,20795,20796,20793,20794,20797,20799)

  */