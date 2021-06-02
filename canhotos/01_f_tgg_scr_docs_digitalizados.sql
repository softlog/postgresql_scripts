CREATE OR REPLACE FUNCTION f_tgg_scr_docs_digitalizados()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_banco_dados integer;
BEGIN

	IF position( 'sconfirmei' in NEW.link_img) < 1 THEN 
		SELECT id_string_conexao
		INTO v_id_banco_dados
		FROM string_conexoes
		WHERE banco_dados = current_database();		
		
		INSERT INTO fila_download_imagens (id_doc, id_banco_dados)
		VALUES (NEW.id, v_id_banco_dados);	
		
	END IF;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
