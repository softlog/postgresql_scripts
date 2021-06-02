-- View: public.v_clientes_re_combinado
--DROP VIEW public.v_clientes_re_combinado;
--DROP VIEW v_conf_cliente CASCADE;
--ALTER VIEW public.v_conf_cliente OWNER TO softlog_lfc;
--ALTER VIEW v_clientes_re_combinado OWNER TO softlog_lfc;


CREATE OR REPLACE VIEW public.v_conf_cliente AS 
WITH t1 AS (
SELECT  
	cliente_parametros.codigo_cliente,
        valor_parametro::integer as regime_especial_combinado	
FROM cliente_parametros
	WHERE cliente_parametros.id_tipo_parametro = 50
)
, t2 AS (
SELECT 
	cliente_parametros.codigo_cliente,       
        valor_parametro::integer as regime_especial_sem_minuta
FROM 
	cliente_parametros
WHERE 
	cliente_parametros.id_tipo_parametro = 130
)
SELECT 
	cliente.codigo_cliente,
	COALESCE(t1.regime_especial_combinado,0) as regime_especial_combinado,
	COALESCE(t2.regime_especial_sem_minuta,0) as regime_especial_sem_minuta
FROM
	cliente
	LEFT JOIN t1
		On t1.codigo_cliente = cliente.codigo_cliente
	LEFT JOIN t2
		ON t2.codigo_cliente = cliente.codigo_cliente;

 --ALTER VIEW public.v_conf_cliente OWNER TO softlog_transsafonso;

--SELECT * FROM cliente_tipo_parametros ORDER BY 1

--DROP VIEW v_clientes_re_combinado ;
CREATE OR REPLACE VIEW public.v_clientes_re_combinado AS 
SELECT cliente.cnpj_cpf,
    cliente.codigo_cliente,
    cliente.nome_cliente,
    origem.nome_cidade AS cidade,
    origem.uf AS estado,
    cliente.empresa_responsavel,
    cliente.tipo_data,
        CASE
            WHEN COALESCE(conf.regime_especial_sem_minuta,0) = 1 OR COALESCE(conf.regime_especial_combinado,0)  = 0 THEN 1
            ELSE 0
        END AS tabela_frete,
    conf.regime_especial_combinado,
    conf.regime_especial_sem_minuta
FROM 
	v_conf_cliente conf 
	LEFT JOIN cliente ON conf.codigo_cliente = cliente.codigo_cliente
	LEFT JOIN cidades origem ON origem.id_cidade::numeric = cliente.id_cidade
	;
 --ALTER VIEW public.v_clientes_re_combinado OWNER TO softlog_transsafonso;	
	
--SELECT * FROM v_clientes_re_combinado WHERE codigo_cliente = 8

--SELECT codigo_cliente FROM  cliente WHERE cnpj_cpf = '02709992000156'

--SELECT * FROM v_conf_cliente WHERE codigo_cliente IN(7)

--SELECT * FROM v_clientes_re_combinado WHERE codigo_cliente IN(724402)

--10398