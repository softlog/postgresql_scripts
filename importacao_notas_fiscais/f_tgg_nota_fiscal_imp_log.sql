-- Function: public.f_tgg_nota_fiscal_imp_log()

-- DROP FUNCTION public.f_tgg_nota_fiscal_imp_log();

CREATE OR REPLACE FUNCTION public.f_tgg_nota_fiscal_imp_log()
  RETURNS trigger AS
$BODY$
DECLARE
	v_atividade_executada text;
	v_login text;
	vTipoEspecificoImport text;
	vAtividadeExecutada text;
	vLogAtividade text;
	v_historico text;
BEGIN

	v_login = fp_get_session('pst_login');
	v_historico = NULL;
	--Verifica se teve opera��o via formul�rio
	vAtividadeExecutada = fp_get_session('ATIVIDADE_EXECUTADA');
	--RAISE NOTICE 'Logando com Atividade Executada %', vAtividadeExecutada;
	IF vAtividadeExecutada IS NOT NULL THEN 

		CASE 
			WHEN vAtividadeExecutada = 'NOVO' 	THEN 
				vLogAtividade = 'INCLUIDO MANUALMENTE';
			WHEN vAtividadeExecutada = 'EDITAR' 	THEN
				vLogAtividade = 'ALTERADO';
			WHEN vAtividadeExecutada = 'BAIXA' 	THEN
				vLogAtividade = 'BAIXA. Cod.Ocorr�ncia: ' || COALESCE(NEW.id_ocorrencia::text,'S.Ocorrencia');
			WHEN vAtividadeExecutada = 'BAIXA NOTREXO' 	THEN
				vLogAtividade = 'BAIXA. via NOTREXO: ' || COALESCE(NEW.id_ocorrencia::text,'S.Ocorrencia');
			WHEN vAtividadeExecutada = 'GED' 	THEN
				vLogAtividade = 'BAIXA. via InfoGED: ' || COALESCE(NEW.id_ocorrencia::text,'S.Ocorrencia');
			WHEN vAtividadeExecutada = 'ROMANEADO'  THEN 
				--Se id do Romaneio est� nulo;
				IF NEW.id_romaneio IS NULL THEN					
					--Pode ter sido exclu�do noutra opera��o.
					IF OLD.id_romaneio IS NOT NULL THEN 
						vLogAtividade 	= 'REMOVIDO DE ROMANEIO';
						v_historico 		= 'Excluido do Romaneio id: ' || OLD.id_romaneio::text;
					END IF; 
				END IF;

				--Se o id do romaneio n�o est� nulo.
				IF NEW.id_romaneio IS NOT NULL THEN 
					--N�o estava ligado a nenhum romaneio
					IF OLD.id_romaneio IS NULL THEN 
						vLogAtividade = 'INCLUIDO EM ROMANEIO';
						v_historico = 'Incluido em Romaneio id: ' || NEW.id_romaneio;
					ELSE
						--Estava ligado a outro romaneio
						IF NEW.id_romaneio <> OLD.id_romaneio THEN 
							vLogAtividade = 'ROMANEIO SUBSTITUIDO';
							v_historico = 'De Romaneio: ' || OLD.id_romaneio::text || ' para ' || NEW.id_romaneio::text;
						END IF;
					END IF;
				END IF;				
					
			WHEN vAtividadeExecutada = 'BAIXA' THEN
				vLogAtividade = 'BAIXA. Cod.Ocorr�ncia: ' || COALESCE(NEW.id_ocorrencia::text,'S.Ocorrencia');
			ELSE
				vLogAtividade = vAtividadeExecutada;
		END CASE;

		--RAISE NOTICE 'Log Atividade %', vLogAtividade;
		INSERT INTO scr_notas_fiscais_imp_log_atividades(
			id_nota_fiscal_imp, 
			data_hora, 
			atividade_executada, 
			usuario,
			historico
			)
		VALUES (
			NEW.id_nota_fiscal_imp,
			now(),
			vLogAtividade,
			v_login,
			v_historico
		);

		-- PERFORM fp_set_session('ATIVIDADE_EXECUTADA',NULL);
	ELSE
		--Se n�o foi via formul�rio, verifica origem da importa��o 
		vTipoEspecificoImport	= fp_get_session('pst_tipo_especifico_importacao');
		--RAISE NOTICE 'Log %', vTipoEspecificoImport;
		-- Grava log de Ocorr�ncias de importa��o
		IF vTipoEspecificoImport IS NOT NULL THEN 
			vTipoEspecificoImport = 'Entrada: ' || LEFT(vTipoEspecificoImport,40);
			INSERT INTO scr_notas_fiscais_imp_log_atividades(
				id_nota_fiscal_imp, 
				data_hora, 
				atividade_executada, 
				usuario 
				)
			VALUES (
				NEW.id_nota_fiscal_imp,
				now(),
				vTipoEspecificoImport,
				v_login
			);
		ELSE
			IF TG_OP = 'INSERT' THEN 
				vTipoEspecificoImport = 'Importa��o de Desconhecido';
				INSERT INTO scr_notas_fiscais_imp_log_atividades(
					id_nota_fiscal_imp, 
					data_hora, 
					atividade_executada, 
					usuario 
					)
				VALUES (
					NEW.id_nota_fiscal_imp,
					now(),
					vTipoEspecificoImport,
					v_login
				);
			END IF;
		END IF;
	END IF;     
     RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

