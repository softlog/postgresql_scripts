CREATE OR REPLACE FUNCTION f_efrete_get_motorista(p_id_motorista integer)
  RETURNS json AS
$BODY$
DECLARE
        retorno json;
BEGIN

	WITH t AS (
		SELECT 				
			trim(mot.cnpj_cpf) as cpf,
			trim(mot.nome_razao) as nome,
			trim(mot.mot_registro) as cnh,		
			trim(mot.mae) as mae,
			trim(mot.bairro) as bairro,
			trim(mot.endereco) as rua,
			''::text as complemento_motorista,
			trim(COALESCE(mot.numero,'0')) as numero,
			mot.nascimento as data_nascimento,
			62::integer as ddd,
			''::text as numero_celular,
			trim(mot.cep) as cep,
			cm.cod_ibge as codigo_municipio,
			fones.*
		FROM 		
			fornecedores mot		
			LEFT JOIN cidades cm
				ON cm.id_cidade = mot.id_cidade
			LEFT JOIN crm_contatos cont
				ON cont.cnpj_cpf = mot.cnpj_cpf
			LEFT JOIN crm_contatos_detalhes fones
				ON fones.id_contato = cont.id_contato
					AND tp_detalhe = 'Celular'
		WHERE 
			--id_fornecedor = p_id_motorista
			id_fornecedor  = 4886
	)
	SELECT row_to_json(t, true) INTO retorno FROM t;
	
        
	RETURN retorno;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--SELECT * FROM f_efrete_get_motorista(4886)


--SELECT * FROM crm_contatos_detalhes
 