DROP VIEW v_usuarios;
--SELECT * FROM v_usuarios
CREATE OR REPLACE VIEW v_usuarios AS 
SELECT 
	id_usuario, 
	1::integer as categoria,
	nome_usuario, 
	email, 	
	senha, 
	login_name, 
	codigo_filial, 
        codigo_empresa, 
        ativo, 
        exibir_dashboard,
        id_usuario as id,
        --(regexp_matches(nome_usuario,'([\w\s]+)\s[\w]+$'))[1] as first_name,	
        --(regexp_matches(nome_usuario,'\s(\w+)$'))[1] as last_name,	
        trim(nome_usuario) as first_name,
        ''::text as last_name,
        trim(login_name) as username,
        trim(senha) as password,
        ativo as active,
        null::timestamp as last_login,
        0::integer as login_count,
        0::integer as fail_login_count,
        null::timestamp as created_on,
        null::timestamp as changed_on,
        null::integer as created_by_fk,
        null::integer as changed_by_fk, 
        1::integer as acesso_raiz,
        null::character(14) as cnpj_cliente
FROM 
	usuarios
UNION 
SELECT 
	(id_webtrack_login * -1) as id_usuario, 
	2::integer as categoria,
	cnpj_cliente as nome_usuario,
	''::text as email,
	senha,
	trim(login_name) as login_name,
	'001' as codigo_filial,
	'001' as codigo_empresa,
	1::integer as ativo,
	0::integer as exibir_dashboard,
        (id_webtrack_login * -1) as id,
        cnpj_cliente as first_name,	
        ''::text as last_name,	
        trim(login_name) as username,
        trim(senha) as password,
        1::integer as active,
        null::timestamp as last_login,
        0::integer as login_count,
        0::integer as fail_login_count,
        null::timestamp as created_on,
        null::timestamp as changed_on,
        null::integer as created_by_fk,
        null::integer as changed_by_fk,
        acesso_raiz,
        cnpj_cliente
FROM 
	webtrack_login;


--SELECT * FROM webtrack_login ORDER BY login_name
--SELECT * FROM webtrack_login LIMIT 10

--SELECT * FROM v_usuarios ORDER BY login_name
