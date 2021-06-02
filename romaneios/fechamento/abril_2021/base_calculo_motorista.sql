--SELECT * FROM cliente_tipo_parametros ORDER BY 1
INSERT INTO cliente_tipo_parametros (id_tipo_parametro, nome_parametro, descricao_parametro)
VALUES (94, 'PERC_BC_ACERTO_AGREG_TOT_FRETE', 'Percentual Redução Base Calculo  Total Frete da Comissão Agregado');

--DELETE FROM cliente_tipo_parametros WHERE id_tipo_parametro = 94

ALTER TABLE scr_viagens_docs ADD COLUMN total_frete_bruto numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_viagens_docs ADD COLUMN peso_total_bruto numeric(12,2) DEFAULT 0.00;
ALTER TABLE scr_viagens_docs ADD COLUMN perc_red_bc_comissao numeric(5,2) DEFAULT 0.00;
ALTER TABLE scr_tabela_motorista_regioes ADD COLUMN perc_red_bc_comissao numeric(5,2) DEFAULT 0.00;
 

ALTER TABLE scr_relatorio_viagem ADD COLUMN total_frete_bruto numeric(5,2) DEFAULT 0.00;

/*
UPDATE scr_viagens_docs SET total_frete_bruto = total_frete, peso_total_bruto = peso_total;

SELECT id_relatorio_viagem, vl_servico_for, vl_acrescimos_for, vl_adiantamentos_for, vl_pagar_for, (vl_servico_for + vl_acrescimos_for - vl_adiantamentos_for) as vl_pagar_for_calculado 
FROM scr_relatorio_viagem 
WHERE numero_relatorio = '0010010000199'
ORDER BY id_relatorio_viagem DESC LIMIT 100


SELECT vl_servico_for, vl_acrescimos_for, vl_adiantamentos_for, vl_pagar_for, (vl_servico_for + vl_acrescimos_for - vl_adiantamentos_for) as vl_pagar_for_calculado 
FROM scr_romaneios  
LEFT JOIN scr_relatorio_viagem_romaneios 
	ON scr_relatorio_viagem_romaneios.id_romaneio = scr_romaneios.id_romaneio
WHERE id_relatorio_viagem = 299
WHERE numero_relatorio = '0010010000199'
ORDER BY id_relatorio_viagem DESC LIMIT 100

--SELECT 104.48 / (1.0448)

--SELECT 100 - 4.48

SELECT 
	(vl_adiantamentos_for - inss_valor - irrf_valor - sest_senat_valor - valor_ab - valor_os - valor_cp - valor_req - valor_outros)::numeric(12,2) as adiantamento,
	(valor_ab + valor_os + valor_cp + valor_req + valor_outros) as descontos
FROM 
	scr_relatorio_viagem
	

--SELECT * FROM cliente_parametros WHERE id_tipo_parametro = 94

*/

/*

INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, valor_parametro)
VALUES (189, 94, '4,48');

INSERT INTO cliente_parametros (codigo_cliente, id_tipo_parametro, valor_parametro)
VALUES (23, 94, '4,48');

SELECT 1 + (4.48/100)
*/