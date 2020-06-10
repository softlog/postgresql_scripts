    WITH filiais_aux AS (

	    SELECT 
		    id_filial,
		    trim(razao_social) as razao_social,
		    trim(nome_descritivo) as descritivo,
		    codigo_filial,
		    codigo_empresa,
		    id_cidade
	    FROM 
		    filial
	    WHERE 
		    codigo_filial = '001'
		    AND codigo_empresa = '001'
	    ORDER BY 1
    )
    , motoristas_aux AS (
		SELECT 
				trim(fornecedores.cnpj_cpf) as cnpj_cpf, 
				fornecedores.id_fornecedor, 
				trim(fornecedores.nome_razao) as nome_motorista, 
				trim(fornecedores.iest) as inscricao_estadual, 
				0::integer as id_endereco,
				trim(fornecedores.endereco) as endereco, 
				trim(fornecedores.numero) as numero, 
				trim(fornecedores.bairro) as bairro, 
				trim(fornecedores.cep) as cep, 
				trim(nome_cidade) as cidade,
				trim(cidades.uf) as estado, 
				trim(cidades.codigo_pais) as codigo_pais,
				trim(fornecedores.ddd) as ddd, 
				trim(fornecedores.telefone1) as telefone, 
				fornecedores.id_cidade,
				'001'::character(3) as codigo_filial,
				'001'::character(3) as codigo_empresa
			FROM 
				fornecedores
				LEFT JOIN cidades ON cidades.id_cidade =  fornecedores.id_cidade
			WHERE
				tipo_motorista = 1
			ORDER BY 
				fornecedores.nome_razao
		
    )
    , cidades_aux AS (
	   SELECT 
		    cidades.id_cidade, 
		    trim(cidades.nome_cidade) as nome_cidade, 
		    cidades.uf, 
		    COALESCE(cidades.cod_ibge,'') as cod_ibge,
                    COALESCE(cidades.lat,0.00) as latitude,
                    COALESCE(cidades.lng,0.00) as longitude	    
            FROM 
		    filiais_aux
		    LEFT JOIN cidades
			ON cidades.id_cidade = filiais_aux.id_cidade
	    UNION ALL
	    SELECT 
		    cidades.id_cidade, 
		    trim(cidades.nome_cidade) as nome_cidade, 
		    cidades.uf, 
		    COALESCE(cidades.cod_ibge,'') as cod_ibge,
                    COALESCE(cidades.lat,0.00) as latitude,
                    COALESCE(cidades.lng,0.00) as longitude
	    FROM 
		motoristas_aux 
		LEFT JOIN cidades
		    ON cidades.id_cidade = motoristas_aux.id_cidade	    
	    ORDER BY 1

    )
    , veiculos_aux AS (
		SELECT 
			trim(placa_veiculo) as placa_veiculo, 
			(COALESCE(trim(nome_marca),'') || ' - ' || COALESCE(trim(descricao_modelo),'')) as descricao,
			'001'::character(3) as codigo_filial,
			'001'::character(3) as codigo_empresa,
			chk_km,
			chk_hr
			id_motorista
		FROM 
			v_veiculos
		ORDER BY 
			placa_veiculo
    )
    , filiais AS (
	WITH temp AS (
		SELECT row_to_json(filiais_aux,true) as filiais FROM filiais_aux
	)
	SELECT array_agg(temp.filiais) as filiais FROM temp		
    )
    , cidades AS (
	WITH temp AS (
		SELECT row_to_json(cidades_aux, true) as  cidades FROM cidades_aux
	) 
	SELECT array_agg(temp.cidades) as cidades FROM temp
    )
    , motoristas AS (
	WITH temp AS (
		SELECT row_to_json(motoristas_aux, true) as  motoristas FROM motoristas_aux
	) 
	SELECT array_agg(temp.motoristas) as motoristas FROM temp
    )
    , veiculos AS (
	WITH temp AS (
		SELECT row_to_json(veiculos_aux, true) as  veiculos FROM veiculos_aux
	) 
	SELECT array_agg(temp.veiculos) as veiculos FROM temp
    )
     SELECT row_to_json(row) as dados FROM (
	    SELECT
		    filiais.filiais,
		    cidades.cidades,
		    motoristas.motoristas,
		    veiculos.veiculos			            
	    FROM
		filiais,
		cidades,
		motoristas,
		veiculos
    ) row
    

/*

SELECT * FROM veiculos LIMIT 100


SELECT row_to_json(t,true) as filial FROM t

*/

