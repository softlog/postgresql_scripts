--- Dashboard de Exemplo
--SELECT * FROM bi_dashboards_itens
--DELETE FROM bi_dashboards_itens
--DELETE FROM bi_dashboards WHERE id = 24


--SELECT * FROM bi_dashboards
--DELETE FROM bi_dashboards WHERE id = 4

--DELETE FROM bi_dashboards_usuarios
--xs, sm, md, lg

--SELECT cstat FROM v_dashboard_conhecimento GROUP BY cstat
-- Tiles
--SELECT f_bi_dashboard_item('dash_exptms_2_mensal_05',4,20,10,'Fretes sem Valor','tiles',6,4,2,2,0,0,0,'row tile_count',null,null,'0',null,'v_scr_',null,null::json,null::json);
--SELECT f_bi_dashboard_item('dash_exptms_2_mensal_06',4,20,10,'Docs Não Autorizados','tiles',6,4,2,2,0,0,0,'row tile_count',null,null,'0',null,'v_scr_',null,null::json,null::json);

--
/*
DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_11';
DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_12';
DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_13';
DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_14';
*/

SELECT f_bi_dashboard(23, 'dash_exptms_2_mensal', '04 - Expedição - Mensal',NULL,'Expedição');

-- GAUGES
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_01',23,40,10,'Frete de NFe Importada','gaugejs',12,4,4,4,0,0,0,'row',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_02',23,40,20,'Conhecimentos Emitidos','gaugejs',12,4,4,4,0,0,0,'row',null,null,'0',null,'v_dashboard_conhecimento_2',null,null::json,null::json);
--SELECT f_bi_dashboard_item('dash_exptms_2_mensal_03',20,40,30,'Conhecimentos Manifestados','gaugejs',6,6,3,3,0,0,0,'row',null,null,'0',null,'v_dashboard_conhecimento_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_04',23,40,30,'Notas Romaneadas','gaugejs',12,4,4,4,0,0,0,'row',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);

SELECT f_bi_dashboard_item('dash_exptms_2_mensal_11',23,20,10,'Romaneios','tiles',6,3,3,3,0,0,0,'row tile_count',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_12',23,20,20,'NFes','tiles',6,3,3,3,0,0,0,'row tile_count',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_13',23,20,30,'Peso','tiles',6,3,3,3,0,0,0,'row tile_count',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_14',23,20,40,'Volumes','tiles',6,3,3,3,0,0,0,'row tile_count',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
-- 
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_05',23,50,10,'NFe Romaneadas','barline_chartjs',12,6,6,6,0,0,0,'row',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_exptms_2_mensal_06',23,50,20,'NFe c/Conhecimentos','barline_chartjs',12,6,6,6,0,0,0,'row',null,null,'0',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);

-- SELECT f_bi_dashboard_item('dash_exptms_2_mensal_07',20,30,10,'Total NFes','sparkline_bar',6,3,3,3,0,0,0,'row tile_count',null,'margin: 10px 0;','1',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);SELECT f_bi_dashboard_item('dash_exptms_2_mensal_08',20,30,20,'Total Frete','sparkline_line',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','1',null,'v_dashboard_conhecimento_2',null,null::json,null::json);
-- SELECT f_bi_dashboard_item('dash_exptms_2_mensal_09',20,30,30,'Total Peso','sparkline_bar',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','1',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);
-- SELECT f_bi_dashboard_item('dash_exptms_2_mensal_10',20,30,40,'Total Volumes','sparkline_line',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','1',null,'v_dashboard_notas_fiscais_2',null,null::json,null::json);


--DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_06'
-- Tables
--SELECT * FROM bi_dashboards_ui_filters

--------------------------------------------------------------------------------
-- TILES - Total Emissões Dia
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "tem_romaneio",
				    "format": null,
				    "formula":"SUM"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",
				    "format": "YYYY-MM",
				    "formula":null
				}
			
			],		
			"group_by": [
				"date"							
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
					
			]		
		},			
		"options":{
			"name_class":"dash_exptms_2_mensal_11",
	                "title":"NFes Rom.Mês",
			"title_icon":"fa-dashboard",
			"field_value":"tem_romaneio",
			"value_color":"green",
			"value_type":null,
			"force_scale_value":1,
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",
			"value_msg":"3%",			
			"msg":"ao mês passado",
			"has_variant":1
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}		

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_11';

--------------------------------------------------------------------------------
-- TILES - Total Frete Dia
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "importada",
				    "format": "YYYY-MM",
				    "formula":"SUM"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",
				    "format": "YYYY-MM",
				    "formula":null
				}
			],		
			"group_by": [
				"date"							
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
					
			]		
		},			
		"options":{
			"name_class":"dash_exptms_2_mensal_12",
	                "title":"NFes Mês",
			"title_icon":"fa-dashboard",
			"field_value":"importada",
			"value_color":"green",
			"value_type":null,
			"force_scale_value":1,
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",
			"value_msg":"3%",			
			"msg":"ao mês passado",
			"has_variant":1
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_12';

--------------------------------------------------------------------------------
-- TILES - Total Peso Dia
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "peso",
				    "format": null,
				    "formula":"SUM"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",	
				    "format": "YYYY-MM",			    
				    "formula":null
				}
			],		
			"group_by": [
				"date"							
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
					
			]		
		},			
		"options":{
			"name_class":"dash_exptms_2_mensal_13",
	                "title":"Total Peso Mês",
			"title_icon":"fa-dashboard",
			"field_value":"peso",
			"value_color":"green",
			"value_type":null,
			"force_scale_value":1,
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",
			"msg":"ao mês passado",
			"has_variant":1
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_13';

--------------------------------------------------------------------------------
-- TILES - Total Volumes Dia
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "qtd_volumes",
				    "format": null,
				    "formula":"SUM"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",	
				    "format": "YYYY-MM",			    
				    "formula":null
				}
			],		
			"group_by": [
				"date"							
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
					
			]		
		},			
		"options":{
			"name_class":"dash_exptms_2_mensal_14",
	                "title":"Total Volumes Mês",
			"title_icon":"fa-dashboard",
			"field_value":"qtd_volumes",
			"value_color":"green",
			"value_type":null,
			"force_scale_value":1,
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",
			"value_msg":"3%",			
			"msg":"ao mês passado",
			"has_variant":1
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_14';		

-- GAUGE Notas Fiscais para Gerar Frete
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"total",
			    "field": "id_nota_fiscal_imp",
			    "format": null,
			    "formula":"COUNT"
			},
			{
			    "id":"atual",
			    "field": "status",
			    "format": null,
			    "formula":"SUM"
			}	
		    ]		    
		},			
		"options":{
				"name_class":"dash_exptms_2_mensal_01",
				"title":"NFes Mês",
				"label":"Frete Calculado",
				"field_value":"atual",
				"field_goal": "value",
				"left_value":"",
				"rigth_value":"",
				"title_icon":"fa-dashboard",
				"scale_number":"K",
				"panel":"1"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}		
		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_01';

-- GAUGE Conhecimentos Emitidos
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"total",
			    "field": "id_conhecimento",
			    "format": null,
			    "formula":"COUNT"
			},
			{
			    "id":"atual",
			    "field": "emitido",
			    "format": null,
			    "formula":"SUM"
			}		
		    ]		    
		},			
		"options":{
				"name_class":"dash_exptms_2_mensal_02",
				"title":"Conhecimento Emitidos Mês",
				"label":"Emitidos",
				"field_value":"atual",
				"field_goal": "value",
				"left_value":"",
				"rigth_value":"",
				"title_icon":"fa-dashboard",
				"scale_number":"K",
				"panel":"1"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_02';


--DELETE FROM bi_dashboards_itens WHERE code_item = 'dash_exptms_2_mensal_05'

-- GAUGE Conhecimentos Romaneados
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"total",
			    "field": "id_nota_fiscal_imp",
			    "format": null,
			    "formula":"COUNT"
			},
			{
			    "id":"atual",
			    "field": "tem_romaneio",
			    "format": null,
			    "formula":"SUM"
			}		
		    ]		    
		},			
		"options":{
				"name_class":"dash_exptms_2_mensal_04",
				"title":"NFe Romaneada Mês",
				"label":"Tem Romaneio",
				"field_value":"atual",
				"field_goal": "value",
				"left_value":"",
				"rigth_value":"",
				"title_icon":"fa-dashboard",
				"scale_number":"K",
				"panel":"1"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_04';





--Notas Fiscais Romaneadas
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
			"data_source": {
			"fields_list" : [{
					"id" : "data_expedicao",
					"field" : "data_expedicao",
					"format" : "DD"
				}, 
				{
					"id" : "id_nota_fiscal_imp",
					"field" : "id_nota_fiscal_imp",				
					"format" : null,
					"formula" : "COUNT"
				},
				{
					"id" : "tem_romaneio",
					"field" : "tem_romaneio",					
					"format" : null,
					"formula" : "SUM"
				}

			],
			"group_by" : [
				"data_expedicao"
			],
			"order_by" : [{
					"field" : "data_expedicao",
					"order" : "ASC"
				}
			]
		},	
		"label": {
			"field":"data_expedicao"			
		},
		"values":[
			{
				"field":"tem_romaneio",
				"color":"#26B99A",
				"label":"Tem Romaneio",
				"type":"line"
			},		
			{
				"field":"id_nota_fiscal_imp",
				"color":"#03586A",
				"label":"Total NFe",
				"type":"bar"
			}
		],
		"options":{
				"legend":false,
				"name_class":"chart_barline_1",
				"title":"NFes Romaneadas Mês",
				"scale":"K",
				"heigth":"200"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date-time",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_05';

--Notas Fiscais com Conhecimento
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
			"data_source": {
			"fields_list" : [{
					"id" : "data_expedicao",
					"field" : "data_expedicao",
					"format" : "DD"
				}, 
				{
					"id" : "id_nota_fiscal_imp",
					"field" : "id_nota_fiscal_imp",				
					"format" : null,
					"formula" : "COUNT"
				},
				{
					"id" : "tem_conhecimento",
					"field" : "tem_conhecimento",
					"format" : null,
					"formula" : "SUM"
				}

			],
			"group_by" : [
				"data_expedicao"
			],
			"order_by" : [{
					"field" : "data_expedicao",
					"order" : "ASC"
				}
			]
		},	
		"label": {
			"field":"data_expedicao"			
		},
		"values":[
			{
				"field":"tem_conhecimento",
				"color":"#26B99A",
				"label":"Tem CTe",
				"type":"line"
			},		
			{
				"field":"id_nota_fiscal_imp",
				"color":"#03586A",
				"label":"Total NFe",
				"type":"bar"
			}
		],
		"options":{
				"legend":false,
				"name_class":"chart_barline_2",
				"title":"NFes c/CTe Mês",
				"scale":"K",
				"heigth":"200"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date-time",
				"type_function":"month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_06';

/*

SELECT f_bi_dashboard_item('dash_01_02',1,1,2,'Tiles 2','tiles',6,4,2,2,0,0,0,'row tile_count',null,null,'0',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_03',1,2,1,'SparkLine 1','sparkline_bar',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','1',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_04',1,2,2,'SparkLine 2','sparkline_line',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','0',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_08',1,2,3,'SparkLine 3','sparkline_line',6,3,3,3,0,0,0,'row top_tiles',null,'margin: 10px 0;','0',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_05',1,3,1,'Gauge 1','gaugejs',12,6,4,3,0,0,0,'row',null,null,'1',null,'v_dashboard_notas_fiscais',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_06',1,4,1,'ChartJs Bar','bar_chartjs',12,6,6,6,0,0,0,'row',null,null,'1',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_07',1,4,2,'ChartJs Bar','bar_chartjs',12,6,6,6,0,0,0,'row',null,null,'1',null,'v_dashboard_conhecimento',null,null::json,null::json);
SELECT f_bi_dashboard_item('dash_01_09',1,3,2,'ChartJs Bar','barline_chartjs',12,6,4,4,0,0,0,'row',null,null,'1',null,'v_dashboard_conhecimento',null,null::json,null::json);
--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "total_frete",
				    "format": null,
				    "formula":"SUM"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",
				    "format": null,
				    "formula":null
				}
			],		
			"group_by": [
				"date"							
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
					
			]		
		},			
		"options":{
			"name_class":"tiles_1",
	                "title":"Total de Frete",
			"title_icon":"fa-dashboard",
			"field_value":"total_frete",
			"value_color":"green",
			"value_type":null,
			"force_scale_value":1,
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",
			"value_msg":"3%",			
			"msg":"Nesta data de expedição"
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"date",
				"operator":"last",
				"value":"2"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_01_01';

--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"value",
				    "field": "id_conhecimento",
				    "format": null,
				    "formula":"COUNT"
				},
				{
				    "id":"date",
				    "field": "data_expedicao",
				    "format": null,
				    "formula":null
				}
			],		
			"group_by": [
				"date"			
			],
			"order_by": [
				{
					"field":"date",
					"order":"ASC"
				}
			]		
		},			
		"options":{
			"name_class":"tiles_2",
	                "title":"Total de Emissões",
			"title_icon":"fa-dashboard",
			"field_value":"total_frete",
			"force_scale_value":1,
			"value_color":"green",
			"msg_color":"green",
			"msg_icon":"fa-sort-asc",			
			"value_msg":"",			
			"msg":"Nesta data de expedição"
		}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"date",
				"operator":"last",
				"value":"2"
			},
						{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		
		]
	}'::json
WHERE 
	code_item = 'dash_01_02';

--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"date",
			    "field": "data_expedicao",
			    "format": null,
			    "casting":"date"	 
			},
			{
			    "id":"values",
			    "field": "id_conhecimento",
			    "format": null,
			    "formula":"COUNT"
			}		
		    ],
		    "group_by": [
			"date"			
		    ],
			"order_by":[
				{
					"field":"date",
					"order":"ASC"
				}
			]
		},	
		"options":{				
				
				"name_class":"sparkline_1",
				"title":"Emissões Mês Atual",
				"height":"160px"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"year-month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"data_emissao",
				"type":"date",
				"type_function":"date",
				"operator":"not_null",
				"value":null
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			},
			{
				"field":"cancelado",
				"type":"numeric",			
				"operator":"=",
				"value":"0"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_03';

--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"date",
			    "field": "data_expedicao",
			    "format": null,
			    "casting":"date"	 
			},
			{
			    "id":"values",
			    "field": "total_frete",
			    "format": null,
			    "formula":"SUM"
			}		
		    ],
		    "group_by": [
			"date"			
		    ],
   		   "order_by":[
				{
					"field":"date",
					"order":"ASC"
				}
			]
		   },	
      		   "options":{				
				
				"name_class":"sparkline_2",
				"title":"Total Frete Mês Atual",
				"height":"160px",
				"force_scale_value":1,
				"value_type":null
			}
			
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"year-month",
				"operator":"last",
				"value":"1"
			},
			{
				"field":"data_emissao",
				"type":"date",
				"type_function":"date",
				"operator":"not_null",
				"value":null
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			},
			{
				"field":"cancelado",
				"type":"numeric",			
				"operator":"=",
				"value":"0"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_04';

--------------------------------------------------------------------------------

UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"total",
			    "field": "id_nota_fiscal_imp",
			    "format": null,
			    "formula":"COUNT"
			},
			{
			    "id":"atual",
			    "field": "status",
			    "format": null,
			    "formula":"SUM"
			}		
		    ]		    
		},			
		"options":{
				"name_class":"gauge_1",
				"title":"NFes Processadas",
				"label":"Testando",
				"field_value":"atual",
				"field_goal": "value",
				"left_value":"",
				"rigth_value":"",
				"title_icon":"fa-dashboard",
				"scale_number":"K",
				"panel":"1"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"date",
				"operator":"last",
				"value":"2"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}		
		]
	}'::json
WHERE 
	code_item = 'dash_01_05';
	
--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"data_emissao",
			    "field": "data_emissao",
			    "format": "TMmon/YY"
			},
			{
			    "id":"data_emissao_aux",
			    "field": "data_emissao",
			    "format": "YYYYMM",
			    "casting": "bigint"
			},
			{
			    "id":"total_frete",
			    "field": "total_frete",
			    "format": null,
			    "formula":"SUM"
			}
		
		    ],
		    "group_by": [
			"data_emissao",
			"data_emissao_aux"
		    ],
			"order_by":[
				{
					"field":"data_emissao_aux",
					"order":"ASC"
				}
			]
		},	
		"label": {
			"field":"data_emissao"			
		},
		"values":[
			{
				"field":"total_frete",
				"color":"#26B99A",
				"label":"Total Frete"
			}		
		],
		"options":{
				"legend":false,
				"name_class":"chart_bar_1",
				"title":"Total de Fretes 6 Últimos Meses",
				"scale":"K"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_emissao",
				"type":"date-time",
				"type_function":"year-month",
				"operator":"last",
				"value":"6"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_06';

--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"data_emissao",
			    "field": "data_emissao",
			    "format": "TMmon/YY"
			},
			{
			    "id":"data_emissao_aux",
			    "field": "data_emissao",
			    "format": "YYYYMM",
			    "casting": "bigint"
			},
			{
			    "id":"total_notas",
			    "field": "valor_nota_fiscal",
			    "format": null,
			    "formula":"SUM"
			}
		
		    ],
		    "group_by": [
			"data_emissao",
			"data_emissao_aux"
		    ],
			"order_by":[
				{
					"field":"data_emissao_aux",
					"order":"ASC"
				}
			]
		},	
		"label": {
			"field":"data_emissao"			
		},
		"values":[
			{
				"field":"total_notas",
				"color":"#26B99A",
				"label":"Total Valor Notas"
			}		
		],
		"options":{
				"legend":false,
				"name_class":"chart_bar_2",
				"title":"Valor Total das Notas dos 6 Últimos Meses",
				"scale":"M"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_emissao",
				"type":"date-time",
				"type_function":"year-month",
				"operator":"last",
				"value":"6"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_07';
--------------------------------------------------------------------------------	
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
		    "fields_list":[
			{
			    "id":"date",
			    "field": "data_expedicao",
			    "format": "TMmon/YY"
			},		
			{
			    "id":"values",
			    "field": "total_frete",
			    "format": null,
			    "formula":"SUM"
			},
			{
			    "id":"data_expedicao_aux",
			    "field": "data_expedicao",
			    "format": "YYYYMM",
			    "casting": "bigint"
			}		
		    ],
		    "group_by": [
			"date",
			"data_expedicao_aux"
		    ],
			"order_by":[
				{
					"field":"data_expedicao_aux",
					"order":"ASC"
				}
			]
		},	
		"options":{				
				
				"name_class":"sparkline_3",
				"title":"T.Frete 12 Últ.Meses",
				"height":"160px",
				"force_scale_value":1,
				"value_type":null
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"year-month",
				"operator":"last",
				"value":"12"
			},
			{
				"field":"data_emissao",
				"type":"date",
				"type_function":"date",
				"operator":"not_null",
				"value":null
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},			
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			},
			{
				"field":"cancelado",
				"type":"numeric",			
				"operator":"=",
				"value":"0"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_08';

--------------------------------------------------------------------------------
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
			"data_source": {
			"fields_list" : [{
					"id" : "data_emissao",
					"field" : "data_emissao",
					"format" : "TMMon/YY"
				}, {
					"id" : "data_emissao_aux",
					"field" : "data_emissao",
					"format" : "YYYY-MM"
				}, 
				{
					"id" : "total_frete",
					"field" : "total_frete",				
					"format" : null,
					"formula" : "SUM"
				},
				{
					"id" : "frete_ideal",
					"field" : "valor_nota_fiscal",
					"percentual" : "0.02",
					"format" : null,
					"formula" : "SUM"
				}

			],
			"group_by" : [
				"data_emissao",
				"data_emissao_aux"
			],
			"order_by" : [{
					"field" : "data_emissao_aux",
					"order" : "ASC"
				}
			]
		},	
		"label": {
			"field":"data_emissao"			
		},
		"values":[
			{
				"field":"frete_ideal",
				"color":"#26B99A",
				"label":"Meta",
				"type":"line"
			},		
			{
				"field":"total_frete",
				"color":"#03586A",
				"label":"Total Frete",
				"type":"bar"
			}
		],
		"options":{
				"legend":false,
				"name_class":"chart_barline_1",
				"title":"Total de Fretes 6 Últimos Meses",
				"scale":"K",
				"heigth":"200"
			}		
		
	}'::json,
	filters = '{
		"filters":[
			{
				"field":"data_emissao",
				"type":"date-time",
				"type_function":"year-month",
				"operator":"last",
				"value":"6"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_01_09';



	-- Data Table: Fretes sem Valor
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"numero_ctrc_filial",
				    "field": "numero_ctrc_filial",
				    "format": null,
				    "formula":null
				},
				{
				    "id":"data_emissao",
				    "field": "data_emissao",
				    "format": "DD/MM/YYYY",
				    "formula":null
				},
				{
				    "id":"tipo_documento",
				    "field": "tipo_documento",
				    "format": null,
				    "formula":null
				}
			],		
			"order_by": [
					{
						"field": "numero_ctrc_filial",
						"order": "ASC"
					}
			]
		},			
		"data":[
			{
				"field":"numero_ctrc_filial",
				"label":"Número ",
				"format":null
			},
			{
				"field":"data_emissao",
				"label":"Data",
				"format":null
			},
			{
				"field":"tipo_transporte",
				"label":"Tipo Transporte",
				"format":null
			}
		],
		"options":{				
				
				"name_class":"dash_exptms_2_mensal_05",
				"title":"Fretes Zerados",
				"height":"160px"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"date",
				"operator":"last",
				"value":"2"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			},
			{
				"field":"cancelado",
				"type":"numeric",			
				"operator":"=",
				"value":"0"
			},
			{
				"field":"total_frete",
				"type":"numeric",			
				"operator":"=",
				"value":"0"
			}

		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_05';




-- Data Table: Fretes com pendencias SEFAZ
UPDATE bi_dashboards_itens SET 
	def_conf = '{	
		"data_source": {
			"fields_list":[
				{
				    "id":"numero_ctrc_filial",
				    "field": "numero_ctrc_filial",
				    "format": null,
				    "formula":null
				},
				{
				    "id":"data_emissao",
				    "field": "data_emissao",
				    "format": "DD/MM/YYYY",
				    "formula":null
				},
				{
				    "id":"tipo_documento",
				    "field": "tipo_documento",
				    "format": null,
				    "formula":null
				},
				{
				    "id":"cstat",
				    "field": "cstat",
				    "format": null,
				    "formula":null
				},
				{
				    "id":"tempo_pendente",
				    "field": "tempo_pendente",
				    "format": null,
				    "formula":null
				}
				
			],		
			"order_by": [
					{
						"field": "tempo_pendente",
						"order": "ASC"
					}
			]
		},			
		"data":[
			{
				"field":"numero_ctrc_filial",
				"label":"Número ",
				"format":null
			},
			{
				"field":"data_emissao",
				"label":"Data",
				"format":null
			},
			{
				"field":"tipo_transporte",
				"label":"Tipo Transporte",
				"format":null
			},
						{
				"field":"cstat",
				"label":"CSTAT",
				"format":null
			},
			{
				"field":"tempo_pendente",
				"label":"Periodo Pend.",
				"format":null
			}
		],
		"options":{				
				
				"name_class":"dash_exptms_2_mensal_06",
				"title":"Documentos Pendência Sefaz",
				"height":"160px"
			}		
		
	}'::json,
	filters = '{ 	
		"filters":[
			{
				"field":"data_expedicao",
				"type":"date",
				"type_function":"date",
				"operator":"last",
				"value":"2"
			},
			{
				"field":"empresa_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_EMPRESA}}"
			},
			{
				"field":"filial_emitente",
				"type":"text",			
				"operator":"=",
				"value":"{{PST_COD_FILIAL}}"
			},
			{
				"field":"pendente_sefaz",
				"type":"numeric",			
				"operator":"=",
				"value":"1"
			},
						{
				"field":"tipo_documento",
				"type":"text",			
				"operator":"=",
				"value":"CTe"
			}
		]
	}'::json
WHERE 
	code_item = 'dash_exptms_2_mensal_06';	


*/