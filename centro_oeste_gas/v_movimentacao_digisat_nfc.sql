CREATE OR REPLACE VIEW v_movimentacao_digisat_nfc AS 
SELECT
	filial.nome_descritivo,
	filial.cnpj,                
	codigo_empresa,
	codigo_filial,
	MAX(ultima_movimentacao) as ultima_movimentacao
FROM
	filial
	LEFT JOIN movimentacao_digisat_nfc
	    ON filial.cnpj = movimentacao_digisat_nfc.cnpj_emissor
GROUP BY
	filial.nome_descritivo,
	filial.cnpj,
	filial.codigo_empresa,
	filial.codigo_filial
ORDER BY 
	ultima_movimentacao DESC;


SELECT nome_descritivo, cnpj, codigo_empresa, codigo_filial, ultima_movimentacao FROM v_movimentacao_digisat_nfc