CREATE OR REPLACE VIEW public.v_cep_mapeamento_entregas_bairro AS 
 WITH t AS (
         SELECT cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            "left"(cli.cep::text, 5)::integer AS rad_cep,
            "right"(cli.cep::text, 3)::integer AS suf_cep,
            c.id_cidade,
            c.nome_cidade,
            c.cod_ibge
           FROM cliente cli
             LEFT JOIN cidades c ON c.id_cidade::numeric = cli.id_cidade
        )
 SELECT t.cnpj_cpf,
    t.nome_cliente,
    t.cep,
    t.rad_cep,
    t.suf_cep,
    t.id_cidade,
    t.nome_cidade,
    t.cod_ibge,
    f.id_bairro,
    f.bairro,
    f.id_regiao
   FROM t
     LEFT JOIN v_bairros_cep_em_regioes_cidades_faixa f ON t.cod_ibge = f.cod_ibge
  WHERE t.rad_cep >= f.cep_rad_ini AND t.suf_cep >= f.cep_suf_ini AND t.rad_cep <= f.cep_rad_fim AND t.suf_cep <= f.cep_suf_fim
  ORDER BY f.bairro;



  
CREATE OR REPLACE VIEW public.v_cliente_bairros_cep AS 
 WITH t AS (
         SELECT cli.codigo_cliente,
            cli.cnpj_cpf,
            cli.nome_cliente,
            cli.cep,
            0 AS rad_cep,
            0 AS suf_cep,
            c.id_cidade,
            c.nome_cidade,
            c.cod_ibge
           FROM cliente cli
             LEFT JOIN cidades c ON c.id_cidade = cli.id_cidade::integer
        )
 SELECT t.codigo_cliente,
    t.cnpj_cpf,
    t.nome_cliente,
    t.cep,
    t.rad_cep,
    t.suf_cep,
    t.id_cidade,
    t.nome_cidade,
    t.cod_ibge,
    f.id_bairro,
    f.bairro
   FROM t
     LEFT JOIN v_bairros_cep_faixa f ON t.cod_ibge = f.cod_ibge
  WHERE
        CASE
            WHEN t.rad_cep = f.fcb_rad_ini::integer THEN t.suf_cep >= f.fcb_suf_ini::integer
            ELSE t.rad_cep > f.fcb_rad_ini::integer
        END AND
        CASE
            WHEN t.rad_cep = f.fcb_rad_fim::integer THEN t.suf_cep <= f.fcb_suf_fim::integer
            ELSE t.rad_cep < f.fcb_rad_fim::integer
        END
  ORDER BY f.bairro;



CREATE OR REPLACE VIEW public.v_regiao_setores AS 
 WITH t AS (
         SELECT rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            rc.distancia_cidade_polo,
            rc.tempo_dias,
            rc.tempo_horas,
            rc.cidade_satelite,
            rc.interior_redespacho,
            rc.capital,
            rc.percurso_fluvial,
            r_1.hora_inicio_viagem
           FROM regiao_cidades rc
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rc.id_regiao
          WHERE r_1.tipo_regiao = 2
        UNION
         SELECT NULL::integer AS id_cidade,
            rb.id_bairro,
            rb.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            NULL::integer AS distancia_cidade_polo,
            NULL::integer AS tempo_dias,
            NULL::integer AS tempo_horas,
            NULL::integer AS cidade_satelite,
            NULL::integer AS interior_redespacho,
            NULL::integer AS capital,
            NULL::integer AS percurso_fluvial,
            r_1.hora_inicio_viagem
           FROM regiao_bairros rb
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rb.id_regiao
          WHERE 1 = 2
        )
 SELECT DISTINCT t.id_cidade,
    c.nome_cidade AS cidade,
    t.id_bairro,
    bc.bairro,
    t.id_setor,
    t.setor,
    t.tipo_composicao,
    t.id_cidade_polo,
    t.id_regiao,
    r.descricao AS regiao,
    r.id_cidade_polo AS id_cidade_polo_regiao,
    t.distancia_cidade_polo,
    t.tempo_dias,
    t.tempo_horas,
    t.cidade_satelite,
    t.interior_redespacho,
    t.capital,
    t.percurso_fluvial,
    t.hora_inicio_viagem
   FROM t
     LEFT JOIN regiao r ON r.id_regiao = t.id_regiao
     LEFT JOIN v_bairros_cep bc ON bc.id_bairro = t.id_bairro
     LEFT JOIN cidades c ON c.id_cidade = t.id_cidade;




CREATE OR REPLACE VIEW public.v_notas_para_entrega AS 
 WITH notas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.destinatario_id,
            c.nome_cliente AS destinatario_nome,
            c.cep AS destinatario_cep,
            c.endereco AS destinatario_endereco,
            c.numero AS destinatario_numero,
            c.bairro AS destinatario_bairro,
            cd.id_cidade AS id_destino,
            cd.nome_cidade AS destinatario_cidade,
            cd.uf AS destinatario_uf,
            cep.id_bairro,
            cep.bairro
           FROM scr_notas_fiscais_imp nf
             LEFT JOIN cliente c ON c.codigo_cliente = nf.destinatario_id
             LEFT JOIN cidades cd ON c.id_cidade::integer = cd.id_cidade
             LEFT JOIN v_cliente_bairros_cep cep ON cep.codigo_cliente = nf.destinatario_id
          WHERE nf.id_romaneio IS NULL
        ), rotas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            s.id_cidade,
            NULL::integer AS id_bairro,
            s.tipo_composicao,
            s.id_setor,
            s.id_cidade_polo,
            s.id_regiao,
            s.id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_setores s ON s.id_cidade = nf.id_destino
          WHERE s.id_setor IS NOT NULL
        UNION
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.id_destino AS id_cidade,
            s.id_bairro,
            s.tipo_composicao,
            s.id_setor,
            s.id_cidade_polo,
            s.id_regiao,
            s.id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_setores s ON s.id_bairro = nf.id_bairro
          WHERE s.id_setor IS NOT NULL
        )
 SELECT rotas.id_nota_fiscal_imp,
    rotas.numero_nota_fiscal,
    rotas.serie_nota_fiscal,
    rotas.id_cidade,
    rotas.id_bairro,
    rotas.tipo_composicao,
    rotas.id_setor,
    rotas.id_cidade_polo,
    rotas.id_regiao,
    rotas.id_cidade_polo_regiao
   FROM rotas;


 CREATE OR REPLACE VIEW public.v_cidades_para_entrega AS 
 SELECT regiao.id_cidade_polo AS id_cidade,
    cidades.nome_cidade,
    cidades.sigla_cidade,
    cidades.uf,
    regiao.id_regiao
   FROM regiao
     LEFT JOIN cidades ON cidades.id_cidade = regiao.id_cidade_polo
  WHERE regiao.tipo_regiao = 1 AND (EXISTS ( SELECT 1
           FROM v_notas_para_entrega
          WHERE v_notas_para_entrega.id_cidade_polo_regiao = regiao.id_cidade_polo));


CREATE OR REPLACE VIEW public.v_setor_para_entrega AS 
 SELECT regiao.id_regiao,
    regiao.descricao,
    regiao.id_cidade_polo,
    regiao.id_regiao_agrupadora
   FROM regiao
     RIGHT JOIN v_cidades_para_entrega ON v_cidades_para_entrega.id_regiao = regiao.id_regiao_agrupadora
  WHERE regiao.tipo_regiao = 2;



  
CREATE OR REPLACE VIEW public.v_regiao_setores2 AS 
 WITH t AS (
         SELECT rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            r_1.tipo_operacao
           FROM regiao_cidades rc
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rc.id_regiao
          WHERE r_1.tipo_regiao = 2
        UNION
         SELECT NULL::integer AS id_cidade,
            rb.id_bairro,
            rb.id_regiao AS id_setor,
            r_1.descricao AS setor,
            r_1.tipo_regiao,
            r_1.tipo_composicao,
            r_1.id_cidade_polo,
            r_1.id_regiao_agrupadora AS id_regiao,
            r_1.tipo_operacao
           FROM regiao_bairros rb
             LEFT JOIN regiao r_1 ON r_1.id_regiao = rb.id_regiao
          WHERE 1 = 2
        )
 SELECT DISTINCT t.id_cidade,
    c.nome_cidade AS cidade,
    t.id_bairro,
    bc.bairro,
    t.id_setor,
    t.setor,
    t.tipo_composicao,
    t.id_cidade_polo,
    t.id_regiao,
    r.descricao AS regiao,
    r.id_cidade_polo AS id_cidade_polo_regiao,
    t.tipo_operacao
   FROM t
     LEFT JOIN regiao r ON r.id_regiao = t.id_regiao
     LEFT JOIN v_bairros_cep bc ON bc.id_bairro = t.id_bairro
     LEFT JOIN cidades c ON c.id_cidade = t.id_cidade;




  
CREATE OR REPLACE VIEW public.v_notas_para_transferencia AS 
 WITH notas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            nf.destinatario_id,
            c.nome_cliente AS destinatario_nome,
            c.cep AS destinatario_cep,
            c.endereco AS destinatario_endereco,
            c.numero AS destinatario_numero,
            c.bairro AS destinatario_bairro,
            cd.id_cidade AS id_destino,
            cd.nome_cidade AS destinatario_cidade,
            cd.uf AS destinatario_uf,
            cep.id_bairro,
            cep.bairro
           FROM scr_notas_fiscais_imp nf
             LEFT JOIN cliente c ON c.codigo_cliente = nf.destinatario_id
             LEFT JOIN cidades cd ON c.id_cidade::integer = cd.id_cidade
             LEFT JOIN v_cliente_bairros_cep cep ON cep.codigo_cliente = nf.destinatario_id
          WHERE nf.id_romaneio IS NULL AND nf.id_ocorrencia = 0 AND nf.data_expedicao >= ('now'::text::date - 3)
        ), rotas AS (
         SELECT nf.id_nota_fiscal_imp,
            nf.numero_nota_fiscal,
            nf.serie_nota_fiscal,
            rc.id_cidade,
            NULL::integer AS id_bairro,
            rc.tipo_composicao,
            rc.id_setor,
            rc.id_cidade_polo,
            rc.id_regiao,
            r.id_cidade_polo AS id_cidade_polo_regiao
           FROM notas nf
             LEFT JOIN v_regiao_cidades rc ON rc.id_cidade = nf.id_destino
             LEFT JOIN regiao r ON r.id_regiao = rc.id_regiao
        )
 SELECT rotas.id_nota_fiscal_imp,
    rotas.numero_nota_fiscal,
    rotas.serie_nota_fiscal,
    rotas.id_cidade,
    rotas.id_bairro,
    rotas.tipo_composicao,
    rotas.id_setor,
    rotas.id_cidade_polo,
    rotas.id_regiao,
    rotas.id_cidade_polo_regiao
   FROM rotas;

