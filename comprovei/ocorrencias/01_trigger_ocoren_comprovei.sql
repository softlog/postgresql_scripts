/*
SELECT id_nota_fiscal_imp FROM scr_notas_fiscais_imp WHERE chave_nfe = '35210845453214001042550210005449981501567492'

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 20383885


UPDATE scr_notas_fiscais_imp_ocorrencias SET id_ocorrencia_nf = id_ocorrencia_nf WHERE id_ocorrencia_nf = 27152493


				SELECT * FROM fila_envio

				BEGIN;
				WITH t AS (
					SELECT 
						fila.id,
						nf.id_nota_fiscal_imp,
						nf.remetente_id,
						cliente.nome_cliente,
						sub.*			
					FROM 	
						fila_envio_romaneios fila		
						LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo			
							ON nfo.id_ocorrencia_nf = fila.id_ocorrencia_nf
						LEFT JOIN scr_notas_fiscais_imp nf 
							ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp
						LEFT JOIN msg_subscricao sub
							ON sub.codigo_cliente = nf.remetente_id AND sub.id_notificacao = 1000
						LEFT JOIN cliente
							ON cliente.codigo_cliente = sub.codigo_cliente			
						
					WHERE
						fila.id_notificacao = 1000
						AND fila.id_tipo_servico = 301
						AND id_subscricao IS NULL
						--AND sub.ativo = 1
				)
				DELETE FROM fila_envio_romaneios
				USING t
				WHERE t.id = fila_envio_romaneios.id;
				ROLLBACK;	
				COMMIT;

SELECT * FROM fila_envio_romaneios WHERE id_ocorrencia_nf = 27152493
                        WHERE
                    		id_tipo_servico = 301
                    		AND id_notificacao = 1000
                    		AND status_envio = 0


SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 2 LIMIT 1
SELECT id_nota_fiscal_imp, remetente_nome FROM v_mgr_notas_fiscais WHERE chave_nfe = '35210802057329000114550000011849911269971385'

SELECT * FROM fila_envio_romaneios WHERE id IN (9787)

DELETE FROM fila_envio_romaneios WHERE id_tipo_servico = 301 AND data_registro <= '2021-09-16 17:00:00'


SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 ORDer BY 1 DESC 
SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 ORDER By data_registro DESC

SELECT codigo_cliente FROM cliente WHERE cnpj_cpf = '45453214001042'

SELECT fp_set_session('pst_cod_empresa', '008')
BEGIN;
WITH t AS (
	SELECT 
		nf.id_nota_fiscal_imp,
		nfo.id_ocorrencia_nf,
		nfo.data_registro
	FROM 
		scr_notas_fiscais_imp nf
		LEFT JOIN scr_notas_fiscais_imp_ocorrencias nfo
			ON nfo.id_nota_fiscal_imp = nf.id_nota_fiscal_imp	
	WHERE 
		remetente_id = 6
		AND nfo.data_registro::timestamp >= '2021-09-29 11:00:00'::timestamp
		AND nfo.id_ocorrencia = 1	

)
UPDATE scr_notas_fiscais_imp_ocorrencias nfo SET id_ocorrencia_nf = nfo.id_ocorrencia_nf FROM t WHERE t.id_ocorrencia_nf = nfo.id_ocorrencia_nf
COMMIT

SELECT * FROM 
SELECT * FROM edi_ocorrencias_entrega WHERE id_ocorrencia_nf = 27458569
SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 20639842
SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp = 20639842 ORDER BY 1 
id_ocorrencia_nf = 27528939

SELECT * FROM scr-20639842
SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 AND data_registro >= '2021-09-29 11:00:00'::timestamp

SELECT * FROM edi_ocorrencias_entrega WHERE id_ocorrencia_nf = 27464318

*/

CREATE OR REPLACE FUNCTION f_tgg_ocoren_comprovei()
  RETURNS trigger AS
$BODY$
DECLARE
	v_ocorrencia_comprovei integer;

	v_tem_parametro integer;
	has_comprovei integer;
	v_empresa text;
	v_id_ocorrencia integer;
	vExecuta boolean;
	vVolta integer;
	vEmpresa text;
	vEntregue integer;
	
BEGIN


	
	
	vEmpresa = fp_get_session('pst_cod_empresa');
	RAISE NOTICE 'EMPRESA %s',vEmpresa;

	BEGIN
		vExecuta = false;


		
		IF TG_TABLE_NAME = 'scr_notas_fiscais_imp_ocorrencias' THEN 
		
			SELECT 	(COALESCE(valor_parametro,'0'))::integer
			INTO 	has_comprovei
			FROM 	parametros 
			WHERE 	cod_empresa = vEmpresa AND upper(cod_parametro) = 'PST_OCORRENCIAS_COMPROVEI';	 
		
		

			RAISE NOTICE 'Comprovei %', has_comprovei;

			IF has_comprovei = 1 THEN 
				vExecuta = True;
			END IF;

			IF vExecuta THEN 
				SELECT softlog_p_comprovei
				INTO vVolta
				FROM edi_ocorrencias_comprovei
				WHERE id_ocorrencia_softlog = NEW.id_ocorrencia;
			END IF;

			IF COALESCE(vVolta,0) = 0 THEN 
				vExecuta = False;
			END IF;
			
			--SELECT * FROM edi_ocorrencias_comprovei
			--SELECT * FROM edi_ocorrencias_entrega LIMIT 1
			--SELECT nome_recebedor FROM scr_notas_fiscais_imp LIMIT 1

			
			IF vExecuta THEN 
				RAISE NOTICE 'Executa Integracao';
				
				SELECT count(*)
				INTO vEntregue
				FROM scr_notas_fiscais_imp_ocorrencias 
				WHERE id_ocorrencia IN (1,2)
					AND data_registro < NEW.data_registro
					AND id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

				IF vEntregue = 1 THEN 
					RETURN NEW;
				END IF;
				
				SELECT 
					count(*)
				INTO 
					v_tem_parametro
				FROM 		

					scr_notas_fiscais_imp nf			
					RIGHT JOIN msg_subscricao sub
						ON sub.codigo_cliente = nf.remetente_id AND sub.id_notificacao = 1000
					LEFT JOIN cliente
						ON cliente.codigo_cliente = sub.codigo_cliente			
				WHERE
					nf.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp
					AND sub.ativo = 1;

				--SELECT * FROM msg_notificacao ORDER BY 1 
				
				IF v_tem_parametro > 0 THEN 
					
				
					--Grava as informações na Fila
					INSERT INTO fila_envio_romaneios (id_notificacao, id_tipo_servico, id_ocorrencia_nf)
					SELECT 
						1000,
						301,
						NEW.id_ocorrencia_nf
					WHERE 
						NOT EXISTS (
							    SELECT 1
							    FROM fila_envio_romaneios
							    WHERE id_tipo_servico = 301
								AND id_notificacao = 1000
								AND id_ocorrencia_nf = NEW.id_ocorrencia_nf
								--AND id_ocorrencia_nf = 27152493
						);
					
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

DROP TRIGGER tgg_ocoren_comprovei_1 ON scr_notas_fiscais_imp_ocorrencias;

CREATE TRIGGER tgg_ocoren_comprovei_1
AFTER INSERT OR UPDATE OR DELETE
ON scr_notas_fiscais_imp_ocorrencias
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_ocoren_comprovei();