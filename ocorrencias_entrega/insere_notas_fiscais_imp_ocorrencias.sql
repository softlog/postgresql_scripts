-- Function: public.insere_notas_fiscais_imp_ocorrencias()

-- DROP FUNCTION public.insere_notas_fiscais_imp_ocorrencias();

CREATE OR REPLACE FUNCTION public.insere_notas_fiscais_imp_ocorrencias()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_nota_fiscal_imp integer;
	v_tentativas_reentrega integer;	
	v_tentativas_devolucao integer;	
	v_tem_devolucao_direta integer;
	
	v_devolucao_direta integer;		
	v_gera_pendencia integer;
	v_gera_reentrega integer;
	v_gera_devolucao integer;
	v_qt_pendencias integer;
	v_gerou_devolucao integer;
	
BEGIN

	PERFORM fp_set_session('codigo_integracao_' || NEW.id_nota_fiscal_imp::text);
	
	
	v_id_nota_fiscal_imp = fp_get_session('id_nota_fiscal_imp')::integer;
	--RAISE NOTICE 'id_nota_fiscal_imp %', v_id_nota_fiscal_imp;

	IF v_id_nota_fiscal_imp = NEW.id_nota_fiscal_imp THEN  
	
		RETURN NULL;
	END IF;
	
	IF TG_OP = 'INSERT'  THEN 
		INSERT INTO scr_notas_fiscais_imp_ocorrencias(
			id_nota_fiscal_imp, 
			id_ocorrencia,
			data_ocorrencia,
			data_registro,
			canhoto,
			obs_ocorrencia)
		 VALUES(
			NEW.id_nota_fiscal_imp,
			NEW.id_ocorrencia,
			COALESCE(NEW.data_ocorrencia, NOW()),
			now(),
			NEW.canhoto,
			NEW.obs_ocorrencia);


	ELSE
		-- Grava ocorrencia no histórico só se tiver alteração de ocorrência
-- 		IF OLD.id_ocorrencia = 1 THEN 
-- 			RETURN NULL;
-- 		END IF;
		
		IF 	COALESCE(OLD.id_ocorrencia,-1) <> COALESCE(NEW.id_ocorrencia, 0) 
			OR COALESCE(OLD.data_ocorrencia,current_date) <> COALESCE(NEW.data_ocorrencia,current_date) 
			OR COALESCE(OLD.canhoto,-1) <> COALESCE(NEW.canhoto, -1)
			OR COALESCE(OLD.obs_ocorrencia,'') <> COALESCE(NEW.obs_ocorrencia,'') 
		THEN 	
			
			
			INSERT INTO scr_notas_fiscais_imp_ocorrencias(
				id_nota_fiscal_imp, 
				id_ocorrencia,
				data_ocorrencia,
				data_registro,
				canhoto,
				obs_ocorrencia)
			 VALUES(
				NEW.id_nota_fiscal_imp,
				NEW.id_ocorrencia,
				COALESCE(NEW.data_ocorrencia, NOW()),
				now(),
				NEW.canhoto,
				NEW.obs_ocorrencia);	


			

			SELECT 	pendencia, gera_reentrega, gera_devolucao, devolucao_direta 
			INTO 	v_gera_pendencia, v_gera_reentrega, v_gera_devolucao, v_devolucao_direta
			FROM 	scr_ocorrencia_edi 
			WHERE 	codigo_edi = NEW.id_ocorrencia;

			--RAISE NOTICE 'Gera Pendencia %', v_gera_pendencia;
			--RAISE NOTICE 'Gera Reentrega %', v_gera_reentrega;
			--RAISE NOTICE 'Gera Devolucao %', v_gera_devolucao;


			v_gerou_devolucao = 0;

			IF v_gera_pendencia = 1 AND v_gera_devolucao = 1  THEN 
				SELECT valor_parametro::integer
				INTO v_tentativas_devolucao
				FROM cliente_parametros
				WHERE codigo_cliente = NEW.consignatario_id
					AND id_tipo_parametro = 142;

						
				v_tentativas_devolucao = COALESCE(v_tentativas_devolucao,0);

				IF v_tentativas_devolucao > 0 THEN 

					SELECT	
						count(*) as qt
					INTO 	
						v_qt_pendencias 
					FROM 	scr_notas_fiscais_imp_ocorrencias oco
						LEFT JOIN scr_ocorrencia_edi edi
							ON edi.codigo_edi = oco.id_ocorrencia
					WHERE 	
						edi.pendencia = 1
						AND oco.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

					IF v_qt_pendencias >= v_tentativas_devolucao THEN 						
						PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 2);
						v_gerou_devolucao = 1;
						--Colocar Flag
					END IF;

				END IF;
			END IF;

			IF v_gera_pendencia = 1 AND  v_devolucao_direta = 1 THEN 

				SELECT valor_parametro::integer
				INTO v_tem_devolucao_direta 
				FROM cliente_parametros
				WHERE codigo_cliente = NEW.consignatario_id
					AND id_tipo_parametro = 143;

				v_tem_devolucao_direta = COALESCE(v_tem_devolucao_direta,0);

				IF v_tem_devolucao_direta = 1 THEN 
					PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 2);
					v_gerou_devolucao = 1;
				END IF;				
	
			END IF;
			
			IF v_gera_pendencia = 1 AND v_gera_reentrega = 1 AND v_gerou_devolucao = 0 THEN 
			
				SELECT valor_parametro::integer
				INTO v_tentativas_reentrega
				FROM cliente_parametros
				WHERE codigo_cliente = NEW.consignatario_id
					AND id_tipo_parametro = 141;
						
				v_tentativas_reentrega = COALESCE(v_tentativas_reentrega,0);

				--RAISE NOTICE 'Tentativas de Reentrega %', v_tentativas_reentrega;
				IF v_tentativas_reentrega > 0 THEN 
					
					SELECT	
						count(*) as qt
					INTO 	
						v_qt_pendencias 
					FROM 	scr_notas_fiscais_imp_ocorrencias oco
						LEFT JOIN scr_ocorrencia_edi edi
							ON edi.codigo_edi = oco.id_ocorrencia
					WHERE 	
						edi.pendencia = 1 AND gera_reentrega = 1
						AND oco.id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;

					IF v_qt_pendencias >= v_tentativas_reentrega AND v_gerou_devolucao = 0 THEN 	
						--RAISE NOTICE 'Replicando nota';
						PERFORM f_replica_nf_via_ocorrencia(NEW.id_nota_fiscal_imp, 3);
						--Colocar Flag
					END IF;

				END IF;
			END IF;		

			
		END IF;
	END IF;

	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
