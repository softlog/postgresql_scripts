ALTER TABLE scr_servicos ADD COLUMN id_produto_nfse integer;
ALTER TABLE scr_servicos ADD COLUMN cnae character(7);
ALTER TABLE scr_servicos ADD COLUMN cnae character(7);



/*
select id_servico_executado, numero_servico, id_conhecimento, codigo_cliente, data_servico, cod_empresa, cod_filial from scr_servicos_executados WHERE 1=2

SELECT scr_servicos_executados_itens.id_servico_executado_item, 
scr_servicos_executados_itens.id_servico_executado, scr_servicos_executados_itens.servico_executado, 
 scr_servicos_executados_itens.id_servico, scr_servicos.servico, scr_servicos_executados_itens.valor_servico 
 from scr_servicos_executados_itens 
 LEFT JOIN scr_servicos ON scr_servicos.id_servico = scr_servicos_executados_itens.id_servico
 WHERE 1=2



SELECT * FROM scr_faturamento WHERE numero_fatura = '0100010003564';
WITH t AS (
	SELECT  
		row_number() over (partition by si.id_servico_executado order by valor_servico desc) as ordem,
		se.numero_servico, 
		se.data_servico,
		si.id_servico,
		s.servico,
		si.valor_servico,
		p.id_produto,
		p.descr_item,
		si.id_servico_executado		
	FROM  
		scr_servicos_executados se 
		LEFT JOIN scr_servicos_executados_itens si
			ON si.id_servico_executado = se.id_servico_executado 
		LEFT JOIN scr_servicos s
			ON s.id_servico = si.id_servico				
		LEFT JOIN com_produtos p
			ON p.id_produto = s.id_produto_nfse
	WHERE 
		id_faturamento = 3564
		--AND si.valor_servico > 0
	ORDER BY 
		si.valor_servico
	DESC
)
, t1 AS (

	SELECT 		
		string_agg(t.servico || ':' || t.valor_servico::text || ' R$', ' / ' order by t.id_servico_executado)  descricao
	FROM
		t
	
)
SELECT * FROM t1, t ORDER BY ordem LIMIT 1

SELECT 
	
	
	

*/
