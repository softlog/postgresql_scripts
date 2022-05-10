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
	p_sem_cnpj_cpf integer;
	p_busca_mun_por_cep integer;
	p_cod_mun_aux text;
	v_id_subscricao integer;
	
	vIdCidade integer;
	vUf character(2);
	vDDD character(2);
	vTipoCliente integer;
	vClassificacaoFiscal character(30);
	vEndereco text;

	vLatitude double precision;
	vLongitude double precision;

	vCodigoCliente integer;
	
	vCursor refcursor;
	vExiste integer;

	vEmpresa text;
	vFilial text;

	vIE text;
	vRazao text;

	v_tem_subscricao integer;

	v_importa_para_crm integer;
	v_id_contato integer;
	
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
	p_sem_cnpj_cpf		 	= COALESCE(((dadosCliente->>'part_sem_cnpj_cpf')::text::integer),0);
	vLatitude			= ((dadosCliente->>'part_latitude')::text::double precision);
	vLongitude			= ((dadosCliente->>'part_longitude')::text::double precision);
	v_id_subscricao 		= COALESCE(((dadosCliente->>'part_subscricao')::text::integer),0);

	IF trim(p_cod_mun) = '' THEN		
		p_cod_mun = NULL;
	END IF;

	vEmpresa 	= fp_get_session('pst_cod_empresa');
	vFilial  	= fp_get_session('pst_filial');


	--BUSCA CODIGO IBGE POR CEP
		
	SELECT valor_parametro::integer
	INTO p_busca_mun_por_cep
	FROM parametros 
	WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_BUSCA_CIDADE_POR_CEP';
	
	p_busca_mun_por_cep = COALESCE(p_busca_mun_por_cep,0);
	
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


	--Importa dados para o CRM
	
	SELECT COALESCE(valor_parametro::integer,0)::integer
	INTO v_importa_para_crm
	FROM parametros 
	WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_IMPORTA_DADOS_CRM';
	

	
	
	-- Verifica se o cliente ja existe
	vCodigoCliente = 0;
	OPEN vCursor FOR 
			SELECT count(*), max(endereco), max(inscricao_estadual), max(nome_cliente)			
			FROM cliente
			WHERE cnpj_cpf = p_cnpj_cpf;
		
	
	RAISE NOTICE 'DESTINATARIO %', p_cnpj_cpf;
	FETCH vCursor INTO vExiste, vEndereco, vIE, vRazao;

	CLOSE vCursor;
		
			

	IF (vExiste = 0) THEN 		
		RAISE NOTICE 'NAO EXISTE';
		
		IF p_busca_mun_por_cep = 1 THEN 
			SELECT 
				cod_ibge
			INTO 
				p_cod_mun_aux
			FROM 
				cep 
			WHERE cep = p_cep;
			p_cod_mun = COALESCE(p_cod_mun_aux,p_cod_mun);
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

		
		--Com o codigo da cidade fazer inclusao na tabela de cliente
		IF vIdCidade IS NOT NULL THEN 
			
			--PERFORM f_debug('Debug ','Linha 63');

			IF p_fone = '' THEN 
				vDDD = '';
			END IF;


			IF (p_sem_cnpj_cpf = 0) THEN
						
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
			ELSE 
				vTipoCliente = 4;
				vClassificacaoFiscal = 'NAO CONTRIBUINT';
			
			END IF;
			RAISE NOTICE 'Cliente cnpj %', p_cnpj_cpf;
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
						email,		--25
						latitude,
						longitude
					     )
				VALUES (  
						trim(p_cnpj_cpf), --1
						replace(fpy_limpa_caracteres(upper(left(p_nome_cliente,50))),'''',''), --2
						replace(fpy_limpa_caracteres(upper(left(p_nome_cliente,50))),'''',''), --3
						upper(COALESCE(left(p_ie,18),'')), --4
						COALESCE(vDDD,''), --5
						COALESCE(p_fone,''), --6
						trim(p_cnpj_cpf), --7
						replace(fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),''))),'''',''), --8
						COALESCE(LEFT(p_nro,6),''), --9
						replace(fpy_limpa_caracteres(upper(COALESCE(LEFT(p_bairro,30),''))),'''',''), --10
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
						left(lower(p_email),100),
						vLatitude,
						vLongitude
					) 						
			RETURNING codigo_cliente;
			
			FETCH vCursor INTO vCodigoCliente;			
			
			CLOSE vCursor;			

			/*
			SELECT codigo_cliente
			INTO vCodigoCliente 
			FROM cliente 
			WHERE cnpj_cpf = p_cnpj_cpf;
			*/

			--SELECT * FROM crm_contatos_detalhes
			--RAISE NOTICE 'Cliente codigo %', vCodigoCliente;

			IF (v_importa_para_crm = 1) AND ( NULLIF(vDDD,'') || (NULLIF(trim(p_fone),'')) <> '') THEN 
				OPEN vCursor FOR
				INSERT INTO public.crm_contatos(
					nome_razao, --1 			    				
					endereco, --3
					numero, --4				
					bairro, --6
					id_cidade, --7
					cep, --8								
					cnpj_cpf, --9
					dt_cadastro --14			    
				) VALUES (
					fpy_limpa_caracteres(upper(left(p_nome_cliente,50))), --1
					fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),''))), --3
					COALESCE(LEFT(p_nro,6),''), --4
					fpy_limpa_caracteres(upper(COALESCE(LEFT(p_bairro,30),''))), --6
					vIdCidade, --7
					COALESCE(trim(p_cep),''), --8
					trim(p_cnpj_cpf), --9
					current_date --14				
				)
				RETURNING id_contato;

				
				FETCH vCursor INTO v_id_contato;				

				CLOSE vCursor;

				INSERT INTO public.crm_cont_relacoes(
				    id_contato, id_estrangeiro, flg_estrangeiro, 
				    atual_em)
				VALUES (v_id_contato, vCodigoCliente, 'C');

				INSERT INTO crm_contatos_detalhes (
					id_contato,
					tp_detalhe, 
					detalhe
				) VALUES (
					v_id_contato,
					'Fone Comercial',
					NULLIF(vDDD,'') || NULLIF(trim(p_fone),'')
				);				
	
			END IF;
		END IF;	
	ELSE
		RAISE NOTICE 'Existe';
		
		IF LEFT(trim(vEndereco),100) = fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),'')))
			AND trim(vIE) = upper(COALESCE(left(p_ie,18),'')) 
			AND trim(vRazao) = fpy_limpa_caracteres(upper(left(p_nome_cliente,50)))
		THEN
			--RAISE NOTICE 'Não mudou Endereco';
			RETURN 0;
		END IF;


		IF p_busca_mun_por_cep = 1 THEN 
			SELECT 
				cod_ibge
			INTO 
				p_cod_mun_aux
			FROM 
				cep 
			WHERE cep = p_cep;
			p_cod_mun = COALESCE(p_cod_mun_aux,p_cod_mun);
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
		--RAISE NOTICE 'Cliente ja esta no sistema %', p_nome_cliente;	
		OPEN vCursor FOR 
		UPDATE cliente SET
			nome_cliente  =  replace(fpy_limpa_caracteres(upper(left(p_nome_cliente,50))),'''',''), --2
			nome_fantasia = replace(fpy_limpa_caracteres(upper(left(p_nome_cliente,50))),'''',''), --3
			ddd = COALESCE(vDDD,''), --5
			telefone = COALESCE(p_fone,''), --6				
			endereco = replace(fpy_limpa_caracteres(upper(COALESCE(LEFT(p_lgr,100),''))),'''',''), --8
			numero=COALESCE(LEFT(p_nro,6),''), --9
			bairro= replace(fpy_limpa_caracteres(upper(COALESCE(LEFT(p_bairro,30),''))),'''',''), --10
			cep=COALESCE(trim(p_cep),''), --11
			id_cidade = vIdCidade, --12				
			ddd_cliente = NULLIF(vDDD,''), --21
			fone_contato = NULLIF(trim(p_fone),''), --22
			email= left(lower(p_email),100),	--25
			inscricao_estadual = upper(COALESCE(left(p_ie,18),'')), --4,
			latitude = vLatitude,
			longitude = vLongitude
		WHERE 
			cliente.cnpj_cpf = p_cnpj_cpf
		RETURNING codigo_cliente;

		FETCH vCursor INTO vCodigoCliente;	

		CLOSE vCursor;
	END IF; 
	
	--RAISE NOTICE 'Codigo Cliente %', vCodigoCliente;
	--RAISE NOTICE 'v_id_subscricao %', v_id_subscricao;
	
	IF vCodigoCliente > 0 AND v_id_subscricao > 0 THEN 
	
		SELECT count(*) 
		INTO v_tem_subscricao
		FROM msg_subscricao
		WHERE codigo_cliente = vCodigoCliente
			AND id_notificacao = 4;


		RAISE NOTICE 'Tem subscricao %', v_tem_subscricao;
		IF v_tem_subscricao = 0 THEN 
			INSERT INTO msg_subscricao (
				ativo,
				id_notificacao,
				codigo_cliente,
				email,
				tipo_host
			) VALUES (
				1,
				4,
				vCodigoCliente,
				p_email,
				0
			);
		END IF;

	END IF;
	
	RETURN vCodigoCliente;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

