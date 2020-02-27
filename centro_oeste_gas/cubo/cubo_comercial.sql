--DELETE FROM bi_cubos WHERE cubo_identificador = 'faturamento';
--SELECT * FROM bi_cubos
--SELECT bi_insere_cubo();
SELECT bi_insere_cubo('comercial','Comercial/NFe/NFCe','SoftLog BI - Análise de Vendas','FROM v_com_nf_cubo',NULL,NULL,NULL,'data');

-- INSERE COLUNAS
-- SELECT bi_insere_coluna('cubo','nome_coluna','sql');
SELECT bi_insere_coluna('comercial','codigo_empresa','codigo_empresa');
SELECT bi_insere_coluna('comercial','codigo_filial','codigo_filial');
SELECT bi_insere_coluna('comercial','modelo_doc_fiscal','modelo_doc_fiscal');
SELECT bi_insere_coluna('comercial','numero_documento','numero_documento');
SELECT bi_insere_coluna('comercial','data_emissao','data_emissao');
SELECT bi_insere_coluna('comercial','cstat','cstat');
SELECT bi_insere_coluna('comercial','id_produto','id_produto');
SELECT bi_insere_coluna('comercial','quantidade','quantidade');
SELECT bi_insere_coluna('comercial','vl_item','vl_item');
SELECT bi_insere_coluna('comercial','vl_desconto','vl_desconto');
SELECT bi_insere_coluna('comercial','vl_total','vl_total');
SELECT bi_insere_coluna('comercial','vl_total_produto','vl_total_produto');
SELECT bi_insere_coluna('comercial','cst_icms','cst_icms');
SELECT bi_insere_coluna('comercial','cfop','cfop');
SELECT bi_insere_coluna('comercial','mes','mes');
SELECT bi_insere_coluna('comercial','ano','ano');
SELECT bi_insere_coluna('comercial','semana','semana');
SELECT bi_insere_coluna('comercial','trimestre','trimestre');
SELECT bi_insere_coluna('comercial','dia','dia');
SELECT bi_insere_coluna('comercial','data','data');
SELECT bi_insere_coluna('comercial','mes_ano','mes_ano');
SELECT bi_insere_coluna('comercial','id_filial','id_filial');
SELECT bi_insere_coluna('comercial','cnpj','cnpj');


-- INSERE DIMENSOES
-----------------------------------------------------------------------------------------------------------------
--SELECT bi_insere_dimensao(p_cubo_identificador, 
-- 	p_coluna_identificador,
-- 	p_dimensao_identificador,
-- 	p_titulo,
-- 	p_tipo_dimensao,
-- 	p_sql_text,
-- 	p_keyField,
-- 	p_lookupField,
-- 	p_parentField,
-- 	p_dimensao_toolbar,
-- 	p_sorting,
-- 	p_wrapto,
-- 	p_forecastingenabled,
-- 	p_forecastingmethod,
-- 	p_precedingName,
-- 	p_consequentName)

SELECT bi_insere_dimensao('comercial','codigo_empresa','empresa','Empresa',2,'SELECT codigo_empresa,razao_social FROM empresa','codigo_empresa','razao_social',NULL,0,2,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','id_filial','filial','Filial',2,'SELECT id_filial,  filial FROM v_filial_cubo','id_filial','filial',NULL,0,2,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','id_produto','id_produto','COD.Prod.',0,NULL,NULL,NULL,NULL,0,1,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','id_produto','produto','Produto',2,'SELECT id_produto, produto FROM v_com_nf_produtos_cubo order by produto','id_produto','produto',NULL,0,2,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','data','data','Data Emissão',0,NULL,NULL,NULL,NULL,0,1,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','data','ano','Ano',0,NULL,NULL,NULL,NULL,0,2,1,0,0,'Ano Anterior','Próximo Ano');
SELECT bi_insere_dimensao('comercial','data','mes','Mês',0,NULL,NULL,NULL,NULL,0,2,2,0,0,'Mês Anterior','Próximo Mês');
SELECT bi_insere_dimensao('comercial','mes_ano','mes_ano','Mês/Ano',2,'SELECT mes_ano_chave(data_emissao::date) as mes_ano_chave,  mes_ano_extenso(mes_ano_chave(data_emissao::date)) as mes_ano_extenso FROM v_com_nf_cubo GROUP BY mes_ano_chave(data_emissao::date) ORDER BY 1','mes_ano_chave','mes_ano_extenso',NULL,0,1,NULL,0,0,'Anterior','Próximo');
SELECT bi_insere_dimensao('comercial','data','dia','Dia',0,NULL,NULL,NULL,NULL,0,2,3,0,0,'Dia Anterior','Próximo Dia');
SELECT bi_insere_dimensao('comercial','semana','semana','Semana',0,NULL,NULL,NULL,NULL,0,2,NULL,0,0,'Semana Anterior','Próxima Semana');
--SELECT bi_insere_dimensao('comercial','trimestre','trimestre2','Trimestre',0,NULL,NULL,NULL,NULL,0,2,3,0,0,'Trimestre Anterior','Trimestre Dia');
SELECT bi_insere_dimensao('comercial','cfop','cfop','CFOP',2,'SELECT codigo_cfop, (codigo_cfop || '' - '' || trim(initcap(descricao_cfop))) as descricao_cfop FROM cfop','codigo_cfop','descricao_cfop',NULL,0,1,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','cnpj','cnpj','CNPJ',0,NULL,NULL,NULL,NULL,0,1,NULL,0,0,NULL,NULL);
SELECT bi_insere_dimensao('comercial','modelo_doc_fiscal','modelo_doc_fiscal','Tipo Doc.',0,NULL,NULL,NULL,NULL,0,1,NULL,0,0,NULL,NULL);


--SELECT * FROM v_com_nf_cubo ORDER BY 1 LIMIT 10
--SELECT * FROM cfop
--SELECT * FROM filial
--SELECT * FROM bi_cubo_dimensoes  WHERE cubo_identificador = 'comercial'
--DELETE FROM bi_cubo_dimensoes WHERE id_cubo_dimensao = 141
-----------------------------------------------------------------------------------------------------------------
-- INSERE MEDIDAS
-- SELECT bi_insere_medida(
-- 	p_cubo_identificador,
-- 	p_coluna_identificador,
-- 	p_medida_identificador,
-- 	p_titulo,
-- 	p_tipo_calculo,
-- 	p_tipo_data,
-- 	p_formato_string,

SELECT bi_insere_medida('comercial','vl_total_produto','vl_total_produto','Vl.Produtos',0,6,'###,###,##0.00');
SELECT bi_insere_medida('comercial','vl_desconto','vl_desconto','Desconto',0,6,'###,###,##0.00');
SELECT bi_insere_medida('comercial','vl_total','vl_total','Valor Total',0,6,'###,###,##0.00');
SELECT bi_insere_medida('comercial','quantidade','quantidade','Quant.',0,6,'###,###,##0.00');

--SELECT trim((string_to_array('CENTRO OESTE GAS - ITAPACI','-'))[2])