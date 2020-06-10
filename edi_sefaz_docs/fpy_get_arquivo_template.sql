CREATE OR REPLACE FUNCTION fpy_get_arquivo(dados text, leiaute text)
  RETURNS text AS
$BODY$
import json

import os
from jinja2 import Environment, FileSystemLoader

TEMPLATE_ENVIRONMENT = Environment(
    autoescape=True,    
    trim_blocks=True,
    lstrip_blocks=True)

contexto = {}
contexto['dados'] = json.loads(dados)
v_retorno = TEMPLATE_ENVIRONMENT.from_string(leiaute).render(contexto)

return v_retorno

$BODY$
  LANGUAGE plpython3u VOLATILE;
