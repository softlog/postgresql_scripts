
CREATE OR REPLACE FUNCTION f_tgg_ab_km_rodados()
  RETURNS trigger AS
$BODY$
DECLARE
	vResultado	t_ab_km_veiculo_pneus%rowtype;	
	vCmd 		text;
BEGIN
	/*
	****************************************************************************************************
	* Metodo para atualizar km rodados dos engates e dos pneus
	****************************************************************************************************

	Dado um abastecimento, pegar:
		- Placa do veiculo (ab_placa)
		- Data do Abastecimento (ab_data)
		- KM do veiculo (ab_km)
		- HR do veiculo (ab_hr)
		- Km Rodados (ab_km_rodados)
		- Hr Rodados (ab_hr_trabalhadas)

	Verificar a data do abastecimento anterior
	Com a data anterior e a data atual, verificar se houve mudanca de
	atrelamento durante o período.

	Se não houve mudanca, 
		- Atualizar:
			Odometro do veiculo tração
			
		- Acrescentar 
			KM/HR rodados nos odometros do(s) veiculo(s) atrelados
			KM/HR rodados nos pneus do veiculo tração
			KM/HR rodados nos pneus do(s) veiculo(s) atrelados

	Se houve mudança,
		- Atualizar:
			Odometro do veiculo tração
			
		- Acrescentar 
			KM/HR rodados nos pneus do veiculo tração
	*/
	

	/*Quando o Abastecimento Entrar no Sistema*/
	IF TG_OP = 'INSERT' THEN 

		/*
		****************************************************************************************************
		* Trazer os engates e as avaliações de cenários.
		****************************************************************************************************
		*/
		WITH    cur_odo_atual AS (
			-- Traz odometro e horimetro atuais da placa tracao e odometro/horimetro do historico
			SELECT  v.placa_veiculo,
				v.tracionado,
				v.odometro_atual::INTEGER AS odometro_atual,
				v.horimetro_atual::NUMERIC(9,1) AS horimetro_atual,
				MAX(COALESCE(k.veic_km,0))::INTEGER as veic_km,
				MAX(COALESCE(k.veic_hr,0.0))::NUMERIC(10,1) AS veic_hr,
				COUNT(1)::INTEGER AS tot_reg_km 
			FROM    veiculos v
				LEFT JOIN frt_veic_km k USING(placa_veiculo)
			GROUP BY v.placa_veiculo,v.tracionado
			ORDER BY v.placa_veiculo
		)
		,cur_ab_ant AS (
			-- Traz a data do abastecimento anterior
			SELECT  ab_data 
			FROM    frt_ab 
			WHERE 	ab_placa = NEW.ab_placa 
			AND     ab_data::timestamp without time zone <  NEW.ab_data::timestamp without time zone 
			--WHERE   ab_placa = 'OOC5689' 
			--AND     ab_data::timestamp without time zone <  '2021-06-13 14:21:27'::timestamp without time zone 		
			ORDER BY ab_data DESC 
			LIMIT 1
		)
		,cur_mov_atual AS (
			-- Identifica o movimento de engate anterior mais proximo da 
			-- data do abastecimento atual
			-- e resgata o odometro
			SELECT  max(frt_mov_eng_deseng.id_mov) AS id_mov,
				frt_mov_eng_deseng.data_mov,  
				frt_mov_eng_deseng.placa_veiculo_tracao AS placa_tracao,
				frt_mov_eng_deseng.odometro_veic_tracao,
				frt_mov_eng_deseng.horimetro_veic_tracao
			FROM    frt_mov_eng_deseng
			WHERE   placa_veiculo_tracao = NEW.ab_placa		
				AND     data_mov::timestamp without time zone <= NEW.ab_data::timestamp without time zone -- data abastecimento atual		
			--WHERE   placa_veiculo_tracao = 'OOC5689' 
			--AND     data_mov::timestamp without time zone <= '2021-06-13 14:21:27'::timestamp without time zone 

			GROUP BY frt_mov_eng_deseng.data_mov,
				 frt_mov_eng_deseng.placa_veiculo_tracao, 
				 frt_mov_eng_deseng.odometro_veic_tracao,
				 frt_mov_eng_deseng.horimetro_veic_tracao
			ORDER BY 1 desc
			LIMIT 1
		)

		,cur_mov_anterior AS (
			-- Identifica o movimento de engate anterior mais proximo da 
			-- data do abastecimento anterior
			-- e resgata o odometro
			SELECT  max(frt_mov_eng_deseng.id_mov) AS id_mov,
				frt_mov_eng_deseng.data_mov,  
				frt_mov_eng_deseng.placa_veiculo_tracao AS placa_tracao,
				frt_mov_eng_deseng.odometro_veic_tracao,
				frt_mov_eng_deseng.horimetro_veic_tracao
			FROM    frt_mov_eng_deseng
				LEFT JOIN cur_ab_ant ON TRUE
			WHERE   placa_veiculo_tracao = NEW.ab_placa
			--WHERE   placa_veiculo_tracao = 'OOC5689'
			
			AND 	data_mov IS NOT NULL 
			AND     CASE WHEN cur_ab_ant.ab_data IS NOT NULL
				     THEN data_mov::timestamp without time zone <= cur_ab_ant.ab_data::timestamp without time zone
				     ELSE TRUE
				     END -- data abastecimento anterior
			GROUP BY frt_mov_eng_deseng.data_mov,
				 frt_mov_eng_deseng.placa_veiculo_tracao, 
				 frt_mov_eng_deseng.odometro_veic_tracao,
				 frt_mov_eng_deseng.horimetro_veic_tracao
			ORDER BY 1 desc
			LIMIT 1
		)
		,cur_ult_mov AS (
		-- Avalia o que deve ser atualizado (km ou hr) de pneus e engates
			SELECT  a.data_mov,
				a.odometro_veic_tracao  AS odo_atual,
				a.horimetro_veic_tracao AS hor_atual,
				b.odometro_veic_tracao  AS odo_anterior,
				b.horimetro_veic_tracao AS hor_anterior,
				CASE WHEN COALESCE(a.odometro_veic_tracao,0) = 
					  COALESCE(b.odometro_veic_tracao,0) 
				     -- Se odo_atual = odo_anterior, nao houve alteracao de 
				     -- engates de reboques durante os dois abastecimentos.
				     -- Entao os km rodados devem ser aplicados nos engates 
				     -- e pneus do tracao e dos engates
				     THEN 1
				     WHEN COALESCE(a.odometro_veic_tracao,0) > 
					  COALESCE(b.odometro_veic_tracao,0) 
				     -- Se odo_atual > odo_anterior, houve alteracao de 
				     -- engates de reboques durante os dois abastecimentos.
				     -- Entao os km rodados devem ser aplicados apenas
				     -- nos pneus do tracao
				     THEN 2
				     -- Em caso de Zero, as datas dos abastecimentos estao 
				     -- inconsistentes. Entao os km rodados nao devem ser aplicados
				     ELSE 0
				     END::INTEGER AS situacao_km,
				     
				CASE WHEN COALESCE(a.horimetro_veic_tracao,0) = 
					  COALESCE(b.horimetro_veic_tracao,0) 
				     -- Se odo_atual = odo_anterior, nao houve alteracao de 
				     -- engates de reboques durante os dois abastecimentos.
				     -- Entao os km rodados devem ser aplicados nos engates 
				     -- e pneus do tracao e dos engates
				     THEN 1
				     WHEN COALESCE(a.horimetro_veic_tracao,0) > 
					  COALESCE(b.horimetro_veic_tracao,0) 
				     -- Se odo_atual > odo_anterior, houve alteracao de 
				     -- engates de reboques durante os dois abastecimentos.
				     -- Entao os km rodados devem ser aplicados apenas
				     -- nos pneus do tracao
				     THEN 2
				     -- Em caso de Zero, as datas dos abastecimentos estao 
				     -- inconsistentes. Entao os km rodados nao devem ser aplicados
				     ELSE 0
				     END::INTEGER AS situacao_hr

			FROM    cur_mov_atual a
				LEFT JOIN cur_mov_anterior b USING(placa_tracao)
		)
		,cur_temp AS (
		-- Traz todos os movimentos de engate / desengate com o mesmo odometro acima
			SELECT  frt_mov_eng_deseng.id_mov,
				frt_mov_eng_deseng.data_mov,
				frt_mov_eng_deseng.placa_veiculo_reboque AS placa_reboque,
				frt_mov_eng_deseng.placa_veiculo_tracao AS placa_tracao,
				frt_mov_eng_deseng.odometro_veic_tracao,
				cur_ult_mov.situacao_km,
				cur_ult_mov.situacao_hr,
				frt_mov_eng_deseng.flag_acao    
			FROM    frt_mov_eng_deseng
				LEFT JOIN cur_ult_mov ON TRUE
			--WHERE   placa_veiculo_tracao = 'OOC5689' --NEW.ab_placa
			WHERE   placa_veiculo_tracao = NEW.ab_placa
			AND     frt_mov_eng_deseng.flag_acao = 1
			AND     frt_mov_eng_deseng.odometro_veic_tracao = cur_ult_mov.odo_atual
			AND     frt_mov_eng_deseng.data_mov = cur_ult_mov.data_mov
			ORDER BY 1 desc
		)

		,cur_placas_aux AS (
		-- Traz um resumo das placas envolvidas
			SELECT  DISTINCT 
				placa_tracao AS placa_veiculo, 
				data_mov,
				odo_trac.odometro_atual,
				odo_trac.horimetro_atual,
				odo_trac.veic_km,
				odo_trac.veic_hr,
				situacao_km,
				situacao_hr,
				1::INTEGER AS tracionado    
			FROM    cur_temp  
				LEFT JOIN cur_odo_atual odo_trac
				       ON cur_temp.placa_tracao = odo_trac.placa_veiculo
			WHERE   ( situacao_km > 0 OR situacao_hr > 0 )
			AND     odo_trac.placa_veiculo IS NOT NULL

			UNION

			SELECT  placa_reboque AS placa_veiculo, 
				data_mov,
				odo_reb.odometro_atual,
				odo_reb.horimetro_atual,
				odo_reb.veic_km,
				odo_reb.veic_hr,
				situacao_km,
				situacao_hr, 
				0::INTEGER AS tracionado 
			FROM    cur_temp
				LEFT JOIN cur_odo_atual odo_reb
				       ON cur_temp.placa_reboque = odo_reb.placa_veiculo
			WHERE   ( situacao_km > 0 OR situacao_hr > 0 )
			AND     odo_reb.placa_veiculo IS NOT NULL 
		)

		,cur_pneus_mov AS (
		-- Traz os pneus dos veiculos envolvidos
			SELECT  m.id_pneu_movimentacao,
				m.id_pneu,
				m.placa_veiculo,
				m.codigo_posicao,
				m.data_mov,
				COALESCE(p.hodometro_atual,0)::INTEGER AS pneu_odo,
				COALESCE(p.horimetro_atual,0)::INTEGER AS pneu_hor,
				COALESCE(m.id_pneu_vida,0)::INTEGER as id_pneu_vida,
				COALESCE(v.km_total,0)::INTEGER AS vida_km,
				0.0::NUMERIC(9,1) AS vida_hr,
				COALESCE((( SELECT  min(f.data_mov) AS data_mov
					    FROM    frt_pneu_movimentacao f
					    WHERE   f.id_pneu = m.id_pneu 
					    AND     f.data_mov > m.data_mov
					    GROUP BY f.id_pneu, f.data_mov
					    ORDER BY f.data_mov
					    LIMIT 1))::timestamp withOUT time zone, 
					    now())::timestamp without time zone AS data_fim_mov
			FROM    frt_pneu_movimentacao m
				LEFT JOIN frt_pneus p 
				       ON m.id_pneu = p.id_pneu
				LEFT JOIN frt_pneu_vida v
				       ON m.id_pneu_vida = v.id_pneu_vida
			WHERE   m.placa_veiculo IS NOT NULL 
			AND     EXISTS (SELECT  1
					FROM    cur_placas_aux
					WHERE   cur_placas_aux.placa_veiculo = m.placa_veiculo)
			AND     m.status = ANY (ARRAY[2, 6]) 
			AND     m.tipo = 1
			ORDER BY m.placa_veiculo, m.id_pneu, m.id_pneu_movimentacao DESC
		)
		, cur_placas AS (
			SELECT  m.id_pneu_movimentacao,
				m.id_pneu,
				m.placa_veiculo,
				m.codigo_posicao,
				m.data_mov,
				m.data_fim_mov,
				m.pneu_odo,
				m.pneu_hor,
				m.id_pneu_vida,
				m.vida_km,
				m.vida_hr,
				p.odometro_atual,
				p.horimetro_atual,
				p.veic_km,
				p.veic_hr,
				p.situacao_km,
				p.situacao_hr,
				p.tracionado

			FROM    cur_pneus_mov m
				LEFT JOIN cur_placas_aux p
				       ON m.placa_veiculo = p.placa_veiculo		
			WHERE   "left"(m.codigo_posicao,1) <> 'Z'
			AND     p.placa_veiculo IS NOT NULL
			AND     p.data_mov <= m.data_fim_mov
			AND     p.data_mov >= m.data_mov
			AND     ( p.situacao_km > 0 OR p.situacao_hr > 0 )
			ORDER BY placa_veiculo, codigo_posicao
		)
		/*
		****************************************************************************************************
		* Cursor para atualizar engates
		* -- Se situacao_km = 1 ou situacao_hr = 1
		* -- os km/hr rodados devem ser aplicados nos engates 
		****************************************************************************************************
		*/
		, cur_engates AS (
			SELECT 	DISTINCT 
				placa_veiculo,
				odometro_atual,
				horimetro_atual,
				veic_km,
				veic_hr,
				situacao_km,
				situacao_hr,
				NEW.ab_km_rodados,
				--1941::numeric(8,0) AS km_rodados,
				NEW.ab_hr_trabalhadas as hr_rodados
				--0.00::numeric(9,2) AS hr_rodados 
			FROM 	cur_placas  
			WHERE 	tracionado = 0 
			AND 	(situacao_km = 1  
			OR 		 situacao_hr = 1) 
		)
		/*
		****************************************************************************************************
		* Cursor para atualizar pneus
		* -- Se situacao_km = 1 ou situacao_hr = 1
		* -- os km/hr rodados devem ser aplicados 
		* -- nos pneus dos engates
		****************************************************************************************************
		*/
		, cur_pneus_eng AS (
			SELECT DISTINCT 
				id_pneu,
				pneu_odo,
				pneu_hor,
				situacao_km,
				situacao_hr,
				NEW.ab_km_rodados,
				--1941::numeric(8,0) AS km_rodados,
				NEW.ab_hr_trabalhadas as hr_rodados
				--0.00::numeric(9,2) AS hr_rodados 		
			FROM 	cur_placas 
			WHERE 	tracionado = 0 
			AND 	(situacao_km = 1  
			OR 		 situacao_hr = 1) 
		) 
		/*
		****************************************************************************************************
		* Cursor para atualizar vidas de pneus
		* -- Se situacao_km = 1 ou situacao_hr = 1
		* -- os km/hr rodados devem ser aplicados 
		* -- nas vidas dos pneus dos engates
		****************************************************************************************************
		*/
		, cur_vida_pneus_eng AS (
			SELECT 	DISTINCT 
				id_pneu_vida,
				vida_km,
				vida_hr,
				situacao_km,
				situacao_hr,
				NEW.ab_km_rodados,
				--1941::numeric(8,0) AS km_rodados,
				NEW.ab_hr_trabalhadas as hr_rodados
				--0.00::numeric(9,2) AS hr_rodados 		
			FROM 	cur_placas 
			WHERE 	tracionado = 0 
			AND 	(situacao_km = 1  
			OR 		 situacao_hr = 1) 
		)
		/*
		****************************************************************************************************
		* Cursor para atualização dos pneus do tração
		* -- Se situacao_km > 0 ou situacao_hr > 0, atualiza pneus do tração
		****************************************************************************************************		
		*/
		, cur_pneus_tracao AS (
			SELECT 	DISTINCT 
				id_pneu,
				pneu_odo,
				pneu_hor,
				situacao_km,
				situacao_hr,
				NEW.ab_km_rodados,
				--1941::numeric(8,0) AS km_rodados,
				NEW.ab_hr_trabalhadas as hr_rodados
				--0.00::numeric(9,2) AS hr_rodados 		
			FROM 	cur_placas 
			WHERE 	tracionado = 1 
			AND 	(situacao_km + situacao_hr) > 0 
		)
		/*
		****************************************************************************************************
		* Cursor para atualizar vidas de pneus do tração
		* -- Se situacao_km > 0 ou situacao_hr > 0, atualiza vidas dos pneus do tração
		****************************************************************************************************
		*/
		, cur_vida_pneus_tracao AS (
			SELECT 	DISTINCT 
				id_pneu_vida,
				vida_km,
				vida_hr,
				situacao_km,
				situacao_hr,
				NEW.ab_km_rodados,
				--1941::numeric(8,0) AS km_rodados,
				NEW.ab_hr_trabalhadas as hr_rodados
				--0.00::numeric(9,2) AS hr_rodados 		
			FROM 	cur_placas 
			WHERE 	tracionado = 1 
			AND 	(situacao_km + situacao_hr) > 0 
		)	
		, comandos AS (
			/*
			****************************************************************************************************
			* Faz o processo de atualização de odometro dos engates 
			****************************************************************************************************
			*/
			WITH cur_engates_temp AS (
				SELECT
					placa_veiculo,
					CASE 	
						WHEN veic_km > 0 THEN veic_km + km_rodados
						WHEN odometro_atual > 0 THEN odometro_atual + km_rodados
						ELSE 0 + km_rodados
					END::numeric(8,0) as km_rodados,
					CASE 	
						WHEN veic_hr > 0 THEN veic_hr + hr_rodados
						WHEN horimetro_atual > 0 THEN horimetro_atual + hr_rodados
						ELSE 0 + hr_rodados
					END::numeric(8,0) as hr_rodados
				FROM	cur_engates
			)		

			, cur_pneus_eng_temp AS (
				SELECT 				
					id_pneu,
					(pneu_odo + km_rodados) as km_rodados,
					(pneu_hor + hr_rodados) as hr_rodados
				FROM 
					cur_pneus_eng
			)
			, cur_vida_pneus_eng_temp AS (
				SELECT 				
					id_pneu_vida,
					(vida_km + km_rodados) as km_rodados,
					(vida_hr + hr_rodados) as hr_rodados
				FROM 
					cur_vida_pneus_eng

			)
			, cur_pneus_tracao_temp AS (
				SELECT 				
					id_pneu,
					(pneu_odo + km_rodados) as km_rodados,
					(pneu_hor + hr_rodados) as hr_rodados
				FROM 
					cur_pneus_tracao

			)
			, cur_vida_pneus_tracao_temp AS (
				SELECT 				
					id_pneu_vida,
					(vida_km + km_rodados) as km_rodados,
					(vida_hr + hr_rodados) as hr_rodados
				FROM 
					cur_vida_pneus_tracao

			)
			/*
			Geração dos Comandos para atualização dos odometros. 
			*/
			SELECT 	
				1::integer as ordem,

				'UPDATE veiculos SET ' 	|| 
				'odometro_atual = ' 	|| km_rodados::text || ', '
				'horimetro_atual = ' 	|| hr_rodados::text || ' '
				'WHERE placa_veiculo = ''' || placa_veiculo || ''';' as cmd
			FROM cur_engates_temp

			UNION 
			SELECT 	
				2::integer as ordem,

				'UPDATE frt_pneus SET ' 	|| 
				'hodometro = ' 		|| km_rodados::text || ', '
				'hodometro_atual = ' 	|| km_rodados::text || ', '
				'horimetro = '	 	|| hr_rodados::text || ', '
				'horimetro_atual = ' 	|| hr_rodados::text || ' '
				'WHERE placa_veiculo = ' || id_pneu::text || ';' as cmd
			FROM cur_pneus_eng_temp

			UNION 
			SELECT 	
				3::integer as ordem,
				'UPDATE frt_pneu_vida SET ' 	|| 
				'km_total = ' 		|| km_rodados::text || ', '
				'hr_total = ' 		|| hr_rodados::text || ' '
				'WHERE id_pneu_vida = ' || id_pneu_vida::text || ';' as cmd
			FROM cur_vida_pneus_eng_temp

			UNION 
			SELECT 	
				4::integer as ordem,
				'UPDATE frt_pneus SET ' 	|| 
				'hodometro = ' 		|| km_rodados::text || ', '
				'hodometro_atual = ' 	|| km_rodados::text || ', '
				'horimetro = '	 	|| hr_rodados::text || ', '
				'horimetro_atual = ' 	|| hr_rodados::text || ' '
				'WHERE placa_veiculo = ' || id_pneu::text || ';' as cmd
			FROM 	cur_pneus_tracao_temp

			UNION 
			SELECT 	
				5::integer as ordem,
				'UPDATE frt_pneu_vida SET ' 	|| 
				'km_total = ' 		|| km_rodados::text || ', '
				'hr_total = ' 		|| hr_rodados::text || ' '
				'WHERE id_pneu_vida = ' || id_pneu_vida::text || ';' as cmd
			FROM cur_vida_pneus_tracao_temp
			
			ORDER BY ordem

		)
		SELECT string_agg(cmd, chr(13) order by ordem) 
		INTO vCmd
		FROM comandos ;

		--Comando para mostrar messagem para DEBUG
		RAISE NOTICE 'Comando: %', vCmd;
		
		--Execução dos Comandos de UPDATE
		EXECUTE vCmd;
		
	END IF;

	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER tgg_ab_km_rodados ON frt_ab;
CREATE TRIGGER tgg_ab_km_rodados
AFTER INSERT OR UPDATE 
ON frt_ab
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_ab_km_rodados();


/*
CREATE TYPE t_ab_km_veiculo_pneus AS (
	id_pneu_movimentacao integer,
	id_pneu integer,
	placa_veiculo character(8),
	codigo_posicao character(3),
	data_mov timestamp,
	data_fim_mov timestamp,
	pneu_odo integer,
	pneu_hor numeric(9,1),
	id_pneu_vida integer,
	vida_km integer,
	vida_hr numeric(9,1),
	odometro_atual integer,
	horimetro_atual numeric(9,1),
	veic_km integer,
	veic_hr numeric(9,1),
	situacao_km integer,
	situacao_hr integer,
	tracionado integer
)
*/