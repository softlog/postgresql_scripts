--DROP FUNCTION f_cria_coleta_de_cotacao(p_id_cotacao integer)
--SELECT * FROM fd_dados_tabela('scr_notas_fiscais_imp') ORDER BY 3
/*
	SELECT f_cria_coleta_de_programacao(19)
	SELECT * FROM col_coletas
	SELECT * FROM fd_dados_tabela('col_coletas') ORDER BY 4
	SELECT 
*/

CREATE OR REPLACE FUNCTION f_cria_coleta_de_programacao(p_id_programacao integer)
  RETURNS integer AS
$BODY$
DECLARE
        v_id_coleta integer;
        v_numero_coleta text;
        v_codigo_programacao text;
        v_cursor refcursor;
        
BEGIN

	OPEN v_cursor FOR 
	INSERT INTO col_coletas(
		
		id_coleta_filial, --2
		filial_coleta, --3
		cod_empresa, --4
		data_solicitacao, --5
		hora_solicitacao, --6		
		
		id_remetente, --7
		remetente_nome, --8
		remetente_cnpj, --9
		remetente_inscricao, --10
		id_end_remetente, --11
		remetente_numero, --12
		remetente_endereco, --13	
		remetente_bairro, --14
		remetente_cidade, --15
		remetente_uf, --16
		remetente_cep, --17
		remetente_ddd, --18
		remetente_telefone, --19
	
		id_consignatario, --33
		consignatario_cnpj, --34
		consignatario_nome, --35
		consignatario_inscricao, --36
		id_end_consignatario, --37
		consignatario_numero, --38
		consignatario_endereco, --39	
		consignatario_bairro, --40	
		consignatario_cidade, --41
		consignatario_uf, --42
		consignatario_cep, --43	
		consignatario_ddd, --44
		consignatario_telefone, --45		
		
		data_coleta, --53
		hora_coleta, --54
		cod_interno_frete, --55
		id_programacao_coleta_entrega --56

	)
	WITH t AS (
		SELECT 
			--(t.codigo_empresa || t.codigo_filial || 		
			--trim(to_char(proximo_numero_sequencia('col_coletas_' || t.codigo_empresa || '_' || t.codigo_filial),'0000000'))) as numero_coleta,
			('001' || '001' || 		
			trim(to_char(proximo_numero_sequencia('col_coletas_' || '001' || '_' || '001'),'0000000'))) as numero_coleta,
			--t.codigo_filial,
			'001'::character(3) as codigo_filial,
			--t.codigo_empresa,
			'001'::character(3) as codigo_empresa,
			p.data,
			to_char(p.hora_prevista_carregamento,'HH24MI') as hora,			
			p.cnpj_base as remetente_cnpj,
			NULL::character(14) as destinatario_cnpj,
			CASE WHEN p.frete_cif_fob = 'CIF' THEN trim(p.cnpj_base) ELSE NULL END::character(14) as consignatario_cnpj,
			p.codigo_programacao,			
			CASE WHEN p.entrada IS NOT NULL THEN p.data ELSE NULL END as data_coleta,
			CASE WHEN p.entrada IS NOT NULL THEN to_char(p.entrada,'HH24MI') ELSE NULL END as hora_coleta			
			
		FROM 
			scr_programacao_coleta_entrega p
		WHERE 
			p.id = p_id_programacao
			
	
	)
	SELECT 
		t.numero_coleta, --2
		t.codigo_filial, --3
		t.codigo_empresa, --4
		t.data, --5
		t.hora, --6

		--Remetente
		r.codigo_cliente, --7
		r.nome_cliente, --8
		trim(t.remetente_cnpj)::character(14), --9
		r.inscricao_estadual, --10
		re.id_endereco, --11
		re.numero, --12
		re.logradouro, --13
		re.bairro, --14
		rc.nome_cidade, --15
		rc.uf, --16
		re.cep, --17
		re.ddd, --18
		re.telefone, --19 		
		c.codigo_cliente, --33
		c.nome_cliente, --34
		trim(t.consignatario_cnpj)::character(14), --35
		c.inscricao_estadual, --36
		ce.id_endereco, --37
		ce.numero, --38
		ce.logradouro, --39
		ce.bairro, --40
		cc.nome_cidade, --41
		cc.uf, --42
		ce.cep, --43
		ce.ddd, --44
		ce.telefone, --45
		t.data_coleta, --53
		t.hora_coleta, --54	
		t.codigo_programacao, --55
		p_id_programacao --56
	FROM
		t
		LEFT JOIN cliente r ON t.remetente_cnpj = r.cnpj_cpf
		LEFT JOIN cliente_enderecos re ON re.codigo_cliente = r.codigo_cliente AND re.id_tipo_endereco = 3
		LEFT JOIN cidades rc ON rc.id_cidade = re.id_cidade		

		LEFT JOIN cliente c ON t.consignatario_cnpj = c.cnpj_cpf
 		LEFT JOIN cliente_enderecos ce ON ce.codigo_cliente = c.codigo_cliente AND ce.id_tipo_endereco = 3
		LEFT JOIN cidades cc ON cc.id_cidade = ce.id_cidade
	RETURNING
		id_coleta, id_coleta_filial, cod_interno_frete;

	FETCH v_cursor INTO v_id_coleta, v_numero_coleta, v_codigo_programacao;

	--SELECT cnpj_base
	--INTO 

-- 	CLOSE v_cursor;
-- 	
-- 	INSERT INTO col_coletas_itens(
-- 		id_coleta, 
-- 		quantidade, 
-- 		peso, 
-- 		vol_m3, 
-- 		valor_nota_fiscal
-- 	)
-- 	SELECT 
-- 		v_id_coleta,
-- 		0,
-- 		0,
-- 		0,
-- 		0;
-- 	
-- 	INSERT INTO col_log_atividades(
-- 		id_coleta_filial, 
-- 		data_hora, 
-- 		atividade_executada, 
-- 		usuario)
-- 	VALUES 
-- 		(
-- 		v_id_coleta,
-- 		now(),
-- 		'COLETA GERADA DA PROGRAMACAO N.: ' || trim(p_id_programacao),
-- 		'SUPORTE'
-- 	);
-- 

	/*
	INSERT INTO col_coletas_itens(
		id_coleta, 
		quantidade, 
		peso, 
		vol_m3, 
		valor_nota_fiscal, 
		id_natureza_carga
	)
	SELECT 
		v_id_coleta,
		t.qtd_volumes,
		t.peso,
		t.valor_cubico,
		t.valor_nota_fiscal,
		n.id_natureza_carga
	FROM
		scr_cotacao_tabela_frete t
		LEFT JOIN scr_natureza_carga n ON trim(n.natureza_carga) = trim(t.natureza_carga)
	WHERE
		t.id_cotacao_tabela_frete = p_id_cotacao;		

	INSERT INTO col_log_atividades(
		id_coleta_filial, 
		data_hora, 
		atividade_executada, 
		usuario)
	VALUES 
		(
		v_id_coleta,
		now(),
		'COLETA GERADA DA PROGRAMACAO N.: ' || trim(to_char(p_id_programacao,'000000000')),
		fp_get_session('pst_login')
		);
	*/

	--UPDATE scr_cotacao_tabela_frete SET id_coleta = v_id_coleta WHERE id_cotacao_tabela_frete = p_id_cotacao;
    
	RETURN v_id_coleta;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;



--SELECT f_cria_coleta_de_cotacao(20) as id_coleta


	



	
		
	

