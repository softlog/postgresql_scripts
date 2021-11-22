WITH t AS (

		SELECT last_value, 'aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq'::text as sequencia FROM aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'almoxarifado_id_almoxarifado_seq'::text as sequencia FROM almoxarifado_id_almoxarifado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'anexos_id_anexo_seq'::text as sequencia FROM anexos_id_anexo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'backup_visoes_id_backup_visao_seq'::text as sequencia FROM backup_visoes_id_backup_visao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'banco_id_banco_seq'::text as sequencia FROM banco_id_banco_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_colunas_id_cubo_coluna_seq'::text as sequencia FROM bi_cubo_colunas_id_cubo_coluna_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_condicoes_id_cubo_condicao_seq'::text as sequencia FROM bi_cubo_condicoes_id_cubo_condicao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_dimensoes_id_cubo_dimensao_seq'::text as sequencia FROM bi_cubo_dimensoes_id_cubo_dimensao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_dimensoes_user_id_cubo_dimensao_user_seq'::text as sequencia FROM bi_cubo_dimensoes_user_id_cubo_dimensao_user_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_medidas_id_cubo_medida_seq'::text as sequencia FROM bi_cubo_medidas_id_cubo_medida_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_medidas_user_id_cubo_medida_user_seq'::text as sequencia FROM bi_cubo_medidas_user_id_cubo_medida_user_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubo_user_id_cubo_user_seq'::text as sequencia FROM bi_cubo_user_id_cubo_user_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_cubos_id_cubo_seq'::text as sequencia FROM bi_cubos_id_cubo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'captcha_log_id_transacao_seq'::text as sequencia FROM captcha_log_id_transacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'carteira_id_carteira_seq'::text as sequencia FROM carteira_id_carteira_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cep_id_cep_seq'::text as sequencia FROM cep_id_cep_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cfop_id_cfop_seq'::text as sequencia FROM cfop_id_cfop_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'chat_mensagens_id_mensagem_seq'::text as sequencia FROM chat_mensagens_id_mensagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'chat_usuarios_id_usuario_chat_seq'::text as sequencia FROM chat_usuarios_id_usuario_chat_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cidades_id_cidade_seq'::text as sequencia FROM cidades_id_cidade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cidades_de_para_id_cidades_de_para_seq'::text as sequencia FROM cidades_de_para_id_cidades_de_para_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cidades_new_id_cidade_seq'::text as sequencia FROM cidades_new_id_cidade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cli_emp_planocontas_id_cli_emp_planocontas_seq'::text as sequencia FROM cli_emp_planocontas_id_cli_emp_planocontas_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_codigo_cliente_seq'::text as sequencia FROM cliente_codigo_cliente_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_enderecos_id_endereco_seq'::text as sequencia FROM cliente_enderecos_id_endereco_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_exportacao'::text as sequencia FROM cliente_exportacao 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_instituicao'::text as sequencia FROM cliente_instituicao 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_origem_destino_id_cliente_origem_destino_seq'::text as sequencia FROM cliente_origem_destino_id_cliente_origem_destino_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_parametros_id_cliente_parametro_seq'::text as sequencia FROM cliente_parametros_id_cliente_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_regiao_origem_destino_id_cliente_regiao_origem_dest_seq'::text as sequencia FROM cliente_regiao_origem_destino_id_cliente_regiao_origem_dest_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_tipo_endereco_id_tipo_endereco_seq'::text as sequencia FROM cliente_tipo_endereco_id_tipo_endereco_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_tipo_parametros_id_tipo_parametro_seq'::text as sequencia FROM cliente_tipo_parametros_id_tipo_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_coletas_id_coleta_seq'::text as sequencia FROM col_coletas_id_coleta_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_coletas_itens_id_item_coleta_seq'::text as sequencia FROM col_coletas_itens_id_item_coleta_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_coletas_nf_imp_id_coleta_nf_imp_seq'::text as sequencia FROM col_coletas_nf_imp_id_coleta_nf_imp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_coletas_romaneio_id_coletas_romaneio_seq'::text as sequencia FROM col_coletas_romaneio_id_coletas_romaneio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_formularios_cancelados_id_col_formularios_cancelados_seq'::text as sequencia FROM col_formularios_cancelados_id_col_formularios_cancelados_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_log_atividades_id_log_atividade_seq'::text as sequencia FROM col_log_atividades_id_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_ocorrencia_coleta_id_ocorrencia_coleta_seq'::text as sequencia FROM col_ocorrencia_coleta_id_ocorrencia_coleta_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_romaneio_ajudantes_id_romaneio_ajudantes_seq'::text as sequencia FROM col_romaneio_ajudantes_id_romaneio_ajudantes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_romaneio_coletas_id_romaneios_seq'::text as sequencia FROM col_romaneio_coletas_id_romaneios_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_centro_custos_id_compras_centro_custo_seq'::text as sequencia FROM com_compras_centro_custos_id_compras_centro_custo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_cotacao_id_cotacao_seq'::text as sequencia FROM com_compras_cotacao_id_cotacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_faturas_id_seq'::text as sequencia FROM com_compras_faturas_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_id_compra_seq'::text as sequencia FROM com_compras_id_compra_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_itens_id_compra_item_seq'::text as sequencia FROM com_compras_itens_id_compra_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_log_atividades_id_compra_log_atividade_seq'::text as sequencia FROM com_compras_log_atividades_id_compra_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_pedido_id_pedido_compra_seq'::text as sequencia FROM com_compras_pedido_id_pedido_compra_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_pedido_itens_id_pedido_compra_item_seq'::text as sequencia FROM com_compras_pedido_itens_id_pedido_compra_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_sol_cot_itens_id_item_seq'::text as sequencia FROM com_compras_sol_cot_itens_id_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_solicitacao_id_solicitacao_seq'::text as sequencia FROM com_compras_solicitacao_id_solicitacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_sugestao_cfop_cst_id_seq'::text as sequencia FROM com_compras_sugestao_cfop_cst_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_temp_id_seq'::text as sequencia FROM com_compras_temp_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_condicoes_pgto_id_condicao_pgto_seq'::text as sequencia FROM com_condicoes_pgto_id_condicao_pgto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_condicoes_pgto_parcelas_id_condicao_pgto_parcela_seq'::text as sequencia FROM com_condicoes_pgto_parcelas_id_condicao_pgto_parcela_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_fabricante_produto_id_fabricante_seq'::text as sequencia FROM com_fabricante_produto_id_fabricante_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_faturas_temp_id_seq'::text as sequencia FROM com_faturas_temp_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_fornecedor_temp_id_seq'::text as sequencia FROM com_fornecedor_temp_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nf_id_nf_seq'::text as sequencia FROM com_nf_id_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nf_itens_id_nf_item_seq'::text as sequencia FROM com_nf_itens_id_nf_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nf_itens_medicamentos_id_lote_medicamento_seq'::text as sequencia FROM com_nf_itens_medicamentos_id_lote_medicamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nf_ref_id_nf_ref_seq'::text as sequencia FROM com_nf_ref_id_nf_ref_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nfe_lote_id_lote_seq'::text as sequencia FROM com_nfe_lote_id_lote_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nfe_lote_itens_id_lote_itens_seq'::text as sequencia FROM com_nfe_lote_itens_id_lote_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nfe_parametros_id_nfe_parametro_seq'::text as sequencia FROM com_nfe_parametros_id_nfe_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_op_estoque_id_operacao_seq'::text as sequencia FROM com_op_estoque_id_operacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_pedido_id_pedido_seq'::text as sequencia FROM com_pedido_id_pedido_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_pedido_itens_id_pedido_itens_seq'::text as sequencia FROM com_pedido_itens_id_pedido_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_cores_id_cor_seq'::text as sequencia FROM com_produtos_cores_id_cor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_de_para_id_produto_de_para_seq'::text as sequencia FROM com_produtos_de_para_id_produto_de_para_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_empresa_fornecedor_id_seq'::text as sequencia FROM com_produtos_empresa_fornecedor_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_grupos_id_grupo_seq'::text as sequencia FROM com_produtos_grupos_id_grupo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_id_produto_seq'::text as sequencia FROM com_produtos_id_produto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_lotes_id_produtos_lotes_seq'::text as sequencia FROM com_produtos_lotes_id_produtos_lotes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_sugestao_cfop_cst_id_seq'::text as sequencia FROM com_produtos_sugestao_cfop_cst_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_temp_id_seq'::text as sequencia FROM com_produtos_temp_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_requisicao_id_requisicao_seq'::text as sequencia FROM com_requisicao_id_requisicao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_requisicao_itens_id_item_req_seq'::text as sequencia FROM com_requisicao_itens_id_item_req_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_solicitacao_produtos_usuario_id_solicitacao_seq'::text as sequencia FROM com_solicitacao_produtos_usuario_id_solicitacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_solicitacao_produtos_usuario_itens_id_item_solicitacao_seq'::text as sequencia FROM com_solicitacao_produtos_usuario_itens_id_item_solicitacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'conf_cursoradapter_id_seq'::text as sequencia FROM conf_cursoradapter_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'conf_formulario_id_formulario_seq'::text as sequencia FROM conf_formulario_id_formulario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'contador_formularios_id_formulario_seq'::text as sequencia FROM contador_formularios_id_formulario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_acoes_id_acao_seq'::text as sequencia FROM crm_acoes_id_acao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_avisos_id_aviso_seq'::text as sequencia FROM crm_avisos_id_aviso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_cargos_id_cargo_seq'::text as sequencia FROM crm_cargos_id_cargo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_comp_cont_acao_id_comp_cont_acao_seq'::text as sequencia FROM crm_comp_cont_acao_id_comp_cont_acao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_comp_cont_id_comp_cont_seq'::text as sequencia FROM crm_comp_cont_id_comp_cont_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_compromissos_fotos_id_compromisso_foto_seq'::text as sequencia FROM crm_compromissos_fotos_id_compromisso_foto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_compromissos_id_compromisso_seq'::text as sequencia FROM crm_compromissos_id_compromisso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_cont_relacoes_id_cont_relacao_seq'::text as sequencia FROM crm_cont_relacoes_id_cont_relacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contatos_detalhes_id_contato_detalhe_seq'::text as sequencia FROM crm_contatos_detalhes_id_contato_detalhe_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contatos_fotos_id_contato_foto_seq'::text as sequencia FROM crm_contatos_fotos_id_contato_foto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contatos_id_contato_seq'::text as sequencia FROM crm_contatos_id_contato_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contr_cont_id_contr_cont_seq'::text as sequencia FROM crm_contr_cont_id_contr_cont_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contratos_id_contrato_seq'::text as sequencia FROM crm_contratos_id_contrato_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_processos_id_processo_seq'::text as sequencia FROM crm_processos_id_processo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_tipos_contrato_id_tp_contrato_seq'::text as sequencia FROM crm_tipos_contrato_id_tp_contrato_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_tipos_documento_id_tp_doc_seq'::text as sequencia FROM crm_tipos_documento_id_tp_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'ct_id_seq'::text as sequencia FROM ct_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cubo_pivot_conf_id_cube_pivot_conf_seq'::text as sequencia FROM cubo_pivot_conf_id_cube_pivot_conf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'debug_id_debug_seq'::text as sequencia FROM debug_id_debug_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'departamentos_funcionarios_id_depto_funcionario_seq'::text as sequencia FROM departamentos_funcionarios_id_depto_funcionario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'departamentos_id_departamento_seq'::text as sequencia FROM departamentos_id_departamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_conhecimentos_cobranca_id_conhecimento_cobranca_seq'::text as sequencia FROM edi_conhecimentos_cobranca_id_conhecimento_cobranca_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_conhecimentos_embarcados_id_conhecimento_embarcado_seq'::text as sequencia FROM edi_conhecimentos_embarcados_id_conhecimento_embarcado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_conhecimentos_nf_id_conhecimento_nf_seq'::text as sequencia FROM edi_conhecimentos_nf_id_conhecimento_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_consignatario_id_consignatario_seq'::text as sequencia FROM edi_consignatario_id_consignatario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_consignatario_id_edi_nota_fiscal_seq'::text as sequencia FROM edi_consignatario_id_edi_nota_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_destinatario_id_destinatario_seq'::text as sequencia FROM edi_destinatario_id_destinatario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_documentos_cobranca_id_documento_cobranca_seq'::text as sequencia FROM edi_documentos_cobranca_id_documento_cobranca_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_intercambio_id_edi_intercambio_seq'::text as sequencia FROM edi_intercambio_id_edi_intercambio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_log_documento_id_log_documento_seq'::text as sequencia FROM edi_log_documento_id_log_documento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_notas_fiscais_cobranca_id_nota_fiscal_cobranca_seq'::text as sequencia FROM edi_notas_fiscais_cobranca_id_nota_fiscal_cobranca_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_notas_fiscais_id_destinatario_seq'::text as sequencia FROM edi_notas_fiscais_id_destinatario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_notas_fiscais_id_edi_nota_fiscal_seq'::text as sequencia FROM edi_notas_fiscais_id_edi_nota_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_ocorrencia_entrega_id_edi_ocorrencia_entrega_seq'::text as sequencia FROM edi_ocorrencia_entrega_id_edi_ocorrencia_entrega_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_ocorrencias_comprovei_id_seq'::text as sequencia FROM edi_ocorrencias_comprovei_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_ocorrencias_entrega_id_seq'::text as sequencia FROM edi_ocorrencias_entrega_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_pagador_id_edi_nota_fiscal_seq'::text as sequencia FROM edi_pagador_id_edi_nota_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_pagador_id_pagador_seq'::text as sequencia FROM edi_pagador_id_pagador_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_redespachador_id_edi_nota_fiscal_seq'::text as sequencia FROM edi_redespachador_id_edi_nota_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_redespachador_id_redespachador_seq'::text as sequencia FROM edi_redespachador_id_redespachador_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_remetente_id_remetente_seq'::text as sequencia FROM edi_remetente_id_remetente_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_sped_docs_id_sped_doc_seq'::text as sequencia FROM edi_sped_docs_id_sped_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_tms_embarcador_docs_id_embarcador_doc_seq'::text as sequencia FROM edi_tms_embarcador_docs_id_embarcador_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_tms_embarcadores_id_embarcador_seq'::text as sequencia FROM edi_tms_embarcadores_id_embarcador_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_bc_credito_id_seq'::text as sequencia FROM efd_bc_credito_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_consumo_agua_id_seq'::text as sequencia FROM efd_consumo_agua_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_consumo_energia_id_seq'::text as sequencia FROM efd_consumo_energia_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_cst_confins_id_cst_confins_seq'::text as sequencia FROM efd_cst_confins_id_cst_confins_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_cst_icms_id_cst_icms_seq'::text as sequencia FROM efd_cst_icms_id_cst_icms_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_cst_ipi_id_cst_ipi_seq'::text as sequencia FROM efd_cst_ipi_id_cst_ipi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_cst_pis_id_cst_pis_seq'::text as sequencia FROM efd_cst_pis_id_cst_pis_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_genero_item_id_genero_item_seq'::text as sequencia FROM efd_genero_item_id_genero_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_grupo_tensao_id_seq'::text as sequencia FROM efd_grupo_tensao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_mod_doc_fiscal_id_mod_doc_fiscal_seq'::text as sequencia FROM efd_mod_doc_fiscal_id_mod_doc_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_situacao_fiscal_id_situacao_fiscal_seq'::text as sequencia FROM efd_situacao_fiscal_id_situacao_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_tipo_item_id_tipo_item_seq'::text as sequencia FROM efd_tipo_item_id_tipo_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_tp_assinante_id_seq'::text as sequencia FROM efd_tp_assinante_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_tp_ligacao_id_seq'::text as sequencia FROM efd_tp_ligacao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_unidades_medida_id_unidade_seq'::text as sequencia FROM efd_unidades_medida_id_unidade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'email_uid_imap_id_seq'::text as sequencia FROM email_uid_imap_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'emb_conhecimentos_embarcados_id_emb_conhecimento_embarcado_seq'::text as sequencia FROM emb_conhecimentos_embarcados_id_emb_conhecimento_embarcado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'emb_documentos_cobranca_id_emb_documento_cobranca_seq'::text as sequencia FROM emb_documentos_cobranca_id_emb_documento_cobranca_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'emb_documentos_cobranca_itens_id_documento_cobranca_itens_seq'::text as sequencia FROM emb_documentos_cobranca_itens_id_documento_cobranca_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'emb_notas_fiscais_id_emb_nota_fiscal_seq'::text as sequencia FROM emb_notas_fiscais_id_emb_nota_fiscal_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'emb_ocorrencia_entrega_id_emb_ocorrencia_entrega_seq'::text as sequencia FROM emb_ocorrencia_entrega_id_emb_ocorrencia_entrega_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'embarcador_logistica_id_embarcador_logistica_seq'::text as sequencia FROM embarcador_logistica_id_embarcador_logistica_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'embarcadores_edi_id_embarcadores_edi_seq'::text as sequencia FROM embarcadores_edi_id_embarcadores_edi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'empresa_id_empresa_seq'::text as sequencia FROM empresa_id_empresa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'empresa_acesso_servicos_id_seq'::text as sequencia FROM empresa_acesso_servicos_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'empresa_regime_tributario_id_seq'::text as sequencia FROM empresa_regime_tributario_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'empresas_seq'::text as sequencia FROM empresas_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estado_aliquotas_icms_id_estado_aliquota_pk_seq'::text as sequencia FROM estado_aliquotas_icms_id_estado_aliquota_pk_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estado_aliquotas_id_estado_aliquota_seq'::text as sequencia FROM estado_aliquotas_id_estado_aliquota_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estado_id_estado_pk_seq'::text as sequencia FROM estado_id_estado_pk_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estado_tabela_icms_id_estado_tabela_icms_seq'::text as sequencia FROM estado_tabela_icms_id_estado_tabela_icms_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estado_tipo_aliquotas_id_tipo_aliquota_seq'::text as sequencia FROM estado_tipo_aliquotas_id_tipo_aliquota_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estoque_movimentacao_id_mov_seq'::text as sequencia FROM estoque_movimentacao_id_mov_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'estoques_id_estoque_seq'::text as sequencia FROM estoques_id_estoque_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fdw_parametros_softlog_cep_id_parametro_softlog_cep_seq'::text as sequencia FROM fdw_parametros_softlog_cep_id_parametro_softlog_cep_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fila_envio_romaneios_id_seq'::text as sequencia FROM fila_envio_romaneios_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fila_protoloco_comprovei_id_seq'::text as sequencia FROM fila_protoloco_comprovei_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'filial_id_filial_seq'::text as sequencia FROM filial_id_filial_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'filial_inscricoes_est_id_inscricao_est_seq'::text as sequencia FROM filial_inscricoes_est_id_inscricao_est_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'filial_rotas_id_filial_rotas_seq'::text as sequencia FROM filial_rotas_id_filial_rotas_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'flag_trigger_tabela_id_flag_trigger_tabela_seq'::text as sequencia FROM flag_trigger_tabela_id_flag_trigger_tabela_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'for_emp_planocontas_id_for_emp_planocontas_seq'::text as sequencia FROM for_emp_planocontas_id_for_emp_planocontas_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedor_cargos_id_cargos_seq'::text as sequencia FROM fornecedor_cargos_id_cargos_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedor_parametros_id_seq'::text as sequencia FROM fornecedor_parametros_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedor_tipo_parametros_id_seq'::text as sequencia FROM fornecedor_tipo_parametros_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedores_id_fornecedor_seq'::text as sequencia FROM fornecedores_id_fornecedor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedores_contas_correntes_id_cc_fornecedor_seq'::text as sequencia FROM fornecedores_contas_correntes_id_cc_fornecedor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fornecedores_fotos_id_foto_seq'::text as sequencia FROM fornecedores_fotos_id_foto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_autor_id_autor_seq'::text as sequencia FROM frt_ab_autor_id_autor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_autor_itens_id_autor_item_seq'::text as sequencia FROM frt_ab_autor_itens_id_autor_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_ecofrt_servicos_id_seq'::text as sequencia FROM frt_ab_ecofrt_servicos_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_ecofrt_tp_mat_id_seq'::text as sequencia FROM frt_ab_ecofrt_tp_mat_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_id_ab_seq'::text as sequencia FROM frt_ab_id_ab_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_import_id_seq'::text as sequencia FROM frt_ab_import_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_itens_id_ab_item_seq'::text as sequencia FROM frt_ab_itens_id_ab_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_layouts_id_seq'::text as sequencia FROM frt_ab_layouts_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_abastecimento_autotrac_id_abastecimento_autotrac_seq'::text as sequencia FROM frt_abastecimento_autotrac_id_abastecimento_autotrac_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_apuracao_analitica_1_id_seq'::text as sequencia FROM frt_apuracao_analitica_1_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_apuracao_id_seq'::text as sequencia FROM frt_apuracao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_bp_id_bp_seq'::text as sequencia FROM frt_bp_id_bp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_consumo_id_consumo_seq'::text as sequencia FROM frt_consumo_id_consumo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_hist_frota_id_hist_frota_seq'::text as sequencia FROM frt_hist_frota_id_hist_frota_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_log_id_frt_log_seq'::text as sequencia FROM frt_log_id_frt_log_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mnt_os_id_os_seq'::text as sequencia FROM frt_mnt_os_id_os_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mnt_os_pecas_id_os_pecas_seq'::text as sequencia FROM frt_mnt_os_pecas_id_os_pecas_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mnt_os_servicos_id_os_servicos_seq'::text as sequencia FROM frt_mnt_os_servicos_id_os_servicos_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mod_ativ_con_id_mac_seq'::text as sequencia FROM frt_mod_ativ_con_id_mac_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mov_eng_deseng_id_mov_seq'::text as sequencia FROM frt_mov_eng_deseng_id_mov_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_os_id_os_seq'::text as sequencia FROM frt_os_id_os_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_os_itens_id_os_item_seq'::text as sequencia FROM frt_os_itens_id_os_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_parametros_autotrac_id_parametro_autotrac_seq'::text as sequencia FROM frt_parametros_autotrac_id_parametro_autotrac_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pm_id_pm_seq'::text as sequencia FROM frt_pm_id_pm_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pmit_id_pmit_seq'::text as sequencia FROM frt_pmit_id_pmit_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pmtv_id_pmtv_seq'::text as sequencia FROM frt_pmtv_id_pmtv_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pmtvit_id_pmtvit_seq'::text as sequencia FROM frt_pmtvit_id_pmtvit_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pmveic_id_pmveic_seq'::text as sequencia FROM frt_pmveic_id_pmveic_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_afericao_id_pneu_afericao_seq'::text as sequencia FROM frt_pneu_afericao_id_pneu_afericao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_chassi_id_chassi_seq'::text as sequencia FROM frt_pneu_chassi_id_chassi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_chassi_posicao_id_chassi_posicao_seq'::text as sequencia FROM frt_pneu_chassi_posicao_id_chassi_posicao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_desenho_id_pneu_desenho_seq'::text as sequencia FROM frt_pneu_desenho_id_pneu_desenho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_despesas_id_pneu_despesa_seq'::text as sequencia FROM frt_pneu_despesas_id_pneu_despesa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_dimensao_id_pneu_dimensao_seq'::text as sequencia FROM frt_pneu_dimensao_id_pneu_dimensao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_eixo_suspenso_id_pneu_eixo_suspenso_seq'::text as sequencia FROM frt_pneu_eixo_suspenso_id_pneu_eixo_suspenso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_manut_id_pneu_manut_seq'::text as sequencia FROM frt_pneu_manut_id_pneu_manut_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_marca_id_pneu_marca_seq'::text as sequencia FROM frt_pneu_marca_id_pneu_marca_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_modelos_id_pneu_modelo_seq'::text as sequencia FROM frt_pneu_modelos_id_pneu_modelo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_motivo_retirada_id_pneu_motivo_retirada_seq'::text as sequencia FROM frt_pneu_motivo_retirada_id_pneu_motivo_retirada_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_movimentacao_id_pneu_movimentacao_seq'::text as sequencia FROM frt_pneu_movimentacao_id_pneu_movimentacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_recapagem_id_pneu_recapagem_seq'::text as sequencia FROM frt_pneu_recapagem_id_pneu_recapagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_viagem_id_pneu_viagem_seq'::text as sequencia FROM frt_pneu_viagem_id_pneu_viagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_viagem_rodagem_id_pneu_viagem_rodagem_seq'::text as sequencia FROM frt_pneu_viagem_rodagem_id_pneu_viagem_rodagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneu_vida_id_pneu_vida_seq'::text as sequencia FROM frt_pneu_vida_id_pneu_vida_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_pneus_id_pneu_seq'::text as sequencia FROM frt_pneus_id_pneu_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_req_id_req_seq'::text as sequencia FROM frt_req_id_req_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_req_itens_id_item_seq'::text as sequencia FROM frt_req_itens_id_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_tmp_sem_parar_id_tmp_sem_parar_seq'::text as sequencia FROM frt_tmp_sem_parar_id_tmp_sem_parar_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_tq_id_tq_seq'::text as sequencia FROM frt_tq_id_tq_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_veic_ativ_id_ativ_seq'::text as sequencia FROM frt_veic_ativ_id_ativ_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_veic_km_id_veic_km_seq'::text as sequencia FROM frt_veic_km_id_veic_km_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_viagem_nao_rodado_id_viagem_nao_rodado_seq'::text as sequencia FROM frt_viagem_nao_rodado_id_viagem_nao_rodado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_viagem_rodagem_id_viagem_rodagem_seq'::text as sequencia FROM frt_viagem_rodagem_id_viagem_rodagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'log_atividades_id_log_seq'::text as sequencia FROM log_atividades_id_log_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'log_retorno_banco_id_log_retorno_banco_seq'::text as sequencia FROM log_retorno_banco_id_log_retorno_banco_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'modulo_atualizacoes_id_atualizacao_modulo_seq'::text as sequencia FROM modulo_atualizacoes_id_atualizacao_modulo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'modulo_atualizacoes_partes_id_modulo_atualizacoes_partes_seq'::text as sequencia FROM modulo_atualizacoes_partes_id_modulo_atualizacoes_partes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'modulos_sistema_permissoes_id_permissao_seq'::text as sequencia FROM modulos_sistema_permissoes_id_permissao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_doc_redespacho_id_doc_redespacho_seq'::text as sequencia FROM msg_doc_redespacho_id_doc_redespacho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_doc_vendedores_id_doc_vendedores_seq'::text as sequencia FROM msg_doc_vendedores_id_doc_vendedores_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_edi_lista_chaves_id_seq'::text as sequencia FROM msg_edi_lista_chaves_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_fila_totvs_erros_id_seq'::text as sequencia FROM msg_fila_totvs_erros_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_fila_totvs_id_seq'::text as sequencia FROM msg_fila_totvs_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_notificacao_id_notificacao_seq'::text as sequencia FROM msg_notificacao_id_notificacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_subscricao_aux_id_subscricao_aux_seq'::text as sequencia FROM msg_subscricao_aux_id_subscricao_aux_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'msg_subscricao_id_subscricao_seq'::text as sequencia FROM msg_subscricao_id_subscricao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'paises_id_pais_seq'::text as sequencia FROM paises_id_pais_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'parametros_id_parametro_seq'::text as sequencia FROM parametros_id_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'pneus_fogo_seq'::text as sequencia FROM pneus_fogo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'produtos_id_produto_seq'::text as sequencia FROM produtos_id_produto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'produtos_codigo_produto_seq'::text as sequencia FROM produtos_codigo_produto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'profile_id_profile_seq'::text as sequencia FROM profile_id_profile_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'recado_login_id_mensagem_seq'::text as sequencia FROM recado_login_id_mensagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'regiao_id_regiao_seq'::text as sequencia FROM regiao_id_regiao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'regiao_bairros_id_regiao_bairro_seq'::text as sequencia FROM regiao_bairros_id_regiao_bairro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'regiao_cidades_id_regiao_cidades_seq'::text as sequencia FROM regiao_cidades_id_regiao_cidades_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'regiao_remetentes_id_seq'::text as sequencia FROM regiao_remetentes_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'remessa_faturas_id_remessa_fatura_seq'::text as sequencia FROM remessa_faturas_id_remessa_fatura_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'remessa_id_remessa_seq'::text as sequencia FROM remessa_id_remessa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_abastecimento_id_abastecimento_seq'::text as sequencia FROM sca_abastecimento_id_abastecimento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_afericao_id_afericao_seq'::text as sequencia FROM sca_afericao_id_afericao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_ajuste_odometro_id_ajuste_seq'::text as sequencia FROM sca_ajuste_odometro_id_ajuste_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_combustivel_id_combustivel_seq'::text as sequencia FROM sca_combustivel_id_combustivel_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_entrada_id_entrada_seq'::text as sequencia FROM sca_entrada_id_entrada_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_estoque_id_movimento_seq'::text as sequencia FROM sca_estoque_id_movimento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_requisicao_id_requisicao_seq'::text as sequencia FROM sca_requisicao_id_requisicao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_requisicao_acoes_id_sca_requisicao_acoes_seq'::text as sequencia FROM sca_requisicao_acoes_id_sca_requisicao_acoes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sca_tanque_id_geral_tanque_seq'::text as sequencia FROM sca_tanque_id_geral_tanque_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_agencias_bancarias_id_agencia_seq'::text as sequencia FROM scf_agencias_bancarias_id_agencia_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_caixas_id_caixa_seq'::text as sequencia FROM scf_caixas_id_caixa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_caixas_historico_id_historico_caixa_seq'::text as sequencia FROM scf_caixas_historico_id_historico_caixa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_centro_custos_id_centro_custo_seq'::text as sequencia FROM scf_centro_custos_id_centro_custo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_centro_custos_emp_001'::text as sequencia FROM scf_centro_custos_emp_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_cheques_cancelados_id_cheque_cancelado_seq'::text as sequencia FROM scf_cheques_cancelados_id_cheque_cancelado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_conta_tabela_modelo_numero_lancamento_seq'::text as sequencia FROM scf_conta_tabela_modelo_numero_lancamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_caixa_seq'::text as sequencia FROM scf_contas_caixa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_correntes_id_conta_corrente_seq'::text as sequencia FROM scf_contas_correntes_id_conta_corrente_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_correntes_seq'::text as sequencia FROM scf_contas_correntes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_pagar_id_conta_pagar_seq'::text as sequencia FROM scf_contas_pagar_id_conta_pagar_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_pagar_anexos_id_conta_pagar_anexo_seq'::text as sequencia FROM scf_contas_pagar_anexos_id_conta_pagar_anexo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_pagar_centro_custos_id_cpagar_custo_seq'::text as sequencia FROM scf_contas_pagar_centro_custos_id_cpagar_custo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_pagar_workflow_id_contas_pagar_workflow_seq'::text as sequencia FROM scf_contas_pagar_workflow_id_contas_pagar_workflow_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_despesas_automaticas_id_despesa_automatica_seq'::text as sequencia FROM scf_despesas_automaticas_id_despesa_automatica_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_emprestimos_entre_empresas_id_emprestimo_seq'::text as sequencia FROM scf_emprestimos_entre_empresas_id_emprestimo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_historicos_id_historico_seq'::text as sequencia FROM scf_historicos_id_historico_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_desenho_pneu_id_desenho_pneu_seq'::text as sequencia FROM scp_desenho_pneu_id_desenho_pneu_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_diagrama_pneus_id_diagrama_pneus_seq'::text as sequencia FROM scp_diagrama_pneus_id_diagrama_pneus_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_diagrama_posicoes_id_diagrama_posicoes_seq'::text as sequencia FROM scp_diagrama_posicoes_id_diagrama_posicoes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_laudos_remocao_id_laudo_remocao_seq'::text as sequencia FROM scp_laudos_remocao_id_laudo_remocao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_marca_pneu_id_marca_pneu_seq'::text as sequencia FROM scp_marca_pneu_id_marca_pneu_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_medidas_pneu_id_medida_pneu_seq'::text as sequencia FROM scp_medidas_pneu_id_medida_pneu_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scp_posicao_pneu_id_posicao_pneu_seq'::text as sequencia FROM scp_posicao_pneu_id_posicao_pneu_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_carta_correcao_id_carta_correcao_seq'::text as sequencia FROM scr_carta_correcao_id_carta_correcao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_carta_correcao_itens_id_carta_correcao_itens_seq'::text as sequencia FROM scr_carta_correcao_itens_id_carta_correcao_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_configuracoes_texto_id_configuracao_texto_seq'::text as sequencia FROM scr_configuracoes_texto_id_configuracao_texto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_averbacao_id_seq'::text as sequencia FROM scr_conhecimento_averbacao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_cf_id_conhecimento_cf_seq'::text as sequencia FROM scr_conhecimento_cf_id_conhecimento_cf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_digitalizado_id_ctrc_digitalizado_seq'::text as sequencia FROM scr_conhecimento_digitalizado_id_ctrc_digitalizado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_entrega_id_conhecimento_entrega_seq'::text as sequencia FROM scr_conhecimento_entrega_id_conhecimento_entrega_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_id_conhecimento_seq'::text as sequencia FROM scr_conhecimento_id_conhecimento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_imagem_id_conhecimento_imagem_seq'::text as sequencia FROM scr_conhecimento_imagem_id_conhecimento_imagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_notas_fiscai_id_conhecimento_notas_fiscais_seq'::text as sequencia FROM scr_conhecimento_notas_fiscai_id_conhecimento_notas_fiscais_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_notas_fiscais_imp_id_notas_fiscais_imp_seq'::text as sequencia FROM scr_conhecimento_notas_fiscais_imp_id_notas_fiscais_imp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_obs_id_conhecimento_obs_seq'::text as sequencia FROM scr_conhecimento_obs_id_conhecimento_obs_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_obs_template_id_observacao_seq'::text as sequencia FROM scr_conhecimento_obs_template_id_observacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_ocorrencias__id_conhecimento_ocorrencia_nf_seq'::text as sequencia FROM scr_conhecimento_ocorrencias__id_conhecimento_ocorrencia_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_redespacho_id_conhecimento_redespacho_seq'::text as sequencia FROM scr_conhecimento_redespacho_id_conhecimento_redespacho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_rodoviario___seq'::text as sequencia FROM scr_conhecimento_rodoviario___seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_id_cotacao_seq'::text as sequencia FROM scr_cotacao_id_cotacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ctrc_log_atividades_id_ctrc_log_atividade_seq'::text as sequencia FROM scr_ctrc_log_atividades_id_ctrc_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_notas_fiscais_id_cotacao_notas_fiscais_seq'::text as sequencia FROM scr_cotacao_notas_fiscais_id_cotacao_notas_fiscais_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_notas_fiscais_imp_id_cotacao_nota_fiscal_imp_seq'::text as sequencia FROM scr_cotacao_notas_fiscais_imp_id_cotacao_nota_fiscal_imp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_tabela_frete_cf_id_cotacao_tabela_frete_cf_seq'::text as sequencia FROM scr_cotacao_tabela_frete_cf_id_cotacao_tabela_frete_cf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_tabela_frete_id_cotacao_tabela_frete_seq'::text as sequencia FROM scr_cotacao_tabela_frete_id_cotacao_tabela_frete_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cotacao_tabela_frete_log_id_cotacao_tabela_frete_log_seq'::text as sequencia FROM scr_cotacao_tabela_frete_log_id_cotacao_tabela_frete_log_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_cce_id_cte_cce_seq'::text as sequencia FROM scr_cte_cce_id_cte_cce_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_cce_itens_id_cte_cce_itens_seq'::text as sequencia FROM scr_cte_cce_itens_id_cte_cce_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_itens_correcao_id_cte_item_correcao_seq'::text as sequencia FROM scr_cte_itens_correcao_id_cte_item_correcao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_lote_id_lote_seq'::text as sequencia FROM scr_cte_lote_id_lote_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_lote_itens_id_lote_itens_seq'::text as sequencia FROM scr_cte_lote_itens_id_lote_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_cte_parametros_id_cte_parametro_seq'::text as sequencia FROM scr_cte_parametros_id_cte_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_despesas_viagem_id_despesa_seq'::text as sequencia FROM scr_despesas_viagem_id_despesa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_doc_anulado_id_anulacao_seq'::text as sequencia FROM scr_doc_anulado_id_anulacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_doc_integracao_id_doc_integracao_seq'::text as sequencia FROM scr_doc_integracao_id_doc_integracao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_doc_integracao_nfe_id_seq'::text as sequencia FROM scr_doc_integracao_nfe_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_docs_digitalizados_id_seq'::text as sequencia FROM scr_docs_digitalizados_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_docs_notrexo_controle_id_seq'::text as sequencia FROM scr_docs_notrexo_controle_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_docs_notrexo_id_seq'::text as sequencia FROM scr_docs_notrexo_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_faturamento_contato_id_faturamento_contato_seq'::text as sequencia FROM scr_faturamento_contato_id_faturamento_contato_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_faturamento_id_faturamento_seq'::text as sequencia FROM scr_faturamento_id_faturamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_faturamento_log_atividades_id_faturamento_log_atividade_seq'::text as sequencia FROM scr_faturamento_log_atividades_id_faturamento_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_faturamento_ocorrencias_id_faturamento_ocorrencia_seq'::text as sequencia FROM scr_faturamento_ocorrencias_id_faturamento_ocorrencia_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_filiais_comissoes_id_filial_comissao_seq'::text as sequencia FROM scr_filiais_comissoes_id_filial_comissao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_filiais_tipo_comissao_id_tipo_comissao_seq'::text as sequencia FROM scr_filiais_tipo_comissao_id_tipo_comissao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_formularios_cancelados_id_formulario_cancelado_seq'::text as sequencia FROM scr_formularios_cancelados_id_formulario_cancelado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_itens_correcao_id_itens_correcao_seq'::text as sequencia FROM scr_itens_correcao_id_itens_correcao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_log_ocorrencias_imp_id_log_ocorrencia_imp_seq'::text as sequencia FROM scr_log_ocorrencias_imp_id_log_ocorrencia_imp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_log_valores_tabelas_frete_id_log_valores_tabelas_frete_seq'::text as sequencia FROM scr_log_valores_tabelas_frete_id_log_valores_tabelas_frete_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_averbacao_erros_id_seq'::text as sequencia FROM scr_manifesto_averbacao_erros_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_averbacao_id_seq'::text as sequencia FROM scr_manifesto_averbacao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_despesas_viagem_id_despesa_manifesto_seq'::text as sequencia FROM scr_manifesto_despesas_viagem_id_despesa_manifesto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_id_manifesto_seq'::text as sequencia FROM scr_manifesto_id_manifesto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_log_atividades_id_manifesto_log_atividade_seq'::text as sequencia FROM scr_manifesto_log_atividades_id_manifesto_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_uf_percurso_id_manifesto_uf_percurso_id_seq'::text as sequencia FROM scr_manifesto_uf_percurso_id_manifesto_uf_percurso_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_mdfe_lote_id_lote_seq'::text as sequencia FROM scr_mdfe_lote_id_lote_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_mdfe_lote_itens_id_mdfe_lote_itens_seq'::text as sequencia FROM scr_mdfe_lote_itens_id_mdfe_lote_itens_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_mdfe_parametros_id_mdfe_parametro_seq'::text as sequencia FROM scr_mdfe_parametros_id_mdfe_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_natureza_carga_id_natureza_carga_seq'::text as sequencia FROM scr_natureza_carga_id_natureza_carga_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_natureza_prestacao_id_natureza_prestacao_seq'::text as sequencia FROM scr_natureza_prestacao_id_natureza_prestacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_nf_protocolo_id_nf_protocolo_seq'::text as sequencia FROM scr_nf_protocolo_id_nf_protocolo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_nf_protocolo_nf_id_nf_protocolo_nf_seq'::text as sequencia FROM scr_nf_protocolo_nf_id_nf_protocolo_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_nf_protocolo_setor_id_nf_protocolo_setor_seq'::text as sequencia FROM scr_nf_protocolo_setor_id_nf_protocolo_setor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_nfe_rastreamentos_id_seq'::text as sequencia FROM scr_nfe_rastreamentos_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_imp_anexos_id_nota_fiscal_anexo_seq'::text as sequencia FROM scr_notas_fiscais_imp_anexos_id_nota_fiscal_anexo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_imp_id_nota_fiscal_imp_seq'::text as sequencia FROM scr_notas_fiscais_imp_id_nota_fiscal_imp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_imp_log_ati_id_nota_fiscal_imp_log_ativid_seq'::text as sequencia FROM scr_notas_fiscais_imp_log_ati_id_nota_fiscal_imp_log_ativid_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_imp_ocorrencias_id_ocorrencia_nf_seq'::text as sequencia FROM scr_notas_fiscais_imp_ocorrencias_id_ocorrencia_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_nao_imp_id_seq'::text as sequencia FROM scr_notas_fiscais_nao_imp_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_segmento_id_seq'::text as sequencia FROM scr_notas_fiscais_segmento_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ocorrencia_edi_id_scr_ocorrencia_edi_seq'::text as sequencia FROM scr_ocorrencia_edi_id_scr_ocorrencia_edi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ocorrencia_obs_edi_id_scr_ocorrencia_obs_edi_seq'::text as sequencia FROM scr_ocorrencia_obs_edi_id_scr_ocorrencia_obs_edi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ocorrencias_proceda_id_seq'::text as sequencia FROM scr_ocorrencias_proceda_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_pre_fatura_entregas_id_pre_fatura_entrega_seq'::text as sequencia FROM scr_pre_fatura_entregas_id_pre_fatura_entrega_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_pre_faturas_id_pre_fatura_seq'::text as sequencia FROM scr_pre_faturas_id_pre_fatura_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_protocolo_dev_canhoto_id_protocolo_dev_seq'::text as sequencia FROM scr_protocolo_dev_canhoto_id_protocolo_dev_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_rastreamento_id_rastreamento_seq'::text as sequencia FROM scr_rastreamento_id_rastreamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_centro_custo_id_relatorio_centro_custo_seq'::text as sequencia FROM scr_relatorio_viagem_centro_custo_id_relatorio_centro_custo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_fechamentos_id_fechamento_seq'::text as sequencia FROM scr_relatorio_viagem_fechamentos_id_fechamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_id_relatorio_viagem_seq'::text as sequencia FROM scr_relatorio_viagem_id_relatorio_viagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_log_atividades_id_log_atividade_seq'::text as sequencia FROM scr_relatorio_viagem_log_atividades_id_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_parcelas_id_parcela_seq'::text as sequencia FROM scr_relatorio_viagem_parcelas_id_parcela_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_redespac_id_relatorio_viagem_redespach_seq'::text as sequencia FROM scr_relatorio_viagem_redespac_id_relatorio_viagem_redespach_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_romaneios_id_relatorio_viagem_romaneio_seq'::text as sequencia FROM scr_relatorio_viagem_romaneios_id_relatorio_viagem_romaneio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_ajudantes_id_romaneio_ajudante_seq'::text as sequencia FROM scr_romaneio_ajudantes_id_romaneio_ajudante_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_despesas_id_romaneio_despesa_seq'::text as sequencia FROM scr_romaneio_despesas_id_romaneio_despesa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_fechamentos_id_fechamento_seq'::text as sequencia FROM scr_romaneio_fechamentos_id_fechamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_log_atividades_id_log_atividade_seq'::text as sequencia FROM scr_romaneio_log_atividades_id_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_nf_id_romaneio_nf_seq'::text as sequencia FROM scr_romaneio_nf_id_romaneio_nf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_redespacho_id_romaneio_redespacho_seq'::text as sequencia FROM scr_romaneio_redespacho_id_romaneio_redespacho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneios_id_romaneio_seq'::text as sequencia FROM scr_romaneios_id_romaneio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_servicos_executados_id_servico_executado_seq'::text as sequencia FROM scr_servicos_executados_id_servico_executado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_servicos_executados_itens_id_servico_executado_item_seq'::text as sequencia FROM scr_servicos_executados_itens_id_servico_executado_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_servicos_id_servico_seq'::text as sequencia FROM scr_servicos_id_servico_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tab_observacoes_id_ocorrencia_seq'::text as sequencia FROM scr_tab_observacoes_id_ocorrencia_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_feriados_id_feriado_seq'::text as sequencia FROM scr_tabela_feriados_id_feriado_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_id_tabela_motorista_seq'::text as sequencia FROM scr_tabela_motorista_id_tabela_motorista_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_log_ativ_id_tabela_motorista_log_ativi_seq'::text as sequencia FROM scr_tabela_motorista_log_ativ_id_tabela_motorista_log_ativi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_regiao_calculos_id_calculo_seq'::text as sequencia FROM scr_tabela_motorista_regiao_calculos_id_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_regioes_id_tabela_motorista_regiao_seq'::text as sequencia FROM scr_tabela_motorista_regioes_id_tabela_motorista_regiao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_tipo_calculo_id_tipo_calculo_seq'::text as sequencia FROM scr_tabela_motorista_tipo_calculo_id_tipo_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_audit_id_tabela_frete_seq'::text as sequencia FROM scr_tabelas_audit_id_tabela_frete_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_calculos_audit_id_calculo_seq'::text as sequencia FROM scr_tabelas_calculos_audit_id_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_calculos_id_calculo_seq'::text as sequencia FROM scr_tabelas_calculos_id_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_cf_audit_id_cf_seq'::text as sequencia FROM scr_tabelas_cf_audit_id_cf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_cf_id_cf_seq'::text as sequencia FROM scr_tabelas_cf_id_cf_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_aereo_origem_dest_id_origem_destino_aereo_seq'::text as sequencia FROM scr_tabelas_frete_aereo_origem_dest_id_origem_destino_aereo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_id_tabela_frete_seq'::text as sequencia FROM scr_tabelas_frete_id_tabela_frete_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_origem_destino_fa_id_origem_destino_faixa_seq'::text as sequencia FROM scr_tabelas_frete_origem_destino_fa_id_origem_destino_faixa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_origem_destino_id_origem_destino_seq'::text as sequencia FROM scr_tabelas_frete_origem_destino_id_origem_destino_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_peso_id_tabelas_frete_peso_seq'::text as sequencia FROM scr_tabelas_frete_peso_id_tabelas_frete_peso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_peso_id_tabelas_frete_peso_seq1'::text as sequencia FROM scr_tabelas_frete_peso_id_tabelas_frete_peso_seq1 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_regiao_faixas_peso_id_regiao_faixa_peso_seq'::text as sequencia FROM scr_tabelas_frete_regiao_faixas_peso_id_regiao_faixa_peso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_regiao_faixas_valor_id_regiao_faixa_valor_seq'::text as sequencia FROM scr_tabelas_frete_regiao_faixas_valor_id_regiao_faixa_valor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_regiao_id_regiao_seq'::text as sequencia FROM scr_tabelas_frete_regiao_id_regiao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_tipo_calculo_id_tipo_calculo_seq'::text as sequencia FROM scr_tabelas_frete_tipo_calculo_id_tipo_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_valor_id_tabelas_frete_valor_seq'::text as sequencia FROM scr_tabelas_frete_valor_id_tabelas_frete_valor_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_valor_id_tabelas_frete_valor_seq1'::text as sequencia FROM scr_tabelas_frete_valor_id_tabelas_frete_valor_seq1 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_frete_workflow_id_tabelas_frete_workflow_seq'::text as sequencia FROM scr_tabelas_frete_workflow_id_tabelas_frete_workflow_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_id_tabela_frete_seq'::text as sequencia FROM scr_tabelas_id_tabela_frete_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_origem_destino_audit_id_origem_destino_seq'::text as sequencia FROM scr_tabelas_origem_destino_audit_id_origem_destino_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_origem_destino_calculos_id_calculo_seq'::text as sequencia FROM scr_tabelas_origem_destino_calculos_id_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_origem_destino_id_origem_destino_seq'::text as sequencia FROM scr_tabelas_origem_destino_id_origem_destino_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_redespacho_id_tabela_redespacho_seq'::text as sequencia FROM scr_tabelas_redespacho_id_tabela_redespacho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_redespacho_regiao_calculos_id_calculo_seq'::text as sequencia FROM scr_tabelas_redespacho_regiao_calculos_id_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_redespacho_regiao_id_regiao_seq'::text as sequencia FROM scr_tabelas_redespacho_regiao_id_regiao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_redespacho_tipo_calculo_id_tipo_calculo_seq'::text as sequencia FROM scr_tabelas_redespacho_tipo_calculo_id_tipo_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_redespacho_workfl_id_tabelas_redespacho_workflo_seq'::text as sequencia FROM scr_tabelas_redespacho_workfl_id_tabelas_redespacho_workflo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_tipo_calculo_id_tipo_calculo_seq'::text as sequencia FROM scr_tabelas_tipo_calculo_id_tipo_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_tipo_veiculo_id_tipo_veiculo_seq'::text as sequencia FROM scr_tabelas_tipo_veiculo_id_tipo_veiculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_workflow_id_tabelas_workflow_seq'::text as sequencia FROM scr_tabelas_workflow_id_tabelas_workflow_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tipos_calculo_id_tipo_calculo_seq'::text as sequencia FROM scr_tipos_calculo_id_tipo_calculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_versao_edi_id_versao_edi_seq'::text as sequencia FROM scr_versao_edi_id_versao_edi_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_despesas_id_viagem_despesa_seq'::text as sequencia FROM scr_viagens_despesas_id_viagem_despesa_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_docs_id_viagem_doc_seq'::text as sequencia FROM scr_viagens_docs_id_viagem_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_fechamento_id_fechamento_seq'::text as sequencia FROM scr_viagens_fechamento_id_fechamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_id_viagem_seq'::text as sequencia FROM scr_viagens_id_viagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_log_atividades_id_viagens_log_atividade_seq'::text as sequencia FROM scr_viagens_log_atividades_id_viagens_log_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scripts_id_script_seq'::text as sequencia FROM scripts_id_script_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sec_groups_group_id_seq'::text as sequencia FROM sec_groups_group_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'servicos_integracao_id_seq'::text as sequencia FROM servicos_integracao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sys_avisos_id_aviso_seq'::text as sequencia FROM sys_avisos_id_aviso_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sys_relatorios_custom_id_sys_relatorio_seq'::text as sequencia FROM sys_relatorios_custom_id_sys_relatorio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sys_relatorios_id_sys_relatorio_seq'::text as sequencia FROM sys_relatorios_id_sys_relatorio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_acessorios_id_acessorio_seq'::text as sequencia FROM tb_acessorios_id_acessorio_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_check_id_categ_check_seq'::text as sequencia FROM tb_categ_check_id_categ_check_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_doc_id_categ_doc_seq'::text as sequencia FROM tb_categ_doc_id_categ_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_trans_id_categ_trans_seq'::text as sequencia FROM tb_categ_trans_id_categ_trans_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_veic_check_id_categ_veic_check_seq'::text as sequencia FROM tb_categ_veic_check_id_categ_veic_check_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_veic_doc_id_categ_veic_doc_seq'::text as sequencia FROM tb_categ_veic_doc_id_categ_veic_doc_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_categ_veic_id_categ_veic_seq'::text as sequencia FROM tb_categ_veic_id_categ_veic_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_check_id_check_seq'::text as sequencia FROM tb_check_id_check_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_combust_lub_id_combust_lub_seq'::text as sequencia FROM tb_combust_lub_id_combust_lub_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_combust_lub_itens_id_item_seq'::text as sequencia FROM tb_combust_lub_itens_id_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_compo_eve_id_cpt_eve_seq'::text as sequencia FROM tb_compo_eve_id_cpt_eve_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_compo_id_cpt_seq'::text as sequencia FROM tb_compo_id_cpt_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_compo_km_id_compo_km_seq'::text as sequencia FROM tb_compo_km_id_compo_km_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_doc_veic_id_doc_veic_seq'::text as sequencia FROM tb_doc_veic_id_doc_veic_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_eve_compo_id_eve_seq'::text as sequencia FROM tb_eve_compo_id_eve_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_ipva_id_ipva_seq'::text as sequencia FROM tb_ipva_id_ipva_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_mod_cpt_id_mod_cpt_seq'::text as sequencia FROM tb_mod_cpt_id_mod_cpt_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_pagamentos_id_pagamento_seq'::text as sequencia FROM tb_pagamentos_id_pagamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_servicos_id_servico_seq'::text as sequencia FROM tb_servicos_id_servico_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_tp_cpt_id_tp_cpt_seq'::text as sequencia FROM tb_tp_cpt_id_tp_cpt_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_veic_acess_id_veic_acess_seq'::text as sequencia FROM tb_veic_acess_id_veic_acess_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_veic_compo_id_veic_compo_seq'::text as sequencia FROM tb_veic_compo_id_veic_compo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tb_veic_km_id_veic_km_seq'::text as sequencia FROM tb_veic_km_id_veic_km_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tbl_aeroportos_id_aeroporto_seq'::text as sequencia FROM tbl_aeroportos_id_aeroporto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'teste_imagem_id_imagem_seq'::text as sequencia FROM teste_imagem_id_imagem_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'veiculos_marcas_id_marca_veiculo_seq'::text as sequencia FROM veiculos_marcas_id_marca_veiculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'veiculos_modelos_id_modelo_veiculo_seq'::text as sequencia FROM veiculos_modelos_id_modelo_veiculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'veiculos_tipos_id_tipo_veiculo_seq'::text as sequencia FROM veiculos_tipos_id_tipo_veiculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'totvs_condicoespagamento_id_seq'::text as sequencia FROM totvs_condicoespagamento_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'totvs_config_id_parametro_seq'::text as sequencia FROM totvs_config_id_parametro_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'totvs_formapagamento_id_seq'::text as sequencia FROM totvs_formapagamento_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'totvs_parametros_filial_id_seq'::text as sequencia FROM totvs_parametros_filial_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'totvs_produtos_id_seq'::text as sequencia FROM totvs_produtos_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'tracking_gps_id_seq'::text as sequencia FROM tracking_gps_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'usuarios_id_usuario_seq'::text as sequencia FROM usuarios_id_usuario_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'usuarios_permissoes_id_permissao_seq'::text as sequencia FROM usuarios_permissoes_id_permissao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'veiculos_id_veiculo_seq'::text as sequencia FROM veiculos_id_veiculo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'veic_atrelamento_id_atrelamento_seq'::text as sequencia FROM veic_atrelamento_id_atrelamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'ven_prop_id_ven_prop_seq'::text as sequencia FROM ven_prop_id_ven_prop_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'ven_prop_it_id_ven_prop_it_seq'::text as sequencia FROM ven_prop_it_id_ven_prop_it_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'vm_historicos_id_historico_seq'::text as sequencia FROM vm_historicos_id_historico_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'vm_login_id_login_seq'::text as sequencia FROM vm_login_id_login_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'vm_notas_acompanhamento_id_acompanhamento_seq'::text as sequencia FROM vm_notas_acompanhamento_id_acompanhamento_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'vm_notas_anexos_id_notas_anexo_seq'::text as sequencia FROM vm_notas_anexos_id_notas_anexo_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'vm_notas_id_nota_seq'::text as sequencia FROM vm_notas_id_nota_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'web_ctrc_caoa_id_lista_seq'::text as sequencia FROM web_ctrc_caoa_id_lista_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'web_ctrc_caoa_itens_id_lista_item_seq'::text as sequencia FROM web_ctrc_caoa_itens_id_lista_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'web_login_cd_id_web_login_seq'::text as sequencia FROM web_login_cd_id_web_login_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'web_login_cd_log_id_log_web_login_seq'::text as sequencia FROM web_login_cd_log_id_log_web_login_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'web_login_redespacho_id_redespacho_seq'::text as sequencia FROM web_login_redespacho_id_redespacho_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'webtrack_login_id_webtrack_login_seq'::text as sequencia FROM webtrack_login_id_webtrack_login_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_imagens_base64_id_seq'::text as sequencia FROM scr_imagens_base64_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'crm_contatos_seq'::text as sequencia FROM crm_contatos_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_romaneio_coletas_001_001'::text as sequencia FROM col_romaneio_coletas_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_id_seq'::text as sequencia FROM bi_dashboards_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_usuarios_id_seq'::text as sequencia FROM bi_dashboards_usuarios_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_widgets_id_seq'::text as sequencia FROM bi_dashboards_widgets_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_datasource_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_datasource_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_order_by_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_order_by_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_group_by_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_group_by_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_filters_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_filters_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_filter_types_pk_id_seq'::text as sequencia FROM bi_dashboards_filter_types_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_filter_types_function_pk_id_seq'::text as sequencia FROM bi_dashboards_filter_types_function_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_operators_pk_id_seq'::text as sequencia FROM bi_dashboards_operators_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_geral_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_geral_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_tile_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_tile_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_gauge_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_gauge_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_sparkline_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_sparkline_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_datatable_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_datatable_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_datatable_sparkline_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_datatable_sparkline_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_barline_values_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_barline_values_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_ui_options_barline_pk_id_seq'::text as sequencia FROM bi_dashboards_ui_options_barline_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_type_sparklines_pk_id_seq'::text as sequencia FROM bi_dashboards_type_sparklines_pk_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'bi_dashboards_itens_id_seq'::text as sequencia FROM bi_dashboards_itens_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_rodoviario_s0_001_001_seq'::text as sequencia FROM scr_conhecimento_rodoviario_s0_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_emissao_rodoviario_s0___seq'::text as sequencia FROM scr_conhecimento_emissao_rodoviario_s0___seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabelas_001_001_seq'::text as sequencia FROM scr_tabelas_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_rodoviario_s1_001_001_seq'::text as sequencia FROM scr_conhecimento_rodoviario_s1_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_minuta_rodoviario_001_001_seq'::text as sequencia FROM scr_minuta_rodoviario_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_emissao_rodoviario_s1___seq'::text as sequencia FROM scr_conhecimento_emissao_rodoviario_s1___seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_minuta_emissao_rodoviario___seq'::text as sequencia FROM scr_minuta_emissao_rodoviario___seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_conta_corrente_001_seq'::text as sequencia FROM scf_conta_corrente_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_contas_pagar_001_001_seq'::text as sequencia FROM scf_contas_pagar_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_faturamento_codigo_faturamento_001_001'::text as sequencia FROM scr_faturamento_codigo_faturamento_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_comissoes_id_manifesto_comissoes_seq'::text as sequencia FROM scr_manifesto_comissoes_id_manifesto_comissoes_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_tipo_id_tipo_manifesto_seq'::text as sequencia FROM scr_manifesto_tipo_id_tipo_manifesto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_pedido_001_001'::text as sequencia FROM com_compras_pedido_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'col_coletas_001_001'::text as sequencia FROM col_coletas_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_nf_001_001_1'::text as sequencia FROM com_nf_001_001_1 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_notas_fiscais_a_imp_id_nfe_seq'::text as sequencia FROM scr_notas_fiscais_a_imp_id_nfe_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_001_001'::text as sequencia FROM frt_ab_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_viagens_001_001'::text as sequencia FROM scr_viagens_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_os_001_001'::text as sequencia FROM frt_os_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_solicitacao_001_001'::text as sequencia FROM com_compras_solicitacao_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'captcha_creditos_id_captcha_credito_seq'::text as sequencia FROM captcha_creditos_id_captcha_credito_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_tabela_motorista_001_001_seq'::text as sequencia FROM scr_tabela_motorista_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_mdfe_001_001_seq'::text as sequencia FROM scr_mdfe_001_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'id_manifesto_docs_seq'::text as sequencia FROM id_manifesto_docs_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_docs_id_manifesto_docs_seq'::text as sequencia FROM scr_manifesto_docs_id_manifesto_docs_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'modulos_sistema_permissoes_limite_id_permissao_limite_seq'::text as sequencia FROM modulos_sistema_permissoes_limite_id_permissao_limite_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'usuarios_permissoes_limite_id_usuario_permissao_limite_seq'::text as sequencia FROM usuarios_permissoes_limite_id_usuario_permissao_limite_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_produtos_codigo_produto_seq'::text as sequencia FROM com_produtos_codigo_produto_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'com_compras_001_001'::text as sequencia FROM com_compras_001_001 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_conta_caixa_001_seq'::text as sequencia FROM scf_conta_caixa_001_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_conhecimento_qrcode_id_conhecimento_qrcode_id_seq'::text as sequencia FROM scr_conhecimento_qrcode_id_conhecimento_qrcode_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_qrcode_id_manifesto_qrcode_id_seq'::text as sequencia FROM scr_manifesto_qrcode_id_manifesto_qrcode_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_fiscal_bloco_ecf_id_seq'::text as sequencia FROM efd_fiscal_bloco_ecf_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'efd_fiscal_produtos_ecf_id_seq'::text as sequencia FROM efd_fiscal_produtos_ecf_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ocorrencias_track3r_id_seq'::text as sequencia FROM scr_ocorrencias_track3r_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'cliente_ie_id_seq'::text as sequencia FROM cliente_ie_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_tq_log_id_tq_log_seq'::text as sequencia FROM frt_tq_log_id_tq_log_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_conta_caixa_003_seq'::text as sequencia FROM scf_conta_caixa_003_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scf_conta_corrente_003_seq'::text as sequencia FROM scf_conta_corrente_003_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ciot_id_ciot_seq'::text as sequencia FROM scr_ciot_id_ciot_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ciot_erros_id_seq'::text as sequencia FROM scr_ciot_erros_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fila_documentos_integracoes_id_seq'::text as sequencia FROM fila_documentos_integracoes_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'impostos_fornecedor_id_seq'::text as sequencia FROM impostos_fornecedor_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'imposto_aliquotas_id_seq'::text as sequencia FROM imposto_aliquotas_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'api_integracao_id_seq'::text as sequencia FROM api_integracao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'filial_sub_id_filial_sub_seq'::text as sequencia FROM filial_sub_id_filial_sub_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_operacao_diaria_id_operacao_diaria_seq'::text as sequencia FROM frt_operacao_diaria_id_operacao_diaria_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'filial_veic_id_filial_veic_seq'::text as sequencia FROM filial_veic_id_filial_veic_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_operacao_id_operacao_seq'::text as sequencia FROM frt_operacao_id_operacao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_tipo_atividades_id_tipo_atividade_seq'::text as sequencia FROM frt_tipo_atividades_id_tipo_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_atividades_id_atividade_seq'::text as sequencia FROM frt_atividades_id_atividade_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_operacao_inspecao_id_operacao_inspecao_seq'::text as sequencia FROM frt_operacao_inspecao_id_operacao_inspecao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_tipo_inspecao_itens_id_tipo_inspecao_item_seq'::text as sequencia FROM frt_tipo_inspecao_itens_id_tipo_inspecao_item_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_romaneio_averbacao_id_seq'::text as sequencia FROM scr_romaneio_averbacao_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_operacao_diaria_inspecao_id_operacao_diaria_inspecao_seq'::text as sequencia FROM frt_operacao_diaria_inspecao_id_operacao_diaria_inspecao_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mov_veic_unid_id_mov_seq'::text as sequencia FROM frt_mov_veic_unid_id_mov_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_mov_filial_veic_id_mov_seq'::text as sequencia FROM frt_mov_filial_veic_id_mov_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fila_envio_app_id_seq'::text as sequencia FROM fila_envio_app_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'fila_nf_app_log_id_seq'::text as sequencia FROM fila_nf_app_log_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_app_uuid_id_seq'::text as sequencia FROM scr_app_uuid_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_ocorrencias_docfinder_id_seq'::text as sequencia FROM scr_ocorrencias_docfinder_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_manifesto_vale_pedagio_id_manifesto_vp_seq'::text as sequencia FROM scr_manifesto_vale_pedagio_id_manifesto_vp_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'edi_romaneios_id_seq'::text as sequencia FROM edi_romaneios_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_dados_aplicativo_id_seq'::text as sequencia FROM frt_dados_aplicativo_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'sped_cta_id_seq'::text as sequencia FROM sped_cta_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'log_faixa_bairro_id_seq'::text as sequencia FROM log_faixa_bairro_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'v_bairros_cep_id_seq'::text as sequencia FROM v_bairros_cep_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_ab_id_seq'::text as sequencia FROM scr_relatorio_viagem_ab_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_epta_sga_id_seq'::text as sequencia FROM frt_ab_epta_sga_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_epta_sga_tp_mat_id_seq'::text as sequencia FROM frt_ab_epta_sga_tp_mat_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_epta_sga_bomba_id_seq'::text as sequencia FROM frt_ab_epta_sga_bomba_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'frt_ab_epta_sga_posto_id_seq'::text as sequencia FROM frt_ab_epta_sga_posto_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_os_id_seq'::text as sequencia FROM scr_relatorio_viagem_os_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
WITH t AS (

		SELECT last_value, 'scr_relatorio_viagem_contas_pagar_id_seq'::text as sequencia FROM scr_relatorio_viagem_contas_pagar_id_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;
