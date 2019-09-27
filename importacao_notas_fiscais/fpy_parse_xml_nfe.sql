CREATE OR REPLACE FUNCTION public.fpy_parse_xml_nfe(xml text)
  RETURNS json AS
$BODY$
import xmltodict
import json 
import traceback

#a = open('C:\\Python\\projetos\\parse_nfe_xml\\31150771015853000145550020000619111004309337.xml')
#a = open('C:\\Python\\projetos\\parse_nfe_xml\\teste.xml')

xml2 = xml.replace('version=1.0','version="1.0"')
xml2 = xml2.replace('encoding=UTF-8','encoding="UTF-8"')
xml2 = xml2.replace('</nfeProc>>','</nfeProc>')

             
if xml2.find('<?xml version="1.0" encoding="utf-8"?><NFe') > -1:
    xml2 = xml2.replace('<?xml version="1.0" encoding="utf-8"?><NFe','<?xml version="1.0" encoding="utf-8"?><nfeProc><NFe')
    xml2 = xml2 + '</nfeProc>'

if xml2.find('nfeProc') == -1:
    
    if not (xml2.find('<nNF>') == -1):
        plpy.notice('Nao achou <nfeProc>')
        xml2 = xml2.replace('<NFe','<nfeProc><NFe').replace('</NFe>','</NFe></nfeProc>')
        
        
try:
    xml_nfe = xmltodict.parse(xml2)
except:
    return None


try:
    info = {}
    info['chave_nfe'] = xml_nfe['procEventoNFe']['evento']['infEvento']['chNFe']
    info['tp_evento']  = xml_nfe['procEventoNFe']['retEvento']['infEvento']['tpEvento']
    info['cstat'] = xml_nfe['procEventoNFe']['retEvento']['infEvento']['cStat']
    plpy.notice(str(info))
    if info.get('tp_evento') == '110111' and info.get('cstat') == '135':
        retorno = json.dumps(info)
        return retorno
except: 
    pass
    #plpy.notice('Deu erro aqui')   
    #plpy.notice(traceback.format_exc())


    
p = dict()
nfe = dict()
#a.close()

try:
    valida = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['xNome']
except:
    return None



lst_part = []


#Dados do Emitente/Remetente
try:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['CPF']

emit_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['xNome'].replace('&','e')
p['part_logradouro'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['xLgr'].replace('&','e')
p['part_numero'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['nro']
p['part_bairro'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['cMun']
emit_cod_mun = p['part_cod_mun']
p['part_uf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['UF']
p['part_cep'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('CEP')
p['part_pais'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('xPais')
p['part_fone'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('fone')
p['part_ie'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['IE']
lst_part.append(p)

#Dados do Destinatario
p = dict()

try:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('CPF')


    

dest_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['xNome'].replace('&','e')
p['part_logradouro'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['xLgr'].replace('&','e')
p['part_numero'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['nro']
p['part_bairro'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['cMun']
dest_cod_mun = p['part_cod_mun']
p['part_uf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['UF']
p['part_cep'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('CEP')
p['part_pais'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('xPais')
p['part_fone'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('fone')
try:
    p['part_ie'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('IE')
except:
    pass
p['part_email'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('email')
lst_part.append(p)

#dados da Nota Fiscal

n = {}

##Chave da NFe
try:
    n['nfe_chave_nfe'] = xml_nfe['nfeProc']['protNFe']['infProt']['chNFe']
except:
    try:
        n['nfe_chave_nfe'] = xml_nfe['nfeProc']['NFe']['infNFe']['@Id'][-44:]
    except:
        pass

##informacoes de remetente/destinatario
n['nfe_emit_cnpj_cpf'] = emit_cnpj
n['nfe_emit_cod_mun']  = emit_cod_mun
n['nfe_dest_cnpj_cpf'] = dest_cnpj
n['nfe_dest_cod_mun']  = dest_cod_mun

##informacoes gerais
onf = xml_nfe['nfeProc']['NFe']['infNFe']['ide']
n['nfe_data_emissao_hr'] = onf.get('dhEmi')
n['nfe_data_emissao'] = onf.get('dhEmi')
n['nfe_pagador_cnpj_cpf'] = onf.get('pagador_cnpj')

try:
    n['nfe_id_nota_fiscal_parceiro'] = onf.get('id_nota_fiscal_parceiro')
    n['nfe_codigo_softlog_parceiro'] = onf.get('codigo_softlog_parceiro')
    n['nfe_id_conhecimento_notas_fiscais'] = onf.get('id_conhecimento_notas_fiscais')
    n['nfe_id_conhecimento_parceiro'] = onf.get('id_conhecimento_parceiro')
    n['nfe_codigo_integracao'] = onf.get('codigo_integracao')
    n['chave_cte'] = onf.get('chave_cte')
except:
    pass

if n['nfe_data_emissao'] is None:
    n['nfe_data_emissao'] = onf.get('dEmi')
n['nfe_numero_doc'] = onf.get('nNF')
n['nfe_modelo'] = onf.get('mod')
n['nfe_serie'] = onf.get('serie')
n['nfe_tp_nf'] = onf.get('tpNF')
n['nfe_ind_final'] = onf.get('indFinal')
n['nfe_ie_dest'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('indIEDest')
n['nfe_origem_cod_mun']  = onf.get('cMunIni')
try:
    info = xml_nfe['nfeProc']['NFe']['infNFe']['infAdic']['infCpl']    
except:
    info = ""
    pass

try:
    natop = onf.get('natOp').upper()
except:
    natop = None
    
##valores
onf = xml_nfe['nfeProc']['NFe']['infNFe']['total']['ICMSTot']

if natop == 'INDUSTRIALIZACAO':
    n['nfe_valor'] = '0.00'
    n['nfe_valor_produtos'] = '0.00'
else:
    n['nfe_valor'] = onf.get('vNF')
    n['nfe_valor_produtos'] = onf.get('vProd')

    
n['nfe_valor_bc'] = onf.get('vBC')
n['nfe_valor_icms'] = onf.get('vICMS')
n['nfe_valor_bc_st'] = onf.get('vBCST')
n['nfe_valor_icms_st'] = onf.get('vST')


##informacoes relativas ao transporte
try:
    n['nfe_transportador_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['transporta'].get('CNPJ')
except:
    pass

try:
    n['nfe_modo_frete'] = xml_nfe['nfeProc']['NFe']['infNFe']['transp'].get('modFrete')
except:
    pass

try:
    placa = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['placa']
    n['nfe_placa_veiculo'] = placa[0:8]
except:
    pass

try:
    #Em alguns casos reboque pode ser uma lista com mais de um veiculo
    onf = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['reboque']
    if str(type(onf)) == "<class 'list'>":
        reboque1 = onf[0].get('placa')
    else:
        reboque1 = onf.get('placa')

    n['nfe_placa_reboque1'] = reboque1[0:8]

except:
    pass

try:
    reboque2 = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['reboque'][1]['placa']
    n['nfe_placa_reboque1'] = reboque2[0:8]
except:
    pass

## Coleta de dados
peso_presumido = '0 '
peso_liquido = '0 '
vol_presumido = '0 '

try:
    #Em alguns casos, vol pode vir em mais de um item
    onf = xml_nfe['nfeProc']['NFe']['infNFe']['transp'].get('vol')

    if str(type(onf)) == "<class 'list'>":
        for v in onf:
            peso_item = v.get('pesoB') or v.get('pesoL') or '0'
            peso_liquido_item = v.get('pesoL') or v.get('pesoB') or '0'
            vol_item = v.get('qVol') or '0'

            peso_presumido = peso_presumido + ' + ' + peso_item
            peso_liquido = peso_liquido + ' + ' + peso_liquido_item
            vol_presumido = vol_presumido + ' + ' + vol_item
    else:
            peso_item = onf.get('pesoB') or onf.get('pesoL') or '0'
            peso_liquido_item = onf.get('pesoL') or onf.get('pesoB') or '0'
            vol_item = onf.get('qVol') or '0'

            peso_presumido = peso_presumido + ' + ' + peso_item
            peso_liquido = peso_liquido + ' + ' + peso_liquido_item
            vol_presumido = vol_presumido + ' + ' + vol_item
except:
    pass

if natop == 'INDUSTRIALIZACAO':
    n['nfe_peso_presumido'] = '0.00'
    n['nfe_peso_liquido'] = '0.00'
    n['nfe_volume_presumido'] = '0.00'
else:
    n['nfe_peso_presumido'] = peso_presumido
    n['nfe_peso_liquido'] = peso_liquido
    n['nfe_volume_presumido'] = vol_presumido



## Informacoes dos Itens de Produto
peso = '0 '
volume = '0 '
especie_mercadoria = '0 '
cfop = None
lst_unidades = []

onf = xml_nfe['nfeProc']['NFe']['infNFe']['det']

descProd = ""
#Testa se tem mais de um produto
if str(type(onf)) == "<class 'list'>":
    for prod in onf:
        peso_item = prod['prod'].get('qCom')
        peso = peso + ' + ' + peso_item

        unidade = prod['prod'].get('uCom')
        if unidade not in lst_unidades:
            lst_unidades.append(unidade)

        cfop = cfop or prod['prod'].get('CFOP')

        try:
            xprod = prod['prod']['xProd']
            descProd = descProd + ' - ' + xprod.replace("'","")
        except:
            descProd = ""
else:
        peso_item = onf['prod'].get('qCom')
        peso = peso +  '+' + peso_item

        unidade = onf['prod'].get('uCom')
        if unidade not in lst_unidades:
            lst_unidades.append(unidade)

        cfop = cfop or onf['prod'].get('CFOP')

        try:
            xprod = onf['prod']['xProd']
            descProd = descProd + ' - ' + xprod.replace("'","")
        except:
            descProd = ""

if info is None:
    info = ""
    
n['nfe_informacoes'] = info.replace("'","") + ' - ' + descProd



n['nfe_volume_produtos'] = peso
n['nfe_peso_produtos'] = peso
try:
    n['nfe_unidade'] = lst_unidades[0]
except:
    n['nfe_unidade'] = 'UN'

n['nfe_especie_mercadoria'] = ','.join(lst_unidades)
n['nfe_especie_mercadoria'] = n['nfe_especie_mercadoria'][0:30]
n['nfe_cfop_predominante'] = cfop	

nfe['dados_nota'] = n
nfe['remetente'] = lst_part[0]
nfe['destinatario'] = lst_part[1]

retorno = json.dumps(nfe)
return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_parse_xml_nfe(xml text)  OWNER TO softlog_unitylog;