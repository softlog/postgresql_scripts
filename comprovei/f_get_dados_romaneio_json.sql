/*
-- Function: public.f_get_dados_romaneio_json(integer, text)
-- SELECT * FROM f_get_dados_romaneio_json(236713,'07179903000120')
-- DROP FUNCTION public.f_get_dados_romaneio_json(integer, text);

SELECT * FROM fila_envio_romaneios ORDER BY 1 DESC LIMIT 1000
SELECT * FROM fila_envio_romaneios WHERE status_envio = 3;

SELECT id_nota_fiscal_imp, data_expedicao, remetente_nome, serie_nota_fiscal, id_romaneio, remetente_cnpj FROM v_mgr_notas_fiscais nf WHERE numero_nota_fiscal = '000671627'

SELECT codigo_cliente FROM cliente WHERE cnpj_cpf = '45453214001042'
SELECT * FROM msg_subscricao WHERE codigo_cliente = 6
SELECT * FROM v_cidades_polo WHERE id_cidade = 2303
SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 35545

SELECT id_romaneio, numero_romaneio, msg_integracao FROM scr_romaneios WHERE numero_romaneio IN ('0010010198170')

,
'0010010193824','0010010193825',
'0010010193826','0010010193827',
'0010010193828','0010010193829',
'0010010193830','0010010193832',
'0010010193833','0010010193834',
'0010010193835','0010010193836',
'0010010193850')


SELECT string_agg(id_romaneio::text,',') FROM scr_romaneios WHERE numero_romaneio IN ('0010010193823',
'0010010193824','0010010193825',
'0010010193826','0010010193827',
'0010010193828','0010010193829',
'0010010193830','0010010193832',
'0010010193833','0010010193834',
'0010010193835','0010010193836',
'0010010193850')

UPDATE fila_envio_romaneios SET status_envio = 0 WHERE id_romaneio IN (227347,227348,227349,227351,227352,227353,227354,227355,227356,227359,227358,227360,227361,227405)
SELECT * FROM fila_envio_romaneios WHERE id_romaneio IN (227347,227348,227349,227351,227352,227353,227354,227355,227356,227359,227358,227360,227361,227405)

SELECT f_get_dados_romaneio_json(id_romaneio, cnpjs_subscritos), * FROM  fila_envio_romaneios WHERE id_romaneio IN (233237)


SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 2 ORDER BY 1 DESC 

SELECT * FROM fila_envio_romaneios WHERE id_tipo_servico = 301 ORDER BY 1 DESC 

SELECT * FROM fila_envio_romaneios WHERE id_romaneio = 233237
SELECT * FROM cidades LIMIT 1
SELECT id_cidade, * FROM filial ORDER BY 1 DESC



*/

CREATE OR REPLACE FUNCTION public.f_get_dados_romaneio_json(
    p_id_romaneio integer,
    p_lista_cnpj text)
  RETURNS text AS
$BODY$
DECLARE
	v_resultado text;
BEGIN
	WITH 
	clientes AS (
		SELECT unnest(string_to_array(p_lista_cnpj,',')) as cnpj
	)
	, nfs AS (
		SELECT 
			rnf.id_nota_fiscal_imp,
			r.tipo_destino,
			r.id_romaneio
		FROM 
			scr_romaneio_nf rnf
			LEFT JOIN scr_romaneios r
				ON r.id_romaneio = rnf.id_romaneio
		WHERE rnf.id_romaneio = p_id_romaneio
	)
	, nf_rom_ant AS ( 
		SELECT 
			rnf.id_nota_fiscal_imp
		FROM 	
			nfs
			LEFT JOIN scr_romaneio_nf rnf
				ON rnf.id_nota_fiscal_imp = nfs.id_nota_fiscal_imp 
					AND rnf.id_romaneio <> p_id_romaneio					
			LEFT JOIN fila_envio_romaneios fila
				ON fila.id_romaneio = rnf.id_romaneio
			LEFT JOIN scr_romaneios r 
				ON rnf.id_romaneio = r.id_romaneio
									
		WHERE 
			1=1 
			--AND fila.data_registro < now()	
			AND fila.id_romaneio < p_id_romaneio
			AND fila.status_confirmacao = 1
			--AND rnf.id_romaneio <> p_id_romaneio
			AND rnf.id_nota_fiscal_imp IS NOT NULL
			AND nfs.tipo_destino = r.tipo_destino
			AND 1=2
	)	
	, rom AS (
			
		SELECT 
			r.id_romaneio, 
			null::text as rota_destino,
			'ROTA ' || r.numero_romaneio as rota_nome,
			to_char(r.data_saida,'YYYYMMDD') as data_romaneio,						
			COALESCE(red.cnpj_cpf, f.cnpj) as transportadora_cnpj,
			COALESCE(red.nome_razao, f.razao_social) as transportadora_nome,
			trim(mot.cnpj_cpf) as codigo_comprovei,
			trim(r.placa_veiculo) as placa_veiculo,
			NULL::text as limites,
			NULL::text as base,	
			COALESCE(r.tipo_destino, 'D')::text as tipo_rota,
			NULL::text as tipo_material,
			NULL::text as fornecimento,
			
			f.nome_descritivo as filial,
			mot.nome_razao AS motorista,
			mot.cnpj_cpf AS motorista_cpf,
					
			r.cod_empresa,
			r.cod_filial,
			r.tipo_romaneio,
			r.numero_romaneio,
			--scr_relatorio_viagem.numero_relatorio,
			r.tipo_frota AS tipo_frota_codigo,
			CASE
			    WHEN r.tipo_frota = 1 THEN 'Própria'::text
			    WHEN r.tipo_frota = 2 THEN 'Agregado'::text
			    ELSE 'Terceiro'::text
			END::character(10) AS tipo_frota,
			r.placa_reboque,
			r.placa_reboque2,
			r.id_origem,
			origem.nome_cidade AS cidade_origem,
			origem.sigla_cidade AS sigla_origem,
			origem.uf AS uf_origem,
			r.data_saida,
			COALESCE(r.id_destino, setor.id_regiao) as id_destino,
			destino.nome_cidade AS cidade_destino,
			destino.sigla_cidade AS sigla_destino,
			destino.uf AS uf_destino,
			r.data_chegada,
			r.cancelado,
			r.data_cancelamento,
			r.motivo_cancelamento,
			--count(scr_conhecimento.id_conhecimento)::numeric AS qtentregas,
			--count(col_coletas.id_coleta)::numeric AS qtcoletas,
			--string_agg(col_coletas.id_coleta_filial::text, ' / '::text)::character(200) AS lst_coletas,
			r.vl_servico_for,
			r.vl_adiantamentos_for,
			r.vl_acrescimos_for,
			r.vl_pagar_for,
			r.vl_despesas_diretas,
			r.total_peso,
			r.total_volume_cubado,
			r.total_peso_cubado,
			r.total_volumes::integer as total_volumes,
			r.total_frete,
			r.total_nf,
			r.id_acerto,
			r.baixa,
			r.fechamento,
			r.redespacho,
			r.id_transportador_redespacho,
			r.tipo_destino,
			f.id_cidade as id_base_origem,
			trim(f.nome_descritivo) as origem,
			trim(f.endereco) as origem_endereco,
			'0'::text as origem_numero,
			''::text as origem_complemento,
			trim(f.bairro) as origem_bairro,
			trim(fc.nome_cidade) as origem_cidade,
			trim(fc.uf) as origem_estado,
			trim(f.cep) as origem_cep,
			'BRASIL'::text as origem_pais,
			trim(fc.cod_ibge) as origem_ibge,
			COALESCE(v_cidades_polo.id_cidade, setor.id_cidade_polo) as id_base_destino,
			COALESCE(trim(fd.nome_descritivo), trim(setor.descricao)) as destino,
			COALESCE(trim(fd.endereco),'ND') as destino_endereco,
			'0'::text as destino_numero,
			''::text as destino_complemento,
			COALESCE(trim(fd.bairro),'CENTRO') as destino_bairro,
			COALESCE(trim(v_cidades_polo.nome_cidade),sc.nome_cidade) as destino_cidade,
			COALESCE(trim(v_cidades_polo.uf), sc.uf) as destino_estado,
			COALESCE(trim(fd.cep), '00000000') as destino_cep,
			'BRASIL'::text as destino_pais,
			COALESCE(trim(fdc.cod_ibge),trim(sc.cod_ibge)) as destino_ibge,
			trim(setor.descricao) as regiao
		FROM scr_romaneios r
-- 			LEFT JOIN scr_relatorio_viagem ON r.id_acerto = scr_relatorio_viagem.id_relatorio_viagem
			LEFT JOIN fornecedores mot ON r.id_motorista = mot.id_fornecedor
			LEFT JOIN fornecedor_parametros conf ON conf.id_fornecedor = mot.id_fornecedor AND conf.id = 1
			LEFT JOIN cidades origem ON r.id_origem = origem.id_cidade
			LEFT JOIN cidades destino ON r.id_destino = destino.id_cidade
-- 			LEFT JOIN scr_viagens_docs ON r.id_romaneio = scr_viagens_docs.id_romaneio
-- 			LEFT JOIN scr_romaneio_fechamentos ON r.id_romaneio = scr_romaneio_fechamentos.id_romaneio
-- 			LEFT JOIN scr_conhecimento_entrega ON scr_conhecimento_entrega.id_romaneios = r.id_romaneio
-- 			LEFT JOIN scr_conhecimento ON scr_conhecimento_entrega.id_conhecimento = scr_conhecimento.id_conhecimento
-- 			LEFT JOIN col_coletas_romaneio ON col_coletas_romaneio.id_romaneios = r.id_romaneio
-- 			LEFT JOIN col_coletas ON col_coletas.id_coleta = col_coletas_romaneio.id_coleta
			LEFT JOIN fornecedores red ON red.id_fornecedor = r.id_transportador_redespacho
			LEFT JOIN filial f ON r.cod_empresa = f.codigo_empresa AND r.cod_filial = f.codigo_filial
			LEFT JOIN cidades fc ON f.id_cidade = fc.id_cidade
			LEFT JOIN v_cidades_polo ON v_cidades_polo.id_cidade = r.id_destino
			LEFT JOIN filial fd ON fd.id_cidade = v_cidades_polo.id_cidade
			LEFT JOIN cidades fdc ON fdc.id_cidade = fd.id_cidade
			LEFT JOIN regiao setor	ON setor.id_regiao = r.id_setor
			LEFT JOIN cidades sc ON sc.id_cidade = setor.id_cidade_polo
		WHERE 
			r.tipo_romaneio = 1 
			AND r.numero_romaneio IS NOT NULL
			AND r.id_romaneio = p_id_romaneio
			--AND r.id_romaneio = 227347
			--SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010025246'	

	)
	, paradas_entrega AS (
		SELECT DISTINCT ON (nf.chave_nfe)			
			rnf.id_romaneio_nf as numero_parada,			
			nf.id_nota_fiscal_imp,
			rnf.id_romaneio,
			CASE WHEN tipo_rota = 'T' THEN 'T' ELSE 'E' END::character(1) as tipo_parada,
			NULL::text as observacao,
			'NFE'::text as tipo_documento,
			trim(to_char(nf.data_emissao,'YYYYMMDD')) as data_emissao,
			ltrim(nf.serie_nota_fiscal, '0') as serie, 
			ltrim(nf.numero_nota_fiscal, '0') as numero,
			nf.chave_nfe,
			nf.valor,
			'55'::character(2) as modelo_fiscal,
			trim(dest.cnpj_cpf) as cnpj, 
			trim(rem.cnpj_cpf) as cnpj_emissor,
			trim(rem.nome_cliente) as nome_emissor,
			trim(rom.transportadora_cnpj) as cnpj_transportador,
			NULL::text as remessa,
			NULL::text as pedido,
			rom.placa_veiculo,
			trim(rom.filial,'') as filial,
			nf.peso_presumido as peso,
			nf.volume_presumido as volume,
			NULL::numeric(16,6) as cubagem,
			NULL::text as onu,
			NULL::text as agendamento,
			nf.peso_liquido,
			NULL::integer as janela,
			NULL::text as data_hora_ini,
			NULL::text as data_hora_fim,
			NULL::text as tipo_material,
			NULL::text as fornecimento,
			trim(dest.cnpj_cpf) as cnpj_cpf,
			dest.codigo_cliente,
			NULL::text as contato,
			trim(dest.telefone) as telefone,
			trim(dest.email) as email,
			trim(dest.nome_cliente) as razao_social,
			trim(dest.endereco) as endereco,
			trim(dest.bairro) as bairro,
			dest.id_cidade,
			trim(cd.nome_cidade) as cidade,
			cd.uf as estado,
			dest.cep,
			'BRASIL'::text as pais,
			NULL::text as tipo_cliente,
			''::text as mensagem,
			NULL::text as gerente_codigo,
			NULL::text as gerente_nome,
			NULL::text as gerente_email,
			NULL::text as gerente_celular,
			NULL::text as supervisor_codigo,
			NULL::text as supervisor_email,
			NULL::text as danfes,
			nf.peso_presumido as sku_peso,
			nf.peso_liquido as sku_peso_liquido,
			nf.volume_presumido as sku_volume,
			('ITENS NFE ' || nf.numero_nota_fiscal)::text as sku_descricao,
			nf.qtd_volumes as sku_volume,
			'UN'::text as sku_unidade,
			nf.chave_nfe as sku_barcode,
			rom.data_saida,
			trim(pag.cnpj_cpf) as cnpj_pagador
		FROM
			scr_romaneio_nf rnf
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
			LEFT JOIN cliente rem
				ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN cliente dest 
				ON dest.codigo_cliente = nf.destinatario_id
			LEFT JOIN cliente pag
				ON pag.codigo_cliente = nf.consignatario_id
			LEFT JOIN cidades cd
				ON cd.id_cidade = dest.id_cidade
			LEFT JOIN rom
				ON rnf.id_romaneio = rom.id_romaneio
		WHERE rnf.id_romaneio = p_id_romaneio
			AND rem.cnpj_cpf IN (SELECT cnpj FROM clientes)
			AND NOT EXISTS (SELECT 1
					FROM nf_rom_ant
					WHERE nf_rom_ant.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
			)
		ORDER BY 
			nf.chave_nfe
	)
	, paradas AS (		
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json, id_romaneio FROM (
					SELECT 
						*
					FROM
						paradas_entrega
					ORDER BY
						id_romaneio, numero
				) row
			)
			SELECT id_romaneio, array_agg(json) as lista_paradas FROM temp GROUP BY id_romaneio
	)
	, rotas_p_finalizar AS (
		SELECT 
			paradas_entrega.id_romaneio,
			'ROTA ' || r.numero_romaneio as rota_nome,
			to_char(r.data_saida,'YYYYMMDD') as data_romaneio,
			mot.cnpj_cpf AS motorista_cpf
		FROM 
			paradas_entrega
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.chave_nfe = paradas_entrega.chave_nfe
			LEFT JOIN scr_romaneio_nf rnf
				ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
			LEFT JOIN scr_romaneios r
				ON r.id_romaneio = rnf.id_romaneio
			LEFT JOIN fornecedores mot ON r.id_motorista = mot.id_fornecedor	
		WHERE
			r.id_romaneio < paradas_entrega.id_romaneio
		GROUP BY
			1,
			2,
			3,
			4			
	
	)
	, rotas_fim AS (
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json, id_romaneio FROM (
					SELECT 
						*
					FROM
						rotas_p_finalizar
					ORDER BY
						id_romaneio
				) row
			)
			SELECT id_romaneio, array_agg(json) as lista_rotas FROM temp GROUP BY id_romaneio		
	)
	, rotas AS (
		WITH temp AS (
				SELECT (row_to_json(row,true))::json as json, id_romaneio FROM (
					SELECT 
						rom.id_romaneio, 
						rota_destino, 
						rota_nome,
						data_romaneio,
						regiao,
						transportadora_cnpj,
						trim(transportadora_nome) as transportadora_nome,
						codigo_comprovei,
						placa_veiculo,
						limites,
						base,
						tipo_rota,
						tipo_material,
						fornecimento,
						filial,
						motorista,
						trim(motorista_cpf) as motorista_cpf,
						paradas.lista_paradas as paradas,
						rotas_fim.lista_rotas as rotas_fim,
						rom.id_base_origem,
						rom.id_origem,
						rom.origem,
						rom.origem_endereco,
						rom.origem_numero,
						rom.origem_complemento,
						rom.origem_bairro,
						rom.origem_cidade,
						rom.origem_estado,
						rom.origem_cep,
						'BRASIL'::text as origem_pais,
						rom.origem_ibge,
						rom.id_base_destino,
						rom.id_destino,
						rom.destino,
						rom.destino_endereco,
						rom.destino_numero,
						rom.destino_complemento,
						rom.destino_bairro,
						rom.destino_cidade,
						rom.destino_estado,
						rom.destino_cep,
						rom.destino_pais,
						rom.destino_ibge
					FROM 
						rom
						LEFT JOIN paradas
							ON paradas.id_romaneio = rom.id_romaneio
						LEFT JOIN rotas_fim
							ON rotas_fim.id_romaneio = rom.id_romaneio
				) row
			)
			SELECT id_romaneio, array_agg(json) as rotas FROM temp GROUP BY id_romaneio
	)
	SELECT row_to_json(row, true) as json 
	INTO v_resultado
		FROM 
		(
			SELECT 
				rotas.rotas as rotas
			FROM 
				rotas
		) row;


	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

