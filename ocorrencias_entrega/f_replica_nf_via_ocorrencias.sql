-- Function: public.f_replica_nf_via_ocorrencia(integer, integer)
/*
SELECT id_nota_fiscal_imp, tipo_transporte, remetente_id, volume_presumido, peso_presumido FROM scr_notas_fiscais_imp 
WHERE numero_nota_fiscal::integer = 122108 ORDER BY 1 

WITH 
	
	id_nota_fiscal_imp 
	

SELECT * FROM scr_notas_fiscais_imp_log_atividades WHERE id_nota_fiscal_imp = 47965



*/
-- DROP FUNCTION public.f_replica_nf_via_ocorrencia(integer, integer);
-- SELECT * FROM v_tipo_transporte ORDER BY 1
-- SELECT * FROM scr_notas_fiscais_imp LIMIT 1
-- UPDATE scr_conhecimento SET cod_operacao_fiscal = '5353' WHERE numero_ctrc_filial = '0010010032510'
-- SELECT f_replica_nf_via_ocorrencia(46269,3)

CREATE OR REPLACE FUNCTION public.f_replica_nf_via_ocorrencia(
    p_id_nf integer,
    p_tipo_transporte integer)
  RETURNS integer AS
$BODY$
DECLARE
	v_gera_devolucao integer;
	v_gera_reentrega integer;
	v_tipo_transporte integer;
	v_id_nf_new integer;
	v_dados json;
BEGIN

	v_tipo_transporte = p_tipo_transporte;

	IF v_tipo_transporte = 1 THEN 
		RETURN p_id_nf;
	END IF;	

	--RAISE NOTICE 'Replicando NF %', p_id_nf;
	SELECT row_to_json(row) as nfes 
	INTO v_dados 
	FROM (
		SELECT 
			id_nota_fiscal_imp::text as id_nota_fiscal_imp,
			trim(nf.chave_nfe) as nfe_chave_nfe,
			CASE WHEN nf.frete_cif_fob = 1 THEN '0' ELSE '1' END::text as nfe_modo_frete,
			trim(rem.cnpj_cpf) as nfe_emit_cnpj_cpf,
			trim(o.cod_ibge) as nfe_emit_cod_mun,
			trim(dest.cnpj_cpf) as nfe_dest_cnpj_cpf,
			--nf.calculado_ate_id_cidade as cidade_destino,
			trim(d.cod_ibge) as nfe_dest_cod_mun,
			nf.data_emissao::date::text as nfe_data_emissao,
			nf.numero_nota_fiscal as nfe_numero_doc,
			'55'::text as nfe_modelo,
			nf.serie_nota_fiscal as nfe_serie,
			nf.placa_veiculo as nfe_placa_veiculo,
			nf.placa_carreta1 as nfe_placa_reboque1,
			nf.placa_carreta2 as nfe_placa_reboque2,
			nf.valor::text as nfe_valor,
			nf.valor_base_calculo::text as nfe_valor_bc,
			nf.valor_icms_nf::text as nfe_valor_icms,
			nf.valor_base_calculo_icms_st::text as nfe_valor_bc_st,
			nf.valor_icms_nf_st::text as nfe_valor_icms_st,
			trim(nf.especie_mercadoria) as nfe_especie_mercadoria,
			trim('UN'::text) as nfe_unidade,
			trim(nf.cfop_pred_nf) as nfe_cfop_predominante,
			''::text as nfe_informacoes,
			nf.consumidor_final::text as nfe_ind_final,
			trim(dest.inscricao_estadual) as nfe_ie_dest,
			'1'::text as nfe_tp_nf,
			nf.peso_presumido::text as nfe_peso_presumido,			
			nf.peso_liquido::text as nfe_peso_liquido,
			nf.peso_presumido::text as nfe_volume_presumido,
			nf.peso::text as nfe_peso_presumido,
			nf.qtd_volumes::text as nfe_volume_produtos,
			nf.valor_total_produtos::text as nfe_valor_produtos,
			nf.peso::text as nfe_peso_produtos,						
			r.emitido,						
			--c.chave_cte
			v_tipo_transporte as tipo_transporte,
			-1::integer as id_romaneio,
			nf.volume_cubico::text as nfe_volume_cubico
			
			--c.redespachador_id::text as redespachador_id	
		FROM		
			scr_romaneios r		
			RIGHT  JOIN scr_notas_fiscais_imp nf
				ON r.id_romaneio = nf.id_romaneio		
			LEFT JOIN cliente rem
				ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN cliente dest
				ON dest.codigo_cliente = nf.destinatario_id
			LEFT JOIN fornecedores red
				ON red.id_fornecedor = r.id_transportador_redespacho
			LEFT JOIN cidades o 
				ON o.id_cidade = calculado_de_id_cidade
			LEFT JOIN cidades d
				ON d.id_cidade = calculado_ate_id_cidade
			LEFT JOIN scr_conhecimento c
				ON c.id_conhecimento = nf.id_conhecimento
		WHERE
			nf.id_nota_fiscal_imp = p_id_nf
	) row;

	--RAISE NOTICE '%', v_dados;
        v_id_nf_new = f_insere_nf(v_dados);
        
	RETURN p_id_nf;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
