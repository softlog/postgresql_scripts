--SELECT * FROM fpy_version()

CREATE OR REPLACE FUNCTION fpy_version()
  RETURNS text AS
$BODY$
import sys

return sys.version
$BODY$
  LANGUAGE plpython3u VOLATILE;


CREATE OR REPLACE FUNCTION fpy_path()
  RETURNS text[] AS
$BODY$
import sys

return sys.path
$BODY$
  LANGUAGE plpython3u VOLATILE;

--SELECT fpy_path()


