-- Function: public.f_py_get_cmd_bloco_cte(text)
-- SELECT f_py_get_cmd_bloco_cte_v2(xml_nfe) FROM xml_nfe WHERE id = 279
-- DROP FUNCTION public.f_py_get_cmd_bloco_cte_v2('<?xml version="1.0" encoding="UTF-8"?>
-- UPDATE xml_nfe SET id = id 
-- Function: public.f_py_get_cmd_bloco_cte(text)
-- SELECT tipo_documento, * FROM xml_nfe WHERE status = 1
-- DROP FUNCTION public.f_py_get_cmd_bloco_cte(text);

CREATE OR REPLACE FUNCTION public.f_py_get_cmd_bloco_cte_v2(p_xml text)
  RETURNS text AS
$BODY$
    plpy.notice('Inicio')
    #plpy.notice(p_xml)
    from bs4 import BeautifulSoup
    import base64
    import traceback

    #Funcoes internas para realizar tarefa
    def retorna_col(coluna,oDomTag,tipoDado,delim="'",valorDefault='NULL'):
        dictValor = dict()

        dictValor['coluna'] = coluna
        dictValor['tipo']   = tipoDado

        if len(oDomTag) > 0:
            valor = oDomTag[0].text.strip()
            if tipoDado[0:9] == 'character':
                tam = int(tipoDado.strip('character(').strip(")"))
                valor = valor[0:tam]
                valor = valor.replace("'","")

            dictValor['valor']  = delim + valor + delim
        else:
            dictValor['valor']  = valorDefault

        return dictValor

    def retorna_col_plain(coluna, valor, tipoDado,delim="'"):

        
        dictValor = dict()

        dictValor['coluna'] = coluna
        dictValor['tipo']   = tipoDado

        if valor is None:
            dictValor['valor'] = 'NULL'
            return dictValor

        #plpy.notice('Antes ' + valor)        
        if tipoDado[0:9] == 'character':
        
            valor = valor.replace("'","")
            tam = int(tipoDado.strip('character(').strip(")"))
            
            
            valor = valor[0:tam]
            #plpy.notice('Depois ' + valor + ' ' + str(tam))
            


        dictValor['valor']  = delim + valor + delim

        return dictValor


    

    def ret_emitente(oDom):
        emit = oDom.findAll('emit')[0]
        l = []



        if len(emit.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',emit.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',emit.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',emit.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',emit.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',emit.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',emit.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',emit.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',emit.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',emit.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',emit.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',emit.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',emit.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',emit.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',emit.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql

    def ret_remetente(oDom):
        Rem = oDom.findAll('rem')[0]

        l = []

        if len(Rem.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',Rem.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',Rem.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',Rem.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',Rem.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',Rem.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',Rem.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',Rem.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',Rem.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',Rem.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',Rem.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',Rem.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',Rem.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',Rem.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',Rem.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql


    def ret_destinatario(oDom):
        Dest = oDom.findAll('dest')[0]

        l = []

        if len(Dest.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',Dest.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',Dest.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',Dest.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',Dest.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',Dest.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',Dest.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',Dest.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',Dest.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',Dest.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',Dest.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',Dest.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',Dest.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',Dest.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',Dest.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql

    def ret_expedidor(oDom):
        exp = oDom.findAll('exped')[0]

        if len(exp) == 0:
            return ''
        l = []

        if len(exp.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',exp.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',exp.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',exp.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',exp.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',exp.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',exp.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',exp.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',exp.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',exp.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',exp.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',exp.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',exp.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',exp.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',exp.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql


    def ret_recebedor(oDom):
        o = oDom.findAll('receb')[0]

        if len(o) == 0:
            return ''
        l = []

        if len(o.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',o.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',o.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',o.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',o.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',o.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',o.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',o.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',o.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',o.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',o.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',o.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',o.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',o.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',o.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql

    def ret_outros(oDom):
        o = oDom.findAll('toma4')[0]

        if len(o) == 0:
            return ''
            
        l = []

        if len(o.findAll('cnpj')) == 0:
            l.append(retorna_col('cnpjcpf',o.findAll('cpf'),'character(14)'))
        else:
            l.append(retorna_col('cnpjcpf',o.findAll('cnpj'),'character(14)'))

        l.append(retorna_col('nomerazao',o.findAll('xnome'),'character(60)'))
        l.append(retorna_col('endereco',o.findAll('xlgr'),'character(60)'))
        l.append(retorna_col('numero',o.findAll('nro'),'character(10)'))
        l.append(retorna_col('bairro',o.findAll('xbairro'),'character(30)'))
        l.append(retorna_col('cidade',o.findAll('xmun'),'character(30)'))
        l.append(retorna_col('estado',o.findAll('uf'),'character(2)'))
        l.append(retorna_col('cep',o.findAll('cep'),'character(10)'))
        l.append(retorna_col('telefone',o.findAll('fone'),'character(15)'))
        l.append(retorna_col('ieestadual',o.findAll('ie'),'character(20)'))
        l.append(retorna_col('codmunicipio',o.findAll('cmun'),'character(10)'))
        l.append(retorna_col('codpais',o.findAll('cpais'),'character(5)'))
        l.append(retorna_col('crt',o.findAll('crt'),'character(1)'))

        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql



    def ret_dados_cte(oDom):
        plpy.notice('Notas Fiscais')
        ide = oDom.findAll('ide')[0]
        vprest = oDom.findAll('vprest')[0]
        l = []

        try:
            r = oDom.find("infcte")
            chave =  "'" + r.attrs.get('id')[3:] + "'"
            l.append(retorna_col_plain('chave',chave,'character(44)',"'"))
        except:
            plpy.notice(traceback.format_exc())        
            l.append(retorna_col_plain('chave','NULL','character(44)',''))
            
        try:
            l.append(retorna_col('numeronf',ide.findAll('nct'),'character(10)'))
        except:
            return ''

        l.append(retorna_col('serie',ide.findAll('serie'),'character(3)'))

        if len(ide.findAll('demi')) == 0:
            l.append(retorna_col('data_emissao',ide.findAll('dhemi'),'date'))
        else:
            l.append(retorna_col('data_emissao',ide.findAll('demi'),'date'))

        l.append(retorna_col_plain('indpag',None,'character(1)'))
        ##l.append(retorna_col('indpag',ide.findAll('modfrete'),'character(1)'))

        

        l.append(retorna_col_plain('vlr_bc','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_icms','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_bcst','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_st','0.00','numeric(12,2)',''))
        l.append(retorna_col('vlr_prod',vprest.findAll('vtprest'),'numeric(12,2)','','0.00'))
        l.append(retorna_col_plain('vlr_frete','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_seg','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_desc','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_ipi','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_pis','0.00','numeric(12,2)',''))
        l.append(retorna_col_plain('vlr_cofins','0.00','numeric(12,2)',''))        
        l.append(retorna_col_plain('vlr_outro','0.00','numeric(12,2)',''))
        l.append(retorna_col('vlr_nf',vprest.findAll('vtprest'),'numeric(12,2)','','0.00'))
        l.append(retorna_col_plain('tpag',None,'character(3)'))
        l.append(retorna_col_plain('modfrete',None,'character(1)'))
        l.append(retorna_col_plain('obs',None,'text'))
        l.append(retorna_col_plain('transportador_cnpj',None,'text'))        

        l.append(retorna_col_plain('transportador_cnpj','NULL','text',''))

        try:
            r = oDom.find("infcte")
            chave =  r.attrs.get('id')[3:] 
            
            plpy.notice(type(chave))
            #plpy.notice(chave)
            l.append(retorna_col_plain('chave',chave,'character(44)',"'"))
            #plpy.notice('Depois ' + chave)
        except:
            plpy.notice(traceback.format_exc())        
            l.append(retorna_col_plain('chave','NULL','character(44)',''))
            

	
        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql
        
    def ret_dados_cte_compl(oDom):

        l = []
        
        ide = oDom.findAll('ide')[0]
        
        l.append(retorna_col('cod_mun_ini',ide.findAll('cmunini'),'character(7)'))        
        l.append(retorna_col('mun_ini',ide.findAll('xmunini'),'character(50)'))
        l.append(retorna_col('uf_ini',ide.findAll('ufini'),'character(2)'))
        l.append(retorna_col('cod_mun_fim',ide.findAll('cmunfim'),'character(7)'))
        l.append(retorna_col('mun_fim',ide.findAll('xmunfim'),'character(50)'))
        l.append(retorna_col('uf_fim',ide.findAll('uffim'),'character(2)'))
        l.append(retorna_col('cfop',ide.findAll('cfop'),'character(4)'))
        l.append(retorna_col('tomador',ide.findAll('toma'),'character(1)'))



        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql

        
    

    def ret_dados_fatura(oDom):
        plpy.notice('Faturas')
        listaFaturasXml = oDom.findAll('dup')
        listaFatura = []
        qt = len(listaFaturasXml)
        if len(listaFaturasXml) == 0:
            l = []
            l.append(retorna_col('fk_notas_fiscais_id',oDom.findAll('vazio'),'integer',''))
            l.append(retorna_col('fk_notas_fiscais_numeronf',oDom.findAll('vazio'),'character(10)'))
            l.append(retorna_col('numero_fatura',oDom.findAll('vazio'),'character(10)'))
            l.append(retorna_col('data_vencimento',oDom.findAll('vazio'),'date'))
            l.append(retorna_col('valor_fatura',oDom.findAll('vazio'),'numeric(12,2)','','0.00'))

            lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

            cmd_sql = 'SELECT null::text as parcela, '  + ','.join(lst_comando)

            cmd_sql = cmd_sql + ' WHERE 1=2 '

            return cmd_sql
        i = 0
        for f in listaFaturasXml:
            i = i + 1
            l = []
            l.append(retorna_col('fk_notas_fiscais_id',f.findAll('vazio'),'integer',''))
            l.append(retorna_col('fk_notas_fiscais_numeronf',dom.findAll('nnf'),'character(10)'))
            l.append(retorna_col('numero_fatura',f.findAll('ndup'),'character(10)'))
            l.append(retorna_col('data_vencimento',f.findAll('dvenc'),'date'))
            l.append(retorna_col('valor_fatura',f.findAll('vdup'),'numeric(12,2)','','0.00'))

            lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

            cmd_sql = "SELECT ('" + str(i) + "/" + str(qt) + "')::text as parcela, " + ",".join(lst_comando)

            listaFatura.append(cmd_sql)

        return ' UNION '.join(listaFatura) + ' ORDER BY data_vencimento '

    #Inicio do codigo

    
    try:
        v_xml = p_xml
    except:
        #plpy.notice(traceback.format_exc())
        v_xml = p_xml
    #plpy.notice('XML')
    #plpy.notice(v_xml)
    dom = BeautifulSoup(v_xml)
    

    cmd_comandos = ''

    cte            = ret_dados_cte(dom)
    
    emitente       = ret_emitente(dom)
    
    try:
        destinatario   = ret_destinatario(dom)
    except:
        destinatario   = ''

    try:
        remetente   = ret_remetente(dom)
    except:
        remetente  = ''
    try:
        expedidor = ret_expedidor(dom)
    except:
        #plpy.notice(traceback.format_exc())
        expedidor = ''

    try:
        recebedor = ret_recebedor(dom)
    except:
        #plpy.notice(traceback.format_exc())
        recebedor = ''

    try:
        outros = ret_outros(dom)
    except:
        
        outros = ''
    

    cte_compl   = ret_dados_cte_compl(dom)
    
    
    
    produtos       = ""
    fatura         = ""

    cmd_comandos = cte + '###' + emitente + '###' + destinatario + '###' + produtos + '###' + fatura + '###' + remetente + '###' + expedidor + '###' + recebedor + '###' + outros + '###' +  cte_compl

    return cmd_comandos
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

