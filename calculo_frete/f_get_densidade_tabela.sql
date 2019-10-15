--SELECT * FROM scr_tabelas_origem_destino 

CREATE OR REPLACE FUNCTION f_get_densidade_tabela(p_tabela text, p_calculado_de_id_cidade integer, p_calculado_ate_id_cidade integer)
  RETURNS integer AS
$BODY$
DECLARE

	v_volume_cubico numeric;
	v_tabela_frete character(13);
	v_id_regiao_origem integer;
	v_id_regiao_destino integer;
	v_calculado_de_id_cidade integer;
	v_calculado_ate_id_cidade integer;
	v_destinatario_id integer;
	v_densidade integer;
	v_peso_cubado numeric(16,3);
	v_aux text;
	rotas json;
		
BEGIN


	rotas = f_scr_retorna_regioes_origem_destino(p_calculado_de_id_cidade,p_calculado_ate_id_cidade,p_tabela);

	v_id_regiao_origem = rotas->>'id_regiao_origem';
	v_id_regiao_destino = rotas->>'id_regiao_destino';
	
-- 	RAISE NOTICE 'Tabela Frete %', p_tabela_frete;
-- 	RAISE NOTICE 'Regiao Origem %', v_id_regiao_origem;
-- 	RAISE NOTICE 'Regiao Destino %', v_id_regiao_destino;
-- 	RAISE NOTICE 'Cidade Origem %', p_calculado_de_id_cidade;
-- 	RAISE NOTICE 'Cidade Destino %', p_calculado_ate_id_cidade;

	
	SELECT 
		tod.densidade,
		tod.ida_volta
	INTO 
		v_densidade,
		v_aux
	FROM 
		scr_tabelas t
		LEFT JOIN scr_tabelas_origem_destino tod
			ON t.numero_tabela_frete = p_tabela
	WHERE
		numero_tabela_frete = v_tabela_frete
		AND 	CASE 	WHEN tod.tipo_rota = 3 THEN 
					true				
				WHEN tod.ida_volta = 1 AND tod.tipo_rota = 2 THEN 
					((tod.id_origem = v_id_regiao_origem AND tod.id_destino = v_id_regiao_destino) 
						OR 
					(tod.id_origem = v_id_regiao_destino AND tod.id_destino = v_id_regiao_origem))
					
				WHEN tod.ida_volta = 0 AND tod.tipo_rota = 2 THEN
					(tod.id_origem = v_id_regiao_origem AND tod.id_destino = v_id_regiao_destino)

				WHEN tod.ida_volta = 1 AND tod.tipo_rota = 1 THEN
					((tod.id_origem = v_calculado_de_id_cidade AND tod.id_destino = v_calculado_ate_id_cidade) 
						OR 
					(tod.id_origem = v_calculado_ate_id_cidade AND tod.id_destino = v_calculado_de_id_cidade))							
					
				WHEN NOT tod.ida_volta = 0 AND tod.tipo_rota = 1 THEN 
					(tod.id_origem = v_calculado_de_id_cidade AND tod.id_destino = v_calculado_ate_id_cidade)

				WHEN tod.tipo_rota = 0 THEN 
					tod.id_destino = v_destinatario_id
				ELSE
					true
				END;

	RAISE NOTICE 'Densidade % ', v_densidade;
	RAISE NOTICE 'Tipo Rota % ', v_aux;
	
	RETURN COALESCE(v_densidade,300);
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

  