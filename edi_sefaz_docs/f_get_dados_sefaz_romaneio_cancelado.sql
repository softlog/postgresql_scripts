--SELECT * FROM edi_sefaz_docs

--UPDATE edi_sefaz_docs SET funcao_responsavel = 'f_get_dados_sefaz_romaneio'

CREATE OR REPLACE FUNCTION f_get_xml_sefaz_romaneio_cancelamento(p_id_romaneio integer)
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
			'2'::text as tpamb,		
			trim(protocolo) as protocolo,
			to_char(COALESCE(r.data_cancelamento, now()), 'YYYY-MM-DD HH24:MI:SS') as data_recebimento,
			fc.uf as cuf
		FROM 			
			scr_romaneios r
			LEFT JOIN scr_romaneio_averbacao a
				ON a.id_romaneio = r.id_romaneio
			LEFT JOIN filial
				ON filial.codigo_empresa = r.cod_empresa
					AND filial.codigo_filial = r.cod_filial
			LEFT JOIN cidades fc
				ON fc.id_cidade = filial.id_cidade
		WHERE 
			r.id_romaneio = p_id_romaneio

	) 
	SELECT row_to_json(t, true) as romaneio INTO vResultado FROM t;
	--SELECT * FROM scr_romaneios WHERE id_romaneio = 160511;


	RETURN vResultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


