-- View: public.v_bairros_cep_em_regioes_cidades

--DROP VIEW public.v_bairros_cep_em_regioes_cidades;
--SELECT * FROM v_bairros_cep_em_regioes_cidades

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
WHERE r.tipo_regiao = 1
UNION 
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
     LEFT JOIN regiao r ON r.id_cidade_polo = c.id_cidade
WHERE r.tipo_regiao = 1;

