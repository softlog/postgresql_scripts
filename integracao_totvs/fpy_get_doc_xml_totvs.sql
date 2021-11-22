-- Function: public.fpy_get_doc_xml_totvs(integer, integer)
-- SELECT * FROM fpy_get_doc_xml_totvs(8032,2)
-- DROP FUNCTION public.fpy_get_doc_xml_totvs(integer, integer);

CREATE OR REPLACE FUNCTION public.fpy_get_doc_xml_totvs(
    p_id_documento integer,
    p_tipo_documento integer)
  RETURNS text AS
$BODY$

import json
from jinja2 import Environment

TEMPLATE_ENVIRONMENT = Environment(
    autoescape=True,    
    trim_blocks=True,
    lstrip_blocks=True)


tpl_produto = """<EstPrdBR >
	<TPRODUTO>
		<CODCOLPRD>5</CODCOLPRD>
		<CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
		<IDPRD>-1</IDPRD>
		<CODIGOPRD>10.001.{{codigo_produto_2}}</CODIGOPRD>
		<NOMEFANTASIA>{{descricao_produto}}</NOMEFANTASIA>
		<NUMNOFABRIC>{{codigo_produto}}</NUMNOFABRIC>
		<ULTIMONIVEL>1</ULTIMONIVEL>
		<TIPO>{{tipo_produto}}</TIPO>
		<DESCRICAO>{{descricao_produto}}</DESCRICAO>
		<NUMEROCCF>{{codigo_mercosul}}</NUMEROCCF>
		<REFERENCIACP>0</REFERENCIACP>
		<CODUNDCONTROLE>UN</CODUNDCONTROLE>
		<CODUNDCOMPRA>UN</CODUNDCOMPRA>
		<CODUNDVENDA>UN</CODUNDVENDA>
		<INATIVO>0</INATIVO>
	</TPRODUTO>
</EstPrdBR>"""

tpl_totvs = """<MovMovimento>
  <TMOV>
    <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
    <IDMOV>-1</IDMOV>
    <CODFILIAL>{{filial_cod_totvs}}</CODFILIAL>
    <CODLOC>{{totvs_cod_loc or ""}}</CODLOC>
    <CODDEPARTAMENTO>{{codigo_depto}}</CODDEPARTAMENTO>
    <CODCFO>{{cod_cfo}}</CODCFO>
    <NUMEROMOV>{{numero_documento}}</NUMEROMOV>
    <SERIE>{{serie_doc}}</SERIE>
    <CODTMV>{{cod_tmv}}</CODTMV>
    <DATAEMISSAO>{{data_emissao[0:10]}}</DATAEMISSAO>
    <DATASAIDA>{{data_saida}}</DATASAIDA>
    <DATAEXTRA1>{{data_emissao}}</DATAEXTRA1>
    {% if tipo_movimento == 2 %}
    <CODCPG>001</CODCPG>
    {% else %}
    <CODCPG>{{cod_cpg or ""}}</CODCPG>
    {% endif %}
    <VALORBRUTO>{{valor_bruto | replace(".",",")}}</VALORBRUTO>    
    <VALORDESC>{{valor_desconto | replace(".",",")}}</VALORDESC>  
    <VALORLIQUIDO>{{valor_liquido | replace(".",",")}}</VALORLIQUIDO>
    <VALOROUTROS>{{valor_liquido | replace(".",",") }}</VALOROUTROS>
    <VIADETRANSPORTE>Rodoviario</VIADETRANSPORTE>
    <CODTB1FLX>{{itens[0].totvs_cod_tb1_flx or ""}}</CODTB1FLX>    
    {% if tipo_movimento == 2 %}
    <CODTB2FLX>001</CODTB2FLX>
    {% else %}
    <CODTB2FLX>{{totvs_cod_tb2_flx or ""}}</CODTB2FLX>
    {% endif %}
    <CODTB3FLX>000</CODTB3FLX>
    <CODTB4FLX>{{tipo_venda or ""}}</CODTB4FLX>
    <DATAMOVIMENTO>{{data_emissao[0:10]}}</DATAMOVIMENTO>
    <CODCCUSTO>{{codigo_centro_custo}}</CODCCUSTO>
    {% if tipo_movimento == 2 %}
    <CODVEN1>{{codigo_motorista or ""}}</CODVEN1>
    {% endif %}
    <CODCOLCFO>{{cod_col_cfo}}</CODCOLCFO>    
    <HORULTIMAALTERACAO>{{data_emissao}}</HORULTIMAALTERACAO>
    <HORARIOEMISSAO>{{data_emissao}}</HORARIOEMISSAO>    
    <DATACRIACAO>{{data_integracao}}</DATACRIACAO>
    <VALORBRUTOINTERNO>{{valor_bruto | replace(".",",")}}</VALORBRUTOINTERNO>
    <HORASAIDA>{{data_emissao}}</HORASAIDA>
    <DATADEDUCAO>{{data_emissao}}</DATADEDUCAO>
    <CODTDO>{{codtdo or ""}}</CODTDO>
    <CODVIATRANSPORTE>1</CODVIATRANSPORTE>
    <DATALANCAMENTO>{{data_emissao}}</DATALANCAMENTO>
    <CHAVEACESSONFE>{{chave}}</CHAVEACESSONFE>
    <VLRDESPACHO>{{valor_despacho|replace(".",",")}}</VLRDESPACHO>   
    {% if tipo_movimento == 1 %}
    <VALORDESP>{{valor_desp|replace(".",",")}}</VALORDESP>
    {% endif %}
    <IDNAT>{{itens[0].cod_id_nat or ""}}</IDNAT>
    <FRETECIFOUFOB>{{frete_cif_fob}}</FRETECIFOUFOB>
    <PRODPREDOMINANTE>{{natureza_carga}}</PRODPREDOMINANTE>
    <HISTORICOCURTO>{{historico_curto}}</HISTORICOCURTO>
  </TMOV>
  {% for item in itens %}
  <TITMMOV>
    <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
    <IDMOV>-1</IDMOV>
    <NSEQITMMOV>{{item.num_item}}</NSEQITMMOV>
    <CODFILIAL>{{filial_cod_totvs}}</CODFILIAL>
    <NUMEROSEQUENCIAL>{{item.num_item}}</NUMEROSEQUENCIAL>
    <IDPRD>{{item.id_prd or ""}}</IDPRD>
    <QUANTIDADE>{{item.quantidade|replace(".",",")}}</QUANTIDADE>
    <PRECOUNITARIO>{{item.vl_item|replace(".",",")}}</PRECOUNITARIO>
    <DATAEMISSAO>{{data_emissao[0:10]}}T00:00:00</DATAEMISSAO>
    <CODTB1FLX>{{item.totvs_cod_tb1_flx or ""}}</CODTB1FLX>
    <CODTB3FLX>000</CODTB3FLX>
    <CODUND>UN</CODUND>
    <QUANTIDADEARECEBER>{{item.quantidade}}</QUANTIDADEARECEBER>
    <VALORUNITARIO>{{item.quantidade|replace(".",",")}}</VALORUNITARIO>
    <CODCCUSTO>{{codigo_centro_custo}}</CODCCUSTO>
    <QUANTIDADEORIGINAL>{{item.quantidade|replace(".",",")}}</QUANTIDADEORIGINAL>
    <VALORBRUTOITEM>{{item.valor_bruto |replace(".",",")}}</VALORBRUTOITEM>    
    <VALORTOTALITEM>{{item.valor_bruto |replace(".",",")}}</VALORTOTALITEM>
    <CODLOC>{{item.totvs_cod_loc or ""}}</CODLOC>
    <QUANTIDADETOTAL>{{item.quantidade |replace(".",",")}}</QUANTIDADETOTAL>        
    <IDNAT>{{item.cod_id_nat or ""}}</IDNAT>
  </TITMMOV>
  {% endfor %}
  {% if tem_rateio == '1' %}
  {% for rateio in rateios %}
  <TITMMOVRATCCU>
      <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
      <IDMOV>-1</IDMOV>
      <NSEQITMMOV>1</NSEQITMMOV>
      <CODCCUSTO>{{rateio.codigo_centro_custo}}</CODCCUSTO>
      <VALOR>{{rateio.valor | replace(".",",")}}</VALOR>
      <IDMOVRATCCU>{{rateio.id_seq}}</IDMOVRATCCU>
   </TITMMOVRATCCU>
   {% endfor %}
   {% endif %}
  <TMOVCOMPL>
    <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
    <IDMOV>-1</IDMOV>
  </TMOVCOMPL>
  {% for fat in faturas %}
  <TMOVPAGTO>
        <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
        <TIPOFORMAPAGTO>3</TIPOFORMAPAGTO>
        <IDFORMAPAGTO>2</IDFORMAPAGTO>
        <IDMOV>-1</IDMOV>
        <IDLAN>-1</IDLAN>
        <IDSEQPAGTO>{{fat.id_seq}}</IDSEQPAGTO>
        <DATAVENCIMENTO>{{fat.data_vencimento}}</DATAVENCIMENTO>
        <VALOR>{{fat.valor | replace(".",",")}}</VALOR>
        {% if tipo_movimento == 1 %}
        <DEBITOCREDITO>C</DEBITOCREDITO>
        {% else %}
        <DEBITOCREDITO>D</DEBITOCREDITO>
        {% endif %}
      </TMOVPAGTO>
  {% endfor %}
  {% if tipo_movimento == 2 %}
  {% for nfe in nfes %}
  <TCTRC>
        <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
        <IDMOV>{{nfe.id_mov}}</IDMOV>
        <NUMEROSEQNOTA>{{nfe.num_item}}</NUMEROSEQNOTA>
        <DATAEMISSAO>{{nfe.data_emissao}}T00:00:00</DATAEMISSAO>
        <CODTDO>NF-e</CODTDO>
        <SERIEDOC>{{nfe.serie_nfe}}</SERIEDOC>
        <NUMERODOC>{{nfe.numero_nfe}}</NUMERODOC>
        <VALORMERCADORIAS>{{nfe.valor_mercadorias}}</VALORMERCADORIAS>
        <NATUREZAVOLUMES>{{nfe.natureza_carga}}</NATUREZAVOLUMES>
        <CHAVEACESSONFE>{{nfe.chave_nfe}}</CHAVEACESSONFE>
  </TCTRC>
  {% endfor %}
  <TMOVTRANSP>
    <CODCOLIGADA>{{filial_cod_col}}</CODCOLIGADA>
    <IDMOV>-1</IDMOV>
    <CODETDENTREGA>{{uf_destino}}</CODETDENTREGA>
    <CODMUNICIPIOENTREGA>{{cod_mun_destino[2:] or ""}}</CODMUNICIPIOENTREGA>
    <CODETDCOLETA>{{uf_origem}}</CODETDCOLETA>
    <CODMUNICIPIOCOLETA>{{cod_mun_origem[2:]}}</CODMUNICIPIOCOLETA>
    <TIPOREMETENTE>C</TIPOREMETENTE>
    <REMETENTECODCOLCFO>{{remetente_col_cfo or ""}}</REMETENTECODCOLCFO>
    <REMETENTECODCFO>{{remetente_cfo or ""}}</REMETENTECODCFO>
    <TIPODESTINATARIO>C</TIPODESTINATARIO>
    <DESTINATARIOCODCOLCFO>{{destinatario_col_cfo or ""}}</DESTINATARIOCODCOLCFO>
    <DESTINATARIOCODCFO>{{destinatario_cfo or ""}}</DESTINATARIOCODCFO>
    <CNPJCPFCOLETA>{{cnpj_coleta}}</CNPJCPFCOLETA>
    <INSCRESTCOLETA>{{ie_coleta or ""}}</INSCRESTCOLETA>
    <CNPJCPFENTREGA>{{cnpj_entrega}}</CNPJCPFENTREGA>
    <INSCRESTENTREGA>{{ie_entrega or ""}}</INSCRESTENTREGA>
    <RUACOLETA>{{end_coleta}}</RUACOLETA>
    <NUMEROCOLETA>S/N</NUMEROCOLETA>
    <BAIRROCOLETA>{{bairro_coleta}}</BAIRROCOLETA>
    <RUAENTREGA>{{end_entrega}}</RUAENTREGA>
    <NUMEROENTREGA>S/N</NUMEROENTREGA>
    <COMPLENTREGA>{{complemento_entrega}}</COMPLENTREGA>
    <BAIRROENTREGA>{{bairro_entrega}}</BAIRROENTREGA>
    <NOMECOLETA>{{nome_razao_coleta}}</NOMECOLETA>
    <NOMEENTREGA>{{nome_razao_entrega}}</NOMEENTREGA>
    <RETIRAMERCADORIA>0</RETIRAMERCADORIA>
    <TIPOCTE>{{tipo_cte}}</TIPOCTE>    
    <TOMADORTIPO>{{tomador_tipo}}</TOMADORTIPO>    
    {% if tomador_tipo == '4' %}
    <TOMADORCODCFO>{{cod_cfo}}</TOMADORCODCFO>
    <TOMADORCODCOLCFO>{{cod_col_cfo}}</TOMADORCODCOLCFO>    
    {% endif %}
    <TIPOSERVICOCTE>{{tipo_servico_cte}}</TIPOSERVICOCTE>
    <TIPOEXPEDIDOR>C</TIPOEXPEDIDOR>
    <EXPEDCODCOLCFO>0</EXPEDCODCOLCFO>
    <EXPEDCODCFO>{{expedidor_cfo}}</EXPEDCODCFO>
    <TIPORECEBEDOR>C</TIPORECEBEDOR>
    <RECEBCODCOLCFO>{{recebedor_col_cfo}}</RECEBCODCOLCFO>
    <RECEBCODCFO>{{recebedor_cfo}}</RECEBCODCFO>
    <LOTACAO>1</LOTACAO>
    <TIPOTRANSPORTADORMDFE>0</TIPOTRANSPORTADORMDFE>
    <TIPOBPE>0</TIPOBPE>
  </TMOVTRANSP>  
  {% endif %}
</MovMovimento>
"""

str_sql = """SELECT f_get_dados_integracao_totvs as dados_doc
             FROM f_get_dados_integracao_totvs(%i,%i) """ % (p_id_documento, p_tipo_documento)
                    

resultado = plpy.execute(str_sql)                    

if len(resultado)>0:

    dados = json.loads(resultado[0]['dados_doc'])
    
    plpy.notice(dados)
    if p_tipo_documento in (1,2):
        doc_totvs = TEMPLATE_ENVIRONMENT.from_string(tpl_totvs).render(dados)
    else:
        doc_totvs = TEMPLATE_ENVIRONMENT.from_string(tpl_produto).render(dados)

    return doc_totvs

return None
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;
ALTER FUNCTION public.fpy_get_doc_xml_totvs(integer, integer)
  OWNER TO softlog_aeroprest;
