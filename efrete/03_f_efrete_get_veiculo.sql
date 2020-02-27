--SELECT * FROM f_efrete_get_veiculo('MMB6679');
CREATE OR REPLACE FUNCTION f_efrete_get_veiculo(p_placa_veiculo character(8))
  RETURNS json AS
$BODY$
DECLARE
        retorno json;
BEGIN

	WITH t AS (
		SELECT 			
			TRIM(v.placa_veiculo) as placa,
			v.rntrc as rntrc,
			v.validade_rntrc,
			v.ano_fabricacao_veiculo::integer as ano_fabricacao,
			v.ano_modelo_veiculo as ano_modelo,
			v.capacidade_tonelada as capacidade_kg,
			v.capacidade_cubica as capacidade_m3,
			trim(v.nrchassis) as chassi,
			cv.cod_ibge as codigo_municipio,
			trim(v.cor_veiculo) as cor,
			trim(vm.nome_marca) as marca,
			trim(vmod.descricao_modelo) as modelo,
			v.numero_eixos::integer as numero_de_eixos,
			trim(v.renavan) as renavam,
			v.veic_tara as tara,
			CASE 
				WHEN v.tp_carroceria IN (1,5,6,10) THEN 'Aberta'
				WHEN v.tp_carroceria IN (2) THEN 'Granelera'
				WHEN v.tp_carroceria IN (3, 4, 7, 8, 9) THEN 'FechadaOuBau'
				WHEN v.tp_carroceria IN (4) THEN 'FechadaOuBau'
				WHEN v.tp_carroceria IN (11, 12, 13, 14, 15) THEN 'NaoAplicavel'
			END::text as tipo_carroceria,

			CASE 
				WHEN v.tracionado = 1 THEN 'Cavalo'			
				WHEN v.porte IN (7)   THEN 'Toco'
				WHEN v.porte IN (8)   THEN 'Truck'
						      ELSE 'NaoAplicavel'
			END::text as TipoRodado			
		FROM 
			veiculos v
			LEFT JOIN cidades cv
				ON cv.id_cidade = v.id_cidade_veiculo
			LEFT JOIN veiculos_marcas vm
				ON vm.id_marca_veiculo = v.id_marca
			LEFT JOIN veiculos_modelos vmod
				ON vmod.id_modelo_veiculo = v.id_modelo
			LEFT JOIN v_tipo_carroceria vtc
				ON vtc.codigo = v.tp_carroceria
			LEFT JOIN v_porte_veiculo vpv 
				ON vpv.codigo = v.porte
		WHERE 
			--v.placa_veiculo = 'MMB6679'
			v.placa_veiculo = p_placa_veiculo			

	)
	SELECT row_to_json(t, true) INTO retorno FROM t;
	
        
	RETURN retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT * FROM f_efrete_get_motorista(4886)


--SELECT * FROM crm_contatos_detalhes
 