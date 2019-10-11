DROP TABLE log_faixa_bairro CASCADE;
CREATE TABLE public.log_faixa_bairro

   (id serial,
    bai_nu_sequencial integer NOT NULL,
    fcb_nu_ordem integer NOT NULL,
    fcb_rad_ini character varying(5) NOT NULL,
    fcb_suf_ini character varying(3) NOT NULL,
    fcb_rad_fim character varying(5) NOT NULL,
    fcb_suf_fim character varying(3) NOT NULL,
    fcb_faixa int4range ,
    CONSTRAINT ind_log_faixa_bairro PRIMARY KEY (id)
    );


DROP TABLE v_bairros_cep CASCADE;
--TRUNCATE v_bairros_cep
CREATE TABLE public.v_bairros_cep
   (id serial,
   id_bairro integer ,
    uf character(2) ,
    id_cidade integer ,
    bairro text ,
    bai_no_abrev character(36) ,
    cod_ibge character(7),
    CONSTRAINT ind_b_bairros_cep_pk PRIMARY KEY (id) );

ALTER TABLE v_bairros_cep ADD COLUMN faixas_cep text;


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




CREATE OR REPLACE VIEW public.v_bairros_cep_faixa AS 
 SELECT b.id_bairro AS id_bairro,
    b.uf,
    b.bairro,
    b.bai_no_abrev,
    f.fcb_nu_ordem AS id_faixa_bairro,
    f.fcb_rad_ini,
    f.fcb_suf_ini,
    f.fcb_rad_fim,
    f.fcb_suf_fim,
    b.id_cidade as loc_nu_sequencial,
    upper(fc.cidade::text) AS localidade,
    fc.cod_ibge,
    fc.cidade as loc_no,
    fc.cep,
    1::integer as loc_in_situacao,
    'M'::text as loc_in_tipo_localidade,
    fc.id_cidade as loc_nu_sequencial_sub,
    null::text as loc_rad1_ini,
    null::text as loc_suf1_ini,
    null::text as loc_rad1_fim,
    null::text as loc_suf1_fim,
    null::text as loc_rad2_ini,
    null::text as loc_suf2_ini,
    null::text as loc_rad2_fim,
    null::text as loc_suf2_fim,
    f.fcb_faixa
   FROM v_bairros_cep b
     LEFT JOIN log_faixa_bairro f ON b.id_bairro = f.bai_nu_sequencial
   LEFT JOIN qualocep_cidade fc
		ON fc.id_cidade = b.id_cidade
     LEFT JOIN qualocep_faixa_cidades i
	ON i.id_cidade = fc.id_cidade;


--SELECT * FROm v_bairros_cep_faixa 

CREATE OR REPLACE VIEW public.v_bairros_cep_em_regioes_cidades AS 
 SELECT cep.id_bairro,
    cep.uf,
    cep.id_cidade AS id_cidade_cep,
    cep.bairro::character(250) AS bairro,
    cep.cod_ibge,
    c.nome_cidade,
    r.id_regiao,
    r.descricao AS regiao
   FROM v_bairros_cep cep
     LEFT JOIN cidades c ON c.cod_ibge = cep.cod_ibge
     LEFT JOIN regiao_cidades rc ON rc.id_cidade = c.id_cidade
     LEFT JOIN regiao r ON rc.id_regiao = r.id_regiao
  WHERE r.tipo_regiao = 1;


CREATE OR REPLACE VIEW public.v_bairros_cep_em_regioes_cidades_faixa AS 
 SELECT t1.id_bairro,
    t1.uf,
    t1.nome_cidade,
    t1.id_cidade_cep,
    t1.cod_ibge,
    t1.bairro,
    t1.id_regiao,
    t1.regiao,
    t2.*,
    t2.fcb_rad_ini::integer AS cep_rad_ini,
    t2.fcb_suf_ini::integer AS cep_suf_ini,
    t2.fcb_rad_fim::integer AS cep_rad_fim,
    t2.fcb_suf_fim::integer AS cep_suf_fim
   FROM v_bairros_cep_em_regioes_cidades t1
     LEFT JOIN v_bairros_cep_faixa t2 ON t1.id_bairro = t2.id_bairro;

/*
1231
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