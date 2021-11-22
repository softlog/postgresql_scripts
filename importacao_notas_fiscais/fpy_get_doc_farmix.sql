-- Function: public.fpy_get_doc_dcenter(text)

-- DROP FUNCTION public.fpy_get_doc_dcenter(text);

CREATE OR REPLACE FUNCTION fpy_get_doc_farmix(arquivo text)
  RETURNS json AS
$BODY$

    """
       NOTA
       DTEMISSAO
       CLIENTE                                   
       ENDERECO                                  
       BAIRRO                
       MUNICIPIO        
       ESTADO  
       CGC             
       IEENT          
       CEP       
       TOTPESO     
       ZEROS1        
       ZEROS2        
       ZEROS3        
       VLTOTAL       
       ZEROS4    
       NUMVOL      
       VLTOTAL1      
       ZEROS5  
       CGCEMIT         
       SERIE  
       CHAVENFE                                      
       CODIBGE  """

    import traceback
    import json
    from doc_parser import DocParser
    
    destinatarios = []
    nfs = []

    #Cria objetos de parser para cada tipo de registro

    struct = (9,11,42,42,22,17,8,16,15,10,12,14,14,14,14,10,12, 14,8,16,7,46,9)
    reg = DocParser.make_parser(struct)

    #a = open(filename,'r',encoding='utf-8')
    #linhas = a.readlines()
    #a.close()

    linhas = arquivo.strip('\n').split('\n')
    #Faz o parser de cada linha, de acordo com o seu tipo de registro
    registros = []
    i = -1
    for linha in linhas:
        i = i + 1
        if i == 0:
            continue
            
        registros.append(reg(linha.replace("&","E")))

    #Ler o conteudo dos registros parseados
    i = 0
    for r in registros:

        print('Dados do Destinatario')
        #Dados do Destinatario
        p = dict()
        p['part_cnpj_cpf'] = r[7].strip().upper()

        if p['part_cnpj_cpf'] == '':
            continue
            
        dest_cnpj = p['part_cnpj_cpf']

        p['part_nome'] = r[2].strip().upper()
        p['part_logradouro'] = r[4].strip().upper()
        p['part_numero'] = 'ND'
        p['part_bairro'] = r[4].strip().upper()
        p['part_cod_mun'] = r[22].strip().upper()
        dest_cod_mun = p['part_cod_mun']
        p['part_uf'] = r[6].strip().upper()
        p['part_cep'] = r[9].strip().upper()
        p['part_pais'] = ''
        p['part_ie'] = r[8].strip().upper()

        destinatarios.append(p)

        n = {}

        emit_cnpj = r[19].strip()

        ##Chave da NFe
        n['nfe_chave_nfe'] = r[21].strip()


        ##informacoes de remetente/destinatario
        n['nfe_emit_cnpj_cpf'] = emit_cnpj
        n['nfe_emit_cod_mun']  = ''
        n['nfe_dest_cnpj_cpf'] = dest_cnpj
        n['nfe_dest_cod_mun']  = dest_cod_mun

        ##informacoes gerais
        de = r[1].strip()
        #plpy.notice('Data de Emissao %s' % de)
        n['nfe_data_emissao'] = de[-4:] + '-' + de[2:4] + '-' + de[0:2]
        n['nfe_numero_doc'] = r[0].strip()
        n['nfe_modelo'] = '55'
        n['nfe_serie'] = n['nfe_chave_nfe'][22:25]
        n['nfe_ie_dest'] = p['part_ie']
        ##valores
        n['nfe_valor'] = r[17].strip()[:-2] + '.' + r[17].strip()[-2:]

        n['nfe_valor_bc'] = '0.00'
        n['nfe_valor_icms'] = '0.00'
        n['nfe_valor_bc_st'] = '0.00'
        n['nfe_valor_icms_st'] = '0.00'
        n['nfe_valor_produtos'] = r[14].strip()[:-2] + '.' + r[14].strip()[-2:]


        ##informacoes relativas ao transporte
        n['nfe_modo_frete'] = '0'

        n['nfe_peso_presumido'] = r[10].strip()[:-3] + '.' + r[10].strip()[-3:]
        n['nfe_peso_liquido'] = r[10].strip()[:-3] + '.' + r[10].strip()[-3:]
        n['nfe_volume_presumido'] = r[16].strip()

        ## Informacoes dos Itens de Produto
        n['nfe_volume_produtos'] = r[16].strip()
        n['nfe_peso_produtos'] = r[10].strip()[:-3] + '.' + r[10].strip()[-3:]
        n['nfe_unidade'] = 'UN'

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
ALTER FUNCTION public.fpy_get_doc_dcenter(text)
  OWNER TO softlog_dng;
