-- Function: public. SELECT * FROM fpy_get_cte_30(26933)

-- DROP FUNCTION public.fpy_get_cte_30(integer);

CREATE OR REPLACE FUNCTION public.fpy_get_cte_30(p_id_doc integer)
  RETURNS text AS
$BODY$

str_qry = """
SELECT
    numero_ctrc_filial,    
    chave_cte,
    xml_cte_com_assinatura,
    xml_proc_cte,
    xml_retorno,
    xml_proc_cancelamento,
    cancelado,
    modal,
    tipo_documento
FROM
    scr_conhecimento c
    LEFT JOIN scr_cte_lote_itens
        ON scr_cte_lote_itens.id_conhecimento = c.id_conhecimento
    LEFT JOIN cliente pagador ON pagador.codigo_cliente = c.pagador_id
    LEFT JOIN filial t ON t.codigo_empresa = c.empresa_emitente AND t.codigo_filial = c.filial_emitente
WHERE
    c.id_conhecimento =  %i 
    AND CASE WHEN c.tipo_documento = 1 THEN coalesce((xpath('/protCTe/infProt/cStat/text()', 	replace(xml_retorno,'xmlns="http://www.portalfiscal.inf.br/cte"','')::xml)::text[])[1],'') = '100' ELSE status = 1 END
    """ % (p_id_doc)

rv = plpy.execute(str_qry)

try:
    if len(rv) == 0:
        return ''
except:
        return ''

#CTe Emitido
if rv[0]['cancelado'] == 0 and rv[0]['tipo_documento'] == 1:
    #plpy.notice('Cte Emitido')
    xml_cte = rv[0]['xml_cte_com_assinatura'] 
    xml_proc_cte = rv[0]['xml_proc_cte'] 
    xml_retorno = rv[0]['xml_retorno']
    from bs4 import BeautifulSoup

    dom = BeautifulSoup(xml_cte)
    inf_cte =  dom.findAll('infcte')
    versao = inf_cte[0].attrs['versao']

    xml_cte = xml_cte.replace('<?xml version="1.0" encoding="UTF-8"?>','')
    #xml_cte = xml_cte.replace('<tpAmb>1</tpAmb>','<tpAmb>2</tpAmb>')
    xml = """<?xml version="1.0" encoding="UTF-8" ?><cteProc versao="%s" xmlns="http://www.portalfiscal.inf.br/cte">%s%s</cteProc>""" % (versao,xml_cte,xml_retorno)

#CTe cancelado
elif rv[0]['cancelado'] == 1 and rv[0]['tipo_documento'] == 1:
    #plpy.notice('Cte Cancelado')

    str_cancel = """SELECT xml_cancelamento 
                    FROM scr_conhecimento_averbacao
                    WHERE id_conhecimento = %i 
                          AND xml_cancelamento IS NOT NULL
                    LIMIT 1""" % (p_id_doc)


    rc = plpy.execute(str_cancel) 

    if rc.nrows() > 0:
        #plpy.notice(rc[0]['xml_cancelamento'])
        xml = rc[0]['xml_cancelamento']
        xml = xml.replace('<?xml version="1.0" encoding="UTF-8"?>','')
        #xml = xml.replace('<tpAmb>1</tpAmb>','<tpAmb>2</tpAmb>')
    else:
        xml = None    

#Minuta Emitida
elif rv[0]['cancelado'] == 0 and rv[0]['tipo_documento'] == 2:

    xml_minuta = rv[0]['xml_proc_cte']
    xml_retorno = rv[0]['xml_retorno']
    from bs4 import BeautifulSoup

    dom = BeautifulSoup(xml_minuta)
    inf_cte =  dom.findAll('infcte')
    versao = inf_cte[0].attrs['versao']

    xml_minuta = xml_minuta.replace('<?xml version="1.0" encoding="UTF-8"?>','')
    #xml_minuta = xml_minuta.replace('<tpAmb>1</tpAmb>','<tpAmb>2</tpAmb>')
    xml_minuta = xml_minuta.replace('<mod>57</mod>','<mod>94</mod>')

    pos1 = xml_minuta.find('<protCTe')    
    pos2 = xml_minuta.find('</protCTe>')

    if not(pos1 == -1 or pos2 == -1):
        xml_minuta = xml_minuta[0:pos1-1] + xml_minuta[pos2 + len('</protCTe>'):]
        xml = xml_minuta
        
#Minuta Cancelada
elif rv[0]['cancelado'] == 1 and rv[0]['tipo_documento'] == 2:

    xml_minuta = rv[0]['xml_proc_cte']
    xml_retorno = rv[0]['xml_retorno']
    xml_cancelado = rv[0]['xml_proc_cancelamento']

    from bs4 import BeautifulSoup

    dom = BeautifulSoup(xml_minuta)
    inf_cte =  dom.findAll('infcte')
    versao = inf_cte[0].attrs['versao']

    xml_minuta = xml_minuta.replace('<?xml version="1.0" encoding="UTF-8"?>','')
    #xml_minuta = xml_minuta.replace('<tpAmb>1</tpAmb>','<tpAmb>2</tpAmb>')
    xml_minuta = xml_minuta.replace('<mod>57</mod>','<mod>94</mod>')

    pos1 = xml_minuta.find('<protCTe')    
    pos2 = xml_minuta.find('</protCTe>')

    if not(pos1 == -1 or pos2 == -1):
        xml_minuta = xml_minuta[0:pos1-1] + xml_cancelado + '</cteProc>'

    xml = xml_minuta

else:
    xml = ''
    
return xml
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;
  
  
--ALTER FUNCTION public.fpy_get_cte_30(integer) OWNER TO softlog_seniorlog;
