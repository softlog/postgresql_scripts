CREATE OR REPLACE VIEW v_tipo_alerta AS 
SELECT 'DOC. MOTORISTA'::character(25) AS tipo_alerta
UNION 
SELECT 'DOC. VEICULO'::character(25) AS tipo_alerta
UNION 
SELECT 'MANUTENCAO'::character(25) AS tipo_alerta;



