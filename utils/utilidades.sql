--UPDATE tabela SET xml = fpy_limpa_caracteres(xml_texto)::xml WHERE condicao

--SELECT fpy_limpa_caracteres('RUA EDUARDO CARLOS  N� 950, SN, ARAGUAIA - BELO HORIZONTE - MG');

--SELECT * FROM scr_notas_fiscais_imp_ocorrencias WHERE obs_ocorrencia IS NOT NULL AND data_registro >= '2019-04-01'
--UPDATE scr_notas_fiscais_imp_ocorrencias SET obs_ocorrencia = fpy_limpa_caracteres(obs_ocorrencia) WHERE obs_ocorrencia IS NOT NULL AND data_registro >= '2019-01-01'

CREATE OR REPLACE FUNCTION fpy_limpa_caracteres(xml text)
  RETURNS text AS
$BODY$
import re

if xml is None:
    return None

EXP = '[^\x09\x0A\x0D\x20-\x7E\xE1\xE0\xE2\xE3\xE4\xE9\xE8\xEA\xEB\xED\xEC\xEF\xF3\xF2\xF4\xF5\xF6\xFA\xF9\xFB\xFC\xC1\xC0\xC2\xC3\xC4\xC9\xC8\xCA\xCB\xCD\xCC\xCF\xD3\xD2\xD4\xD5\xD6\xDA\xD9\xDB\xDC\xE7\xC7\x26]'

v_retorno = re.sub(EXP,"",xml)

return v_retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;



CREATE OR REPLACE FUNCTION public.retira_acento(text)
  RETURNS text AS
$BODY$
	SELECT translate($1,'áàâãäéèêëíìïóòôõöúùûüÁÀÂÃÄÉÈÊËÍÌÏÓÒÔÕÖÚÙÛÜçÇ&''','aaaaaeeeeiiiooooouuuuAAAAAEEEEIIIOOOOOUUUUcCe ');
$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;
