/*
	SELECT * FROM scr_programacao_coleta ORDER By 1;

	SELECT * FROM veiculos WHERE placa_veiculo = 'OLH7055'

	SELECT placa_veiculo, placas_engates, id_coleta, id_programacao_coleta FROM col_coletas
	SELECT * FROM scr_programacao_coleta WHERE id = 289

	DELETE FROM col_coletas CASCADE;
	DELETE FROM col_coletas_itens
	DELETE FROM scr_notas_fiscais_imp;
	DELETE FROM scr_programacao_coleta_entrega
	DELETE FROM scr_conhecimento CASCADE
	
	UPDATE scr_programacao_coleta SET id = id WHERE id = 2
	WITH t AS (
				SELECT 
					placa_tracao, 
					placas_engates,
				        trim(unnest(string_to_array(placas_engates,','))) as placa_engate 
				FROM 
					v_frt_veic_tracionado 
			)
			SELECT placa_tracao, placas_engates

			SELECT * FROM veiculos WHERE placa_veiculo = 'NKE7616'
			FROM t WHERE placa_engate = 'NKE7616';	

	
	
*/

CREATE OR REPLACE FUNCTION f_tgg_programacao_coleta()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_coleta integer;
	v_empresa character(3);
	v_filial character(3);
	v_cursor refcursor;
	v_numero_coleta character(13);
	v_codigo_programacao character(13);
	v_placa text;
	v_placa_engates text;
	v_cancelado integer;

	
BEGIN

	--Verifica se tem coleta para esta programacao/base

	SELECT id_coleta, cancelado
	INTO v_id_coleta, v_cancelado
	FROM col_coletas
	WHERE col_coletas.id_programacao_coleta = NEW.id;
	

	SELECT codigo_empresa, codigo_filial 
	INTO v_empresa, v_filial
	FROM filial 
	WHERE cnpj = NEW.cnpj_transportador;


	

	IF NEW.status <> 'Cancelado' THEN 
		--Se nao tiver, inclui
		IF v_id_coleta IS NULL THEN 

			WITH t AS (
				SELECT 
					placa_tracao, 
					placas_engates,
				        trim(unnest(string_to_array(placas_engates,','))) as placa_engate 
				FROM 
					v_frt_veic_tracionado 
			)
			SELECT placa_tracao, placas_engates
			INTO v_placa, v_placa_engates
			FROM t WHERE placa_engate = NEW.placa;		

			IF v_placa IS NULL THEN 
				SELECT placa_veiculo 
				INTO v_placa
				FROM veiculos
				WHERE placa_veiculo = NEW.placa;
			END IF;	
		
			OPEN v_cursor FOR 
			INSERT INTO col_coletas(
				
				id_coleta_filial, --2
				filial_coleta, --3
				cod_empresa, --4
				data_solicitacao, --5
				hora_solicitacao, --6
				id_remetente, --7
				remetente_nome, --8			
				remetente_inscricao, --10
				id_end_remetente, --11			
				remetente_telefone, --19		
				id_consignatario, --33			
				consignatario_nome, --35
				consignatario_inscricao, --36
				id_end_consignatario, --37			
				consignatario_telefone, --45					
				data_coleta, --53
				hora_coleta, --54
				cod_interno_frete, --55
				id_programacao_coleta, --56
				placa_veiculo, --57.1
				placas_engates, --57.2
				tipo_frete, --58
				emitido, --59
				alarme_prazo, --60
				saida_coleta --61
				

			)
			WITH t AS (
				SELECT 
					(v_empresa || v_filial || 		
					trim(to_char(proximo_numero_sequencia('col_coletas_' || v_empresa || '_' || v_filial),'0000000'))) as numero_coleta,
					v_filial as codigo_filial,
					v_empresa as codigo_empresa,
					NEW.data,
					to_char(NEW.hora_prevista_carregamento,'HH24MI') as hora,			
					NEW.cnpj_pagador as remetente_cnpj,				
					CASE WHEN NEW.frete_cif_fob = 'CIF' THEN trim(NEW.cnpj_pagador) ELSE NULL END::character(14) as consignatario_cnpj,
					NEW.codigo_programacao,			
					CASE WHEN NEW.entrada IS NOT NULL THEN NEW.data ELSE NULL END as data_coleta,
					CASE WHEN NEW.entrada IS NOT NULL THEN to_char(NEW.entrada,'HH24MI') ELSE NULL END as hora_coleta							
					
			
			)
			SELECT 
				t.numero_coleta, --2
				t.codigo_filial, --3
				t.codigo_empresa, --4
				t.data, --5
				t.hora, --6			
				r.codigo_cliente, --7
				r.nome_cliente, --8			
				r.inscricao_estadual, --10
				re.id_endereco, --11						
				re.telefone, --19 		
				c.codigo_cliente, --33
				c.nome_cliente, --34			
				c.inscricao_estadual, --36
				ce.id_endereco, --37			
				ce.telefone, --45
				t.data_coleta, --53
				t.hora_coleta, --54	
				t.codigo_programacao, --55
				NEW.id, --56
				v_placa, --57.1
				v_placa_engates, --57.2
				CASE WHEN NEW.frete_cif_fob = 'CIF' THEN 1 ELSE 2 END,
				1, --59
				NULL,
				CASE WHEN NEW.saida IS NOT NULL THEN (NEW.data::text || ' ' || NEW.saida::text)::timestamp ELSE NULL END
			FROM
				t
				LEFT JOIN cliente r ON t.remetente_cnpj = r.cnpj_cpf
				LEFT JOIN cliente_enderecos re ON re.codigo_cliente = r.codigo_cliente AND re.id_tipo_endereco = 3
				LEFT JOIN cidades rc ON rc.id_cidade = re.id_cidade		

				LEFT JOIN cliente c ON t.consignatario_cnpj = c.cnpj_cpf
				LEFT JOIN cliente_enderecos ce ON ce.codigo_cliente = c.codigo_cliente AND ce.id_tipo_endereco = 3
				LEFT JOIN cidades cc ON cc.id_cidade = ce.id_cidade
			RETURNING
				id_coleta, id_coleta_filial, cod_interno_frete;

			FETCH v_cursor INTO v_id_coleta, v_numero_coleta, v_codigo_programacao;

			CLOSE v_cursor;

			UPDATE col_coletas SET remetente_cnpj = NEW.cnpj_pagador WHERE id_coleta = v_id_coleta;

			IF NEW.frete_cif_fob = 'CIF' THEN 
				UPDATE col_coletas SET consignatario_cnpj = NEW.cnpj_pagador WHERE id_coleta = v_id_coleta;
			END IF;


			
			INSERT INTO col_coletas_itens(
				id_coleta, 
				quantidade, 
				peso, 
				vol_m3, 
				valor_nota_fiscal
			)
			SELECT 
				v_id_coleta,
				0,
				0,
				0,
				0;
			
			INSERT INTO col_log_atividades(
				id_coleta_filial, 
				data_hora, 
				atividade_executada, 
				usuario)
			VALUES 
				(
				v_numero_coleta,
				now(),
				'COLETA GERADA DA PROGRAMACAO N.: ' || trim(v_numero_coleta),
				'SUPORTE'
			);			
			
		END IF;

		IF TG_OP = 'UPDATE' THEN 
			IF OLD.entrada IS NULL AND NEW.entrada IS NOT NULL THEN 
				UPDATE col_coletas SET data_coleta = NEW.data, hora_coleta = to_char(NEW.entrada,'HH24MI') WHERE id_coleta = v_id_coleta;
				
				INSERT INTO col_log_atividades(
					id_coleta_filial, 
					data_hora, 
					atividade_executada, 
					usuario)
				VALUES 
					(
					v_numero_coleta,
					now(),
					'COLETA ATUALIZADA PROGRAMACAO N.: ' || trim(NEW.codigo_programacao),
					'SUPORTE'
				);			
			END IF;			

			IF OLD.saida IS NULL AND NEW.saida IS NOT NULL THEN 
				UPDATE col_coletas SET 
					saida_coleta = (NEW.data::text || ' ' || NEW.saida::text)::timestamp 
				WHERE id_coleta = v_id_coleta;				
			END IF;			

		END IF;
	
		--Se tiver, verificar se precisa alterar
	END IF;




	--Se programacao for cancelada, cancelar coleta
	IF NEW.status = 'Cancelado' THEN 
		IF v_id_coleta IS NOT NULL AND v_cancelado = 0 THEN 
		
			UPDATE col_coletas SET cancelado = 1 WHERE id_coleta = v_id_coleta;

			INSERT INTO col_log_atividades(
				id_coleta_filial, 
				data_hora, 
				atividade_executada, 
				usuario)
			VALUES 
				(
				v_numero_coleta,
				now(),
				'COLETA CANCELADA DE PROGRAMACAO N.: ' || trim(NEW.codigo_programacao),
				'SUPORTE'
			);	
		END IF;
	END IF;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

/*
SELECT placa_veiculo, placas_engates, id_programacao_coleta FROM col_coletas;

SELECT * FROM scr_programacao_coleta WHERE id = 280
*/