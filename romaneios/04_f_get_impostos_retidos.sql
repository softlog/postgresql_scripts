/*
 
SELECT 
	id_ as id,
	tipo_imposto_ as tipo_imposto,
	imposto_ as imposto,
	id_fornecedor_ as id_fornecedor,
	mes_ref_ as mes_ref,
	ano_ref_ as ano_ref,
	data_ref_ as data_ref,
	valor_operacao_ as valor_operacao,
	percentual_base_calculo_ as percentual_base_calculo,
	base_calculo_ as base_calculo,
	aliquota_ as aliquota,
	valor_imposto_ as valor_imposto,
	deducoes_ as deducoes,
	id_ciot_ as id_ciot,
	qt_dependentes_ as qt_dependentes,
	automatico_ as automatico
FROM 	
	f_get_impostos_ciot(5366, 5355, 0, current_date, 40000.00, 2, null, 1)
*/


CREATE OR REPLACE FUNCTION f_get_impostos_retidos(
	p_id_fornecedor integer, 
	p_id_cidade_origem integer, 
	p_operacao_municipal integer, 
	p_data_ref date,
	p_valor_operacao numeric(12,2),
	p_qt_dependentes integer,
	p_valor_acumulado_mes numeric(12,2),
	p_recolhe_inss integer
	
)
  RETURNS TABLE (
	id_ integer,
	tipo_imposto_ integer,
	imposto_ character(20),
	id_fornecedor_ integer,
	mes_ref_ integer,
	ano_ref_ integer,
	data_ref_ date,
	valor_operacao_ numeric(12,2),
	percentual_base_calculo_ numeric(5,2),
	base_calculo_ numeric(12,2),
	aliquota_ numeric(5,2),
	valor_imposto_ numeric(12,2),
	deducoes_ numeric(12,2),
	id_ciot_ integer,
	qt_dependentes_ integer,			
	automatico_ integer 
  )  AS
$BODY$
/*
	p_id_fornecedor: Codigo do autonomo contratado.
	p_id_cidade_origem: Codigo da cidade origem da prestacao do servico.
	p_operacao_municipal: 0 para operacao não municipal, 1 para o inverso.
	p_valor_frete: Valor do frete pago ao autonomo.
	p_qt_dependentes: Quantidade de dependentes para abatimento na base de calculo do irrf.
	p_valor_acumulado_mes: Parametro opcional, caso precise usar uma base de calculo do irrf nao automatica.

	SELECT * FROM imposto_aliquotas
	SELECT * FROM impostos

	
	----------- Base de Calculo IR TAC -------------------
	LEI Nº 7.713, DE 22 DE DEZEMBRO DE 1988.

	Art. 9º Quando o contribuinte auferir rendimentos da prestação de serviços de transporte, em veículo próprio locado, 
	ou adquirido com reservas de domínio ou alienação fiduciária, o imposto de renda incidirá sobre:

	I - 10% (dez por cento) do rendimento bruto, decorrente do transporte de carga;(Redação dada pela lei nº 12.794, de 2013)
	II - sessenta por cento do rendimento bruto, decorrente do transporte de passageiros.

	Parágrafo único. O percentual referido no item I deste artigo aplica-se também sobre o rendimento bruto 
	da prestação de serviços com trator, máquina de terraplenagem, colheitadeira e assemelhados.

	----------- Base de Calculo INSS TAC -------------------
	Instrução Normativa RFB nº 971, de 13 de novembro de 2009

	Art. 55, inciso V, § 2º:

	O salário-de-contribuição do condutor autônomo de veículo rodoviário (inclusive o taxista), 
	do auxiliar de condutor autônomo, do operador de trator, máquina de terraplenagem, colheitadeira e assemelhados, 
	sem vínculo empregatício, do motorista que atua no transporte de passageiros por meio de aplicativo de transporte, 
	e do cooperado filiado a cooperativa de transportadores autônomos, corresponde a 20% (vinte por cento) do valor bruto 
	auferido pelo frete, carreto, transporte, conforme estabelece o § 4º do art. 201 do Decreto nº 3.048, 
	de 6 de maio de 1999 - Regulamento da Previdência Social, observado o limite máximo a que se refere o § 2º do art. 54, 
	vedada a dedução de valores gastos com combustível ou manutenção do veículo, ainda que discriminados no documento correspondente.
	(Redação dada pelo(a) Instrução Normativa RFB nº 1867, de 25 de janeiro de 2019) 	
	
*/
DECLARE
	--v_imposto t_impostos_fornecedor%rowtype;

BEGIN

	
	
	--Calculo do IRRF	
	RETURN QUERY	
	WITH 
	p AS (
		SELECT 
			p_id_fornecedor as id_fornecedor,
			p_id_cidade_origem as id_cidade,
			p_operacao_municipal as operacao_municipal,
			p_data_ref as data_ref,
			p_valor_operacao as valor_operacao,
			p_qt_dependentes as qt_dependentes,
			p_valor_acumulado_mes as valor_acumulado_mes,
			p_recolhe_inss as recolhe_inss
		
	)
-- 	p AS (
-- 		SELECT 
-- 			10::integer as id_fornecedor,
-- 			5505::integer as id_cidade,
-- 			0::integer as operacao_municipal,
-- 			current_date as data_ref,
-- 			00.00::numeric(12,2) as valor_operacao,
-- 			0::integer as qt_dependentes,
-- 			NULL::numeric(12,2) as valor_acumulado_mes,
-- 			0::integer as recolhe_inss
-- 	)
	, impostos AS (
		SELECT 
			id,
			imposto,
			percentual_base_calculo,
			base_calculo_mensal
		FROM 
			impostos
			
	)	
	, datas_vigencia AS (	
		SELECT 
			tipo_imposto,
			MAX(data_vigencia) as data_vigencia
		FROM
			imposto_aliquotas 
		WHERE
			data_vigencia <= current_date
		GROUP BY 
			tipo_imposto
	)
	, inss AS (
		WITH teto_inss AS (
			SELECT 
				MAX(ia.faixa_base_calculo_fim)::numeric(12,2) as faixa_maxima,
				MAX(ia.aliquota)::numeric(12,2) as aliquota,
				MAX(ia.faixa_base_calculo_fim)::numeric(12,2) * 
				  (MAX(ia.aliquota)::numeric(12,2)/100)::numeric(12,2) as valor_maximo
			FROM
				datas_vigencia dv,
				imposto_aliquotas ia
			WHERE 
				
				ia.tipo_imposto = 3
				AND ia.data_vigencia = dv.data_vigencia
			
		)	
		, inss_mes AS (
			SELECT
				p.id_fornecedor,
				(COALESCE(SUM(ifo.valor_imposto),0.00)) as valor_inss_mes,
				(teto_inss.faixa_maxima * (teto_inss.aliquota/100))::numeric(12,2) as valor_maximo,
				teto_inss.faixa_maxima,
				teto_inss.aliquota
			FROM 	
				teto_inss,
				p
				LEFT JOIN impostos_fornecedor ifo				
					ON ifo.id_fornecedor = p.id_fornecedor			
					AND tipo_imposto = 3
					AND mes_ref = extract(month from current_date)::integer
					AND ano_ref = extract(year from current_date)::integer					
			--SELECT * FROM impostos_fornecedor
			GROUP BY
				p.id_fornecedor,
				P.valor_operacao,
				teto_inss.faixa_maxima,
				teto_inss.aliquota

		) 
		, bc AS (
			SELECT 
				p.id_fornecedor,
				(p.valor_operacao * (i.percentual_base_calculo / 100))::numeric(12,2) as base_calculo
			FROM 
				P
				,impostos i
				
			WHERE 
				i.id = 3
		)
		, calculo_inss AS (
			SELECT 
				bc.base_calculo,
				ia.faixa_base_calculo_ini,
				ia.faixa_base_calculo_fim,										
				ia.aliquota,	
				ia.tipo_imposto,							
				CASE 	WHEN bc.base_calculo > im.faixa_maxima 
					THEN im.valor_maximo - im.valor_inss_mes
					ELSE (bc.base_calculo * (ia.aliquota/100))::numeric(12,2) - im.valor_inss_mes
				END::numeric(12,2) as valor_inss
			FROM 
				datas_vigencia dv,
				bc,
				imposto_aliquotas ia,
				p
				LEFT JOIN inss_mes im
					ON im.id_fornecedor = p.id_fornecedor
				
			WHERE
				ia.data_vigencia = dv.data_vigencia
				AND ia.tipo_imposto = 3
				AND dv.tipo_imposto = 3
				AND bc.base_calculo >= ia.faixa_base_calculo_ini
				AND (CASE 
					WHEN ia.faixa_base_calculo_fim = im.faixa_maxima 
					THEN true
					ELSE bc.base_calculo <= ia.faixa_base_calculo_fim
				END)			
				
				
		)
		SELECT 		
			faixa_base_calculo_ini,
			faixa_base_calculo_fim,
			base_calculo,
			aliquota,
			tipo_imposto,
			CASE WHEN p.recolhe_inss = 1 THEN valor_inss ELSE 0.00 END::numeric(12,2) as valor_inss
		FROM 
			p,
			calculo_inss
	) 
	, irrf AS (	 
		
		WITH irrf_frete_mes AS (
			SELECT
				p.id_fornecedor,
				(COALESCE(SUM(ifo.valor_operacao),0.00) + p.valor_operacao) as valor_operacao_mes
			FROM 	
				p
				LEFT JOIN impostos_fornecedor ifo				
					ON ifo.id_fornecedor = p.id_fornecedor			
					AND tipo_imposto = 1
					AND mes_ref = extract(month from current_date)::integer
					AND ano_ref = extract(year from current_date)::integer					
			--SELECT * FROM impostos_fornecedor
			GROUP BY
				p.id_fornecedor,
				P.valor_operacao
				

		)		
		, irrf_preparacao AS (
			SELECT 
				ia.tipo_imposto,
				ia.data_vigencia,
				ia.faixa_base_calculo_ini,
				ia.faixa_base_calculo_fim,
				ia.aliquota,
				ia.parcela_deducao,
				ia.valor_dependente,
				((fm.valor_operacao_mes  * (i.percentual_base_calculo /100)) 
					- inss.valor_inss
					- ia.valor_dependente * p.qt_dependentes
				)::numeric(12,2) as base_calculo_irrf
				
			FROM 
				p,
				inss,					
				irrf_frete_mes fm,					
				datas_vigencia idv,
				imposto_aliquotas ia
				LEFT JOIN impostos i
					ON i.id = ia.tipo_imposto
			WHERE 			
				ia.data_vigencia = idv.data_vigencia					
				AND ia.tipo_imposto = 1
			
		)
		,calculo_irrf AS (
			SELECT 
				ip.*,
				((base_calculo_irrf * (aliquota/100)) - parcela_deducao)::numeric(12,2) as valor_irrf
			FROM 
				irrf_preparacao ip
			WHERE 
				base_calculo_irrf >= faixa_base_calculo_ini
				AND base_calculo_irrf <= faixa_base_calculo_fim

		)
		SELECT * FROM calculo_irrf
	)
	, sest_senat AS (
		WITH  bc AS (
			SELECT 
				p.id_fornecedor,
				(p.valor_operacao * (i.percentual_base_calculo / 100))::numeric(12,2) as base_calculo
			FROM 
				P
				,impostos i				
			WHERE 
				i.id = 4							
		)
		, calculo_sest_senat AS (
			SELECT 
				bc.base_calculo,										
				ia.aliquota,				
				(bc.base_calculo * (ia.aliquota/100))::numeric(12,2) as valor_sest_senat			
			FROM 
				datas_vigencia dv,
				bc,
				imposto_aliquotas ia				
			WHERE
				ia.data_vigencia = dv.data_vigencia				
				AND ia.tipo_imposto = 4		
				AND dv.tipo_imposto = 4
				
				
		)
		SELECT 
			base_calculo,
			aliquota,
			valor_sest_senat
		FROM 
			calculo_sest_senat	
	)
	, iss AS (
		
		WITH calculo_iss AS (
			SELECT 
				p.valor_operacao as base_calculo,										
				ia.aliquota,				
				(p.valor_operacao * (ia.aliquota/100))::numeric(12,2) as valor_iss
			FROM 
				p,
				datas_vigencia dv,				
				imposto_aliquotas ia				
			WHERE
				ia.data_vigencia = dv.data_vigencia				
				AND ia.tipo_imposto = 2
				AND dv.tipo_imposto = 2
				AND ia.id_cidade = p.id_cidade
				
				
		)
		SELECT 
			base_calculo,
			aliquota,
			valor_iss
		FROM 
			calculo_iss	
	)
	SELECT 
		NULL::integer as id,
		impostos.id as tipo_imposto,
		impostos.imposto,
		p.id_fornecedor,
		extract('month' from p.data_ref)::integer as mes_ref,
		extract('year' from p.data_ref)::integer as ano_ref,
		p.data_ref,
		p.valor_operacao,
		impostos.percentual_base_calculo, 
		inss.base_calculo,
		inss.aliquota,
		inss.valor_inss as valor_imposto,
		0.00::numeric(12,2) as deducoes,
		NULL::integer as id_ciot,
		p.qt_dependentes,
		1::integer as automatico
	FROM 
		p,
		impostos,
		inss
	WHERE 
		impostos.id = 3
		AND p.recolhe_inss = 1
	UNION
	SELECT 
		NULL::integer as id,	
		impostos.id as tipo_imposto,	
		impostos.imposto,
		p.id_fornecedor,		
		extract('month' from p.data_ref)::integer as mes_ref,
		extract('year' from p.data_ref)::integer as ano_ref,
		p.data_ref,
		p.valor_operacao,
		impostos.percentual_base_calculo, 
		irrf.base_calculo_irrf as base_calculo,
		irrf.aliquota,
		irrf.valor_irrf as valor_imposto,
		irrf.parcela_deducao::numeric(12,2) as deducoes,
		NULL::integer as id_ciot,
		p.qt_dependentes,
		1::integer as automatico
	FROM 
		p,
		impostos,
		irrf
	WHERE 
		impostos.id = 1
	UNION 
	SELECT 
		NULL::integer as id,		
		impostos.id as tipo_imposto,
		impostos.imposto,	
		p.id_fornecedor,			
		extract('month' from p.data_ref)::integer as mes_ref,
		extract('year' from p.data_ref)::integer as ano_ref,
		p.data_ref,
		p.valor_operacao,
		impostos.percentual_base_calculo, 
		sest_senat.base_calculo,
		sest_senat.aliquota,
		sest_senat.valor_sest_senat as valor_imposto,
		0.00::numeric(12,2) as deducoes,
		NULL::integer as id_ciot,
		p.qt_dependentes,
		1::integer as automatico
	FROM 
		p,
		impostos,
		sest_senat
	WHERE 
		impostos.id = 4
	UNION 
	SELECT 
		NULL::integer as id,		
		impostos.id as tipo_imposto,
		impostos.imposto,		
		p.id_fornecedor,
		extract('month' from p.data_ref)::integer as mes_ref,
		extract('year' from p.data_ref)::integer as ano_ref,
		p.data_ref,
		p.valor_operacao,
		impostos.percentual_base_calculo, 
		iss.base_calculo,
		iss.aliquota,
		iss.valor_iss as valor_imposto,
		0.00::numeric(12,2) as deducoes,
		NULL::integer as id_ciot,
		p.qt_dependentes,
		1::integer as automatico
	FROM 
		p,
		impostos,
		iss
	WHERE 
		impostos.id = 2
		AND p.operacao_municipal = 1
	ORDER BY 
		tipo_imposto;
		

	
	--SELECT * FROM impostos
	
	--SELECT * FROM imposto_aliquotas WHERE tipo_imposto = 3
	--Calculo do INSS

	--Calculo do SEST/SENAT

	--Calculo do ISS	
        
	--RETURN 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


  