CREATE OR REPLACE FUNCTION f_tgg_lcto_ab_sfrota()
  RETURNS trigger AS
$BODY$
DECLARE
	vCursor refcursor;
	v_id_ab integer;
	v_valor_unitario numeric(12,2);
	v_id_bomba integer;
BEGIN

	

	SELECT valor_parametro::integer
	INTO v_id_bomba
	FROM parametros 
	WHERE 	cod_empresa = NEW.codigo_empresa
		AND cod_filial = NEW.codigo_filial
		AND upper(cod_parametro) = 'PST_ID_BOMBA_COMBUST_PADRAO';		

	
	IF NEW.valor_unitario = 0.00 THEN 
		SELECT valor_custo
		INTO v_valor_unitario
		FROM com_produtos 
		LEFT JOIN tb_combust_lub_itens
			ON tb_combust_lub_itens.id_produto = com_produtos.id_produto
		WHERE id_combust_lub = NEW.id_tp_combust;
		
		v_valor_unitario = COALESCE(v_valor_unitario, NEW.valor_unitario);
	ELSE
		v_valor_unitario = NEW.valor_unitario;
	END IF;

	--SELECT * FROM frt_ab
	
	--UPDATE frt_ab_import_sfrota SET id = id
	OPEN vCursor FOR
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
		ab_origem --14		
	) VALUES (
		NEW.codigo_empresa,
		NEW.codigo_filial,
		NEW.codigo_empresa || NEW.codigo_filial || 
		trim(to_char(proximo_numero_sequencia('frt_ab_' || NEW.codigo_empresa || '_' || NEW.codigo_filial) ,'0000000')),
		NEW.placa_veiculo,
		NEW.id_tp_combust ,
		NEW.data_abastecimento,
		NEW.id_usuario,
		NEW.odometro::numeric(8,0),
		NULL::integer,
		NEW.id_motorista,
		NEW.litragem,
		v_valor_unitario,
		v_valor_unitario * NEW.litragem,
		1::integer
	) RETURNING id_ab;

	FETCH vCursor INTO v_id_ab;

	CLOSE vCursor;

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
	) VALUES (	
		v_id_ab,
		NEW.id_tp_combust,
		1,
		NEW.id_usuario,
		0,
		NEW.litragem,
		v_valor_unitario,
		v_valor_unitario * NEW.litragem,
		'IMPORTACAO AUTOMATICA DE EDI',
		now(),
		0.00,
		0.00,
		NULL
	);
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

 --ALTER FUNCTION f_tgg_lcto_ab_sfrota() OWNER TO softlog_organics
/*
SELECT * FROM frt_ab;

DELETE FROM frt_ab WHERE id_ab = 78

*/