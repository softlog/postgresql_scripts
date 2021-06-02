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
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (2,'MERCADORIA PRE-ENTREGUE (MOBILE)','PR�ENTREGA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (3,'MERCADORIA DEVOLVIDA AO REMETENTE','ENTREGA','DEVOLU��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (4,'DESTINATARIO RETIRA','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (5,'CLIENTE ALEGA MERCAD DESACORDO C/ PEDIDO','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (7,'CHEGADA NO CLIENTE DESTINAT�RIO','INFORMATIVA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (9,'DESTINATARIO DESCONHECIDO','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (10,'LOCAL DE ENTREGA NAO LOCALIZADO','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (11,'LOCAL DE ENTREGA FECHADO/AUSENTE','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (13,'ENTREGA PREJUDICADA PELO HORARIO','PEND�NCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (14,'NOTA FISCAL ENTREGUE','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (15,'ENTREGA AGENDADA PELO CLIENTE','PEND�NCIA CLIENTE','AGENDAMENTO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (16,'ENTREGA AGUARDANDO INSTRUCOES','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (17,'MERCADORIA ENTREGUE NO PARCEIRO','INFORMATIVA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (18,'MERCAD REPASSADA P/ PROX TRANSPORTADORA','ENTREGA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (20,'CLIENTE ALEGA FALTA DE MERCADORIA','PEND�NCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (23,'CLIENTE ALEGA MERCADORIA AVARIADA','PEND�NCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (25,'REMETENTE RECUSA RECEBER DEVOLU��O','PEND�NCIA CLIENTE','DEVOLU��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (26,'AGUARDANDO AUTORIZACAO P/ DEVOLUCAO','PEND�NCIA CLIENTE','DEVOLU��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (27,'DEVOLUCAO AUTORIZADA','INFORMATIVA','DEVOLU��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (28,'AGUARDANDO AUTORIZACAO P/ REENTREGA','PEND�NCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (29,'REENTREGA AUTORIZADA','INFORMATIVA','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (31,'PRIMEIRA TENTATIVA DE ENTREGA','PEND�NCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (32,'SEGUNDA TENTATIVA DE ENTREGA','PEND�NCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (33,'TERCEIRA TENTATIVA DE ENTREGA','PEND�NCIA CLIENTE','REENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (34,'MERCADORIA EM CONFERENCIA NO CLIENTE','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (35,'AGUARDANDO AGENDAMENTO DO CLIENTE','PEND�NCIA CLIENTE','AGENDAMENTO');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (36,'MERCAD EM DEVOLUCAO EM OUTRA OPERACAO','BAIXA','DEVOLU��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (37,'ENTREGA REALIZADA COM RESSALVA','PEND�NCIA TRANSPORTADORA','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (38,'CLIENTE RECUSA/NAO PODE RECEBER MERCAD','PEND�NCIA CLIENTE','ENTREGA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (39,'CLIENTE RECUSA PAGAR O FRETE','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (40,'FRETE DO CTRC DE ORIGEM RECEBIDO','INFORMATIVA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (45,'CARGA SINISTRADA PEND�NCIA','CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (50,'FALTA DE MERCADORIA','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (51,'SOBRA DE MERCADORIA','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (52,'FALTA DE DOCUMENTACAO','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (53,'MERCADORIA AVARIADA','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (54,'EMBALAGEM AVARIADA','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (55,'CARGA ROUBADA','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (56,'MERCAD RETIDA PELA FISCALIZACAO','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (57,'GREVE OU PARALIZACAO','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (58,'MERCAD LIBERADA PELA FISCALIZACAO','INFORMATIVA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (59,'VEICULO AVARIADO/SINISTRADO','PEND�NCIA TRANSPORTADORA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (60,'VIA INTERDITADA','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (61,'MERCADORIA CONFISCADA PELA FISCALIZA��O','BAIXA','FINALIZADORA');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (62,'VIA INTERDITADA POR FATORES NATURAIS','PEND�NCIA CLIENTE','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (65,'NOTIFIC REMET DE ENVIO NOVA MERCAD','PEND�NCIA TRANSPORTADORA','FINALIZADORA');
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
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (91,'MERCADORIA EM INDENIZACAO','PEND�NCIA TRANSPORTADORA','INDENIZA��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (92,'MERCADORIA INDENIZADA','BAIXA','INDENIZA��O');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (93,'CTRC EMITIDO PARA EFEITO DE FRETE','BAIXA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (94,'CTRC SUBSTITUIDO','BAIXA','GERAL');
INSERT INTO edi_ocorrencias_ssw (codigo_status,descricao, tipo, processo) VALUES (99,'CTRC BAIXADO/CANCELADO','BAIXA','GERAL');

