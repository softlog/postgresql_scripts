--SELECT * FROM scr_tabelas_tipo_calculo ORDER BY 1 ASC

INSERT INTO scr_tabelas_tipo_calculo (id_tipo_calculo, descricao, dividir_por, ativo)
VALUES (82, 'Pedágio/Fração Interior', 1, 1);

INSERT INTO scr_tabelas_tipo_calculo (id_tipo_calculo, descricao, dividir_por, ativo)
VALUES (83, 'Pedágio/Fração Satélite', 1, 1);

--DELETE FROM scr_tabelas_tipo_calculo WHERE id_tipo_calculo = 85
INSERT INTO scr_tabelas_tipo_calculo (id_tipo_calculo, descricao, dividir_por, ativo)
VALUES (96, 'Taxa Entrega Area de Risco', 100, 1);

--SELECT * FROM scr_tabelas_tipo_calculo ORDER BY 1