
ALTER TABLE tb_check ADD COLUMN dc_positivo character(20);
ALTER TABLE tb_check ADD COLUMN dc_negativo character(20);
ALTER TABLE tb_check ADD COLUMN tem_obs  integer DEFAULT 0;
ALTER TABLE tb_check ADD COLUMN id_tipo_inspecao integer REFERENCES frt_tipo_inspecao(id_tipo_inspecao);


COMMENT ON COLUMN tb_check.dc_positivo
		IS 'Descricao da Avaliacao Positiva';
COMMENT ON COLUMN tb_check.dc_negativo
		IS 'Descricao da Avaliacao Negativa';
COMMENT ON COLUMN tb_check.tem_obs
		IS 'Indicativo de observacao: 0 - Nao tem, 1 - Tem';

COMMENT ON COLUMN tb_check.id_tipo_inspecao
	IS 'Chave Estrangeira Para relacionar com a tabela frt_tipo_inspecao';