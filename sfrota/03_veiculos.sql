ALTER TABLE veiculos ADD COLUMN id_filial integer

UPDATE veiculos SET chk_hr = 1, chk_km = 0 WHERE placa_veiculo IN (
'TTT-3188','TTT-3187','TTT-3186'
)
/*

TRUNCATE filial_sub

INSERT INTO filial_sub (id_filial, codigo_filial_sub, nome_descritivo)
VALUES (1,'001','CURRAL 001');

INSERT INTO filial_sub (id_filial, codigo_filial_sub, nome_descritivo)
VALUES (1,'002','CURRAL 002');

INSERT INTO filial_sub (id_filial, codigo_filial_sub, nome_descritivo)
VALUES (1,'003','CURRAL 003');



*/


--SELECT * FROM filial