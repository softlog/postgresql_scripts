CREATE OR REPLACE FUNCTION f_tgg_set_data_fim_ocorrencia()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_ultima_ocorrencia integer;
BEGIN

	BEGIN
		SELECT 
			id_ocorrencia_nf
		INTO  
			v_id_ultima_ocorrencia
		FROM  
			scr_notas_fiscais_imp_ocorrencias 
		WHERE 	
			id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
			AND id_ocorrencia_nf <> NEW.id_ocorrencia_nf
		ORDER BY 
			data_ocorrencia 
		DESC LIMIT 1;
			
		UPDATE 
			scr_notas_fiscais_imp_ocorrencias 
		SET 
			data_fim = NEW.data_ocorrencia 
		WHERE 
			id_ocorrencia_nf = v_id_ultima_ocorrencia;
	EXCEPTION WHEN OTHERS  THEN 
		RAISE NOTICE 'ERRO %', SQLERRM;
	END;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_z_set_data_fim_ocorrencia
AFTER INSERT 
ON scr_notas_fiscais_imp_ocorrencias
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_set_data_fim_ocorrencia();