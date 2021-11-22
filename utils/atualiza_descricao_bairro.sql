--SELECT converte_caracteres_especiais(bairro), * FROM qualocep_bairro WHERE id_cidade = 9668

UPDATE qualocep_bairro SET bairro = UPPER(converte_caracteres_especiais(bairro));
UPDATE qualocep_bairro SET bairro = retira_acento(bairro);
UPDATE qualocep_bairro SET bairro = replace(bairro,'''',' ');
UPDATE qualocep_bairro SET bairro = fpy_limpa_caracteres(bairro);


UPDATE qualocep_cidade SET cidade = UPPER(converte_caracteres_especiais(cidade));
UPDATE qualocep_cidade SET cidade = retira_acento(cidade);
UPDATE qualocep_cidade SET cidade = replace(cidade,'''',' ');
UPDATE qualocep_cidade SET cidade = fpy_limpa_caracteres(cidade);

UPDATE v_bairros_cep SET bairro = UPPER(converte_caracteres_especiais(bairro));
UPDATE v_bairros_cep SET bairro = retira_acento(bairro);
UPDATE v_bairros_cep SET bairro = replace(bairro,'''',' ');
UPDATE v_bairros_cep SET bairro = fpy_limpa_caracteres(bairro);

--SELECT * FROM qualocep_cidade WHERE cidade like '%SAO PAULO%'