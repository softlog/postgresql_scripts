-- Function: public.f_get_dados_romaneio_json(integer, text)
-- SELECT * FROM f_get_dados_romaneio_json(35545,'06234797000178,06234797000178,06073848000127,06234797000178,06234797000178,06073848000127,00904728000490')
-- DROP FUNCTION public.f_get_dados_romaneio_json(integer, text);35545
/*

	SELECT f_get_dados_romaneio_krona(40738, '', '') 

	SELECT id_veiculo, * FROM veiculos WHERE placa_veiculo = 'PYM4170'
	
	
	

	SELECT * FROM scr_romaneios WHERE placa_veiculo = 'PYM4170' ORDER BY 1 DESC LIMIT 10;

	SELECT nome_razao FROM fornecedores WHERE cnpj_cpf = '81526172704'

	PST_INTEGRACAO_KRONA

	INSERT INTO parametros (cod_empresa, codigo_modulo, cod_parametro, valor_parametro, tipo_parametro)
	VALUES ('001', 'ST_RODOVIA', 'pST_integracao_krona', '1', 'N');


	--DELETE FROM fila_documentos_integracoes WHERE tipo_integracao = 11
DELETE FROM fila_documentos_integracoes WHERE tipo_integracao = 11
	INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, lst_documentos, id_romaneio, data_registro)
	VALUES (11, 2, NULL, 42168, now());

	INSERT INTO fila_documentos_integracoes (tipo_integracao, tipo_documento, lst_documentos, id_romaneio, data_registro)
	VALUES (11, 2, NULL, 42375, now());

	SELECT
            id,
            f_get_dados_romaneio_krona(id_romaneio, '%(usuario)s', '%(senha)s') as dados,
            id_romaneio
        FROM
            fila_documentos_integracoes
            fila_documentos_integracoes
        WHERE
            enviado = 0
            AND pendencia = 0
            AND tipo_integracao = 11
            AND qt_tentativas < 4
        ORDER BY
            1


SELECT
            id,
            f_get_dados_romaneio_krona(id_romaneio, '%(usuario)s', '%(password)s') as dados,
            id_romaneio,
            *
        FROM
            fila_documentos_integracoes
        WHERE
            enviado = 0
            AND pendencia = 0
            AND tipo_integracao = 11
            AND qt_tentativas < 4
        ORDER BY
            1

            SELECT * FROM 

                                        mensagens = '%s',


                                        mensagens = '%s',

	
*/

CREATE OR REPLACE FUNCTION public.f_get_dados_romaneio_krona(p_id_romaneio integer, p_usuario text, p_senha text)
  RETURNS text AS
$BODY$
DECLARE
	v_resultado text;
BEGIN
	WITH 
	
	rom AS (
			
		SELECT 
			r.id_romaneio,
			p_usuario as usuario,
			p_senha as senha,
			--Transportadora
			'TRANSPORTADOR'::text as tipo_filial,
			id_remetente_origem,
			trim(f.cnpj) as cnpj,
			trim(f.razao_social) as razao_social,
			trim(f.nome_descritivo) as nome_fantasia,
			trim(fc.nome_cidade) as unidade,			
			trim(f.endereco) as filial_rua,
			trim(f.numero) as filial_numero,						
			trim(f.bairro) as filial_bairro,
			trim(fc.nome_cidade) as filial_cidade,
			trim(fc.uf) as filial_uf,
			trim(f.cep) as filial_cep,
			trim(f.telefone) as filial_fone1,

			--Origem
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN 'TRANSPORTADOR' ELSE 'OUTROS' END::text as tipo_origem,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.cnpj) ELSE trim(rem.cnpj_cpf) END::text as origem_cnpj,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.razao_social) ELSE trim(rem.nome_cliente) END::text as origem_razao_social,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.nome_descritivo) ELSE trim(rem.nome_fantasia) END::text as origem_nome_fantasia,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(fc.nome_cidade) ELSE trim(rc.nome_cidade) END::text as origem_unidade,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(fc.uf) ELSE trim(rc.uf) END::text as origem_uf,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.endereco) ELSE trim(rem.endereco) END::text as origem_rua,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.numero) ELSE trim(COALESCE(rem.numero,'0')) END::text as origem_numero,			
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.bairro) ELSE trim(rem.bairro) END::text as origem_bairro,
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(fc.nome_cidade) ELSE trim(rc.nome_cidade) END::text as origem_cidade,			
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.cep) ELSE trim(rem.cep) END::text as origem_cep,			
			CASE WHEN r.id_remetente_origem IS NULL OR  r.id_remetente_origem = 0 THEN trim(f.telefone) ELSE trim(rem.telefone) END::text as origem_telefone1,

			
			--Motorista
			trim(mot.cnpj_cpf) as mot_cpf,
			trim(mot.nome_razao) as mot_nome,
			trim(mot.identidade) as mot_rg,
			trim(mot.orgao_expedidor) as mot_orgao_expedidor,			
			trim(mot.mot_registro) as mot_cnh,	
			--trim(mot.mot_validade) as mot_cnh_vencimento,
			trim(mot.mot_categoria) as mot_cnh_categoria,			
			trim(mot.bairro) as mot_bairro,
			trim(mot.endereco) as mot_rua,
			trim(COALESCE(mot.numero,'0')) as mot_numero,
			mot.nascimento as mot_nascimento,			
			mot.celular_ciot as mot_celular,
			trim(mot.cep) as mot_cep,
			(cm.nome_cidade)::text as mot_cidade,
			cm.uf as mot_uf,

			CASE 
				WHEN r.tipo_frota = 1 THEN 'FROTA' 
				WHEN r.tipo_frota = 2 THEN 'AGREGADO'
				WHEN r.tipo_frota = 3 THEN 'CARRETEIRO'
			END::text as mot_vinculo,

			--Veiculo
			(LEFT(trim(r.placa_veiculo),3) || '-' || RIGHT(trim(r.placa_veiculo),4))::text  as placa_veiculo,
			
			CASE WHEN trim(vt.nome_marca) NOT IN ('AGRALE', 'CHRYSLER', 'CITROEN', 'FNM', 
							      'FORD', 'GM','CHEVROLET', 'HIUNDAI', 
							      'HONDA', 'HYUNDAI', 'INTERNATIONAL', 
							      'IVECO', 'FIAT', 'KIA', 'MERCEDES BENZ', 
							      'MITSUBISHI', 'PEUGEOT', 'RENAULT', 'SCANIA', 
							      'SINOTRUK', 'TOYOTA', 'VOLVO', 'VW')
			     THEN 'OUTROS' 
			     ELSE trim(vt.nome_marca)
			END::text as marca,
			
			trim(COALESCE(vt.descricao_modelo,'')) as modelo,

			 
			CASE 
				WHEN trim(cor_veiculo) = 'BRANCO' THEN 'BRANCA'
				WHEN trim(cor_veiculo) = 'PRETO' THEN 'PRETA'
				WHEN trim(cor_veiculo) = 'AMARELO' THEN 'OUTROS' 
				WHEN trim(cor_veiculo) = 'AZUL' THEN 'AZUL'
				WHEN trim(cor_veiculo) = 'VERMELHO' THEN 'VERMELHA'
				WHEN trim(cor_veiculo) = 'VERDE' THEN 'VERDE'
				WHEN trim(cor_veiculo) = 'LARANJA' THEN 'LARANJA'
				WHEN trim(cor_veiculo) = 'ROXO' THEN 'ROXA'
				WHEN trim(cor_veiculo) = 'CINZA' THEN 'CINZA'
				WHEN trim(cor_veiculo) = 'PRATA' THEN 'PRATA'
				WHEN trim(cor_veiculo) = 'MARROM' THEN 'MARROM'
				WHEN trim(cor_veiculo) = 'ROSA' THEN 'ROSA'
				ELSE 'OUTROS'
			END::text as cor,			
			v.ano_modelo_veiculo as ano,
			--Criar rotina para retornar Tipo,
			'OUTROS'::text as tipo,
			trim(v.rntrc) as antt,
			trim(v.renavan) as renavan,
			v.validade_rntrc::text as validade_antt,
			trim(prop.cnpj_cpf) as prop_cnpj_cpf,
			trim(prop.nome_razao) as proprietario,			
			trim(prop.bairro) as prop_bairro,
			trim(prop.endereco) as prop_rua,
			trim(COALESCE(prop.numero,'0')) as prop_numero,						
			prop.celular_ciot as prop_celular,
			trim(prop.cep) as prop_cep,
			(pc.nome_cidade)::text as prop_cidade,
			pc.uf as prop_uf,
			--Criar rotina para retornar tecnologia
			f_retorna_parametro_veiculo(r.placa_veiculo, 3)::text as tecnologia,			
			--Criar coluna id_rastreador
			f_retorna_parametro_veiculo(r.placa_veiculo, 1)::text as id_rastreador,
			--Criar coluna comunicacao 
			f_retorna_parametro_veiculo(r.placa_veiculo, 2) as comunicacao,			
			f_retorna_parametro_veiculo(r.placa_veiculo, 6)::text as tecnologia_sec,						
			f_retorna_parametro_veiculo(r.placa_veiculo, 4)::text as id_rastreador_sec,			
			f_retorna_parametro_veiculo(r.placa_veiculo, 5) as comunicacao_sec,
			'S'::text as rastreada,			
			--Verificar que significa
			'S'::text as fixo,

			--VIAGEM
			CASE WHEN r.tipo_destino = 'D' THEN 'ENTREGA' ELSE 'TRANSFERÊNCIA' END::text as tipo_viagem,			
			CASE WHEN r.tipo_destino = 'D' THEN 'URBANO' ELSE 'RODOVIÁRIO' END::text as percurso,	
			CASE WHEN r.tipo_destino = 'D' THEN 'OUTROS' ELSE 'TRANSPORTADOR' END::text as tipo_cliente,				
			--r.total_nf::text as valor,
			to_char(r.data_saida,'YYYY-MM-DD HH24:MI:SS') as inicio_previsto,
			to_char(r.data_saida + INTERVAL'1 DAY','YYYY-MM-DD HH24:MI:SS') as fim_previsto,			
			--Parametrizar
			COALESCE(conf.valor_parametro,'LIBERADO')::text as liberacao,
			'13 OUTRAS NÃO RELACIONADAS'::text as mercadoria_id			
			--SELECT * FROM scr_natureza_carga ORDER BY 1


			
		FROM 
			scr_romaneios r
			LEFT JOIN fornecedores mot ON r.id_motorista = mot.id_fornecedor
			LEFT JOIN cidades cm
				ON cm.id_cidade = mot.id_cidade									
			LEFT JOIN fornecedor_parametros conf 
				ON conf.id_fornecedor = mot.id_fornecedor AND conf.id_tipo_parametro = 12
			LEFT JOIN filial f ON r.cod_empresa = f.codigo_empresa AND r.cod_filial = f.codigo_filial
			LEFT JOIN cidades fc ON f.id_cidade = fc.id_cidade		
			LEFT JOIN cliente rem ON rem.codigo_cliente = r.id_remetente_origem
			LEFT JOIN cidades rc ON rc.id_cidade = rem.id_cidade
			
			LEFT JOIN veiculos v
				ON r.placa_veiculo = v.placa_veiculo
			LEFT JOIN v_veic_tipo vt
				ON vt.id_tipo_veiculo = v.id_tipo_veiculo	
			
			LEFT JOIN fornecedores prop
				ON prop.id_fornecedor = v.id_proprietario
			LEFT JOIN cidades pc
				ON pc.id_cidade = prop.id_cidade
			
		WHERE 
			r.tipo_romaneio = 1 
			--AND r.tipo_destino = 'D'
			--AND r.numero_romaneio IS NOT NULL
			AND r.id_romaneio = p_id_romaneio
			--AND r.id_romaneio = 42375
			--SELECT id_romaneio FROM scr_romaneios WHERE numero_romaneio = '0010010025246'	

	)
	, destinos_temp AS (
		SELECT 
			rnf.id_romaneio,
			row_number(*) over (partition by 1) as sequencia,						
			'OUTROS'::text as tipo,
			trim(dest.cnpj_cpf) as cnpj,
			trim(dest.nome_cliente) as razao_social,
			trim(dest.nome_fantasia) as nome_fantasia,
			trim(cd.nome_cidade) as unidade,
			trim(dest.endereco) as rua,
			trim(COALESCE(dest.numero,'0'))::text as numero,
			trim(dest.bairro) as bairro,
			trim(dest.cep) as cep,
			trim(cd.nome_cidade) as cidade,
			cd.uf as uf,
			trim(dest.telefone) as telefone1
		FROM
			scr_romaneio_nf rnf
			LEFT JOIN scr_notas_fiscais_imp nf
				ON nf.id_nota_fiscal_imp = rnf.id_nota_fiscal_imp
			LEFT JOIN cliente dest 
				ON dest.codigo_cliente = nf.destinatario_id
			LEFT JOIN cidades cd
				ON cd.id_cidade = dest.id_cidade
		WHERE 
			1=1
			AND rnf.id_romaneio = p_id_romaneio
			--AND rnf.id_romaneio = 35545
		GROUP BY
			rnf.id_romaneio,
			dest.codigo_cliente,
			cd.id_cidade
		ORDER BY cidade
		
	)	
	, valores AS (
		
		SELECT 	
			scr_romaneio_nf.id_romaneio,
			SUM(valor)::text as valor
		FROM
			scr_romaneio_nf 
			LEFT JOIN scr_notas_fiscais_imp
				ON scr_romaneio_nf.id_nota_fiscal_imp = scr_notas_fiscais_imp.id_nota_fiscal_imp		
		WHERE
			scr_romaneio_nf.id_romaneio = p_id_romaneio
		GROUP BY
			scr_romaneio_nf.id_romaneio

	)
	, rotas_temp AS (
		SELECT (cidade || '-' || uf)::text as unidade FROM destinos_temp GROUP BY (cidade || '-' || uf)::text

	)
	, rotas as (
		SELECT 
			id_romaneio,
			((rom.origem_cidade || '-' || rom.origem_uf) || ',' || string_agg(rotas_temp.unidade,',')) as rota 
		FROM 
			rom, rotas_temp 
		GROUP BY 
			rom.id_romaneio, rom.origem_cidade, rom.origem_uf
	)
	, destinos AS (		
			WITH temp AS (
				SELECT (row_to_json(row,true))::json as json, id_romaneio FROM (
					SELECT 
						*
					FROM
						destinos_temp
					ORDER BY
						sequencia
				) row
			)
			SELECT id_romaneio, array_agg(json) as destinos FROM temp GROUP BY id_romaneio
	)
	SELECT (row_to_json(row,true))::json as json
	INTO v_resultado
	FROM (
		SELECT 
			rom.*,
			valores.valor,
			rotas.rota,
			destinos.destinos
		FROM 
			rom
			LEFT JOIN valores
				ON valores.id_romaneio = rom.id_romaneio
			LEFT JOIN rotas
				ON rotas.id_romaneio = rom.id_romaneio
			LEFT JOIN destinos
				ON destinos.id_romaneio = rom.id_romaneio
	) row;
	


	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

