CREATE OR REPLACE VIEW public.v_regiao_bairros AS 
 SELECT rc.id_regiao_bairro,
    COALESCE(r.id_regiao_agrupadora, rc.id_regiao) AS id_regiao,
    rc.id_bairro,    
    rc.tempo_dias,
    rc.tempo_horas,        
    r.id_cidade_polo,
    r.tipo_composicao,
    r.id_regiao AS id_setor,
    r.descricao AS regiao,
    r.descricao AS setor,
    NULL::character(50) AS bairro
FROM regiao_bairros rc
     LEFT JOIN regiao r ON r.id_regiao = rc.id_regiao;



--SELECT * FROM regiao