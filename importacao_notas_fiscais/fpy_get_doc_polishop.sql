-- Function: public.fpy_get_doc_polishop(text)

-- DROP FUNCTION public.fpy_get_doc_polishop(text);

CREATE OR REPLACE FUNCTION public.fpy_get_doc_polishop(arquivo text)
  RETURNS json AS
$BODY$

    import traceback
    import xmltodict
    import json
    import re
    import json
    import requests
    from time import sleep 
    from collections import OrderedDict    

    def get_viacep(cep):
        r = plpy.execute("SELECT cod_ibge FROM cep WHERE cep = '%s'"%(cep))
        if (r.nrows() > 0):            
            return r[0]['cod_ibge']
        else:
            return ''
		
    EXP = '[^\x09\x0A\x0D\x20-\x7E\xE1\xE0\xE2\xE3\xE4\xE9\xE8\xEA\xEB\xED\xEC\xEF\xF3\xF2\xF4\xF5\xF6\xFA\xF9\xFB\xFC\xC1\xC0\xC2\xC3\xC4\xC9\xC8\xCA\xCB\xCD\xCC\xCF\xD3\xD2\xD4\xD5\xD6\xDA\xD9\xDB\xDC\xE7\xC7\x26]'


    #arquivo = "C:\\Python\\projetos\\parse_xml_polishop\\exemplo.xml"

    dteste = OrderedDict()
    #a = open(arquivo)
    #texto = a.read()
    #a.close()

    try:
        xml_nfe = xmltodict.parse(arquivo)
    except:
        k = arquivo.find('<?xml version="1.0" encoding="ISO-8859-1"?>',2)
        arquivo2 = arquivo[0:k]
        xml_nfe = xmltodict.parse(arquivo2)

    entregas = xml_nfe['expedicao'].get('entregar')  
    if type(entregas) == type(dteste):
        entregas = [entregas]
    
    plpy.notice("Entregas Tipo " + str(type(entregas)))

    coletas = xml_nfe['expedicao'].get('coletar')
    if type(coletas) == type(dteste):
        coletas = [coletas]
    plpy.notice("Coletas Tipo " + str(type(coletas)))
    
    if coletas is None:
        coletas = []

    if entregas is None:
        entregas = []
    entregas = entregas + coletas
    
    numero_romaneio = xml_nfe['expedicao']['doc_expedidor']

    if not str(type(entregas)) == "<class 'list'>":
        entregas = [entregas]

    lst_part = []
    lst_nf = []

    for ent in entregas:

        #Dados do Destinatario
        dest = ent['fisco']['cabecalho']
        p = dict()


        p['part_cnpj_cpf'] = dest.get('cpf_cnpj')
        dest_cnpj = p['part_cnpj_cpf']

        p['part_nome'] = dest.get('nome').replace('&','e')
        p['part_logradouro'] = dest.get('endereco').replace('&','e')
        p['part_numero'] = dest.get('numero')
        p['part_bairro'] = dest.get('bairro').replace('&','e')    
        
        p['part_cidade'] = dest.get('cidade')
        p['part_uf'] = dest.get('estado')
        p['part_cep'] = dest.get('cep')

        dest_cod_mun = get_viacep(p['part_cep'])
        p['part_cod_mun'] = dest_cod_mun
	
        p['part_pais'] = 'BRASIL'
        p['part_ie'] = dest.get('rg_ie')

        if ent['pedido'].get('DDD1') is not None:
            p['part_fone'] = ent['pedido'].get('DDD1').replace('(','').replace(')','')
            p['part_fone'] = p['part_fone'] + ent['pedido'].get('fone1')
        elif ent['pedido'].get('DDD2') is not None:
            p['part_fone'] = ent['pedido'].get('DDD2').replace('(','').replace(')','')
            p['part_fone'] = p['part_fone'] + ent['pedido'].get('fone2')
        elif ent['pedido'].get('DDD3') is not None:
            p['part_fone'] = ent['pedido'].get('DDD3').replace('(','').replace(')','')
            p['part_fone'] = p['part_fone'] + ent['pedido'].get('fone3')
        elif ent['pedido'].get('DDD4') is not None:
            p['part_fone'] = ent['pedido'].get('DDD4').replace('(','').replace(')','')
            p['part_fone'] = p['part_fone'] + ent['pedido'].get('fone4')
        else:
            p['part_fone'] = None

        p['part_email'] = ent['pedido']['email']


        lst_part.append(p)

        #dados da Nota Fiscal

        n = {}

        nfe = ent['fisco']['cabecalho']

        ##Chave da NFe
        n['nfe_chave_nfe'] = nfe.get('chavenfe')


        ##
        ##informacoes de remetente/destinatario
        n['nfe_emit_cnpj_cpf'] = nfe.get('emitente')
        n['nfe_emit_cod_mun']  = ''

        n['nfe_dest_cnpj_cpf'] = dest_cnpj
        n['nfe_dest_cod_mun']  = dest_cod_mun

        ##
        ##informacoes gerais
        n['nfe_numero_pedido'] = ent['pedido']['numero']
        n['nfe_numero_romaneio'] = numero_romaneio
        n['nfe_data_emissao_hr'] = None
        dt_emi = nfe.get('emissao')

        n['nfe_data_emissao'] = dt_emi[-4:] + '-' + dt_emi[3:5] + '-' + dt_emi[0:2]
        n['nfe_numero_doc'] = nfe.get('notafiscal')
        n['nfe_modelo'] = '0' #Verificar se e assim mesmo
        n['nfe_serie'] = nfe.get('serie')

        #n['nfe_tp_nf'] = onf.get('tpNF')
        #n['nfe_ind_final'] = onf.get('indFinal')

        #n['nfe_ie_dest'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('indIEDest')

        ####valores
        n['nfe_valor'] = nfe.get('valor').replace('.','').replace(',','.')
        n['nfe_valor_bc'] = nfe.get('valor').replace('.','').replace(',','.')
        n['nfe_valor_icms'] = nfe.get('icms').replace('.','').replace(',','.')
        n['nfe_valor_bc_st'] = nfe.get('valor').replace('.','').replace(',','.')
        n['nfe_valor_icms_st'] = nfe.get('icmssubstituicao').replace('.','').replace(',','.')
        n['nfe_valor_produtos'] = nfe.get('valor').replace('.','').replace(',','.')

        ##informacoes relativas ao transporte
        n['nfe_transportador_cnpj_cpf'] = ent['fisco']['transporte'].get('cnpj')

        mod_frete =  ent['fisco']['transporte'].get('freteporconta')

        #TODO Conferir se eh isto mesmo
        if mod_frete == 'EMITENTE':
            n['nfe_modo_frete'] = '0'
        else:
            n['nfe_mod_frete'] = '1'

        n['nfe_peso_presumido'] = ent['fisco']['transporte'].get('peso').replace('.','').replace(',','.')
        n['nfe_peso_liquido'] = ent['fisco']['transporte'].get('peso').replace('.','').replace(',','.')        
        n['nfe_volume_presumido'] = ent['fisco']['transporte'].get('volumes').replace('.','').replace(',','.')
        n['nfe_volume_cubico'] = ent['fisco']['transporte'].get('cubagem').replace('.','').replace(',','.')
        

        nf_itens = ent['fisco']['itens']

    ##    if not str(type(nf_itens)) == "<class 'list'>":
    ##        nf_itens = [nf_itens]

        n['nfe_especie_mercadoria'] = 'UN'
        n['nfe_unidade'] = 'UN'
        n['nfe_volume_produtos'] = n['nfe_volume_presumido']
        n['nfe_peso_produtos'] = n['nfe_peso_presumido']

        n['nfe_cfop_predominante'] = nfe.get('operacaofiscal')

        lst_nf.append(n)

    dados = {'participantes':lst_part,
             'nfs':lst_nf
    }

    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

