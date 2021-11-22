TRUNCATE qualocep_bairro;
TRUNCATE qualocep_cidade;
TRUNCATE qualocep_faixa_cidades;
TRUNCATE qualocep_faixa_bairros;
TRUNCATE qualocep_estado;

SELECT * FROM qualocep_faixa_cidades;
SELECT * FROM qualocep_faixa_bairros;

ALTER TABLE qualocep_faixa_cidades ADD COLUMN id integer;

CREATE OR REPLACE FUNCTION f_tgg_qualocep()
  RETURNS trigger AS
$BODY$
DECLARE
	v_existe integer;
BEGIN

	RETURN NEW;
	IF TG_TABLE_NAME = 'qualocep_bairro' THEN 
		SELECT count(*)
		INTO v_existe
		FROM qualocep_bairro 
		WHERE id_bairro = NEW.id_bairro;

		IF v_existe > 0 THEN 
			RETURN NEW;
		END IF;
	END IF;

	IF TG_TABLE_NAME = 'qualocep_cidade' THEN
		SELECT count(*)
		INTO v_existe
		FROM qualocep_cidade
		WHERE id_cidade = NEW.id_cidade;

		IF v_existe > 0 THEN 
			RETURN NEW;
		END IF ;
	END IF;


	IF TG_TABLE_NAME = 'qualocep_faixa_cidades' THEN
	
		SELECT count(*)
		INTO v_existe
		FROM qualocep_faixa_cidades
		WHERE id_cidade = NEW.id_cidade;

		IF v_existe > 0 THEN 
			RETURN NEW;
		END IF ;
	END IF;
	
	IF TG_TABLE_NAME = 'qualocep_faixa_bairros' THEN
		SELECT count(*)
		INTO v_existe
		FROM qualocep_faixa_cidades
		WHERE cep_inicial = NEW.cep_inicial AND cep_final = NEW.cep_final AND NEW.id_bairro = id_bairro;

		IF v_existe > 0 THEN 
			RETURN NEW;
		END IF;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE DROP TRIGGER tgg_qualocep_bairro ON qualocep_bairro
BEFORE INSERT 
ON qualocep_bairro
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_qualocep();

CREATE DROP TRIGGER tgg_qualocep_cidades ON qualocep_bairro
BEFORE INSERT 
ON qualocep_bairro
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_qualocep();

CREATE DROP TRIGGER tgg_qualocep_faixa_cidades ON qualocep_faixa_cidades
BEFORE INSERT 
ON qualocep_faixa_cidades
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_qualocep();

CREATE DROP TRIGGER tgg_qualocep_faixa_bairros ON qualocep_faixa_bairros
BEFORE INSERT 
ON qualocep_faixa_bairros
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_qualocep();
