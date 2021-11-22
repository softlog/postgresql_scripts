/*

SELECT * FROM frt_ab WHERE ab_id_romaneio IS NULL ab_nr = '0010010000795'
UPDATE frt_ab SET ab_id_romaneio = NULL WHERE id_ab = 812


SELECT * FROM scr_romaneios WHERE id_romaneio = 440
SELECT * FROM scr_romaneio_despesas WHERE id_romaneio = 440


UPDATE frt_ab SET ab_id_romaneio = NULL WHERE ab_nr = '0010010000795'

BEGIN;
UPDATE frt_ab SET id_ab = id_ab
UPDATE frt_ab SET ab_id = ab_id 
DELETE FROM scr_romaneio_despesas WHERE id_romaneio_despesa = 102;


SELECT * FROM parametros
INSERT INTO parametros (cod_empresa, codigo_modulo, cod_parametro, valor_parametro, tipo_parametro)
VALUES ('001','ST_RODOVIA', 'pST_LANCA_AB_VIAGEM', 1, 'N')

SELECT * FROM parametros ORDER BY 1 DESC;


*/

CREATE OR REPLACE FUNCTION f_tgg_frt_ab_viagem()
  RETURNS trigger AS
$BODY$
DECLARE

	v_id_romaneio integer;
	v_qt integer;
	v_id_despesa integer;
	v_lanca_ab_viagem integer;
	v_id_despesa_ab integer;
	vEmpresa text;
	v_qtd numeric(12,2);
	v_vlr_unit numeric(12,2);
BEGIN


	vEmpresa = fp_get_session('pst_cod_empresa');
	--SELECT * FROM frt_ab

	
	SELECT valor_parametro::integer
	INTO v_lanca_ab_viagem 
	FROM parametros 
	WHERE cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_LANCA_AB_VIAGEM';

	v_lanca_ab_viagem = COALESCE(v_lanca_ab_viagem, 0);

	RAISE NOTICE 'Lanca Viagem %', v_lanca_ab_viagem;
	
	IF v_lanca_ab_viagem = 0 THEN 
		RAISE NOTICE 'Saindo Pq não lança viagem';
		RETURN NEW;
	END IF;

	IF TG_TABLE_NAME = 'frt_ab' THEN 

		RAISE NOTICE 'Trigger disparada';
		
		--Se estiver integrado sai
		IF NEW.ab_id_romaneio IS NOT NULL THEN 
			RETURN NEW;
		END IF;

		--Identifica tipo de despesa abastecimento
		SELECT id_despesa 
		INTO v_id_despesa_ab 
		FROM scr_despesas_viagem
		WHERE TRIM(descricao_despesa) = 'ABASTECIMENTO';

		IF v_id_despesa_ab IS NULL THEN
			RETURN NEW;
		END IF;

		--Identifica Viagem
		v_id_romaneio = f_identifica_viagem(NEW.ab_placa, NEW.ab_data,'A');

		--Se encontrou viagem, faz lancamento na mesma	
		IF v_id_romaneio IS NOT NULL  THEN 
		
			NEW.ab_id_romaneio = v_id_romaneio;

			SELECT id_romaneio_despesa
			INTO v_id_despesa 
			FROM scr_romaneio_despesas 
			WHERE 
				id_ab = NEW.id_ab;


			SELECT 	SUM(ab_qtd), SUM(ab_vlr_unit)
			INTO 	v_qtd, v_vlr_unit
			FROM 	frt_ab_itens
			WHERE 	id_ab = NEW.id_ab;

			


			IF NEW.ab_cancelado = 0 THEN 
				IF v_id_despesa IS NULL THEN 	
					--Lança despesa
					INSERT INTO scr_romaneio_despesas(				
						id_romaneio, --1
						id_fornecedor, --2
						id_despesa, --3
						cod_empresa, --4
						cod_filial, --5
						id_unidade, --6
						quantidade, --7
						vl_unitario, --8
						valor_despesa, --9
						codigo_centro_custo, --10
						observacao, --11
						data_referencia, --12 
						descricao, --13
						tipo_operacao, --14
						credito_debito, --15
						forma_pagamento, --16
						id_acerto, --17
						odometro, --18
						numero_documento, --19
						lancar_conta, --20
						id_conta_pagar, --21
						data_vencimento, --22
						data_emissao, --23
						ab_origem, --24
						ab_id_combust, -- 25
						ab_id_bomba, --26
						id_ab, --27
						id_ab_item --28					
					) VALUES (
						v_id_romaneio, --1, 
						NULL, --2,
						v_id_despesa_ab, --3,
						NEW.ab_empresa, --4,
						NEW.ab_filial, --5,
						1, --6,
						v_qtd, --7,
						v_vlr_unit, --8,
						NEW.ab_vlr_total, --9,
						NULL, --10,
						NEW.ab_obs, --11,
						NEW.ab_data, --12,
						'ABASTECIMENTO ' || NEW.ab_nr, --13,
						2,--14,
						2,--15,
						1,--16,
						NULL,--17,
						NEW.ab_km::integer,--18,
						NULL,--19,
						0,--20,
						NULL,--21,
						NULL,--22,
						NULL,--23,
						0,--24,
						NULL,--25,
						NULL,--26,
						NEW.id_ab,--27,
						NULL --28
					);

					UPDATE scr_romaneios 
					SET 
						vl_despesas_diretas = vl_despesas_diretas + NEW.ab_vlr_total,
						vl_despesas_a_vista = vl_despesas_a_vista + NEW.ab_vlr_total,
						vl_despesas_viagem = vl_despesas_viagem + NEW.ab_vlr_total
					WHERE id_romaneio = v_id_romaneio;	 
				ELSE
					UPDATE scr_romaneio_despesas SET id_ab = v_id_despesa;			
				END IF;		
			ELSE
				IF v_id_despesa IS NOT NULL THEN 	
					DELETE FROM scr_romaneio_despesas WHERE id_romaneio_despesa = v_id_despesa;

					UPDATE scr_romaneios 
					SET 
						vl_despesas_diretas = vl_despesas_diretas - NEW.ab_vlr_total,
						vl_despesas_a_vista = vl_despesas_a_vista - NEW.ab_vlr_total,
						vl_despesas_viagem = vl_despesas_viagem - NEW.ab_vlr_total
					WHERE id_romaneio = v_id_romaneio;
						 
				END IF;
			END IF;

		END IF;
	END IF;

	IF TG_TABLE_NAME = 'scr_romaneios' AND TG_OP = 'UPDATE' THEN 

		IF OLD.emitido = 0 AND NEW.emitido = 1 THEN 
			UPDATE frt_ab SET id_ab = id_ab WHERE ab_data = NEW.data_saida::date AND ab_placa = NEW.placa_veiculo;
		END IF;

	END IF;

	--SELECT * FROM frt_ab
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT emitido, tipo_romaneio FROM scr_romaneios ORDER BY emitido DESC

DROP TRIGGER tgg_frt_ab_viagem ON frt_ab;
CREATE TRIGGER tgg_frt_ab_viagem
AFTER INSERT OR UPDATE OR DELETE
ON frt_ab
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_frt_ab_viagem();


DROP TRIGGER tgg_scr_romaneios_ab_viagem ON scr_romaneios;
CREATE TRIGGER tgg_scr_romaneios_ab_viagem
AFTER INSERT OR UPDATE OR DELETE
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_frt_ab_viagem();
