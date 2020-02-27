CREATE TABLE vuupt_tmp
(
	id serial NOT NULL,
	dados text,
	CONSTRAINT vuupt_id_pk PRIMARY KEY (id)
 );

ALTER TABLE vuupt_tmp ADD COLUMN data_registro timestamp DEFAULT NOW();
ALTER TABLE vuupt_tmp ADD COLUMN id_edi_ocorrencia_entrega integer;

--SELECT * FROM vuupt_tmp LIMIT 1
--SELECET
--DELETE FROM edi_ocorrencias_entrega WHERE servico_integracao = 5

--SELECT * FROM edi_ocorrencias_entrega
UPDATE vuupt_tmp SET id_edi_ocorrencia_entrega = NULL WHERE id_edi_ocorrencia_entrega > 0;

SELECT * FROM vuupt_tmp ORDER BY 1 DESC 
--SELECT * FROM edi_tms_agenda_envio WHERE id_banco_dados = 53


CREATE OR REPLACE FUNCTION f_tgg_vuupt_tmp()
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
	
BEGIN

	IF NEW.id_edi_ocorrencia_entrega IS NOT NULL THEN 
		RETURN NEW;
	END IF;	
	vDados = NEW.dados::json;

	v_evento = vDados->>'event' ;

	IF NOT v_evento = 'Vuupt\Events\Service\ServiceDoneEvent' THEN 
		NEW.id_edi_ocorrencia_entrega = 0;
		RETURN NEW;
	END IF;

	v_numero_nota_fiscal = ((vDados->>'payload')::json->>'code') as numero_nota_fiscal;
	v_id = ((vDados->>'payload')::json->>'id')::integer;

	
	IF (vDados->>'payload')::json->>'status_done' = 'success' THEN 
		--RAISE NOTICE 'Sucesso';
		v_id_ocorrencia = 1;
	ELSE
		--RAISE NOTICE 'Motivo Insucesso %',vDados->>'failed_reason_id';
		v_id_ocorrencia = ((vDados->>'payload')::json->>'failed_reason_id')::integer;
	END IF;
	--Se o servico nao foi feito via integracao
	IF char_length(v_numero_nota_fiscal) < 13 THEN 
	
		v_destinatario_cnpj = ((vDados->>'payload')::json->>'customer')::json->>'code' as destinatario_cnpj;

		OPEN vCursor FOR 
		INSERT INTO edi_ocorrencias_entrega (
			servico_integracao,
			numero_nfe,
			serie_nfe,
			cnpj_emitente,
			chave_nfe,
			data_ocorrencia,
			id_nota_fiscal_imp,
			latitude, 
			longitude,
			numero_ocorrencia,
			id_ocorrencia_app
		)
		SELECT 
			5,
			nf.numero_nota_fiscal,
			nf.serie_nota_fiscal,
			r.cnpj_cpf,
			nf.chave_nfe,
			((vDados->>'payload')::json->>'completed_at')::timestamp,
			nf.id_nota_fiscal_imp,
			((vDados->>'payload')::json->>'latitude'),
			((vDados->>'payload')::json->>'longitude'),
			v_id_ocorrencia,
			v_id::integer
		FROM 
			scr_notas_fiscais_imp nf
			LEFT JOIN cliente d
				ON d.codigo_cliente = nf.destinatario_id	
			LEFT JOIN cliente r
				ON r.codigo_cliente = nf.remetente_id
		WHERE 
			numero_nota_fiscal::integer = v_numero_nota_fiscal::integer
			AND d.cnpj_cpf = v_destinatario_cnpj
		RETURNING id;	

		FETCH vCursor INTO v_id_ocorrencia;

		CLOSE vCursor;

		NEW.id_edi_ocorrencia_entrega = v_id_ocorrencia;
			
	ELSE	
		OPEN vCursor FOR
		INSERT INTO edi_ocorrencias_entrega (
			servico_integracao,
			numero_nfe,
			serie_nfe,
			cnpj_emitente,
			chave_nfe,
			data_ocorrencia,
			id_nota_fiscal_imp,
			latitude, 
			longitude,
			numero_ocorrencia,
			id_ocorrencia_app
		)
		SELECT 
			5,
			nf.numero_nota_fiscal,
			nf.serie_nota_fiscal,
			r.cnpj_cpf,
			nf.chave_nfe,
			((vDados->>'payload')::json->>'completed_at')::timestamp,
			nf.id_nota_fiscal_imp,
			((vDados->>'payload')::json->>'latitude'),
			((vDados->>'payload')::json->>'longitude'),
			v_id_ocorrencia,
			v_id::integer
		FROM 
			fila_documentos_integracoes fd
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = fd.id_nota_fiscal_imp			
			LEFT JOIN cliente r
				ON r.codigo_cliente = nf.remetente_id
		WHERE 
			fd.tipo_documento = 1 
			AND id_integracao = v_id
			AND tipo_integracao = 5
		RETURNING id;	

		FETCH vCursor INTO v_id_ocorrencia;

		CLOSE vCursor;

		NEW.id_edi_ocorrencia_entrega = v_id_ocorrencia;
		
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_vuupt_tmp 
BEFORE INSERT OR UPDATE 
ON vuupt_tmp
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_vuupt_tmp()



--SELECT * FROM vuupt_tmp