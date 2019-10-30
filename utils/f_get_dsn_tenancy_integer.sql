CREATE OR REPLACE FUNCTION f_get_dsn_tenancy(p_id_bd integer)
  RETURNS text AS
$BODY$
DECLARE
       v_dsn text; 
BEGIN

		
        SELECT 
		(
		'dbname=' || trim(banco_dados) || ' '
		'user='   || trim(usuario)     || ' '
		'port='   || trim(port)        || ' ' 
		'password='|| trim(senha)    || ' '
		'host='    || trim(host)        
		)::text 
	INTO 
		v_dsn
        FROM
		string_conexoes
	WHERE 
		CASE WHEN p_id_bd >= 10000 THEN id_string_conexao = (p_id_bd/1000) ELSE id_string_conexao = id_string_conexao END;

	RETURN v_dsn;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT f_get_dsn_tenancy(53001)

--SELECT * FROM scr_nf_protocolo LIMIT 100