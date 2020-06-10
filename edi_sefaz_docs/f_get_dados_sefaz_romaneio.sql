--SELECT * FROM edi_sefaz_docs
--SELECT f_get_arquivo_sefaz('ROMANEIO_CANCELAMENTO', current_date, 161679)
--SELECT * FROM f_get_dados_sefaz_romaneio(161679)
--UPDATE edi_sefaz_docs SET funcao_responsavel = 'f_get_dados_sefaz_romaneio'

CREATE OR REPLACE FUNCTION f_get_dados_sefaz_romaneio(p_id_romaneio integer)
  RETURNS json AS
$BODY$
DECLARE
        vResultado json;
BEGIN

	WITH t AS (
		SELECT 	
			r.id_romaneio,
			r.cod_empresa,
			r.cod_filial,
			'91'::text as mod,
			'1'::text as serie,
			right(r.numero_romaneio,7) as nct,
			to_char(r.data_saida, 'YYYY-MM-DD HH24:MI:SS') as dhemi,
			'0'::text as tpamb,
			'0'::text as tpcte,
			CASE WHEN tipo_modal = 1 THEN '01' ELSE '02' END::text as modal,
			CASE WHEN id_transportador_redespacho IS NOT NULL THEN '0' ELSE '2' END::text as tpserv,
			origem.cod_ibge as cmunini,
			origem.uf as ufini,
			COALESCE(setor_destino.cod_ibge, destino.cod_ibge) as cmunfim,
			COALESCE(setor_destino.uf, destino.uf) as uffim,
			'0'::text as toma,
			('DOCUMENTO ROMANEIO ' || r.numero_romaneio)::text as compl_xobs,
			''::text as obscont_xcampo,
			''::text as obscont_xtexto,
			filial.cnpj as emit_cnpj,		
			fc.cod_ibge as emit_enderemit_cmun,		
			trim(fc.uf) as emit_enderemit_uf,
			filial.cnpj as rem_cnpj,
			trim(filial.inscricao_estadual) as rem_ie,
			trim(filial.razao_social) as rem_xnome,
			trim(filial.endereco) as rem_enderrem_xlgr,
			trim(COALESCE(filial.numero,'')) as rem_enderrem_nro,
			trim(filial.bairro) as rem_enderrem_xbairro,
			fc.cod_ibge as rem_enderrem_cmun,
			trim(fc.nome_cidade) as rem_enderrem_xmun,
			trim(filial.cep) as rem_enderrem_cep,
			trim(fc.uf) as rem_enderrem_uf,
			2::integer as tipo_pessoa_dest,
			filial.cnpj as dest_cnpj,
			trim(filial.inscricao_estadual) as dest_ie,
			trim(filial.razao_social) as dest_xnome,
			trim(filial.endereco) as dest_enderdest_xlgr,
			trim(COALESCE(filial.numero,'')) as dest_enderdest_nro,
			trim(filial.bairro) as dest_enderdest_xbairro,
			fc.cod_ibge as dest_enderdest_cmun,
			trim(fc.nome_cidade) as dest_enderdest_xmun,
			trim(filial.cep) as dest_enderdest_cep,
			trim(fc.uf) as dest_enderdest_uf,
			SUM(nf.valor) as infcarga_vcarga,
			'4'::text as responsavel_seguro,
			SUM(nf.valor) as seg_vcarga
		FROM 
			scr_romaneios r
			LEFT JOIN filial
				ON filial.codigo_empresa = r.cod_empresa
					AND filial.codigo_filial = r.cod_filial
			LEFT JOIN cidades fc
				ON fc.id_cidade = filial.id_cidade
			LEFT JOIN cidades origem 
				ON origem.id_cidade = r.id_origem
			LEFT JOIN cidades destino
				ON destino.id_cidade = r.id_destino
			LEFT JOIN regiao setor
				ON setor.id_regiao = r.id_setor
			LEFT JOIN cidades setor_destino
				ON setor_destino.id_cidade = setor.id_cidade_polo
			LEFT JOIN scr_romaneio_nf rnf
				ON rnf.id_romaneio = r.id_romaneio
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
		WHERE 
			r.id_romaneio = p_id_romaneio
		GROUP BY 
			r.id_romaneio,
			filial.id_filial,
			fc.id_cidade,
			origem.id_cidade,
			destino.id_cidade,
			setor_destino.id_cidade,
			setor.id_regiao
			

	) 
	SELECT row_to_json(t, true) as romaneio INTO vResultado FROM t;
	--SELECT * FROM scr_romaneios WHERE id_romaneio = 160511;


	RETURN vResultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


