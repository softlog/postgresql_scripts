

CREATE OR REPLACE FUNCTION f_tgg_previsao_entrega_oco()
  RETURNS trigger AS
$BODY$
DECLARE	
	v_id_ocorrencia integer;
	v_data_ocorrencia date;
	v_dias integer;
	v_data_previsao_entrega date;
BEGIN


	--Calcula Tempo de Entrega
	IF TG_TABLE_NAME = 'scr_notas_fiscais_imp_ocorrencias' THEN 

		RAISE NOTICE 'NFe';
	
		--Verifica se tem parametro dizendo qual ocorrencia usar para inicio de viagem
		SELECT 
			valor_parametro::integer
		INTO 
			v_id_ocorrencia
		FROM 
			scr_notas_fiscais_imp nf
			LEFT JOIN cliente_parametros cp
				ON cp.codigo_cliente = nf.consignatario_id
		WHERE 
			nf.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
			AND cp.id_tipo_parametro = 144;

		--Se tiver dispara a trigger para pegar previsao de entrega se existir romaneio.
		IF v_id_ocorrencia IS NOT NULL THEN 
			IF v_id_ocorrencia < 300 OR v_id_ocorrencia > 399 THEN 
				UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;
			END IF;		
		END IF;
			
	END IF;
	
	IF TG_TABLE_NAME = 'scr_romaneio_nf' THEN 
		RAISE NOTICE 'Romaneio';

		--Verifica se tem parametro dizendo qual ocorrencia usar para inicio de viagem
		SELECT 
			valor_parametro::integer
		INTO 
			v_id_ocorrencia
		FROM 
			scr_notas_fiscais_imp nf
			LEFT JOIN cliente_parametros cp
				ON cp.codigo_cliente = nf.consignatario_id
		WHERE 
			nf.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
			AND cp.id_tipo_parametro = 144;

		--SELECT * FROM regiao_remetentes

		RAISE NOTICE 'Ocorrencia de Entrega %', v_id_ocorrencia;

		--Se tem ocorrencia, verifica se ja foi registrada na NFe
		IF v_id_ocorrencia IS NOT NULL THEN 

			SELECT data_ocorrencia::date 
			INTO v_data_ocorrencia
			FROM scr_notas_fiscais_imp_ocorrencias
			WHERE id_ocorrencia = v_id_ocorrencia
				AND id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;
								
		ELSE

			SELECT data_saida::date
			INTO v_data_ocorrencia
			FROm scr_romaneios
			WHERE id_romaneio = NEW.id_romaneio;


		END IF;	

		
		--Se nao tem data de ocorrencia, eh pq ainda aguarda ocorrencia ser registrada
		IF v_data_ocorrencia IS NOT NULL THEN 

			WITH t AS (
				SELECT 
					v_data_ocorrencia::date as data_inicial,
					f_prazo_dias_entrega(v_data_ocorrencia, rc.tempo_dias, nf.calculado_ate_id_cidade) as prazo_dias					
				FROM 
					scr_notas_fiscais_imp nf
					LEFT JOIN regiao_cidades rc
						ON rc.id_cidade = nf.calculado_ate_id_cidade
					LEFT JOIN regiao_remetentes rr
						ON rr.id_regiao = rc.id_regiao
				WHERE 
					nf.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp	
					AND rr.remetente_id = nf.remetente_id
			)
			SELECT 
				prazo_dias,
				data_inicial + prazo_dias
			INTO 
				v_dias,
				v_data_previsao_entrega
			FROM 
				t;


			RAISE NOTICE 'Data ocorrencia % - Data Previsao % - Tempo Dias %', v_data_ocorrencia, v_data_previsao_entrega, v_dias;

			
			UPDATE scr_notas_fiscais_imp SET 
				data_previsao_entrega = v_data_previsao_entrega
			WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

		END IF;		
					
			
	END IF;


	
		
     
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_previsao_entrega_1 ON scr_romaneio_nf;
CREATE TRIGGER tgg_previsao_entrega_1
AFTER INSERT OR UPDATE 
ON scr_romaneio_nf
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_previsao_entrega_oco();

DROP TRIGGER tgg_previsao_entrega_2 ON scr_notas_fiscais_imp_ocorrencias;
CREATE TRIGGER tgg_previsao_entrega_2
AFTER INSERT OR UPDATE 
ON scr_notas_fiscais_imp_ocorrencias 
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_previsao_entrega_oco();