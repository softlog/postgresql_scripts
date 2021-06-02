/*

SELECT * FROM com_compras_itens WHERE placa_veiculo IS NOT NULL;

SELECT fp_set_session('pst_usuario','1');

SELECT f_gera_os_por_compras_itens(com_compras.id_compra) FROM com_compras LEFT JOIN com_compras_itens ON com_compras.id_compra = com_compras_itens.id_compra WHERE com_compras_itens.id_compra = 262;

SELECT * FROM frt_os
SELECT * FROM com_compras_itens WHERE id_compra = 262;

SELECT * FROM frt_os ORDER BY 1 DESC LIMIT 10

DELETE FROM frt_os WHERE os_abertura = '2021-02-02 16:01:18.542978'

SELECT 	
	array_agg(id_compra_item), 
	array_length(array_agg(id_compra_item),1)
FROM 	
	com_compras
	LEFT JOIN com_compras_itens
		ON com_compras_itens.id_compra = com_compras.id_compra
WHERE 
	com_compras_itens.id_os IS NULL
	AND com_compras_itens.placa_veiculo IS NOT NULL 
	AND com_compras.id_compra = 262;

SELECT * FROM scf_contas_pagar LIMIT 1
	

*/


CREATE OR REPLACE FUNCTION public.f_gera_os_por_compras_itens(p_id_compra integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_usuario integer;
	v_id_os integer; 
	v_retorno integer;
	v_itens_os text[];
	v_id_itens integer[];
	v_id_itens_str text;
	v_itens text;
	t integer;
	i integer;
	v_id_item integer;
	v_cursor refcursor;

BEGIN

	v_usuario = fp_get_session('pst_usuario');


	WITH t AS (
		SELECT 
			string_agg(id_compra_item::text,',') as itens
		FROM 
			com_compras_itens
		WHERE
			com_compras_itens.id_compra = p_id_compra
			AND com_compras_itens.id_os IS NULL
		GROUP BY 
			com_compras_itens.placa_veiculo
	) 
	SELECT array_agg(t.itens) INTO v_itens_os FROM t;

		

	--v_itens_os = string_to_array(v_id_itens_str,',');

--      SELECT array_agg(t.itens)
-- 	INTO 	v_id_itens
-- 	FROM 	com_compras
-- 		LEFT JOIN com_compras_itens
-- 			ON com_compras_itens.id_compra = com_compras.id_compra
-- 	WHERE 
-- 		com_compras_itens.id_os IS NULL
-- 		AND com_compras_itens.placa_veiculo IS NOT NULL 
-- 		AND com_compras.id_compra = p_id_compra;


	--RAISE NOTICE 'Compra %', p_id_compra;
	t = COALESCE(array_length(v_itens_os, 1),0);
	RAISE NOTICE 'Qt Itens %', t;
	IF t = 0 THEN 
		RETURN 0;
	END IF;	
	
	FOR i IN 1..t LOOP
		
		v_itens = v_itens_os[i];
		
		RAISE NOTICE 'Item %', v_itens;
		
		OPEN v_cursor FOR
		INSERT INTO frt_os
		(
			os_empresa,
			os_filial_resp,
			os_filial_solic,
			os_filial_pg,
			os_nr,
			os_placa,
			os_status,
			os_tp,
			os_aber_tp,
			os_abertura,
			os_tp_oficina,
			id_compra,
			os_id_cliente,
			os_nr_nf,
			os_vlr_pecas,
			os_vlr_servs,
			os_vlr_total,
			os_nr_nf_emissao,
			os_aprov_usu,
			os_aprovacao,
			os_obs 
		) 
		WITH t AS (
			SELECT unnest(string_to_array(v_itens,','))::integer as id_item			
		)
		SELECT  
			codigo_empresa, 
			codigo_filial, 
			codigo_filial,
			codigo_filial, 
			(codigo_empresa||codigo_filial||LPAD(cast(proximo_numero_sequencia('frt_os_'||codigo_empresa||'_'||codigo_filial) as varchar),7,'0'))::character(13) as os_nr,
			com_compras_itens.placa_veiculo,
			3::integer AS os_status,
			2::INTEGER AS os_tp,
			1::INTEGER AS os_aber_tp,
			now()::timestamp without time zone AS os_abertura,
			2::integer AS os_tp_oficina,
			com_compras.id_compra::integer as id_compra,
			fornecedores.id_fornecedor as os_id_cliente,
			numero_documento::INTEGER,
			SUM(CASE WHEN com_produtos.tipo_item = '07' THEN com_compras_itens.vl_total ELSE 0.00 END)::numeric(10,2) as os_vlr_pecas,
			SUM(CASE WHEN com_produtos.tipo_item <> '07' THEN com_compras_itens.vl_total ELSE 0.00 END)::numeric(10,2) as os_vlr_servs,
			SUM(com_compras_itens.vl_total)::numeric(12,2) as os_vlr_total,
			com_compras.data_emissao::date as os_nr_nf_emissao,
			v_usuario AS os_aprov_usu,
			now()::timestamp without time zone AS os_aprovacao,
			('GERADA POR ESCRITURACAO '::TEXT || numero_compra::TEXT || ' VEICULO ' || com_compras_itens.placa_veiculo)::TEXT AS os_obs 
		FROM 	
			t			
			LEFT JOIN com_compras_itens 
				ON t.id_item = com_compras_itens.id_compra_item
			LEFT JOIN com_compras 
				ON com_compras_itens.id_compra = com_compras.id_compra
			LEFT JOIN fornecedores
				ON fornecedores.cnpj_cpf = com_compras.cnpj_fornecedor
			LEFT JOIN com_produtos
				ON com_produtos.id_produto = com_compras_itens.id_produto		
		GROUP BY 
			com_compras.id_compra,
			fornecedores.id_fornecedor,
			com_compras_itens.placa_veiculo,
			now(),
			v_usuario
		RETURNING id_os;
	

		FETCH v_cursor INTO v_id_os;

		CLOSE v_cursor;

		IF  v_id_os IS NOT NULL THEN

			-- Gerou OS
			v_retorno := 1 ;

			-- Inserir os Itens da Nota nos Itens da OS
			INSERT INTO frt_os_itens
			(
				id_os,
				item_numero,
				item_origem,
				item_id_origem,
				item_qtd,
				item_vlr_unit,
				id_almoxarifado,
				chave_pro,
				flag_aprovado,
				item_status  
			)	
			WITH t AS (
				SELECT unnest(string_to_array(v_itens,','))::integer as id_item			
			)		
			SELECT  
				v_id_os, 
				Row_Number() OVER(ORDER BY id_compra_item) As item_numero, 
				CASE WHEN cp.tipo_item = '07'
				     THEN 2
				     ELSE 1
				END::INTEGER AS item_origem, 
				id_produto, 
				quantidade,
				vl_item,
				id_almoxarifado,
				(id_almoxarifado::TEXT || LPAD(id_produto::TEXT,6,'0'))::INTEGER as chave_pro,
				1::INTEGER AS flag_aprovado,
				1::INTEGER AS item_status
			FROM    
				t
				LEFT JOIN com_compras_itens ci
					ON ci.id_compra_item = t.id_item
				LEFT JOIN com_produtos cp 
					USING(id_produto);
			

			--SELECT ARRAY[4] <@ '{1,2,3}'::integer[]
			-- Linkar no compras a OS gerada			
			--SELECT array_agg(unnest(string_to_array(v_itens,','))) INTO v_id_itens;
			WITH t AS (
				SELECT unnest(string_to_array(v_itens,','))::integer as item
			)
			SELECT array_agg(item) INTO v_id_itens FROM t;
			UPDATE  com_compras_itens
			SET     id_os = v_id_os 
			WHERE   ARRAY[id_compra_item] <@  v_id_itens;	
		ELSE
			v_retorno = 0;

		END IF;


	END LOOP;

	
	RETURN v_retorno;

END;
$function$
