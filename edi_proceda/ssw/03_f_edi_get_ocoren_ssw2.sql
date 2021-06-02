/*
-- Function: public.f_edi_get_doccob_v3(integer[])
--SELECT * FROM scr_conhecimento_ocorrencias_nf WHERE id_conhecimento = 221487
-- DROP FUNCTION public.f_edi_get_doccob_v3(integer[]);
-- SELECT * FROM scr_faturamento ORDER BY 1 DESC LIMIT 100
-- SELECT * FROM f_edi_get_doccob_v3(1162)
-- SELECT f_edi_get_ocoren_vyttra('{352027}'::integer[])as dados
-- OCOR_TIPODOCUMENTO

-- SELECT f_edi_get_ocoren_vyttra('{366748}'::integer[]);

SELECT * FROM msg_edi_lista_chaves WHERE lista_chaves = '19143235';
SELECT id_conhecimento, remetente_nome FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010118295';

SELECT * FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = 221487
SELECT * FROM scr_conhecimento_notas_fiscais WHERE 

SELECT * FROM edi_tms_docs ORDER BY 1 

SELECT f_edi_get_ocoren_ssw2('{19005882}'::integer[])

SELECT * FROM edi_tms_embarcador_docs WHERE id_embarcador = 39 ORDER BY 1



SELECT * FROM edi_tms_agenda_envio WHERE id_banco_dados =107

SELECT f_edi_get_ocoren_ssw2('{19184565}'::integer[])as dados

124

SELECT * FROM f_edi_get_ocoren_ssw2('{19603235}')

SELECT * FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 58479

SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 17908201;

SELECT * FROM msg_edi_lista_chaves WHERE msg_edi_lista_chaves.lista_chaves = '19603235'
17908201
*/

CREATE OR REPLACE FUNCTION f_edi_get_ocoren_ssw2(lst_ids integer[])
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
			trim(edi.senha) as token,
			trim(rem.cnpj_cpf) as remetente_cnpj,
			f.cnpj as transportador_cnpj,
			c.id_conhecimento,
			null::integer as id_conhecimento_notas_fiscais,
			rpad(COALESCE(trim(leading from nf.serie_nota_fiscal,'0'),''),3,' ') AS serie_nota_fiscal,
			right(nf.numero_nota_fiscal::bigint::text,9) as numero_nota_fiscal,
			nf.chave_nfe,
			c.chave_cte,
			ossw.codigo_status as codigo_ocorrencia,
			trim(ossw.descricao) as ocorrencia,
			(to_char(onf.data_registro, 'YYYY-MM-DD HH24:MI:SS') || ':000-03:00') as data_registro,
			onf.data_ocorrencia,
			fpy_limpa_caracteres(trim(CASE 
				WHEN COALESCE(o.codigo_edi,0) = 0 	THEN 'PROCESSO DE TRANSPORTE INICIADO'
				WHEN COALESCE(codigo_edi,0) IN (1,2)	THEN 'ENTREGA REALIZADA. RECEBIDA POR: ' || 
										COALESCE(TRIM(UPPER(c.nome_recebedor)),'Nao Informado') 		 
							ELSE LEFT(o.ocorrencia,70) 
			END)) as observacao, 			
			fpy_limpa_caracteres(f_get_link_img(nf.id_nota_fiscal_imp,2)) as link_img
		FROM 			
			scr_notas_fiscais_imp_ocorrencias onf
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = onf.id_nota_fiscal_imp
			LEFT JOIN cliente rem
				ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN scr_conhecimento c	
				ON nf.id_conhecimento = c.id_conhecimento 	
			LEFT JOIN scr_ocorrencia_edi 	o	
				ON onf.id_ocorrencia = o.codigo_edi 
			LEFT JOIN edi_ocorrencias_ssw ossw
				ON ossw.id_ocorrencia_softlog = o.codigo_edi
			LEFT JOIN filial f 
				ON f.codigo_empresa = nf.empresa_emitente AND f.codigo_filial = nf.filial_emitente
			LEFT JOIN empresa 
				ON empresa.codigo_empresa = nf.empresa_emitente		
			LEFT JOIN cliente pag
				ON pag.codigo_cliente = nf.consignatario_id
			LEFT JOIN edi_tms_embarcadores emb
				ON emb.cnpj_cliente = pag.cnpj_cpf
			LEFT JOIN edi_tms_embarcador_docs edi
				ON edi.id_embarcador = emb.id_embarcador
			LEFT JOIN edi_tms_docs docs
				ON docs.id_doc = edi.id_doc	
		WHERE 
			--onf.id_ocorrencia_nf = lst_ids[1]
			onf.id_ocorrencia_nf = 19603235
			AND docs.tipo_doc = -4
			AND ossw.id_ocorrencia_softlog IS NOT NULL
		
	)
	SELECT row_to_json(t)
	--INTO v_resultado 
	FROM t;
		
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



