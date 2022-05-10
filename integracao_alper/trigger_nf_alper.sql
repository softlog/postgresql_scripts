CREATE OR REPLACE FUNCTION f_tgg_alper_nf()
  RETURNS trigger AS
$BODY$
DECLARE
	has_alper integer;
	vEmpresa text;
	
BEGIN
	
	SELECT 	(COALESCE(valor_parametro,'0'))::integer
	INTO 	has_alper
	FROM 	parametros 
	WHERE 	cod_empresa = COALESCE(NEW.empresa_emitente,'001') AND upper(cod_parametro) = 'PST_INTEGRACAO_ALPER';

	IF COALESCE(has_alper,0) = 1 THEN 
	
		INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
		VALUES (10,1,NEW.id_nota_fiscal_imp,NULL);
		
	END IF;

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_zzz_alper
AFTER INSERT 
ON scr_notas_fiscais_imp
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_alper_nf();




--ALTER TABLE scr_notas_fiscais_imp DISABLE TRIGGER tgg_zzz_alper


