-- Function: public.f_scr_retorna_regioes_origem_destino(integer, integer, text)
--SELECT f_scr_retorna_regioes_origem_destino_bairros(5505,49142,'0010010000001')
-- DROP FUNCTION public.f_scr_retorna_regioes_origem_destino(integer, integer, text);


CREATE OR REPLACE FUNCTION public.f_scr_retorna_regioes_origem_destino_bairros(
    vIdCidadeOrigem integer,
    vIdBairroDestino integer,
    vTabelaFrete text)
  RETURNS json AS
$BODY$
DECLARE
	vTipoTabela		integer;
	vRegioes 		json;

	vIdRegiaoOrigem		integer;
	vIdRegiaoDestino	integer;

	vTipoRota		integer; -- 1 - Cidade, 2 - Região, 0 - Sem rota
BEGIN	

	-- Recupera a origem e o destino caso o tipo de rota seja por região.	
	-- Verifica se a cidade de origem está em alguma região de origem da tabela de frete
	SELECT 
		tod.id_origem
	INTO 
		vIdRegiaoOrigem		
	FROM 
		scr_tabelas_origem_destino tod
		LEFT JOIN scr_tabelas t 	ON t.id_tabela_frete = tod.id_tabela_frete
		LEFT JOIN regiao rco	ON tod.id_origem = rco.id_regiao
	WHERE 
		t.numero_tabela_frete 	= vTabelaFrete
		AND tod.tipo_rota 	= 2
		AND rco.id_cidade_polo 	= vIdCidadeOrigem;

	-- Se não foi encontrado nenhuma região de origem da cidade de origem, então:
	-- 	Verifica se a cidade de origem está em alguma região de destino, cadastrada na tabela
	IF vIdRegiaoOrigem IS NULL THEN 
		SELECT 
			tod.id_destino
		INTO 
			vIdRegiaoOrigem
		FROM
			scr_tabelas_origem_destino tod
			LEFT JOIN scr_tabelas t 
				ON t.id_tabela_frete = tod.id_tabela_frete
			LEFT JOIN regiao rcd
				ON tod.id_destino = rcd.id_regiao
		WHERE
			t.numero_tabela_frete 	= vTabelaFrete
			AND tod.tipo_rota 	= 2
			AND rcd.id_cidade_polo	= vIdCidadeOrigem;

		-- Se a cidade de origem não está em nenhuma região origem ou destino da tabela, então:
		-- 	Não há como determinar a região de origem, retorna -1;
		IF vIdRegiaoOrigem IS NULL THEN
			vIdRegiaoOrigem = -1;
			vIdRegiaoDestino = -1;
		END IF;		
	END IF;

	-- Se a Região de Origem for diferente de -1, ou seja, foi encontrado uma região de origem, então:
	-- 	verifica se a cidade de destino está em alguma região de destino, 
	-- 	cuja região de origem seja a encontrada.
	IF vIdRegiaoOrigem > -1 THEN
		-- Verifica se a cidade de origem está em alguma região de origem da tabela de frete
		SELECT 
			tod.id_destino
		INTO 
			vIdRegiaoDestino		
		FROM 
			scr_tabelas_origem_destino tod
			LEFT JOIN scr_tabelas t 	
				ON t.id_tabela_frete = tod.id_tabela_frete
			LEFT JOIN v_regiao_bairros rbo	
				ON tod.id_destino = rbo.id_regiao
		WHERE 
			t.numero_tabela_frete 	= vTabelaFrete
			AND tod.tipo_rota 	= 2
			AND tod.id_origem	= vIdRegiaoOrigem
			AND rbo.id_bairro 	= vIdBairroDestino;


		-- Se não foi encontrada numa região de destino da tabela, então:
		--	Verifica se a cidade de destino está  
		-- 	está em alguma região de origem, cuja região de destino 
		--      seja igual à Região de origem encontrada
		IF vIdRegiaoDestino IS NULL THEN 
			SELECT 
				tod.id_origem
			INTO 
				vIdRegiaoDestino		
			FROM 
				scr_tabelas_origem_destino tod
				LEFT JOIN scr_tabelas t 	
					ON t.id_tabela_frete = tod.id_tabela_frete
				LEFT JOIN v_regiao_bairros rbd	
					ON tod.id_origem = rbd.id_regiao
			WHERE 
				t.numero_tabela_frete 	= vTabelaFrete
				AND tod.tipo_rota 	= 2
				AND tod.id_destino	= vIdRegiaoOrigem
				AND rbd.id_bairro 	= vIdBairroDestino;
			

			-- Se a cidade de origem não está em nenhuma região origem ou destino da tabela, então:
			-- 	Não há como determinar a região de origem, retorna -1;
			IF vIdRegiaoDestino IS NULL THEN
				vIdRegiaoDestino = -1;				
			END IF;				
			
		END IF;
	END IF;

	vRegioes = ('{"id_regiao_origem":' || vIdRegiaoOrigem::text || ',"id_regiao_destino":' || vIdRegiaoDestino::text || '}')::json; 

	RETURN vRegioes;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

