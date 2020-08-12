CREATE TABLE fila_envio_app
(
	id serial,
	tipo_documento integer, 
	id_romaneio integer,	
	id_nota_fiscal_imp integer,
	id_conhecimento_nota_fiscal integer,	
	cpf character(14),
	data_romaneio date,
	data_alteracao timestamp,
	retirada integer DEFAULT 0,
	data_registro timestamp DEFAULT now(),
	CONSTRAINT fila_envio_app_id_pk PRIMARY KEY (id)	
);

/*
	SELECT 
		--to_char(MAX(data_alteracao),'YYYY-MM-DD HH24:MI:SS') as ultima_alteracao
		data_alteracao,
		id_romaneio,
		f.cpf
	 FROM 
		fornecedores m
		LEFT JOIN scr_app_uuid u
		    ON u.id_fornecedor = m.id_fornecedor
		LEFT JOIN fila_envio_app f
		    ON f.cpf = m.cnpj_cpf
	 WHERE
	     u.uuid = '83db01a4-0b2f-4fd4-9104-552bcc24510c' 
	   ORDER BY data_alteracao DESC
	     AND f.id = 4846
	     AND 
	     f.data_romaneio = '2020-07-28 00:00:00'


	SELECT * FROM fila_envio_app WHERE id = 4846
*/
--UPT
--SELECT * FROM fila_envio_app WHERE id_romaneio = 1656
--SELECT data_romaneio, data_saida FROM scr_romaneios WHERE id_romaneio = 1628
--SELECT data_romaneio, data_saida, emitido, id_romaneio, cpf_motorista FROM scr_romaneios WHERE id_motorista = 8 ORDER BY 1 DESC
--SELECT * FROM scr_romaneio_nf WHERE id_romaneio = 1656
--SELECT * FROM scr_conhecimento_entrega
--SELECT * FROM scr_conhecimento_ocorrencias_nf
--SELECT * FROM fila_envio_app WHERE id_romaneio = 133750
--UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio WHERE id_romaneio = 1656
--SELECT * FROM 
--SELECT * FROM fila_nf_app_log 

CREATE TABLE fila_nf_app_log
(
	id serial,	
	ultimo_download timestamp,
	id_app_uuid integer,
	data_registro timestamp DEFAULT now(),	
	CONSTRAINT fila_nf_app_log_id_pk PRIMARY KEY (id)
);


--SELEct id_fornecedor FROM fornecedores WHERE cnpj_cpf = '10795347413'
--SELECT * FROm scr_app_uuid WHERE id_fornecedor = 8 ORDER BY last_login DESC
CREATE TABLE scr_app_uuid
(
	id serial,
	id_fornecedor integer,
	id_usuario integer,
	uuid text,
	status integer DEFAULT 0,
	last_login timestamp,		
	CONSTRAINT scr_app_uuid_id_pk PRIMARY KEY (id)
);





CREATE TRIGGER tgg_enfileira_nf_app
AFTER INSERT OR UPDATE OR DELETE
ON scr_romaneio_nf
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_enfileira_nf_app();


CREATE TRIGGER tgg_enfileira_nf_app_2
AFTER INSERT OR UPDATE OR DELETE
ON scr_conhecimento_entrega
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_enfileira_nf_app();



CREATE OR REPLACE FUNCTION f_insere_fila_nf_app_log(p_uuid text, p_ultimo_download timestamp)
  RETURNS integer AS
$BODY$
DECLARE
       vId integer;
       v_id_uuid integer;
       v_ultimo_download text;
       vCursor refcursor;
BEGIN

	SELECT 
		a.id, b.id
	INTO 
		vId, v_id_uuid
	FROM
		fila_nf_app_log a
		RIGHT JOIN scr_app_uuid b
			ON a.id_app_uuid = b.id
	WHERE
		b.uuid = p_uuid;

	--SELECT * FROM fila_nf_app_log
	IF vId IS NULL THEN 
		OPEN vCursor FOR
		INSERT INTO fila_nf_app_log (ultimo_download, id_app_uuid)
		VALUES (p_ultimo_download, v_id_uuid);
	ElSE
		UPDATE fila_nf_app_log SET
			ultimo_download = p_ultimo_download
			
		WHERE
			id = v_id;		
	END IF;
			
	RETURN vId;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

/*

SELE

SELECT * FROM scr_faturamento WHERE numero_fatura = '0010010006254'
SELECT string_agg(id_conhecimento::text,',') FROM scr_conhecimento WHERE id_faturamento = 6305;
SELECT * FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento IN (311098,311100,311085,311087,311090,311092,311094,311096)
SELECT string_agg(id_conhecimento_notas_fiscais::text, ',') FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento IN (311098,311100,311085,311087,311090,311092,311094,311096)

UPDATE scr_docs_digitalizados SET id = id WHERE id_conhecimento_notas_fiscais IN (636472,636473,636474,636475,636476,636477,636478,636479)
6305

*/


-- SELECT id_romaneio FROM scr_romaneios WHERE data_saida::date = '2020-02-28' AND cpf_motorista = '06167894671';
--SELECT string_agg(id_romaneio::text,',') FROM scr_romaneios WHERE data_saida::date = current_date -1
--UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio WHERE id_romaneio IN (513,512,511,510,509,508,507,506,505,504,503,501,500,499,498)

--SELECT * FROM frt_tipo_atividades