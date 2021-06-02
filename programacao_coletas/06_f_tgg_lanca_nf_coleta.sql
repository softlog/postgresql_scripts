CREATE OR REPLACE FUNCTION f_tgg_lanca_nf_coleta()
  RETURNS trigger AS
$BODY$
DECLARE
	v_id_coleta integer;
	v_id_natureza_carga integer;	
	vCursor refcursor;
BEGIN


	SELECT id_coleta 
	INTO v_id_coleta
	FROM col_coletas_itens
	WHERE id_nota_fiscal_imp = NEW.id_nota_fiscal_imp;


	IF v_id_coleta IS NULL THEN 

		SELECT id_natureza_carga
		INTO v_id_natureza_carga
		FROM scr_natureza_carga	
		WHERE trim(natureza_carga) = NEW.natureza_carga;

		--SELECT * FROM col_coletas_itens LIMIT 1
		--RAISE NOTICE 'Incluindo NF % na Programação %', NEW.chave_nfe, NEW.cod_interno_frete;
		OPEN vCursor FOR 
		INSERT INTO col_coletas_itens(
			id_coleta, 
			quantidade, 
			peso, 
			vol_m3, 
			valor_nota_fiscal,
			id_nota_fiscal_imp,
			id_natureza_carga, 
			data_nf,
			numero_nf,
			serie_nota_fiscal
		)
		SELECT 
			id_coleta,
			NEW.qtd_volumes,
			NEW.peso,
			NEW.volume_cubico,
			NEW.valor,
			NEW.id_nota_fiscal_imp,
			v_id_natureza_carga,
			NEW.data_emissao,
			NEW.numero_nota_fiscal,
			NEW.serie_nota_fiscal			
		FROM 
			col_coletas
		WHERE 
			col_coletas.cod_interno_frete = NEW.cod_interno_frete			
			AND col_coletas.filial_coleta = NEW.filial_emitente
			AND col_coletas.cod_empresa = NEW.empresa_emitente			
		RETURNING id_coleta;

		FETCH vCursor INTO v_id_coleta;

		CLOSE vCursor;
		
		IF v_id_coleta IS NOT NULL THEN 
			UPDATE col_coletas SET id_motorista = NEW.id_motorista WHERE id_coleta = v_id_coleta;
			--SELECT id_motorista FROM scr_notas_fiscais_imp					
			DELETE FROM col_coletas_itens WHERE id_nota_fiscal_imp IS NULL AND id_coleta = v_id_coleta;
		END IF;
			
	END IF;
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--SELECT id_coleta, id_nota_fiscal_imp, * FROM col_coletas_itens ORDER BY id_coleta
--SELECT id_nota_fiscal_imp, id_item_coleta  FROM col_coletas_itens
--SELECT id_nota_fiscal_imp FROM col_coletas_itens
--UPDATE scr_notas_fiscais_imp SET id_nota_fiscal_imp = id_nota_fiscal_imp 
