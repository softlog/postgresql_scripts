SELECT * FROM string_conexoes ORDER BY 2


SELECT * FROM msg_fila_envio WHERE id_banco_dados = 42 AND id_notificacao = 10

SELECT * FROM msg_notificacao ORDER BY 1;

SELECT * FROM msg_subscricao WHERE id_notificacao = 10;


SELECT id_conhecimento, tipo_documento, data_entrega, numero_ctrc_filial, consig_red_nome, status, pagador_id, consig_red_id FROM scr_conhecimento WHERE consig_red_id = 1935 ORDER BY 1 DESC LIMIT 100;

UPDATE scr_conhecimento SET status = 5 WHERE id_conhecimento = 28642;

1981
1935
154




