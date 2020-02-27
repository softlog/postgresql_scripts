CREATE TABLE fila_documentos_integracoes
(
	id serial NOT NULL,  
	tipo_integracao integer,
	tipo_documento integer,
	data_registro timestamp DEFAULT NOW(),
	data_processamento timestamp,
	enviado integer DEFAULT 0,
	qt_tentativas integer DEFAULT 0,
	pendencia integer DEFAULT 0,
	id_nota_fiscal_imp integer,
	id_conhecimento_notas_fiscais integer,
	id_conhecimento integer,
	id_romaneio integer,  
	mensagens json,
	CONSTRAINT scr_notas_fiscais_integracoes_id_pk PRIMARY KEY (id)  
);

COMMENT ON COLUMN fila_documentos_integracoes.tipo_integracao
		IS '1 - COMPROVEI, 2 - E-CONFIRMEI, 3-ITRACK, 5-VUUPT, 6 - EFrete';
COMMENT ON COLUMN fila_documentos_integracoes.tipo_documento
		IS '1-NFe; 2 - NFe-Com-Cte, 3 - CTe, 4 - Romaneio, 5 - Manifesto, 6 - Proprietario, 7 - Motorista, 8 - Veiculo ';
COMMENT ON COLUMN fila_documentos_integracoes.data_registro
		IS 'Data em que o registro foi inserido';
COMMENT ON COLUMN fila_documentos_integracoes.data_processamento
		IS 'Ultima data de processamento do registro';
COMMENT ON COLUMN fila_documentos_integracoes.enviado
		IS 'Flag para sinalizar se foi enviado';
COMMENT ON COLUMN fila_documentos_integracoes.qt_tentativas
		IS 'Numero de tentativas de envio';
COMMENT ON COLUMN fila_documentos_integracoes.pendencia
		IS 'Flag para indicar se o documento tem pendencia';
COMMENT ON COLUMN fila_documentos_integracoes.mensagens
		IS 'Mensagens recebidas nos processamentos';


ALTER TABLE fila_documentos_integracoes ADD COLUMN id_integracao integer;

ALTER TABLE fila_documentos_integracoes ADD COLUMN finalizou_processo integer DEFAULT 0;

ALTER TABLE fila_documentos_integracoes ADD COLUMN principal integer DEFAULT 0;

ALTER TABLE fila_documentos_integracoes ADD COLUMN agrupado integer DEFAULT 0;

ALTER TABLE fila_documentos_integracoes ADD COLUMN alterar integer DEFAULT 0;

ALTER TABLE fila_documentos_integracoes ADD COLUMN acao text;

--ALTER TABLE fila_documentos_integracoes ADD COLUMN id_integracao integer;

--UPDATE fila_documentos_integracoes SET agrupado = 1 WHERE enviado = 1
--SELECT id_nota_fiscal_imp FROM scr_notas_fiscais_imp WHERE chave_nfe = '31181125392895000188550020001837351430261143'






--SELECT * FROM fila_documentos_integracoes WHERE id_romaneio = 136328
--SELECT * FROM api_integracao WHERE id_fila = 58869
--DELETE FROM fila_documentos_integracoes WHERE data_registro::date = '2018-07-04'