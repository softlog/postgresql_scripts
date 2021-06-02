/*
SELECT 
(origem.nome_cidade || ' - ' || origem.uf) as origem,
(destino.nome_cidade || ' - ' || destino.uf) as destino,

scr_romaneios.numero_romaneio, scr_romaneios.data_saida, scr_romaneios.placa_veiculo, scr_romaneios.numero_tabela_motorista, scr_romaneios.id_origem, scr_romaneios.id_destino, scr_romaneios.id_regiao, scr_romaneios.id_setor, scr_romaneios.diarias, scr_romaneios.km_rodados, v_documentos_romaneios.volume, v_documentos_romaneios.volume, v_documentos_romaneios.peso, v_documentos_romaneios.cubagem, v_documentos_romaneios.servicos_realizados, v_documentos_romaneios.total_frete, regiao.descricao as regiao, setor.descricao as setor, scr_romaneios.vl_servico_for, scr_romaneios.vl_acrescimos_for, scr_romaneios.vl_adiantamentos_for, scr_romaneios.vl_pagar_for FROM scr_romaneios LEFT JOIN scr_romaneio_nf ON scr_romaneios.id_romaneio = scr_romaneios.id_romaneio LEFT JOIN v_documentos_romaneios ON v_documentos_romaneios.id_romaneio = scr_romaneios.id_romaneio LEFT JOIN regiao ON regiao.id_regiao = scr_romaneios.id_regiao LEFT JOIN regiao setor ON setor.id_regiao = scr_romaneios.id_setor LEFT JOIN cidades origem ON origem.id_cidade = scr_romaneios.id_origem LEFT JOIN cidades destino ON destino.id_cidade = scr_romaneios.id_destino WHERE 1=2 ORDER BY scr_romaneios.data_saida;


SELECT ID_FORNECEDOR, NOME_RAZAO, CNPJ_CPF FROM FORNECEDORES   WHERE fornecedores.id_fornecedor = '3018'

SELECT * FROM scr_relatorio_viagem

SELECT * FROM scr_romaneios LIMIT 1

SELECT * FROM scr_romaneios ORDER BY 1 DESC LIMIT 100

*/

CREATE VIEW v_documentos_romaneios AS 
SELECT 
	scr_romaneio_nf.id_romaneio,	
	SUM(qtd_volumes) as volume,
	SUM(peso) as peso,
	SUM(volume_cubico) as cubagem,
	0.00 as total_frete,
	COUNT(*) as servicos_realizados
FROM 
	scr_romaneio_nf 
	LEFT JOIN scr_notas_fiscais_imp ON scr_notas_fiscais_imp.id_nota_fiscal_imp = scr_romaneio_nf.id_nota_fiscal_imp
GROUP BY 
	id_romaneio_nf

UNION 
SELECT 	
	id_romaneios as id_romaneio,
	SUM(scr_conhecimento_entrega.qtd_volumes) as volume,
	SUM(scr_conhecimento_entrega.peso) as peso,
	SUM(scr_conhecimento_entrega.volume_cubico) as cubagem,
	SUM(scr_conhecimento_entrega.entrega_realizada) as servicos_realizados,
	SUM(COALESCE(scr_conhecimento.total_frete,0.00)) as total_frete 
FROM 
	scr_conhecimento_entrega 
	LEFT JOIN scr_conhecimento ON scr_conhecimento.id_conhecimento = scr_conhecimento_entrega.id_conhecimento
GROUP BY 
	id_romaneios 

UNION 
SELECT 
	id_romaneios as id_romaneio,
	SUM(qtd_volumes) as volume,
	SUM(peso) as peso,
	SUM(volume_cubico) as cubagem,
	SUM(coleta_realizada) as servicos_realizados,
	0.00::numeric(12,2) as total_frete 
FROM 
	col_coletas_romaneio 
GROUP BY 
	id_romaneios 
