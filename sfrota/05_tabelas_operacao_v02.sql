/*
    Interface tera uma tela para registrar operação diária (frt_operacao_diaria).
    Nela terá uma Aba/Page com grid para registrar atividades das maquinas (frt_atividades).
    Atualizado por Itamar, 20200504 - V02
*/

----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS frt_operacao_diaria CASCADE;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_operacao_diaria
(
	id_operacao_diaria serial NOT NULL,
	data_inicial timestamp,
	hora_final timestamp,
	codigo_empresa character(3),
	codigo_filial character(3),  	
	CONSTRAINT frt_operacao_diaria_id_pk PRIMARY KEY (id_operacao_diaria)	
);

COMMENT ON COLUMN frt_operacao_diaria.id_operacao_diaria
		IS 'Chave primaria';
COMMENT ON COLUMN frt_operacao_diaria.data_inicial
		IS 'Data Hora que iniciou a operacao diaria';
COMMENT ON COLUMN frt_operacao_diaria.hora_final
		IS 'Data Hora que finalizou a operacao diaria';
COMMENT ON COLUMN frt_operacao_diaria.codigo_empresa
		IS 'Codigo Empresa da operacao';
COMMENT ON COLUMN frt_operacao_diaria.codigo_filial
		IS 'Codigo Filial da operacao';


----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS frt_tipo_atividades CASCADE;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_tipo_atividades
(
	id_tipo_atividade serial NOT NULL,
	atividade character(100),
	CONSTRAINT frt_tipo_atividades_id_pk PRIMARY KEY (id_tipo_atividade)
);

COMMENT ON COLUMN frt_tipo_atividades.id_tipo_atividade
		IS 'Chave Primaria';
COMMENT ON COLUMN frt_tipo_atividades.atividade
		IS 'Descricao da Atividade';

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('TRANSPORTE');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('LIMPEZA');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('CARREGAMENTO');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('SERVICOS PATIO');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('APLICACAO ADUBO');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('ADITIVACAO');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('UMIDECER LEIRA');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('MOLHAR PATIO');

INSERT INTO frt_tipo_atividades (atividade)
VALUES ('OUTRO');

----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS frt_atividades;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_atividades 
(
	id_atividade serial NOT NULL,
	id_operacao_diaria integer,
	placa_veiculo character(8),
	id_tipo_atividade integer,
	id_produto integer,
	id_filial_sub integer,
	id_operador integer,
	odometro_inicial integer,
	odometro_final integer,
	horimetro_inicial NUMERIC(8,1),
	horimetro_final NUMERIC(8,1),
	data_inicio timestamp,
	data_fim timestamp,
	status integer DEFAULT 0,
	pesagem NUMERIC(20,4) DEFAULT 0.0000,	
	CONSTRAINT frt_atividades_id_pk PRIMARY KEY (id_atividade),
	
	CONSTRAINT frt_atividades_id_operacao_diaria_fk FOREIGN KEY (id_operacao_diaria)
		REFERENCES frt_operacao_diaria (id_operacao_diaria) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,
			
	CONSTRAINT frt_atividades_placa_veiculo_fk FOREIGN KEY (placa_veiculo)
		REFERENCES veiculos (placa_veiculo) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT,
			
	CONSTRAINT frt_atividades_id_tipo_atividade_fk FOREIGN KEY (id_tipo_atividade)
		REFERENCES frt_tipo_atividades (id_tipo_atividade) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT,
			
	CONSTRAINT frt_atividades_id_produto_fk FOREIGN KEY (id_produto)
		REFERENCES com_produtos (id_produto) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT,
			
	CONSTRAINT frt_atividades_id_filial_sub_fk FOREIGN KEY (id_filial_sub)
		REFERENCES filial_sub (id_filial_sub) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT,
			
	CONSTRAINT frt_atividades_id_operador_fk FOREIGN KEY (id_operador)
		REFERENCES fornecedores (id_fornecedor) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT	
);

COMMENT ON COLUMN frt_atividades.id_atividade
		IS 'Chave Primaria';
COMMENT ON COLUMN frt_atividades.id_operacao_diaria
		IS 'Chave Estrangeira da Tabela frt_operacao_diaria';
COMMENT ON COLUMN frt_atividades.placa_veiculo
		IS 'Placa do veiculo/maquina da atividade realizada';
COMMENT ON COLUMN frt_atividades.id_tipo_atividade
		IS 'Chave Estrangeira para o tipo de atividade executada';
COMMENT ON COLUMN frt_atividades.id_produto
		IS 'Chave Estrangeira para o tipo de produto da atividade';
COMMENT ON COLUMN frt_atividades.id_filial_sub
		IS 'Chave Estrangeira do Local onde esta sendo realizada a atividade';
COMMENT ON COLUMN frt_atividades.id_operador
		IS 'Chave Estrandeira do Motorista/Operador da maquina';
COMMENT ON COLUMN frt_atividades.odometro_inicial
		IS 'Kilometragem inicial do veiculo/maquina';
COMMENT ON COLUMN frt_atividades.odometro_final
		IS 'Kilometragem final do veiculo/maquina';
COMMENT ON COLUMN frt_atividades.horimetro_inicial
		IS 'Horimetro inicial do veiculo/maquina';
COMMENT ON COLUMN frt_atividades.horimetro_final
		IS 'Horimetro final do veiculo/maquina';
COMMENT ON COLUMN frt_atividades.data_inicio
		IS 'Data/hora do inicio da atividade';
COMMENT ON COLUMN frt_atividades.data_fim
		IS 'Data/fim do inicio da atividade';
COMMENT ON COLUMN frt_atividades.status
		IS 'Status da atividade (para uso futuro)';
COMMENT ON COLUMN frt_atividades.pesagem
		IS 'Peso do produto da atividade realizada';

----------------------------------------------------------------------------------------------------
-- Tabela Interna de Controle
DROP TABLE IF EXISTS frt_tipo_inspecao CASCADE;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_tipo_inspecao
(
	id_tipo_inspecao integer NOT NULL,
	tipo_inspecao character(100),
	CONSTRAINT frt_tipo_inspecao_id PRIMARY KEY (id_tipo_inspecao)	
);	

COMMENT ON COLUMN frt_tipo_inspecao.id_tipo_inspecao
		IS 'Chave Primaria sem auto-incremento pois valor deve ser o mesmo em todas as bases de dados';
COMMENT ON COLUMN frt_tipo_inspecao.tipo_inspecao
		IS 'Descricao do tipo de inspecao';

INSERT INTO frt_tipo_inspecao (id_tipo_inspecao, tipo_inspecao)
VALUES (1, 'Detalhes de Inspecao por Maquina');

INSERT INTO frt_tipo_inspecao (id_tipo_inspecao, tipo_inspecao)
VALUES (2, 'Detalhes de Inspecao por Veiculo');

----------------------------------------------------------------------------------------------------
-- Tabela Interna de Controle
DROP TABLE IF EXISTS frt_tipo_inspecao_itens CASCADE;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_tipo_inspecao_itens
(
	id_tipo_inspecao_item serial NOT NULL,
	id_tipo_inspecao integer,
	nome_item character(200),
	descricao_positivo character(200),
	descricao_negativo character(200),
	CONSTRAINT frt_tipo_inspecao_itens_id PRIMARY KEY (id_tipo_inspecao_item),	
	CONSTRAINT frt_tipo_inspecao_itens_id_tipo_inspecao_fk FOREIGN KEY (id_tipo_inspecao)
		REFERENCES frt_tipo_inspecao (id_tipo_inspecao) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE
);	

COMMENT ON COLUMN frt_tipo_inspecao_itens.id_tipo_inspecao_item
		IS 'Chave Primaria';
COMMENT ON COLUMN frt_tipo_inspecao_itens.id_tipo_inspecao
		IS 'Chave Estrangeira do tipo de Inspecao';
COMMENT ON COLUMN frt_tipo_inspecao_itens.nome_item
		IS 'Descricao do Item de Inspecao';
COMMENT ON COLUMN frt_tipo_inspecao_itens.descricao_positivo
		IS 'Texto que aparece para usuario em caso positivo (ex.: Ok)';
COMMENT ON COLUMN frt_tipo_inspecao_itens.descricao_negativo
		IS 'Texto que aparece para o usuario em caso negativo (ex.: Danificado)';

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Parabrisas', 'Ok', 'Danificado');	

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Rodas', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Dobradicas', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Ar Condicionado', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Embuchamento', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Precisa Limpeza do Filtro de Ar', 'Nao', 'Sim');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Correia do Motor', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Farois', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (1, 'Buzina', 'Ok', 'Danificado');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Oleo Hidraulico', 'No Nivel', 'Abaixo do Nivel');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Liquido de Arrefecimento', 'No Nivel', 'Abaixo do Nivel');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Oleo do Motor', 'No Nivel', 'Abaixo do Nivel');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Vazamento', 'Nao', 'Sim');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Oleo da Transmissao', 'No Nivel', 'Abaixo do Nivel');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Fluido de Freio', 'No Nivel', 'Abaixo do Nivel');

INSERT INTO frt_tipo_inspecao_itens (id_tipo_inspecao, nome_item, descricao_positivo, descricao_negativo)
VALUES (2, 'Drenar Agua do Tanque Combustivel', 'Nao', 'Sim');

----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS frt_operacao_diaria_inspecao;
----------------------------------------------------------------------------------------------------
CREATE TABLE frt_operacao_diaria_inspecao
(
	id_operacao_diaria_inspecao serial NOT NULL,
	id_operacao_diaria integer,
	id_tipo_inspecao_item integer,
	valor_positivo integer,
	valor_negativo integer,	
	CONSTRAINT frt_operacao_diaria_inspecao_id_pk PRIMARY KEY (id_operacao_diaria_inspecao),
	CONSTRAINT frt_operacao_diaria_inspecao_id_operacao_diaria_fk FOREIGN KEY (id_operacao_diaria)
		REFERENCES frt_operacao_diaria (id_operacao_diaria) MATCH SIMPLE
			ON UPDATE CASCADE ON DELETE CASCADE,		
	CONSTRAINT frt_operacao_diaria_inspecao_id_tipo_inspecao_item_fk FOREIGN KEY (id_tipo_inspecao_item)
		REFERENCES frt_tipo_inspecao_itens (id_tipo_inspecao_item) MATCH SIMPLE
			ON UPDATE RESTRICT ON DELETE RESTRICT	
);

COMMENT ON COLUMN frt_operacao_diaria_inspecao.id_operacao_diaria_inspecao
		IS 'Chave Primaria';
COMMENT ON COLUMN frt_operacao_diaria_inspecao.id_operacao_diaria
		IS 'Chave Estrangeira da Operacao Diaria';
COMMENT ON COLUMN frt_operacao_diaria_inspecao.id_tipo_inspecao_item
		IS 'Tipo do Item Inspecionado';
COMMENT ON COLUMN frt_operacao_diaria_inspecao.valor_positivo
		IS 'Valor em caso positivo (0 ou 1)';
COMMENT ON COLUMN frt_operacao_diaria_inspecao.valor_negativo
		IS 'Valor em caso negativo (0 ou 1)';

----------------------------------------------------------------------------------------------------
-- EndScript
----------------------------------------------------------------------------------------------------
