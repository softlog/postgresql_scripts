CREATE OR REPLACE FUNCTION f_get_dados_integracao_alper(p_id_nota_fiscal_imp integer)
  RETURNS json AS
$BODY$
DECLARE
	v_resultado json;
BEGIN
        
	WITH t AS (
		SELECT 
			nf.id_nota_fiscal_imp,
			trim(cnpj_cpf(nf.remetente_cnpj)) as remetente_cnpj,
			trim(nf.remetente_ie) as remetente_ie,
			trim(nf.remetente_endereco) as remetente_endereco,
			trim(nf.remetente_cidade) as remetente_cidade,
			nf.remetente_uf,
			nf.remetente_cep,
			trim(nf.remetente_nome) as remetente_nome,
			trim(nf.destinatario_nome) as destinatario_nome,			
			trim(cnpj_cpf(lpad(nf.destinatario_cnpj,14,'0'))) as destinatario_cnpj,
			trim(nf.destinatario_ie) as destinatario_ie,
			trim(nf.destinatario_endereco) as destinatario_endereco,
			trim(nf.destinatario_cidade) as destinatario_cidade,
			trim(nf.destinatario_bairro) as destinatario_bairro,
			nf.destinatario_cep,
			CASE WHEN nf.destinatario_telefone IS NULL  OR trim(nf.destinatario_telefone) = '' THEN '62999991111' ELSE nf.destinatario_telefone END::text as destinatario_telefone,
			trim(cidades.cod_ibge) as destinatario_cod_mun,
			nf.destinatario_uf,
			nf.destinatario_numero,
			CASE WHEN char_length(nf.destinatario_cnpj) = 14 THEN 1 ELSE 2 END::text as destinatario_tipo_pessoa,
			ltrim(to_char(now(), 'DDMMYYYY'),'0') as data_integracao,
			ltrim(to_char(now(), 'HH24MI'),'0') as hora_integracao,
			'NOT' || to_char(now(), 'DDMMHH24MI') || '0' as ident_intercambio,
			'NOT' || to_char(now(), 'DDMMHH24MI') || '0' as ident_documento,
			nf.modal,
			2::integer as tipo_transporte_carga,
			3::integer as tipo_carga,
			'C'::text as frete_cif_fob,
			nf.serie_nota_fiscal, 
			nf.numero_nota_fiscal::bigint as numero_nota_fiscal,
			to_char(nf.data_emissao,'DD/MM/YYYY') as data_emissao,
			nf.valor as valor_nota_fiscal,
			nf.volume_presumido as qtd_volumes,
			nf.peso_presumido as peso,
			CASE WHEN nf.volume_cubico > 0 THEN (300/nf.volume_cubico) ELSE 0 END::numeric(20,4) as peso_cubado,
			'S'::text as tipo_icms,
			'S'::text as tem_seguro,
			0.00::numeric(12,2) as valor_servico,
			'N'::text as plano_carga_rapida, 
			0.00::numeric(12,2) as valor_seguro,
			0.00::numeric(12,2) as valor_frete_peso,
			0.00::numeric(12,2) as valor_frete_valor,
			0.00::numeric(12,2) as valor_outras_taxas,
			0.00::numeric(12,2) as valor_total_frete,
			'I'::text as acao,
			0.00::numeric(12,2) as imposto,
			0.00::numeric(12,2) as imposto_st,
			nf.chave_nfe
		FROM 
			v_mgr_notas_fiscais nf
			LEFT JOIN cidades 
				ON cidades.id_cidade = nf.destinatario_id_cidade
		WHERE 
			--nf.id_nota_fiscal_imp = 6199365
			nf.id_nota_fiscal_imp = p_id_nota_fiscal_imp
	) 
	SELECT row_to_json(t,true) as dados 
	INTO v_resultado
	FROM t;
	
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

/*
SELECT volume_presumido FROM scr_notas_fiscais_imp LIMIT 1
SELECT * FROM scr_romaneio_nf ORDER BY 1 DESC LIMIT 100


SELECT * FROM fila_documentos_integracoes WHERE enviado = 0 AND tipo_integracao = 10 AND pendencia = 1 AND data_registro >= '2020-11-15 18:00:00'

INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, id_nota_fiscal_imp, id_romaneio)
SELECT 
	10,
	1,
	rnf.id_nota_fiscal_imp,
	r.id_romaneio
FROM 		
	scr_romaneios r
	LEFT JOIN scr_romaneio_nf rnf
		ON rnf.id_romaneio = r.id_romaneio			
	LEFT JOIN scr_notas_fiscais_imp nf
		ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp			
WHERE
	r.id_romaneio = 184207
	AND rnf.id_nota_fiscal_imp IS NOT NULL;


*/

	