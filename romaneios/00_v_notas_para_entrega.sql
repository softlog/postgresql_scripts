-- View: public.v_notas_para_entrega

-- DROP VIEW public.v_notas_para_entrega;

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

/*
--SELECT * FROM v_notas_para_entrega

SELECT * FROM v_cliente_bairros_cep
*/
