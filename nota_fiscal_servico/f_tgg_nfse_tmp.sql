-- Function: public.f_tgg_vuupt_tmp()
--SELECT * FROM nfse_tmp
-- DROP FUNCTION public.f_tgg_vuupt_tmp();

CREATE OR REPLACE FUNCTION public.f_tgg_nfse_tmp()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id integer;
	v_destinatario_cnpj text;
	v_numero_nota_fiscal text;
	v_evento text;
	v_id_nf integer;
	vDados json;	
	vCursor refcursor;
	v_id_ocorrencia integer;	
	v_data_emissao date;
	v_situacao text;
	v_numero_nfse text;
	v_serie text;
	v_lote text;
	v_autorizacao date;
	v_mensagem text;
	v_codigo_verificacao text;
	v_pdf text;
	v_xml text;
	v_id_integracao text;
	
BEGIN

	
	
	vDados = NEW.dados::json;

	v_situacao = ((vDados->>'situacao'));
	v_id_integracao = vDados->>idIntegracao;

	v_id_nf = RIGHT(v_id_integracao, 7)::integer;

	IF v_situacao = 'CONCLUIDO' THEN
	 		
		v_numero_nfse =  vDados->>'numeroNfse';
		v_data_emissao = vDados->>'emissao';
		v_serie = vDados->>'serie';
		v_lote = vDados->>'lote';
		v_codigo_verificacao = vDados->>'codigoVerificacao';
		v_autorizacao = (vDados->>'autorizacao')::date;
		v_mensagem = vDados->>'mensagem';
		v_pdf = vDados->>'pdf';
		v_xml = vDados->>'xml';	

		
		UPDATE com_nf SET
			numero_nota_fiscal = com_nf.codigo_empresa || com_nf.codigo_filial || LPAD(RIGHT(v_numero_nfse,7),7,'0'),
			serie_doc = v_serie, 
			numero_documento = LPAD(RIGHT(v_numero_nfse,9),9,'0'),
			data_emissao = (RIGHT(v_data_emissao,4) || '-' || SUBSTR(v_data_emissao, 3,2) || '-' || LEFT(v_data_emissao,2))::timestamp,
			data_saida_entrada = (RIGHT(v_data_emissao,4) || '-' || SUBSTR(v_data_emissao, 3,2) || '-' || LEFT(v_data_emissao,2))::timestamp,
			lote = v_lote,
			cstat = 100,
			xmotivo = 'RPS Autorizada com sucesso',
			data_autorizacao = (RIGHT(v_autorizacao,4) || '-' || SUBSTR(v_autorizacao, 3,2) || '-' || LEFT(v_autorizacao,2))::timestamp,
			numero_recibo = v_codigo_verificacao,
			pdf_nfse = v_pdf,
			xml_nfse = v_xml
		WHERE
			com_nf.id_nf = v_id_nf;

		
			
			
		
	END IF;

	IF v_situacao = 'REJEITADO' THEN 	
		UPDATE com_nf SET
			xmotivo = v_mensagem
		WHERE
			com_nf.id_nf = v_id_nf;		
	END IF;


	IF v_situacao = 'CANCELADO' THEN 	
		v_mensagem = vDados->>'mensagem';
		UPDATE com_nf SET
			data_cancelamento = NOW()
		WHERE
			com_nf.id_nf = v_id_nf;
		
	END IF;	
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
