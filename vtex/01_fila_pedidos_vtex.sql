CREATE TABLE fila_pedidos_vtex
(
	id serial NOT NULL,
	numero_pedido text,
	data_autorizacao timestamp,	
	status integer DEFAULT 0,
	id_banco_dados integer,
	data_registro timestamp DEFAULT now(),
	data_processamento timestamp,	
	qt_tentativas integer DEFAULT 0,  
	CONSTRAINT fila_pedidos_vtex_id_pk PRIMARY KEY (id)
);

ALTER TABLE fila_pedidos_vtex ADD COLUMN chave_nfe character(44);

ALTER TABLE fila_pedidos_vtex ADD COLUMN data_criacao timestamp;



/*
SELECT * FROM fila_pedidos_vtex ORDER BY 1 DESC

SELECT * FROM fila_pedidos_vtex WHERE numero_pedido = '108702115364301'

35210105889907000177550020002104791659316552
DELETE FROM fila_pedidos_vtex WHERE status = 0

SELECT * FROM fila_pedidos_vtex WHERE status = 0
SELECT 
	fila.*,
	nf.numero_nota_fiscal, 
	nf.chave_nfe,
	nf.data_expedicao,
	nf.data_emissao
	 
FROM 
	fila_pedidos_vtex fila 
	LEFT JOIN scr_notas_fiscais_imp nf
		ON nf.numero_pedido_nf = fila.numero_pedido
WHERE 
	fila.data_registro >= '2020-10-07 00:00:00'
*/
--SELECT * FROM fila_pedidos_vtex WHERE status = 0
--DELETE FROM  fila_pedidos_vtex
CREATE TABLE fila_ocorrencias_pedido_vtex
(
	id serial NOT NULL,
	id_fila_pedido integer,	
	status integer DEFAULT 0,	
	data_registro timestamp DEFAULT now(),
	data_processamento timestamp,	
	id_conhecimento_notas_fiscais integer,
	id_nota_fiscal_imp integer,
	id_ocorrencia integer,
	id_ocorrencia_nf integer,
	qt_tentativas integer DEFAULT 0, 	 
	CONSTRAINT fila_ocorrencias_pedido_vtex_id_pk PRIMARY KEY (id)
);

ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN id_cidade integer;
ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN evento text;
ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN data_ocorrencia text;
ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN operacao_por_nota integer DEFAULT 0;
ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN id_romaneio integer;
ALTER TABLE fila_ocorrencias_pedido_vtex ADD COLUMN id_manifesto integer;


CREATE OR REPLACE FUNCTION f_tgg_valida_pedidos_vtex()
  RETURNS trigger AS
$BODY$
DECLARE
	v_qt integer;
	v_id_remetente integer;
BEGIN

	SELECT 
		count(*)
	INTO 
		v_qt
	FROM 
		fila_pedidos_vtex
	WHERE 
		numero_pedido = NEW.numero_pedido
		AND id <> NEW.id;

	IF v_qt > 0 THEN 
		RETURN NULL;
	END IF;
	

	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER fila_pedidos_vtex
BEFORE INSERT OR UPDATE 
ON fila_pedidos_vtex
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_valida_pedidos_vtex();



/*




SELECT * FROM fila_pedidos_vtex WHERE numero_pedido = '104604155863301'

SELECT * FROM fila_ocorrencias_pedido_vtex WHERE id_fila_pedido = 29582;

SELECT id_ocorrencia, id_romaneio, remetente_id FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 14341;

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp= 14341;

UPDATE scr_notas_fiscais_imp_ocorrencias SET id_ocorrencia_nf = id_ocorrencia_nf WHERE id_ocorrencia_nf = 18404;

SELECT * FROM 303
	
	DELETE FROM fila_ocorrencias_pedido_vtex WHERE id_ocorrencia_nf IS NULL
	SELECT * FROM fila_ocorrencias_pedido_vtex

	SELECT 
		id,
		id_fila_pedido,
		id_conhecimento_notas_fiscais,
		id_ocorrencia
		
	fila_ocorrencias_pedido_vtex
		
	DELETE FROM scr_nota
	SELECT * FROM cliente_parametros WHERE codigo_cliente = 32
	DELETE FROM fila_pedidos_vtex

	INSERT INTO fila_pedidos_vtex (numero_pedido, data_autorizacao, id_banco_dados)
	VALUES ('104170103948701','2020-06-22T18:20:25.0000000+00:00'::timestamp, 123)

	--DELETE FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 10697

	SELECT numero_pedido_nf, chave_nfe, numero_nota_fiscal FROM v_mgr_notas_fiscais WHERE id_nota_fiscal_imp = 10698
	SELECT * FROM scr_notas_fiscais_imp_log_atividades ORDER BY 1 DESC LIMIT 10
	
	SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 10

	SELECT codigo_cliente, nome_cliente FROM cliente WHERE cnpj_cpf = '05889907000177'
	BEGIN;
	INSERT INTO scr_doc_integracao (
		doc_xml,
		tipo_doc,
		codigo_empresa,
		codigo_filial
	) VALUES (
		'%s',
		14,
		'001',
		'001'
	);
	UPDATE fila_pedidos_vtex SET
		status = 1,
		data_processamento = now()
	WHERE id = %i
	COMMIT;
	
		

	SELECT 
		id,
		numero_pedido,
		data_autorizacao		
	FROM 
		fila_pedidos_vtex 
	WHERE 
		status = 0


	INSERT INTO fila_pedidos_vtex (
		numero_pedido,
		data_autorizacao,
		id_banco_dados
	) VALUES (
		'%s',
		'%s',
		%i
	)

SELECT 
	replace(
		to_char(COALESCE(
			max(data_autorizacao), 
			current_date::timestamp),
		'YYYY-MM-DD HH24:MI:SS'
		), ' ','T') 
	|| '.000Z TO ' 
	|| to_char((current_date + 1)::timestamp,'YYYY-MM-DD')
	|| 'T23:59:59.0000Z'
	as filtro_data
FROM 
	fila_pedidos_vtex 
WHERE 
	data_autorizacao::date = current_date

SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 20

DELETE FROM fila_pedidos_vtex;
UPDATE fila_pedidos_vtex SET status = 0
SELECT * FROM fila_pedidos_vtex ORDER BY data_autorizacao




*/