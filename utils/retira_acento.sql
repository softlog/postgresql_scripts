-- Function: public.retira_acento(text)

-- DROP FUNCTION public.retira_acento(text);

CREATE OR REPLACE FUNCTION public.retira_acento(text)
  RETURNS text AS
$BODY$
	SELECT translate($1,'באגדהיטךכםלןףעפץצתשûüְֱֲֳִָֹÊֻּֽֿ׃ׂװױײÚÙÛÜחַ''','aaaaaeeeeiiiooooouuuuAAAAAEEEEIIIOOOOOUUUUcC ');
$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;

