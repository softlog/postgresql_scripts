CREATE OR REPLACE FUNCTION public.f_insere_cliente(dadosCliente json)
  RETURNS integer AS
$BODY$
DECLARE
	p_cnpj_cpf text;
	p_nome_cliente text;
	p_ie text;
	p_lgr text; 
	p_nro text; 
	p_bairro text;
	p_cod_mun text; 
	p_cidade text;
	p_uf text;
	p_cep text; 
	p_fone text; 
	p_email text; 
	p_percentual_devolucao numeric;
	p_percentual_reentrega numeric; 
	p_forma_pagamento text;
	p_prazo_pagamento integer;
	p_imposto_por_conta_cliente integer;
	p_tipo_frete_padrao text; 
	p_frequencia_faturamento text;
	
	vIdCidade integer;
	vUf character(2);
	vDDD character(2);
	vTipoCliente integer;
	vClassificacaoFiscal character(30);

	vCodigoCliente integer;
	
	vCursor refcursor;
	vExiste integer;

	vEmpresa text;
	vFilial text;
	
BEGIN	
	
	--Deserializa os dados de json
	p_cnpj_cpf 			= dadosCliente->>'part_cnpj_cpf';
	p_nome_cliente 			= UPPER(fpy_limpa_caracteres(retira_acento(dadosCliente->>'part_nome')));
	p_ie 				= dadosCliente->>'part_ie';
	p_lgr 				= UPPER(fpy_limpa_caracteres(retira_acento(dadosCliente->>'part_logradouro'))); 
	p_nro 				= UPPER(fpy_limpa_caracteres(retira_acento(dadosCliente->>'part_numero'))); 
	p_bairro 			= UPPER(fpy_limpa_caracteres(retira_acento(dadosCliente->>'part_bairro')));
	p_cod_mun 			= dadosCliente->>'part_cod_mun';
	p_cidade			= UPPER(fpy_limpa_caracteres(retira_acento(dadosCliente->>'part_cidade')));
	p_uf 				= UPPER(dadosCliente->>'part_uf');
	p_cep 				= dadosCliente->>'part_cep';
	p_fone 				= dadosCliente->>'part_fone';
	p_fone				= COALESCE(right(p_fone,8),'');
	p_email 			= dadosCliente->>'part_email';
	p_percentual_devolucao 		= ((dadosCliente->>'percentual_devolucao')::Text)::numeric(12,2);
	p_percentual_reentrega 		= ((dadosCliente->>'percentual_reentrega')::Text)::numeric(12,2);
	p_forma_pagamento 		= dadosCliente->>'forma_pagamento';
	p_prazo_pagamento 		= ((dadosCliente->>'prazo_pagamento')::Text)::integer;
	p_imposto_por_conta_cliente 	= ((dadosCliente->>'imposto_cliente')::Text)::integer;
	p_tipo_frete_padrao 		= dadosCliente->>'frete_padrao';
	p_frequencia_faturamento 	= dadosCliente->>'frequencia_faturamento';


	IF trim(p_cod_mun) = '' THEN		
		p_cod_mun = NULL;
	END IF;

	vEmpresa 	= fp_get_session('pst_cod_empresa');
	vFilial  	= fp_get_session('pst_filial');
	
	--Percentual Devolucao
	IF p_percentual_devolucao IS NULL THEN 	
		SELECT valor_parametro::numeric
		INTO p_percentual_devolucao
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_PERCENTUAL_DEVOLUCAO';
	END IF; 


	--Percentual Reentrega
	IF p_percentual_reentrega IS NULL THEN 	
		SELECT replace(valor_parametro,',','.')::numeric
		INTO p_percentual_reentrega
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_PERCENTUAL_REENTREGA';
	END IF;


	--FORMA PAGAMENTO
	IF p_forma_pagamento IS NULL THEN 	
		SELECT valor_parametro::text
		INTO p_forma_pagamento
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_FORMA_PAGAMENTO';
	END IF;

	--Prazo Pagamento
	IF p_prazo_pagamento IS NULL THEN 	
		SELECT valor_parametro::integer
		INTO p_prazo_pagamento
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_PRAZO_PAGAMENTO';
	END IF;

	--Imposto por conta cliente
	IF p_imposto_por_conta_cliente IS NULL THEN 	
		SELECT valor_parametro
		INTO p_imposto_por_conta_cliente
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_IMPOSTO_POR_CONTA_CLIENTE';
	END IF;

	--Tipo Frete Padrao
	IF p_tipo_frete_padrao IS NULL THEN 	
		SELECT valor_parametro
		INTO p_tipo_frete_padrao
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_TIPO_FRETE_PADRAO';
	END IF;

	--Frequencia Faturamento
	IF p_frequencia_faturamento IS NULL THEN 	
		SELECT valor_parametro
		INTO p_frequencia_faturamento
		FROM parametros 
		WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_FREQUENCIA_FATURAMENTO';
	END IF;
	
	-- Verifica se o cliente ja existe
	vCodigoCliente = 0;
	OPEN vCursor FOR 
			SELECT count(*)
			FROM cliente
			WHERE cnpj_cpf = p_cnpj_cpf;
		
	

	FETCH vCursor INTO vExiste;

	CLOSE vCursor;


	IF (vExiste = 0) THEN 		

		
		IF p_cod_mun IS NOT NULL THEN 
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE trim(cod_ibge) = trim(p_cod_mun);
		ELSE 
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE trim(nome_cidade) = trim(p_cidade) AND uf = trim(p_uf);
		END IF;

		FETCH vCursor INTO vIdCidade, vUf, vDDD;

		CLOSE vCursor;


		-- Se a cidade nao foi encontrada, utiliza uma busca por distancia de edicao
		IF vIdCidade IS NULL THEN 

			WITH t AS (
				SELECT id_cidade, uf, ddd_padrao, levenshtein(trim(nome_cidade), upper(trim(p_cidade))) as lev
				FROM  cidades
				WHERE levenshtein(trim(nome_cidade), upper(trim(p_cidade))) < 4
					AND uf = trim(p_uf) AND cod_ibge IS NOT NULL
			) 
			SELECT id_cidade, uf, ddd_padrao 
			INTO vIdCidade, vUf, vDDD
			FROM t
			ORDER BY lev LIMIT 1;

		END IF;


		-- Se a cidade nao foi encontrada, usa codigo de cidade desconhecida no sistema
		IF vIdCidade IS NULL THEN 
		
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE id_cidade = 0;

			FETCH vCursor INTO vIdCidade, vUf, vDDD;

			CLOSE vCursor;

		END IF;

		
		--Com o codigo da cidade fazer inclusao na tabela de cliente
		IF vIdCidade IS NOT NULL THEN 
			
			--PERFORM f_debug('Debug ','Linha 63');

			IF p_fone = '' THEN 
				vDDD = '';
			END IF;

						
			IF fd_valida_cnpj_cpf(right(trim(p_cnpj_cpf),11)) = 1  AND fd_valida_cnpj_cpf(right(trim(p_cnpj_cpf),14)) = 0 THEN 
				p_cnpj_cpf = right(trim(p_cnpj_cpf),11);
			END IF;
			
			IF char_length(trim(p_cnpj_cpf)) = 11 THEN
				vTipoCliente = 2;
				vClassificacaoFiscal = 'NAO CONTRIBUINT';			
			ELSE
				vTipoCliente = 1;
				vClassificacaoFiscal = 'COMERCIO';
			END IF;
			
	
			OPEN vCursor FOR
			INSERT INTO cliente (
						cnpj_cpf, --1
						nome_cliente, --2
						nome_fantasia, --3 
						inscricao_estadual, --4
						ddd, --5
						telefone, --6
						cnpj_cpf_responsavel, --7
						endereco, --8
						numero, --9
						bairro, --10
						cep, --11
						id_cidade, --12
						tipo_cliente, -- 13
						classificacao_fiscal, --14
						natureza_da_carga, --15
						formas_pgto, --16
						frequencia_faturamento, --17
						prazo_pagamento, --18
						frete, --19
						contato, --20
						ddd_cliente, --21
						fone_contato, --22
						percentual_devolucao, --23
						percentual_reentrega, --24
						email		--25
					     )
				VALUES (  
						trim(p_cnpj_cpf), --1
						fpy_limpa_caracteres(upper(left(p_nome_cliente,50))), --2
						fpy_limpa_caracteres(upper(left(p_nome_cliente,50))), --3
						upper(COALESCE(left(p_ie,18),'')), --4
						COALESCE(vDDD,''), --5
						COALESCE(p_fone,''), --6
						trim(p_cnpj_cpf), --7
						fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),''))), --8
						COALESCE(LEFT(p_nro,6),''), --9
						fpy_limpa_caracteres(upper(COALESCE(LEFT(p_bairro,30),''))), --10
						COALESCE(trim(p_cep),''), --11
						vIdCidade, --12
						vTipoCliente, --13
						vClassificacaoFiscal, --14
						'DIVERSOS', --15
						trim(p_forma_pagamento), --16
						trim(p_frequencia_faturamento), --17
						p_prazo_pagamento, --18
						trim(p_tipo_frete_padrao), --19
						'SEM INFORMACAO', --20
						NULLIF(vDDD,''), --21
						NULLIF(trim(p_fone),''), --22				
						p_percentual_devolucao, --23
						p_percentual_reentrega, --24
						left(lower(p_email),100)
					) 						
			RETURNING codigo_cliente;

			FETCH vCursor INTO vCodigoCliente;
			
			CLOSE vCursor;			
		END IF;	
	ELSE
		
		IF char_length(trim(p_cnpj_cpf)) > 11 THEN 
			RETURN vCodigoCliente;
		END IF;

		IF p_cod_mun IS NOT NULL THEN 
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE trim(cod_ibge) = trim(p_cod_mun);
		ELSE 
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE trim(nome_cidade) = trim(p_cidade) AND uf = trim(p_uf);
		END IF;

		FETCH vCursor INTO vIdCidade, vUf, vDDD;

		CLOSE vCursor;


		-- Se a cidade nao foi encontrada, utiliza uma busca por distancia de edicao
		IF vIdCidade IS NULL THEN 

			WITH t AS (
				SELECT id_cidade, uf, ddd_padrao, levenshtein(trim(nome_cidade), upper(trim(p_cidade))) as lev
				FROM  cidades
				WHERE levenshtein(trim(nome_cidade), upper(trim(p_cidade))) < 4
					AND uf = trim(p_uf) AND cod_ibge IS NOT NULL
			) 
			SELECT id_cidade, uf, ddd_padrao 
			INTO vIdCidade, vUf, vDDD
			FROM t
			ORDER BY lev LIMIT 1;

		END IF;



		-- Se a cidade nao foi encontrada, usa codigo de cidade desconhecida no sistema
		IF vIdCidade IS NULL THEN 
		
			OPEN vCursor FOR SELECT id_cidade, uf, ddd_padrao FROM cidades WHERE id_cidade = 0;

			FETCH vCursor INTO vIdCidade, vUf, vDDD;

			CLOSE vCursor;

		END IF;	
			
		OPEN vCursor FOR 
		UPDATE cliente SET
			ddd = COALESCE(vDDD,''), --5
			telefone = COALESCE(p_fone,''), --6				
			endereco = fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),''))), --8
			numero=COALESCE(LEFT(p_nro,6),''), --9
			bairro=fpy_limpa_caracteres(upper(COALESCE(LEFT(p_bairro,30),''))), --10
			cep=COALESCE(trim(p_cep),''), --11
			id_cidade = vIdCidade, --12				
			ddd_cliente = NULLIF(vDDD,''), --21
			fone_contato = NULLIF(trim(p_fone),''), --22
			email= left(lower(p_email),100),	--25
			inscricao_estadual = upper(COALESCE(left(p_ie,18),'')) --4
		WHERE 
			cliente.cnpj_cpf = p_cnpj_cpf
		RETURNING codigo_cliente;

		FETCH vCursor INTO vCodigoCliente;	

		CLOSE vCursor;
	END IF; 
	
	RETURN vCodigoCliente;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

