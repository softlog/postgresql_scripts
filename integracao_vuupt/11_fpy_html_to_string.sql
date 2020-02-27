--set client_encoding to UTF8;
--SELECT convert(fpy_html_to_string('{"message":"Erro inserindo item","errors":{"name":["O campo name \u00e9 obrigat\u00f3rio."],"source":["O campo source \u00e9 obrigat\u00f3rio."],"start_at":["O campo start at \u00e9 obrigat\u00f3rio."],"start_location_base_id":["O campo start location base id \u00e9 obrigat\u00f3rio."],"end_location_type":["O campo end location type \u00e9 obrigat\u00f3rio."],"agent_id":["O campo agent id \u00e9 obrigat\u00f3rio."],"vehicle_id":["O campo vehicle id \u00e9 obrigat\u00f3rio."],"transport_mode":["O campo transport mode \u00e9 obrigat\u00f3rio."]},"status_code":422}')
--SELECT char_length('\u00e9')
CREATE OR REPLACE FUNCTION public.fpy_html_to_string(texto text)
  RETURNS text AS
$BODY$

if texto is None:
    return None
else:
    try:
        r = eval("u'" + texto + "'")
        ##plpy.notice(eval("u'"+texto + "'"))
    except:
        r = texto

    return r
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;


  --SELECT retira_acento(fpy_html_to_string(resposta)), convert_from(convert_to(resposta,'SQL_ASCII'),'utf-8'), * FROM api_integracao WHERE id_fila  = 9415
--SELECT jsonb_pretty('{"message":"Erro inserindo item","errors":{"name":["O campo name é obrigatório."],"source":["O campo source é obrigatório."],"start_at":["O campo start at é obrigatório."],"start_location_base_id":["O campo start location base id é obrigatório."],"end_location_type":["O campo end location type é obrigatório."],"agent_id":["O campo agent id é obrigatório."],"vehicle_id":["O campo vehicle id é obrigatório."],"transport_mode":["O campo transport mode é obrigatório."]},"status_code":422}')

	