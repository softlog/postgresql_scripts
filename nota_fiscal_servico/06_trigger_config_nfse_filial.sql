CREATE OR REPLACE FUNCTION f_tgg_config_nfse()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_banco_dados integer;	
BEGIN

	SELECT id_string_conexao 
	INTO v_id_banco_dados
	FROM string_conexoes
	WHERE banco_dados = current_database();

	IF NEW.modulo_nfse = 1 AND NEW.habilitada_plugnotas = 0 THEN 
		INSERT INTO fila_nfse(tipo_servico, id_banco_dados, id_doc)
		VALUES (3,v_id_banco_dados, NEW.id_filial);
	END IF;        
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

--UPDATE filial SET habilitada_plugnotas = 0;
--SELECT * FROM scr_servicos

CREATE TRIGGER tgg_config_nfse
AFTER INSERT OR UPDATE 
ON filial
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_config_nfse();

--UPDATE filial SET modulo_nfse = 1 

--UPDATE filial SET certificado_id = 1

--SELECT * FROM filial

/*
WITH t AS (
        	SELECT
        		f.cnpj,
        		fpy_limpa_caracteres(f.razao_social) as razao_social,
        		trim(f.inscricao_estadual) as ie,
        		trim(f.inscricao_municipal) as im,
        		fpy_limpa_caracteres(f.nome_descritivo) as nome_fantasia,
        		CASE WHEN f.regime_tributario = 1
                    THEN true
                    ELSE false
                END::boolean as is_simples,
        		CASE 	WHEN f.regime_tributario = 1 THEN 1
        			WHEN f.regime_tributario = 2 THEN 3
        			WHEN f.regime_tributario = 3 THEN 4
        			ELSE 0
        		END::integer as regime_tributario,
        		0::integer as regime_tributario_especial,
        		fpy_limpa_caracteres(trim(f.endereco)) as endereco,
        		trim(f.numero) as numero,
        		''::text as complemento,
        		fpy_limpa_caracteres(trim(f.bairro)) as bairro,
        		cidades.cod_ibge as codigo_cidade,
        		cidades.uf,
        		f.cep,
        		f.ddd,
        		f.telefone as numero,
        		trim(f.email_principal) as email,
                empresa.id_empresa,
                CASE WHEN empresa.certificado IS NOT NULL THEN 1 ELSE 0 END::integer as cert_empresa,
        		COALESCE(f.certificado, empresa.certificado) as certificado,
                COALESCE(f.certificado_id, empresa.certificado_id) as certificado_id,
                COALESCE(trim(f.certificado_senha), trim(empresa.certificado_senha))
                    as certificado_senha,
                habilitada_plugnotas as cadastrado,
                trim(iss.serie) as serie,
                trim(iss.numero_doc) as numero_doc,
                trim(iss.lote) as lote,
                trim(iss.usuario) as usuario,
                trim(iss.senha) as senha,
                iss.incentivo_fiscal,
                iss.incentivo_cultural
        	FROM
        		filial f
        		LEFT JOIN cidades
        			ON cidades.id_cidade = f.id_cidade
        		LEFT JOIN empresa
        			ON empresa.codigo_empresa = f.codigo_empresa
                LEFT JOIN filial_parametros_iss iss
                    ON iss.id_cidade = f.id_cidade AND iss.id_filial = f.id_filial
        	WHERE f.id_filial = 27
        )
        SELECT row_to_json(t, true) as dados_empresa FROM t
*/