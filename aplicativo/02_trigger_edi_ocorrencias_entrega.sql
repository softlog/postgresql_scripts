
CREATE TRIGGER tgg_edi_ocorrencias_entrega
BEFORE INSERT OR UPDATE 
ON edi_ocorrencias_entrega
FOR EACH ROW
EXECUTE PROCEDURE edi_ocorrencias_entrega();

--SELECT * FROM scr_imagens_base64