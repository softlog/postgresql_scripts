-- Function: public.fpy_get_doc_dcenter(text)

-- DROP FUNCTION public.fpy_get_doc_dcenter(text);

CREATE OR REPLACE FUNCTION fpy_get_doc_dcenter(arquivo text)
  RETURNS json AS
$BODY$


    import traceback
    import json
    from doc_parser import DocParser
    
    destinatarios = []
    nfs = []

    #Cria objetos de parser para cada tipo de registro

    struct = (44,9,8,14,14,60,60,10,60,7,8,16,15,3,10,10,8,60,2,30)
    reg = DocParser.make_parser(struct)

    #a = open(filename,'r',encoding='utf-8')
    #linhas = a.readlines()
    #a.close()

    linhas = arquivo.strip('\n').split('\n')
    #Faz o parser de cada linha, de acordo com o seu tipo de registro
    registros = []
    for linha in linhas:
        registros.append(reg(linha))

    #Ler o conteudo dos registros parseados
    i = 0
    for r in registros:

        print('Dados do Destinatario')
        #Dados do Destinatario
        p = dict()
        p['part_cnpj_cpf'] = r[4].strip().upper()

        if p['part_cnpj_cpf'] == '':
            continue
            
        dest_cnpj = p['part_cnpj_cpf']

        p['part_nome'] = r[5].strip().upper()
        p['part_logradouro'] = r[6].strip().upper()
        p['part_numero'] = r[7].strip().upper()
        p['part_bairro'] = r[8].strip().upper()
        p['part_cod_mun'] = r[9].strip().upper()
        dest_cod_mun = p['part_cod_mun']
        p['part_uf'] = r[18].strip().upper()
        p['part_cep'] = r[10].strip().upper()
        p['part_pais'] = ''
        p['part_ie'] = r[11].strip().upper()

        destinatarios.append(p)

        n = {}

        emit_cnpj = r[3].strip()

        ##Chave da NFe
        n['nfe_chave_nfe'] = r[0]


        ##informacoes de remetente/destinatario
        n['nfe_emit_cnpj_cpf'] = emit_cnpj
        n['nfe_emit_cod_mun']  = ''
        n['nfe_dest_cnpj_cpf'] = dest_cnpj
        n['nfe_dest_cod_mun']  = dest_cod_mun

        ##informacoes gerais
        de = r[2]
        #plpy.notice('Data de Emissao %s' % de)
        n['nfe_data_emissao'] = de[0:4] + '-' + de[4:6] + '-' + de[-2:]
        n['nfe_numero_doc'] = r[1]
        n['nfe_modelo'] = '55'
        n['nfe_serie'] = n['nfe_chave_nfe'][22:25]
        n['nfe_ie_dest'] = p['part_ie']
        ##valores
        n['nfe_valor'] = r[12]

        n['nfe_valor_bc'] = '0.00'
        n['nfe_valor_icms'] = '0.00'
        n['nfe_valor_bc_st'] = '0.00'
        n['nfe_valor_icms_st'] = '0.00'
        n['nfe_valor_produtos'] = r[12]


        ##informacoes relativas ao transporte
        n['nfe_modo_frete'] = '0'

        n['nfe_peso_presumido'] = r[15]
        n['nfe_peso_liquido'] = r[14]
        n['nfe_volume_presumido'] = r[13]

        ## Informacoes dos Itens de Produto
        n['nfe_volume_produtos'] = r[13]
        n['nfe_peso_produtos'] = r[15]
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
