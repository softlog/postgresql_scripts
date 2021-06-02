-- Function: public.f_get_div_docs_digitalizado(text, integer)
/*
SELECT string_agg(cliente.codigo_cliente::text, ',') FROM cliente WHERE nome_cliente LIKE '%DIRECION%'
SELECT id_conhecimento FROM scr_conhecimento WHERE consig_red_id IN (597,1987,511,966,327,642,321,330,154) AND data_emissao >= '2021-01-01'::timestamp
 SELECT
                           string_agg(nf.numero_nota_fiscal,',' order by nf.numero_nota_fiscal) as numero_nota_fiscal,
			               0::integer as id_ocorrencia,
                           (to_char(c.data_entrega,'DD/MM/YYYY') ||  ' ' || left(c.hora_entrega,2) ||':'|| right(c.hora_entrega,2)) as data,
                           c.hora_entrega,
                           c.remetente_id,
                           cnpj_cpf(c.remetente_cnpj) || ' - ' || retira_acento(c.remetente_nome) as remetente_nome,
                           c.remetente_cnpj,
                           c.destinatario_id,
                           cnpj_cpf(c.destinatario_cnpj) || ' - ' || retira_acento(c.destinatario_nome) as destinatario_nome,
                           retira_acento(COALESCE(c.nome_recebedor,'')) as nome_recebedor,
                           COALESCE(c.cpf_recebedor,''),
                           COALESCE(c.numero_awb,''),
                           ''::text as ocorrencia,
                           0::integer as pendencia,
                           cnpj_cpf(t.cnpj) || ' - ' || retira_acento(t.razao_social) as Transportadora,
                           c.consig_red_id,
                           cnpj_cpf(c.pagador_cnpj) || ' - ' || retira_acento(pagador.nome_cliente) as pagador,
                           c.pagador_cnpj,
                           c.numero_ctrc_filial,
                           COALESCE(f_get_url_docs_digitalizado(c.id_conhecimento::text,1),'') as comprovante_entrega

               FROM scr_conhecimento c
		                LEFT JOIN scr_conhecimento_notas_fiscais nf ON c.id_conhecimento = nf.id_conhecimento
                        LEFT JOIN cliente pagador ON pagador.codigo_cliente = c.consig_red_id
                        LEFT JOIN filial t ON t.codigo_empresa = c.empresa_emitente AND t.codigo_filial = c.filial_emitente
               WHERE c.id_conhecimento = 34988
               GROUP BY
			             c.id_conhecimento,
			             t.id_filial,
			             pagador.codigo_cliente


*/

-- DROP FUNCTION public.f_get_div_docs_digitalizado(text, integer);
CREATE OR REPLACE FUNCTION public.f_get_url_docs_digitalizado(
    lista_ids text,
    tipo_doc integer)
  RETURNS text AS
$BODY$
DECLARE
        url text;
        str_sql text;
        vCursor refcursor;
        urls text;
        resultado text;
BEGIN
	resultado = NULL;
	--Por Digitalizacao na tabela de scr_conhecimento_digitalizado'
	RAISE NOTICE 'Lista ids %', lista_ids;
	
        IF tipo_doc = 1 THEN 
		IF fp_get_session('pst_cod_empresa') IS NULL THEN 
			PERFORM fp_set_session('pst_cod_empresa',empresa_emitente) 
			FROM scr_conhecimento 
			WHERE id_conhecimento 
			IN (lista_ids::integer);
		END IF;
		
		url = f_get_parametro_sistema('pST_url_servicos',fp_get_session('pst_cod_empresa'));
		str_sql = 'SELECT string_agg(''<p><div><a href="'' || ''' || url || ''' || caminho_arquivo || ''">Visualizar Imagem do Documento.</a></div></p>'','''') as lista_id 
				FROM scr_conhecimento_digitalizado
			    WHERE id_conhecimento IN (' || lista_ids || ') GROUP BY id_ctrc_digitalizado';
		
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;

		RAISE NOTICE '%', str_sql;
		RAISE NOTICE 'URLS %', urls;
		IF urls IS NOT NULL THEN 			
			RETURN urls;
		END IF;        	
        

		str_sql = 'SELECT string_agg(''<p><div><a href="'' || trim(link_img) || ''">Visualizar Imagem do Documento.</a></div></p>'','''')  as lista_id 
				FROM scr_docs_digitalizados
			    WHERE id_conhecimento IN (' || lista_ids || ') GROUP BY id';
			    
		RAISE NOTICE '%', str_sql;
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;
		IF urls IS NOT NULL THEN 
			RETURN urls;
		END IF;        	
		
        END IF;

	--Imagens de baixas em scr_notas_fiscais_imp
        IF tipo_doc = 3 THEN 
	
		str_sql = 'SELECT string_agg(''<p><div><<a href="'' || trim(link_img) || ''">Visualizar Imagem do Documento.</a></div></p>'','''')  as lista_id 
				FROM scr_docs_digitalizados
			    WHERE id_nota_fiscal_imp IN (' || lista_ids || ')';
			    
		RAISE NOTICE '%', str_sql;
		OPEN vCursor FOR EXECUTE str_sql;		
		FETCH vCursor INTO urls;
		CLOSE vCursor;
		IF urls IS NOT NULL THEN 
			RETURN urls;
		END IF;        	
		
        END IF;

        
	RETURN resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

