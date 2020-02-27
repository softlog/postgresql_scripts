CREATE OR REPLACE FUNCTION f_efrete_get_proprietario(p_id integer)
  RETURNS json AS
$BODY$
DECLARE
        retorno json;
BEGIN

	WITH t AS (
		SELECT 
			trim(prop.cnpj_cpf) as cnpj,
			CASE WHEN char_length(trim(prop.cnpj_cpf)) = 11 THEN 'Fisica' ELSE 'Juridica' END::text as tipo_pessoa,
			trim(prop.nome_razao) as razao_social,							
			trim(prop.bairro) as bairro,
			trim(prop.endereco) as rua_proprietario,
			''::text as complemento_proprietario,
			trim(COALESCE(prop.numero,'0')) as numero,
			62::integer as ddd,
			'981671973'::text as numero_celular,
			trim(prop.cep) as cep,
			cp.cod_ibge as codigo_municipio,
			'TAC'::text as tipo_tranportador,
			TRIM(veiculos.rntrc) as rntrc			
		FROM 
			fornecedores prop				
			LEFT JOIN cidades cp
				ON cp.id_cidade = prop.id_cidade	
			LEFT JOIN veiculos
				ON veiculos.id_proprietario = prop.id_fornecedor

				
			
		WHERE 
			id_fornecedor  = 4886
	)
	SELECT row_to_json(t, true) INTO retorno FROM t;
	
        
	RETURN retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT * FROM f_efrete_get_proprietario(4886)


--SELECT * FROM crm_contatos_detalhes
 