	
CREATE OR REPLACE FUNCTION public.fpy_extrai_valor(
    texto text,
    termo text)
  RETURNS text AS
$BODY$

    import re
    import traceback
    try:
        l = texto.partition(termo)

        #Verifica se a divisão foi bem sucedida 
        if l[2] is not None:
            r = l[2].strip().split(' ')[0]
        else:
            r = None
    except Exception as e:
        r = None

    if r is not None and r != '':
        
        return r.strip()

    try:
        l = re.findall(termo,texto)
        
        r = l[0].strip()                
        if r.strip() == '':
            r = None
    except:
        #plpy.notice(termo)
        #plpy.notice(texto)
        #plpy.notice(traceback.format_exc())
        r = None

    return r
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_extrai_valor(texto text, termo text) OWNER TO softlog_solar;