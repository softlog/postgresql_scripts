/*

SELECT f_get_dados_integracao_alper_lote('6494056,6494063,6494064,6494065,6494066,6494079,6494099,6494109,6494110,6494120,6494137,6494148,6494157,6494158,6494159,6494164,6494179,6494198,6494228,6494229,6494251,6494253,6494257,6494258,6494265,6494266,6494269,6494279,6494301,6494345,6494396,6494466,6494471,6494504,6494538,6494545,6494568');

SELECT * FROM fila_documentos_integracoes WHERE lst_documentos IS NOT NULL 


*/

CREATE OR REPLACE FUNCTION f_get_dados_integracao_alper_lote(p_lst_nf text)
  RETURNS json AS
$BODY$
DECLARE
	v_resultado json;
	str_sql text;
	vCursor refcursor;
		
BEGIN

        str_sql = 'WITH t AS (
			WITH temp AS (
				SELECT row_to_json(row, true) as nfs FROM (				
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
						trim(cnpj_cpf(lpad(nf.destinatario_cnpj,14,''0''))) as destinatario_cnpj,
						trim(nf.destinatario_ie) as destinatario_ie,
						trim(nf.destinatario_endereco) as destinatario_endereco,
						trim(nf.destinatario_cidade) as destinatario_cidade,
						trim(nf.destinatario_bairro) as destinatario_bairro,
						nf.destinatario_cep,
						CASE WHEN nf.destinatario_telefone IS NULL  OR trim(nf.destinatario_telefone) = '''' THEN ''62999991111'' ELSE nf.destinatario_telefone END::text as destinatario_telefone,
						trim(cidades.cod_ibge) as destinatario_cod_mun,
						nf.destinatario_uf,
						nf.destinatario_numero,
						CASE WHEN char_length(nf.destinatario_cnpj) = 14 THEN 1 ELSE 2 END::text as destinatario_tipo_pessoa,
						ltrim(to_char(now(), ''DDMMYYYY''),''0'') as data_integracao,
						ltrim(to_char(now(), ''HH24MI''),''0'') as hora_integracao,
						''NOT'' || to_char(now(), ''DDMMHH24MI'') || ''0'' as ident_intercambio,
						''NOT'' || to_char(now(), ''DDMMHH24MI'') || ''0'' as ident_documento,
						nf.modal,
						2::integer as tipo_transporte_carga,
						3::integer as tipo_carga,
						''C''::text as frete_cif_fob,
						nf.serie_nota_fiscal, 
						nf.numero_nota_fiscal::bigint as numero_nota_fiscal,
						to_char(nf.data_emissao,''DD/MM/YYYY'') as data_emissao,
						nf.valor as valor_nota_fiscal,
						nf.volume_presumido as qtd_volumes,
						nf.peso_presumido as peso,
						CASE WHEN nf.volume_cubico > 0 THEN (300/nf.volume_cubico) ELSE 0 END::numeric(20,4) as peso_cubado,
						''S''::text as tipo_icms,
						''S''::text as tem_seguro,
						0.00::numeric(12,2) as valor_servico,
						''N''::text as plano_carga_rapida, 
						0.00::numeric(12,2) as valor_seguro,
						0.00::numeric(12,2) as valor_frete_peso,
						0.00::numeric(12,2) as valor_frete_valor,
						0.00::numeric(12,2) as valor_outras_taxas,
						0.00::numeric(12,2) as valor_total_frete,
						''I''::text as acao,
						0.00::numeric(12,2) as imposto,
						0.00::numeric(12,2) as imposto_st,
						nf.chave_nfe
					FROM 
						v_mgr_notas_fiscais nf
						LEFT JOIN cidades 
							ON cidades.id_cidade = nf.destinatario_id_cidade
					WHERE 
						--nf.id_nota_fiscal_imp = 6199365
						nf.id_nota_fiscal_imp IN ( ' || p_lst_nf || ')
				) row
			)
			SELECT array_agg(nfs) as nfs FROM temp 
	) 
	SELECT 
		row_to_json(row,true) as dados FROM (
			SELECT 
				nfs 
			FROM 
				t
		) row;';
	

	OPEN vCursor FOR EXECUTE str_sql;
	FETCH vCursor INTO v_resultado;
	CLOSE vCursor;
	
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;