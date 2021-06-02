-- Function: public.retorna_regiao_destino_motorista(integer, integer, character)

DROP FUNCTION public.retorna_regiao_destino_motorista(integer, integer, character);

CREATE OR REPLACE FUNCTION public.retorna_regiao_destino_motorista(
    id_regiao_origem integer,
    id_cidade_destino integer,
    p_id_destinatario integer,
    tabela_motorista character)
  RETURNS integer AS
$BODY$
DECLARE
	codigo_regiao_origem ALIAS FOR $1;
	codigo_cidade_destino ALIAS FOR $2;		
	tabela_motorista ALIAS FOR $3;

	vQt integer;
	
	id_regiao_destino integer;

	cur_regiao_destino refcursor;
	cur_regiao_destino_inversa refcursor;	
BEGIN	
	

	IF codigo_regiao_origem = -1 THEN 

		--RAISE NOTICE '%', 'Sem Origem';

		SELECT 
			count(*) 
		INTO 
			vQt
		FROM 
			scr_tabela_motorista
			LEFT JOIN scr_tabela_motorista_regioes ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista			
		WHERE 	scr_tabela_motorista_regioes.id_regiao_destino = -1 				
				AND numero_tabela_motorista = tabela_motorista;

		

		IF vQt > 0 THEN 
			RETURN -1;
		ELSE
			--RAISE NOTICE 'Procurando Destino %', codigo_cidade_destino;

			SELECT 
				regiao_destino.id_regiao as regiao_destino
			INTO 
				id_regiao_destino
			FROM 
				
				scr_tabela_motorista
				LEFT JOIN scr_tabela_motorista_regioes
					ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
				LEFT JOIN regiao_cidades as regiao_destino
					ON scr_tabela_motorista_regioes.id_regiao_destino = regiao_destino.id_regiao
				LEFT JOIN cidades as cidades_destino
					ON regiao_destino.id_cidade = cidades_destino.id_cidade	
				LEFT JOIN cliente 
					ON cliente.codigo_cliente = 
				LEFT JOIN regiao_bairros 
					ON scr_tabela_motorista_regioes.id_regiao_destino = v_regiao_bairros.id_regiao						
				
			WHERE 				
				numero_tabela_motorista = tabela_motorista				
				AND (cidades_destino.id_cidade = codigo_cidade_destino 
					OR
				     regiao_bairros.id_bairro = 
				;

			RETURN id_regiao_destino;
			
		END IF;
	END IF;
	
	OPEN cur_regiao_destino FOR
	SELECT 
		regiao_destino.id_regiao as regiao_destino
	FROM 
		scr_tabela_motorista
		LEFT JOIN scr_tabela_motorista_regioes
			ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
		LEFT JOIN regiao_cidades as regiao_destino
			ON scr_tabela_motorista_regioes.id_regiao_destino = regiao_destino.id_regiao
		LEFT JOIN cidades as cidades_destino
			ON regiao_destino.id_cidade = cidades_destino.id_cidade	
	WHERE 
		numero_tabela_motorista = tabela_motorista
		AND scr_tabela_motorista_regioes.id_regiao_origem = codigo_regiao_origem
		AND cidades_destino.id_cidade = codigo_cidade_destino;
		
	FETCH cur_regiao_destino INTO id_regiao_destino;


	IF FOUND THEN 
		CLOSE cur_regiao_destino;
		RETURN id_regiao_destino;
	ELSE
		CLOSE cur_regiao_destino;
		OPEN cur_regiao_destino_inversa FOR
		SELECT 
			regiao_destino.id_regiao as regiao_destino
		FROM 
			scr_tabela_motorista
			LEFT JOIN scr_tabela_motorista_regioes
				ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
			LEFT JOIN regiao_cidades as regiao_destino
				ON scr_tabela_motorista_regioes.id_regiao_origem = regiao_destino.id_regiao
			LEFT JOIN cidades as cidades_destino
				ON regiao_destino.id_cidade = cidades_destino.id_cidade	
		WHERE 
			numero_tabela_motorista = tabela_motorista
			AND scr_tabela_motorista_regioes.id_regiao_destino = codigo_regiao_origem
			AND cidades_destino.id_cidade = codigo_cidade_destino;
			
		FETCH cur_regiao_destino_inversa INTO id_regiao_destino;

		IF FOUND THEN 
			CLOSE cur_regiao_destino_inversa;
			RETURN id_regiao_destino;		
		ELSE 
			CLOSE cur_regiao_destino_inversa;
			RETURN 0;		
		END IF;

		
	END IF;
	--Tipo Tabela Não é Válido
	RETURN -2;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

