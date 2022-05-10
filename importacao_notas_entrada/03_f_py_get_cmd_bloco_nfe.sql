-- Function: public.f_py_get_cmd_bloco_nfe(text)
-- SELECT f_py_get_cmd_bloco_nfe_v2(xml_nfe) FROM xml_nfe WHERE id = 27
-- DROP FUNCTION public.f_py_get_cmd_bloco_nfe(text);

CREATE OR REPLACE FUNCTION public.f_py_get_cmd_bloco_nfe_v2(p_xml text)
  RETURNS text AS
$BODY$

    from bs4 import BeautifulSoup
    import base64

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
            if tipoDado[0:4] == 'text':                
                valor = valor.replace("'","")

            dictValor['valor']  = delim + valor + delim
        else:
            dictValor['valor']  = valorDefault

        return dictValor

    def retorna_col_plain(coluna, valor, tipoDado, delim="'"):
	
        dictValor = dict()

        dictValor['coluna'] = coluna
        dictValor['tipo']   = tipoDado

        if valor is None:
            dictValor['valor'] = 'NULL'
            return dictValor
                
        if tipoDado[0:9] == 'character':
            valor = valor.replace("'","")
            tam = int(tipoDado.strip('character(').strip(")"))
            valor = valor[0:tam]



        dictValor['valor']  = delim + valor + delim

        return dictValor



    def ret_produtos(oDom):
        listaProdutosXml = oDom.findAll('det')
        ide = oDom.findAll('ide')[0]
        if len(ide.findAll('demi')) == 0:
            data_emissao = ide.findAll('dhemi')[0].text.strip() 
        else:
            data_emissao = ide.findAll('demi')[0].text.strip()             
            
        listaProdutos   = []
        lista_ncm_1 = []
        lista_ncm_2 = []

        i = 0
        for produto in listaProdutosXml:
            i = i + 1
            l = []
            l.append(retorna_col('num_item',produto.findAll('vazio'),'integer','',str(i)))
            l.append(retorna_col('cod_prod',produto.findAll('cprod'),'character(20)'))
            l.append(retorna_col('descricao',produto.findAll('xprod'),'character(60)'))
            l.append(retorna_col('ncm',produto.findAll('ncm'),'character(15)'))
            l.append(retorna_col('cfop_for',produto.findAll('cfop'),'character(4)'))
            l.append(retorna_col('cfop_ent',produto.findAll('vazio'),'character(4)'))
            l.append(retorna_col('und',produto.findAll('ucom'),'character(3)'))
            l.append(retorna_col('qtd',produto.findAll('qcom'),'numeric(18,6)','','0.00'))
            l.append(retorna_col('unit',produto.findAll('vuncom'),'numeric(18,6)','','0.00'))
            l.append(retorna_col('total',produto.findAll('vprod'),'numeric(18,2)','','0.00'))
            l.append(retorna_col('desconto',produto.findAll('vdesc'),'numeric(10,2)','','0.00'))
            l.append(retorna_col('frete',produto.findAll('vfrete'),'numeric(12,2)','','0.00'))
            l.append(retorna_col('seguro',produto.findAll('vseg'),'numeric(12,2)','','0.00'))
            l.append(retorna_col('despesas_acessorias',produto.findAll('voutro'),'numeric(12,2)','','0.00'))




            #ICMS
            try:
                icms = produto.findAll('icms')[0]
                

                l.append(retorna_col('cst',icms.findAll('cst'),'character(4)'))
                l.append(retorna_col('bc',icms.findAll('vbc'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('aliq_icms',icms.findAll('picms'),'numeric(8,2)','','0.00'))
                l.append(retorna_col('icms',icms.findAll('vicms'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('bcst',icms.findAll('vbcst'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('aliq_icmsst',icms.findAll('picmsst'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('icmsst',icms.findAll('vicmsst'),'numeric(12,2)','','0.00'))
            except:
            
                l.append(retorna_col_plain('cst', None,'character(4)',''))
                l.append(retorna_col_plain('bc','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('aliq_icms','0.00','numeric(8,2)',''))
                l.append(retorna_col_plain('icms','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('bcst','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('aliq_icmsst','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('icmsst','0.00','numeric(12,2)',''))



            l.append(retorna_col('aliq_ipi',produto.findAll('pipi'),'numeric(12,2)','','0.00'))
            l.append(retorna_col('valor_ipi',produto.findAll('vipi'),'numeric(12,2)','','0.00'))

            if len(produto.findAll('ncm')) > 0:
                ncm = produto.findAll('ncm')[0].text.strip()
                l.append(retorna_col_plain('tem_st_ncm','0','integer',''))

            try:
                l.append(retorna_col('p_cred_sn',icms.findAll('pcredsn'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('v_cred_icms_sn',icms.findAll('vcredicmssn'),'numeric(12,2)','','0.00'))

            except:
                l.append(retorna_col_plain('p_cred_sn','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('v_cred_icms_sn','0.00','numeric(12,2)',''))

                
            #PIS
            
            try:
                pis = produto.findAll('pis')[0]
                l.append(retorna_col('bc_pis',pis.findAll('vbc'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('aliq_pis',pis.findAll('ppis'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('vl_pis',pis.findAll('vpis'),'numeric(12,2)','','0.00'))
            except:
                l.append(retorna_col_plain('bc_pis','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('aliq_pis','0.00','numeric(12,2)',''))
                l.append(retorna_col_plain('vl_pis','0.00','numeric(12,2)',''))
            
            #COFINS
            try:
                cofins = produto.findAll('cofins')[0]
                l.append(retorna_col('bc_cofins',cofins.findAll('vbc'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('aliq_cofins',cofins.findAll('pcofins'),'numeric(12,2)','','0.00'))
                l.append(retorna_col('vl_cofins',cofins.findAll('vcofins'),'numeric(12,2)','','0.00'))
            except:
                l.append(retorna_col('bc_cofins','0.00','numeric(12,2)',''))
                l.append(retorna_col('aliq_cofins','0.00','numeric(12,2)',''))
                l.append(retorna_col('vl_cofins','0.00','numeric(12,2)',''))
            
            
            
            lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

            cmd_sql = 'SELECT ' + ','.join(lst_comando)

            listaProdutos.append(cmd_sql)

        return ' UNION '.join(listaProdutos) + ' ORDER BY num_item '

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

    def ret_dados_nfe(oDom):
        ide = oDom.findAll('ide')[0]

        l = []

        try:
            r = oDom.find("infnfe")
            chave = r.attrs.get('id')[3:]
            l.append(retorna_col_plain('chave',chave,'character(44)',"'"))
        except:
            plpy.notice(traceback.format_exc())
            l.append(retorna_col_plain('chave','NULL','character(44)',''))

        try:
            l.append(retorna_col('numeronf',ide.findAll('nnf'),'character(10)'))
        except:
            return ''
            
        l.append(retorna_col('serie',ide.findAll('serie'),'character(3)'))
        ##plpy.notice(ide.findAll('nnf')[0].text)


        if len(ide.findAll('demi')) == 0:
            l.append(retorna_col('data_emissao',ide.findAll('dhemi'),'date'))
        else:
            l.append(retorna_col('data_emissao',ide.findAll('demi'),'date'))


        l.append(retorna_col('indpag',oDom.findAll('modfrete'),'character(1)'))


        totais = oDom.findAll('total')[0]

        l.append(retorna_col('vlr_bc',totais.findAll('vbc'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_icms',totais.findAll('vicms'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_bcst',totais.findAll('vbcst'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_st',totais.findAll('vst'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_prod',totais.findAll('vprod'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_frete',totais.findAll('vfrete'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_seg',totais.findAll('vseg'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_desc',totais.findAll('vdesc'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_ipi',totais.findAll('vipi'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_pis',totais.findAll('vpis'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_cofins',totais.findAll('vcofins'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_outro',totais.findAll('voutro'),'numeric(12,2)','','0.00'))
        l.append(retorna_col('vlr_nf',totais.findAll('vnf'),'numeric(12,2)','','0.00'))
        


        pag = oDom.findAll('tpag')
        l.append(retorna_col('tpag',pag,'character(3)'))

        transp = oDom.findAll('transp')[0]
        l.append(retorna_col('modfrete',transp.findAll('modfrete'),'character(1)'))

        try:
            info = oDom.findAll('infadic')[0]
            l.append(retorna_col('obs',info.findAll('infcpl'),'text'))            
        except:            
            l.append(retorna_col_plain('obs','NULL','text',''))

        
        try:
            l.append(retorna_col('transportador_cnpj',transp.findAll('cnpj'),'character(14)'))
        except:        
            l.append(retorna_col_plain('transportador_cnpj','NULL','text',''))

        
            
        lst_comando = [x['valor'] + '::' + x['tipo'] + ' as ' + x['coluna'] for x in l]

        cmd_sql = 'SELECT ' + ','.join(lst_comando) + ';'

        return cmd_sql

    def ret_dados_fatura(oDom):
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

    ##plpy.notice(p_xml[0:250])
    v_xml = p_xml
    dom = BeautifulSoup(v_xml)

    #plpy.notice(v_xml)
    cmd_comandos = ''
    
    nfe            = ret_dados_nfe(dom)
    if nfe == '':
        return '';
        
    emitente         = ret_emitente(dom)
    destinatario     = ret_destinatario(dom)
    produtos         = ret_produtos(dom)
    fatura        = ret_dados_fatura(dom)

    cmd_comandos = nfe + '###' + emitente + '###' + destinatario + '###' + produtos + '###' + fatura

    return cmd_comandos
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

