-- Function: public.f_edi_notfis_nfe_romaneio_dng(integer)

-- DROP FUNCTION public.f_edi_notfis_nfe_romaneio_dng(integer);

CREATE OR REPLACE FUNCTION public.f_edi_notfis_nfe_romaneio_softlog(p_id_romaneio integer)
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
		
	WITH t AS (
		SELECT 				
		
			r311.registro || 
			r312.registro || 
			r313.registro || 
			r333.registro || 
			r316.registro || 
			r317.registro as registros
			
		FROM 

			v_notfis_nfe_313_softlog_v31 r313
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro AND r333.id_romaneio = r313.id_romaneio
			LEFT JOIN v_notfis_311_v31 r311 ON r311.id_registro = r313.remetente_id	
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id
			LEFT JOIN v_notfis_316_v31 r316 ON r316.codigo_filial = r313.filial_emitente AND 
							r316.codigo_empresa = r313.empresa_emitente
			LEFT JOIN v_notfis_317_v31 r317 ON r317.codigo_filial = r313.filial_emitente AND 
							r317.codigo_empresa = r313.empresa_emitente
							
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

	vEdiNotFis = vCabecalho  || vEdiNotFis || vRodape;
	
	RETURN COALESCE(vEdiNotFis,'');
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
