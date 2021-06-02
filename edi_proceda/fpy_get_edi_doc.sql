-- Function: public.fpy_get_edi_doc(text, integer)

-- DROP FUNCTION public.fpy_get_edi_doc(text, integer);

CREATE OR REPLACE FUNCTION public.fpy_get_edi_doc(
    v_lista_chaves text,
    v_id_doc_edi integer)
  RETURNS text AS
$BODY$
    from tpl_edi_tools import tpl_edi
    import json
    import traceback

    str_sql = """SELECT formato_doc, funcao_responsavel
                FROM edi_tms_docs
                WHERE id_doc = %i""" % (v_id_doc_edi)

    dados_edi = plpy.execute(str_sql,1)

    nome_funcao = dados_edi[0]["funcao_responsavel"]
    template = dados_edi[0]["formato_doc"]

    str_sql_2 = """
                    SELECT
                        %s('{%s}'::integer[])as dados
                    """ % (nome_funcao, v_lista_chaves)

    dados_json_edi = plpy.execute(str_sql_2,1)

    json_edi_text = dados_json_edi[0]["dados"]

    json_edi = json.loads(json_edi_text)

    mk_doc_edi = tpl_edi()

    try:
        arquivo_edi = mk_doc_edi.get_doc_edi(json_edi,template)
        arquivo_edi = arquivo_edi.replace('\n','\r\n')
    except Exception as e:
        
        arquivo_edi = traceback.format_exc()
    
    return arquivo_edi



$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

