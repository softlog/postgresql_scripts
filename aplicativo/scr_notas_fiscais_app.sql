
CREATE TABLE scr_notas_fiscais_app
(
	id serial,
	id_romaneio integer,
	id_nota_fiscal_imp integer,
	id_conhecimento_nota_fiscal integer,
	cpf character(11),	
	data_registro timestamp DEFAULT now(),	
	data_recebimento timestamp,
	enviado integer,
	CONSTRAINT scr_notas_fiscais_app_id_pk PRIMARY KEY (id)
);

CREATE TABLE scr_app_uuid
(
	id serial,
	id_fornecedor integer,
	id_usuario integer,
	uuid text,
	status integer DEFAULT 0,
	last_login timestamp,	
	CONSTRAINT scr_app_uuid_id_pk PRIMARY KEY (id)
);

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
		
		SELECT row_to_json(row, true) FROM (
			SELECT 'Usuario Inexistente'::text as mensagem
		) row
		INTO vRetorno;
		
		RETURN vRetorno;
		 
	END IF;
		
	IF v_uuid IS NULL THEN
		INSERT INTO scr_app_uuid (id_fornecedor, uuid)
		VALUES (v_id_usuario, v_uuid);
	END IF;


	SELECT 	f.id_fornecedor, app.uuid, '123456' as senha
	INTO 	v_id_usuario, v_uuid, v_senha
	FROM 	fornecedores f
		LEFT JOIN scr_app_uuid app
			ON app.uuid = p_uuid
				AND f.id_fornecedor = app.id_fornecedor
	WHERE
		f.cnpj_cpf = p_login;


	RETURN 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT * FROM frt_tipo_atividades