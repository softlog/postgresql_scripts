-- Function: public.f_edi_notfis_nfe_romaneio_dng(text)

-- DROP FUNCTION public.f_edi_notfis_nfe_romaneio_dng(text);

CREATE OR REPLACE FUNCTION public.f_edi_notfis_nfe_romaneio_dng(p_lst_id_romaneio text)
  RETURNS text AS
$BODY$
DECLARE
	vCabecalho text;	
	vEdiNotFis text;
	vRodape text;
	
BEGIN

	WITH lista_romaneios AS (
		SELECT unnest(string_to_array(p_lst_id_romaneio,','))::integer as id_romaneio
	)
	SELECT  
		registro
	INTO 
		vCabecalho
	FROM
		scr_romaneios r
		LEFT JOIN v_notfis_000_310_v31 t ON t.codigo_filial = r.cod_filial AND t.codigo_empresa = r.cod_empresa
	WHERE 
		id_romaneio IN (select id_romaneio from lista_romaneios)
	LIMIT 1
	;
		

	WITH lista_romaneios AS (
		SELECT unnest(string_to_array(p_lst_id_romaneio,','))::integer as id_romaneio
	)
	,t AS (
		SELECT 			
			r311.registro || 
			r312.registro || 
			r313.registro || 
			r333.registro 	as registros		
		FROM 
			v_notfis_nfe_313_v31 r313
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro
			LEFT JOIN v_notfis_311_v31 r311 ON r311.id_registro = r313.remetente_id
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id
			
		WHERE r313.id_romaneio IN (SELECT id_romaneio from lista_romaneios)
	)
	SELECT 
		string_agg(t.registros,'')
	INTO 
		vEdiNotFis 
	FROM 
		t;


	WITH lista_romaneios AS (
		SELECT unnest(string_to_array(p_lst_id_romaneio,','))::integer as id_romaneio
	)
	SELECT 
		registro
	INTO 
		vRodape
	FROM
		v_notfis_nfe_313_v31 t 
	WHERE 
		id_romaneio IN (select id_romaneio from lista_romaneios);

	vEdiNotFis = vCabecalho || vEdiNotFis || vRodape;
	
	RETURN COALESCE(vEdiNotFis,'');
	
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
