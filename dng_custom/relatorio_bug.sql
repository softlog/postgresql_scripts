SELECT id_nota_fiscal_imp, data_expedicao FROM scr_notas_fiscais_imp WHERE id_nota_fiscal_imp = 4251286
	WITH  cur_estado AS (
		select 	id_estado 
				,nome_estado
		FROM estado
		)
		
        ,cur_cli AS (
        SELECT   codigo_cliente 
                ,nome_cliente 
                ,id_cidade 
                ,cnpj_cpf

        FROM    cliente 

        )
	,cur_for AS (
		SELECT	id_fornecedor
				,nome_razao
				,cnpj_cpf
		FROM fornecedores
		)
	,cur_nfimp AS (
        SELECT   data_expedicao
        	,data_emissao
        	,data_registro
                ,empresa_emitente 
                ,id_conhecimento 
                ,remetente_id
                ,destinatario_id 
                ,volume_presumido 
                ,peso_presumido 
                ,codigo_nota 
                ,tipo_transporte 
                ,consignatario_id
                ,id_nota_fiscal_imp
                ,ro.numero_romaneio
                ,nf2.id_ocorrencia
                ,nf2.data_ocorrencia

        FROM    scr_notas_fiscais_imp nf2
                LEFT  JOIN cur_cli r 
                        ON r.codigo_cliente::INTEGER = nf2.remetente_id::INTEGER 

                LEFT  JOIN cur_cli d 
                        ON d.codigo_cliente::INTEGER = nf2.destinatario_id::INTEGER 
                
                LEFT JOIN cidades cd 
                		ON cd.id_cidade = d.id_cidade
                		
                LEFT JOIN estado
                		ON estado.id_estado = cd.uf                

                LEFT  JOIN cur_cli p 
                        ON p.codigo_cliente::INTEGER = nf2.consignatario_id::INTEGER 
                        
                LEFT  JOIN scr_romaneios ro 
                		ON ro.id_romaneio = nf2.id_romaneio
        WHERE	1=1
        		AND  (NF2.DATA_EXPEDICAO::DATE >= '2019-07-01'  AND   NF2.DATA_EXPEDICAO::DATE <= '2019-07-30')
        		
        ) --SELECT * FROm cur_nfimp

	,cur_conhec AS (
        SELECT   con.id_conhecimento
                ,con.id_faturamento 
                ,con.numero_ctrc_filial 
                ,con.tipo_transporte
                ,con.tipo_documento
                ,con.tabele_frete
                ,con.total_frete 
                ,con.chave_cte
                ,con.remetente_id
                ,con.consig_red_cnpj
                ,con.cancelado
                ,con.data_emissao::date as data_cte
        FROM    scr_conhecimento con
        LEFT 	JOIN scr_faturamento fat ON fat.id_faturamento = con.id_faturamento
        WHERE	1=1
				AND con.id_conhecimento IN (SELECT DISTINCT id_conhecimento from cur_nfimp)
        )

		-- inserçao feita em 02-03-2018 para relacionar melhor as notas do conhecimento com a tabela de notas importadas
	,cur_nfcon AS (
		SELECT	
			nf.*,
			(trim(c.remetente_id::text) || '_' ||  
				ltrim(trim(nf.numero_nota_fiscal),'0') || '_' || 
				ltrim(trim(nf.serie_nota_fiscal),'0')) as codigo_nota,
			nfimp.id_nota_fiscal_imp as id_nota_fiscal_imp2
			
		FROM scr_conhecimento_notas_fiscais nf
		LEFT JOIN scr_conhecimento c ON c.id_conhecimento = nf.id_conhecimento
		LEFT JOIN scr_notas_fiscais_imp nfimp 
			ON nfimp.id_nota_fiscal_imp = nf.id_nota_fiscal_imp
			-- nfimp.codigo_nota = 
-- 				(trim(c.remetente_id::text) || '_' ||  
-- 					ltrim(trim(nf.numero_nota_fiscal),'0') || '_' || 
-- 					ltrim(trim(nf.serie_nota_fiscal),'0'))	

		WHERE	nf.id_conhecimento IN (SELECT DISTINCT id_conhecimento from cur_conhec)
		) 
         SELECT * FROM cur_nfcon WHERE numero_nota_fiscal = '000353564'
        ,cur_rs AS (
        SELECT   id_cidade 
        		,id_setor
                ,setor
                ,id_regiao

        FROM    v_regiao_setores2 

        )

        ,cur_fat AS (
        SELECT   id_faturamento
                ,numero_fatura 

        FROM    scr_faturamento 

        )

        ,cur_tp AS ( 
        SELECT   nf.id_nota_fiscal_imp as id_nota_fiscal_imp 
                ,nf.data_nota_fiscal AS data_emissao_nf
                ,nf2.data_expedicao
                ,nf.numero_nota_fiscal
                ,nf.serie_nota_fiscal
                ,r.nome_cliente remetente
                ,d.cnpj_cpf as cnpj_destinatario
                ,d.nome_cliente destinatario
                ,cd.nome_cidade AS cidade_destino
                ,cd.uf                
				,v_rs.setor                
				,nf2.volume_presumido AS volumes
                ,nf2.peso_presumido AS peso
                ,nf.valor as valor_nota
                ,nf.valor AS valor_total_notas
                ,nf.valor_total_produtos
                ,c.total_frete AS total_frete_cte
                ,c.numero_ctrc_filial AS numero_cte
                ,c.data_cte
                ,c.chave_cte
                ,c.id_conhecimento
                ,c.id_faturamento
                ,t.calcular_a_partir_de
                ,nf.total_frete_nf
                ,nf.total_frete_prod
                ,(CASE  COALESCE(t.calcular_a_partir_de, 1)
                        WHEN 1 THEN nf.total_frete_nf 
                        WHEN 3 THEN nf.total_frete_prod 
                        ELSE 0.00 END) AS valor_frete_nota 
                ,(      trim(c.remetente_id::text)       || '_' || 
                  ltrim(trim(nf.numero_nota_fiscal),'0') || '_' || 
                  ltrim(trim(nf.serie_nota_fiscal), '0') || '_' || 
                        triM(c.tipo_transporte::text))::TEXT as codigo_nota 
                ,p.nome_cliente as cliente_consignatario
                ,nf2.numero_romaneio
                ,nf2.data_ocorrencia
                ,oco.ocorrencia

			FROM    (select * from cur_nfcon) nf

			LEFT  JOIN cur_nfimp nf2
					ON nf2.id_nota_fiscal_imp = nf.id_nota_fiscal_imp2


                LEFT  JOIN cur_conhec c 
                        ON c.id_conhecimento = nf.id_conhecimento

                LEFT  JOIN cur_cli r 
                        ON r.codigo_cliente::INTEGER = nf2.remetente_id::INTEGER 

                LEFT  JOIN cur_cli d 
                        ON d.codigo_cliente::INTEGER = nf2.destinatario_id::INTEGER 

                LEFT  JOIN cur_cli p 
                        ON p.codigo_cliente::INTEGER = nf2.consignatario_id::INTEGER 

                LEFT  JOIN cidades cd
                        ON cd.id_cidade::INTEGER = d.id_cidade::INTEGER 
                LEFT  JOIN cur_rs v_rs 
                        ON v_rs.id_cidade::INTEGER = d.id_cidade::INTEGER                 LEFT  JOIN v_calcular_a_partir_de t 
                        ON t.numero_tabela_frete = c.tabele_frete 

                LEFT  JOIN cur_fat fat 
                        ON fat.id_faturamento = c.id_faturamento 

                LEFT JOIN cur_for redespachador
						ON redespachador.cnpj_cpf = c.consig_red_cnpj
						
				LEFT JOIN scr_ocorrencia_edi oco
						ON oco.codigo_edi = nf2.id_ocorrencia

        WHERE 1=1

 AND 2=2


 AND C.TIPO_DOCUMENTO <> 3
        AND c.cancelado <> 1
        )

SELECT   tp.data_emissao_nf
		,tp.data_expedicao
		,tp.data_cte		
		,tp.numero_nota_fiscal
		,tp.serie_nota_fiscal
		,tp.remetente
		,tp.cnpj_destinatario
		,tp.destinatario
		,tp.cidade_destino
		,tp.uf		
		,tp.setor		
		,tp.volumes
		,tp.peso
		,tp.valor_nota
		,tp.valor_total_notas
		,tp.valor_total_produtos
		,tp.total_frete_cte
		,tp.valor_frete_nota
		,tp.numero_cte
		,tp.chave_cte
		,tp.cliente_consignatario
		,tp.numero_romaneio
		,tp.data_ocorrencia
		,tp.ocorrencia

FROM    cur_tp tp 
WHERE 
	tp.numero_nota_fiscal = '000353564'

ORDER   BY
		numero_cte, numero_nota_fiscal, serie_nota_fiscal