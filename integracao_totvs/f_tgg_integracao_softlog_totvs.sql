-- Function: public.f_tgg_integracao_softlog_totvs()
--SELECT * FROM cliente_parametros WHERE id_tipo_parametro >= 10000
-- DROP FUNCTION public.f_tgg_integracao_softlog_totvs();

CREATE OR REPLACE FUNCTION public.f_tgg_integracao_softlog_totvs()
  RETURNS trigger AS
$BODY$
DECLARE
	v_existe integer;
	v_codigo_empresa character(3);
	v_codigo_filial character(3);
	v_regime_tributario integer;
BEGIN


	IF TG_TABLE_NAME = 'cliente' THEN 


		INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, codigo_empresa, codigo_filial)
		SELECT 
			NEW.codigo_cliente,
			10000,
			filial.codigo_empresa,
			filial.codigo_filial
		FROM
			filial
		WHERE
			NOT EXISTS (SELECT 1
				    FROM cliente_parametros
				    WHERE id_tipo_parametro = 10000 
				    AND filial.codigo_empresa = cliente_parametros.codigo_empresa
				    AND filial.codigo_filial = cliente_parametros.codigo_filial
				    AND codigo_cliente = NEW.codigo_cliente
		);



		INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, codigo_empresa, codigo_filial)
		SELECT 
			NEW.codigo_cliente,
			10003,
			filial.codigo_empresa,
			filial.codigo_filial
		FROM
			filial
		WHERE
			NOT EXISTS (SELECT 1
				    FROM cliente_parametros
				    WHERE id_tipo_parametro = 10003
				    AND filial.codigo_empresa = cliente_parametros.codigo_empresa
				    AND filial.codigo_filial = cliente_parametros.codigo_filial
				    AND codigo_cliente = NEW.codigo_cliente
		);
		
	END IF;

	IF TG_TABLE_NAME = 'fornecedores' THEN 


		INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
		SELECT 
			NEW.id_fornecedor,
			10000,
			filial.codigo_empresa,
			filial.codigo_filial
		FROM
			filial
		WHERE
			NOT EXISTS (SELECT 1
				    FROM fornecedor_parametros
				    WHERE id_tipo_parametro = 10000
				    AND filial.codigo_empresa = fornecedor_parametros.codigo_empresa
				    AND filial.codigo_filial = fornecedor_parametros.codigo_filial
				    AND id_fornecedor = NEW.id_fornecedor
			);


	

		IF NEW.tipo_motorista = 1 THEN 

				INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
				SELECT 
					NEW.id_fornecedor,
					10002,
					filial.codigo_empresa,
					filial.codigo_filial
				FROM
					filial
				WHERE
					NOT EXISTS (SELECT 1
						    FROM fornecedor_parametros
						    WHERE id_tipo_parametro = 10002
						    AND filial.codigo_empresa = fornecedor_parametros.codigo_empresa
						    AND filial.codigo_filial = fornecedor_parametros.codigo_filial
						    AND id_fornecedor = NEW.id_fornecedor
					);		
		ELSE
			DELETE FROM 
				fornecedor_parametros 
			WHERE 
				id_fornecedor = NEW.id_fornecedor
				AND id_tipo_parametro = 100002;
		END IF;


		INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
		SELECT 
			NEW.id_fornecedor,
			10003,
			filial.codigo_empresa,
			filial.codigo_filial
		FROM
			filial
		WHERE
			NOT EXISTS (SELECT 1
				    FROM fornecedor_parametros
				    WHERE id_tipo_parametro = 10003
				    AND filial.codigo_empresa = fornecedor_parametros.codigo_empresa
				    AND filial.codigo_filial = fornecedor_parametros.codigo_filial
				    AND id_fornecedor = NEW.id_fornecedor
			);
		
	END IF;


	IF TG_TABLE_NAME = 'filial' THEN 

		--SELECT * FROM totvs_config ORDER BY 1 
		--INSERT INTO 
		INSERT INTO totvs_parametros_filial (
			empresa,
			filial,
			id_parametro_totvs
		) 
		SELECT 
			NEW.codigo_empresa,
			NEW.codigo_filial,
			id_parametro
		FROM 
			totvs_config
		WHERE
			NOT EXISTS (SELECT 1 
				FROM totvs_parametros_filial 
				WHERE id_parametro_totvs = totvs_config.id_parametro
				AND empresa = NEW.codigo_empresa 
				AND filial = NEW.codigo_filial);


		IF TG_OP = 'INSERT' THEN 
			--Adiciona configuracoes cliente
			
			INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, codigo_empresa, codigo_filial)
			SELECT 
				cliente.codigo_cliente,
				10000,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM
				cliente;


			INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, codigo_empresa, codigo_filial)
			SELECT 
				cliente.codigo_cliente,
				10003,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM
				cliente;
				
			

			--Adiciona configuracoes fornecedores
			INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
			SELECT 
				fornecedores.id_fornecedor,
				10000,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM
				fornecedores;


			INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
			SELECT 
				fornecedores.id_fornecedor,
				10002,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM
				fornecedores
			WHERE 
				tipo_motorista = 1;
				

			INSERT INTO fornecedor_parametros (id_fornecedor, id_tipo_parametro, codigo_empresa, codigo_filial)
			SELECT 
				fornecedores.id_fornecedor,
				10003,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM
				fornecedores;

			--Adiciona configuracoes cfop
			INSERT INTO totvs_cfop (cfop, codigo_empresa, codigo_filial)
			SELECT DISTINCT
				cfop,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM 
				totvs_cfop;

			
			--SELECT * FROM totvs_cfop WHERE codigo_empresa = '003' AND codigo_filial = '002' ORDER BY cfop

			--DELETE FROM totvs_cfop WHERE codigo_empresa = '003' AND codigo_filial = '002' 
			--Adiciona configuracoes formapagamento			
			-- INSERT INTO totvs_formapagamento (id_pagamento_softlog, codigo_empresa, codigo_filial
-- 			SELECT 
				
			--FROM totvs_formapagamento 
			

			--Adicona configuracoes condicaopagamento

			--Adiciona configuracoes produtos
			IF NEW.regime_tributario = 3 THEN 
				INSERT INTO totvs_produtos (id_produto, codigo_empresa, codigo_filial)		
				SELECT DISTINCT
					id_produto,
					NEW.codigo_empresa,
					NEW.codigo_filial
				FROM 
					com_produtos;
			END IF;

			

			--Adiciona configuracoes veiculos
			INSERT INTO totvs_veiculos (placa_veiculo, codigo_empresa, codigo_filial)
			SELECT DISTINCT
				placa_veiculo,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM 
				veiculos;

			

			--Adiciona configuracoes de departamento
			INSERT INTO totvs_departamentos (id_departamento, codigo_empresa, codigo_filial)
			SELECT DISTINCT
				id_departamento,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM 
				departamentos;


			--Adiciona configuracoes de forma de pagamento		
			INSERT INTO totvs_formapagamento (id_pagamento_softlog, codigo_empresa, codigo_filial)
			SELECT DISTINCT
				id_pagamento,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM 
				tb_pagamentos;


			

			--Adiciona configuracoes de condicoes de pagamento
			INSERT INTO totvs_condicoespagamento (id_condicao_pagamento, codigo_empresa, codigo_filial)
			SELECT DISTINCT
				id_condicao_pgto,
				NEW.codigo_empresa,
				NEW.codigo_filial
			FROM 
				com_condicoes_pgto;
			
			
		END IF;			
	END IF;


	IF TG_TABLE_NAME = 'com_produtos' THEN 
-- 
-- 		SELECT 	regime_tributario 
-- 		INTO 	v_regime_tributario 
-- 		FROM 	filial;
		-- WHERE	codigo_filial = v_codigo_filial AND 
-- 			codigo_empresa = v_codigo_empresa;
-- 		
		--IF v_regime_tributario = 3 THEN 
			--RAISE NOTICE 'Inserindo produtos';
			INSERT INTO totvs_produtos (
				codigo_empresa,
				codigo_filial,
				id_produto
				
			)
			SELECT 
				filial.codigo_empresa,
				filial.codigo_filial,
				NEW.id_produto
			FROM 
				filial
			WHERE
				NOT EXISTS (SELECT 1 
					FROM totvs_produtos 
					WHERE id_produto = NEW.id_produto
					AND totvs_produtos.codigo_empresa = filial.codigo_empresa
					AND totvs_produtos.codigo_filial = filial.codigo_filial
				);			
		--END IF;
	END IF;
	

	IF TG_TABLE_NAME = 'veiculos' THEN 

			INSERT INTO totvs_veiculos (
				placa_veiculo,
				codigo_empresa,
				codigo_filial
			)
			SELECT 
				NEW.placa_veiculo,
				filial.codigo_empresa,
				filial.codigo_filial
			FROM 
				filial
			WHERE
				NOT EXISTS (SELECT 1 
					FROM totvs_veiculos
					WHERE placa_veiculo = NEW.placa_veiculo
					AND totvs_veiculos.codigo_empresa = filial.codigo_empresa
					AND totvs_veiculos.codigo_filial = filial.codigo_filial
			);			
			--END IF;
	END IF;


	IF TG_TABLE_NAME = 'departamentos' THEN 

			INSERT INTO totvs_departamentos (
				id_departamento,
				codigo_empresa,
				codigo_filial
			)
			SELECT 
				NEW.id_departamento,
				filial.codigo_empresa,
				filial.codigo_filial
			FROM 
				filial
			WHERE
				NOT EXISTS (SELECT 1 
					FROM totvs_departamentos
					WHERE id_departamento = NEW.id_departamento
					AND totvs_departamentos.codigo_empresa = filial.codigo_empresa
					AND totvs_departamentos.codigo_filial = filial.codigo_filial
					);			
			--END IF;
	END IF;

	--UPDATE tb_pagamentos SET id_pagamento = id_pagamento;
	--SELECT * FROM com_condicoes_pgto
	
	IF TG_TABLE_NAME = 'com_condicoes_pgto' THEN 

			INSERT INTO totvs_condicoespagamento (
				id_condicao_pagamento,
				codigo_empresa,
				codigo_filial
			)
			SELECT 
				NEW.id_condicao_pgto,
				filial.codigo_empresa,
				filial.codigo_filial
			FROM 
				filial
			WHERE
				NOT EXISTS (SELECT 1 
					FROM totvs_condicoespagamento
					WHERE id_condicao_pagamento = NEW.id_condicao_pgto
					AND totvs_condicoespagamento.codigo_empresa = filial.codigo_empresa
					AND totvs_condicoespagamento.codigo_filial = filial.codigo_filial
					);			
			--END IF;
	END IF;


	IF TG_TABLE_NAME = 'tb_pagamentos' THEN 

			INSERT INTO totvs_formapagamento (
				id_pagamento_softlog,
				codigo_empresa,
				codigo_filial
			)
			SELECT 
				NEW.id_pagamento,
				filial.codigo_empresa,
				filial.codigo_filial
			FROM 
				filial
			WHERE
				NOT EXISTS (SELECT 1 
					FROM totvs_formapagamento
					WHERE id_pagamento_softlog = NEW.id_pagamento
					AND totvs_formapagamento.codigo_empresa = filial.codigo_empresa
					AND totvs_formapagamento.codigo_filial = filial.codigo_filial
					);			
			--END IF;
	END IF;




	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_tgg_integracao_softlog_totvs()
  OWNER TO softlog_aeroprest;
