/*
SELECT id_nf, vl_desconto, modelo_doc_fiscal FROM com_nf WHERE chave_eletronica = '52191203530737000104650010000014521779561345';

BEGIN;
DELETE FROM com_nf WHERE id_nf = 37339

UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao WHERE chave_doc = '52191203530737000104650010000014521779561345'

SELECT chave_eletronica FROM com_nf WHERE id_nf IN (37337,37336,37335)

SELECT * FROM com_nf_itens ORDER BY 1 DESC LIMIT 100

SELECT * FROm com_nf_itens WHERE id_nf = 37340

SELECT * FROM scr_doc_integracao WHERE chave_doc = '52191203530737000104650010000014521779561345';

SELECT f_com_nf_corrige_importacao(doc_xml, chave_doc) FROM scr_doc_integracao WHERE chave_doc IN ('52190103163171000120650010000036351092474572','52190103163171000120650010000036891786100546','52190103163171000120650010000037339389419649','52190403163171000120650010000043281703590510','52191103163171000120650010000054691998407724','52191103163171000120650010000056951582741542')


SELECT * FROM v_com_nf_cubo WHERE modelo_doc_fiscal = '65' AND id_produto = 0

SELECT 
	*
FROM 
	efd_fiscal_produtos_ecf


--SELECT * FROM com_produtos 


SELECT row_to_json(scr_doc_integracao) as dados FROM scr_doc_integracao LIMIT 1
*/


CREATE OR REPLACE FUNCTION f_com_nf_corrige_importacao(p_xml text, p_chave text)
  RETURNS integer AS
$BODY$
DECLARE
     v_desconto numeric(12,2);
     v_id_produto integer;
     v_codigo_produto text;   
     v_unidade text;
     dadosItens json;
     v_dados json;
     v_produtos json;
     v_id_nf integer;
     v_valor numeric(12,2);
     v_vl_item numeric(12,2);
     v_quantidade numeric(12,2);
     t integer;
     
BEGIN
		
	v_dados = fpy_parse_xml_nfc(p_xml);
	--RAISE NOTICE 'Dados: %s', v_dados;						
	--RAISE NOTICE '%', v_dados;
	v_produtos = (v_dados->>'produtos')::json;
	t = json_array_length(v_produtos)-1;
	
	FOR i IN 0..t LOOP	
		dadosItens = (v_produtos->>i)::json;

		--RAISE NOTICE '%', dadosItens;

		v_unidade = (dadosItens->>'produto_unidade')::text;
		
		BEGIN 
			v_valor		= ((dadosItens->>'produto_vl_total')::text)::numeric(12,2);
		EXCEPTION WHEN OTHERS THEN 
			v_valor 	= 0.00;
		END;

		BEGIN 
			v_vl_item	= ((dadosItens->>'produto_vl_unit')::text)::numeric(12,2);
		EXCEPTION WHEN OTHERS THEN 
			v_vl_item	= 0.00;
		END;

		RAISE NOTICE 'Valor Item %',v_vl_item;

		BEGIN 
			v_quantidade	= ((dadosItens->>'produto_qtd')::text)::numeric(12,6);
		EXCEPTION WHEN OTHERS THEN 
			v_quantidade		= 0.00;
		END;

		RAISE NOTICE 'Quantidade %', v_quantidade;
		--RAISE NOTICE 'Participante %', v_participantes::text;
		BEGIN 
			v_desconto = ((dadosItens->>'produto_vl_desc')::text)::numeric(12,2);
		EXCEPTION WHEN OTHERS THEN 
			v_desconto = 0.00;
		END;

					
		
		SELECT id_nf
		INTO   v_id_nf
		FROM  com_nf 
		WHERE chave_eletronica = p_chave;


		v_codigo_produto = (dadosItens->>'produto_codigo')::text;
		RAISE NOTICE 'Codigo Produto %', v_codigo_produto::text;
		SELECT id_produto_softlog
		INTO v_id_produto
		FROM efd_fiscal_produtos_ecf
		WHERE codigo_produto = v_codigo_produto;					

		
		UPDATE com_nf_itens SET 
			vl_desconto = v_desconto,
			quantidade = v_quantidade,
			unidade = v_unidade,
			vl_item = v_vl_item,
			codigo_prod_digisat = 	v_codigo_produto		
		WHERE 
			id_nf = v_id_nf AND id_produto = v_id_produto;
			
		
	END LOOP;			
	
        
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;