/*
SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 100

SELECT fpy_get_doc_notfis(doc_xml), doc_xml FROM scr_doc_integracao WHERE id_doc_integracao = 3217

	SELECT fpy_get_doc_notfis_50('')

*/
--DROP FUNCTION fpy_get_doc_notfis(arquivo text)



CREATE OR REPLACE FUNCTION fpy_get_doc_notfis_50(arquivo text)
  RETURNS json AS
$BODY$
    import re
    import traceback
    import json
    #import requests
    from doc_parser import DocParser
    from time import sleep


    def get_viacep(cep):
        r = plpy.execute("SELECT cod_ibge FROM cep WHERE cep = '%s'"%(cep))
        if (r.nrows() > 0):
            #plpy.notice('Encontrei Cep %s' % cep)
            return r[0]['cod_ibge']
        else:
            #plpy.notice('Nao Encontrei Cep %s' % cep)
            return ''
	
    participantes = []
    nfs = []

    #Cria objetos de parser para cada tipo de registro
    struct = (3,35,35,6,4,12,244)
    reg_000 = DocParser.make_parser(struct)
    reg_500 = DocParser.make_parser((3,14,322))
    reg_501 = DocParser.make_parser((3,50,14,15,15,15,50,35,35,9,9,9,8,4,25,43))
        
    reg_502 = DocParser.make_parser((3,50,14,50,35,35,9,9,9,35,4,86))

    reg_503 = DocParser.make_parser((3,50,14,15,15,50,35,35,9,9,9,35,4,4,1,1,50))

    reg_504 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,4,4,1,1,65))

    reg_505 = DocParser.make_parser((3,3,9,8,15,15,7,1,1,1,1,8,10,1,1,1,4,2,1,10,2,20,20,20,20,20,1,8,4,8,4,9,45,15,1,40))

    reg_506 = DocParser.make_parser((3,8,9,9,10,10,1,1,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,13,13,13,24))

    reg_507 = DocParser.make_parser((3,8,9,10,10,15,15,15,15,15,15,15,15,15,15,15,5,15,1,15,5,15,15,5,15,15,3,4,2,20))

    reg_508 = DocParser.make_parser((3,50,50,50,186))

    reg_509 = DocParser.make_parser((3,14,50,3,9,14,50,3,9,14,50,3,9,10,5,12,14,67))

    reg_511 = DocParser.make_parser((3,8,15,20,50,4,20,8,50,50,50,20,41))

    reg_513 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,75))

    reg_514 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,4,71))

    reg_515 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,75))

    reg_516 = DocParser.make_parser((3,3,9,44,8,9,10,15,15,15,15,15,15,15,15,15,15,5,15,1,15,5,15,15,5,15,15,5))

    reg_519 = DocParser.make_parser((3,15,15,15,10,281))

    #a = open(filename,'r',encoding='utf-8')
    #linhas = a.readlines()
    #a.close()

    linhas = arquivo.split('\n')

    #Faz o parser de cada linha, de acordo com o seu tipo de registro
    registros = []
    linhas2 = []

    i = -1
    for linha in linhas:        
        i = i + 1        
        #plpy.notice('Linha %i',i)
        reg = linhas[i]        
        while 1:
            if reg.find("\r\r") == -1:
                break
            reg = reg.replace('\r\r','\r')
            
        if reg.strip() != '':
            #plpy.notice('Adicionado')         
            linhas2.append(reg)
            #plpy.notice(reg)
           
            
    i = -1 
    tamanho = 0
    #for linha in linhas2:
        #plpy.notice(linha)
        #if linha[0:3] == '313':
            #tamanho = len(linha)
            #plpy.notice('Tamanho %i' % tamanho)
            #plpy.notice(linha)
            #break

    i = -1   
    
    c_501 = -1
    c_502 = -1
    c_503 = -1
    c_505 = -1
    c_506 = -1
    c_507 = -1
    c_516 = -1
   
    
    for linha in linhas2:    
        i = i + 1
        id_reg = linha[0:3]

        if id_reg == '000':
            registros.append((i,reg_000(linha)))

        elif id_reg == '500':
            registros.append((i,reg_500(linha)))

        elif id_reg == '501':
            #plpy.notice('Tamanho %i'% tamanho)
            
            registros.append((i,reg_501(linha)))

        elif id_reg == '502':
            registros.append((i,reg_502(linha)))

        elif id_reg == '503':
            registros.append((i,reg_503(linha)))

        elif id_reg == '504':
            
            registros.append((i,reg_504(linha)))

        elif id_reg == '505':
            c_505 = c_505 + 1
            nfs.append({})
            registros.append((c_505,reg_505(linha)))

        elif id_reg == '506':
            c_506 = c_506 + 1
            registros.append((c_506,reg_506(linha)))

        elif id_reg == '507':
            c_507 = c_507 + 1
            registros.append((c_507,reg_507(linha)))

        elif id_reg == '508':
            registros.append((i,reg_508(linha)))

        elif id_reg == '509':
            registros.append((i,reg_509(linha)))
            
        elif id_reg == '511':
            registros.append((i,reg_511(linha)))

        elif id_reg == '513':
            registros.append((i,reg_513(linha)))

        elif id_reg == '514':
            registros.append((i,reg_514(linha)))
            
        elif id_reg == '515':
            registros.append((i,reg_515(linha)))
            
        elif id_reg == '516':
            c_516 = c_516 + 1
            registros.append((c_516,reg_516(linha)))

        elif id_reg == '519':
            registros.append((i,reg_519(linha)))

    #Ler o conteudo dos registros parseados
    i = 0
    for grupo, r in registros:

        if len(r) == 0:
            i = i + 1
            continue

        id = r[0]


        if id in ('000','500', '502'):
            i = i + 1            
            continue


        if id == '501':
            nfe_pagador_cnpj_cpf = None
            emit_cnpj = r[2].strip()
            emit_cod_mun = None
            
            #plpy.notice('CNPJ %s',emit_cnpj)                      
            
            p = {}
            p['part_cnpj_cpf'] = r[2].strip().upper()               

            emit_cnpj = p['part_cnpj_cpf']
            p['part_nome'] = r[1].strip().upper()
            p['part_logradouro'] = r[6].strip().upper()
            p['part_numero'] = ''
            p['part_bairro'] = r[7].strip().upper()
            p['part_cidade'] = r[8].strip().upper()
            p['part_cod_mun'] = r[10]
            p['part_uf'] = r[11].strip().upper()
            p['part_cep'] = r[9].strip().upper()
            p['part_pais'] = ''
            p['part_fone'] = r[14].strip().upper()
            p['part_ie'] = r[3].strip().upper()
                

            if p['part_cod_mun'].strip() == '':
                try:
                    p['part_cod_mun'] = get_viacep(p['part_cep'])
                except:
                    pass

            emit_cod_mun = nfe_pagador_cnpj_cpf = p['part_cod_mun']
            

            participantes.append(p)
            
            i = i + 1
            continue


        if id == '503':
            #print('Dados do Destinatario')
            #Dados do Destinatario
            p = dict()

            tipo_pessoa = r[14].strip().upper()

            dest_cnpj = r[2].strip().upper()
            if tipo_pessoa == '2':
                dest_cnpj = dest_cnpj[-11:]
                
            p['part_cnpj_cpf'] = dest_cnpj

            p['part_nome'] = r[1].strip().upper()
            p['part_logradouro'] = r[5].strip().upper()
            p['part_numero'] = ''
            p['part_bairro'] = r[6].strip().upper()
            p['part_cidade'] = r[7].strip().upper()
            p['part_cod_mun'] = r[9].strip().upper()            
            p['part_uf'] = r[10].strip().upper()
            p['part_cep'] = r[8].strip().upper()
            p['part_pais'] = ''
            p['part_fone'] = r[11].strip().upper()
            p['part_ie'] = r[3].strip().upper()
            participantes.append(p)


            if p['part_cod_mun'].strip() == '':
                try:
                    p['part_cod_mun'] = get_viacep(p['part_cep'])
                except:
                    pass

            dest_cod_mun = p['part_cod_mun']        
	    

        if id == '516':

            nfs[grupo]['chave_cte'] = r[3] 
            nfs[grupo]['nfe_pagador_cnpj_cpf'] = nfs[grupo]['chave_cte'][6:20]
            nfs[grupo]['nfe_valor_cte_origem'] = r[8][:-2] + '.' + r[8][-2:]
            nfe_pagador_cnpj_cpf = nfs[grupo]['chave_cte'][6:20]
            
        if id == '505':
            print('Dados da Nota Fiscal')

            
            
            ##Chave da NFe

            #n['nfe_pagador_cnpj_cpf'] = nfe_pagador_cnpj_cpf
            #plpy.notice(str(len(r)))

            ##informacoes de remetente/destinatario
            nfs[grupo]['nfe_emit_cnpj_cpf'] = emit_cnpj
            nfs[grupo]['nfe_emit_cod_mun']  = emit_cod_mun
            nfs[grupo]['nfe_dest_cnpj_cpf'] = dest_cnpj
            nfs[grupo]['nfe_dest_cod_mun']  = dest_cod_mun

            ##informacoes gerais

            de = r[3]
            nfs[grupo]['nfe_data_emissao'] = de[-4:] + '-' + de[2:4] + '-' + de[0:2]
            nfs[grupo]['nfe_numero_doc'] = r[2]
            nfs[grupo]['nfe_modelo'] = '55'
            nfs[grupo]['nfe_serie'] = r[1]
            nfs[grupo]['nfe_ie_dest'] = p['part_ie']
            nfs[grupo]['nfe_numero_pedido'] = r[22].strip()

            nfs[grupo]['nfe_chave_nfe'] = r[32][0:44]

            ##informacoes relativas ao transporte
            if r[10] == 'C':
                nfs[grupo]['nfe_modo_frete'] = '0'
            else:
                nfs[grupo]['nfe_modo_frete'] = '1'            

            nfs[grupo]['nfe_cfop_predominante'] = r[16]

        if id == '506':
            nfs[grupo]['nfe_valor'] = r[9][:-2] + '.' + r[9][-2:]

            nfs[grupo]['nfe_valor_bc'] = '0.00'
            nfs[grupo]['nfe_valor_icms'] = '0.00'
            nfs[grupo]['nfe_valor_bc_st'] = '0.00'
            nfs[grupo]['nfe_valor_icms_st'] = '0.00'
            nfs[grupo]['nfe_valor_produtos'] = r[13][:-2] + '.' + r[13][-2:]

        if id == '507':
                    
            nfs[grupo]['nfe_valor_frete'] = r[5][:-2] + '.' + r[5][-2:]
            
            nfs[grupo]['nfe_peso_presumido'] = r[2][:-3] + '.' + r[2][-3:]
            nfs[grupo]['nfe_peso_liquido'] = r[2][:-3] + '.' + r[2][-3:]
            nfs[grupo]['nfe_volume_presumido'] = r[1][:-2] 

            ## Informacoes dos Itens de Produto
            nfs[grupo]['nfe_volume_produtos'] = r[1][:-2] 
            nfs[grupo]['nfe_peso_produtos'] = r[2][:-3] + '.' + r[2][-3:]
            nfs[grupo]['nfe_unidade'] = 'UN'

            nfs[grupo]['nfe_especie_mercadoria'] = 'DIVERSOS'            

        i = i + 1

    dados = {'participantes':participantes,
             'nfs':nfs
    }        
    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;



