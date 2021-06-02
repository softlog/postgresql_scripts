/*
SELECT f_get_args_averbweb(4120, 1, 1)
*/
CREATE OR REPLACE FUNCTION f_get_args_averbweb(p_id_doc integer,p_tipo_documento integer, status integer)
  RETURNS text AS
$BODY$
DECLARE
     v_resultado text;   
BEGIN


	WITH t AS (
		SELECT 	
			trim(s.usuario) as usuario,
			trim(s.senha) as senha,
			filial.cnpj as emit_nome,
			trim(filial.razao_social) as emit_cnpj,
			trim(ce.nome_cidade) as emit_cidade,
			trim(ce.uf) as emit_uf,


			'CTE'::text as tipo_documento,		
			CASE 
				WHEN c.tipo_transporte IN (3,12) THEN 'E'
				WHEN c.tipo_transporte IN (19) THEN 'R'
				WHEN c.tipo_transporte IN (18) THEN 'U'
				ELSE 'N'
			END::text as tipo_cte,
			ltrim(RIGHT(c.numero_ctrc_filial, 7),'0') as num_documento,
			trim(c.serie_doc) as serie_documento,
			''::text as sub_serie_doc,
			to_char(c.data_emissao, 'dd/mm/yyyy') as data_emissao,		
			CASE WHEN c.modal = 1 THEN 'RODOVIARIO' ELSE 'AEREO' END::text as tipo_embarque,
			trim(c.natureza_carga) as tipo_mercadoria,
			to_char(valor_nota_fiscal,'999G999G999G990D00') as valor_mercadoria,
			trim(COALESCE(c.placa_veiculo,'')) as placa,
			
			trim(c.remetente_nome) as remet_nome,
			trim(c.remetente_cnpj) as remet_cnpj,
			trim(cr.nome_cidade) as remet_cidade,
			trim(cr.uf) as remet_uf,
			
			trim(c.destinatario_nome) as dest_nome,
			trim(c.destinatario_cnpj) as dest_cnpj,
			trim(cd.nome_cidade) as dest_cidade,
			trim(cd.uf) as dest_uf			
			
		FROM  
			scr_conhecimento c
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = c.empresa_emitente
			LEFT JOIN filial
				ON filial.codigo_empresa = c.empresa_emitente AND filial.codigo_filial = c.filial_emitente
			LEFT JOIN empresa_acesso_servicos s
				ON s.id_empresa = empresa.id_empresa
			LEFT JOIN cidades ce
				ON ce.id_cidade = filial.id_cidade
			LEFT JOIN cidades cr
				ON c.calculado_de_id_cidade = cr.id_cidade
			LEFT JOIN cidades cd
				ON c.calculado_ate_id_cidade = cd.id_cidade
		WHERE 
			id_conhecimento = p_id_doc
			AND id_servico_integracao = 101
	)
	SELECT 
		'\$args = array(' ||
		'\"usuario\"=>\"' || t.usuario || '\",' ||
		'\"senha\"=>\"' || t.senha || '\",' ||
		'\"emit_nome\"=>\"' || t.emit_nome || '\",' ||
		'\"emit_cnpj\"=>\"' || t.emit_cnpj || '\",' ||
		'\"emit_cidade\"=>\"' || t.emit_cidade || '\",' ||
		'\"emit_uf\"=>\"' || t.emit_uf || '\",' ||
		'\"tipo_documento\"=>"' || t.tipo_documento || '\",' ||
		'\"tipo_cte\"=>\"' || t.tipo_cte || '\",' ||
		'\"num_documento\"=>\"' || t.num_documento || '\",' ||
		'\"serie_documento\"=>\"' || t.serie_documento || '\",' ||
		'\"sub_serie_doc\"=>\"' || t.sub_serie_doc || '\",' ||
		'\"data_emissao\"=>\"' || t.data_emissao || '\",' ||
		'\"tipo_embarque\"=>\"' || t.tipo_embarque || '\",' ||
		'\"tipo_mercadoria\"=>\"' || t.tipo_mercadoria || '\",' ||
		'\"valor_mercadoria\"=>\"' || t.valor_mercadoria || '\",' ||
		'\"placa\"=>\"' || t.placa || '\",' ||
		'\"remet_nome\"=>\"' || t.remet_nome || '\",' ||
		'\"remet_cidade\"=>\"' || t.remet_cidade || '\",' ||
		'\"remet_uf\"=>\"' || t.remet_uf || '\",' ||
		'\"remet_cidade\"=>"' || t.remet_cidade || '\",' ||
		'\"remet_uf\"=>\"' || t.remet_uf || '\",' ||
		'\"dest_nome\"=>\"' || t.dest_nome || '\",' ||
		'\"dest_cidade\"=>\"' || t.dest_cidade || '\",' ||
		'\"dest_uf\"=>\"' || t.dest_uf || '\"' ||		
		');'
	INTO 
		v_resultado
	FROM
		t;

        RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

  --ALTER FUNCTION f_get_args_averbweb(p_id_doc integer,p_tipo_documento integer, status integer) OWNER TO softlog_ses