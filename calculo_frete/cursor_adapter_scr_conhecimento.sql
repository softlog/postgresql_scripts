UPDATE conf_cursoradapter SET
select_cmd = 'SELECT scr_conhecimento.id_conhecimento
	,scr_conhecimento.empresa_emitente
	,scr_conhecimento.filial_emitente
	,scr_conhecimento.numero_ctrc_filial
	,scr_conhecimento.numero_documento
	,scr_conhecimento.remetente_id
	,scr_conhecimento.remetente_cnpj
	,scr_conhecimento.calculado_de_id_cidade
	,scr_conhecimento.destinatario_id
	,scr_conhecimento.destinatario_cnpj
	,scr_conhecimento.calculado_ate_id_cidade
	,scr_conhecimento.consig_red_id
	,scr_conhecimento.consig_red_id_endereco
	,scr_conhecimento.consig_red_cnpj
	,scr_conhecimento.consig_red_cif_fob
	,scr_conhecimento.consig_red
	,scr_conhecimento.conhecimento_origem
	,scr_conhecimento.data_conhecimento_origem
	,scr_conhecimento.redespachador_id
	,scr_conhecimento.redespachador_cnpj
	,scr_conhecimento.frete_cif_fob
	,scr_conhecimento.observacoes_coleta
	,scr_conhecimento.observacoes_entrega
	,scr_conhecimento.qtd_volumes
	,scr_conhecimento.peso
	,scr_conhecimento.peso_cubado
	,scr_conhecimento.volume_cubico
	,scr_conhecimento.natureza_carga
	,scr_conhecimento.especie
	,scr_conhecimento.valor_nota_fiscal
	,scr_conhecimento.DATA_EMISSAO
	,scr_conhecimento.TOTAL_FRETE
	,scr_conhecimento.desconto
	,scr_conhecimento.tabele_frete
	,scr_conhecimento.tipo_imposto
	,scr_conhecimento.cod_operacao_fiscal
	,scr_conhecimento.observacoes_conhecimento
	,scr_conhecimento.aliquota
	,scr_conhecimento.imposto_incluso
	,scr_conhecimento.numero_fatura
	,scr_conhecimento.numero_formulario
	,scr_conhecimento.cancelado
	,scr_conhecimento.situacao
	,scr_conhecimento.avista
	,scr_conhecimento.STATUS
	,scr_conhecimento.usuario_inclusao
	,scr_conhecimento.usuario_alteracao
	,scr_conhecimento.usuario_emissao
	,scr_conhecimento.usuario_cancelamento
	,scr_conhecimento.data_nota_fiscal
	,scr_conhecimento.data_previsao_entrega
	,scr_conhecimento.data_cancelamento
	,scr_conhecimento.data_digitacao
	,scr_conhecimento.tipo_transporte
	,scr_conhecimento.incidencia
	,scr_conhecimento.id_coleta_filial
	,scr_conhecimento.expresso
	,scr_conhecimento.emergencia
	,scr_conhecimento.escolta
	,scr_conhecimento.escolta_horas_coleta
	,scr_conhecimento.escolta_horas_entrega
	,scr_conhecimento.coleta_escolta
	,scr_conhecimento.coleta_expresso
	,scr_conhecimento.coleta_emergencia
	,scr_conhecimento.coleta_normal
	,scr_conhecimento.coleta_dificuldade
	,scr_conhecimento.coleta_exclusiva
	,scr_conhecimento.entrega_escolta
	,scr_conhecimento.entrega_expresso
	,scr_conhecimento.entrega_emergencia
	,scr_conhecimento.entrega_normal
	,scr_conhecimento.entrega_dificuldade
	,scr_conhecimento.entrega_exclusiva
	,scr_conhecimento.taxa_dce::INTEGER
	,scr_conhecimento.taxa_exclusivo::INTEGER
	,scr_conhecimento.modal
	,scr_conhecimento.TIPO_DOC_REFERENCIADO
	,scr_conhecimento.CTE_REFERENCIADO
	,scr_conhecimento.TIPO_DOCUMENTO
	,scr_conhecimento.total_frete_origem
	,scr_conhecimento.serie_doc
	,scr_conhecimento.cte_ambiente
	,scr_conhecimento.tipo_ctrc_cte
	,scr_conhecimento.percentual_frete
	,scr_conhecimento.placa_veiculo
	,scr_conhecimento.placa_reboque1
	,scr_conhecimento.placa_reboque2
	,scr_conhecimento.id_motorista
	,scr_conhecimento.distancia_combinada
	,scr_conhecimento.flg_viagem
	,scr_conhecimento.flg_importado
	,scr_conhecimento.numero_minuta_aereo
	,scr_conhecimento.ident_emissor_aereo
	,scr_conhecimento.classe_tarifa_aereo
	,scr_conhecimento.codigo_tarifa_aereo
	,scr_conhecimento.valor_tarifa_aereo
	,scr_conhecimento.dimensao_aereo
	,scr_conhecimento.tipo_entrega
	,scr_conhecimento.id_aeroporto_origem
	,scr_conhecimento.id_aeroporto_destino
	,scr_conhecimento.chave_cte
	,scr_conhecimento.prot_autorizacao_cte
	,scr_conhecimento.observacao_etiqueta
	,scr_conhecimento.substituicao_tributaria
	,scr_conhecimento.tipo_frete
	,scr_conhecimento.icms_st
	,scr_conhecimento.aliquota_icms_st
	,scr_conhecimento.perc_reducao_base_calculo
	,scr_conhecimento.base_calculo_st_reduzida
	,scr_conhecimento.credito_presumido_outorgado
	,scr_conhecimento.iss
	,scr_conhecimento.aliquota_iss
	,scr_conhecimento.cst_pis
	,scr_conhecimento.aliquota_pis
	,scr_conhecimento.valor_pis
	,scr_conhecimento.cst_cofins
	,scr_conhecimento.aliquota_cofins
	,scr_conhecimento.valor_cofins
	,scr_conhecimento.status_cte
	,scr_conhecimento.responsavel_seguro
	,scr_conhecimento.cstat
	,scr_conhecimento.xmotivo
	,base_calculo
	,imposto
	,scr_conhecimento.perc_desconto
	,numero_awb
	,aprovado
	,id_conhecimento_principal
	,regime_especial_mg
	,data_cte_re
	,id_manifesto
	,id_faturamento
	,observacoes_conhecimento_2
	,codigo_vendedor
	,id_tipo_veiculo
	,vl_frete_peso
	,id_pre_fatura_entrega	
	,consumidor_final
	,difal_icms
	,difal_icms_origem
	,difal_icms_destino
	,aliq_icms_interna
	,aliquota_fcp
	,valor_fcp
	,calculo_difal
	,aliq_icms_inter
	,base_calculo_difal
	,dt_agenda_coleta
	,dt_agenda_entrega
	,placa_coleta
	,ctid
	,locent_destinatario_id 
	,locent_destinatario_cnpj 
	,locent_destinatario_id_endereco 
	,nfe_anulacao
	,expedidor_cnpj
	,recebedor_cnpj
	,numero_averbacao
	,tipo_veiculo
	,km_rodado
	,scr_conhecimento.qtd_ajudantes
FROM scr_conhecimento
WHERE 1=2',

cursor_schema = translate('ID_CONHECIMENTO I
	,EMPRESA_EMITENTE C(3)
	,FILIAL_EMITENTE C(3)
	,NUMERO_CTRC_FILIAL C(13)
	,NUMERO_DOCUMENTO C(13)
	,REMETENTE_ID I
	,REMETENTE_CNPJ C(14)
	,CALCULADO_DE_ID_CIDADE I
	,DESTINATARIO_ID I
	,DESTINATARIO_CNPJ C(14)
	,CALCULADO_ATE_ID_CIDADE I
	,CONSIG_RED_ID I
	,CONSIG_RED_ID_ENDERECO I
	,CONSIG_RED_CNPJ C(14)
	,CONSIG_RED_CIF_FOB I
	,CONSIG_RED I
	,CONHECIMENTO_ORIGEM C(44)
	,DATA_CONHECIMENTO_ORIGEM D
	,REDESPACHADOR_ID I
	,REDESPACHADOR_CNPJ C(14)
	,FRETE_CIF_FOB I
	,OBSERVACOES_COLETA C(250)
	,OBSERVACOES_ENTREGA C(250)
	,QTD_VOLUMES I
	,PESO N(12, 3)
	,PESO_CUBADO N(12, 3)
	,VOLUME_CUBICO N(12, 6)
	,NATUREZA_CARGA C(40)
	,ESPECIE C(10)
	,VALOR_NOTA_FISCAL N(13, 2)
	,DATA_EMISSAO T
	,TOTAL_FRETE N(12, 2)
	,DESCONTO N(12, 2)
	,TABELE_FRETE C(13)
	,TIPO_IMPOSTO I
	,COD_OPERACAO_FISCAL C(5)
	,OBSERVACOES_CONHECIMENTO M
	,ALIQUOTA N(7, 2)
	,IMPOSTO_INCLUSO I
	,NUMERO_FATURA C(13)
	,NUMERO_FORMULARIO C(6)
	,CANCELADO I
	,SITUACAO I
	,AVISTA I
	,STATUS I
	,USUARIO_INCLUSAO I
	,USUARIO_ALTERACAO I
	,USUARIO_EMISSAO I
	,USUARIO_CANCELAMENTO I
	,DATA_NOTA_FISCAL D
	,DATA_PREVISAO_ENTREGA D
	,DATA_CANCELAMENTO T
	,DATA_DIGITACAO T
	,TIPO_TRANSPORTE I
	,INCIDENCIA N(14, 2)
	,ID_COLETA_FILIAL C(13)
	,EXPRESSO I
	,EMERGENCIA I
	,ESCOLTA I
	,ESCOLTA_HORAS_COLETA I
	,ESCOLTA_HORAS_ENTREGA I
	,COLETA_ESCOLTA I
	,COLETA_EXPRESSO I
	,COLETA_EMERGENCIA I
	,COLETA_NORMAL I
	,COLETA_DIFICULDADE I
	,COLETA_EXCLUSIVA I
	,ENTREGA_ESCOLTA I
	,ENTREGA_EXPRESSO I
	,ENTREGA_EMERGENCIA I
	,ENTREGA_NORMAL I
	,ENTREGA_DIFICULDADE I
	,ENTREGA_EXCLUSIVA I
	,TAXA_DCE I
	,TAXA_EXCLUSIVO I
	,MODAL I
	,TIPO_DOC_REFERENCIADO I
	,CTE_REFERENCIADO C(44)
	,TIPO_DOCUMENTO I
	,TOTAL_FRETE_ORIGEM N(14, 2)
	,SERIE_DOC C(10)
	,CTE_AMBIENTE I
	,TIPO_CTRC_CTE I
	,PERCENTUAL_FRETE N(8, 2)
	,PLACA_VEICULO C(10)
	,PLACA_REBOQUE1 C(8)
	,PLACA_REBOQUE2 C(8)
	,ID_MOTORISTA I
	,DISTANCIA_COMBINADA I
	,FLG_VIAGEM I
	,FLG_IMPORTADO I
	,NUMERO_MINUTA_AEREO C(9)
	,IDENT_EMISSOR_AEREO C(20)
	,CLASSE_TARIFA_AEREO C(1)
	,CODIGO_TARIFA_AEREO C(4)
	,VALOR_TARIFA_AEREO N(15, 2)
	,DIMENSAO_AEREO C(14)
	,TIPO_ENTREGA I
	,ID_AEROPORTO_ORIGEM I
	,ID_AEROPORTO_DESTINO I
	,CHAVE_CTE C(44)
	,PROT_AUTORIZACAO_CTE C(15)
	,OBSERVACAO_ETIQUETA C(50)
	,SUBSTITUICAO_TRIBUTARIA I
	,TIPO_FRETE C(3)
	,ICMS_ST N(14, 2)
	,ALIQUOTA_ICMS_ST N(7, 2)
	,PERC_REDUCAO_BASE_CALCULO N(7, 2)
	,BASE_CALCULO_ST_REDUZIDA N(14, 2)
	,CREDITO_PRESUMIDO_OUTORGADO N(14, 2)
	,ISS N(14, 2)
	,ALIQUOTA_ISS N(7, 2)
	,CST_PIS C(3)
	,ALIQUOTA_PIS N(7, 2)
	,VALOR_PIS N(14, 2)
	,CST_COFINS C(3)
	,ALIQUOTA_COFINS N(7, 2)
	,VALOR_COFINS N(14, 2)
	,STATUS_CTE I
	,RESPONSAVEL_SEGURO I
	,CSTAT C(3)
	,XMOTIVO M
	,BASE_CALCULO N(12, 2)
	,IMPOSTO N(12, 2)
	,PERC_DESCONTO N(7, 2)
	,NUMERO_AWB C(15)
	,APROVADO I
	,ID_CONHECIMENTO_PRINCIPAL I
	,REGIME_ESPECIAL_MG I
	,DATA_CTE_RE D
	,ID_MANIFESTO I
	,ID_FATURAMENTO I
	,OBSERVACOES_CONHECIMENTO_2 M
	,CODIGO_VENDEDOR C(10)
	,ID_TIPO_VEICULO I
	,VL_FRETE_PESO N(12, 2)
	,ID_PRE_FATURA_ENTREGA I	
	,CONSUMIDOR_FINAL I
	,DIFAL_ICMS N(12, 2)
	,DIFAL_ICMS_ORIGEM N(12, 2)
	,DIFAL_ICMS_DESTINO N(12, 2)
	,ALIQ_ICMS_INTERNA N(5,2)
	,ALIQUOTA_FCP N(5,2)
	,VALOR_FCP N(12, 2)
	,CALCULO_DIFAL I
	,ALIQ_ICMS_INTER N(5,2)
	,BASE_CALCULO_DIFAL N(12,2)
	,DT_AGENDA_COLETA T
	,DT_AGENDA_ENTREGA T
	,PLACA_COLETA C(8)
	,CTID C(20)
	,LOCENT_DESTINATARIO_ID I,
	LOCENT_DESTINATARIO_CNPJ C(14),
	LOCENT_DESTINATARIO_ID_ENDERECO I,
	NFE_ANULACAO C(44),
	EXPEDIDOR_CNPJ C(14),
	RECEBEDOR_CNPJ C(14),
	NUMERO_AVERBACAO C(50),
	TIPO_VEICULO I,
	KM_RODADO I,
	QTD_AJUDANTES I',chr(13)||chr(10)||chr(9),'')
, 
update_name_list = translate('
	ID_CONHECIMENTO scr_conhecimento.ID_CONHECIMENTO
	,EMPRESA_EMITENTE scr_conhecimento.EMPRESA_EMITENTE
	,FILIAL_EMITENTE scr_conhecimento.FILIAL_EMITENTE
	,NUMERO_CTRC_FILIAL scr_conhecimento.NUMERO_CTRC_FILIAL
	,NUMERO_DOCUMENTO scr_conhecimento.NUMERO_DOCUMENTO
	,REMETENTE_ID scr_conhecimento.REMETENTE_ID
	,REMETENTE_CNPJ scr_conhecimento.REMETENTE_CNPJ
	,CALCULADO_DE_ID_CIDADE scr_conhecimento.CALCULADO_DE_ID_CIDADE
	,DESTINATARIO_ID scr_conhecimento.DESTINATARIO_ID
	,DESTINATARIO_CNPJ scr_conhecimento.DESTINATARIO_CNPJ
	,CALCULADO_ATE_ID_CIDADE scr_conhecimento.CALCULADO_ATE_ID_CIDADE
	,CONSIG_RED_ID scr_conhecimento.CONSIG_RED_ID
	,CONSIG_RED_ID_ENDERECO scr_conhecimento.CONSIG_RED_ID_ENDERECO
	,CONSIG_RED_CNPJ scr_conhecimento.CONSIG_RED_CNPJ
	,CONSIG_RED_CIF_FOB scr_conhecimento.CONSIG_RED_CIF_FOB
	,CONSIG_RED scr_conhecimento.CONSIG_RED
	,CONHECIMENTO_ORIGEM scr_conhecimento.CONHECIMENTO_ORIGEM
	,DATA_CONHECIMENTO_ORIGEM scr_conhecimento.DATA_CONHECIMENTO_ORIGEM
	,REDESPACHADOR_ID scr_conhecimento.REDESPACHADOR_ID
	,REDESPACHADOR_CNPJ scr_conhecimento.REDESPACHADOR_CNPJ
	,FRETE_CIF_FOB scr_conhecimento.FRETE_CIF_FOB
	,OBSERVACOES_COLETA scr_conhecimento.OBSERVACOES_COLETA
	,OBSERVACOES_ENTREGA scr_conhecimento.OBSERVACOES_ENTREGA
	,QTD_VOLUMES scr_conhecimento.QTD_VOLUMES
	,PESO scr_conhecimento.PESO
	,PESO_CUBADO scr_conhecimento.PESO_CUBADO
	,VOLUME_CUBICO scr_conhecimento.VOLUME_CUBICO
	,NATUREZA_CARGA scr_conhecimento.NATUREZA_CARGA
	,ESPECIE scr_conhecimento.ESPECIE
	,VALOR_NOTA_FISCAL scr_conhecimento.VALOR_NOTA_FISCAL
	,DATA_EMISSAO scr_conhecimento.DATA_EMISSAO
	,TOTAL_FRETE scr_conhecimento.TOTAL_FRETE
	,DESCONTO scr_conhecimento.DESCONTO
	,TABELE_FRETE scr_conhecimento.TABELE_FRETE
	,TIPO_IMPOSTO scr_conhecimento.TIPO_IMPOSTO
	,COD_OPERACAO_FISCAL scr_conhecimento.COD_OPERACAO_FISCAL
	,OBSERVACOES_CONHECIMENTO scr_conhecimento.OBSERVACOES_CONHECIMENTO
	,ALIQUOTA scr_conhecimento.ALIQUOTA
	,IMPOSTO_INCLUSO scr_conhecimento.IMPOSTO_INCLUSO
	,NUMERO_FATURA scr_conhecimento.NUMERO_FATURA
	,NUMERO_FORMULARIO scr_conhecimento.NUMERO_FORMULARIO
	,CANCELADO scr_conhecimento.CANCELADO
	,SITUACAO scr_conhecimento.SITUACAO
	,AVISTA scr_conhecimento.AVISTA
	,STATUS scr_conhecimento.STATUS
	,USUARIO_INCLUSAO scr_conhecimento.USUARIO_INCLUSAO
	,USUARIO_ALTERACAO scr_conhecimento.USUARIO_ALTERACAO
	,USUARIO_EMISSAO scr_conhecimento.USUARIO_EMISSAO
	,USUARIO_CANCELAMENTO scr_conhecimento.USUARIO_CANCELAMENTO
	,DATA_NOTA_FISCAL scr_conhecimento.DATA_NOTA_FISCAL
	,DATA_PREVISAO_ENTREGA scr_conhecimento.DATA_PREVISAO_ENTREGA
	,DATA_CANCELAMENTO scr_conhecimento.DATA_CANCELAMENTO
	,DATA_DIGITACAO scr_conhecimento.DATA_DIGITACAO
	,TIPO_TRANSPORTE scr_conhecimento.TIPO_TRANSPORTE
	,INCIDENCIA scr_conhecimento.INCIDENCIA
	,ID_COLETA_FILIAL scr_conhecimento.ID_COLETA_FILIAL
	,EXPRESSO scr_conhecimento.EXPRESSO
	,EMERGENCIA scr_conhecimento.EMERGENCIA
	,ESCOLTA scr_conhecimento.ESCOLTA
	,ESCOLTA_HORAS_COLETA scr_conhecimento.ESCOLTA_HORAS_COLETA
	,ESCOLTA_HORAS_ENTREGA scr_conhecimento.ESCOLTA_HORAS_ENTREGA
	,COLETA_ESCOLTA scr_conhecimento.COLETA_ESCOLTA
	,COLETA_EXPRESSO scr_conhecimento.COLETA_EXPRESSO
	,COLETA_EMERGENCIA scr_conhecimento.COLETA_EMERGENCIA
	,COLETA_NORMAL scr_conhecimento.COLETA_NORMAL
	,COLETA_DIFICULDADE scr_conhecimento.COLETA_DIFICULDADE
	,COLETA_EXCLUSIVA scr_conhecimento.COLETA_EXCLUSIVA
	,ENTREGA_ESCOLTA scr_conhecimento.ENTREGA_ESCOLTA
	,ENTREGA_EXPRESSO scr_conhecimento.ENTREGA_EXPRESSO
	,ENTREGA_EMERGENCIA scr_conhecimento.ENTREGA_EMERGENCIA
	,ENTREGA_NORMAL scr_conhecimento.ENTREGA_NORMAL
	,ENTREGA_DIFICULDADE scr_conhecimento.ENTREGA_DIFICULDADE
	,ENTREGA_EXCLUSIVA scr_conhecimento.ENTREGA_EXCLUSIVA
	,TAXA_DCE scr_conhecimento.TAXA_DCE
	,TAXA_EXCLUSIVO scr_conhecimento.TAXA_EXCLUSIVO
	,MODAL scr_conhecimento.MODAL
	,TIPO_DOC_REFERENCIADO scr_conhecimento.TIPO_DOC_REFERENCIADO
	,CTE_REFERENCIADO scr_conhecimento.CTE_REFERENCIADO
	,TIPO_DOCUMENTO scr_conhecimento.TIPO_DOCUMENTO
	,TOTAL_FRETE_ORIGEM scr_conhecimento.TOTAL_FRETE_ORIGEM
	,SERIE_DOC scr_conhecimento.SERIE_DOC
	,CTE_AMBIENTE scr_conhecimento.CTE_AMBIENTE
	,TIPO_CTRC_CTE scr_conhecimento.TIPO_CTRC_CTE
	,PERCENTUAL_FRETE scr_conhecimento.PERCENTUAL_FRETE
	,PLACA_VEICULO scr_conhecimento.PLACA_VEICULO
	,PLACA_REBOQUE1 scr_conhecimento.PLACA_REBOQUE1
	,PLACA_REBOQUE2 scr_conhecimento.PLACA_REBOQUE2
	,ID_MOTORISTA scr_conhecimento.ID_MOTORISTA
	,DISTANCIA_COMBINADA scr_conhecimento.DISTANCIA_COMBINADA
	,FLG_VIAGEM scr_conhecimento.FLG_VIAGEM
	,FLG_IMPORTADO scr_conhecimento.FLG_IMPORTADO
	,NUMERO_MINUTA_AEREO scr_conhecimento.NUMERO_MINUTA_AEREO
	,IDENT_EMISSOR_AEREO scr_conhecimento.IDENT_EMISSOR_AEREO
	,CLASSE_TARIFA_AEREO scr_conhecimento.CLASSE_TARIFA_AEREO
	,CODIGO_TARIFA_AEREO scr_conhecimento.CODIGO_TARIFA_AEREO
	,VALOR_TARIFA_AEREO scr_conhecimento.VALOR_TARIFA_AEREO
	,DIMENSAO_AEREO scr_conhecimento.DIMENSAO_AEREO
	,TIPO_ENTREGA scr_conhecimento.TIPO_ENTREGA
	,ID_AEROPORTO_ORIGEM scr_conhecimento.ID_AEROPORTO_ORIGEM
	,ID_AEROPORTO_DESTINO scr_conhecimento.ID_AEROPORTO_DESTINO
	,CHAVE_CTE scr_conhecimento.CHAVE_CTE
	,PROT_AUTORIZACAO_CTE scr_conhecimento.PROT_AUTORIZACAO_CTE
	,OBSERVACAO_ETIQUETA scr_conhecimento.OBSERVACAO_ETIQUETA
	,SUBSTITUICAO_TRIBUTARIA scr_conhecimento.SUBSTITUICAO_TRIBUTARIA
	,TIPO_FRETE scr_conhecimento.TIPO_FRETE
	,ICMS_ST scr_conhecimento.ICMS_ST
	,ALIQUOTA_ICMS_ST scr_conhecimento.ALIQUOTA_ICMS_ST
	,PERC_REDUCAO_BASE_CALCULO scr_conhecimento.PERC_REDUCAO_BASE_CALCULO
	,BASE_CALCULO_ST_REDUZIDA scr_conhecimento.BASE_CALCULO_ST_REDUZIDA
	,CREDITO_PRESUMIDO_OUTORGADO scr_conhecimento.CREDITO_PRESUMIDO_OUTORGADO
	,ISS scr_conhecimento.iss
	,ALIQUOTA_ISS scr_conhecimento.ALIQUOTA_ISS
	,CST_PIS scr_conhecimento.CST_PIS
	,ALIQUOTA_PIS scr_conhecimento.ALIQUOTA_PIS
	,VALOR_PIS scr_conhecimento.VALOR_PIS
	,CST_COFINS scr_conhecimento.CST_COFINS
	,ALIQUOTA_COFINS scr_conhecimento.ALIQUOTA_COFINS
	,VALOR_COFINS scr_conhecimento.VALOR_COFINS
	,STATUS_CTE scr_conhecimento.STATUS_CTE
	,RESPONSAVEL_SEGURO scr_conhecimento.RESPONSAVEL_SEGURO
	,CSTAT scr_conhecimento.CSTAT
	,XMOTIVO scr_conhecimento.XMOTIVO
	,BASE_CALCULO scr_conhecimento.base_calculo
	,IMPOSTO scr_conhecimento.imposto
	,PERC_DESCONTO scr_conhecimento.PERC_DESCONTO
	,NUMERO_AWB scr_conhecimento.numero_awb
	,APROVADO scr_conhecimento.aprovado
	,CODIGO_VENDEDOR scr_conhecimento.codigo_vendedor
	,CONSUMIDOR_FINAL scr_conhecimento.consumidor_final
	,DIFAL_ICMS scr_conhecimento.difal_icms
	,DIFAL_ICMS_ORIGEM scr_conhecimento.difal_icms_origem
	,DIFAL_ICMS_DESTINO scr_conhecimento.difal_icms_destino
	,ALIQ_ICMS_INTERNA scr_conhecimento.aliq_icms_interna
	,ALIQUOTA_FCP scr_conhecimento.aliquota_fcp
	,VALOR_FCP scr_conhecimento.valor_fcp
	,CALCULO_DIFAL scr_conhecimento.calculo_difal
	,ALIQ_ICMS_INTER scr_conhecimento.aliq_icms_inter
	,BASE_CALCULO_DIFAL scr_conhecimento.base_calculo_difal
	,DT_AGENDA_COLETA scr_conhecimento.dt_agenda_coleta
	,DT_AGENDA_ENTREGA scr_conhecimento.dt_agenda_entrega
	,PLACA_COLETA scr_conhecimento.placa_coleta
	,LOCENT_DESTINATARIO_ID scr_conhecimento.locent_destinatario_id
	,LOCENT_DESTINATARIO_CNPJ scr_conhecimento.locent_destinatario_cnpj 
	,LOCENT_DESTINATARIO_ID_ENDERECO scr_conhecimento.locent_destinatario_id_endereco 
	,NFE_ANULACAO scr_conhecimento.nfe_anulacao
	,EXPEDIDOR_CNPJ scr_conhecimento.expedidor_cnpj
	,RECEBEDOR_CNPJ scr_conhecimento.recebedor_cnpj
	,NUMERO_AVERBACAO scr_conhecimento.numero_averbacao
	,TIPO_VEICULO scr_conhecimento.tipo_veiculo
	,KM_RODADO scr_conhecimento.km_rodado
	,QTD_AJUDANTES scr_conhecimento.qtd_ajudantes',chr(13)||chr(10)||chr(9),'')
, updatable_field_list = '
	ID_CONHECIMENTO
	,EMPRESA_EMITENTE
	,FILIAL_EMITENTE
	,NUMERO_CTRC_FILIAL
	,NUMERO_DOCUMENTO
	,REMETENTE_ID
	,REMETENTE_CNPJ
	,CALCULADO_DE_ID_CIDADE
	,DESTINATARIO_ID
	,DESTINATARIO_CNPJ
	,CALCULADO_ATE_ID_CIDADE
	,CONSIG_RED_ID
	,CONSIG_RED_ID_ENDERECO
	,CONSIG_RED_CNPJ
	,CONSIG_RED_CIF_FOB
	,CONSIG_RED
	,CONHECIMENTO_ORIGEM
	,DATA_CONHECIMENTO_ORIGEM
	,REDESPACHADOR_ID
	,REDESPACHADOR_CNPJ
	,FRETE_CIF_FOB
	,OBSERVACOES_COLETA
	,OBSERVACOES_ENTREGA
	,QTD_VOLUMES
	,PESO
	,PESO_CUBADO
	,VOLUME_CUBICO
	,NATUREZA_CARGA
	,ESPECIE
	,VALOR_NOTA_FISCAL
	,DATA_EMISSAO
	,TOTAL_FRETE
	,DESCONTO
	,TABELE_FRETE
	,TIPO_IMPOSTO
	,COD_OPERACAO_FISCAL
	,OBSERVACOES_CONHECIMENTO
	,ALIQUOTA
	,IMPOSTO_INCLUSO
	,NUMERO_FATURA
	,NUMERO_FORMULARIO
	,CANCELADO
	,SITUACAO
	,AVISTA
	,STATUS
	,USUARIO_INCLUSAO
	,USUARIO_ALTERACAO
	,USUARIO_EMISSAO
	,USUARIO_CANCELAMENTO
	,DATA_NOTA_FISCAL
	,DATA_PREVISAO_ENTREGA
	,DATA_CANCELAMENTO
	,DATA_DIGITACAO
	,TIPO_TRANSPORTE
	,INCIDENCIA
	,ID_COLETA_FILIAL
	,EXPRESSO
	,EMERGENCIA
	,ESCOLTA
	,ESCOLTA_HORAS_COLETA
	,ESCOLTA_HORAS_ENTREGA
	,COLETA_ESCOLTA
	,COLETA_EXPRESSO
	,COLETA_EMERGENCIA
	,COLETA_NORMAL
	,COLETA_DIFICULDADE
	,COLETA_EXCLUSIVA
	,ENTREGA_ESCOLTA
	,ENTREGA_EXPRESSO
	,ENTREGA_EMERGENCIA
	,ENTREGA_NORMAL
	,ENTREGA_DIFICULDADE
	,ENTREGA_EXCLUSIVA
	,TAXA_DCE
	,TAXA_EXCLUSIVO
	,MODAL
	,TIPO_DOC_REFERENCIADO
	,CTE_REFERENCIADO
	,TIPO_DOCUMENTO
	,TOTAL_FRETE_ORIGEM
	,SERIE_DOC
	,CTE_AMBIENTE
	,TIPO_CTRC_CTE
	,PERCENTUAL_FRETE
	,PLACA_VEICULO
	,PLACA_REBOQUE1
	,PLACA_REBOQUE2
	,ID_MOTORISTA
	,DISTANCIA_COMBINADA
	,FLG_VIAGEM
	,FLG_IMPORTADO
	,NUMERO_MINUTA_AEREO
	,IDENT_EMISSOR_AEREO
	,CLASSE_TARIFA_AEREO
	,CODIGO_TARIFA_AEREO
	,VALOR_TARIFA_AEREO
	,DIMENSAO_AEREO
	,TIPO_ENTREGA
	,ID_AEROPORTO_ORIGEM
	,ID_AEROPORTO_DESTINO
	,CHAVE_CTE
	,PROT_AUTORIZACAO_CTE
	,OBSERVACAO_ETIQUETA
	,SUBSTITUICAO_TRIBUTARIA
	,TIPO_FRETE
	,ICMS_ST
	,ALIQUOTA_ICMS_ST
	,PERC_REDUCAO_BASE_CALCULO
	,BASE_CALCULO_ST_REDUZIDA
	,CREDITO_PRESUMIDO_OUTORGADO
	,ISS
	,ALIQUOTA_ISS
	,CST_PIS
	,ALIQUOTA_PIS
	,VALOR_PIS
	,CST_COFINS
	,ALIQUOTA_COFINS
	,VALOR_COFINS
	,STATUS_CTE
	,RESPONSAVEL_SEGURO
	,CSTAT
	,XMOTIVO
	,BASE_CALCULO
	,IMPOSTO
	,PERC_DESCONTO
	,NUMERO_AWB
	,APROVADO
	,CODIGO_VENDEDOR
	,CONSUMIDOR_FINAL 
	,DIFAL_ICMS 
	,DIFAL_ICMS_ORIGEM 
	,DIFAL_ICMS_DESTINO
	,ALIQ_ICMS_INTERNA
	,ALIQUOTA_FCP
	,VALOR_FCP
	,CALCULO_DIFAL
	,ALIQ_ICMS_INTER
	,BASE_CALCULO_DIFAL
	,DT_AGENDA_COLETA
	,DT_AGENDA_ENTREGA
	,PLACA_COLETA
	,LOCENT_DESTINATARIO_ID
	,LOCENT_DESTINATARIO_CNPJ
	,LOCENT_DESTINATARIO_ID_ENDERECO
	,NFE_ANULACAO
	,EXPEDIDOR_CNPJ
	,RECEBEDOR_CNPJ
	,NUMERO_AVERBACAO
	,TIPO_VEICULO
	,KM_RODADO
	,QTD_AJUDANTES'
FROM
	conf_formulario
WHERE
	conf_formulario.id_formulario = conf_cursoradapter.id_formulario
	AND conf_formulario.nome_formulario 		= 'CTRC_AEREO_V02'
	AND conf_cursoradapter.nome_cursoradapter	= 'scr_conhecimento';


