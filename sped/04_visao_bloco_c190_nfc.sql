--ALTER VIEW v_efd_fiscal_bloco_c190 OWNER TO softlog_bsb;

CREATE OR REPLACE VIEW v_efd_fiscal_bloco_c190 AS 
WITH t AS (
	SELECT bloco_nfc as b, * FROM efd_fiscal_bloco_ecf WHERE COALESCE(bloco_nfc,'') <> ''
),
t1 AS (
	SELECT unnest(string_to_array(b,chr(13)||chr(10))) linha, id FROM t
),
t2 AS (
	SELECT 
		row_number() over (partition by 1) as ord, 	
		left(rtrim(ltrim(linha,'|'),'|'),4) as ident, 
		string_to_array(linha,'|') as campos,
		id
	FROM 
		t1
),
tb_190 AS (
	SELECT 
		id,
		ord as id_ord,
		ord -1 as id_tb_100,
		campos[3] as cst_icms,
		campos[4] as cfop,
		f_edi_sped_get_valor(campos[5]) as aliq_icms,
		f_edi_sped_get_valor(campos[6]) as vl_opr,
		f_edi_sped_get_valor(campos[7]) as vl_bc_icms,
		f_edi_sped_get_valor(campos[8]) as vl_icms,
		f_edi_sped_get_valor(campos[9]) as vl_bc_icms_st,
		f_edi_sped_get_valor(campos[10]) as vl_icms_st,
		f_edi_sped_get_valor(campos[11]) as vl_red_bc,
		f_edi_sped_get_valor(campos[12]) as vl_ipi,
		campos[13] as cod_obs		
	FROM 
		t2
	WHERE
		ident = 'C190'
	
) SELECT * FROM tb_190;


