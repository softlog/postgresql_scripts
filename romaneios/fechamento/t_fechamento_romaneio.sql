-- Function: public.f_tabela_motorista_fornecedor()

-- DROP FUNCTION public.f_tabela_motorista_fornecedor();

CREATE OR REPLACE FUNCTION public.f_tabela_motorista_fornecedor()
  RETURNS trigger AS
$BODY$
DECLARE
	vCursor refcursor; --cursor para receber dados do comando select principal
	--vLinha 	scf_contas_correntes%ROWTYPE; 
	--vCmd text;
	v_id_for integer;
BEGIN	

	IF TG_TABLE = 'scr_romaneios' THEN 
		IF NEW.ativa = 1 THEN 
			
			UPDATE fornecedores SET numero_tabela_motorista = NEW.numero_tabela_motorista 
			WHERE cnpj_cpf = NEW.cpf_motorista;

			SELECT id_fornecedor
			INTO v_id_for
			FROM fornecedores
			WHERE cnpj_cpf = NEW.cpf_motorista;

			IF TG_OP = 'UPDATE' THEN 
				UPDATE fornecedores SET numero_tabela_motorista = NULL 
				WHERE cnpj_cpf = OLD.cpf_motorista;				
			END IF;

			RAISE NOTICE 'Codigo Fornecedor %', v_id_for;
			RAISE NOTICE 'CNPJ CPF %', NEW.cpf_motorista;
					
			UPDATE scr_romaneios SET 
				numero_tabela_motorista = NEW.numero_tabela_motorista 		
			FROM 
			WHERE
				(id_motorista = v_id_motorista OR cnpj_cpf_proprietario = NEW.cpf_motorista)
				AND numero_tabela_motorista IS NULL;		
				

					
			UPDATE scr_romaneios SET id_romaneio = id_romaneio 
			WHERE 
				fechamento = 1 
				AND 
				NOT EXISTS (	SELECT 1
						FROM scr_relatorio_viagem_romaneios
						WHERE scr_romaneios.id_romaneio = scr_relatorio_viagem_romaneios.id_romaneio
					)
				AND
					numero_tabela_motorista = NEW.numero_tabela_motorista;
					
					
				--SELECT * FROM scr_romaneios LIMIT 1

			--UPDATE scr_tabela_motorista SET 
		END IF;
	END IF;
	
	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


--SELECT * FROM scr_romaneios WHERE tipo_frota = 2 AND numero_tabela_motorista IS NULL ORDER BY 1 DESC LIMIT 100
--SELECT * FROM scr_romaneios WHERE cnpj_cpf_proprietario = 