DROP FOREIGN TABLE fila_importacao_xml;
CREATE FOREIGN TABLE public.fila_importacao_xml
   (tipo_servico integer ,
    tipo_doc integer ,
    id_banco_dados integer ,
    codigo_empresa character(3) ,
    codigo_filial character(3) ,
    chave_doc character(44) ,
    status integer DEFAULT 0,
    data_registro timestamp without time zone DEFAULT now(),
    data_processamento timestamp without time zone ,
    id_usuario integer DEFAULT 0,
    status_importacao integer DEFAULT 0,
    data_processamento_importacao timestamp without time zone ,
    id2 integer ,
    qt_tentativas integer DEFAULT 0,
    mensagem_api text ) 
 SERVER integracao_softlog_fdw;

-- ALTER TABLE fila_importacao_xml ADD COLUMN mensagem_api text;
-- ALTER FOREIGN TABLE fila_importacao_xml ADD COLUMN status_importacao integer DEFAULT 0;
-- ALTER FOREIGN TABLE fila_importacao_xml ADD COLUMN data_processamento_importacao timestamp;
-- ALTER FOREIGN TABLE fila_importacao_xml ADD COLUMN id2 integer;


--SELECT * FROM fila_importacao_xml ORDER BY data_registro DESC 

--SELECT * FROM string_conexoes ORDER BY 2
/*
	SELECT 
		id,
		tipo_servico,		
		id_banco_dados,
		codigo_empresa,
		codigo_filial,
		chave_doc,
		status,
		data_registro,		
		id_usuario
	FROM 
		fila_importacao_xml
	WHERE 
		status = 0
		AND tipo_doc = 2

BEGIN;
INSERT INTO fila_importacao_xml ( codigo_empresa, codigo_filial, id_banco_dados, chave_doc, id_usuario)
SELECT '001','001', 82, chave_nfe, 1 FROM scr_notas_fiscais_imp ORDER BY id_nota_fiscal_imp DESC LIMIT 1;
SELECT * FROM fila_importacao_xml 
DELETE FROM fila_importacao_xml 
UPDATE fila_importacao_xml set status = 0 WHERE data_processamento IS NOT NULL

SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 30
SELECT * FROM scr_notas_fiscais_imp WHERE chave_nfe = '35190400358491000147550010000123581000032440'
*/




