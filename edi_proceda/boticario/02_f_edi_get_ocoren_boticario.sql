/*
-- Function: public.f_edi_get_doccob_v3(integer[])
--SELECT * FROM scr_conhecimento_ocorrencias_nf WHERE id_conhecimento = 221487
-- DROP FUNCTION public.f_edi_get_doccob_v3(integer[]);
-- SELECT * FROM scr_faturamento ORDER BY 1 DESC LIMIT 100
-- SELECT * FROM f_edi_get_doccob_v3(1162)
-- SELECT f_edi_get_ocoren_vyttra('{352027}'::integer[])as dados
-- OCOR_TIPODOCUMENTO

-- SELECT f_edi_get_ocoren_vyttra('{366748}'::integer[]);

SELECT * FROM msg_edi_lista_chaves WHERE lista_chaves = '366748';
SELECT id_conhecimento, remetente_nome FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010118295';

SELECT * FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = 221487
SELECT * FROM scr_conhecimento_notas_fiscais WHERE 

SELECT f_edi_get_ocoren_ssw('{19005882}'::integer[])
SELECT * FROM edi_tmdocs ORDER BY 1

SELECT * FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 58479


SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 17908201;



*/
CREATE OR REPLACE FUNCTION f_edi_get_ocoren_boticario(p_id integer)
  RETURNS json AS
$BODY$
DECLARE
	v_resultado json;
	str_sql text;
	v_cursor refcursor;
	v_id text;
BEGIN
	
WITH t AS (		
		
		SELECT 			
			id_ocorrencia_nf,
			trim(rem.cnpj_cpf) as cnpj_transportador,
			f.cnpj as cnpj_transportadora,
			nf.chave_nfe,	
			onf.id_ocorrencia,
			COALESCE(oc.codigo_cliente, onf.id_ocorrencia) as motivo_ocorrencia,		
			(to_char(onf.data_registro, 'YYYY-MM-DD HH24:MI:SS') || ':000-03:00') as data_registro,
			onf.data_ocorrencia as data,
			nf.nome_recebedor as recebedor, 
			nf.cpf_recebedor as recebedor_rg,
			nf.placa_veiculo,
			trim(mot.cnpj_cpf) as cpf_motorista
		FROM 			
			scr_notas_fiscais_imp_ocorrencias onf
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = onf.id_nota_fiscal_imp
			LEFT JOIN cliente rem
				ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN scr_ocorrencia_edi 	o	
				ON onf.id_ocorrencia = o.codigo_edi 
			LEFT JOIN filial f 
				ON f.codigo_empresa = nf.empresa_emitente AND f.codigo_filial = nf.filial_emitente
			LEFT JOIN cliente_edi_ocoren_depara oc
				ON oc.codigo_cliente = nf.remetente_id
					AND nfo.id_ocorrencia = oc.id_ocorrencia_softlog
			LEFT JOIN fornecedores mot
				ON mot.id_fornecedor = nf.id_motorista
		WHERE 
			--onf.id_ocorrencia_nf = lst_ids[1]
			--onf.id_ocorrencia_nf = 19603235
			onf.id_ocorrencia_nf = p_id
		
	)
	SELECT row_to_json(t)
	INTO v_resultado 
	FROM t;	
		
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



