--SELECT fd_modelo_trigger()

--SELECT * FROM scr_relatorio_viagem_romaneios WHERE id_relatorio_viagem =  833
CREATE OR REPLACE FUNCTION f_tgg_rateia_acerto_minuta()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN
	--SELECT id_relatorio_viagem FROM scr_relatorio_viagem ORDER BY 1 DESC
	-- SELECT max(id_relatorio_viagem) FROM scr_relatorio_viagem
	--Faz rateio do frete por total de despesas do acerto	
	WITH t AS (
		SELECT 	
			rv.id_relatorio_viagem,
			c.id_conhecimento,						
			c.total_frete,
			c.peso,
			rv.vl_servico_for,
			rv.vl_despesas_viagem,
			rv.total_despesas_indiretas,
			(rv.vl_despesas_viagem + rv.total_despesas_indiretas + rv.vl_servico_for) as total_despesas,
			SUM(c.peso) OVER (PARTITION BY rv.id_relatorio_viagem) as peso_total
		FROM 
			scr_conhecimento c

			LEFT JOIN scr_viagens_docs d
				ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1

			LEFT JOIN scr_romaneios r 
				ON r.id_romaneio = d.id_romaneio

			LEFT JOIN scr_relatorio_viagem_romaneios vr
				ON vr.id_romaneio = r.id_romaneio

			RIGHT JOIN scr_relatorio_viagem rv 
				ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
				
		WHERE 
			c.data_emissao IS NOT NULL			
			--AND r.cancelado = 0	
			--AND c.cancelado = 0
			--AND rv.id_relatorio_viagem = 836
			AND rv.id_relatorio_viagem = NEW.id_relatorio_viagem
	)
	, t1 AS (
		SELECT 
			t.id_relatorio_viagem,
			t.id_conhecimento,
			t.total_frete,
			t.peso,
			t.total_despesas,
			t.peso_total,
			COALESCE((total_despesas * (peso/COALESCE(NULLIF(peso_total,0),1))),0.00)::numeric(12,2) as valor_frete
		FROM 
			t
			
	)
	, t2 AS (
		SELECT 
			id_relatorio_viagem,
			MAX(id_conhecimento) as id_conhecimento,
			(total_despesas - SUM(valor_frete)) as diferenca
		FROM
			t1
		GROUP BY 
			id_relatorio_viagem,
			total_despesas	
			
	)
	, t3 AS (
		SELECT
			t1.id_relatorio_viagem,
			t1.id_conhecimento,
			t1.total_frete,
			COALESCE(t2.diferenca,0.00) as diferenca,
			t1.total_despesas,
			t1.peso,
			(t1.valor_frete + COALESCE(diferenca,0.00)) as valor_frete
		FROM 
			t1 
			LEFT JOIN t2
				ON t1.id_conhecimento = t2.id_conhecimento	
		
	)		
	UPDATE scr_conhecimento SET
		total_frete = t3.valor_frete
	FROM 
		t3
	WHERE
		t3.id_conhecimento = scr_conhecimento.id_conhecimento;


	--Exclui componentes de frete dos conhecimentos
	WITH t AS (
		SELECT 	
			rv.id_relatorio_viagem,
			c.id_conhecimento,						
			c.total_frete			
		FROM 
			scr_conhecimento c

			LEFT JOIN scr_viagens_docs d
				ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1

			LEFT JOIN scr_romaneios r 
				ON r.id_romaneio = d.id_romaneio

			LEFT JOIN scr_relatorio_viagem_romaneios vr
				ON vr.id_romaneio = r.id_romaneio

			RIGHT JOIN scr_relatorio_viagem rv 
				ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
				
		WHERE 
			c.data_emissao IS NOT NULL			
			--AND r.cancelado = 0	
			--AND c.cancelado = 0
			AND rv.id_relatorio_viagem = NEW.id_relatorio_viagem
	)
	DELETE FROM scr_conhecimento_cf 
	USING t
	WHERE t.id_conhecimento = scr_conhecimento_cf.id_conhecimento;

	--Inclui componentes de Frete
	WITH t AS (
		SELECT 	
			rv.id_relatorio_viagem,
			c.id_conhecimento,						
			c.total_frete,
			c.peso,
			d.id_viagem_doc
		FROM 
			scr_conhecimento c
			
			LEFT JOIN scr_viagens_docs d
				ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1

			LEFT JOIN scr_romaneios r 
				ON r.id_romaneio = d.id_romaneio

			LEFT JOIN scr_relatorio_viagem_romaneios vr
				ON vr.id_romaneio = r.id_romaneio

			RIGHT JOIN scr_relatorio_viagem rv 
				ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
				
		WHERE 
			c.data_emissao IS NOT NULL			
			--AND r.cancelado = 0	
			--AND c.cancelado = 0
			AND rv.id_relatorio_viagem = NEW.id_relatorio_viagem
	)

	--SELECT * FROM scr_conhecimento_cf LIMIT 1
	INSERT INTO scr_conhecimento_cf (
		id_conhecimento, 
		id_tipo_calculo, 
		excedente, 
		quantidade, 
		valor_item,
		valor_total, 
		valor_minimo, 
		valor_pagar,
		operacao, 
		id_faixa, 
		combinado, 
		modo_calculo, 
		perc_desconto,
		valor_pagar_sdesconto,
		desconto
	) 
	SELECT
		t.id_conhecimento, 
		1,
		0,
		1,
		COALESCE(t.total_frete,0.00),
		COALESCE(t.total_frete,0.00),
		COALESCE(t.total_frete,0.00),
		0.00,		
		'C',
		1,
		1,
		1,
		0.00,
		COALESCE(t.total_frete,0.00),
		0.00
	FROM 
		t;
	


	--Atualiza valor do frete nos documentos de viagens
	WITH t AS (
		SELECT 	
			rv.id_relatorio_viagem,
			c.id_conhecimento,						
			c.total_frete,
			c.peso,
			d.id_viagem_doc			
		FROM 
			scr_conhecimento c
			
			LEFT JOIN scr_viagens_docs d
				ON d.id_documento = c.id_conhecimento AND d.tipo_documento = 1

			LEFT JOIN scr_romaneios r 
				ON r.id_romaneio = d.id_romaneio

			LEFT JOIN scr_relatorio_viagem_romaneios vr
				ON vr.id_romaneio = r.id_romaneio

			RIGHT JOIN scr_relatorio_viagem rv 
				ON rv.id_relatorio_viagem = vr.id_relatorio_viagem
				
		WHERE 
			c.data_emissao IS NOT NULL			
			--AND r.cancelado = 0	
			--AND c.cancelado = 0
			--AND rv.id_relatorio_viagem = 833
			AND rv.id_relatorio_viagem = NEW.id_relatorio_viagem
	)
	UPDATE scr_viagens_docs SET
		total_frete = COALESCE(t.total_frete,0.00),
		total_frete_bruto = COALESCE(t.total_frete,0.00)
	FROM t	
	WHERE t.id_viagem_doc = scr_viagens_docs.id_viagem_doc;
	
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--DROP TRIGGER tgg_rateia_acerto_minuta ON scr_relatorio_viagem;

CREATE TRIGGER tgg_rateia_acerto_minuta
AFTER UPDATE OF flg_rateio_documentos 
ON scr_relatorio_viagem
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_rateia_acerto_minuta();