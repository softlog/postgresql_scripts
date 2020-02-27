--SELECT * FROM fila_documentos_integracoes ORDER BY 1 DESC LIMIT 100
CREATE OR REPLACE FUNCTION f_reenvia_romaneio_vuupt(p_id_romaneio integer)
  RETURNS integer AS
$BODY$
DECLARE
	vIdFila integer;        
        vIdRomaenioVuupt integer;        
BEGIN
/*       
	SELECT 
		id,		
		id_integracao
	FROM 
		fila_documentos_integracoes
	WHERE
		id_romaneio = 119237
		AND tipo_documento = 4
		AND enviado = 1;

	SELECT 
		id_nota_fiscal_imp,
		id_integracao
	FROM
		fila_documentos_integracoes f
	WHERE 
		f.id_romaneio = 119237
		AND f.tipo_documento = 1
	
	3 = Verifica se tem nf acrescentada
	4 = Verifica se motorista 
	5 = Seta coluna alterar para 1
*/

	--1 = Verifica se o romaneio está na fila - Ok

	SELECT 
		id,		
		id_integracao
	INTO 
		vIdFila,		
		vIdRomaneioVuupt
	FROM 
		fila_documentos_integracoes
	WHERE
		id_romaneio = p_id_romaneio
		AND tipo_documento = 4
		AND enviado = 1;


	--2 = Verifica se tem nf excluída 
	WITH notas_romaneio AS (
		SELECT 
			nf.id_nota_fiscal_imp,
			r.id_romaneio
		FROM 		
			scr_romaneios r				
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_romaneio = r.id_romaneio
		WHERE
			r.id_romaneio = 119237
			--r.id_romaneio = p_id_romaneio
	)
	, notas_fila AS (
		SELECT 
			id_nota_fiscal_imp,
			id_integracao
		FROM
			fila_documentos_integracao f
		WHERE 
			f.id_romaneio = 119237
			AND f.tipo_documento = 1			
	)
	, notas_excluidas AS (
		
	)
	

	RETURN 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;