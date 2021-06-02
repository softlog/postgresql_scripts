-- Integracao Parceiros
--DELETE FROM msg_notificacao WHERE id_notificacao IN (400,401,402)
INSERT INTO msg_notificacao (id_notificacao, ativo, notificacao, especie_notificacao, notifica_fornecedor)
VALUES (400,1,'Envio de NFe Transportada por NFe romaneada',1,1);

INSERT INTO msg_notificacao (id_notificacao, ativo, notificacao, especie_notificacao, notifica_fornecedor)
VALUES (401,1,'Envio de NFe Transportada por Cte romaneado',1,1);

INSERT INTO msg_notificacao (id_notificacao, ativo, notificacao, especie_notificacao, notifica_fornecedor)
VALUES (402,1,'Envio de NFe Transportada por Cte emitido',1,1);


--DELETE FROM msg_notificacao WHERE id_notificacao = 400

