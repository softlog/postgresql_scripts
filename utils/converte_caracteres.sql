--SELECT fpy_contem_char_no_ascii(nome_cliente) as nome_convertido, * FROm cliente WHERE nome_cliente like '%Ãƒ%'
-- 
--SELECT converte_caracteres_especiais('JOÃƒÂ¿O LEANDRO LAGO DA COSTA'),'Ãƒ','Ã')
-- 
--SELECT replace('J C DISTRIBUIDORA E SERVIÃƒÂ¿OS LTDAME','ÃƒÂ¿','Ç')
--SELECT 'v_str = replace(v_str,''' || utf8 || ''',''' || letra || ''');' as comando  FROM mapa_char_especiais

 
CREATE OR REPLACE FUNCTION converte_caracteres_especiais(p_str text)
  RETURNS text AS
$BODY$
DECLARE
        v_str text;
BEGIN

	v_str = p_str;
	
	v_str = replace(v_str,'Ã¡','á');
	v_str = replace(v_str,'Ã ','à');
	v_str = replace(v_str,'Ã¢','â');
	v_str = replace(v_str,'Ã£','ã');
	v_str = replace(v_str,'Ã¤','ä');
	v_str = replace(v_str,'Ã©','é');
	v_str = replace(v_str,'Ã¨','è');
	v_str = replace(v_str,'Ãª','ê');
	v_str = replace(v_str,'Ã«','ë');
	v_str = replace(v_str,'Ã­','í');
	v_str = replace(v_str,'Ã¬','ì');
	v_str = replace(v_str,'Ã®','î');
	v_str = replace(v_str,'Ã¯','ï');
	v_str = replace(v_str,'Ã³','ó');
	v_str = replace(v_str,'Ã²','ò');
	v_str = replace(v_str,'Ã´','ô');
	v_str = replace(v_str,'Ãµ','õ');
	v_str = replace(v_str,'Ã¶','ö');
	v_str = replace(v_str,'Ãº','ú');
	v_str = replace(v_str,'Ã¹','ù');
	v_str = replace(v_str,'Ã»','û');
	v_str = replace(v_str,'Ã¼','ü');
	v_str = replace(v_str,'Ã§','ç');
	v_str = replace(v_str,'Ã','Á');
	v_str = replace(v_str,'Ã€','À');
	v_str = replace(v_str,'Ã‚','Â');
	v_str = replace(v_str,'Ãƒ','Ã');
	v_str = replace(v_str,'Ã„','Ä');
	v_str = replace(v_str,'Ã‰','É');
	v_str = replace(v_str,'Ãˆ','È');
	v_str = replace(v_str,'ÃŠ','Ê');
	v_str = replace(v_str,'Ã‹','Ë');
	v_str = replace(v_str,'Ã','Í');
	v_str = replace(v_str,'ÃŒ','Ì');
	v_str = replace(v_str,'ÃŽ','Î');
	v_str = replace(v_str,'Ã','Ï');
	v_str = replace(v_str,'Ã“','Ó');
	v_str = replace(v_str,'Ã’','Ò');
	v_str = replace(v_str,'Ã”','Ô');
	v_str = replace(v_str,'Ã•','Õ');
	v_str = replace(v_str,'Ã–','Ö');
	v_str = replace(v_str,'Ãš','Ú');
	v_str = replace(v_str,'Ã™','Ù');
	v_str = replace(v_str,'Ã›','Û');
	v_str = replace(v_str,'Ãœ','Ü');
	v_str = replace(v_str,'Ã‡','Ç');
        
	RETURN v_str;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE;

--SELECT * FROM v_mapa_char_especiais



CREATE VIEW v_mapa_char_especiais AS
WITH t AS (
	SELECT 'á'
	 as letra, 1 as id UNION SELECT  'à'
	 as letra, 2 as id UNION SELECT  'â'
	 as letra, 3 as id UNION SELECT  'ã'
	 as letra, 4 as id UNION SELECT  'ä'
	 as letra, 5 as id UNION SELECT  'é'
	 as letra, 6 as id UNION SELECT  'è'
	 as letra, 7 as id UNION SELECT  'ê'
	 as letra, 8 as id UNION SELECT  'ë'
	 as letra, 9 as id UNION SELECT  'í'
	 as letra, 10 as id UNION SELECT  'ì'
	 as letra, 11 as id UNION SELECT  'î'
	 as letra, 12 as id UNION SELECT  'ï'
	 as letra, 13 as id UNION SELECT  'ó'
	 as letra, 14 as id UNION SELECT  'ò'
	 as letra, 15 as id UNION SELECT  'ô'
	 as letra, 16 as id UNION SELECT  'õ'
	 as letra, 17 as id UNION SELECT  'ö'
	 as letra, 18 as id UNION SELECT  'ú'
	 as letra, 19 as id UNION SELECT  'ù'
	 as letra, 20 as id UNION SELECT  'û'
	 as letra, 21 as id UNION SELECT  'ü'
	 as letra, 22 as id UNION SELECT  'ç'
	 as letra, 23 as id UNION SELECT  'Á'
	 as letra, 24 as id UNION SELECT  'À'
	 as letra, 25 as id UNION SELECT  'Â'
	 as letra, 26 as id UNION SELECT  'Ã'
	 as letra, 27 as id UNION SELECT  'Ä'
	 as letra, 28 as id UNION SELECT  'É'
	 as letra, 29 as id UNION SELECT  'È'
	 as letra, 30 as id UNION SELECT  'Ê'
	 as letra, 31 as id UNION SELECT  'Ë'
	 as letra, 32 as id UNION SELECT  'Í'
	 as letra, 33 as id UNION SELECT  'Ì'
	 as letra, 34 as id UNION SELECT  'Î'
	 as letra, 35 as id UNION SELECT  'Ï'
	 as letra, 36 as id UNION SELECT  'Ó'
	 as letra, 37 as id UNION SELECT  'Ò'
	 as letra, 38 as id UNION SELECT  'Ô'
	 as letra, 39 as id UNION SELECT  'Õ'
	 as letra, 40 as id UNION SELECT  'Ö'
	 as letra, 41 as id UNION SELECT  'Ú'
	 as letra, 42 as id UNION SELECT  'Ù'
	 as letra, 43 as id UNION SELECT  'Û'
	 as letra, 44 as id UNION SELECT  'Ü'
	 as letra, 45 as id UNION SELECT  'Ç'
	 as letra, 46 as id
),
t2 AS (
	SELECT 'Ã¡'  
	as utf8, 1 as id UNION SELECT 'Ã ' 
	as utf8, 2 as id UNION SELECT 'Ã¢'  
	as utf8, 3 as id UNION SELECT 'Ã£'  
	as utf8, 4 as id UNION SELECT 'Ã¤'  
	as utf8, 5 as id UNION SELECT 'Ã©'  
	as utf8, 6 as id UNION SELECT 'Ã¨'  
	as utf8, 7 as id UNION SELECT 'Ãª'  
	as utf8, 8 as id UNION SELECT 'Ã«'  
	as utf8, 9 as id UNION SELECT 'Ã­'  
	as utf8, 10 as id UNION SELECT 'Ã¬'  
	as utf8, 11 as id UNION SELECT 'Ã®'  
	as utf8, 12 as id UNION SELECT 'Ã¯'  
	as utf8, 13 as id UNION SELECT 'Ã³'  
	as utf8, 14 as id UNION SELECT 'Ã²'  
	as utf8, 15 as id UNION SELECT 'Ã´'  
	as utf8, 16 as id UNION SELECT 'Ãµ'  
	as utf8, 17 as id UNION SELECT 'Ã¶'  
	as utf8, 18 as id UNION SELECT 'Ãº'
	as utf8, 19 as id UNION SELECT 'Ã¹'  
	as utf8, 20 as id UNION SELECT 'Ã»'  
	as utf8, 21 as id UNION SELECT 'Ã¼'  
	as utf8, 22 as id UNION SELECT 'Ã§'  
	as utf8, 23 as id UNION SELECT 'Ã'  
	as utf8, 24 as id UNION SELECT 'Ã€'  
	as utf8, 25 as id UNION SELECT 'Ã‚'  
	as utf8, 26 as id UNION SELECT 'Ãƒ'  
	as utf8, 27 as id UNION SELECT 'Ã„'  
	as utf8, 28 as id UNION SELECT 'Ã‰'
	as utf8, 29 as id UNION SELECT 'Ãˆ'  
	as utf8, 30 as id UNION SELECT 'ÃŠ'  
	as utf8, 31 as id UNION SELECT 'Ã‹'  
	as utf8, 32 as id UNION SELECT 'Ã'  
	as utf8, 33 as id UNION SELECT 'ÃŒ'  
	as utf8, 34 as id UNION SELECT 'ÃŽ'  
	as utf8, 35 as id UNION SELECT 'Ã'  
	as utf8, 36 as id UNION SELECT 'Ã“'  
	as utf8, 37 as id UNION SELECT 'Ã’'  
	as utf8, 38 as id UNION SELECT 'Ã”'
	as utf8, 39 as id UNION SELECT 'Ã•'  
	as utf8, 40 as id UNION SELECT 'Ã–'  
	as utf8, 41 as id UNION SELECT 'Ãš'  
	as utf8, 42 as id UNION SELECT 'Ã™'  
	as utf8, 43 as id UNION SELECT 'Ã›'  
	as utf8, 44 as id UNION SELECT 'Ãœ'  
	as utf8, 45 as id UNION SELECT 'Ã‡'
	as utf8, 46 as id
) 
SELECT 
	t.id,
	t.letra,
	t2.utf8
FROM 
	t 
	LEFT JOIN t2 ON t.id = t2.id
ORDER BY 
	t.id;