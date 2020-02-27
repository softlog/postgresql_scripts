


BEGIN;

SELECT * FROM fd_drop_visoes_dependentes('log_retorno_banco');

ALTER TABLE log_retorno_banco ALTER COLUMN arquivo TYPE character(60);

SELECT * FROM fd_restaura_visoes_dependentes('log_retorno_banco');

COMMIT;