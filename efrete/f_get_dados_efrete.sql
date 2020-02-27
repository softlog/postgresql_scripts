--SELECT EXTRACT(EPOCH FROM current_date) as data_nascimento_motorista
--select date_part('epoch', '1956-04-07 00:00:00'::timestamp) --from data;
WITH t AS (
	SELECT 
		m.id_manifesto,
		m.numero_manifesto,
		mot.nascimento,
		trim(mot.cnpj_cpf) as cpf_motorista,
		trim(mot.nome_razao) as nome_motorista,
		trim(mot.mot_registro) as cnh_motorista,		
		trim(mot.mae) as mae_motorista,
		trim(mot.bairro) as bairro_motorista,
		trim(mot.endereco) as rua_motorista,
		''::text as complemento_motorista,
		trim(COALESCE(mot.numero,'0')) as numero_motorista,
		EXTRACT(EPOCH FROM mot.nascimento) as data_nascimento_motorista,
		62::integer as ddd_motorista,
		'981671973'::text as telefone_motorista,
		trim(mot.cep) as cep_motorista,
		cm.cod_ibge as codigo_municipio_motorista, 
		trim(prop.cnpj_cpf) as cnpj_cpf_proprietario,
		CASE WHEN char_length(trim(prop.cnpj_cpf)) = 11 THEN 'Fisica' ELSE 'Juridica' END::text as tipo_pessoa_proprietario,
		trim(prop.nome_razao) as nome_proprietario,
		trim(prop.mot_registro) as cnh_proprietario,
		prop.nascimento as data_nasimento_proprietario,
		trim(prop.mae) as mae_proprietario,
		trim(prop.bairro) as bairro_proprietario,
		trim(prop.endereco) as rua_proprietario,
		''::text as complemento_proprietario,
		trim(COALESCE(prop.numero,'0')) as numero_proprietario,
		EXTRACT(EPOCH FROM prop.nascimento) as data_nascimento_proprietario,
		62::integer as ddd_proprietario,
		'981671973'::text as telefone_proprietario,
		trim(prop.cep) as cep_proprietario,
		cp.cod_ibge as codigo_municipio_motorista,
		'TAC'::text as tipo_tranportador,
		m.placa_veiculo,
		CASE WHEN m.placas_engates IS NOT NULL THEN m.placa_veiculo || ',' || placas_engates ELSE m.placa_veiculo END as placas
	FROM 
		scr_manifesto m
		LEFT JOIN fornecedores mot
			ON mot.id_fornecedor = m.id_motorista
		LEFT JOIN cidades cm
			ON cm.id_cidade = mot.id_cidade
		LEFT JOIN fornecedores prop
			ON prop.cnpj_cpf = m.cnpj_cpf_proprietario
		LEFT JOIN cidades cp
			ON cp.id_cidade = prop.id_cidade	
	WHERE 
		id_manifesto = 8403
)
, t1 AS (
	SELECT 
		t.id_manifesto,
		unnest(string_to_array(placas,',')) as placa_veiculo
	FROM   
		t
	
) 
,veiculos AS (
	SELECT 
		t1.id_manifesto,
		v.placa_veiculo,
		v.rntrc as rntrc,
		v.validade_rntrc,
		v.ano_fabricacao_veiculo::integer as ano_fabricacao,
		v.ano_modelo_veiculo as ano_modelo,
		v.capacidade_tonelada as capacidade_kg,
		v.capacidade_cubica as capacidade_m3,
		trim(v.nrchassis) as chassi,
		cv.cod_ibge as codigo_municipio_veiculo,
		trim(v.cor_veiculo) as cor,
		trim(vm.nome_marca) as marca,
		trim(vmod.descricao_modelo) as modelo,
		v.numero_eixos::integer as numero_de_eixos,
		trim(v.renavan) as renavam,
		v.veic_tara as tara,
		CASE 
			WHEN v.tp_carroceria IN (1,5,6,10) THEN 'Aberta'
			WHEN v.tp_carroceria IN (2) THEN 'Granelera'
			WHEN v.tp_carroceria IN (3, 4, 7, 8, 9) THEN 'FechadaOuBau'
			WHEN v.tp_carroceria IN (4) THEN 'FechadaOuBau'
			WHEN v.tp_carroceria IN (11, 12, 13, 14, 15) THEN 'NaoAplicavel'
		END::text as tipo_carroceria,

		CASE 
			WHEN v.tracionado = 1 THEN 'Cavalo'			
			WHEN v.porte IN (7)   THEN 'Toco'
			WHEN v.porte IN (8)   THEN 'Truck'
					      ELSE 'NaoAplicavel'
		END::text as TipoRodado			
	FROM 
		t1
		LEFT JOIN veiculos v
			ON trim(v.placa_veiculo) = trim(t1.placa_veiculo)
		LEFT JOIN cidades cv
			ON cv.id_cidade = v.id_cidade_veiculo
		LEFT JOIN veiculos_marcas vm
			ON vm.id_marca_veiculo = v.id_marca
		LEFT JOIN veiculos_modelos vmod
			ON vmod.id_modelo_veiculo = v.id_modelo
		LEFT JOIN v_tipo_carroceria vtc
			ON vtc.codigo = v.tp_carroceria
		LEFT JOIN v_porte_veiculo vpv 
			ON vpv.codigo = v.porte
)





/*

SELECT * FROM scr_manifesto LIMIT 1;
SELECT * FROM fd_dados_tabela('veiculos') ORDER BY campo;
SELECT * FROM fd_dados_tabela('veiculos') WHERE campo like '%proprietario%';
SELECT * FROM fd_dados_tabela('scr_romaneios') WHERE campo like '%engate%';

SELECT id_tipo_frota, tipo_frota FROM v_tipo_frota ORDER BY id_tipo_frota

SELECT scr_manifesto.* 
FROM 
	scr_manifesto 
	LEFT JOIN veiculos
		ON veiculos.placa_veiculo = scr_manifesto.placa_veiculo
WHERE placas_engates like '%,%' AND veiculos.tipo_frota IN (2,3) ORDER BY 1 DESC LIMIT 100


SELECT * FROM veiculos_marcas
SELECT * FROM veiculos_modelos LIMIT 1

SELECT * FROM v_tipo_carroceria

SELECT * FROM v_porte_veiculo
*/



-- SELECT * FROM veiculos WHERE placa_veiculo = 'AMF6956'
-- SELECT * FROM fornecedores WHERE id_fornecedor = 6657
-- SELECT * FROM scr_romaneios WHERE id_romaneio = 59369
-- SELECT to_timestamp(EXTRACT(EPOCH FROM now()));