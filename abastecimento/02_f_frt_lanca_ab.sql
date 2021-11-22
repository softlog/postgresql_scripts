-- Function: public.f_frt_lanca_ab(character, json)
--SELECT * FROM frt_ab_import LIMIT 10
-- DROP FUNCTION public.f_frt_lanca_ab(character, json);
--TRUNCATE frt_ab
--
CREATE OR REPLACE FUNCTION public.f_frt_lanca_ab(
    p_empresa character,
    dados json)
  RETURNS integer AS
$BODY$
DECLARE
	filial character(3);
BEGIN

        SET datestyle = "ISO, DMY";

	SELECT 	filial.codigo_filial 
	INTO 	filial 
	FROM 	empresa
		LEFT JOIN filial
			ON empresa.codigo_empresa = filial.codigo_empresa
			AND empresa.cnpj = filial.cnpj
	WHERE 
		empresa.codigo_empresa = p_empresa;

	
	WITH ent AS (
	SELECT 
		p_empresa,
		filial,
		dados as j	
	),
	header AS (
		SELECT * FROM ent, json_populate_record(null::t_frt_ecofrt_header, ent.j#>'{header}') 
	),
	detalhes AS (
		SELECT x.* FROM ent, json_populate_recordset(null::t_frt_ecofrt_detalhes, ent.j#>'{detalhes}')  as x
	),
	trailler AS (
		SELECT * FROM ent, json_populate_record(null::t_frt_ecofrt_trailler, ent.j#>'{trailler}') 
	),
	ab_novo AS (
		INSERT INTO frt_ab (
			ab_empresa, --1
			ab_filial, --2
			ab_nr, --3
			ab_placa, --4
			ab_id_combust, --5
			ab_data, --6
			ab_usu, --7
			ab_km, --8
			ab_id_posto, --9
			ab_id_motorista, --10
			ab_qtd, --11
			ab_vlr_unit, --12
			ab_vlr_total, --13
			ab_origem, --14		
			ab_placas_engates --15
		)
		SELECT 
			p_empresa as ab_empresa,
			filial as ab_filial,
			p_empresa || filial || 
			trim(to_char(proximo_numero_sequencia('frt_ab_' ||p_empresa || '_' || filial),'0000000')) as ab_nr,
			detalhes.placa as ab_placa,
			coi.id_combust_lub as ab_id_combust,
			detalhes.dt_trans as ab_data,
			1::integer as ab_usu,
			hodom::numeric(8,0) as ab_km,
			posto.id_fornecedor as ab_id_posto,
			mot.id_fornecedor as ab_id_motorista,
			qt_mater::numeric(10,2) as ab_qtd,
			CASE 
				WHEN vl_trans > 0 AND qt_mater > 0
				THEN vl_trans/qt_mater
				ELSE 0.00
			END::numeric(14,2) as ab_vlr_unit,
			vl_trans::numeric(14,2) as ab_vlr_total,
			1::integer as ab_origem,
			f_retorna_placas_engates(detalhes.placa, detalhes.dt_trans)
			
			--,detalhes.*	
		FROM 
		
			detalhes
			LEFT JOIN fornecedor_parametros mot_par
				ON trim(mot_par.valor_parametro)::text = trim(detalhes.matric)::text 
					AND mot_par.id_tipo_parametro = 50 

			LEFT JOIN fornecedores mot
				ON mot.id_fornecedor = mot_par.id_fornecedor

			LEFT JOIN fornecedores posto
				ON detalhes.cnpj_estab = posto.cnpj_cpf

			LEFT JOIN frt_ab_ecofrt_tp_mat mat
				ON mat.tipo = "Tipo_Material_no_Arquivo"

			LEFT JOIN Tb_Combust_Lub coi
				ON coi.id_produto = mat.id_produto	
		WHERE
			servico = 'Abastecimento'
		RETURNING *
	)
	INSERT INTO frt_ab_itens (
		id_ab, -- ID do Abastecimento
		ab_id_combust, -- ID do Combustivel / Lubrificante (Tabela Tb_Combust_Lub)
		ab_encheu, -- Esse Abastecimento encheu o tanque? 0 = Nao / 1 = Sim
		ab_usu, -- Usuario do Sistema que fez o registro
		ab_id_bomba, -- ID da Bomba Propria, caso seja Abastecimento Interno (FK na tabela Frt_Bomba)
		ab_qtd, -- Quantidade de Litros ou M3 do Abastecimento
		ab_vlr_unit, -- Valor Unitario do Combustivel
		ab_vlr_total, -- Valor Total do Combustivel
		ab_obs, -- Observacoes sobre este Abastecimento
		atual_em, -- Data e Hora da atualizacao
		ab_vlr_acresc, -- Valor de Acrescimo no preco do Combustivel
		ab_vlr_descon, -- Valor de Desconto no preco do Combustivel
		ab_id_posto -- ID do Posto (fornecedores.id_fornecedor)
	)
	SELECT 
		ab_novo.id_ab,
		ab_novo.ab_id_combust,
		1,
		ab_usu,
		0,
		ab_qtd,
		ab_vlr_unit,
		ab_vlr_total,
		'IMPORTACAO AUTOMATICA DE EDI',
		now(),
		0.00,
		0.00,
		ab_id_posto
	FROM ab_novo;
		
		 
	RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

