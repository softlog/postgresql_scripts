-- Function: public.f_py_get_cmd_bloco_cte(text)
-- SELECT f_py_get_cmd_bloco_cte_v2(xml_nfe) FROM xml_nfe WHERE id = 279
-- DROP FUNCTION public.f_py_get_cmd_bloco_cte_v2('<?xml version="1.0" encoding="UTF-8"?>
-- UPDATE xml_nfe SET id = id 
-- Function: public.f_py_get_cmd_bloco_cte(text)
-- SELECT tipo_documento, * FROM xml_nfe WHERE status = 1
-- DROP FUNCTION public.f_py_get_cmd_bloco_cte(text);

CREATE OR REPLACE FUNCTION public.f_py_get_chave_cte(p_xml text)
  RETURNS text AS
$BODY$
    
from bs4 import BeautifulSoup
import base64
import traceback

   
try:
    oDom = BeautifulSoup(p_xml)
    r = oDom.find("infcte")
    chave =  r.attrs.get('id')[3:] 
    
    return chave
except:
    return None
  
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

