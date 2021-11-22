BEGIN;

SELECT * FROM fd_drop_visoes_dependentes('log_faixa_bairro');

DROP FOREIGN TABLE log_faixa_bairro;
CREATE TABLE public.log_faixa_bairro
(
    id serial,
    bai_nu_sequencial integer NOT NULL,
    fcb_nu_ordem integer NOT NULL,
    fcb_rad_ini character varying(5) NOT NULL,
    fcb_suf_ini character varying(3) NOT NULL,
    fcb_rad_fim character varying(5) NOT NULL,
    fcb_suf_fim character varying(3) NOT NULL,
    fcb_faixa int4range ,
    CONSTRAINT ind_log_faixa_bairro PRIMARY KEY (id)
);


DROP FOREIGN TABLE v_bairros_cep CASCADE;
--TRUNCATE v_bairros_cep
CREATE TABLE public.v_bairros_cep
   (id serial,
   id_bairro integer ,
    uf character(2) ,
    id_cidade integer ,
    bairro text ,
    bai_no_abrev character(36) ,
    cod_ibge character(7),
    CONSTRAINT ind_b_bairros_cep_pk PRIMARY KEY (id));

ALTER TABLE v_bairros_cep ADD COLUMN faixas_cep text;

TRUNCATE v_bairros_cep;
INSERT INTO v_bairros_cep (id_bairro, uf, id_cidade, bairro, bai_no_abrev, cod_ibge, faixas_cep)
SELECT 
	b.id_bairro,
	c.uf,
	b.id_cidade,
	UPPER(retira_acento(bairro)) as bairro,
	null,
	c.cod_ibge,
	string_agg(cep_inicial || '-' || cep_final,',')
FROM 
	qualocep_bairro b
	LEFT JOIN qualocep_cidade c
		ON c.id_cidade = b.id_cidade
	LEFT JOIN qualocep_faixa_bairros l
		ON l.id_bairro = b.id_bairro
GROUP BY 
	b.id_bairro,
	c.uf,
	b.id_cidade,
	b.bairro,
	c.cod_ibge;

	--SELECT * FROM qualocep_cidade

--TRUNCATE log_faixa_bairro;
TRUNCATE log_faixa_bairro;
INSERT INTO log_faixa_bairro (bai_nu_sequencial, fcb_nu_ordem, fcb_rad_ini, fcb_suf_ini, fcb_rad_fim, fcb_suf_fim, fcb_faixa)
SELECT 
 id_bairro,
 row_number() over (partition by id_bairro) as ordem,
 left(cep_inicial,5) as fcb_rad_ini,
 right(cep_inicial,3) as fcb_suf_ini,
 left(cep_final,5) as fcb_rad_fim,
 right(cep_final,3) as fcb_suf_fim,
 int4range(cep_inicial::integer, cep_final::integer +1 ) as faixa
FROM qualocep_faixa_bairros
ORDER BY id_bairro, cep_inicial;


--Código que altera ou recria a visão

SELECT * FROM fd_restaura_visoes_dependentes('log_faixa_bairro');

COMMIT;




/*
1231
SELECT * FROM log_faixa_bairro
SELECT * FROM v_bairros_cep_faixa WHERE id_bairro = 2222
SELECT * FROM v_bairros_cep WHERE id_bairro = 2222
SELECT * FROM v_bairros_cep_em_regioes_cidades_faixa WHERE id_bairro = 1231
BEGIN;
DELETE FROM regiao WHERE id_regiao = 11;
COMMIT;
SELECT * FROM log_faixa_bairro WHERE bai_nu_sequencial = 2222

			SELECT 	bai_nu_sequencial, *
			
			FROM 	log_faixa_bairro 
			WHERE 
				72549500::integer <@ fcb_faixa;

SELECT * FROM 

SELECT * FROM qualocep_faixa_bairros WHERE id_bairro = 2222

--SELECT * FROM qualocep_faixa_cidades
*/