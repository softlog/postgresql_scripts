-- UPDATE scr_notas_fiscais_imp SET flg_calculo_frete = 1 WHERE id_nota_fiscal_imp = 26447
-- 
-- SELECT id_nota_fiscal_imp FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::bigint IN (006920224,006925528)
-- 
-- SELECT * FROM fd_dados_tabela('scr_notas_fiscais_imp') ORDER BY campo
-- 
-- UPDATE scr_notas_fiscais_imp SET flg_calculo_frete = 1, data_emissao_hr = '2017-07-31 15:00:00' WHERE id_nota_fiscal_imp IN (5253879,5270425) AND status = 0;
-- 
-- SELECT * FROM fila_frete_automatico WHERE id_nfe IN (5253879,5270425);
-- 
-- UPDATE scr_conhecimento SET cancelado = 1 WHERE id_conhecimento IN (481225,481226);
-- 
-- SELECT tipo_documento, id_conhecimento, data_cte_re, numero_ctrc_filial, total_frete, dt_agenda_coleta FROM scr_conhecimento WHERE id_conhecimento IN (481227,481228)
-- 
-- 481210,481211)
-- 
-- SELECT * FROM f_scr_parametros_calculo_frete('481223')
-- 481208
-- 481209

-- Function: public.f_tgg_enfileira_calculo()

-- DROP FUNCTION public.f_tgg_enfileira_calculo();

CREATE OR REPLACE FUNCTION public.f_tgg_enfileira_calculo()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_banco_dados integer;
	chave_agrupadora text;
	v_tipo_agrupamento integer;
	vStatus integer;
	v_frete_automatico integer;

	v_numero_tabela character(13);
	v_qt integer;
	vEmpresa character(3);
BEGIN
	--Inicio Nota Cancelada
	IF NEW.status = 2 THEN 
		RETURN NEW;
	END IF;
	--Fim - Nota Cancelada

-- 	--Calcula Frete Automatico só o que tiver parametrizado
-- 	SELECT 
-- 		valor_parametro::integer
-- 	INTO
-- 		v_frete_automatico
-- 	FROM
-- 		cliente_parametros
-- 	WHERE
-- 		codigo_cliente = NEW.remetente_id 
-- 		AND id_tipo_parametro = 100;
-- 		
-- 	IF COALESCE(v_frete_automatico,0) <> 1 THEN
-- 		RETURN NEW;
-- 	END IF;
		
	IF TG_WHEN = 'BEFORE' THEN 

		IF NEW.numero_tabela_frete IS NULL AND TG_OP = 'UPDATE' THEN


			SELECT 
				tabela_padrao
			INTO 
				v_numero_tabela
			FROM 
				cliente 			
			WHERE
				cliente.codigo_cliente = NEW.consignatario_id;



			IF v_numero_tabela IS NULL THEN
				SELECT 
					numero_tabela_frete
				INTO 
					v_numero_tabela
				FROM 
					cliente 
					LEFT JOIN scr_tabelas 
						ON scr_tabelas.cnpj_cliente = cliente.cnpj_cpf
				WHERE
					cliente.codigo_cliente = NEW.consignatario_id;
			END IF;

			IF v_numero_tabela IS NULL THEN

				SELECT 
					numero_tabela_frete
				INTO 
					v_numero_tabela
				FROM 
					cliente 
					LEFT JOIN scr_tabelas 
						ON left(scr_tabelas.cnpj_cliente,8) = left(cliente.cnpj_cpf,8)
				WHERE
					cliente.codigo_cliente = NEW.consignatario_id;

			END IF;
			
			IF v_numero_tabela IS NOT NULL THEN
				NEW.numero_tabela_frete = v_numero_tabela;				
			END IF;

			
		END IF;
		RETURN NEW;
	END IF;


	IF TG_OP = 'DELETE' THEN 
		RETURN OLD;
	END IF;

	--Obtem o id do banco de dados
	SELECT id_string_conexao 
	INTO v_id_banco_dados 
	FROM string_conexoes 
	WHERE trim(banco_dados) = trim(current_database());

	SELECT empresa_responsavel
	INTO vEmpresa
	FROM cliente
	WHERE codigo_cliente = NEW.consignatario_id;


	SELECT 		
		valor_parametro::integer
	INTO 
		v_tipo_agrupamento
	FROM 
		cliente_parametros 
	WHERE
		codigo_cliente = NEW.consignatario_id
		AND id_tipo_parametro = 80;
		

	v_tipo_agrupamento = COALESCE(v_tipo_agrupamento,1);
	
	IF v_tipo_agrupamento = 1 THEN
		chave_agrupadora = (((	NEW.remetente_id::text || '_'::text) 
					|| NEW.destinatario_id::text) || '_'::text) 
					|| NEW.data_emissao::text;
	END IF;

	IF v_tipo_agrupamento = 2 THEN 
		chave_agrupadora = (NEW.remetente_id::text || '_'::text) || NEW.destinatario_id::text;
	END IF;

	IF v_tipo_agrupamento = 3 THEN 
		chave_agrupadora = (NEW.remetente_id::text || '_'::text) || NEW.id_nota_fiscal_imp::text;
	END IF;		

	IF NEW.numero_tabela_frete IS NULL THEN 
	
		RAISE NOTICE 'Nota %', NEW.id_nota_fiscal_imp;
		RAISE NOTICE 'Sem tabela de frete';
		RETURN NULL;
		
	END IF;	

	IF NEW.id_conhecimento IS NULL THEN
		vStatus = 0;
	ELSE
		vStatus = 1;
	END IF;

 	BEGIN 
		INSERT INTO fila_frete_automatico (
			id_banco_dados,
			id_nfe,
			chave_grupo,
			empresa_emitente,
			filial_emitente,
			status,
			id_conhecimento
		)
		VALUES (
			v_id_banco_dados,
			NEW.id_nota_fiscal_imp,
			chave_agrupadora,
			COALESCE(vEmpresa,'001'),
			'001',
			vStatus,
			NEW.id_conhecimento
		);
	EXCEPTION 
		WHEN others THEN 
			RAISE NOTICE 'Ocorreu um erro';
	END;	
		

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
--ALTER FUNCTION public.f_tgg_enfileira_calculo()
--  OWNER TO softlog_saocarlos2;


--DROP TRIGGER tgg_zzzz_enfileira_calculo ON scr_notas_fiscais_imp;
--DROP TRIGGER tgg_zzzz_enfileira_calculo_before ON scr_notas_fiscais_imp;

CREATE TRIGGER tgg_zzzz_enfileira_calculo
--AFTER INSERT OR UPDATE OF numero_tabela_frete
AFTER UPDATE OF flg_calculo_frete
ON scr_notas_fiscais_imp
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_enfileira_calculo();


CREATE TRIGGER tgg_zzzz_enfileira_calculo_before
BEFORE UPDATE OF flg_calculo_frete
ON scr_notas_fiscais_imp
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_enfileira_calculo();

-- 
-- SELECT numero_ctrc_filial FROM scr_conhecimento WHERE id_conhecimento IN (
-- 3068451,3068460,3068465,3068473,3068482,3068437,3068446,3068447,3068447,3068448,3068449,3068450,3068455,3068464,3068464,3068474,3068483,3068452,3068461,3068461,3068466,3068476,3068486,3068486,3068453,3068456,3068463,3068472,3068480,3068462,3068470,3068481,3068489,3068493,3068457,3068469,3068479,3068488,3068488,3068494,3068454,3068467,3068475,3068484,3068484,3068490,3068459,3068471,3068477,3068485,3068485,3068492,3068458,3068468,3068478,3068487,3068491,3068495,3068496,3068497,3068497
-- )
-- 
-- DELETE FROM scr_conhecimento WHERE id_conhecimento IN (
-- 3068451,3068460,3068465,3068473,3068482,3068437,3068446,3068447,3068447,3068448,3068449,3068450,3068455,3068464,3068464,3068474,3068483,3068452,3068461,3068461,3068466,3068476,3068486,3068486,3068453,3068456,3068463,3068472,3068480,3068462,3068470,3068481,3068489,3068493,3068457,3068469,3068479,3068488,3068488,3068494,3068454,3068467,3068475,3068484,3068484,3068490,3068459,3068471,3068477,3068485,3068485,3068492,3068458,3068468,3068478,3068487,3068491,3068495,3068496,3068497,3068497
-- )


--SELECT string_agg(id_conhecimento::text,',') FROM fila_frete_automatico WHERE id_banco_dados = 53