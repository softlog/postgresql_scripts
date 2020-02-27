-- Function: public.f_edi_notfis_romaneio(integer)
--SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010131669'
-- DROP FUNCTION public.f_edi_notfis_romaneio(integer);
--SELECT numero_romaneio, * FROM scr_romaneios WHERE id_transportador_redespacho IS NOT NULL ORDER BY 1 DESC LIMIT 200
--SELECT * FROM v_mgr_notas_fiscais WHERE id_romaneio = 126904
--SELECT * FROM f_edi_notfis_panservice_nfe_romaneio(144060)

CREATE OR REPLACE FUNCTION public.f_edi_notfis_panservice_nfe_romaneio(p_id_romaneio integer)
  RETURNS text AS
$BODY$
DECLARE
	vCabecalho text;	
	vEdiNotFis text;
	vRodape text;	
BEGIN

	SELECT 
		registro
	INTO 
		vCabecalho
	FROM
		scr_romaneios r
		LEFT JOIN v_notfis_000_310_v31 t ON t.codigo_filial = r.cod_filial AND t.codigo_empresa = r.cod_empresa
	WHERE 
		id_romaneio = p_id_romaneio;
		
	WITH rom AS (
		SELECT
			id_romaneio,
			cod_empresa,
			cod_filial
		FROM 
			scr_romaneios
		WHERE
			id_romaneio = p_id_romaneio
	), 
	t AS (
		SELECT 			
			r311.registro || 
			r312.registro || 
			r313.registro as registros
		FROM 			
			v_notfis_nfe_313_v31 r313
			LEFT JOIN rom
				ON rom.id_romaneio = r313.id_romaneio
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro
			LEFT JOIN v_notfis_contratante_311_v31 r311 ON r311.codigo_filial = rom.cod_filial AND r311.codigo_empresa = rom.cod_empresa
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id			
		WHERE r313.id_romaneio = p_id_romaneio
	)
	SELECT 
		string_agg(t.registros,'')
	INTO 
		vEdiNotFis 
	FROM 
		t;


	SELECT 
		registro
	INTO 
		vRodape
	FROM
		v_notfis_318_v31 t 
	WHERE 
		id_romaneio = p_id_romaneio;

	vEdiNotFis = vCabecalho || vEdiNotFis || vRodape;
	
	RETURN COALESCE(vEdiNotFis,'');
	
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;

