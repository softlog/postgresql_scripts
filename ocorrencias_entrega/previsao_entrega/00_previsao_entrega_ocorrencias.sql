/*
SELECT id_nota_fiscal_imp, data_previsao_entrega FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210719897687000138550010001250041203357352'

2021-09-07

SELECT id_romaneio, data_saida FROM scr_romaneios WHERE data_saida >= '2021-08-01 00:00:00' ORDER BY 1 
SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 53319 ORDER BY 1 DESC

numero_nota_fiscal::integer = 3225
SELECT id_romaneio, data_saida FROM scr_romaneios WHERE numero_romaneio = '0010010001260'
COMMIT;
SELECT * from scr_romaneio_nf WHERe id_nota_fiscal_imp = 47726;
BEGIN;
UPDATE scr_romaneio_nf SET id_nota_fiscal_imp = id_nota_fiscal_imp WHERE id_romaneio > 1858;
SELECT id_nota_fiscal_imp, data_previsao_entrega FROM scr_notas_fiscais_imp WHERE numero_nota_fiscal::integer = 3225
ROLLBACK;
SELECT * FROM empresa_acesso_servicos

SELECT * FROM scr_eventos_sistema_log_atividades WHERE id_ocorrencia = 701
WITH t AS (
						SELECT 
							'2021-09-25 05:06:33'::date as data_inicial,
							f_prazo_dias_entrega('2021-09-25 05:06:33', rc.tempo_dias, nf.calculado_ate_id_cidade) as prazo_dias					
						FROM 
							scr_notas_fiscais_imp nf
							LEFT JOIN regiao_cidades rc
								ON rc.id_cidade = nf.calculado_ate_id_cidade
							LEFT JOIN regiao_remetentes rr
								ON rr.id_regiao = rc.id_regiao
						WHERE 
							nf.id_nota_fiscal_imp = 234172
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

WITH t AS (
	SELECT 
		'2021-09-02 14:40:50'::date as data_inicial,
		f_prazo_dias_entrega('2021-09-02 14:40:50', rc.tempo_dias, nf.calculado_ate_id_cidade) as prazo_dias					
	FROM 
		scr_notas_fiscais_imp nf
		LEFT JOIN regiao_cidades rc
			ON rc.id_cidade = nf.calculado_ate_id_cidade
		LEFT JOIN regiao_remetentes rr
			ON rr.id_regiao = rc.id_regiao
	WHERE 
		nf.id_nota_fiscal_imp = 53319
		AND rr.remetente_id = nf.remetente_id
)
SELECT 
	prazo_dias,
	data_inicial + prazo_dias
FROM 
	t;
data_previsao_entrega

SELECT COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA','001')::integer,0);
v_operacao_por_nota = COALESCE(f_get_parametro_sistema('PST_OPERACAO_POR_NOTA',v_empresa)::integer,0);

SELECT id_romaneio, numero_romaneio, data_saida, previsao_transferencia, id_setor FROM scr_romaneios WHERE numero_romaneio = '0010010198903'
SELECT fp_set_session('pst_cod_empresa','001')

UPDATE scr_romaneios SET id_romaneio = id_romaneio WHERE id_romaneio = 234172


					SELECT 
						'2021-09-25 05:06:33'::timestamp as data_inicial,
						f_prazo_dias_entrega_dh(
							'2021-09-25 05:06:33', 
							COALESCE(fr.dias_transferencia, 0), 
							COALESCE(fr.horas_previsao_chegada,0), 
							COALESCE(fr.minutos_previsao_chegada,0), 
							regiao.id_cidade_polo
						) as prazo_minutos
					FROM 
						--scr_notas_fiscais_imp nf										
						filial
						LEFT JOIN filial_rotas_tempo fr
							ON fr.id_filial = filial.id_filial						
						LEFT JOIN regiao 
							ON regiao.id_regiao = fr.id_regiao
					WHERE 
						1=1
						AND filial.codigo_empresa = '001'
						AND filial.codigo_filial = '001'
						AND fr.id_regiao = 41
	
*/
CREATE OR REPLACE FUNCTION f_tgg_previsao_entrega_oco()
  RETURNS trigger AS
$BODY$
DECLARE	
	v_id_ocorrencia integer;
	v_data_ocorrencia date;
	v_dias integer;
	v_minutos integer;
	v_data_previsao_entrega date;
	v_data_previsao_entrega_dh timestamp;
	v_previsao_transferencia integer;
	v_previsao_distribuicao integer;
	v_previsao_data_hora integer;
	v_empresa text;
	v_tipo_romaneio text;
BEGIN

	BEGIN 
		
		v_empresa = fp_get_session('pst_cod_empresa');

		v_previsao_transferencia = COALESCE(f_get_parametro_sistema('PST_PRAZO_TRANSFERENCIA',v_empresa)::integer,0);

		v_previsao_distribuicao = COALESCE(f_get_parametro_sistema('PST_PRAZO_DISTRIBUICAO', v_empresa)::integer,0);

		v_previsao_data_hora = COALESCE(f_get_parametro_sistema('PST_PRAZO_DATA_HORA', v_empresa)::integer,0);
		

		v_previsao_transferencia = 1;
		--Calcula Tempo de Entrega de Romaneio de Distribuicao 
		IF v_previsao_distribuicao = 1 THEN 
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
						AND id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
					ORDER BY data_ocorrencia DESC LIMIT 1;
										
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

					v_data_previsao_entrega = COALESCE(v_data_previsao_entrega, current_date + 1);
					v_dias = COALESCE(v_dias,1);
					RAISE NOTICE 'Data ocorrencia % - Data Previsao % - Tempo Dias %', v_data_ocorrencia, v_data_previsao_entrega, v_dias;

					UPDATE scr_notas_fiscais_imp SET 
						data_previsao_entrega = v_data_previsao_entrega
					WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

				END IF;		
				
			END IF;

			
		END IF;

		IF v_previsao_transferencia = 1  THEN 

			RAISE NOTICE 'Previsao de Transferencia';
			IF TG_TABLE_NAME = 'scr_romaneios' THEN 

				IF NEW.cancelado = 1 THEN 
					RETURN NEW;
				END IF;
				IF NOT NEW.tipo_destino = 'T' THEN 
					RETURN NEW;
				END IF;

				WITH t AS (
					SELECT 
						NEW.data_saida as data_inicial,
						f_prazo_dias_entrega_dh(
							NEW.data_saida, 
							COALESCE(fr.dias_transferencia, 0), 
							COALESCE(fr.horas_previsao_chegada,0), 
							COALESCE(fr.minutos_previsao_chegada,0), 
							regiao.id_cidade_polo
						) as prazo_minutos
					FROM 
						--scr_notas_fiscais_imp nf										
						filial
						LEFT JOIN filial_rotas_tempo fr
							ON fr.id_filial = filial.id_filial						
						LEFT JOIN regiao 
							ON regiao.id_regiao = fr.id_regiao
					WHERE 
						1=1
						AND filial.codigo_empresa = NEW.cod_empresa
						AND filial.codigo_filial = NEW.cod_filial
						AND fr.id_regiao = NEW.id_setor
				)
				SELECT 
					prazo_minutos,
					data_inicial +  make_interval(mins := prazo_minutos)
				INTO 
					v_minutos,
					v_data_previsao_entrega_dh
				FROM 
					t;

				--SELECT * FROM filial_rotas_tempo

				v_data_previsao_entrega_dh = COALESCE(v_data_previsao_entrega_dh, NEW.data_saida::date + 1);
				v_minutos = COALESCE(v_minutos,1);

				RAISE NOTICE 'Data saida % - Data Previsao % - Minutos %', NEW.data_saida, v_data_previsao_entrega_dh, v_minutos;

				NEW.previsao_transferencia = v_data_previsao_entrega_dh;

				UPDATE scr_romaneio_nf SET id_romaneio = id_romaneio WHERE id_romaneio = NEW.id_romaneio;

				PERFORM fp_set_session('data_previsao_dh_' || NEW.id_romaneio::text, NEW.previsao_transferencia::text);

				
				
				
			END IF;

			IF TG_TABLE_NAME = 'scr_romaneio_nf' THEN 

				RAISE NOTICE 'Romaneio';
			
				v_data_previsao_entrega_dh = fp_get_session('data_previsao_dh_' || NEW.id_romaneio::text);
				--Se nao tem data de ocorrencia, eh pq ainda aguarda ocorrencia ser registrada
				IF v_data_previsao_entrega_dh IS NOT NULL THEN 			

					UPDATE scr_notas_fiscais_imp SET 
						data_previsao_entrega_dh = v_data_previsao_entrega_dh
					WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

				END IF;		
				
			END IF;		

		END IF;
	
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'ERRO ****************************************%', SQLERRM;
		RETURN NEW;
	END;
     
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


DROP TRIGGER tgg_previsao_entrega_3 ON scr_romaneios;
CREATE TRIGGER tgg_previsao_entrega_3
BEFORE INSERT OR UPDATE 
ON scr_romaneios
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_previsao_entrega_oco();