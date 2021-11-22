-- View: public.v_regiao_cidades

-- DROP VIEW public.v_regiao_cidades;

CREATE OR REPLACE VIEW public.v_regiao_cidades AS 
 SELECT rc.id_regiao_cidades,
    COALESCE(r.id_regiao_agrupadora, rc.id_regiao) AS id_regiao,
    rc.id_cidade,
    rc.distancia_cidade_polo,
    rc.tempo_dias,
    rc.tempo_horas,
    rc.cidade_satelite,
    rc.interior_redespacho,
    rc.capital,
    rc.percurso_fluvial,
    r.id_cidade_polo,
    r.tipo_composicao,
    r.id_regiao AS id_setor,
    r.descricao AS regiao,
    r.descricao AS setor,
    NULL::character(50) AS bairro,
    rc.faixa_cep_ini,
    rc.faixa_cep_fim
FROM regiao_cidades rc
     LEFT JOIN regiao r ON r.id_regiao = rc.id_regiao;


