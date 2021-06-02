-- Function: public.f_grava_historico_relatorio_viagem()
-- UPDATE scr_relatorio_viagem SET numero_relatorio = numero_relatorio WHERE numero_relatorio IS NULL;
-- DROP FUNCTION public.f_grava_historico_relatorio_viagem();

CREATE OR REPLACE FUNCTION public.f_grava_historico_relatorio_viagem()
  RETURNS trigger AS
$BODY$
DECLARE
	lcHistorico text;
	v_numero_relatorio character(13);	
BEGIN	
	lcHistorico = NEW.historico || ' ' || NEW.numero_relatorio;
	NEW.historico = lcHistorico;

	WITH parcelas AS (
		SELECT id_conta_pagar, id_relatorio_viagem 
		FROM scr_relatorio_viagem_parcelas 
		WHERE scr_relatorio_viagem_parcelas.id_relatorio_viagem = NEW.id_relatorio_viagem
	)
	UPDATE scf_contas_pagar SET historico_conta = lcHistorico, numero_documento = SUBSTR(NEW.numero_relatorio,4,10) 
	WHERE EXISTS (
			SELECT 	1
			FROM 	parcelas
			WHERE 	parcelas.id_conta_pagar = scf_contas_pagar.id_conta_pagar::integer
		     );

	

	IF NEW.numero_relatorio IS NULL THEN 
		v_numero_relatorio = NEW.empresa || NEW.filial
			|| lpad(trim(proximo_numero_sequencia('scr_relatorio_viagens_' || NEW.empresa || '_' || NEW.filial)::text), 7, '0');

		NEW.numero_relatorio = v_numero_relatorio;
	END IF;

	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

