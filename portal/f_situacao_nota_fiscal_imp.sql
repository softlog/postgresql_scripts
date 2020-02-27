-- Function: public.f_situacao_nota_fiscal_imp(integer)
/*
SELECT * FROM edi_ocorrencias_entrega
SELECt * FROM f_situacao_nota_fiscal_imp(44322,0)
SELECT * FROM scr_notas_fiscais_imp LIMIT 1
*/
-- DROP FUNCTION public.f_situacao_nota_fiscal_imp(integer);

CREATE OR REPLACE FUNCTION public.f_situacao_nota_fiscal_imp(p_id_nota_fiscal_imp integer, p_publica integer)
  RETURNS SETOF t_situacao_nota_fiscal_imp AS
$BODY$
DECLARE
	registro t_situacao_nota_fiscal_imp%rowtype;	
BEGIN

	FOR registro IN 			
		WITH nfe_log AS (
			SELECT  
				id_nota_fiscal_imp_log_atividade,
				nf_log.id_nota_fiscal_imp,
				data_hora,
				atividade_executada,
				usuario,
				historico,
				CASE 	WHEN atividade_executada = 'INCLUIDO EM ROMANEIO' 
					THEN trim((regexp_matches(historico,'\s\d+'))[1])::integer
					ELSE null
				END::integer as id_romaneio,
				CASE 	WHEN atividade_executada = 'INCLUIDO EM ROMANEIO' 
					THEN 1
					ELSE 0
				END::integer as incluido_romaneio,
				CASE 	WHEN left(atividade_executada,5) = 'BAIXA' 
					THEN trim((regexp_matches(atividade_executada,'\s\d+'))[1])::integer
					ELSE null
				END::integer as id_ocorrencia,
				CASE 	WHEN left(atividade_executada,5) = 'BAIXA' 
					THEN 1
					ELSE 0
				END::integer as tem_ocorrencia
				
			FROM	
				scr_notas_fiscais_imp_log_atividades nf_log 

			WHERE 
				id_nota_fiscal_imp = p_id_nota_fiscal_imp
				-- id_nota_fiscal_imp = 9215358					
		),
		nfe_log_min AS (
			SELECT MIN(id_nota_fiscal_imp_log_atividade) as primeira_ocorrencia FROM nfe_log			
		)		
		
		, nfe_oco AS (

			SELECT 
				nf_oco.id_nota_fiscal_imp,
				nf_oco.id_ocorrencia as id_ocorrencia_2,
				nf_oco.data_ocorrencia,
				nf_oco.data_registro as data_registro_oco,
				oco.ocorrencia,
				nf_oco.obs_ocorrencia,
				nf_oco.id_ocorrencia_nf			

			FROM  
				scr_notas_fiscais_imp_ocorrencias nf_oco
				LEFT JOIN scr_ocorrencia_edi oco 
					ON nf_oco.id_ocorrencia = oco.codigo_edi				
			WHERE 
				nf_oco.id_nota_fiscal_imp = p_id_nota_fiscal_imp
				--nf_oco.id_nota_fiscal_imp = 9215358
				
		),
		con AS (
			WITH temp AS (
				SELECT id_conhecimento 
				FROM scr_notas_fiscais_imp
				WHERE id_nota_fiscal_imp = p_id_nota_fiscal_imp
				--WHERE id_nota_fiscal_imp = 9215358
			)
			SELECT 
				c.id_conhecimento,
				c.numero_ctrc_filial,	
				c.data_emissao as data_emissao_con,
				c.tipo_documento,
				c.data_digitacao,
				c.total_frete,	
				c.regime_especial_mg,			
				CASE 	WHEN c.tipo_documento = 3 THEN 'MINUTA DE FRETE ' || c.numero_ctrc_filial
					WHEN c.tipo_documento = 2 THEN 'MINUTA '|| c.numero_ctrc_filial
					WHEN c.tipo_documento = 1 THEN 'CTe '|| c.numero_ctrc_filial
					WHEN c.id_conhecimento IS NULL THEN 'SEM CALCULO FRETE'				
				END::text as conhecimento
			FROM	
				scr_conhecimento c 
			WHERE
				EXISTS (SELECT 1
					FROM temp
					WHERE temp.id_conhecimento = c.id_conhecimento)
				AND tipo_documento <> 3
		)
		, nf AS (	
			--EXPLAIN ANALYSE 
			SELECT 				
				nf.id_nota_fiscal_imp,
				nf.serie_nota_fiscal, 
				nf.numero_nota_fiscal,
				nf.chave_nfe,
				(rem.nome_fantasia || ', ' || trim(cr.nome_cidade) || '-' || trim(cr.uf)) as remetente,
				(dest.nome_cliente || ', ' || trim(cd.nome_cidade)  || '-' || trim(cd.uf)) as destinatario,	
				--trim(to_char(r.id_romaneio,'9999999') || '-' ||  r.numero_romaneio) as romaneio,
				--v_rs.regiao,
				--v_rs.setor,
				COALESCE(nf.data_emissao,nf.data_emissao_hr) as data_emissao,
				nf.data_registro,
				nf.data_expedicao,
				nf.id_ocorrencia				

			FROM 				
				scr_notas_fiscais_imp nf 	
				LEFT JOIN cliente rem 
					ON rem.codigo_cliente = nf.remetente_id				
				LEFT JOIN cidades cr
					ON cr.id_cidade = rem.id_cidade::integer
				LEFT JOIN cliente dest 
					ON dest.codigo_cliente = nf.destinatario_id
				LEFT JOIN cidades cd 
					ON cd.id_cidade = dest.id_cidade::integer
 				--LEFT JOIN v_regiao_setores v_rs ON v_rs.id_cidade = dest.id_cidade::integer	
			WHERE 
				--nf.id_nota_fiscal_imp = p_id_nota_fiscal_imp
				nf.id_nota_fiscal_imp = p_id_nota_fiscal_imp
				--nf.id_nota_fiscal_imp = 9215358
		)
		, rom AS (	
			SELECT			
				o_r.nome_cidade as cidade_origem_calculo,
				d_r.nome_cidade as cidade_destino_calculo,
				r.data_saida,
				r.data_chegada,
				r.numero_romaneio as romaneio,				
				mot.nome_razao as motorista,		
				mot.cnpj_cpf as cpf_motorista,
				r.placa_veiculo,
				CASE 	WHEN r.tipo_destino = 'T' THEN 'TRANSFERENCIA' 
					WHEN r.tipo_destino = 'D' THEN 'DISTRIBUICAO'
					WHEN r.id_romaneio IS NULL THEN 'NAO ROMANEADO '
					ELSE 'ROMANEADA' 
				END::text as tipo_destino,
				r.id_origem,
				(o_r.nome_cidade || '-' || o_r.uf)::text as origem_romaneio,
				r.id_destino,
				(d_r.nome_cidade || '-' || d_r.uf)::text as destino_romaneio,
				r.id_setor,						
				r.id_romaneio
			FROM 
				scr_romaneio_nf r_nf 
				LEFT JOIN scr_romaneios r 
					ON r.id_romaneio = r_nf.id_romaneio AND r.cancelado = 0
				LEFT JOIN scr_romaneio_log_atividades rlog 
					ON rlog.id_romaneio = r.id_romaneio 					
				LEFT JOIN fornecedores mot 
					ON mot.id_fornecedor = r.id_motorista	
				LEFT JOIN cidades o_r 
					ON o_r.id_cidade = r.id_origem::integer
				LEFT JOIN cidades d_r 
					ON d_r.id_cidade = r.id_destino::integer
			WHERE 
				--id_nota_fiscal_imp = 9215358
				id_nota_fiscal_imp = p_id_nota_fiscal_imp
		)		
		, eventos AS (
			SELECT
				1::integer as peso,
				'EMISSAO NFE'::text as evento,
				remetente as unidade,
				data_emissao::timestamp as data,
				'Chave Nfe: ' || chave_nfe::text as detalhes,
				null::text as usuario,
				id_nota_fiscal_imp as id,				
				'DO FORM scr_notas_fiscais_imp.scx WITH [scr_notas_fiscais_imp], [id_nota_fiscal_imp], ' || id_nota_fiscal_imp::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM
				nf		
			UNION 
			SELECT 	
				2::integer as peso,
				'ENTREGUE A TRANSPORTADORA'::text as evento,
				'001'::text as unidade,
				data_registro as data,
				atividade_executada::text as detalhes,				
				usuario::text as usuario,
				nf.id_nota_fiscal_imp as id,
				'DO FORM scr_notas_fiscais_imp.scx WITH [scr_notas_fiscais_imp], [id_nota_fiscal_imp], ' || nf.id_nota_fiscal_imp::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM
				nfe_log_min
				LEFT JOIN nfe_log
					ON nfe_log.id_nota_fiscal_imp_log_atividade = nfe_log_min.primeira_ocorrencia				
				LEFT JOIN nf ON nf.id_nota_fiscal_imp = nfe_log.id_nota_fiscal_imp 
			UNION 
			SELECT
				3::integer as peso,
				'EXPEDICAO'::text as evento,
				'001'::text as unidade,
				data_expedicao::timestamp as data,
				''::text as detalhes,
				null::text as usuario,
				id_nota_fiscal_imp as id,
				'DO FORM scr_notas_fiscais_imp.scx WITH [scr_notas_fiscais_imp], [id_nota_fiscal_imp], ' || id_nota_fiscal_imp::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM
				nf
			WHERE
				p_publica = 1
			UNION 
			SELECT 
				4::integer as peso,
				('SAIDA ' || tipo_destino)::text as evento,
				origem_romaneio as unidade,
				data_saida as data,
				('Rom:' || romaneio || ', Mot:' || motorista || ', Veic:' || placa_veiculo)::text as detalhes,
				nfe_log.usuario::text as usuario,
				rom.id_romaneio as id,
				'DO FORM romaneio_coleta_entrega_novo_v01_novo.scx WITH [scr_romaneios], [id_romaneio], ' || rom.id_romaneio::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM 
				rom
				LEFT JOIN nfe_log ON nfe_log.id_romaneio = rom.id_romaneio AND nfe_log.incluido_romaneio = 1
			WHERE
				p_publica = 1
			UNION 
			SELECT 
				5::integer as peso,
				('CHEGADA ' || tipo_destino)::text as evento,
				CASE 	WHEN tipo_destino = 'DISTRIBUICAO' 
					THEN destinatario 
					ELSE destino_romaneio 
				END as unidade,
				data_chegada as data,
				('Rom:' || romaneio || ', Mot:' || motorista || ', Veic:' || placa_veiculo)::text as detalhes,
				null::text as usuario,
				id_romaneio as id,
				'DO FORM romaneio_coleta_entrega_novo_v01_novo.scx WITH [scr_romaneios], [id_romaneio], ' || id_romaneio::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM 
				nf, rom
			WHERE
				data_chegada IS NOT NULL
				AND p_publica = 1
			UNION 
			SELECT 
				6::integer as peso,
				CASE 
					WHEN id_ocorrencia_2 = 0 
					THEN 'INICIO VIAGEM' 
					ELSE 'OCORRENCIA ENTREGA' 
				END::text as evento,
				CASE 	WHEN app.latitude IS NOT NULL AND app.numero_ocorrencia IN (1,2)
					THEN '<a href="https://maps.google.com/?q=' || app.latitude::text || ',' || app.longitude::text || '" target="_blank">Localização</a>'
					ELSE ''
				END as unidade,
				nfe_oco.data_ocorrencia as data,
				CASE WHEN obs_ocorrencia IS NOT NULL AND trim(obs_ocorrencia) <> '' THEN 
					(ocorrencia || ' Obs.:' || obs_ocorrencia)::text 
				ELSE
					ocorrencia
				END::text as detalhes,
				nfe_log.usuario as usuario,
				id_ocorrencia_nf as id,
				''::text as form
								
			FROM 
				nf, nfe_oco
				LEFT JOIN nfe_log ON nfe_log.id_ocorrencia = nfe_oco.id_ocorrencia_2
				LEFT JOIN edi_ocorrencias_entrega app
					ON app.id_nota_fiscal_imp = nfe_oco.id_nota_fiscal_imp
						AND app.numero_ocorrencia = nfe_oco.id_ocorrencia_2
			UNION 
			SELECT
				7::integer as peso,
				'CALCULO FRETE'::text as evento,
				'001'::text as unidade,
				data_digitacao as data,
				conhecimento as detalhes,
				null::text as usuario,
				id_conhecimento as id,
				'DO FORM ctrc_aereo_v02.scx WITH [scr_conhecimento], [id_conhecimento], ' || id_conhecimento::text || ',[VISUALIZAR], thisform.Name '::text as form
			FROM 
				con
			WHERE
				p_publica = 1
			UNION 
			SELECT 
				8::integer as peso,
				'EMISSAO TRANSPORTE'::text as evento,
				'001'::text as unidade,
				data_emissao_con as data,
				''::text as detalhes,
				null::text as usuario,
				id_conhecimento as id,
				''::text as form
			FROM 
				con		
			WHERE
				p_publica = 1	
			
		)
		SELECT 
			evento,
			unidade,
			data,
			detalhes,
			usuario,
			id,
			form
		FROM 
			eventos 
		ORDER BY 
			data,
			peso
	LOOP
		RETURN NEXT registro;
	END LOOP;

	RETURN ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

