CREATE EXTENSION unaccent;

CREATE OR REPLACE FUNCTION f_get_destinatario_programacao(p_apelido text, p_id_coleta integer)
  RETURNS text AS
$BODY$
DECLARE
        id_nota_fiscal_imp integer;
        v_nome_cliente text;
BEGIN

	WITH t AS (
		SELECT destinatario_nome, similarity(trim(p_apelido), trim(destinatario_nome)) as similaridade
		INTO v_nome_cliente
		FROM v_mgr_notas_fiscais nf
			LEFT JOIN col_coletas_itens coi
				ON coi.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
		WHERE
			coi.id_coleta = p_id_coleta
	)
	SELECT * FROM t WHERE t.similaridade > 0.1 ORDER BY similaridade DESC LIMIT 1;		
		
	RETURN v_nome_cliente;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


  

/*
SELECT * FROM scr_programacao_coleta WHERE codigo_programacao = '4032556875'   

WITH t AS (
SELECT destinatario_nome, similarity(trim('PLANTALTO'), trim(destinatario_nome)) as similaridade 
        FROM v_mgr_notas_fiscais nf
		LEFT JOIN col_coletas_itens coi
			ON coi.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
	WHERE
		coi.id_coleta = 10

)
SELECT * FROM t ORDER BY similaridade DESC;	

SELECT id_nota_f


SELECT apelido_cliente, f_get_destinatario_programacao(apelido_cliente, col_coletas.id_coleta), ordem, col_coletas.id_coleta
FROM scr_programacao_coleta_entrega 
	LEFT JOIN col_coletas
		ON col_coletas.id_programacao_coleta = scr_programacao_coleta_entrega.id_programacao_coleta
ORDER BY col_coletas.id_programacao_coleta


SELECT id_nota_fiscal_imp, destinatario_nome, similarity('AP VALPARAISO', destinatario_nome) FROM v_mgr_notas_fiscais WHERE id_nota_fiscal_imp IN (5013,5014,5015,5016,5017)


SELECT * FROM col_coletas WHERE id_coleta = 19
SELECT * FROM col_coletas_itens WHERE id_coleta = 19
--SELECT 




*/