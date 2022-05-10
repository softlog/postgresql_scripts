-- Function: public.grava_data_cancelamento_contas_pagar()

-- DROP FUNCTION public.grava_data_cancelamento_contas_pagar();

CREATE OR REPLACE FUNCTION grava_data_cancelamento_contas_pagar()
  RETURNS trigger AS
$BODY$
DECLARE
BEGIN
      IF NEW.status_conta = 6 AND NEW.data_cancelamento IS NULL THEN 
		NEW.data_cancelamento = current_date;	
      END IF;

      IF NEW.status_conta = 6 THEN 
		UPDATE com_compras SET conta_pagar_id = NULL WHERE conta_pagar_id = NEW.id_conta_pagar;
      END IF;
      
 RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
