CREATE OR REPLACE FUNCTION fpy_get_doc_notfis(arquivo text)
  RETURNS json AS
$BODY$
    import re
    import traceback
    import json
    #import requests
    from doc_parser import DocParser
    from time import sleep


    def valida_cpf(cpf):
        """ If cpf in the Brazilian format is valid, it returns True, otherwise, it returns False. """
        #plpy.notice(cpf)
        # Check if type is str
        if not isinstance(cpf,str):
            return False

        # Remove some unwanted characters
        cpf = re.sub("[^0-9]",'',cpf)

        # Checks if string has 11 characters
        if len(cpf) != 11:
            return False

        sum = 0
        weight = 10

        """ Calculating the first cpf check digit. """
        for n in range(9):
            sum = sum + int(cpf[n]) * weight

            # Decrement weight
            weight = weight - 1

        verifyingDigit = 11 -  sum % 11

        if verifyingDigit > 9 :
            firstVerifyingDigit = 0
        else:
            firstVerifyingDigit = verifyingDigit

        """ Calculating the second check digit of cpf. """
        sum = 0
        weight = 11
        for n in range(10):
            sum = sum + int(cpf[n]) * weight

            # Decrement weight
            weight = weight - 1

        verifyingDigit = 11 -  sum % 11

        if verifyingDigit > 9 :
            secondVerifyingDigit = 0
        else:
            secondVerifyingDigit = verifyingDigit

        if cpf[-2:] == "%s%s" % (firstVerifyingDigit,secondVerifyingDigit):
            return True
        return False

    def valida_chave_nfe(chave_nfe):

        peso = [4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, 0]

        if len(chave_nfe) != 44:
            return False

        soma = 0


        for p, c in zip(peso,list(chave_nfe)):
            soma = soma + (p * int(c))

        if (soma == 0):
            return False

        soma = soma - (11 * int((soma / 11)))

        if (soma==0) or (soma==1):
            verif = 0
        else:
            verif = 11 - soma

        if str(verif) == chave_nfe[43]:
            return True
        else:
            return False

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
    struct = (3,35,35,6,4,12,145)
    reg_000 = DocParser.make_parser(struct)
    reg_310 = DocParser.make_parser((3,14,223))
    reg_311 = DocParser.make_parser((3,14,15,40,35,9,9,8,40,67))

    
    
    
    # Customizacao SIMPRESS
    reg_311_SPSS = DocParser.make_parser((3,35,14,15,65,19,30,8,9,2,4,35,1))
    
    reg_312 = DocParser.make_parser((3,40,14,15,40,20,35,9,9,9,4,35,1,1,5))

    #Customizacao 360 Imprimir
    reg_312_360 = DocParser.make_parser((3,40,14,15,100,20,35,9,9,9,4,35,1,1,5))

    # Customizacao SIMPRESS
    reg_312_SPSS = DocParser.make_parser((3,35,14,15,65,19,30,8,9,2,4,35,1))
    
    reg_313 = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2))
    #Customizacao 360
    reg_313_360 = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2,44,10))

    # Customizacao Santa Cruz
    reg_313_SC = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,
                            1,1,15,15,7,1,15,15,15,15,1,12,12,1,6,6,6,44,15,6))

    #Customizacao AGV
    reg_313_AGV = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2, 10, 44))

    reg_313_AGV2 = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2, 10, 44,3,40,14,15,40,20,35,9,9,9,35,44))

    # Customizacao SIMPRESS    
    reg_313_SPSS = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,20,44))
    # Customizacao SOFTLOG
    reg_313_SOFTLOG = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,20,44,44))

    # Customizacao VIDA PURA
    reg_313_VIDA_PURA = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2,44))

    # Customizacao ZAP
    reg_313 = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,2))

    #Customizacao Pratti
    reg_313_pratti = DocParser.make_parser((3,15,7,1,1,1,1,3,8,8,15,15,7,15,7,5,1,
                                      1,15,15,7,1,15,15,15,15,1,12,12,1,44))    
    
    reg_333 = DocParser.make_parser((3,4,1,8,4,8,4,15,1,10,26,26,26,26,15,5,
                                                            5,10,5,12,5))

    

    reg_314 = DocParser.make_parser((3,7,15,30,7,15,30,7,15,30,7,15,30,29))
    reg_317 = DocParser.make_parser((3,40,14,15,40,20,35,9,9,9,35,44))
    
    reg_318 = DocParser.make_parser((3,40,14,15,40,20,35,9,9,9,35,11))
    reg_318_zap = DocParser.make_parser((3,126,44))

    reg_319 = DocParser.make_parser((3,20,7,7,7,7,7,7,40,4,20,44))

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
        plpy.notice(linha)
        if linha[0:3] == '313':
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

        elif id_reg == '310':
            registros.append(reg_310(linha))

        elif id_reg == '311':
            #plpy.notice('Tamanho %i'% tamanho)
            
            if linha[3:11] in  ('07432517') or tamanho == 303:                            
                emb_spss = True
            else:                
                emb_spss = False

            if tamanho in (346,347):
                emb_softlog = True
            else:
                emb_softlog = False

            if emb_softlog:
                registros.append(reg_311_SPSS(linha))
            else:
                registros.append(reg_311(linha))

            if linha[3:11] in ('21902826'):
                emb_360 = True
            else:
                emb_360 = False

        elif id_reg == '312':
            if emb_spss:                
                registros.append(reg_312_SPSS(linha))
            elif emb_softlog:  
                registros.append(reg_312_SPSS(linha))
            elif emb_360:
                registros.append(reg_312_360(linha))
            else:
                #plpython.notice(linha)
                registros.append(reg_312(linha))

        elif id_reg == '313':
            #plpy.notice('Funcionando aqui inicio')
            emb_pratti = False
            if emb_spss or len(linha) == 303:
                emb_spss = True
                #plpy.notice('LEIAUTE SIMPRESS')
                registros.append(reg_313_SPSS(linha))           
            elif emb_softlog:     
                #plpy.notice(reg_313_SOFTLOG(linha))
                #plpy.notice(linha)           
                emb_softlog = True
                registros.append(reg_313_SOFTLOG(linha))              
            elif len(linha) in (284,285):
                registros.append(reg_313_VIDA_PURA(linha))                

            elif len(linha) == 295 and not emb_360:
                registros.append(reg_313_AGV(linha))                                

            elif len(linha) == 295 and emb_360:
                registros.append(reg_313_360(linha))                

            elif len(linha) == 862:
                #plpy.notice(linha)
                registros.append(reg_313_AGV2(linha))
            elif len(linha) == 283:
                 emb_pratti = True
                 registros.append(reg_313_pratti(linha))
            elif len(linha) == 322 or len(linha) == 321:
                #plpy.notice('LEIAUTE SANTA CRUZ')
                registros.append(reg_313_SC(linha))
            else:
                #plpy.notice('LEIAUTE PADRAO')
                registros.append(reg_313(linha))
            #plpy.notice('Funcionando aqui fim')
        elif id_reg == '333':
            registros.append(reg_333(linha))

        elif id_reg == '314':
            registros.append(reg_314(linha))

        elif id_reg == '317':
            registros.append(reg_317(linha))
            
             
        elif id_reg == '318':
            ##plpy.notice(str(len(linha)))
            registros.append(reg_318_zap(linha))

        elif id_reg == '319':
            ##plpy.notice(str(len(linha)))
            registros.append(reg_319(linha))


    #Ler o conteudo dos registros parseados
    i = 0
    for r in registros:

        if len(r) == 0:
            i = i + 1
            continue

        id = r[0]


        if id in ('000','310'):
            i = i + 1            
            continue


        if id == '311':
            lst_notas = []
            nfe_pagador_cnpj_cpf = None
            emit_cnpj = r[1].strip()                             
            emit_cod_mun = None
            
            #plpy.notice('CNPJ %s',emit_cnpj)
      
            if emb_softlog:
                p = {}
                p['part_cnpj_cpf'] = r[2].strip().upper()               

                emit_cnpj = p['part_cnpj_cpf']
                p['part_nome'] = r[1].strip().upper()
                p['part_logradouro'] = r[4].strip().upper()
                p['part_numero'] = ''
                p['part_bairro'] = r[5].strip().upper()
                p['part_cidade'] = r[6].strip().upper()
                p['part_cod_mun'] = r[8][2:0].strip().upper()
                p['part_uf'] = r[9].strip().upper()
                p['part_cep'] = r[7].strip().upper().replace('-','')
                p['part_pais'] = ''
                p['part_fone'] = r[11].strip().upper()
                p['part_ie'] = r[3].strip().upper()
                

                if p['part_cod_mun'].strip() == '':
                    try:
                        p['part_cod_mun'] = get_viacep(p['part_cep'])
                    except:
                        pass

                emit_cod_mun = p['part_cod_mun']

            else:
                p = {}
                p['part_cnpj_cpf'] = r[1].strip().upper()
                emit_cnpj = p['part_cnpj_cpf']
                
                p['part_nome'] = r[8].strip().upper()
                p['part_logradouro'] = r[3].strip().upper()
                p['part_numero'] = ''
                p['part_bairro'] = 'ND'
                p['part_cidade'] = r[4].strip().upper()
                p['part_cod_mun'] = ''
                p['part_uf'] = r[6].strip().upper()
                p['part_cep'] = r[5].strip().upper().replace('-','')
                p['part_pais'] = ''
                p['part_fone'] = ''
                p['part_ie'] = r[2].strip().upper()
                

                if p['part_cod_mun'].strip() == '':
                    try:
                        p['part_cod_mun'] = get_viacep(p['part_cep'])
                    except:
                        pass

                emit_cod_mun = p['part_cod_mun']
                
            participantes.append(p)
            i = i + 1
            continue


        if id == '312':
            print('Dados do Destinatario')
            #Dados do Destinatario
            p = dict()

            tipo_pessoa = r[12].strip().upper()

            dest_cnpj = r[2].strip().upper()
            if tipo_pessoa == '2':
                dest_cnpj = dest_cnpj[-11:]

            if valida_cpf(dest_cnpj[-11:]):
                dest_cnpj = dest_cnpj[-11:]

                
            p['part_cnpj_cpf'] = dest_cnpj

            p['part_nome'] = r[1].strip().upper()
            p['part_logradouro'] = r[4].strip().upper()
            p['part_numero'] = ''
            p['part_bairro'] = r[5].strip().upper()
            p['part_cidade'] = r[6].strip().upper()
            p['part_cod_mun'] = r[8].strip().upper()            
            p['part_uf'] = r[9].strip().upper()
            p['part_cep'] = r[7].strip().upper().replace('-','')
            p['part_pais'] = ''
            p['part_fone'] = r[11].strip().upper()
            p['part_ie'] = r[3].strip().upper().replace('-','').replace('.','')
            participantes.append(p)


            if p['part_cod_mun'].strip() == '':
                try:
                    p['part_cod_mun'] = get_viacep(p['part_cep'])
                except:
                    pass

            dest_cod_mun = p['part_cod_mun']

        if id == '317':

            try:
                #Se objeto existe
                if len(lst_notas) == 0:
                    nfe_pagador_cnpj_cpf = r[2]

                #Se existem nfs lidas
                #plpy.notice('Pegando pagador')
                for nf in lst_notas:

                    #plpy.notice('Pagador = ' + r[2])
                    #plpy.notice('Chave ', r[11])
                    
                    nf['nfe_pagador_cnpj_cpf'] = r[2]   
                    nf['chave_cte'] = r[11]             
                
            except:
                nfe_pagador_cnpj_cpf = r[2]

            p = dict()            

                                        
            p['part_cnpj_cpf'] = r[2].strip().upper()
            p['part_nome'] = r[1].strip().upper()
            p['part_logradouro'] = r[4].strip().upper()
            p['part_numero'] = ''
            p['part_bairro'] = r[5].strip().upper()
            p['part_cidade'] = r[6].strip().upper()
            p['part_cod_mun'] = r[8].strip().upper()            
            p['part_uf'] = r[9].strip().upper()
            p['part_cep'] = r[7].strip().upper().replace('-','')
            p['part_pais'] = ''
            p['part_fone'] = r[10].strip().upper()
            p['part_ie'] = r[3].strip().upper().replace('-','').replace('.','')
            
            

            


            if p['part_cod_mun'].strip() == '':
                try:
                    p['part_cod_mun'] = get_viacep(p['part_cep'])
                except:
                    pass

            participantes.append(p)
            pagador_cod_mun = p['part_cod_mun']

        
            
        if id == '313':
            print('Dados da Nota Fiscal')

            n = {}

            ##Chave da NFe

            n['nfe_pagador_cnpj_cpf'] = nfe_pagador_cnpj_cpf
            #plpy.notice(str(len(r)))
            if emb_spss:
                n['nfe_chave_nfe'] = r[31]
            elif emb_softlog:
                n['nfe_chave_nfe'] = r[31]
                n['chave_cte'] = r[32]
            elif len(r) == 36:
                n['nfe_chave_nfe'] = r[33]
            elif len(r) == 33 and not emb_360:
                n['nfe_chave_nfe'] = r[32]                        
            elif len(r) == 32 or len(r) == 45:
                n['nfe_chave_nfe'] = r[31]
                n['nfe_numero_pedido'] = r[1][:7]

                if n['nfe_chave_nfe'][20:22] == '57':
                    n['chave_cte'] = r[31]
                    
                try:
                    n['chave_cte'] = n['nfe_chave_nfe']
                    n['nfe_pagador_cnpj_cpf'] = n['nfe_chave_nfe'][6:20]
                    n['nfe_chave_nfe'] = None
                    
                except:
                    pass
            elif emb_pratti:
                n['nfe_chave_nfe'] = r[30]            
            else:
                n['nfe_chave_nfe'] = emit_cnpj + r[7].strip().zfill(3) + r[8].strip().zfill(9)


            if emb_360:                
                n['nfe_numero_pedido'] = r[32].strip()
            
            ##informacoes de remetente/destinatario
            n['nfe_emit_cnpj_cpf'] = emit_cnpj
            n['nfe_emit_cod_mun']  = emit_cod_mun
            n['nfe_dest_cnpj_cpf'] = dest_cnpj
            n['nfe_dest_cod_mun']  = dest_cod_mun

            ##informacoes gerais

            de = r[9]
            n['nfe_data_emissao'] = de[-4:] + '-' + de[2:4] + '-' + de[0:2]
            n['nfe_numero_doc'] = r[8]
            n['nfe_modelo'] = '55'
            n['nfe_serie'] = r[7]
            n['nfe_ie_dest'] = p['part_ie']
            ##valores
            n['nfe_valor'] = r[13][:-2] + '.' + r[13][-2:]

            n['nfe_valor_bc'] = '0.00'
            n['nfe_valor_icms'] = '0.00'
            n['nfe_valor_bc_st'] = '0.00'
            n['nfe_valor_icms_st'] = '0.00'
            n['nfe_valor_produtos'] = r[13][:-2] + '.' + r[13][-2:]
            n['nfe_valor_frete'] = r[25][:-2] + '.' + r[25][-2:]


            n['nfe_placa_veiculo'] = r[20]
            ##informacoes relativas ao transporte
            if r[6] == 'C':
                n['nfe_modo_frete'] = '0'
            else:
                n['nfe_modo_frete'] = '1'

            n['nfe_peso_presumido'] = r[14][:-2] + '.' + r[14][-2:]
            n['nfe_peso_liquido'] = r[14][:-2] + '.' + r[14][-2:]
            n['nfe_volume_presumido'] = r[12][:-2] + '.' + r[12][-2:]

            ## Informacoes dos Itens de Produto
            n['nfe_volume_produtos'] = r[12][:-2] + '.' + r[12][-2:]
            n['nfe_peso_produtos'] = r[14][:-2] + '.' + r[14][-2:]
            n['nfe_unidade'] = 'UN'

            n['nfe_especie_mercadoria'] = 'DIVERSOS'


         
            try:
                proximo_id = registros[i+1][0]

                if proximo_id == '333':
                    n['nfe_cfop_predominante'] = registros[i+1][1]
            except:
                print(traceback.format_exc())

            try:
                proximo_id = registros[i+1][0]

                if proximo_id == '318':
                    if len(registros[i+1]) == 3:                        
                        #plpy.notice(registros[i+1][2])
                        if valida_chave_nfe(registros[i+1][2]):                        
                            n['nfe_chave_nfe'] = registros[i+1][2]
            except:
                print(traceback.format_exc())         
             
            try:
                proximo_id = registros[i+1][0]

                if proximo_id == '319':
                    if len(registros[i+1]) == 12:                        
                        #plpy.notice(registros[i+1][2])
                        if valida_chave_nfe(registros[i+1][11]):                        
                            n['nfe_chave_nfe'] = registros[i+1][11]
            except:
                print(traceback.format_exc())         

                 
            nfs.append(n)
            lst_notas.append(n)

      
        i = i + 1

    dados = {'participantes':participantes,
             'nfs':nfs
    }        
    #plpy.notice(json.dumps(dados))
    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;

--ALTER FUNCTION fpy_get_doc_notfis(arquivo text) OWNER TO softlog_3glog;
