ALTER TABLE scr_ciot ADD COLUMN motivo_cancelamento character(100);
ALTER TABLE scr_ciot ADD COLUMN cancelado integer DEFAULT 0;
ALTER TABLE scr_ciot ADD COLUMN protocolo_cancelamento character(100);

ALTER TABLE scr_ciot ADD COLUMN valor_quitacao numeric(12,2);
ALTER TABLE scr_ciot ADD COLUMN valor_irrf numeric(12,2);
ALTER TABLE scr_ciot ADD COLUMN valor_inss numeric(12,2);
ALTER TABLE scr_ciot ADD COLUMN valor_iss numeric(12,2);
ALTER TABLE scr_ciot ADD COLUMN valor_sest_senat numeric(12,2);
ALTER TABLE scr_ciot ADD COLUMN protocolo_encerramento character(100);

ALTER TABLE scr_ciot ADD COLUMN inicio_contrato date DEFAULT current_date;
ALTER TABLE scr_ciot ADD COLUMN fim_contrato date;

ALTER TABLE scr_ciot ADD COLUMN id_cidade_origem integer;
ALTER TABLE scr_ciot ADD COLUMN id_cidade_destino integer;


--SELECT * FROM scr_ciot


--SELECT scr_ciot.id_ciot, 'Manifesto'::character(10) as origem_d, scr_ciot.numero_ciot, scr_ciot.origem, scr_ciot.data_abertura, scr_ciot.data_encerramento, scr_ciot.data_cancelamento, scr_ciot.status_ciot, scr_ciot.id_manifesto, scr_ciot.id_romaneio, scr_ciot.recolhe_inss, scr_ciot.base_calculo_mes, scr_ciot.id_motorista, scr_ciot.id_proprietario, mot.nome_razao as motorista, prop.nome_razao as proprietario, m.numero_manifesto, scr_ciot.placa_veiculo, frete_pago_terceiro, frete_adiantamento_terceiro, CASE WHEN scr_ciot.id_cidade_origem = scr_ciot.id_cidade_destino THEN 1 ELSE 0 END::integer as op_municipal, scr_ciot.data_abertura::date as data_ref, scr_ciot.inicio_contrato, scr_ciot.fim_contrato, scr_ciot.id_cidade_origem, scr_ciot.id_cidade_destino, scr_ciot.valor_quitacao, scr_ciot.valor_irrf, scr_ciot.valor_inss, scr_ciot.valor_iss, scr_ciot.valor_sest_senat, scr_ciot.protocolo_cancelamento, scr_ciot.cancelado, scr_ciot.motivo_cancelamento, scr_ciot.protocolo_encerramento, scr_ciot.viagem_padrao FROM scr_ciot  LEFT JOIN scr_manifesto m ON m.id_manifesto = scr_ciot.id_manifesto   LEFT JOIN fornecedores mot ON mot.id_fornecedor = scr_ciot.id_motorista LEFT JOIN fornecedores prop ON prop.id_fornecedor = scr_ciot.id_proprietario WHERE 1=2 