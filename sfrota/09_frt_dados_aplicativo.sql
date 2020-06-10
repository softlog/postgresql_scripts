CREATE TABLE frt_dados_aplicativo 
(
	id serial NOT NULL,
	tipo_dados integer,
	dados_aplicativo text,
	id_operacao_diaria integer,
	status integer default 0,
	data_registro timestamp DEFAULT now(),
	CONSTRAINT frt_dados_aplicativo_id_pk PRIMARY KEY (id)
);

--ALTER TABLE frt_dados_aplicativo RENAME COLUMN id_atividade_diaria  TO id_operacao_diaria

--SELECT * FROM frt_dados_aplicativo



CREATE TRIGGER tgg_frt_dados_aplicativo 
BEFORE INSERT OR UPDATE OR DELETE
ON frt_dados_aplicativo
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_frt_dados_aplicativo();

/*

--TRUNCATE frt_operacao_diaria CASCADE
SELECT * FROM frt_operacao_diaria
SELECT * FROM frt_dados_aplicativo
UPDATE frt_dados_aplicativo SET id = id;

WITH t AS (
	SELECT '{"checklists":[{"codigo_empresa":"001","codigo_filial":"001","data_inicial":"2020-06-02","placa_veiculo":"TTT3187","inspecoes":[{"id_checklist":1,"id_check":65,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":66,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":67,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":68,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":69,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":70,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":71,"valor_positivo":true,"valor_negativo":false},{"id_checklist":1,"id_check":-1,"valor_positivo":false,"valor_negativo":true}]}]}'::json as dados
)
SELECT json_each(dados) FROM t

*/