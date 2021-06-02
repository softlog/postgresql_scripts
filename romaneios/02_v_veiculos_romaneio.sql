CREATE OR REPLACE VIEW public.v_veiculos_romaneio AS 
 SELECT veiculos.placa_veiculo,
    veiculos.id_proprietario,
    fornecedores.nome_razao AS nome_proprietario,
    fornecedores.cnpj_cpf,
    veiculos_tipos.numero_eixos,
        CASE
            WHEN veiculos_tipos.classificacao::integer = 3 THEN 1
            WHEN veiculos_tipos.classificacao::integer = 4 THEN 2
            WHEN veiculos_tipos.classificacao::integer = 5 THEN 3
            ELSE 0
        END AS classificacao,
    veiculos_tipos.capacidade_cubica,
    veiculos_tipos.capacidade_tonelada,
    veiculos_tipos.tipo_veiculo,
    veiculos.veiculo_proprio,
    v_tipo_carroceria.tipo_carroceria::character varying(15) AS tipo_carroceria,
    (((btrim(veiculos_marcas.nome_marca::text) || ' / '::text) || btrim(veiculos_modelos.descricao_modelo::text)))::character(40) AS modelo_veiculo,
    veiculos_tipos.comprimento,
    veiculos_tipos.largura,
    veiculos_tipos.altura,
    veiculos.tipo_frota,
    veiculos.odometro_atual
   FROM veiculos
     LEFT JOIN fornecedores ON fornecedores.id_fornecedor::numeric = veiculos.id_proprietario
     LEFT JOIN veiculos_tipos ON veiculos_tipos.id_tipo_veiculo::numeric = veiculos.id_tipo_veiculo
     LEFT JOIN v_tipo_carroceria ON veiculos_tipos.tp_carroceria = v_tipo_carroceria.codigo
     LEFT JOIN veiculos_marcas ON veiculos_marcas.id_marca_veiculo::numeric = veiculos_tipos.id_marca
     LEFT JOIN veiculos_modelos ON veiculos_modelos.id_modelo_veiculo::numeric = veiculos_tipos.id_modelo;

