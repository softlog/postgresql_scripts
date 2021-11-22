CREATE OR REPLACE FUNCTION f_exec_cmd(cmd text)
  RETURNS integer AS
$BODY$
DECLARE
     v_cursor refcursor;
     v_cmd text;   
BEGIN
	RAISE NOTICE '%',cmd;
        OPEN v_cursor FOR EXECUTE cmd;

        FETCH v_cursor INTO v_cmd;

        CLOSE v_cursor;

        EXECUTE v_cmd;
        
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


  WITH t AS (
	SELECT 
		('WITH t AS (

			SELECT last_value, ''' || c.relname || '''::text as sequencia FROM ' || c.relname  || ' 
		) 
		SELECT ''ALTER SEQUENCE ''|| sequencia || '' RESTART WITH '' || (last_value + 1000000)::text || '';'' FROM t;') as cmd
		
	FROM 
		pg_class c 
	WHERE c.relkind = 'S'
) SELECT f_exec_cmd(cmd) FROM t;