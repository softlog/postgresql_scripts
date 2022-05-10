-- Function: public.f_tgg_lanca_frt_ab_epta()

-- DROP FUNCTION public.f_tgg_lanca_frt_ab_epta();

/*


SELECT * FROM frt_ab_epta_sga_bomba

SELECT * FROM frt_ab_epta_sga 

UPDATE frt_ab SET ab_obs = 'IMPORTACAO AUTOMATICA DE EDI EPTA SGA'
SELECT * FROM frt_ab 

*/
-- Function: public.f_tgg_lanca_frt_ab_epta()
-- DROP FUNCTION public.f_tgg_lanca_frt_ab_epta();

/*
SELECT * FROM frt_ab_epta_sga ORDER BY 1 DESC
SELECT * FROM frt_ab ORDER BY 1 DESC LIMIT 1000

SELECT * FROM frt_ab WHERE id_ab >= 2949

*/

CREATE OR REPLACE FUNCTION public.f_tgg_lanca_frt_ab_epta()
  RETURNS trigger AS
$BODY$
DECLARE
	v_empresa character(3);
	v_filial character(3);	
	v_ab_nr character(13);
	v_ab_placa character(10);
	v_id_combust integer;
	v_data timestamp;
	v_usuario integer;	
	v_id_motorista integer;
	v_id_bomba integer;
	v_id_posto integer;
	v_id_ab integer;
	v_id_veiculo integer;
	v_placa_veiculo character(8);
	v_existe integer;
	v_placas_engate text;

	v_km_atual numeric(8,2);
	v_km_anterior numeric(8,2);
	v_km_rodado numeric(8,2);

	v_atu_km_ab integer;
	
	
	vCursor refcursor;
	
BEGIN

	IF  TG_WHEN = 'BEFORE' THEN 
		/*
			Verifica se ja existe lancamento com veiculo, data, hora e valor total. 
			Objetivo: nao permitir o reprocessamento de um mesmo arquivo.
		*/
		SELECT  count(*)
		INTO    v_existe
		FROM    frt_ab_epta_sga
		WHERE   1=1
		AND     placa_veiculo = NEW.placa_veiculo
		AND     data_abastecimento = NEW.data_abastecimento
		AND     hora_abastecimento = NEW.hora_abastecimento
		AND     valor_total = NEW.valor_total
		AND     id <> NEW.id;

		IF  v_existe > 0 THEN 
			RAISE NOTICE 'Ja Existe';
			RETURN NULL;
		END IF;	

		--RAISE NOTICE 'Inserindo Abastecimento';
		/*
			Verifica se o veiculo existe no cadastro do sistema.
			Objetivo: Evitar erro de Constraint que valida se a placa existe.
		*/
			
		SELECT  placa_veiculo, id_veiculo
		INTO    v_placa_veiculo, v_id_veiculo
		FROM    veiculos
		WHERE   placa_veiculo = TRIM(NEW.placa_veiculo);

		IF  v_placa_veiculo IS NULL THEN
			RAISE NOTICE 'PLACA % NAO EXISTE', NEW.placa_veiculo;
			RETURN NEW;
		END IF;


		v_placas_engate = f_retorna_placas_engates(v_placa_veiculo, (NEW.data_abastecimento || ' ' || NEW.hora_abastecimento)::timestamp);


		-- Verifica quantidade de kilometros rodados
		v_km_atual = COALESCE(NEW.hodometro::integer / 10,0)::NUMERIC(8,0);
		
		SELECT ab_km
		INTO v_km_anterior
		FROM frt_ab
		WHERE 
			ab_placa = trim(NEW.placa_veiculo)
			AND ab_data < (NEW.data_abastecimento || ' ' || NEW.hora_abastecimento)::timestamp
		ORDER BY ab_data DESC			
		LIMIT 1;

		RAISE NOTICE 'VEICULO % KM ANTERIOR % A %', trim(NEW.placa_veiculo), v_km_anterior, (NEW.data_abastecimento || ' ' || NEW.hora_abastecimento)::timestamp;
		IF v_km_anterior IS NOT NULL THEN 
			v_km_rodado = v_km_atual - v_km_anterior;
		ELSE
			v_km_rodado = 0.00;
		END IF;


		/*
			Recupera variaveis globais
		*/
		
		v_filial    = fp_get_session('pst_filial');
		v_empresa   = fp_get_session('pst_cod_empresa');
		v_usuario   = fp_get_session('pst_usuario')::integer;

		
		
		
		--SELECT * FROM FRT_VEIC_KM 

		--Recupera o id_fornecedor do motorista.
		SELECT  id_fornecedor
		INTO    v_id_motorista
		FROM    fornecedores 
		WHERE   cnpj_cpf = RIGHT(NEW.cpf_frentista,11);


		
		

		/*
		SELECT  id_posto
		INTO    v_id_posto
		FROM    frt_ab_epta_sga_posto
		WHERE   numero_filial = NEW.numero_filial
		AND     numero_posto = NEW.numero_posto;
		*/

		/*
			Busca na tabela de/para qual o id da bomba no sistema Softlog
			associado ao codigo da bomba no sistema epta sga
		*/
		SELECT  id_bp
		INTO    v_id_bomba
		FROM    frt_ab_epta_sga_bomba
		WHERE   numero_filial = NEW.numero_filial
		AND     numero_posto = NEW.numero_posto
		AND     numero_bomba = NEW.numero_bomba;

		--SELECT * FROM frt_ab_epta_sga_tp_mat
		--UPDATE frt_ab_epta_sga SET id = id 
		--SELECT * FROM frt_ab

		--SELECT * FROM tb_combust_lub_itens

		/*
			Busca na tabela de/para qual o id_combust_lub no sistema Softlog
			associado ao codigo de produto no sistema epta sga.
		*/
		
		SELECT  coi.id_combust_lub 
		INTO    v_id_combust
		FROM    frt_ab_epta_sga_tp_mat mat			
                LEFT JOIN tb_combust_lub_itens coi
                       ON coi.id_produto = mat.id_produto_softlog
		WHERE   mat.ident_produto = NEW.ident_produto;

		--Gera o ab_nr
		v_ab_nr = v_empresa || v_filial || trim(to_char(proximo_numero_sequencia('frt_ab_' || v_empresa || '_' || v_filial), '0000000'));

		SET datestyle = "ISO, DMY";

		
		--Inclusão do registro na tabela frt_ab
		IF  NEW.id_ab IS NULL THEN 
			OPEN vCursor FOR
			INSERT INTO frt_ab (
				ab_empresa, --1
				ab_filial, --2
				ab_nr, --3
				ab_placa, --4
				ab_id_combust, --5
				ab_data, --6
				ab_usu, --7
				ab_km, --8
				ab_hr, --8.1
				ab_id_bomba, --9
				ab_id_motorista, --10
				ab_qtd, --11
				ab_vlr_unit, --12
				ab_vlr_total, --13
				ab_origem, --14		
				ab_obs, --15
				ab_placas_engates, --16
				ab_km_rodados, --17
				ab_km_anterior, --18
				ab_hr_anterior, --19
				ab_hr_trabalhadas --20
			) VALUES (
				v_empresa,
				v_filial,
				v_ab_nr,
				trim(NEW.placa_veiculo),
				v_id_combust,
				(NEW.data_abastecimento || ' ' || NEW.hora_abastecimento)::timestamp,
				v_usuario,
				COALESCE(NEW.hodometro::integer / 10,0)::NUMERIC(8,0),
				COALESCE(NEW.horimetro::INTEGER / 100,0)::NUMERIC(9,2),
				v_id_bomba,
				v_id_motorista,
				replace(NEW.quantidade,',','.')::numeric(10,2),
				replace(NEW.valor_unitario,',','.')::numeric(14,2),
				replace(NEW.valor_total,',','.')::numeric(14,2),
				2,
				'IMPORTACAO AUTOMATICA DE EDI EPTA SGA',
				v_placas_engate,
				v_km_rodado,
				v_km_anterior,
				0,
				0
			)
			RETURNING id_ab;
			FETCH vCursor INTO v_id_ab;

			CLOSE vCursor;

			--Inclusão do registro no frt_ab_itens
			INSERT INTO frt_ab_itens (
				id_ab, -- ID do Abastecimento
				ab_id_combust, -- ID do Combustivel / Lubrificante (Tabela Tb_Combust_Lub)
				ab_encheu, -- Esse Abastecimento encheu o tanque? 0 = Nao / 1 = Sim
				ab_usu, -- Usuario do Sistema que fez o registro
				ab_id_bomba, -- ID da Bomba Propria, caso seja Abastecimento Interno (FK na tabela Frt_Bomba)
				ab_qtd, -- Quantidade de Litros ou M3 do Abastecimento
				ab_vlr_unit, -- Valor Unitario do Combustivel
				ab_vlr_total, -- Valor Total do Combustivel
				ab_obs, -- Observacoes sobre este Abastecimento
				atual_em, -- Data e Hora da atualizacao
				ab_vlr_acresc, -- Valor de Acrescimo no preco do Combustivel
				ab_vlr_descon--, -- Valor de Desconto no preco do Combustivel
				--ab_id_posto -- ID do Posto (fornecedores.id_fornecedor)
			) VALUES (
				v_id_ab,
				v_id_combust,
				1,
				v_usuario,
				v_id_bomba,
				replace(NEW.quantidade,',','.')::numeric(10,3),
				replace(NEW.valor_unitario,',','.')::numeric(14,3),
				replace(NEW.valor_total,',','.')::numeric(14,3),
				'IMPORTACAO AUTOMATICA DE EDI EPTA SGA',
				now(),
				0.00,
				0.00--,
				--v_id_posto
			);

			NEW.id_ab = v_id_ab;


			SELECT COALESCE(valor_parametro::integer, 0)  
			INTO v_atu_km_ab 
			FROM parametros 
			WHERE lower(cod_parametro) = 'pst_atu_km_abastec'
				AND cod_empresa = v_empresa;

			v_atu_km_ab = COALESCE(v_atu_km_ab,0);
			

			--Verifica se faz lancamento em FRT_VEIC_KM
			IF v_atu_km_ab = 1 THEN 

				INSERT INTO frt_veic_km (
					id_veiculo, 
					placa_veiculo, 
					tb_origem, 
					id_origem, 
					veic_km, 
					veic_hr,
					veic_flag,
					veic_dthr,
					veic_tipo,
					veic_obs
				) VALUES (
					v_id_veiculo,
					trim(NEW.placa_veiculo),
					'FRT_AB',
					v_id_ab,
					v_km_atual,
					0.00,
					0,
					NOW(),
					2,
					'ABASTECIMENTO'
				);	
			
			END IF;
			
		END IF;
		
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

