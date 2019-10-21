/*
SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 100

SELECT fpy_get_doc_notfis(doc_xml), doc_xml FROM scr_doc_integracao WHERE id_doc_integracao = 3217

	SELECT fpy_get_doc_notfis('0008SCIENCE COSMETICOS E PRODUTOS NATUASSISLOG                           2208181100NOT220811000
310NOTFI220811000
3110726287100039411062393       RUA FRANCISCA DANTAS, 327 - SALA 213, PASAO JOAO DE MERITI                 25525030 RJ       220820188SCIENCE COSMETICOS E PRODUTOS NATURAIS 
312ANA LUCIA CUNHA                         00020079508715               R MAXWELL, 424 - AP. 301                VILA ISABEL         RIO DE JANEIRO                     20541100          RJ           21998811434                        2
3132963936                  C0030001260321082018COSMETICOS     CAIXAS         0000100000000000016802003050000000  000000000000000000000000000000        000000000000000000000000000000000000000000000000000000000812I000000000000000000000000   33180807262871000394550030000126031536803706
318000000000205626000000000522200000000000000000000000000001200000000000000000000000000000000')

*/
--DROP FUNCTION fpy_get_doc_notfis(arquivo text)

CREATE OR REPLACE FUNCTION fpy_get_doc_notfis_51(arquivo text)
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
    struct = (3,35,35,6,4,12,225)
    reg_000 = DocParser.make_parser(struct)
    reg_500 = DocParser.make_parser((3,14,303))
    reg_501 = DocParser.make_parser((3,50,14,15,15,15,50,35,35,9,9,9,8,4,25,24))
        
    reg_502 = DocParser.make_parser((3,50,14,50,35,35,9,9,9,35,4,4,67))

    reg_503 = DocParser.make_parser((3,50,14,15,15,50,35,35,9,9,9,35,4,4,1,1,31))

    reg_504 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,44,1,1,46))

    reg_505 = DocParser.make_parser((3,3,9,8,15,15,7,1,1,1,1,8,10,1,1,1,4,2,1,10,2,20,20,20,20,20,1,8,4,8,4,9,45,15,1,10,10,1))

    reg_506 = DocParser.make_parser((3,8,9,9,10,101,1,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,13,13,13,5))

    reg_507 = DocParser.make_parser((3,8,9,10,10,15,15,15,15,15,15,15,15,15,15,15,5,15,1,15,5,15,15,5,15,15,3,4,2,1))

    reg_508 = DocParser.make_parser((3,50,50,50,167))

    reg_509 = DocParser.make_parser((3,14,50,3,9,14,50,3,9,14,50,3,9,10,5,12,14,48))

    reg_511 = DocParser.make_parser((3,8,15,20,50,4,20,8,45,45,45,20,9,10,15,3))

    reg_513 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,56))

    reg_514 = DocParser.make_parser((3,50,14,15,50,35,35,9,9,9,35,4,52))
    

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
        if linha[0:3] == '313':
            tamanho = len(linha)
            #plpy.notice('Tamanho %i' % tamanho)
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

        elif id_reg == '312':
            if emb_spss:                
                registros.append(reg_312_SPSS(linha))
            elif emb_softlog:  
                registros.append(reg_312_SPSS(linha))
            else:
                registros.append(reg_312(linha))

        elif id_reg == '313':
            
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
            elif len(linha) == 322 or len(linha) == 321:
                #plpy.notice('LEIAUTE SANTA CRUZ')
                registros.append(reg_313_SC(linha))
            else:
                #plpy.notice('LEIAUTE PADRAO')
                registros.append(reg_313(linha))

        elif id_reg == '333':
            registros.append(reg_333(linha))

        elif id_reg == '314':
            registros.append(reg_314(linha))

        elif id_reg == '317':
            registros.append(reg_317(linha))
             
        elif id_reg == '318':
            registros.append(reg_318(linha))

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
                p['part_cep'] = r[7].strip().upper()
                p['part_pais'] = ''
                p['part_fone'] = r[11].strip().upper()
                p['part_ie'] = r[3].strip().upper()
                

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
                
            p['part_cnpj_cpf'] = dest_cnpj

            p['part_nome'] = r[1].strip().upper()
            p['part_logradouro'] = r[4].strip().upper()
            p['part_numero'] = ''
            p['part_bairro'] = r[5].strip().upper()
            p['part_cidade'] = r[6].strip().upper()
            p['part_cod_mun'] = r[8].strip().upper()            
            p['part_uf'] = r[9].strip().upper()
            p['part_cep'] = r[7].strip().upper()
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

        if id == '317':
            try:	    
                n['nfe_pagador_cnpj_cpf'] = r[2]
            except:
                nfe_pagador_cnpj_cpf = r[2]
            
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
            elif len(r) == 32:
                n['nfe_chave_nfe'] = r[31]
                n['nfe_numero_pedido'] = r[1][:7]
            else:
                n['nfe_chave_nfe'] = emit_cnpj + r[7].strip().zfill(3) + r[8].strip().zfill(9)

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

            nfs.append(n)

        i = i + 1

    dados = {'participantes':participantes,
             'nfs':nfs
    }        
    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;


--ALTER FUNCTION fpy_get_doc_notfis(arquivo text) OWNER TO softlog_assislog;
