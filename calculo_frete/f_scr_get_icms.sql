-- Function: public.f_scr_get_icms(json, refcursor, refcursor, refcursor)
/*


SELECT id_conhecimento FROM scr_conhecimento WHERE id_conhecimento_principal = 4289583

SELECT string_agg(id_nota_fiscal_imp::text, ',') FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = 4289853
SELECT cnpj_cpf FROM cliente WHERE codigo_cliente = 16714
UPDATE scr_conhecimento SET cancelado = 1, data_cancelamento = now() WHERE id_conhecimento = 4289853

SELECT id_conhecimento, data_digitacao FROM scr_conhecimento ORDER BY 1 DESC LIMIT 100
DELETE 
DELETE FROM scr_conhecimento WHERE id_conhecimento >= 4367187
 FROM scr_notas_fiscais_imp
 WHERE id_nota_fiscal_imp IN (5995020,5995027,5995033,5995037,5995042,5995046,5995048,5995050,5995051)

 UPDATE scr_

5996803
SELECT * FROM scr_tipo_imposto
*/
-- DROP FUNCTION public.f_scr_get_icms(json, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_scr_get_icms(
    dados json,
    cimpostocf refcursor,
    cimposto refcursor,
    msg_imposto refcursor)
  RETURNS SETOF refcursor AS
$BODY$
 DECLARE
	--Variaveis para receber valores do dados json
 	valor_operacao 		numeric(12,2);
 	aliquota       		numeric(5,2);
 	aliquota_icms_st	numeric(5,2);
 	aliquota_inter 		numeric(5,2);
 	aliquota_intra 		numeric(5,2);
 	aliquota_fcp		numeric(5,2);
 	percentual_desconto	numeric(5,2);
 	percentual_cred_st	numeric(5,2);
 	tipo_imposto		numeric(5,2);
 	imposto_incluso		integer;
 	calculo_difal		integer;
 	perc_difal_dest		numeric(5,2); 	
 	remetente_cnpj		text;
 	 	
	--Variaveis de Calculo
  	cursor			refcursor; 	
	retorno	 		json; 	
	cf_frete		numeric(12,2);
  	aliq			numeric(12,2);
 	base_calculo 		numeric(12,2);
 	base_calculo_st		numeric(12,2);
	imposto 		numeric(12,2);
	icms_st			numeric(12,2);
 	
 	id_conhecimento_cf 	integer;
 	valor_credito_st	numeric(12,2); 	
 	difal			numeric(12,2);
 	difal_origem		numeric(12,2);
 	difal_destino		numeric(12,2);
 	fcp			numeric(12,2);
 	

	bc_destino		numeric(12,2);
	bc_origem		numeric(12,2);
	icms_destino		numeric(12,2);
	icms_origem		numeric(12,2); 	 	

	v_padrao_sistema 	integer;
	v_isenta 		integer;
 	
 BEGIN	





	WITH ent AS (
		SELECT '{
			"valor_operacao" : 1000.00,
			"aliquota" : 0.00,
			"aliquota_icms_st" : 12.00,
			"aliq_icms_inter" : 0.00,
			"aliq_icms_interna" : 18.00,
			"aliquota_fcp" : 0.00,
			"perc_base_calculo" : 0.00,
			"perc_cred_st" : 0.00,
			"tipo_imposto" : 9,
			"imposto_incluso" : 2,
			"calculo_difal": 0,
			"remetente_cnpj":null
		}'::json as j
	)
	SELECT 
		x.valor_operacao,
		x.aliquota,
		x.aliquota_icms_st,		
		x.aliq_icms_inter,
		x.aliq_icms_interna,
		x.aliquota_fcp,
		x.perc_base_calculo,
		x.perc_cred_st,
		x.tipo_imposto,
		x.imposto_incluso,
		x.calculo_difal,
		x.remetente_cnpj
	INTO 
		valor_operacao,
		aliquota,
		aliquota_icms_st,
		aliquota_inter,
		aliquota_intra,
		aliquota_fcp,
		percentual_desconto,
		percentual_cred_st,
		tipo_imposto,
		imposto_incluso,
		calculo_difal,
		remetente_cnpj	
	FROM
		ent,
		json_to_record(COALESCE(dados, j))
		as x (
			valor_operacao 		numeric(12,2),
			aliquota		numeric(5,2),
			aliquota_icms_st	numeric(5,2),
			aliq_icms_inter		numeric(5,2),
			aliq_icms_interna	numeric(5,2),
			aliquota_fcp		numeric(5,2),
			perc_base_calculo	numeric(5,2),
			perc_cred_st		numeric(5,2),
			tipo_imposto		integer,
			imposto_incluso		integer,
			calculo_difal		integer,
			remetente_cnpj		text
		);
	
	-- Implementacoes em 04/02/2016 --
	-- Para atender instruções do CONVENIO ICMS 93-2015 
	-- Calculo do Diferencial de Aliquotas para não contribuinte em outro estado
	-- Calculo do Fundo de Combate a Pobreza

	-- Inicializa as variaveis de calculo	
	base_calculo 	= 0.00;
	imposto		= 0.00;
	bc_origem	= 0.00;
	icms_origem	= 0.00;
	bc_destino	= 0.00;
	icms_destino	= 0.00;
	fcp		= 0.00;

	SELECT padrao_sistema, isento INTO v_padrao_sistema, v_isenta FROM scr_tipo_imposto WHERE scr_tipo_imposto.tipo_imposto = tipo_imposto;
	-- Nao calcula se tipo de imposto for isento
	IF v_isenta = 0 THEN 		

		IF padrao_sistema = 0 THEN
			aliq = aliquota_icms_st;
		ELSE
			aliq = aliquota;
		END IF;	
		
		
		WITH 
			frete_sem_imposto AS (
				SELECT 
					1::integer as id,
					valor_operacao::numeric(12,2) as total_frete_sem_imposto
				
			),
			base_calculo_aux AS (
				SELECT 
					id,
					total_frete_sem_imposto,
					CASE 	WHEN percentual_desconto > 0 --v_perc_desconto > 0 
							THEN total_frete_sem_imposto - ((total_frete_sem_imposto * percentual_desconto/100)) 
							ELSE total_frete_sem_imposto
						END::numeric(12,5) as base_calculo_aux
					FROM
						frete_sem_imposto 
			),
			frete_com_imposto AS (
				SELECT 
					base_calculo_aux.id,
					base_calculo_aux.total_frete_sem_imposto,
					base_calculo_aux,							
					CASE 	WHEN  imposto_incluso = 1 --imposto_incluso = 1
						THEN (base_calculo_aux + ((base_calculo_aux * aliq)/100))
						ELSE base_calculo_aux / ((100-aliq)/100) 
					END::numeric(12,5) as base_calculo_,
					CASE 	WHEN  imposto_incluso = 1 --imposto_incluso = 1
						THEN (base_calculo_aux + ((base_calculo_aux * aliquota_inter)/100))
						ELSE base_calculo_aux / ((100-aliquota_inter)/100) 
					END::numeric(12,5) as base_calculo_inter,
					CASE 	WHEN  imposto_incluso = 1 --imposto_incluso = 1
						THEN (base_calculo_aux + ((base_calculo_aux * (aliquota_intra + aliquota_fcp))/100))
						ELSE base_calculo_aux / ((100-aliquota_intra - aliquota_fcp)/100) 
					END::numeric(12,5) as base_calculo_difal					
				FROM 	
					base_calculo_aux
					
			)			
			SELECT 				
				CASE WHEN imposto_incluso = 1 THEN 
					base_calculo_aux 
				ELSE 
					base_calculo_ 
				END::numeric(12,2), --Base Calculo
				
				CASE WHEN imposto_incluso = 1 THEN 
					(base_calculo_aux * aliq)/100 
				ELSE 
					(base_calculo_ * aliq)/100 
				END::numeric(12,2), -- imposto
				
				CASE WHEN imposto_incluso = 1 THEN 
					base_calculo_aux 
				ELSE 
					base_calculo_difal 
				END::numeric(12,2), -- bc_origem
				
				CASE WHEN imposto_incluso = 1 THEN 
					(base_calculo_aux * aliquota_inter)/100 
				ELSE 
					(base_calculo_difal * aliquota_inter)/100 
				END::numeric(12,2), -- icms_origem
				
				CASE WHEN imposto_incluso = 1 THEN 
					base_calculo_aux 
				ELSE 
					base_calculo_difal 
				END::numeric(12,2), --bc_destino
				
				CASE WHEN imposto_incluso = 1 THEN 
					(base_calculo_aux * aliquota_intra)/100 
				ELSE 
					(base_calculo_difal * aliquota_intra)/100 
				END::numeric(12,2), -- icms_destino								
				
				CASE WHEN imposto_incluso = 1 THEN 
					(base_calculo_aux * aliquota_fcp)/100 
				ELSE 
					(base_calculo_difal * aliquota_fcp)/100 
				END::numeric(12,2) -- fcp
			
			INTO 
				base_calculo,
				imposto,
				bc_origem,
				icms_origem,
				bc_destino,
				icms_destino,
				fcp
			FROM 
				frete_com_imposto;
	END IF;

	--Calcula o imposto devido pelo Diferencial de Alíquotas
	IF calculo_difal = 1 THEN 
		perc_difal_dest = f_get_perc_difal(extract(year from current_date)::integer);
		difal 		= icms_destino - icms_origem;
		difal_origem 	= difal * ((100 - perc_difal_dest)/100);
		difal_destino 	= difal * (perc_difal_dest/100);
		
	ELSE
		bc_origem 	= 0.00;
		bc_destino	= 0.00;
		icms_origem	= 0.00;
		icms_destino	= 0.00;
		perc_difal_dest = 0.00;
		difal 		= 0.00;
		difal_origem 	= 0.00;
		difal_destino 	= 0.00;
		fcp		= 0.00;
	END IF;

	--Se for simples, base de calculo igual a zero.
	IF tipo_imposto = 11 THEN 
		base_calculo = 0.00;
		imposto	     = 0.00;		
	END IF;
	
	--Verifica se tem percentual de desconto de credito outorgado.
	IF percentual_cred_st > 0.00 THEN 
		valor_credito_st = (base_calculo * aliquota * (percentual_cred_st/100))/100;
	ELSE
		valor_credito_st = 0.00;
	END IF;
	
	OPEN cImpostoCf FOR 
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1000::integer as id_tipo_calculo,
		'ICMS'::character(50) as descricao,
		0::integer as excedente,
		base_calculo::numeric(12,5) as quantidade,
		(CASE WHEN base_calculo = 0.00 THEN 0.00 ELSE aliq/100 END)::numeric(12,6) as valor_item,
		imposto::numeric(12,2) as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		imposto::numeric(12,2) as valor_pagar,			
		(CASE WHEN imposto_incluso = 1 THEN 'I' ELSE 'C' END)::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
	WHERE
		calculo_difal = 0 OR tipo_imposto IN (2,11)
	UNION
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1000::integer as id_tipo_calculo,
		'ICMS'::character(50) as descricao,
		0::integer as excedente,
		bc_origem::numeric(12,5) as quantidade,
		(CASE WHEN bc_origem = 0.00 THEN 0.00 ELSE aliquota_inter/100 END)::numeric(12,6) as valor_item,
		icms_origem::numeric(12,2) as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		icms_origem::numeric(12,2) as valor_pagar,			
		(CASE WHEN imposto_incluso = 1 THEN 'I' ELSE 'C' END)::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
	WHERE
		--Se for simples, não destaca icms
		calculo_difal = 1 
		AND tipo_imposto NOT IN (2,11)
	UNION
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1002::integer as id_tipo_calculo,
		'Difal Origem'::character(50) as descricao,
		0::integer as excedente,
		1::numeric(12,5) as quantidade,
		difal_origem::numeric(12,6) as valor_item,
		difal_origem as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		difal_origem as valor_pagar,			
		(CASE WHEN imposto_incluso = 1 THEN 'I' ELSE 'C' END)::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
	WHERE
		calculo_difal = 1
		AND tipo_imposto NOT IN (2)
	UNION 
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1003::integer as id_tipo_calculo,
		'Difal Destino'::character(50) as descricao,
		0::integer as excedente,
		1::numeric(12,5) as quantidade,
		difal_destino::numeric(12,6) as valor_item,
		difal_destino as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		difal_destino as valor_pagar,
		(CASE WHEN imposto_incluso = 1 THEN 'I' ELSE 'C' END)::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
	WHERE 
		calculo_difal = 1
		AND tipo_imposto NOT IN (2)
	UNION 
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1004::integer as id_tipo_calculo,
		'FCP'::character(50) as descricao,
		0::integer as excedente,
		1::numeric(12,5) as quantidade,
		fcp::numeric(12,6) as valor_item,
		fcp as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		fcp as valor_pagar,			
		(CASE WHEN imposto_incluso = 1 THEN 'I' ELSE 'C' END)::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
		
	WHERE 
		calculo_difal = 1
		AND tipo_imposto NOT IN (2)
	UNION
	SELECT 
		NULL::integer as id_cf,
		NULL::integer as id,
		1001::integer as id_tipo_calculo,
		'Crédito de ICMS ST'::character(50) as descricao,
		0::integer as excedente,
		(base_calculo * aliquota)::numeric(12,5) as quantidade,
		(percentual_cred_st/100)::numeric(12,6) as valor_item,
		valor_credito_st::numeric(12,2) as valor_total,
		0.00::numeric(12,2) as valor_minimo,
		valor_credito_st::numeric(12,2) as valor_pagar,			
		'C'::character(1) as operacao,
		1::integer as id_faixa,
		0::integer as combinado,
		1::integer as modo_calculo,
		0.00::numeric(5,2) as perc_desconto,
		0.00::numeric(12,2) as valor_pagar_sdesconto,
		0.00::numeric(12,2) as desconto
	WHERE
		percentual_cred_st > 0
		AND tipo_imposto NOT IN (2)
	ORDER BY
		id_tipo_calculo;
		
	

	RETURN NEXT cImposto;

	--Calculo do Imposto Consolidado
	
	--Quando tem difal utiliza os calculos do icms na origem
	-- A não ser que seja simples	
	IF calculo_difal = 1 AND tipo_imposto <> 11 THEN 		
		base_calculo 		= bc_origem;		
		imposto 		= icms_origem;		
	END IF;

	CASE WHEN 
	--Define se o imposto faz parte do valor cobrado do frete
	--Se for substituição Tributária, valor do imposto não integra montante do frete
	--Se 
	IF 
		imposto_incluso = 2 
		AND (
			(tipo_imposto NOT IN (6,7,8) )
			OR (tipo_imposto = 9 AND LEFT(remetente_cnpj,8) <> '33337122')  --Caso Especial (Generalizar em regra)
		)
	THEN
		cf_frete = 	COALESCE(imposto,0)
				+ COALESCE(difal_origem,0) 
				+ COALESCE(difal_destino,0)
				+ COALESCE(fcp,0);
	ELSE
		cf_frete = 0.00;
	END IF;

	
	base_calculo_st = 0.00;
	icms_st		= 0.00;
	
	--Para os impostos que não são de tributação normal 
	--Destaca em campos separados
	IF tipo_imposto IN (6,7,8,9,10) THEN 
		base_calculo_st = base_calculo;
		icms_st		= imposto;
		base_calculo	= 0.00;		
		imposto 	= 0.00;		
	END IF;
	
	
		
	OPEN cImposto FOR
	SELECT 	
		null::integer as id,
		base_calculo,
		imposto,
		base_calculo_st::numeric(12,2) as base_calculo_st_reduzida,
		icms_st,		
		bc_origem as base_calculo_difal, 
		difal_origem as difal_icms_origem,
		difal_destino as difal_icms_destino,
		fcp as valor_fcp,
		cf_frete;
	
		
	
	retorno = '{"msg_imposto":""}'::json;

	OPEN msg_imposto FOR SELECT retorno as msg_imposto;
	
	RETURN NEXT msg_imposto ; 	
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
