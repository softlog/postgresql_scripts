-- Function: public.f_total_frete_relatorio_viagem(integer)

-- DROP FUNCTION public.f_total_frete_relatorio_viagem(integer);

--SELECT total_frete FROM scr_relatorio_viagem WHERE id_relatorio_viagem = 275
--SELECT f_total_frete_relatorio_viagem(305)

CREATE OR REPLACE FUNCTION public.f_total_frete_relatorio_viagem(pidrelatorio integer)
  RETURNS numeric AS
$BODY$
DECLARE 
	pIdRelatorio ALIAS FOR $1;
	vTotalFrete numeric(12,2);
	vCursor refcursor;
		
BEGIN
	vTotalFrete = 0;

	--SELECT * FROM scr_conhecimento WHERE id_manifesto = 390
	
	OPEN vCursor FOR 
	WITH lista_conhecimento as 
	(
		SELECT scr_conhecimento.id_conhecimento, 1::integer as c
		FROM scr_relatorio_viagem
		LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
		RIGHT JOIN scr_conhecimento_entrega ON scr_romaneios.id_romaneio = scr_conhecimento_entrega.id_romaneios
		LEFT JOIN scr_conhecimento ON scr_conhecimento_entrega.id_conhecimento = scr_conhecimento.id_conhecimento
		WHERE scr_relatorio_viagem.id_relatorio_viagem = pIdRelatorio


		UNION 

		--Seleciona id_documento que tipo 2 é o id_manifesto, gravado no conhecimento
		SELECT scr_manifesto.id_manifesto as id_conhecimento, 2::integer as c
		FROM scr_relatorio_viagem
		LEFT JOIN scr_romaneios ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto		
		RIGHT JOIN scr_viagens_docs ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio		
		LEFT JOIN scr_manifesto ON scr_manifesto.id_manifesto = scr_viagens_docs.id_documento AND tipo_documento = 2		
		LEFT JOIN scr_conhecimento ON scr_conhecimento.id_manifesto = scr_manifesto.id_manifesto
		WHERE scr_relatorio_viagem.id_relatorio_viagem = pIdRelatorio and scr_viagens_docs.tipo_documento = 2		

	),
	t1 AS (
		SELECT sum(total_frete) as total_frete
		FROM scr_conhecimento 
		WHERE EXISTS(	SELECT 	1
				FROM	lista_conhecimento
				WHERE 	lista_conhecimento.id_conhecimento = scr_conhecimento.id_conhecimento AND c = 1
			)					
		
		UNION 
		SELECT 
			sum(scr_viagens_docs.total_frete) as total_frete
		FROM 
			scr_relatorio_viagem
			LEFT JOIN scr_romaneios 
				ON scr_relatorio_viagem.id_relatorio_viagem = scr_romaneios.id_acerto
			RIGHT JOIN scr_viagens_docs 
				ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio
		WHERE 
			scr_relatorio_viagem.id_relatorio_viagem = pIdRelatorio and tipo_documento = 1
		UNION 
		SELECT sum(total_frete) as total_frete
		FROM scr_manifesto 
		WHERE EXISTS(	SELECT 	1
				FROM	lista_conhecimento
				WHERE 	lista_conhecimento.id_conhecimento = scr_manifesto.id_manifesto AND c = 2
			)		
	)
	SELECT SUM(total_frete) as total_frete FROM t1;
	
	FETCH vCursor INTO vTotalFrete;

	CLOSE vCursor;
	
RETURN vTotalFrete;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

