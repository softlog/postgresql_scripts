
CREATE OR REPLACE FUNCTION public.fpy_parse_xml_cte(xml_cte text)
  RETURNS json AS
$BODY$


import traceback
import xmltodict
from decimal import Decimal
from collections import OrderedDict
import json


#a = open('C:\\Python\\projetos\\parse_nfe_xml\\31150771015853000145550020000619111004309337.xml')
#a = open('C:\\Python\\projetos\\parse_nfe_xml\\teste.xml')


try:
    xml = xmltodict.parse(xml_cte)
except:
    return None

lst_part = []
#Dados do Remetente
p = dict()
try:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['rem']['CNPJ']    
except:
    plpy.notice(traceback.format_exc())
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['rem']['CPF']

emit_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml['cteProc']['CTe']['infCte']['rem']['xNome'].replace('&','e')
p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['xLgr'].replace('&','e')
p['part_numero'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['nro']
p['part_bairro'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['cMun']
emit_cod_mun = p['part_cod_mun']
p['part_uf'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['UF']
p['part_cep'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme'].get('CEP')
p['part_pais'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme'].get('xPais')
p['part_fone'] = xml['cteProc']['CTe']['infCte']['rem'].get('fone')
try:
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['rem']['IE']
except:
    p['part_ie'] = None
    
lst_part.append(p)


#Dados do Destinatario
p = dict()
try:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['dest']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['dest']['CPF']

dest_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml['cteProc']['CTe']['infCte']['dest']['xNome'].replace('&','e')
p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['xLgr'].replace('&','e')
p['part_numero'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['nro']
p['part_bairro'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['cMun']
dest_cod_mun = p['part_cod_mun']
p['part_uf'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['UF']
p['part_cep'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('CEP')
p['part_pais'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('xPais')
p['part_fone'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('fone')
try:
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['dest'].get('IE')
except:
    pass
p['part_email'] = xml['cteProc']['CTe']['infCte']['dest'].get('email')
lst_part.append(p)

#Dados do Emitente/Transportador
try:
    tomador = xml['cteProc']['CTe']['infCte']['ide']['toma4'].get('toma')

    p = dict()
    try:
        p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['CNPJ']
    except:    
        p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['CPF']

    pagador_cnpj = p['part_cnpj_cpf']

    p['part_nome'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['xNome'].replace('&','e')
    p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma']['xLgr'].replace('&','e')
    p['part_numero'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma'].get('nro')
    p['part_bairro'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma']['xBairro'].replace('&','e')
    p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma']['cMun']

    pagador_cod_mun = p['part_cod_mun']
    p['part_uf'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma']['UF']
    p['part_cep'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma'].get('CEP')
    p['part_pais'] = xml['cteProc']['CTe']['infCte']['ide']['toma4']['enderToma'].get('xPais')    
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['ide']['toma4'].get('IE')
    lst_part.append(p)    

    
except:
    p = dict()
    try:
        p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['emit']['CNPJ']
    except:    
        p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['emit']['CPF']

    pagador_cnpj = p['part_cnpj_cpf']

    p['part_nome'] = xml['cteProc']['CTe']['infCte']['emit']['xNome'].replace('&','e')
    p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['xLgr'].replace('&','e')
    p['part_numero'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['nro']
    p['part_bairro'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['xBairro'].replace('&','e')
    p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['cMun']

    pagador_cod_mun = p['part_cod_mun']
    p['part_uf'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['UF']
    p['part_cep'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit'].get('CEP')
    p['part_pais'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit'].get('xPais')
    p['part_fone'] = xml['cteProc']['CTe']['infCte']['emit'].get('fone')
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['emit']['IE']
    lst_part.append(p)    


#dados da Nota Fiscal

n = {}


try:
    infNFe = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infDoc']['infNFe'] 

    if type(infNFe) == type([]):
        lista_nfe = [ x['chave'] for x in infNFe]
    else:
        nfes = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infDoc']['infNFe']['chave']

        if type(nfes) == type(""):
            lista_nfe = []
            lista_nfe.append(nfes)

        elif  type(nfes) == type([]):
            lista_nfe = [x for x in nfes]
        else:
            lista_nfe = []
except:
    lista_nfe = []


total_nfe = len(lista_nfe)
valor_carga = Decimal(xml['cteProc']['CTe']['infCte']['infCTeNorm']['infCarga']['vCarga'])
valor_cte_origem = Decimal(xml['cteProc']['CTe']['infCte']['vPrest']['vTPrest'])
peso_carga = Decimal(0.00)

volume_carga = Decimal(0.00)

inf_c = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infCarga']['infQ']

if type(inf_c) == type(OrderedDict()):
    lista_inf = [inf_c]

if type(inf_c) == type([]):
    lista_inf = [x for x in inf_c]

for inf in lista_inf:
     #plpy.notice(str(inf))
    if inf['tpMed'].upper().find('PESO AFERIDO') > -1:   
        vl = inf.get('qCarga')
        if type(vl) == type([]):
            vl = vl[0]
        peso_carga = Decimal(vl)


    if peso_carga == Decimal(0.00) and inf['tpMed'].upper().find('PESO') > -1 and peso_carga == Decimal(0.00):
        vl = inf.get('qCarga')
        if type(vl) == type([]):
            vl = vl[0]

        #plpy.notice(inf.get('qCarga'))
        peso_carga = Decimal(vl)
        
    if volume_carga == Decimal(0.00) and inf['tpMed'].upper().find('VOLUME') > -1:
        #plpy.notice(inf.get('qCarga'))
        vl = inf.get('qCarga')
        if type(vl) == type([]):
            vl = vl[0]
        
        volume_carga = Decimal(vl)
        

notas_fiscais = []
for chave in lista_nfe:

    ##plpy.notice(chave)
    n = {}
    ##Chave do CTe
    try:
        n['chave_cte'] = xml['cteProc']['protCTe']['infProt']['chCTe']
    except: 
        try:
            n['chave_cte'] = xml['cteProc']['CTe']['infCte']['@Id'][-44:]
        except:
            pass

    n['nfe_valor_cte_origem'] = str(valor_cte_origem)
    
    n['nfe_chave_nfe'] = chave
    
    n['nfe_emit_cnpj_cpf'] = emit_cnpj
    n['nfe_emit_cod_mun']  = emit_cod_mun
    n['nfe_dest_cnpj_cpf'] = dest_cnpj
    n['nfe_dest_cod_mun']  = dest_cod_mun
    n['nfe_origem_cod_mun']  = xml['cteProc']['CTe']['infCte']['ide']['cMunIni']

    ##informacoes gerais
    onf = xml['cteProc']['CTe']['infCte']['ide']

    n['nfe_data_emissao_hr'] = onf.get('dhEmi')
    n['nfe_data_emissao'] = onf.get('dhEmi')
    n['nfe_pagador_cnpj_cpf'] = pagador_cnpj

    if n['nfe_data_emissao'] is None:
        n['nfe_data_emissao'] = onf.get('dEmi')



    n['nfe_numero_doc'] =  n['nfe_chave_nfe'][25:34]
    n['nfe_modelo'] = '55'
    n['nfe_serie'] = n['nfe_chave_nfe'][22:25]
    n['nfe_tp_nf'] = '1'
    n['nfe_ind_final'] = '0'
    n['nfe_ie_dest'] = '1'

    n['nfe_informacoes'] = ""

    ##valores
    n['nfe_valor'] = str(valor_carga/total_nfe)
    n['nfe_valor_bc'] = "0.00"
    n['nfe_valor_icms'] = "0.00"
    n['nfe_valor_bc_st'] = "0.00"
    n['nfe_valor_icms_st'] = "0.00"
    n['nfe_valor_produtos'] = str(valor_carga/total_nfe)


    ##informacoes relativas ao transporte
    try:
        n['nfe_modo_frete'] = "0"
    except:
        pass

    ## Coleta de dados
    peso_presumido = str(peso_carga/total_nfe)
    peso_liquido = str(peso_carga/total_nfe)
    vol_presumido = str(volume_carga/total_nfe)

    n['nfe_peso_presumido'] = peso_presumido
    n['nfe_peso_liquido'] = peso_liquido
    n['nfe_volume_presumido'] = vol_presumido
    

    ## Informacoes dos Itens de Produto
    n['nfe_volume_produtos'] = peso_presumido
    n['nfe_peso_produtos'] = peso_presumido
    n['nfe_unidade'] = 'UN'

    n['nfe_especie_mercadoria'] = "UN"
    n['nfe_especie_mercadoria'] = ""
    n['nfe_cfop_predominante'] = ""

    notas_fiscais.append(n)


dados = {'participantes':lst_part,
         'nfs':notas_fiscais}

retorno = json.dumps(dados)

return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_parse_xml_cte(xml text)  OWNER TO softlog_medilog;