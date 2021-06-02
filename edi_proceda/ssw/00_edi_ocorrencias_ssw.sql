CREATE TABLE edi_ocorrencias_ssw 
(
	id serial NOT NULL,
	codigo_status integer,
	descricao character(150),
	tipo character(50),
	processo character(15),
	id_ocorrencia_softlog integer,
	CONSTRAINT edi_ocorrencias_ssw_id_pk PRIMARY KEY (id)
);


INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (1,'MERCADORIA ENTREGUE','ENTREGA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (2,'MERCADORIA PRE-ENTREGUE (MOBILE)','PRÉENTREGA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (3,'MERCADORIA DEVOLVIDA AO REMETENTE','ENTREGA','DEVOLUÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (4,'DESTINATARIO RETIRA','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (5,'CLIENTE ALEGA MERCAD DESACORDO C/ PEDIDO','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (7,'CHEGADA NO CLIENTE DESTINATÁRIO','INFORMATIVA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (9,'DESTINATARIO DESCONHECIDO','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (10,'LOCAL DE ENTREGA NAO LOCALIZADO','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (11,'LOCAL DE ENTREGA FECHADO/AUSENTE','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (13,'ENTREGA PREJUDICADA PELO HORARIO','PENDÊNCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (14,'NOTA FISCAL ENTREGUE','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (15,'ENTREGA AGENDADA PELO CLIENTE','PENDÊNCIA CLIENTE','AGENDAMENTO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (16,'ENTREGA AGUARDANDO INSTRUCOES','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (17,'MERCADORIA ENTREGUE NO PARCEIRO','INFORMATIVA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (18,'MERCAD REPASSADA P/ PROX TRANSPORTADORA','ENTREGA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (20,'CLIENTE ALEGA FALTA DE MERCADORIA','PENDÊNCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (23,'CLIENTE ALEGA MERCADORIA AVARIADA','PENDÊNCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (25,'REMETENTE RECUSA RECEBER DEVOLUÇÃO','PENDÊNCIA CLIENTE','DEVOLUÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (26,'AGUARDANDO AUTORIZACAO P/ DEVOLUCAO','PENDÊNCIA CLIENTE','DEVOLUÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (27,'DEVOLUCAO AUTORIZADA','INFORMATIVA','DEVOLUÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (28,'AGUARDANDO AUTORIZACAO P/ REENTREGA','PENDÊNCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (29,'REENTREGA AUTORIZADA','INFORMATIVA','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (31,'PRIMEIRA TENTATIVA DE ENTREGA','PENDÊNCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (32,'SEGUNDA TENTATIVA DE ENTREGA','PENDÊNCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (33,'TERCEIRA TENTATIVA DE ENTREGA','PENDÊNCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (34,'MERCADORIA EM CONFERENCIA NO CLIENTE','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (35,'AGUARDANDO AGENDAMENTO DO CLIENTE','PENDÊNCIA CLIENTE','AGENDAMENTO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (36,'MERCAD EM DEVOLUCAO EM OUTRA OPERACAO','BAIXA','DEVOLUÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (37,'ENTREGA REALIZADA COM RESSALVA','PENDÊNCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (38,'CLIENTE RECUSA/NAO PODE RECEBER MERCAD','PENDÊNCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (39,'CLIENTE RECUSA PAGAR O FRETE','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (40,'FRETE DO CTRC DE ORIGEM RECEBIDO','INFORMATIVA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (45,'CARGA SINISTRADA PENDÊNCIA','CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (50,'FALTA DE MERCADORIA','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (51,'SOBRA DE MERCADORIA','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (52,'FALTA DE DOCUMENTACAO','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (53,'MERCADORIA AVARIADA','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (54,'EMBALAGEM AVARIADA','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (55,'CARGA ROUBADA','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (56,'MERCAD RETIDA PELA FISCALIZACAO','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (57,'GREVE OU PARALIZACAO','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (58,'MERCAD LIBERADA PELA FISCALIZACAO','INFORMATIVA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (59,'VEICULO AVARIADO/SINISTRADO','PENDÊNCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (60,'VIA INTERDITADA','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (61,'MERCADORIA CONFISCADA PELA FISCALIZAÇÃO','BAIXA','FINALIZADORA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (62,'VIA INTERDITADA POR FATORES NATURAIS','PENDÊNCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (65,'NOTIFIC REMET DE ENVIO NOVA MERCAD','PENDÊNCIA TRANSPORTADORA','FINALIZADORA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (66,'NOVA MERCAD ENVIADA PELO REMETENTE','INFORMATIVA','FINALIZADORA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (73,'AGUARDANDO DISPONIBILIDADE DE BALSA','INFORMATIVA','BALSA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (74,'PRIMEIRA TENTATIVA DE COLETA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (75,'SEGUNDA TENTATIVA DE COLETA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (76,'TERCEIRA TENTATIVA DE COLETA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (77,'COLETA CANCELADA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (78,'COLETA REVERSA REALIZADA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (79,'COLETA REVERSA AGENDADA','INFORMATIVA','COLETA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (80,'MERCADORIA RECEBIDA PARA TRANSPORTE','INFORMATIVA','OPERACIONAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (82,'SAIDA DE UNIDADE','INFORMATIVA','OPERACIONAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (83,'CHEGADA EM UNIDADE','INFORMATIVA','OPERACIONAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (84,'CHEGADA NA UNIDADE','INFORMATIVA','OPERACIONAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (85,'SAIDA PARA ENTREGA','INFORMATIVA','OPERACIONAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (86,'ESTORNO DE BAIXA/ENTREGA ANTERIOR','INFORMATIVA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (91,'MERCADORIA EM INDENIZACAO','PENDÊNCIA TRANSPORTADORA','INDENIZAÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (92,'MERCADORIA INDENIZADA','BAIXA','INDENIZAÇÃO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (93,'CTRC EMITIDO PARA EFEITO DE FRETE','BAIXA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (94,'CTRC SUBSTITUIDO','BAIXA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (99,'CTRC BAIXADO/CANCELADO','BAIXA','GERAL');

