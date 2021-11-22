-- View: public.v_alertas
-- SELECT * FROM frt_pmveic
-- SELECT * FROM frt_pmveic
-- DROP VIEW public.v_alertas;
/*
Explain ANALYSE
SELECT * FROM v_alertas WHERE data_vencto >= current_date
*/
--SELECT * FROM v_alertas_2
CREATE OR REPLACE VIEW public.v_alertas AS 
WITH 
	prox_manut AS (
		WITH    cur_veic AS (
			    -- Traz os veiculos validos
			    SELECT  placa_veiculo,
				    chk_km,
				    odometro_atual,
				    horimetro_atual 
			    FROM    veiculos
			    WHERE   ativo = 1
			    AND     bloqueado <> 1
			    )

			    ,cur_maxkm AS (
			    -- pega atualização de maior KM/HR pelo histórico
			    SELECT 	k.placa_veiculo,
				    MAX(COALESCE(k.veic_km,0))::INTEGER AS ult_km,
				    MAX(COALESCE(k.veic_hr,0))::INTEGER AS ult_hr
			    FROM 	frt_veic_km k
				    LEFT JOIN cur_veic USING (placa_veiculo)
			    WHERE   cur_veic.placa_veiculo IS NOT NULL
			    GROUP BY k.placa_veiculo 
			    )

			    ,cur_veicmaxkm AS (
			    -- Compara o KM/HR atual do veiculo com o do Histórico 
			    -- e traz o maior.
			    SELECT 	v.placa_veiculo,
				    CASE WHEN k.ult_km IS NOT NULL 
					  AND k.ult_km > v.odometro_atual 
					 THEN k.ult_km 
					 ELSE v.odometro_atual 
					 END::INTEGER AS ult_km,
				    CASE WHEN k.ult_hr IS NOT NULL 
					  AND k.ult_hr > v.horimetro_atual 
					 THEN k.ult_hr 
					 ELSE v.horimetro_atual 
					 END::INTEGER AS ult_hr
			    FROM 	cur_veic v
				    LEFT JOIN cur_maxkm k USING(placa_veiculo)
			    )

			    ,cur_tmp1 AS (
			    -- Calcula os dias que faltam e os km que faltam 
			    -- para executar a manutencao, bem como a media 
			    -- de km/dia desde a ultima manutencao
			    select 	a.id_pmveic,
				    (a.pmveic_proxdia - current_date)::INTEGER as dias_faltam, 
				    (CURRENT_DATE - a.pmveic_ult_dia)::INTEGER AS dias_passou,

				    (a.pmveic_proxkm - v.ult_km )::INTEGER as km_faltam, 
				    (v.ult_km - a.pmveic_ult_km )::INTEGER AS km_rodado, 

				    (a.pmveic_proxhr - v.ult_hr )::INTEGER as hr_faltam, 
				    (v.ult_hr - a.pmveic_ult_hr )::INTEGER AS hr_trabal, 

				    CASE WHEN ( current_date - a.pmveic_ult_dia)::INTEGER > 0 
					  AND ( v.ult_km - a.pmveic_ult_km) > 0 
					 -- houve km e dias desde a ultima manutencao
					 -- divide km_rodado/dias_passou
					 THEN ((v.ult_km - a.pmveic_ult_km) / (current_date - a.pmveic_ult_dia)) 
					 WHEN (v.ult_km - a.pmveic_ult_km) > 0 
					 -- houve so km desde a ultima manutencao
					 -- pode estar calculando no proprio dia da 
					 -- ultima manutencao entao media = km_rodado
					 THEN (v.ult_km - a.pmveic_ult_km)
					 ELSE 0 -- nao houve km
					 END::INTEGER as media_dia_km, 

				    CASE WHEN ( current_date - a.pmveic_ult_dia)::INTEGER > 0 
					  AND ( v.ult_hr - a.pmveic_ult_hr) > 0 
					 -- houve hr e dias desde a ultima manutencao
					 -- divide hr_trabal/dias_passou
					 THEN ((v.ult_hr - a.pmveic_ult_hr) / (current_date - a.pmveic_ult_dia)) 
					 WHEN (v.ult_hr - a.pmveic_ult_hr) > 0 
					 -- houve so hr desde a ultima manutencao
					 -- pode estar calculando no proprio dia da 
					 -- ultima manutencao entao media = hr_trabal
					 THEN (v.ult_hr - a.pmveic_ult_hr)
					 ELSE 0 -- nao houve km
					 END::INTEGER as media_dia_hr 

			    from 	frt_pmveic a 
				    left join cur_veicmaxkm v USING(placa_veiculo) 
			    WHERE 	1=1 
			    --AND a.id_pmveic = 17420
			    AND     a.pmveic_ativo = 1
			    AND     v.placa_veiculo IS NOT NULL
			    )

			    ,
			    cur_tmp2 AS (
			    -- Calcula, com base na media de km/dia, quantos 
			    -- dias faltam para atingir o limite de km que foi
			    -- estipulado no item.
			    SELECT 	id_pmveic,

				    media_dia_km::INTEGER, -- km_rodados / dia
				    media_dia_hr::INTEGER, -- horas trabalhadas / dia

				    dias_faltam::INTEGER, -- dias ate proximo agendamento
				    dias_passou::INTEGER, -- dias desde ultima manutencao

				    km_faltam::INTEGER, -- km para rodar ate atingir km limite
				    -- Se km_faltam for negativo, já atingiu o km limite
				    km_rodado::INTEGER,

				    hr_faltam::INTEGER, -- hr para trabalhar ate atingir hr limite
				    -- Se hr_faltam for negativo, já atingiu o hr limite
				    hr_trabal::INTEGER,

				    CASE WHEN media_dia_km  =  0
					 -- nao houve km desde a ultima manutencao
					 THEN dias_faltam::INTEGER

					 WHEN km_faltam  >  0
					  AND media_dia_km  >  0
					 -- houve km e ainda nao atingiu o limite
					 -- entao km que falta / media
					 THEN (km_faltam / media_dia_km)::INTEGER

					 WHEN km_faltam <=  0
					  AND media_dia_km  >  0
					 -- houve km e ja atingiu ou passou o limite 
					 -- entao km que falta / media (vai dar dias negativos)
					 THEN (km_faltam / media_dia_km)::INTEGER

					 ELSE 0 

					 END::INTEGER AS kmdias_faltam, 

				    CASE WHEN media_dia_hr  =  0
					 -- nao houve hr desde a ultima manutencao
					 THEN dias_faltam::INTEGER

					 WHEN hr_faltam  >  0
					  AND media_dia_hr  >  0
					 -- houve hr e ainda nao atingiu o limite
					 -- entao hr que falta / media
					 THEN (hr_faltam / media_dia_hr)::INTEGER

					 WHEN hr_faltam <=  0
					  AND media_dia_hr  >  0
					 -- houve hr e ja atingiu ou passou o limite 
					 -- entao hr que falta / media (vai dar dias negativos)
					 THEN (hr_faltam / media_dia_hr)::INTEGER

					 ELSE 0 

					 END::INTEGER AS hrdias_faltam 

			    FROM 	cur_tmp1
			    )

			    ,cur_tmp3_km AS (
			    -- Define, no momento, o que ocorrera primeiro, se 
			    -- a data agendada (dias_faltam) ou os km agendados 
			    -- (kmdias_faltam) convertendo o menor na proxima 
			    -- data para a manutencao.
			    SELECT 	
					id_pmveic,
					km_faltam,
				    CASE WHEN kmdias_faltam > 0 
					  AND kmdias_faltam < dias_faltam 
					 -- proxima data baseada na media dos km
					 THEN current_date 	+ kmdias_faltam

					 WHEN kmdias_faltam > 0
					  AND kmdias_faltam > dias_faltam 
					 -- proxima data baseada na agenda
					 THEN current_date 	+ dias_faltam

					 WHEN kmdias_faltam < 0
					 -- km ja passou do limite entao 
					 -- reduz data para data anterior a atual
					 -- * kmdias_faltam está negativo por isso soma
					 THEN current_date 	+ kmdias_faltam

					 WHEN dias_faltam   > 0 
					 -- se chegou aqui, prevalesce a proxima data agendada
					 THEN current_date 	+ dias_faltam

					 ELSE null 

					 END::DATE AS proxima_data ,

				    -- Aqui foi acrescentado o descritivo do status da análise
				    -- para indicar ao operador eventuais mudanças no agendamento
				    CASE WHEN kmdias_faltam > 0 
					  AND kmdias_faltam < dias_faltam 
					 -- proxima data baseada na media dos km
					 THEN 'Validade reduzida pela media de KM'

					 WHEN kmdias_faltam > 0
					  AND kmdias_faltam > dias_faltam 
					 -- proxima data baseada na agenda
					 THEN 'Agenda Normal'

					 WHEN kmdias_faltam < 0
					 -- km ja passou do limite entao 
					 -- reduz data para data anterior a atual
					 THEN 'Validade reduzida por KM excedido'

					 WHEN dias_faltam   > 0 
					 -- se chegou aqui, prevalesce a proxima data agendada
					 THEN 'Agenda Normal'

					 ELSE 'Agenda Normal' 

					 END::TEXT AS observs 
			    FROM 	cur_tmp2 
			    )

			    ,cur_tmp3_hr AS (
			    -- Define, no momento, o que ocorrera primeiro, se 
			    -- a data agendada (dias_faltam) ou as horas agendadas 
			    -- (hrdias_faltam) convertendo a menor na proxima 
			    -- data para a manutencao.
			    SELECT 	
					id_pmveic,
					hr_faltam,
				    CASE WHEN hrdias_faltam > 0 
					  AND hrdias_faltam < dias_faltam 
					 -- proxima data baseada na media das horas
					 THEN current_date 	+ hrdias_faltam

					 WHEN hrdias_faltam > 0
					  AND hrdias_faltam > dias_faltam 
					 -- proxima data baseada na agenda
					 THEN current_date 	+ dias_faltam

					 WHEN hrdias_faltam < 0
					 -- hr ja passou do limite entao 
					 -- reduz data para data anterior a atual
					 -- * hrdias_faltam está negativo por isso soma
					 THEN current_date 	+ hrdias_faltam

					 WHEN dias_faltam   > 0 
					 -- se chegou aqui, prevalesce a proxima data agendada
					 THEN current_date 	+ dias_faltam

					 ELSE null 

					 END::DATE AS proxima_data ,

				    -- Aqui foi acrescentado o descritivo do status da análise
				    -- para indicar ao operador eventuais mudanças no agendamento
				    CASE WHEN hrdias_faltam > 0 
					  AND hrdias_faltam < dias_faltam 
					 -- proxima data baseada na media das horas
					 THEN 'Validade reduzida pela media de HORAS'

					 WHEN hrdias_faltam > 0
					  AND hrdias_faltam > dias_faltam 
					 -- proxima data baseada na agenda
					 THEN 'Agenda Normal'

					 WHEN hrdias_faltam < 0
					 -- hr ja passou do limite entao 
					 -- reduz data para data anterior a atual
					 THEN 'Validade reduzida por HORAS excedidas'

					 WHEN dias_faltam   > 0 
					 -- se chegou aqui, prevalesce a proxima data agendada
					 THEN 'Agenda Normal'

					 ELSE 'Agenda Normal' 

					 END::TEXT AS observs 
			    FROM 	cur_tmp2 
			    )
			    
			SELECT 	
				id_pmveic,
				'KM'::text as tipo,
				(COALESCE(proxima_data::CHAR(10), '1901-01-01'::CHAR(10))::CHAR(10) || '*' || 
				     COALESCE(observs, 'Agenda Normal')::CHAR(50) || '$' || 
				     COALESCE(km_faltam::INTEGER,0::INTEGER)::CHAR(12))::TEXT AS retorno
			from    
				cur_tmp3_km
			UNION ALL      

			SELECT 	
				id_pmveic,
				'HR'::text as tipo,
				(COALESCE(proxima_data::CHAR(10), '1901-01-01'::CHAR(10))::CHAR(10) || '*' || 
					 COALESCE(observs, 'Agenda Normal')::CHAR(50) || '$' || 
					 COALESCE(hr_faltam::INTEGER,0::INTEGER)::CHAR(12))::TEXT AS retorno
			from    
				cur_tmp3_hr
		)
	,cur_man AS (	
	SELECT 
		DISTINCT ON (v.placa_veiculo, a.id_pmveic) v.placa_veiculo,
		v.id_veiculo,
		v.chk_km,
		a.id_pmveic,
		CASE
		    WHEN v.chk_km = 1 THEN km.retorno
		    ELSE hr.retorno
		END AS obs_manut
	FROM 
		
		veiculos v
		LEFT JOIN frt_pmveic a
			ON v.placa_veiculo = a.placa_veiculo
		LEFT JOIN prox_manut km
			ON km.id_pmveic = a.id_pmveic AND km.tipo = 'KM'
		LEFT JOIN prox_manut hr
			ON hr.id_pmveic = a.id_pmveic AND hr.tipo = 'HR'
			
-- 		(SELECT veiculos.placa_veiculo,
--				veiculos.chk_km,
-- 				veiculos.id_veiculo
--				FROM veiculos
--				WHERE veiculos.ativo = 1 AND veiculos.bloqueado <> 1) v 
-- 		USING (placa_veiculo)
	WHERE 
		a.pmveic_ativo = 1 
		AND v.placa_veiculo IS NOT NULL
        )
        , cur_posicao AS (
         SELECT DISTINCT v.id_veiculo,
            v.obs_manut,
            "position"(v.obs_manut, '$'::text) AS pos_kmhr
           FROM cur_man v
        ), 
        tmp_alertas AS (
         SELECT 
		fornecedores.mot_validade AS data_vencto,
		'DOC. MOTORISTA'::character(25) AS tipo_alerta,
		'CNH'::character(60) AS descr_doc,
		COALESCE(fornecedores.mot_registro, ''::character varying)::character(40) AS numero_doc,
		(('MOTORISTA: '::text || btrim(COALESCE(fornecedores.nome_razao, ''::character varying)::text)))::character(200) AS descr_alerta,
		fornecedores.id_fornecedor AS id_alerta,
		''::character(50) AS obs_alerta,
		0 AS km_faltam,
		0 AS hr_faltam
	FROM 
		fornecedores
	WHERE 
		fornecedores.tipo_motorista = 1 
		AND 
		fornecedores.mot_validade IS NOT NULL
		AND fornecedores.mot_validade IS NOT NULL 
		AND fornecedores.mot_validade >= '1901-01-01'::date
        UNION
        SELECT 
		fornecedores.mot_validade_averbacao AS data_vencto,
		'DOC. MOTORISTA'::character(25) AS tipo_alerta,
		'AVERBACAO'::character(60) AS descr_doc,
		COALESCE(fornecedores.mot_averbacao, ''::character varying)::character(40) AS numero_doc,
		(('MOTORISTA: '::text || btrim(fornecedores.nome_razao::text)))::character(200) AS descr_alerta,
		fornecedores.id_fornecedor AS id_alerta,
		''::character(50) AS obs_alerta,
		0 AS km_faltam,
		0 AS hr_faltam
	FROM 
		fornecedores
	WHERE 
		fornecedores.tipo_motorista = 1 
		AND fornecedores.mot_validade_averbacao IS NOT NULL
		AND fornecedores.mot_validade_averbacao >= '1901-01-01'::date

        UNION
	SELECT fornecedores.mot_seg_validade AS data_vencto,
		'DOC. MOTORISTA'::character(25) AS tipo_alerta,
		'CARTAO SEGURADORA'::character(60) AS descr_doc,
		COALESCE(fornecedores.mot_seg_cartao, ''::character varying)::character(40) AS numero_doc,
		(('MOTORISTA: '::text || btrim(fornecedores.nome_razao::text)))::character(200) AS descr_alerta,
		fornecedores.id_fornecedor AS id_alerta,
		''::character(50) AS obs_alerta,
		0 AS km_faltam,
		0 AS hr_faltam
	FROM 
		fornecedores
	WHERE 
		fornecedores.tipo_motorista = 1 
		AND fornecedores.mot_seg_validade IS NOT NULL
		AND fornecedores.mot_seg_validade >= '1901-01-01'::date
        UNION
	SELECT 
		v.validade_rntrc AS data_vencto,
		'DOC. VEICULO'::character(25) AS tipo_alerta,
		'RNTRC'::character(60) AS descr_doc,
		COALESCE(v.rntrc, ''::bpchar)::character(40) AS numero_doc,
		(((((((('PLACA: '::text || btrim(v.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
		v.id_veiculo AS id_alerta,
		''::character(50) AS obs_alerta,
		0 AS km_faltam,
		0 AS hr_faltam
	FROM 
		v_veiculos v
	WHERE 
		v.validade_rntrc IS NOT NULL 
		AND v.validade_rntrc >= '1901-01-01'::date
		AND v.ativo = 1 
		AND v.bloqueado <> 1
		
        UNION
	SELECT 
		v_tb_categ_doc.doc_validade AS data_vencto,
		'DOC. VEICULO'::character(25) AS tipo_alerta,
		COALESCE(v_tb_categ_doc.doc_sigla, ''::bpchar)::character(60) AS descr_doc,
		COALESCE(v_tb_categ_doc.doc_numero, ''::bpchar)::character(40) AS numero_doc,
		(((((((('PLACA: '::text || btrim(v_tb_categ_doc.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
		v_tb_categ_doc.id_veiculo AS id_alerta,
		''::character(50) AS obs_alerta,
		0 AS km_faltam,
		0 AS hr_faltam
	FROM 
		v_tb_categ_doc
		LEFT JOIN v_veiculos v USING (id_veiculo)
	WHERE 
		v_tb_categ_doc.doc_validade IS NOT NULL 
		AND v_tb_categ_doc.doc_validade >= '1901-01-01'::date
		AND v.id_veiculo IS NOT NULL 
		AND v.ativo = 1 
		AND v.bloqueado <> 1		
        UNION
        SELECT 
		"left"(m.obs_manut, 10)::date AS data_vencto,
		'MANUTENCAO'::character(25) AS tipo_alerta,
		COALESCE(p.descr_item, ''::bpchar)::character(60) AS descr_doc,
		(('FROTA '::text || btrim(COALESCE(v.numero_frota, ''::bpchar)::text)))::character(40) AS numero_doc,
		(((((((('PLACA: '::text || btrim(a.placa_veiculo::text)) || ' - '::text) || btrim(v.nome_marca::text)) || ' - '::text) || btrim(v.descricao_modelo::text)) || ' - '::text) || btrim(v.cor_veiculo::text)))::character(200) AS descr_alerta,
		a.id_veiculo AS id_alerta,
		"substring"(m.obs_manut, 12, s.pos_kmhr - 12)::character(50) AS obs_alerta,
		CASE
		    WHEN v.chk_km = 1 THEN "substring"(m.obs_manut, s.pos_kmhr + 1, 12)::integer
		    ELSE 0
		END AS km_faltam,
		CASE
		    WHEN v.chk_hr = 1 THEN "substring"(m.obs_manut, s.pos_kmhr + 1, 12)::integer
		    ELSE 0
		END AS hr_faltam
	FROM 
		frt_pmveic a
		LEFT JOIN cur_man m USING (placa_veiculo)
		LEFT JOIN cur_posicao s 
			ON m.id_veiculo = s.id_veiculo AND m.obs_manut = s.obs_manut
		LEFT JOIN v_veiculos v USING (placa_veiculo)
		LEFT JOIN frt_pmit i USING (id_pmit)
		LEFT JOIN v_produtos p 
			ON i.pmit_id_origem = p.id_produto
		WHERE 
			1 = 1 
			AND a.pmveic_ativo = 1 
			AND m.placa_veiculo IS NOT NULL 
			AND s.id_veiculo IS NOT NULL 
			AND v.placa_veiculo IS NOT NULL 
			AND v.ativo = 1 
			AND v.bloqueado <> 1 
			AND p.id_produto IS NOT NULL
	ORDER BY data_vencto
        ), 
        tbl_alertas AS (
	SELECT 
		tmp_alertas.data_vencto,
		tmp_alertas.tipo_alerta,
		tmp_alertas.descr_doc,
		tmp_alertas.numero_doc,
		tmp_alertas.descr_alerta,
		tmp_alertas.id_alerta,
		tmp_alertas.data_vencto - now()::date AS faltam_dias,
		tmp_alertas.obs_alerta,
		tmp_alertas.km_faltam,
		tmp_alertas.hr_faltam
	FROM 
		tmp_alertas

        )
 SELECT tbl_alertas.data_vencto,
    tbl_alertas.tipo_alerta,
    tbl_alertas.descr_doc,
    tbl_alertas.numero_doc,
    tbl_alertas.descr_alerta,
    tbl_alertas.faltam_dias,
    tbl_alertas.obs_alerta,
        CASE
            WHEN tbl_alertas.faltam_dias < 0 THEN 1
            WHEN tbl_alertas.faltam_dias >= 0 AND tbl_alertas.faltam_dias <= (6 - date_part('dow'::text, now()::date)::integer) THEN 2
            WHEN tbl_alertas.faltam_dias > (6 - date_part('dow'::text, now()::date)::integer) AND tbl_alertas.faltam_dias <= date_part('days'::text, date_trunc('month'::text, now()::date::timestamp with time zone) + '1 mon'::interval - '1 day'::interval - now()::date::timestamp with time zone)::integer THEN 3
            WHEN tbl_alertas.faltam_dias > date_part('days'::text, date_trunc('month'::text, now()::date::timestamp with time zone) + '1 mon'::interval - '1 day'::interval - now()::date::timestamp with time zone)::integer THEN 4
            ELSE NULL::integer
        END AS situacao,
    tbl_alertas.id_alerta,
        CASE tbl_alertas.tipo_alerta
            WHEN 'DOC. MOTORISTA'::bpchar THEN ('DO FORM ("fornecedor_v01.scx") WITH "fornecedores", "id_fornecedor", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("fornecedor_v01")'::text
            WHEN 'DOC. VEICULO'::bpchar THEN ('DO FORM ("veiculos_frotista.scx") WITH "veiculos", "id_veiculo", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("veiculos_frotista")'::text
            WHEN 'MANUTENCAO'::bpchar THEN ('DO FORM ("veiculos_frotista.scx") WITH "veiculos", "id_veiculo", '::text || btrim(tbl_alertas.id_alerta::text)) || ', "EDITAR", thisform.Name NAME ("veiculos_frotista")'::text
            ELSE ''::text
        END AS do_form,
    tbl_alertas.km_faltam,
    tbl_alertas.hr_faltam
   FROM tbl_alertas;

--SELECT * FROM tmp_alertas