CREATE OR REPLACE FUNCTION f_tgg_edi_atividades()
  RETURNS trigger AS
$BODY$
DECLARE	
	v_id_romaneio integer;
	cur_romaneio refcursor;		
	v_numero_romaneio character(13);	
	i integer;
	tam integer;
	v_unidade_origem character(3);
	v_unidade_destino character(3);
	v_tipo_frota integer;
	v_proprietario character(14);
	v_usuario character(30);
BEGIN


	--SELECT * FROM edi_romaneios

	--Cria Romaneio 
	IF NEW.id_romaneio IS NULL THEN 


		--Cria o número do romaneio;
		v_numero_romaneio = NEW.codigo_empresa || NEW.codigo_filial ||
			lpad(
				proximo_numero_sequencia('atividades_frota_' ||
					NEW.codigo_empresa || '_' ||
					NEW.codigo_filial)::text,
				7,
				'0'
			);


		SELECT codigo_filial
		INTO v_unidade_origem
		FROM filial
		WHERE id_filial = NEW.id_origem;

		SELECT lpad(codigo_filial_sub,3,'0')
		INTO v_unidade_destino
		FROM filial_sub
		WHERE id_filial_sub = (NEW.id_destino * -1);

		SELECT codigo_filial
		INTO v_unidade_origem
		FROM filial
		WHERE id_filial = NEW.id_origem;

		
		SELECT CASE WHEN frotista = 1 THEN 1 ELSE 3 END, cnpj_cpf_proprietario
		INTO  v_tipo_frota, v_proprietario
		FROM v_veiculos
		WHERE placa_veiculo = NEW.placa_veiculo;


		SELECT login_name
		INTO v_usuario
		FROM usuarios
		WHERE id_usuario = NEW.id_usuario;
		
		OPEN cur_romaneio FOR 
		INSERT INTO PUBLIC.scr_romaneios (
			tipo_romaneio, --(2)
			cod_empresa, --(3)
			cod_filial, --(4)
			numero_romaneio, --(5)
			data_romaneio, --(6)
			id_origem, --(7)
			id_destino, --(8)			
			id_setor, --(8.1)
			data_saida, --(9)
			data_chegada, --(10)
			diarias, --(11)
			baixa, --(12)
			tipo_frota, --(13)
			placa_veiculo, --(14)
			placa_reboque, --(15)
			placa_reboque2, --(16)
			cnpj_cpf_proprietario, --(17)
			capacidade_kg, --(18)
			capacidade_m3, --(19)
			id_motorista,--(20)
			cpf_motorista,--(21)
			numero_tabela_motorista,--(22)
			redespacho,--(23)
			id_transportador_redespacho,--(24)
			numero_tabela_redespacho,--(25)			
			emitido,--(29)
			cancelado,--(30)			
			fechamento,--(49)			
			tipo_modal, --(53)						
			unidade_origem, --54
			unidade_destino, --55
			id_tipo_atividade, --56
			id_produto, --57
			url_odometro, --58
			url_horimetro, --59
			odometro_inicial, --60
			horimetro_inicial, --61
			total_peso, --62
			tipo_rota --63
			
		) VALUES (
			3,--(2)
			NEW.codigo_empresa,--(3)
			NEW.codigo_filial,--(4)
			v_numero_romaneio,--(5)			
			NEW.data_romaneio,--(6)
			NEW.id_origem,--(7)
			(NEW.id_destino) * -1,--(8)
			NULL, --(8.1)
			NEW.data_inicio, --(9) 
			NEW.data_fim, --(10)
			0, --(11)
			1, --(12)
			v_tipo_frota, --(13)
			NEW.placa_veiculo, --(14)
			NULL, --(15)
			NULL, --(16)
			v_proprietario, --(17)
			0, --(18) t.capacidade_kg
			0, --(19) t.capacidade_m3
			NEW.id_motorista, --(20)
			NULL, --(21)
			NULL, --(22) --Numero Tabela Motorista
			NULL, --(23)
			NULL, --(24)
			NULL, --(25)
			1, --(29)
			0, --(30)
			1, --(49)
			1, --(53)
			v_unidade_origem, --54
			v_unidade_destino, --55
			NEW.id_tipo_atividade, --56
			NEW.id_produto, --57
			NEW.url_odometro, --58
			NEW.url_horimetro, --59
			CASE WHEN NEW.odometro_inicial = -1 THEN NULL ELSE NEW.odometro_inicial END, --60
			CASE WHEN NEW.horimetro_inicial = -1 THEN NULL ELSE NEW.horimetro_inicial END, --61
			NEW.peso_carga::numeric(8,2), --62
			NEW.tipo_rota --63		
			
		)		
		RETURNING  id_romaneio;

		FETCH cur_romaneio INTO v_id_romaneio;

		CLOSE cur_romaneio;	

		NEW.id_romaneio = v_id_romaneio;



		INSERT INTO scr_romaneio_log_atividades (
			id_romaneio,
			data_transacao,
			usuario,
			acao_executada
		) VALUES (
			v_id_romaneio,
			NEW.data_registro,
			v_usuario,
			'CADASTRO VIA APLICATIVO SFROTA'
		);
		/*
		
		tam = array_length(NEW.lst_notas,1);

		FOR i IN 1..tam LOOP
			RAISE NOTICE 'Romaneando NF %',NEW.lst_notas[i];
			UPDATE scr_notas_fiscais_imp SET id_romaneio = v_id_romaneio WHERE id_nota_fiscal_imp = NEW.lst_notas[i];
		END LOOP;


	
		-- Recalcula Totais
		WITH t AS (
			SELECT 
				nf.id_romaneio,
				SUM(nf.peso_presumido) as total_peso,
				SUM(nf.volume_presumido) as total_volumes, 
				SUM(nf.volume_cubico) as total_volume_cubado, 
				SUM(nf.valor) as total_nf, 
				0.00 as total_frete			
			FROM 
				scr_notas_fiscais_imp nf			
			WHERE 	
				nf.id_romaneio = v_id_romaneio		
			GROUP BY nf.id_romaneio
				
		)		
		UPDATE scr_romaneios SET  
			total_volume_cubado = t.total_volume_cubado,
			total_volumes = t.total_volumes,
			total_nf = t.total_nf,
			total_frete = t.total_frete,
			total_peso = t.total_peso
		FROM
			t
		WHERE
			t.id_romaneios = scr_romaneios.id_romaneio;		
		*/

		--SELECT * FROM scr_romaneio_log_atividades;
	END IF;

     
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


/*
CREATE TRIGGER tgg_edi_romaneio_atividades
BEFORE INSERT OR UPDATE 
ON edi_romaneios
FOR EACH ROW
WHEN (NEW.tipo_rota = 2)
EXECUTE PROCEDURE f_tgg_edi_atividades()
*/