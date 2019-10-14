--SELECT * FROm efd_fiscal_bloco_ecf v_efd_fiscal_bloco_c100
--ALTER VIEW v_efd_fiscal_bloco_c100 OWNER TO softlog_bsb;

CREATE OR REPLACE VIEW v_efd_fiscal_bloco_c100 AS 
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
tb_100 AS (
	SELECT 
		id,
		ord as id_ord,
		campos[3] as ind_oper,
		campos[4] as ind_emit,
		campos[5] as cod_part,
		campos[6] as cod_mod,
		campos[7] as cod_sit,
		campos[8] as ser,
		campos[9] as num_doc,
		campos[10] as chv_nfe,
		campos[11] as dt_doc,
		campos[12] as dt_e_s,		
		f_edi_sped_get_valor(campos[13]) as vl_doc,
		campos[14] as ind_pgto,
		f_edi_sped_get_valor(campos[15]) as vl_desc,
		f_edi_sped_get_valor(campos[16]) as vl_abat_nt,
		f_edi_sped_get_valor(campos[17]) as vl_merc,
		campos[18] as ind_frt,
		f_edi_sped_get_valor(campos[19]) as vl_frt,
		f_edi_sped_get_valor(campos[20]) as vl_seg,
		f_edi_sped_get_valor(campos[21]) as vl_out_da,
		f_edi_sped_get_valor(campos[22]) as vl_bc_icms,
		f_edi_sped_get_valor(campos[23]) as vl_icms,
		f_edi_sped_get_valor(campos[24]) as vl_bc_icms_st,
		f_edi_sped_get_valor(campos[25]) as vl_icms_st,
		f_edi_sped_get_valor(campos[26]) as vl_ipi,
		f_edi_sped_get_valor(campos[27]) as vl_pis,
		f_edi_sped_get_valor(campos[28]) as vl_cofins,
		f_edi_sped_get_valor(campos[29]) as vl_pis_st,		
		f_edi_sped_get_valor(campos[30]) as vl_cofins_st		
	FROM 
		t2
	WHERE
		ident = 'C100'
	
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
		campos[13] as cfop		
	FROM 
		t2
	WHERE
		ident = 'C190'
	
) SELECT * FROM tb_100;


