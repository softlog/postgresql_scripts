-- Function: public.retorna_regiao_origem_motorista(integer, character)

-- DROP FUNCTION public.retorna_regiao_origem_motorista(integer, character);
/*
SELECT retorna_regiao_origem_motorista(5355, '0010010000005')

SELECT * FROM scr_tabela_motorista_regioes WHERE id_tabela_motorista = 8
	SELECT count(*) 
	FROM 
		scr_tabela_motorista 
		LEFT JOIN scr_tabela_motorista_regioes ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista	
	WHERE 	
		numero_tabela_motorista = '0010010000005'
	GROUP BY 
		scr_tabela_motorista_regioes.id_regiao_origem, 
		scr_tabela_motorista_regioes.id_regiao_destino;


*/
CREATE OR REPLACE FUNCTION public.retorna_regiao_origem_motorista(
    id_cidade_origem integer,
    tabela_motorista character)
  RETURNS integer AS
$BODY$
DECLARE
	codigo_cidade_origem ALIAS FOR $1;	
	tabela_motorista ALIAS FOR $2;

	cur_geral refcursor;	
	regiao_generica integer;
	
	cur_regiao refcursor;
	
	codigo_regiao_origem integer;
	
	id_regiao_origem integer;

	cur_regiao_origem refcursor;
	cur_regiao_origem_inversa refcursor;
	cur_tabela_motorista refcursor;

	v_qt integer;
BEGIN	


	RAISE NOTICE 'BUSCANDO REGIAO DA TABELA %', tabela_motorista;
	SELECT count(*) INTO v_qt 
	FROM 
		scr_tabela_motorista 
		LEFT JOIN scr_tabela_motorista_regioes ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista	
	WHERE 	
		numero_tabela_motorista = tabela_motorista;
	

	RAISE NOTICE 'Quantidade %', v_qt;
	--VERIFICA SE A TABELA DE MOTORISTA CONTEM REGIAO GENERICA	
	IF v_qt = 1 THEN 
		OPEN cur_geral FOR 
				SELECT count(*) 
				FROM scr_tabela_motorista
				LEFT JOIN scr_tabela_motorista_regioes ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
				WHERE 	scr_tabela_motorista_regioes.id_regiao_origem = -1 
					AND scr_tabela_motorista_regioes.id_regiao_destino = -1 
					AND numero_tabela_motorista = tabela_motorista;

		FETCH cur_geral INTO regiao_generica;
		
		CLOSE cur_geral;

		IF regiao_generica > 0 THEN 
			RETURN -1 ;
		END IF;
	END IF;
	

	OPEN cur_regiao_origem FOR
			SELECT 
				regiao_origem.id_regiao as regiao_origem
			FROM 
				scr_tabela_motorista
				LEFT JOIN scr_tabela_motorista_regioes
					ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
				LEFT JOIN regiao_cidades as regiao_origem
					ON scr_tabela_motorista_regioes.id_regiao_origem = regiao_origem.id_regiao
				LEFT JOIN cidades as cidades_origem
					ON regiao_origem.id_cidade = cidades_origem.id_cidade	
			WHERE 
				numero_tabela_motorista = tabela_motorista
				AND cidades_origem.id_cidade = codigo_cidade_origem
			GROUP BY regiao_origem.id_regiao;
				

		FETCH cur_regiao_origem INTO id_regiao_origem;


		IF FOUND THEN 
			CLOSE cur_regiao_origem;
			RETURN id_regiao_origem;
		ELSE
			CLOSE cur_regiao_origem;
			OPEN cur_regiao_origem_inversa FOR
			SELECT 
				regiao_origem.id_regiao as regiao_origem
			FROM 
				scr_tabela_motorista
				LEFT JOIN scr_tabela_motorista_regioes
					ON scr_tabela_motorista.id_tabela_motorista = scr_tabela_motorista_regioes.id_tabela_motorista
				LEFT JOIN regiao_cidades as regiao_origem
					ON scr_tabela_motorista_regioes.id_regiao_destino = regiao_origem.id_regiao
				LEFT JOIN cidades as cidades_origem
					ON regiao_origem.id_cidade = cidades_origem.id_cidade	
			WHERE 
				numero_tabela_motorista = tabela_motorista
				AND cidades_origem.id_cidade = codigo_cidade_origem
			GROUP BY regiao_origem.id_regiao;

			FETCH cur_regiao_origem_inversa INTO id_regiao_origem;

			IF FOUND THEN 
				CLOSE cur_regiao_origem_inversa;
				RETURN id_regiao_origem;
			ELSE 
				CLOSE cur_regiao_origem_inversa;
				RETURN 0;	
			END IF;	
		END IF;
	

	RETURN -2;
	--RETURN TRIM(to_char(codigo_cidade_origem,'00000')) || TRIM(to_char(codigo_cidade_destino,'00000')) || TRIM(tabela_frete);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
