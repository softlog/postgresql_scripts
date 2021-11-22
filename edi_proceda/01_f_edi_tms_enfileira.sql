-- Function: public.f_edi_tms_enfileira(integer, timestamp without time zone, timestamp without time zone)

/*

SELECT * FROM edi_tms_agenda_envio WHERE id_banco_dados = 73
SELECT * FROM string_conexoes WHERE id_string_conexao = 75

SELECT * FROM now()

SELECT data_importacao - lead(data_importacao) over (partition by 1 order by data_importacao DESC) as intervalo, * FROM email_uid_imap WHERE status = 1 ORDER BY data_importacao DESC LIMIT  100 

SELECT * FROM email_uid_imap WHERE status = 0 order by DATA_REGISTRO desc
WHERE status = 0 


SELECT f_edi_tms_enfileira(
    9,
    now()::timestamp,
    '2021-09-01 00:00:00');
    
SELECT * FROM empresa_acesso_servicos;
UPDATE empresa_acesso_servicos SET codigo_acesso = 'xml-nfe' WHERE id = 3;
SELECT * FROM msg_edi_lista_chaves ORDER BY 1 DESC LIMIT 100
SELECT  f_edi_tms_enfileira(5,now()::timestamp, null::timestamp);
SELECT * FROM scr_doc_integracao
SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_ocorrencia_nf IN (19149463, 19143235);

SELECT * FROM edi_tms_embarcadores ORDER BY 1;
SELECT * FROM empresa_acesso_servicos
SELECT * FROM scr_notas_fiscais_imp 
UPDATE empresa_acesso_servicos SET codigo_acesso = '\Faturamento\TR0000129800\Entrada';

SELECT * FROM msg_edi_lista_chaves ORDER BY 1 DESC LIMIT 100;

--DROP FUNCTION public.f_edi_tms_enfileira(integer, timestamp without time zone, timestamp without time zone);

SELECT * FROM edi_tms_embarcador_docs


SELECT
*


FROM email_uid_imap

ORDER BY id DESC LIMIT 1000

SELECT data_registro FROM scr_notas_fiscais_imp ORDER By 1 DESC LIMIT 100


*/



CREATE OR REPLACE FUNCTION public.f_edi_tms_enfileira(
    p_id_subscricao integer,
    p_data_ref timestamp without time zone,
    p_ultimo_processamento timestamp without time zone)
  RETURNS integer AS
$BODY$
DECLARE
        v_id_doc integer;
        v_cnpj_cliente text;
        v_tipo_doc integer;
        v_id_embarcador integer;
        v_data_ini timestamp;
        v_data_fim timestamp;
        v_tipo_evento integer;
        v_id_bd integer;
        v_proximo_processamento timestamp;
        v_horario character(4);
        v_periodo integer;
        v_id integer;
        v_operacao_por_nota text;
        
BEGIN	
	/*
		Vers�o em teste em assislog. Estudar como parametrizar no embarcador, para rodar em todos clientes softlog.
		
	*/
	SELECT 	COALESCE(MAX(valor_parametro),'0')
	INTO 	v_operacao_por_nota 
	FROM 	parametros 
	WHERE 	upper(cod_parametro) = 'PST_OPERACAO_POR_NOTA';	

	RAISE NOTICE 'Tipo operacao %', v_operacao_por_nota;
	
	--Recupera informacoes necessarias para filtrar os documentos
	SELECT 
		ed.id_doc,		
		ed.tipo_evento,
		e.cnpj_cliente,
		d.tipo_doc,
		e.id_embarcador,
		ed.tipo_evento,
		ed.horario,
		ed.periodo
	INTO 
		v_id_doc,
		v_tipo_evento,
		v_cnpj_cliente,
		v_tipo_doc,
		v_id_embarcador,
		v_tipo_evento,
		v_horario,
		v_periodo
	FROM 
		edi_tms_embarcador_docs ed
		LEFT JOIN edi_tms_embarcadores e 
			ON e.id_embarcador = ed.id_embarcador
		LEFT JOIN edi_tms_docs d
			ON d.id_doc = ed.id_doc				
	WHERE 
		ed.id_embarcador_doc = p_id_subscricao;


	
		
	-- Define filtro de datas de acordo com o tipo de evento

	v_data_fim := p_data_ref;	

	IF v_tipo_evento = 1 THEN 
		v_data_ini = v_data_fim - make_interval(months :=1);
	END IF;

	IF v_tipo_evento = 2 THEN 
		v_data_ini = v_data_fim - make_interval(weeks := 1);
	END IF;

	IF v_tipo_evento = 3 THEN 
		v_data_ini = v_data_fim - make_interval(days := 1);
	END IF;	

	IF v_tipo_evento = 6 THEN 
		v_data_ini = v_data_fim - make_interval(mins := v_periodo);
	END IF;	

	--Se o último processamento for menor que o inicio do intervalo 
	-- então utiliza este como inicio do período da seleção.
	IF v_data_ini IS NOT NULL THEN 
		IF v_data_ini > p_ultimo_processamento THEN 
			v_data_ini = p_ultimo_processamento;
		END IF;
	END IF;


	RAISE NOTICE 'Tipo doc %',v_tipo_doc::text;
	
	-- Enfileira Conembs
	IF v_tipo_doc = 1 THEN 
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves		
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,
			string_agg(id_conhecimento::text,',')
		FROM
			scr_conhecimento
		WHERE
			data_emissao >=  v_data_ini
			AND data_emissao <= v_data_fim
			AND consig_red_cnpj = v_cnpj_cliente
			AND cancelado = 0
		GROUP BY
			empresa_emitente,
			filial_emitente,
			consig_red_id;
	END IF;

	-- Enfileira Ocoren por conhecimentos embarcados
	IF v_tipo_doc = 2 AND v_operacao_por_nota = '0' THEN 
		RAISE NOTICE 'OCOREN por CTE';
		
		--PERFORM f_debug('Data Ini',v_data_ini::text);
		--PERFORM f_debug('Data Fim',v_data_fim::text);
		--PERFORM f_debug('Data Fim',v_cnpj_cliente);
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			SELECT 
				1::integer as id,
				consig_red_id,
				empresa_emitente,
				filial_emitente,
				c.id_conhecimento
			FROM
				scr_conhecimento c 			
				LEFT JOIN scr_conhecimento_notas_fiscais nf
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE			
				c.data_emissao  >= v_data_ini 
				AND 
				c.data_emissao  < v_data_fim 
				AND trim(consig_red_cnpj) = trim(v_cnpj_cliente)
			UNION 
			--Seleciona as entregas por data de registro
			SELECT 			
				2::integer as id,
				consig_red_id,
				empresa_emitente,				
				filial_emitente,
				c.id_conhecimento
			FROM
				scr_conhecimento c 			
				LEFT JOIN scr_conhecimento_ocorrencias_nf nf
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE			
				--f_data_entrega(c.data_entrega,c.hora_entrega)  >= v_data_ini 
				nf.data_registro  >= v_data_ini 
				AND 
				--f_data_entrega(c.data_entrega,c.hora_entrega)  < v_data_fim 
				nf.data_registro  < v_data_fim 
				AND trim(c.consig_red_cnpj) = trim(v_cnpj_cliente)
				AND data_entrega IS NOT NULL
			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,			
			string_agg(id_conhecimento::text,',')
			
		FROM 
			t
		GROUP BY 
			consig_red_id,
			empresa_emitente,
			filial_emitente	;
	END IF;



	-- Enfileira Ocoren da Vytra por conhecimentos embarcados
	IF v_tipo_doc = -2 AND v_operacao_por_nota = '0' THEN 
		
		RAISE NOTICE 'Data Ini %',v_data_ini;
		RAISE NOTICE 'Data Fim %',v_data_fim;
		RAISE NOTICE 'Cliente %',v_cnpj_cliente;
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			
			--Seleciona as entregas por data de registro
			SELECT 			
				2::integer as id,
				consig_red_id,
				empresa_emitente,				
				filial_emitente,
				id_conhecimento_ocorrencia_nf
			FROM
				scr_conhecimento c 			
				LEFT JOIN scr_conhecimento_ocorrencias_nf nf
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE			
				--f_data_entrega(c.data_entrega,c.hora_entrega)  >= v_data_ini 
				nf.data_registro  >= v_data_ini 
				AND 
				--f_data_entrega(c.data_entrega,c.hora_entrega)  < v_data_fim 
				nf.data_registro  < v_data_fim 
				AND trim(c.remetente_cnpj) = trim(v_cnpj_cliente)
				--AND data_entrega IS NOT NULL
			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,			
			id_conhecimento_ocorrencia_nf::text
			
		FROM 
			t;

			
	END IF;


	-- Enfileira Ocoren da SSW por conhecimentos embarcados
	IF v_tipo_doc = -3 THEN 
	
		RAISE NOTICE 'Data Ini %',v_data_ini;
		RAISE NOTICE 'Data Fim %',v_data_fim;
		RAISE NOTICE 'Cliente %',v_cnpj_cliente;
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			
			--Seleciona as entregas por data de registro
			SELECT 			
				2::integer as id,
				consig_red_id,
				empresa_emitente,				
				filial_emitente,
				id_conhecimento_ocorrencia_nf
			FROM
				scr_conhecimento c 			
				LEFT JOIN scr_conhecimento_ocorrencias_nf nf
					ON c.id_conhecimento = nf.id_conhecimento
			WHERE			
				--f_data_entrega(c.data_entrega,c.hora_entrega)  >= v_data_ini 
				nf.data_registro  >= v_data_ini 
				AND 
				--f_data_entrega(c.data_entrega,c.hora_entrega)  < v_data_fim 
				nf.data_registro  < v_data_fim 
				AND trim(c.consig_red_cnpj) = trim(v_cnpj_cliente)
				--AND data_entrega IS NOT NULL
			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,			
			id_conhecimento_ocorrencia_nf::text
			
		FROM 
			t;

			
	END IF;


	-- Enfileira Ocoren da SSW por NFe embarcada
	IF v_tipo_doc = -4 THEN 
		
		RAISE NOTICE 'Data Ini %',v_data_ini;
		RAISE NOTICE 'Data Fim %',v_data_fim;
		RAISE NOTICE 'Cliente %',v_cnpj_cliente;

		--SELECT * FROM filial WHERE cnpj = '19035166000171'
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			--SELECT * FROM v_mgr_notas_fiscais LIMIT 1
			--Seleciona as entregas por data de registro
			SELECT 			
				2::integer as id,
				nf.consignatario_id,
				empresa_emitente,				
				filial_emitente,
				id_ocorrencia_nf
			FROM
				v_mgr_notas_fiscais nf 			
				LEFT JOIN scr_notas_fiscais_imp_ocorrencias onf
					ON nf.id_nota_fiscal_imp = onf.id_nota_fiscal_imp
			WHERE			
				--f_data_entrega(c.data_entrega,c.hora_entrega)  >= v_data_ini 
				onf.data_registro  >= v_data_ini 
				AND 
				--f_data_entrega(c.data_entrega,c.hora_entrega)  < v_data_fim 
				onf.data_registro  < v_data_fim 
				AND trim(nf.pagador_cnpj) = trim(v_cnpj_cliente)
				--AND data_entrega IS NOT NULL
			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,			
			id_ocorrencia_nf::text
			
		FROM 
			t;
			
	END IF;


	-- Enfileira Ocoren por notas fiscais embarcadas
	IF v_tipo_doc = 2 AND v_operacao_por_nota = '1' THEN 
	
		RAISE NOTICE 'Entrei em Operacao por Nota'; 
		RAISE NOTICE 'Data Ini %', v_data_ini;
		RAISE NOTICE 'Data Fim %', v_data_fim;
		RAISE NOTICE 'CNPJ %', v_cnpj_cliente;
		
		--PERFORM f_debug('Data Ini',v_data_ini::text);
		--PERFORM f_debug('Data Fim',v_data_fim::text);
		--PERFORM f_debug('Data Fim',v_cnpj_cliente);
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			SELECT 			
				3::integer as id,
				nf.consignatario_id,
				COALESCE(c.empresa_responsavel,nf.empresa_emitente) as empresa_emitente,			
				nf.filial_emitente,
				nfo.id_ocorrencia_nf
		FROM 
			scr_notas_fiscais_imp_ocorrencias nfo
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = nfo.id_nota_fiscal_imp
			LEFT JOIN cliente c
				ON c.codigo_cliente = nf.consignatario_id
			LEFT JOIN scr_ocorrencia_edi 	o	
				ON nfo.id_ocorrencia = o.codigo_edi 	
			LEFT JOIN scr_ocorrencia_obs_edi obs	
				ON nf.id_ocorrencia_obs = obs.codigo_edi_obs 
			LEFT JOIN filial f 
				ON f.codigo_empresa = c.empresa_responsavel AND f.codigo_filial = nf.filial_emitente
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = c.empresa_responsavel
		WHERE			
			nfo.data_registro  >= v_data_ini 				
			AND nfo.data_registro  < v_data_fim 
			AND trim(cnpj_cpf) = trim(v_cnpj_cliente)
-- 			AND CASE WHEN current_database() = 'softlog_assislog' THEN true ELSE o.codigo_edi <> 0 END			
-- 			AND o.ocorrencia_coleta = 0
-- 			AND CASE WHEN current_database() = 'softlog_assislog' THEN true ELSE o.publica = 1 END			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,	
			string_agg(id_ocorrencia_nf::text,',')			
		FROM 
			t
		GROUP BY 
			consignatario_id,
			empresa_emitente,
			filial_emitente	;
	END IF;



	--Enfileira Ocoren por Historico de Ocorrencia
	IF v_tipo_doc = 4 THEN 
	
		--PERFORM f_debug('Data Ini',v_data_ini::text);
		--PERFORM f_debug('Data Fim',v_data_fim::text);
		--PERFORM f_debug('Cliente',v_cnpj_cliente);
		
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			SELECT 
				1::integer as id,
				consig_red_id,
				empresa_emitente,
				filial_emitente,
				o.id_conhecimento_ocorrencia_nf, 
				now()
			FROM
				scr_conhecimento_ocorrencias_nf o
				LEFT JOIN scr_conhecimento c
					ON c.id_conhecimento = o.id_conhecimento
			WHERE			
				o.data_registro  >= v_data_ini 
				AND 
				o.data_registro < v_data_fim 
				AND trim(consig_red_cnpj) = trim(v_cnpj_cliente)
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			v_id_embarcador,
			v_id_doc,			
			string_agg(id_conhecimento_ocorrencia_nf::text,',')
		FROM 
			t
		GROUP BY 
			consig_red_id,
			empresa_emitente,
			filial_emitente;
	END IF;

	-- Enfileira Doccob
	IF v_tipo_doc = 3 THEN 
		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		SELECT 
			codigo_empresa,
			codigo_filial,
			v_id_embarcador,
			v_id_doc,
			string_agg(f.id_faturamento::text,',')
		FROM
			scr_faturamento f
		WHERE
			f.data_emissao >= v_data_ini 
			AND f.data_emissao < v_data_fim
			AND f.fatura_cnpj = v_cnpj_cliente
		GROUP BY
			codigo_empresa,
			codigo_filial,
			fatura_sacado_id;
	END IF;	

	-- Enfileira Abastecimento
	IF v_tipo_doc = 7 THEN 
		INSERT INTO msg_edi_lista_chaves(
			id_doc, 
			id_embarcador, 			
			data_ref			
		)
		SELECT 
			v_id_doc,
			v_id_embarcador,
			generate_series(v_data_ini,v_data_fim - make_interval(days := 1),'1 day');
		
	END IF;

	
	-- Enfileira Importacao XML-NFe-Mail
	-- Nesta Fila o tipo_doc e usado para direcionar para o script de importacao
	IF v_tipo_doc IN (8,9,10,12, 14, 16) THEN 
		
		INSERT INTO msg_edi_lista_chaves(
			id_doc, 
			id_embarcador, 			
			data_ref,			
			id_notificacao						
		)
		SELECT 
			v_id_doc,
			v_id_embarcador,
			current_date,
			v_tipo_doc::integer;		
	END IF;




	SELECT id_string_conexao 
	INTO v_id_bd
	FROM string_conexoes
	WHERE banco_dados = current_database();

	v_proximo_processamento = f_edi_tms_proximo_processamento(v_tipo_evento, 
								  v_periodo,
								  v_horario,
								  v_data_fim								  
								  );
								  

	RAISE NOTICE 'Proximo Processamento %',v_proximo_processamento;
	UPDATE edi_tms_agenda_envio SET 
		ultimo_processamento  = v_data_fim,
		proximo_processamento = v_proximo_processamento
	WHERE 
		id_subscricao = p_id_subscricao
		AND id_banco_dados = v_id_bd;

	--SELECT * FROM edi_tms_agenda_envio SET ultimo_processamento = v_data_ref
	
	RETURN 0;
	        
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
