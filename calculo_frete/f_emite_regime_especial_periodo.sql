-- Function: public.f_emite_regime_especial_periodo(integer[], date, date, date, integer, numeric, numeric, integer, integer, refcursor, refcursor, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_emite_regime_especial_periodo(integer[], date, date, date, integer, numeric, numeric, integer, integer, refcursor, refcursor, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_emite_regime_especial_periodo(
    p_lst_nf integer[],
    data_ini date,
    data_fim date,
    p_data_re date,
    p_qt_cte integer,
    p_valor_periodo numeric,
    p_valor_por_cte numeric,
    p_codigo_cliente integer,
    p_id_conhecimento integer,
    cf refcursor,
    msg refcursor,
    imposto_cf refcursor,
    imposto refcursor,
    msg_imposto refcursor)
  RETURNS text AS
$BODY$
DECLARE
	nfs text[];	
	qt integer;
	qt_nfs_cte integer;
	v_id_cte_re integer;
	
	v_empresa character(3);
	i integer;
	corte integer;
	lista_nf integer[];
	cont integer;
	cont2 integer;
	cont3 integer;
	v_id_conhecimento integer [];
	valor_doc     	numeric(12,2);
	resto_valor	numeric(12,2);
 	vEmpresa text;
	v_tabela_sem_minuta integer;
	qt_cte integer;	
	v_sem_limite_minimo_re integer;
	

BEGIN		

	vEmpresa = fp_get_session('pst_cod_empresa');	
	v_sem_limite_minimo_re = fp_get_session('pst_sem_limite_minimo_re');


	IF p_lst_nf IS NULL THEN 
		SELECT 
			string_to_array(string_agg(nf.id_nota_fiscal_imp::text,',' order by nf.id_nota_fiscal_imp),','), 
			count(*),
			rem.empresa_responsavel
		INTO 
			nfs,
			qt
		FROM 
			scr_notas_fiscais_imp nf
			LEFT JOIN cliente rem ON rem.codigo_cliente = nf.remetente_id
			LEFT JOIN cidades origem ON origem.id_cidade = rem.id_cidade
			LEFT JOIN cliente dest ON dest.codigo_cliente = nf.destinatario_id
			LEFT JOIN cidades destino ON destino.id_cidade = dest.id_cidade
		WHERE 
			CASE 	WHEN rem.tipo_data = 1 THEN  
					nf.data_expedicao     >= data_ini
					AND nf.data_expedicao <= data_fim
				WHEN rem.tipo_data = 2 THEN  
					nf.data_emissao     >= data_ini
					AND nf.data_emissao <= data_fim
				ELSE 
					false
			END		
			AND nf.id_conhecimento IS NULL
			AND nf.status = 0
			AND origem.uf = destino.uf
			AND origem.uf = 'SP'
			AND remetente_id = p_codigo_cliente
			AND frete_cif_fob = 1
			AND rem.empresa_responsavel = vEmpresa
		GROUP BY 
			rem.empresa_responsavel;
	ELSE
		qt = array_length(p_lst_nf,1);
		
		FOR i IN 1..qt LOOP
			nfs = nfs || ARRAY[p_lst_nf[i]::text];
		END LOOP;
		
	END IF;	

	IF v_empresa IS NOT NULL THEN
		PERFORM fp_set_session('pst_cod_empresa',v_empresa);
	END IF;

	IF v_sem_limite_minimo_re = 1 THEN 
		UPDATE scr_notas_fiscais_imp 
		SET flg_calculo_frete = 1, limite_minimo_re = 0
		WHERE ARRAY[id_nota_fiscal_imp] <@ p_lst_nf;		
		RETURN '0';
	END IF;


	--Verifica se calcula por tabela sem minuta ou por valor fixo
	IF p_valor_periodo = 0 AND p_valor_por_cte = 0 THEN 

		v_tabela_sem_minuta = 1;

		--Verifica se existe cte em regime especial naquele dia. 
		SELECT 
			c.id_conhecimento,
			COUNT(*) as qt 
		INTO 
			v_id_cte_re,
			qt_nfs_cte
		FROM 
			scr_conhecimento c
			LEFT JOIN scr_conhecimento_notas_fiscais nf
				ON nf.id_conhecimento = c.id_conhecimento
		WHERE 
			CASE WHEN c.tipo_transporte = 18 THEN 
				consig_red_id = p_codigo_cliente
			ELSE
				remetente_id = p_codigo_cliente
			END
			AND c.data_cte_re = p_data_re
			AND c.cancelado = 0
			AND c.tipo_documento = 1
			AND COALESCE(cstat,'') <> '100'
		GROUP BY 
			c.id_conhecimento
		HAVING count(*) < 2000;

		
		v_id_cte_re = COALESCE(v_id_cte_re,0);
		qt_nfs_cte = COALESCE(qt_nfs_cte,0);
		
		IF (qt % 2000) = 0 THEN
			qt_cte = (qt + qt_nfs_cte)/2000;
		ELSE
			qt_cte = (qt + qt_nfs_cte)/2000 + 1;
		END IF;
		
		corte = 2000;

		cont  = qt_nfs_cte;
		cont2 = qt_nfs_cte;
		cont3 = 1;
	ELSE
		v_tabela_sem_minuta = 0;
		qt_cte = p_qt_cte;

		IF p_valor_periodo > 0 THEN 
			valor_doc   = p_valor_periodo/qt_cte;
			resto_valor = p_valor_periodo - (valor_doc * qt_cte);
		ELSE
			valor_doc   = p_valor_por_cte;
			resto_valor = 0.00;
		END IF;

		RAISE NOTICE 'Valor Doc %', valor_doc;
		RAISE NOTICE 'Resto Valor %', resto_valor;


		i = array_length(nfs,1);
		
		corte = qt/qt_cte;	

		cont  = 0;
		cont2 = 0;
		cont3 = 1;
		
	END IF;

	
	RAISE NOTICE 'Qt Notas %', qt;
	
	IF qt < 1 THEN
		RETURN '0';
	END IF;
	
	FOR i IN 1..qt LOOP	

		--Cria uma lista com a quantidade de notas permitidas dentro do cte
		lista_nf = lista_nf || nfs[i]::integer;		
		cont     = cont  + 1;
		cont2 	 = cont2 + 1;

-- 		RAISE NOTICE 'Cont %', cont;
-- 		RAISE NOTICE 'Cont2 %',cont2;
-- 		RAISE NOTICE 'Cont3 %',cont3;
-- 		RAISE NOTICE 'Qt Cte %',qt_cte;
		--Se atingiu o limite de notas, gera o cte com a lista
		IF cont2 = qt or (cont = corte AND cont3 < qt_cte) THEN 
			RAISE NOTICE 'Corte em %', i;
			RAISE NOTICE 'Lista Nfs: %', lista_nf::text;
			
			cont = 0;			

			IF v_tabela_sem_minuta = 0 THEN 	
				
				v_id_conhecimento = v_id_conhecimento || f_emite_regime_especial_valor_fixo(lista_nf,
							valor_doc + resto_valor,
							p_data_re,
							p_codigo_cliente,
							'imposto_cf',
							'imposto',
							'msg_imposto');
			ELSE
				
				RAISE NOTICE 'Sem minuta';
				v_id_conhecimento = v_id_conhecimento || f_emite_regime_especial_sem_minuta(lista_nf,							
							p_data_re,
							p_codigo_cliente,
							v_id_cte_re,
							'cf',
							'msg',
							'imposto_cf',
							'imposto',
							'msg_imposto');

			END IF;
			cont3 = cont3 + 1;
			
			v_id_cte_re = 0;
						
			lista_nf = '{}'::text[];
			resto_valor = 0.00;			
		END IF;		
	END LOOP;

-- 	--Verifica se a empresa utiliza regime especial
-- 	vEmpresa = fp_get_session('pst_cod_empresa')::text;
-- 	
-- 	SELECT 	valor_parametro::integer 
-- 	INTO 	vRegimeEspecial
-- 	FROM 	parametros 
-- 	WHERE 	cod_empresa = vEmpresa 
-- 		AND upper(cod_parametro) = 'PST_REGIME_ESPECIAL';
-- 	
-- 
-- 
-- 	--IF vRegimeEspecial = 1 AND vRegimeEspecialCombinado = 1 THEN 			
-- 	--	vIdConhecimento = f_emite_conhecimento_automatico_re_combinado(lstnf);		
-- 	--END IF;	
-- 	
 	RETURN array_to_string(v_id_conhecimento,',');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
