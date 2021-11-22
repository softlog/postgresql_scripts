--- Frete Combinado
--DELETE FROM scr_tabelas WHERE RIGHT(numero_tabela_frete,10) = '9999999999';

--- Para cada empresa, uma tabela frete combinado
--SELECT max(id_origem_destino) FROM scr_tabelas_origem_destino;


--ALTER SEQUENCE scr_tabelas_id_tabela_frete_seq RESTART WITH 1408;
--SELECT * FROM scr_tabelas ORDER BY 1
--ALTER SEQUENCE scr_tabelas_origem_destino_id_origem_destino_seq RESTART WITH 3274;
--SELECT f_criacao_tabela_combinada('001')

CREATE OR REPLACE FUNCTION f_criacao_tabela_combinada(pCodEmpresa text)
  RETURNS boolean AS
$BODY$
DECLARE
	vIdTabelaFrete 		integer;
	vIdOrigemDestino	integer;
	vCf			integer;
	vExiste			integer;
	
BEGIN
	--Verifica se existe tabela combinada para a empresa
	SELECT 	count(*) 
	INTO 	vExiste
	FROM 	scr_tabelas
	WHERE 	numero_tabela_Frete = pCodEmpresa || '9999999999';

	IF vExiste > 0 THEN 
		RETURN false;		
	END IF;
	
 	--Grava dados na tabela scr_tabelas; 	
	WITH tbl AS (
		INSERT INTO scr_tabelas(
			numero_tabela_frete, 
			descricao_tabela,
			vigencia_tabela,
			aplicacao_tabela,
			combinado, 
			ativa) 
		VALUES 
			(
			pCodEmpresa || '9999999999',
			'FRETE COMBINADO',
			current_date,
			current_date,
			1,
			1) 
		RETURNING id_tabela_frete
	) 
	SELECT id_tabela_frete INTO vIdTabelaFrete FROM tbl;

	--SELECT * FROM vIdTabelaFrete;

	WITH tbl AS ( 	
		INSERT INTO scr_tabelas_origem_destino(
		    tipo_rota, 
		    id_tabela_frete            
		    )
		VALUES (
			3,
			vIdTabelaFrete
		)
		RETURNING id_origem_destino
	)
	SELECT id_origem_destino INTO vIdOrigemDestino FROM tbl;


	INSERT INTO scr_tabelas_cf(
		id_origem_destino, 
		id_tipo_calculo
	)
	SELECT 
		vIdOrigemDestino, 
		id_tipo_calculo 
	FROM 
		scr_tabelas_tipo_calculo
	WHERE  
		id_tipo_calculo IN (1,2,16,17,18,5,15);


	RETURN true;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

-- Faz o lançamento das tabelas combinadas em cada empresa

-- Trigger e Função para lançar tabela combinada quando a empresa for criada

CREATE OR REPLACE FUNCTION f_tgg_lanca_tabela_combinada()
  RETURNS trigger AS
$BODY$
DECLARE
	vResultado boolean;
	vOperacao text;
BEGIN
 	--Grava dados na tabela scr_tabelas;
	--Verifica se tem alguma operação realizada no form de digitação do conhecimento


	PERFORM f_criacao_tabela_combinada(NEW.codigo_empresa);

	RETURN NULL;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



