-- View: public.v_notfis_nfe_313_v31
--SELECT * FROM v_notfis_nfe_313_v31 LIMIT 1
-- DROP VIEW public.v_notfis_nfe_313_v31;

CREATE OR REPLACE VIEW public.v_notfis_nfe_313_v31 AS 
 SELECT rnf.id_nota_fiscal_imp AS id_registro,
    nf.remetente_id,
    nf.destinatario_id,
    nf.consignatario_id,
    nf.id_conhecimento,
    rnf.id_romaneio,
    nf.empresa_emitente,
    nf.filial_emitente,
    ('313'::text 
    || rpad(''::text, 15, ' '::text)
    || rpad(''::text, 7, ' '::text) 
    || CASE
            WHEN nf.modal = 2 THEN '2'::text
            ELSE '1'::text
        END 
    || rpad(''::text, 1, '0'::text)
    || rpad(''::text, 1, '0'::text)
    || CASE
            WHEN nf.frete_cif_fob = 2 THEN 'F'::text
            ELSE 'C'::text
    END
    || lpad('001'::text, 3, '0'::text) 
    || lpad("right"(nf.numero_nota_fiscal::text, 8), 8, '0'::text) 
    || lpad(COALESCE(to_char(nf.data_emissao::timestamp with time zone, 'DDMMYYYY'::text), ''::text), 8, '0'::text)
    || rpad(COALESCE(nf.natureza_carga, ''::bpchar)::text, 15, ' '::text) 
    || rpad('UNIDADE'::text, 15, ' '::text) 
    || btrim(to_char(nf.volume_presumido, '00000V99'::text))
    || btrim(to_char(nf.valor, '0000000000000V99'::text))
    || btrim(to_char(nf.peso_presumido, '00000V99'::text)) 
    || btrim(to_char(nf.volume_cubico, '000V99'::text)) 
    || rpad(''::text, 1, ' '::text) 
    || rpad(''::text, 1, ' '::text)
    || btrim(to_char(0.00, '0000000000000V99'::text)) 
    || btrim(to_char(0.00, '0000000000000V99'::text)) 
    || rpad(''::text, 7, ' '::text) 
    || rpad(''::text, 1, ' '::text) 
    || btrim(to_char(0.00, '0000000000000V99'::text)) 
    || btrim(to_char(0.00, '0000000000000V99'::text)) 
    || btrim(to_char(0.00, '0000000000000V99'::text)) 
    || btrim(to_char(COALESCE(c.total_frete,0.00), '0000000000000V99'::text)) 
    || rpad('I'::text, 1, ' '::text)
    || btrim(to_char(0.00, '0000000000V99'::text)) 
    || btrim(to_char(0.00, '0000000000V99'::text)) 
    || rpad(''::text, 1, ' '::text)
    || rpad(''::text, 20, ' '::text)
    || rpad(''::text, 44, COALESCE(nf.chave_nfe::text, '0'::text))
    || rpad(''::text, 44, COALESCE(c.chave_cte, '0'::text)) 
    || btrim(to_char(nf.valor_total_produtos, '0000000000V99'::text)) 
    || chr(13)|| chr(10) ) AS registro
   FROM scr_notas_fiscais_imp nf
     LEFT JOIN scr_romaneio_nf rnf ON rnf.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
     LEFT JOIN scr_conhecimento c
	ON c.id_conhecimento = nf.id_conhecimento
    --WHERE rnf.id_romaneio IS NOT NULL AND nf.id_nota_fiscal_imp  = 774337
   
UNION 
SELECT nf.id_conhecimento_notas_fiscais AS id_registro,
    c.remetente_id,
    c.destinatario_id,
    c.consig_red_id as consignatario_id,
    c.id_conhecimento,
    rnf.id_romaneios as id_romaneio,
    c.empresa_emitente,
    c.filial_emitente,
    ((((((((((((((((((((((((((((((('313'::text || rpad(''::text, 15, ' '::text)) || rpad(''::text, 7, ' '::text)) ||
        CASE
            WHEN c.modal = 2 THEN '2'::text
            ELSE '1'::text
        END) || rpad(''::text, 1, '0'::text)) || rpad(''::text, 1, '0'::text)) ||
        CASE
            WHEN c.frete_cif_fob = 2 THEN 'F'::text
            ELSE 'C'::text
        END) || lpad('001'::text, 3, '0'::text)) 
		|| lpad("right"(nf.numero_nota_fiscal::text, 8), 8, '0'::text)) 
		|| lpad(COALESCE(to_char(nf.data_nota_fiscal::timestamp with time zone, 'DDMMYYYY'::text), ''::text), 8, '0'::text)) 
		|| rpad(COALESCE(c.natureza_carga, ''::bpchar)::text, 15, ' '::text)) 
		|| rpad('UNIDADE'::text, 15, ' '::text)) 
		|| btrim(to_char(nf.qtd_volumes, '00000V99'::text))) 
		|| btrim(to_char(nf.valor, '0000000000000V99'::text))) 
		|| btrim(to_char(nf.peso, '00000V99'::text))) 
		|| btrim(to_char(nf.volume_cubico, '000V99'::text))) 
		|| rpad(''::text, 1, ' '::text)) 
		|| rpad(''::text, 1, ' '::text)) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| rpad(''::text, 7, ' '::text)) 
		|| rpad(''::text, 1, ' '::text)) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| btrim(to_char(0.00, '0000000000000V99'::text))) 
		|| rpad('I'::text, 1, ' '::text)) 
		|| btrim(to_char(0.00, '0000000000V99'::text))) 
		|| btrim(to_char(0.00, '0000000000V99'::text))) 
		|| rpad(''::text, 1, ' '::text)) 
		|| rpad(''::text, 20, ' '::text)
		|| rpad(''::text, 44, COALESCE(nf.chave_nfe::text, '0'::text))) 
		|| rpad(''::text, 44, COALESCE(c.chave_cte::text, '0'::text))) 
		|| btrim(to_char(nf.valor_total_produtos, '0000000000000V99'::text)) 
		|| chr(13)|| chr(10)  AS registro
FROM 
	scr_conhecimento_entrega rnf
	LEFT JOIN scr_conhecimento c	
		ON c.id_conhecimento = rnf.id_conhecimento
	LEFT JOIN scr_conhecimento_notas_fiscais nf
		ON c.id_conhecimento = nf.id_conhecimento
--WHERE nf.id_conhecimento_notas_fiscais = 774337

/*
	
-- SELECT * FROM scr_conhecimento_notas_fiscais LIMIT 1	
-- SELECT id_fornecedor, nome_razao FROM fornecedores WHERE nome_razao like '%DNG%'
-- SELECT * FROM scr_romaneios WHERE id_transportador_redespacho = 1470
-- SELECT * FROM f_edi_notfis_nfe_romaneio(31592)

SELECT * FROM f_edi_notfis_nfe_romaneio(31243) as texto_edi;

-- SELECT * FROM v_notfis_nfe_313_v31 WHERE id_romaneio = 31243
-- SELECT * FROM v_notfis_nfe_313_v31 WHERE id_romaneio = 30494
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
			v_notfis_nfe_313_v31 r313
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro				
			LEFT JOIN v_notfis_311_v31 r311 ON r311.id_registro = r313.remetente_id	
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id
			LEFT JOIN v_notfis_316_v31 r316 ON r316.codigo_filial = r313.filial_emitente AND 
							r316.codigo_empresa = r313.empresa_emitente
			LEFT JOIN v_notfis_317_v31 r317 ON r317.codigo_filial = r313.filial_emitente AND 
							r317.codigo_empresa = r313.empresa_emitente
		WHERE r313.id_romaneio = 31592
	)
	SELECT 
		string_agg(t.registros,'')
	INTO 
		vEdiNotFis 
	FROM 
		t;

WITH t AS (
		SELECT
			r311.registro || 
			r312.registro || 
			r313.registro || 
			r333.registro || 
			r316.registro || 
			r317.registro as registros
		FROM 
			v_notfis_nfe_313_v31 r313
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro AND r333.id_romaneio = r313.id_romaneio
			LEFT JOIN v_notfis_311_v31 r311 ON r311.id_registro = r313.remetente_id	
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id
			LEFT JOIN v_notfis_316_v31 r316 ON r316.codigo_filial = r313.filial_emitente AND 
							r316.codigo_empresa = r313.empresa_emitente
			LEFT JOIN v_notfis_317_v31 r317 ON r317.codigo_filial = r313.filial_emitente AND 
							r317.codigo_empresa = r313.empresa_emitente
		WHERE r313.id_romaneio = 31592

	)
	SELECT 
		string_agg(t.registros,'')
	
	FROM 
		t;



311090531340001450749251000173  INTERSECCAO ROD DF001 C/ROD 475         BRASILIA                           72427010 DF       06052021ELFA MEDICAMENTOS S.A.                                                                                     
312MUNICIPIO DE CHALE                      18392548000190               R CEL JOSE MARIA GOMES                  CENTRO              CHALE                              36985000 3116001  MG           3333451425                         1      
313                      100C0010025816205052021DIVERSOS       UNIDADE        0000400000000000013935000016000000  000000000000000000000000000000        000000000000000000000000000000000000000000000000000000000000I000000000000000000000000 53210509053134000145550050002581621100008635
33361080000000000000000000000000                          000000000000000           000000000000000           000000000000000           000000000000000           000000000000000           000000000000000                                     
316BSB-DF TRANSPORTES DE CARGAS LTDA - ME  089445560001480748976900130  ADE CONJUNTO 27,  LOTES 28/29           AGUAS CLARAS        BRASILIA                           71991140 5300108  DF           6133865726                                
317BSB-DF TRANSPORTES DE CARGAS LTDA - ME  089445560001480748976900130  ADE CONJUNTO 27,  LOTES 28/29           AGUAS CLARAS        BRASILIA                           71991140 5300108  DF       6133865726                                    



		SELECT * FROM v_notfis_nfe_313_v31 WHERE id_registro = 774337

		SELECT * FROM v_notfis_318_v31 WHERE id_romaneio = 31243


		SELECT * FROM scr_conhecimento_entrega WHERE id_romaneios = 31243


		SELECT * FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = 427358


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

SELECT * FROM 


SELECT 
	registro
FROM
	scr_romaneios r
	LEFT JOIN v_notfis_000_310_v31 t ON t.codigo_filial = r.cod_filial AND t.codigo_empresa = r.cod_empresa
WHERE 
	id_romaneio = 30494;

SELECT 			
			r311.registro || 
			r312.registro || 
			r313.registro || 
			COALESCE(r333.registro,'') || 
			COALESCE(r316.registro,'') || 
			COALESCE(r317.registro,'') as registros
		FROM 
			v_notfis_nfe_313_v31 r313
			LEFT JOIN v_notfis_333_v31 r333 ON r333.id_registro = r313.id_registro
			LEFT JOIN v_notfis_311_v31 r311 ON r311.id_registro = r313.remetente_id
			LEFT JOIN v_notfis_312_v31 r312 ON r312.id_registro = r313.destinatario_id
			LEFT JOIN v_notfis_316_v31 r316 ON r316.codigo_filial = r313.filial_emitente AND 
							r316.codigo_empresa = r313.empresa_emitente
			LEFT JOIN v_notfis_317_v31 r317 ON r317.codigo_filial = r313.filial_emitente AND 
							r317.codigo_empresa = r313.empresa_emitente
		WHERE r313.id_romaneio = 30494


	SELECT 
		registro
	FROM
		v_notfis_318_v31 t 
	WHERE 
		id_romaneio = 30494;

*/
