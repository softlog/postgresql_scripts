--DELETE FROM scr_app_uuid
--SELECT * FROM scr_app_uuid
--SELECT f_app_autentica_usuario as resultado FROM f_app_autentica_usuario('06167894671', 'dd5f0d06-11ca-4017-b148-dcbf5394fa25', '123456')
--SELECT * FROM scr_app_uuid WHERE id_fornecedor = 483
--uuid = '0a32e0c9-af1a-4495-9431-53dd0228167d'
--SELECT * FROM fornecedores WHERE id_fornecedor = 483
--SELECT * FROM f
--SELECT * FROM f_app_autentica_usuario('06167894671','123456','197b1234-b197-4d65-9424-d8c14ca00822')
CREATE OR REPLACE FUNCTION f_app_autentica_usuario(p_login text, p_senha text, p_uuid text)
  RETURNS json AS
$BODY$
DECLARE
        v_id_app integer;
        v_id_usuario integer;
        v_senha text;
        v_uuid text;
        vRetorno json;
        
BEGIN

	SELECT 	f.id_fornecedor, app.uuid, '123456' as senha
	INTO 	v_id_usuario, v_uuid, v_senha
	FROM 	fornecedores f
		LEFT JOIN scr_app_uuid app
			ON app.uuid = p_uuid
				AND f.id_fornecedor = app.id_fornecedor
	WHERE
		f.cnpj_cpf = p_login;


	IF v_id_usuario IS NULL THEN 
		RAISE NOTICE 'usuario inexistente';
		SELECT row_to_json(row, true) FROM (
			SELECT 'Usuario Inexistente'::text as retorno
		) row
		INTO vRetorno;
		
		RETURN NULL;
		 
	END IF;
	RAISE NOTICE 'UUID %', v_uuid	;
	IF v_uuid IS NULL THEN
		
		INSERT INTO scr_app_uuid (id_fornecedor, uuid)
		VALUES (v_id_usuario, p_uuid);
	END IF;


	IF (p_senha <> v_senha) THEN 
		SELECT row_to_json(row, true) FROM (
			SELECT 'Senha incorreta'::text as retorno
		) row
		INTO vRetorno;
		
		RETURN NULL;
	END IF;

	UPDATE scr_app_uuid SET last_login = now() WHERE 
		id_fornecedor = v_id_usuario
		AND uuid = p_uuid;
	
	SELECT row_to_json(row,true) as retorno INTO vRetorno FROM (
		SELECT 	
			f.id_fornecedor as id_usuario, 
			app.uuid, 			
			trim(f.nome_razao) as nome_usuario,
			trim(f.email) as email,
			trim(f.cnpj_cpf) as cnpj_cpf,
			trim(f.nome_razao) as login_name
		FROM 	fornecedores f
			LEFT JOIN scr_app_uuid app
				ON f.id_fornecedor = app.id_fornecedor
		WHERE
			f.cnpj_cpf = p_login AND app.uuid = p_uuid
		) row;


	RETURN vRetorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

