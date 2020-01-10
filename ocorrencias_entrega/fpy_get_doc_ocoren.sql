CREATE OR REPLACE FUNCTION fpy_get_doc_ocoren(arquivo text)
  RETURNS json AS
$BODY$
    import re
    import traceback
    import json
    #import requests
    from doc_parser import DocParser
    from time import sleep
    	
    participantes = []
    nfs = []

    #Cria objetos de parser para cada tipo de registro
    struct = (3,35,35,6,4,12,25)
    reg_000 = DocParser.make_parser(struct)

    reg_340 = DocParser.make_parser((3,14,103))
    reg_341 = DocParser.make_parser((3,14,40,63))
    
    reg_342 = DocParser.make_parser((3,14,3,8,44,2,8,4,2,70,6))
    
    
    

    
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
    for linha in linhas2:
        #plpy.notice(linha)
        if linha[0:3] == '342':
            tamanho = len(linha)
            plpy.notice('Tamanho %i' % tamanho)
            #plpy.notice(linha)
            break

    i = -1
    for linha in linhas2: 
        i = i + 1
        id_reg = linha[0:3]

        if id_reg == '000':
            registros.append(reg_000(linha))

        elif id_reg == '340':
            registros.append(reg_340(linha))

        elif id_reg == '341':
            registros.append(reg_341(linha))

        elif id_reg == '342':
            registros.append(reg_342(linha))
            

    #Ler o conteudo dos registros parseados
    i = 0
    lista_oco = []
    transportador = ""
    for r in registros:

        if len(r) == 0:
            i = i + 1
            continue

        id = r[0]


        if id in ('000','310'):
            i = i + 1            
            continue


        if id == '341':            
            transportador = r[1]
            continue


        if id == '342':
            print('Dados da Ocorrência de Entrega')
            
            #Ocorrencias de entrega
            
            oco = dict()            
            oco['transportador'] = transportador
            oco['remetente'] = r[1]
            oco['serie_nota_fiscal'] = r[2]
            oco['numero_nota_fiscal'] = r[3]
            oco['chave_nfe'] = r[4]
            oco['id_ocorrencia'] = r[5]
            oco['data_ocorrencia'] = r[6][-4:] + '-' + r[6][-6:4] + '-' + r[6][0:2]
            oco['hora_ocorrencia'] = r[7][0:2] + ':' + r[7][-2:] + ':00' 
      
            lista_oco.append(oco)
            

      
        i = i + 1

    dados = {'ocorrencias':lista_oco }        

    #plpy.notice(json.dumps(dados))
    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;

--ALTER FUNCTION fpy_get_doc_notfis(arquivo text) OWNER TO softlog_3glog;
