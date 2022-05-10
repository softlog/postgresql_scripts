-- Function: public.altera_tree_centro_custo_filhos()

-- DROP FUNCTION public.altera_tree_centro_custo_filhos();
SELECT * FROM fd_dados_tabela('scf_centro_custos');

CREATE OR REPLACE FUNCTION public.altera_tree_centro_custo_filhos()
  RETURNS trigger AS
$BODY$
DECLARE
       id_endereco_cobranca integer;
BEGIN

      IF new.atualizar = 1 THEN
      
	      NEW.atualizar = null;
	      
              UPDATE scf_centro_custos SET tree_centro_custo = (SELECT 
		--t.codigo_centro_custo, 
		--t.id_pai_centro_custo, 
		--t.level_centro_custo, 
		t.tree_centro_custo
	      FROM connectby('scf_centro_custos'::text, 'codigo_centro_custo'::text, 'id_pai_centro_custo'::text, '0'::text, 0, '.'::text) 
		t(codigo_centro_custo text, id_pai_centro_custo text, level_centro_custo integer, tree_centro_custo text) 
	      WHERE t.codigo_centro_custo = NEW.codigo_centro_custo::text) WHERE scf_centro_custos.id_centro_custo = new.id_centro_custo AND  scf_centro_custos.id_centro_custo_pai IS NOT NULL;
			

	      UPDATE scf_centro_custos SET nivel = (SELECT 
		--t.codigo_centro_custo, 
		--t.id_pai_centro_custo, 
		t.level_centro_custo
		--t.tree_centro_custo
	      FROM connectby('scf_centro_custos'::text, 'codigo_centro_custo'::text, 'id_pai_centro_custo'::text, '0'::text, 0, '.'::text) 
		t(codigo_centro_custo text, id_pai_centro_custo text, level_centro_custo integer, tree_centro_custo text) 
	      WHERE t.codigo_centro_custo = NEW.codigo_centro_custo::text) WHERE scf_centro_custos.id_centro_custo = new.id_centro_custo AND  scf_centro_custos.id_centro_custo_pai IS NOT NULL;

	      UPDATE scf_centro_custos SET atualizar = 1 WHERE scf_centro_custos.id_pai_centro_custo = old.codigo_centro_custo;	          	
	      
      END IF;
       
      RETURN NEW;      
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.altera_tree_centro_custo_filhos()
  OWNER TO softlog_pdl;
