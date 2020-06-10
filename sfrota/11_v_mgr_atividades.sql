-- View: public.v_mgr_scr_viagens
--SELECT * FROM v_mgr_scr_atividades
-- DROP VIEW public.v_mgr_scr_viagens;
--DROP VIEW public.v_mgr_scr_atividades ;
CREATE OR REPLACE VIEW public.v_mgr_scr_atividades AS 
SELECT scr_romaneios.id_romaneio,
	scr_romaneios.data_romaneio,
	scr_romaneios.cod_empresa,
	scr_romaneios.cod_filial,
	scr_romaneios.tipo_romaneio,
	scr_romaneios.numero_romaneio,
	scr_relatorio_viagem.numero_relatorio,
	scr_romaneios.tipo_frota AS tipo_frota_codigo,
	CASE
		WHEN scr_romaneios.tipo_frota = 1 THEN 'Própria'::text
		WHEN scr_romaneios.tipo_frota = 2 THEN 'Agregado'::text
		ELSE 'Terceiro'::text
	END::character(10) AS tipo_frota,
	fornecedores.nome_razao AS motorista,
	fornecedores.cnpj_cpf AS motorista_cpf,
	scr_romaneios.placa_veiculo,
	scr_romaneios.id_origem,
	CASE WHEN scr_romaneios.tipo_rota = 1 THEN 
		origem.nome_cidade 
	ELSE 
		filial_origem.nome_descritivo
	END::text AS cidade_origem,
	origem.uf AS uf_origem,
	scr_romaneios.data_saida,
	scr_romaneios.id_destino,
	CASE WHEN scr_romaneios.tipo_rota = 1 THEN 
		destino.nome_cidade 
	ELSE 
		filial_destino.nome_descritivo
	END::text AS cidade_destino,
	destino.uf AS uf_destino,
	scr_romaneios.data_chegada,
	scr_romaneios.cancelado,
	scr_romaneios.data_cancelamento,
	scr_romaneios.motivo_cancelamento,
	CASE
	    WHEN scr_romaneios.cancelado = 1 THEN 'Cancelada'::text
	    WHEN scr_romaneios.fechamento = 0 THEN 'Viajando'::text
	    WHEN scr_romaneios.fechamento = 1 AND scr_romaneios.id_acerto IS NULL THEN 'Encerrada'::text
	    WHEN scr_romaneios.fechamento = 1 AND scr_romaneios.id_acerto IS NOT NULL THEN 'Acertada'::text
	    ELSE NULL::text
	END::character(10) AS status,
	scr_romaneios.vl_servico_for,
	scr_romaneios.vl_adiantamentos_for,
	scr_romaneios.vl_acrescimos_for,
	scr_romaneios.vl_pagar_for,
	scr_romaneios.vl_despesas_diretas,
	scr_romaneios.total_peso,
	scr_romaneios.total_volume_cubado,
	scr_romaneios.total_peso_cubado,
	scr_romaneios.total_volumes,
	scr_romaneios.total_frete,
	scr_romaneios.total_nf,
	scr_romaneios.id_acerto,
	scr_romaneios.baixa,
	scr_romaneios.fechamento,
	''::text AS lista_nota_fiscal,
	scr_romaneios.placas_engates,
	scr_romaneios.id_motorista,
	scr_romaneios.odometro_inicial,
	scr_romaneios.odometro_final,
	scr_romaneios.km_rodados,
	frt_tipo_atividades.atividade,
	com_produtos.id_produto,
	com_produtos.descr_item as produto,
	tipo_rota,
	CASE 	WHEN tipo_rota = 1 
		THEN 'Cidades' 
		ELSE 'Unidades' 
	END::text as tipo_rota_descritivo
FROM 
	scr_romaneios
	LEFT JOIN scr_relatorio_viagem 
		ON scr_romaneios.id_acerto = scr_relatorio_viagem.id_relatorio_viagem
	LEFT JOIN fornecedores 
		ON scr_romaneios.id_motorista = fornecedores.id_fornecedor
	LEFT JOIN filial filial_origem 
		ON scr_romaneios.id_origem = filial_origem.id_filial AND scr_romaneios.tipo_rota = 2
	LEFT JOIN filial_sub filial_destino 
		ON scr_romaneios.id_destino = filial_destino.id_filial_sub AND scr_romaneios.tipo_rota = 2
	LEFT JOIN cidades origem 
		ON 
		CASE 	
			WHEN tipo_rota = 1 
			THEN scr_romaneios.id_origem = origem.id_cidade 
			ELSE filial_origem.id_cidade = origem.id_cidade 
		END			
	LEFT JOIN cidades destino 
		ON 
		CASE 
			WHEN tipo_rota = 1
			THEN scr_romaneios.id_destino = destino.id_cidade AND scr_romaneios.tipo_rota = 1
			ELSE filial_destino.id_filial_sub = destino.id_cidade
		END
	LEFT JOIN frt_tipo_atividades 
		ON frt_tipo_atividades.id_tipo_atividade = scr_romaneios.id_tipo_atividade
	LEFT JOIN com_produtos
		ON com_produtos.id_produto = scr_romaneios.id_produto
--SELECT * FROM com_produtos
     --LEFT JOIN scr_viagens_docs ON scr_romaneios.id_romaneio = scr_viagens_docs.id_romaneio
     --LEFT JOIN scr_conhecimento ON scr_viagens_docs.id_documento = scr_conhecimento.id_conhecimento AND scr_viagens_docs.tipo_documento = 1
     --LEFT JOIN scr_manifesto ON scr_viagens_docs.id_documento = scr_manifesto.id_manifesto AND scr_viagens_docs.tipo_documento = 3
WHERE scr_romaneios.tipo_romaneio = 3 AND scr_romaneios.numero_romaneio IS NOT NULL


