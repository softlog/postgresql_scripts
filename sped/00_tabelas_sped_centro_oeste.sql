--DROP TABLE efd_fiscal_bloco_ecf;
CREATE TABLE efd_fiscal_bloco_ecf
(
	id serial NOT NULL,
	cnpj character(14),
	periodo character(8),
	bloco text,
	lista_produtos text,
	lista_unidades text,
	qt_linhas integer,
	bloco_9 text,
	CONSTRAINT efd_fiscal_bloco_ecf_id_pk 
	PRIMARY KEY (id)
);

--DROP TABLE efd_fiscal_produtos_ecf --efd_fiscal_produtos_ecf
--SELECT * FROM efd_fiscal_produtos_ecf
--UPDATE efd_fiscal_produtos_ecf SET id_produto_softlog = 3
CREATE TABLE efd_fiscal_produtos_ecf
(
	id serial NOT NULL,
	codigo_produto character(10),
	descricao_produto character(60),
	id_produto_softlog integer,
	CONSTRAINT efd_fiscal_produtos_ecf_id_pk 
	PRIMARY KEY (id)
);


CREATE OR REPLACE FUNCTION f_insere_itens_ecf(codigo text, descricao text)
  RETURNS integer AS
$BODY$
DECLARE
        v_codigo integer;        
BEGIN

	SELECT codigo_produto 
	INTO v_codigo 
	FROM efd_fiscal_produtos_ecf 
	WHERE trim(codigo_produto) = trim(codigo);

        IF v_codigo IS NULL THEN 
		INSERT INTO efd_fiscal_produtos_ecf (codigo_produto,descricao_produto)
		VALUES (codigo, descricao);
        END IF;
        
	RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
