		INSERT INTO msg_edi_lista_chaves(
			empresa, 
			filial, 
			id_embarcador, 
			id_doc, 
			lista_chaves
		)
		WITH t AS ( 
			--Seleciona as entregas por data de emissao
			--SELECT * FROM v_mgr_notas_fiscais LIMIT 1
			--Seleciona as entregas por data de registro
			SELECT 			
				2::integer as id,
				nf.consignatario_id,
				empresa_emitente,				
				filial_emitente,
				id_ocorrencia_nf
			FROM
				v_mgr_notas_fiscais nf 			
				LEFT JOIN scr_notas_fiscais_imp_ocorrencias onf
					ON nf.id_nota_fiscal_imp = onf.id_nota_fiscal_imp
			WHERE	
				numero_nota_fiscal::integer = 58479
				--numero_nota_fiscal = '000016837'
				--f_data_entrega(c.data_entrega,c.hora_entrega)  >= v_data_ini 
				--onf.data_registro  >= '2020-11-10 00:00:00'::timestamp
				--AND 
				--f_data_entrega(c.data_entrega,c.hora_entrega)  < v_data_fim 
				--onf.data_registro >= '2020-11-20 00:00:00'::timestamp				
				AND nf.pagador_cnpj= trim('03608196000190')
				--AND data_entrega IS NOT NULL
			
		)
		SELECT 
			empresa_emitente,
			filial_emitente,
			39,
			65,			
			id_ocorrencia_nf::text			
		FROM 
			t;

/*


--SELECT * FROM msg_edi_lista_chaves ORDER BY 1 DESC LIMIT 10
--SELECT * FROM msg_edi_lista_chaves WHERE lista_chaves = '19684005'
--UPDATE scr_notas_fiscais_imp_ocorrencias SET id_ocorrencia_nf = id_ocorrencia_nf WHERE id_ocorrencia_nf = 19603235
--SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE id_nota_fiscal_imp = 17939172
--SELECT data_emissao FROM v_mgr_notas_fiscais WHERE chave_nfe = '35201010515224000513550030000424011100256770'
-- SELECT * FROM edi_tms_embarcadores
--03608196000190
--SELECT * FROM edi_tms_embarcador_docs ORDER BY 1 

SELECT id_nota_fiscal_imp, pagador_nome, pagador_cnpj, chave_nfe FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal::integer = 000081588


*/