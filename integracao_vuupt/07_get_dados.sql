--3810284 
--SELECT * FROM fila_documentos_integracoes WHERE tipo_documento = 4
--SELECT * FROM fila_documentos_integracoes WHERE  enviado = 0LIMIT 1
--SELECT f_dados_docs_integracao(2162)
--SELECT * FROM api_integracao ORDER BY 1 DESC LIMIT 100 WHERE id_softlog = 11548
--DELETE FROM api_integracao WHERE id = 27
--DROP FUNCTION f_dados_docs_integracao(p_id_nf integer)
--SELECT * FROM api_integracao WHERE id_fila = 79
--DELETE FROM api_integracao WHERE id_fila = 79
CREATE OR REPLACE FUNCTION f_dados_docs_integracao(p_id_fila integer)
  RETURNS json AS
$BODY$
DECLARE
	vDados json;
        
BEGIN

	--SELECT * FROM fornecedor_parametros
	WITH nf AS (
		SELECT 
			fd.id,
			--Nota Fiscal
			r.id_romaneio,
			r.numero_romaneio,
			to_char(r.data_romaneio,'YYYY-MM-DD HH24:MI:SS') as data_romaneio,
			r.data_saida::date as data_expedicao,                            
			to_char(r.data_saida,'YYYY-MM-DD HH24:MI:SS') as data_saida,
			to_char(r.data_chegada, 'YYYY-MM-DD HH24:MI:SS') as data_chegada,
			r.placa_veiculo,
			r.id_motorista,
			mot.cnpj_cpf as motorista_cpf,
			mot.id_cidade as motorista_id_cidade,
			r.id_transportador_redespacho,
			red.cnpj_cpf as redespachador_cpf,
			red.id_cidade as redespacho_id_cidade,
			r.id_origem,			
			nf.id_nota_fiscal_imp,
			trim(to_char(nf.data_emissao,'YYYY-MM-DD')) as data_emissao,
			trim(to_char(nf.data_expedicao,'YYYY-MM-DD')) as data_expedicao,
			trim(nf.serie_nota_fiscal) as serie,
			trim(nf.numero_nota_fiscal) as numero_nota_fiscal,
			nf.chave_nfe,
			trim(nf.serie_nota_fiscal) || '/' || trim(nf.numero_nota_fiscal) as codigo_servico_softlog,
			nf.valor,					
			nf.peso_presumido as peso,
			nf.peso_liquido,
			nf.id_ocorrencia,
			to_char(nf.data_ocorrencia,'YYYY-MM-DD HH24:MI:SS') as data_ocorrencia,
			nf.volume_presumido as volume,
			null::integer as id_conhecimento_notas_fiscais,
			nf.id_conhecimento,
			fp.valor_parametro as id_motorista_vuupt, 

			--Remetente
			rem.codigo_cliente as remetente_id,
			trim(rem.nome_cliente) as remetente_nome,
			trim(rem.cnpj_cpf) as remetente_cnpj_cpf,
			CASE 	WHEN char_length(rem.cnpj_cpf) = 9 
				THEN 'person'
				ELSE 'company'
			END::text as remetente_tipo_contato,
			CASE 	WHEN rem.end_complemento IS NOT NULL 
				THEN trim(fpy_limpa_caracteres(rem.endereco)) || ', ' || trim(fpy_limpa_caracteres(rem.end_complemento)) 
				ELSE trim(fpy_limpa_caracteres(rem.endereco))
			END as remetente_endereco,
			trim(fpy_limpa_caracteres(rem.numero)) as remetente_numero,
			trim(fpy_limpa_caracteres(rem.bairro)) as remetente_bairro,
			rem.id_cidade as remetente_id_cidade, 
			rem.cep as remetente_cep,
			(rem.ddd || ' ' || rem.telefone) as remetente_telefone,
			trim(fpy_limpa_caracteres(cr.nome_cidade)) as remetente_nome_cidade,
			cr.uf as remetente_uf,
			rem.latitude as remetente_latitude,
			rem.longitude as remetente_longitude,
			rem.id_vuupt as remetente_id_vuupt,

			--Destinatario
			dest.codigo_cliente as destinatario_id,
			trim(dest.nome_cliente) as destinatario_nome,
			trim(dest.cnpj_cpf) as destinatario_cnpj_cpf,
			CASE 	WHEN char_length(rem.cnpj_cpf) = 9 
				THEN 'person'
				ELSE 'company'
			END::text as destinatario_tipo_contato,
			CASE 	WHEN dest.end_complemento IS NOT NULL 
				THEN trim(fpy_limpa_caracteres(dest.endereco)) || ', ' || trim(fpy_limpa_caracteres(dest.end_complemento)) 
				ELSE trim(fpy_limpa_caracteres(dest.endereco))
			END as destinatario_endereco,
			trim(fpy_limpa_caracteres(dest.numero)) as destinatario_numero,
			trim(fpy_limpa_caracteres(dest.bairro)) as destinatario_bairro,
			dest.id_cidade as destinatario_id_cidade, 
			dest.cep as destinatario_cep,
			(dest.ddd || ' ' || dest.telefone) as destinatario_telefone,
			trim(fpy_limpa_caracteres(cd.nome_cidade)) as destinatario_nome_cidade,
			cd.uf as destinatario_uf,
			dest.latitude as destinatario_latitude,
			dest.longitude as destinatario_longitude,
			dest.id_vuupt as destinatario_id_vuupt		
		FROM 
			fila_documentos_integracoes fd
			LEFT JOIN scr_romaneios r
				ON r.id_romaneio = fd.id_romaneio
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp
			LEFT JOIN fornecedores mot
				ON mot.id_fornecedor = r.id_motorista
			LEFT JOIN fornecedor_parametros fp
				ON fp.id_fornecedor = mot.id_fornecedor 
					AND id_tipo_parametro = 5
			LEFT JOIN fornecedores red
				ON red.id_fornecedor = r.id_transportador_redespacho
			LEFT JOIN cliente rem
				ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN cidades cr
				ON cr.id_cidade = rem.id_cidade
			
			LEFT JOIN cliente dest 
				ON dest.codigo_cliente = nf.destinatario_id
			LEFT JOIN cidades cd
				ON cd.id_cidade = dest.id_cidade
			
		WHERE
			--fd.id = 78
			fd.id = p_id_fila
			--nf.id_nota_fiscal_imp = 3839381
			--nf.id_nota_fiscal_imp = p_id_nf	
	)
	SELECT 
		row_to_json(row, true) 
	INTO 
		vDados
	FROM 
	(
		SELECT 
			nf.*
		FROM 
			nf
	
	) row;        

	RETURN vDados;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
--SELECT * FROM fila_documentos_integracoes
