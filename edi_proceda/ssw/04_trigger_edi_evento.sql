CREATE OR REPLACE FUNCTION f_tgg_enfileira_edi_evento()
  RETURNS trigger AS
$BODY$
DECLARE
	
	
BEGIN

	
	INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
	) 
	SELECT 
		nf.empresa_emitente,
		nf.filial_emitente,
		edi.id_embarcador,
		edid.id_doc,
		NEW.id_ocorrencia_nf::text
	FROM 
		edi_tms_embarcadores edi
		LEFT JOIN v_mgr_notas_fiscais nf
			ON nf.pagador_cnpj = edi.cnpj_cliente
		LEFT JOIN edi_tms_embarcador_docs edid
			ON edid.id_embarcador = edi.id_embarcador
		LEFT JOIN edi_tms_docs
			ON edi_tms_docs.id_doc = edid.id_doc
	WHERE
		id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
		AND edi_tms_docs.tipo_doc IN (2,-3,-4)
		AND edid.tipo_evento = 4;
		
		
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;




CREATE TRIGGER tgg_enfileira_edi_evento
AFTER INSERT OR UPDATE
ON scr_notas_fiscais_imp_ocorrencias
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_enfileira_edi_evento();



--SELECT * FROM edi_tms_embarcadores ORDER BY 1 DESC 