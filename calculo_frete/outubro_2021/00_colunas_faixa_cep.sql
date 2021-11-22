ALTER TABLE scr_tabelas_origem_destino ADD COLUMN faixa_cep_ini integer;
ALTER TABLE scr_tabelas_origem_destino ADD COLUMN faixa_cep_fim integer;
ALTER TABLE scr_tabelas_origem_destino ADD COLUMN usa_faixa_cep integer DEFAULT 0;


ALTER TABLE regiao_cidades ADD COLUMN faixa_cep_ini integer;
ALTER TABLE regiao_cidades ADD COLUMN faixa_cep_fim integer;
ALTER TABLE regiao ADD COLUMN usa_faixa_cep integer DEFAULT 0;
ALTER TABLE scr_tabelas ADD COLUMN usa_faixa_cep integer DEFAULT 0; 


