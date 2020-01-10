-- Function: public.fpy_get_doc_doria(text)

-- DROP FUNCTION public.fpy_get_doc_doria(text);
CREATE OR REPLACE FUNCTION public.fpy_get_doc_doria(arquivo text)
  RETURNS json AS
$BODY$


    import traceback
    import json
    from doc_parser import DocParser

    def get_viacep(cep):
        r = plpy.execute("SELECT cod_ibge FROM cep WHERE cep = '%s'"%(cep))
        if (r.nrows() > 0):
            #plpy.notice('Encontrei Cep %s' % cep)
            return r[0]['cod_ibge']
        else:
            #plpy.notice('Nao Encontrei Cep %s' % cep)
            return ''
               
    destinatarios = []
    nfs = []

    #Cria objetos de parser para cada tipo de registro

    struct = (6,8,40,40,20,30,2,14,16,8,10,12,12,12,12,8,10,12,4,14,9,3,8,6,9, 44, 14)
    reg = DocParser.make_parser(struct)
    
    struct_2 = (6,8,40,40,20,30,2,14,16,8,10,12,12,12,12,8,10,12,4,14,3,44)
    reg_luchefarma = DocParser.make_parser(struct_2)

    struct_3 = (7,8,40,40,20,30,2,14,16,8,10,12,12,12,12,8,10,12,4,14,12,44)    
    reg_genericos = DocParser.make_parser(struct_3)

    struct_4 = (6,8,40,40,20,30,2,14,16,8,10,12,12,12,12,8,10,12,2,14,44)
    reg_profarma = DocParser.make_parser(struct_4)

    struct_5 = (6,8,40,40,20,30,2,14,16,8,10,12,12,12,12,8,10,12,2,14)
    reg_profarma_sem_chave = DocParser.make_parser(struct_5)
    
    #a = open(filename,'r',encoding='utf-8')
    #linhas = a.readlines()
    #a.close()

    linhas = arquivo.strip('\n').split('\n')
    #Faz o parser de cada linha, de acordo com o seu tipo de registro
    registros = []
    is_luchefarma = False
    for linha in linhas:
    
        #plpy.notice('Tamanho Linha ' + str(len(linha)))
        tem_chave = True
        if len(linha) == 338 or is_luchefarma:        
            #plpy.notice('Luchefarma')
            registros.append(reg_luchefarma(linha))	
            is_luchefarma = True            
        elif len(linha) == 333:
            registros.append(reg_profarma(linha))
        elif len(linha) == 289:
            registros.append(reg_profarma_sem_chave(linha))            
            tem_chave = False
        elif len(linha) == 348 or linha[0:7] == 'VER0002':
            registros.append(reg_genericos(linha))	                        
        else:
            registros.append(reg(linha))
            #plpy.notice('Normal')           
	    

    #Ler o conteudo dos registros parseados
    i = 0
    
    for r in registros:

        ##Chave da NFe
        n = {}
        #plpy.notice('Tamanho ',str(len(r)))
        
        if not tem_chave:
            n['nfe_chave_nfe'] = ''
        elif len(r) == 22:
            n['nfe_chave_nfe'] = r[21]
        elif len(r) == 21:
            n['nfe_chave_nfe'] = r[20]
        elif len(r) == 27:
            n['nfe_chave_nfe'] = r[25]
        else:
            continue

        #print('Dados do Destinatario')
        #Dados do Destinatario
        p = dict()
        p['part_cnpj_cpf'] = r[7].strip().upper()

        if p['part_cnpj_cpf'] == '':
            continue
            
        dest_cnpj = p['part_cnpj_cpf']

        p['part_nome'] = r[2].strip().upper()
        p['part_logradouro'] = r[3].strip().upper()
        p['part_numero'] = 'SN'
        p['part_bairro'] = r[4].strip().upper()

               
        
        
        p['part_uf'] = r[6].strip().upper()
        p['part_cep'] = r[9].strip().upper()
        p['part_cod_mun'] = ''
        p['part_cidade'] = r[5].strip().upper()
        if p['part_cod_mun'].strip() == '':
            try:
                p['part_cod_mun'] = get_viacep(p['part_cep'])
            except:
                pass

        dest_cod_mun = p['part_cod_mun']
        p['part_pais'] = ''
        p['part_ie'] = r[8][:14].strip().upper()

        destinatarios.append(p)        

        if tem_chave:
            emit_cnpj = n['nfe_chave_nfe'][6:20] 
        else:
            emit_cnpj = r[19]

        ##informacoes de remetente/destinatario
        n['nfe_emit_cnpj_cpf'] = emit_cnpj
        n['nfe_emit_cod_mun']  = ''
        n['nfe_dest_cnpj_cpf'] = dest_cnpj        
        n['nfe_dest_cod_mun']  = dest_cod_mun

        ##informacoes gerais
        de = r[1]
        #plpy.notice('Data de Emissao %s' % de)
        n['nfe_data_emissao'] = de[-4:] + "-" + de[2:4] + "-" + de[:2]
        if len(r) == 22 and r[0] != 'VER0002':
            #plpy.notice('entrei aqui')
            n['nfe_numero_doc'] = r[0]
        elif not tem_chave:
            n['nfe_numero_doc'] = r[0]
        else:          
            n['nfe_numero_doc'] = n['nfe_chave_nfe'][25:25+9]

        
        
        #n['nfe_numero_doc'] = r[20]
        n['nfe_modelo'] = '55'
        if tem_chave:
            n['nfe_serie'] = n['nfe_chave_nfe'][22:25]
        else:
            n['nfe_serie'] = '018'
            
        n['nfe_ie_dest'] = p['part_ie']
        ##valores
        n['nfe_valor'] = r[17][:-2] + '.' + r[17][-2:]

        n['nfe_valor_bc'] = '0.00'
        n['nfe_valor_icms'] = '0.00'
        n['nfe_valor_bc_st'] = '0.00'
        n['nfe_valor_icms_st'] = '0.00'
        n['nfe_valor_produtos'] = r[14][:-2] + '.' + r[14][-2:]


        ##informacoes relativas ao transporte
        n['nfe_modo_frete'] = '0'

        if is_luchefarma:

            n['nfe_peso_presumido'] = r[10][:-2] + '.' + r[10][-2:]
            n['nfe_peso_liquido'] = r[10][:-2] + '.' + r[10][-2:]
            n['nfe_volume_presumido'] = r[16][:-3] + '.' + r[16][-3:]

            ## Informacoes dos Itens de Produto
            n['nfe_volume_produtos'] = r[16][:-3] + '.' + r[16][-3:]
            n['nfe_peso_produtos'] = r[10][:-2] + '.' + r[10][-2:]

        else:

            n['nfe_peso_presumido'] = r[10][:-3] + '.' + r[10][-3:]
            n['nfe_peso_liquido'] = r[10][:-3] + '.' + r[10][-3:]
            n['nfe_volume_presumido'] = r[16][:-2] + '.' + r[16][-2:]

            ## Informacoes dos Itens de Produto
            n['nfe_volume_produtos'] = r[16][:-2] + '.' + r[16][-2:]
            n['nfe_peso_produtos'] = r[10][:-3] + '.' + r[10][-3:]
        

        n['nfe_unidade'] = 'UN'
        try:
            n['nfe_numero_pedido'] = r[24]
        except:
            n['nfe_numero_pedido'] = None

        n['nfe_especie_mercadoria'] = 'DIVERSOS'

        nfs.append(n)


    dados = {'participantes':destinatarios,
                 'nfs':nfs
        }
   
    retorno = json.dumps(dados)    
    return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

