/*

DELETE FROM col_coletas CASCADE;
DELETE FROM col_coletas_itens CASCADE;
DELETE FROM scr_notas_fiscais_imp CASCADE;
--DELETE FROM scr_programacao_coleta
--SELECT * FROM scr_programacao_coleta_entrega
UPDATE scr_programacao_coleta SET id = id 
SELECT * FROM col_coletas
SELECT f_insere_prog_petrobras(
			'5306',
                        'CIF'::text,
                        13946::integer,
                        'GEPE COM.DER.PETROL.'::text,
                        '4032517755'::text,
                        'PRW3373'::character(8),
                        'Programado'::text,
                        NULL::integer,
                        '23/12/2020'::date,
                        '10:30'::time,
                        NULL::time,
                        NULL::time,
                        NULL::timestamp,
                        NULL::timestamp,
                        '2020-12-23 01:16:00'::timestamp,
                        NULL::timestamp,
                        NULL::timestamp
        ) as id_programacao


	SELECT * FROM scr_programacao_coleta_entrega ORDER BY codigo_programacao
	
*/


CREATE OR REPLACE FUNCTION f_insere_prog_petrobras(
	p_cnpj_transportador text,
	p_codigo_base text,
	p_cif_fob text,	
	p_codigo_cliente integer,
	p_apelido_cliente text,
	p_programacao text,
	p_placa character(8),
	p_status text,
	p_ordem integer,
	p_data date,
	p_hora_marcada time,
	p_entrada time,
	p_saida time,
	p_estimativa timestamp,
	p_eta_original timestamp,
	p_eta_atual timestamp,
	p_chegada_cliente timestamp,
	p_saida_cliente timestamp	
)
  RETURNS integer AS
$BODY$
DECLARE
        v_id integer;
        v_id_entrega integer;
        vCursor refcursor;
        v_cnpj text;
        
BEGIN

	SELECT id
	INTO v_id
	FROM scr_programacao_coleta
	WHERE codigo_programacao =  p_programacao
		AND codigo_base = p_codigo_base;

	IF v_id IS NULL THEN 


		SELECT 	cliente.cnpj_cpf
		INTO 	v_cnpj
		FROM 	cliente_parametros
			LEFT JOIN cliente
				ON cliente.codigo_cliente = cliente_parametros.codigo_cliente
		WHERE 	
			cliente_parametros.id_tipo_parametro = 93 
			AND trim(cliente_parametros.valor_parametro) = p_codigo_base;			
		
		
		OPEN vCursor FOR
		INSERT INTO public.scr_programacao_coleta(	
			cnpj_transportador, --1.0
			codigo_base, --1.1			
			cnpj_pagador, --1.2		
			frete_cif_fob, --2
			codigo_programacao, --5
			placa, --6
			status, --7			
			data, --9
			hora_prevista_carregamento, --10
			entrada, --11
			saida --12
		) VALUES (
			p_cnpj_transportador, --1.0
			p_codigo_base, --1.1
			v_cnpj, --1.2
			p_cif_fob, --2
			p_programacao, --5
			p_placa, --6
			p_status, --7			
			p_data, --9
			p_hora_marcada, --10
			p_entrada, --11
			p_saida --12
					
		) 
		RETURNING id;

		FETCH vCursor INTO v_id;

		CLOSE vCursor;




		--Verifica se existe entrega
		SELECT scr_programacao_coleta_entrega.id 
		INTO v_id_entrega
		FROM scr_programacao_coleta_entrega
			LEFT JOIN scr_programacao_coleta
				ON scr_programacao_coleta.id = scr_programacao_coleta_entrega.id_programacao_coleta					
		WHERE 
			scr_programacao_coleta_entrega.codigo_cliente = p_codigo_cliente
			AND scr_programacao_coleta.codigo_base = p_codigo_base
			AND scr_programacao_coleta.codigo_programacao = p_programacao;

		
		--Insere Programacao Entrega
		IF v_id_entrega IS NULL THEN 

			INSERT INTO public.scr_programacao_coleta_entrega(				
				id_programacao_coleta, --1.1			
				codigo_cliente, --3
				apelido_cliente, --4				
				status, --7
				ordem, --8
				estimativa, --13 
				eta_original, --14
				eta_atual, --15
				chegada_cliente, --16 
				saida_cliente --17			
			) VALUES (
				v_id, --1.1
				p_codigo_cliente, --3
				upper(retira_acento(fpy_limpa_caracteres(p_apelido_cliente))), --4
				p_status, --7
				p_ordem, --8
				p_estimativa, --13
				p_eta_original, --14
				p_eta_atual, --15
				p_chegada_cliente, --16
				p_saida_cliente --17			
			);

		ELSE
			UPDATE scr_programacao_coleta_entrega SET 
				status = p_status,
				ordem = p_ordem,				
				estimativa = p_estimativa,
				eta_original = p_eta_original,
				eta_atual = p_eta_atual,
				chegada_cliente = p_chegada_cliente,
				saida_cliente = p_saida_cliente
			WHERE
				id = v_id;
		END IF;
		
	ELSE
		UPDATE scr_programacao_coleta SET 
			status = p_status,			
			entrada = p_entrada,
			saida = p_saida			
		WHERE
			id = v_id;


		--Verifica se existe entrega
		SELECT scr_programacao_coleta_entrega.id 
		INTO v_id_entrega
		FROM scr_programacao_coleta_entrega
			LEFT JOIN scr_programacao_coleta
				ON scr_programacao_coleta.id = scr_programacao_coleta_entrega.id_programacao_coleta					
		WHERE 
			scr_programacao_coleta_entrega.codigo_cliente = p_codigo_cliente
			AND scr_programacao_coleta.codigo_base = p_codigo_base
			AND scr_programacao_coleta.codigo_programacao = p_programacao;


		IF v_id_entrega IS NULL THEN 
			INSERT INTO public.scr_programacao_coleta_entrega(				
				id_programacao_coleta, --1.1			
				codigo_cliente, --3
				apelido_cliente, --4				
				status, --7
				ordem, --8
				estimativa, --13 
				eta_original, --14
				eta_atual, --15
				chegada_cliente, --16 
				saida_cliente --17			
			) VALUES (
				v_id, --1.1
				p_codigo_cliente, --3
				upper(retira_acento(fpy_limpa_caracteres(p_apelido_cliente))), --4
				p_status, --7
				p_ordem, --8
				p_estimativa, --13
				p_eta_original, --14
				p_eta_atual, --15
				p_chegada_cliente, --16
				p_saida_cliente --17			
			);
		ELSE
			UPDATE scr_programacao_coleta_entrega SET
				status = p_status, --7
				ordem = p_ordem, --8
				estimativa = p_estimativa, --13 
				eta_original = p_eta_original, --14
				eta_atual = p_eta_atual, --15
				chegada_cliente = p_chegada_cliente, --16 
				saida_cliente = p_saida_cliente
			WHERE
				id = v_id_entrega;		
		
		END IF;

	
			
	END IF;
        
	RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;	

 
