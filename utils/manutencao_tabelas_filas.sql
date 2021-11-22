SELECT count(*) FROM msg_fila_envio;

SELECT * FROM msg_fila_envio LIMIT 100;

SELECT count(*) FROM msg_fila_edi ;



DELETE FROM msg_fila_envio WHERE data_envio < '2021-08-20 00:00:00';
DELETE FROM msg_fila_envio WHERE id_banco_dados IS NULL;

DELETE FROM msg_fila_edi WHERE data_envio < '2021-08-20 00:00:00';
DELETE FROM msg_fila_edi WHERE id_banco_dados IS NULL;
--SELECT count(*) FROM msg_fila_averb_atm; 

DELETE FROM msg_fila_averb_atm WHERE data_fila < '2021-08-20 00:00:00';
DELETE FROM msg_fila_averb_atm WHERE id_banco_dados IS NULL;
--DELETE FROM msg_fila_envio WHERE data_registro < '2020-03-01 00:00:00'