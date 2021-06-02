-- Function: public.f_lanca_cc_relatorio_viagem(integer, numeric, integer)

-- DROP FUNCTION public.f_lanca_cc_relatorio_viagem(integer, numeric, integer);

CREATE OR REPLACE FUNCTION public.f_lanca_cc_relatorio_viagem(
    pidrelatorio integer,
    pvalor numeric,
    pcentrocusto integer)
  RETURNS text AS
$BODY$
DECLARE 
	pIdRelatorio ALIAS FOR $1;
	pValor ALIAS FOR $2;
	pCentroCusto ALIAS FOR $3;	
	vCodigoEmpresa character(3);	
	v_centro_custo integer;
BEGIN
	--Insere novos Registros no Centro de Custo, caso não houver.

	vCodigoEmpresa = fp_get_session('pst_cod_empresa');

	SELECT valor_parametro::integer 
	INTO v_centro_custo
	FROM parametros 
	WHERE upper(cod_parametro) = 'PST_CENTRO_CUSTO_RELATORIO_VIAGEM' 
	AND cod_empresa = vCodigoEmpresa;
	
	
	INSERT INTO scr_relatorio_viagem_centro_custos (id_relatorio_viagem, grupo_acerto, codigo_centro_custo)
	SELECT DISTINCT 
		scr_relatorio_viagem.id_relatorio_viagem, 
		1,
		COALESCE(fornecedores.codigo_centro_custo,pcentrocusto, v_centro_custo)
	FROM 	scr_relatorio_viagem
		LEFT JOIN fornecedores ON fornecedores.id_fornecedor = scr_relatorio_viagem.id_fornecedor 
	WHERE 	
		scr_relatorio_viagem.id_relatorio_viagem = pIdRelatorio
		AND NOT EXISTS (SELECT 	1 
				FROM 	scr_relatorio_viagem_centro_custos					
				WHERE 	scr_relatorio_viagem_centro_custos.id_relatorio_viagem = pIdRelatorio);

	--Atualiza Valores Totais dos Grupos de Centro de Custos
	UPDATE scr_relatorio_viagem_centro_custos 
	SET valor_por_centro_custo = 	pValor
	WHERE id_relatorio_viagem = 	pIdRelatorio;		
		
		
RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



