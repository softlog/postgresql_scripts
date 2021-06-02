-- Function: public.f_grava_docs_viagens(character, integer, integer, integer, timestamp without time zone, refcursor, refcursor)

-- DROP FUNCTION public.f_grava_docs_viagens(character, integer, integer, integer, timestamp without time zone, refcursor, refcursor);
/*
COMMIT;
Begin;
SELECT 	f_grava_docs_viagens(		'0010010004062',2,3499,51,'2021-04-20 08:29:00',5355,5355,'0010010000009','cursor_docs','msg')::text as mensagem
FETCH ALL IN "cursor_docs";
FETCH ALL IN "msg"

--SELECT * FROM regiao_cidades WHERE id_cidade = 5355

Begin;
SELECT 	f_grava_docs_viagens(		'0010010004075',2,3531,17,'2021-02-24 08:24:00',5355,5272,'0010010000005','cursor_docs','msg')::text as mensagem

commit;
SELECT 
	tr.perc_red_bc_comissao
FROM 	
	scr_tabela_motorista t
	LEFT JOIN scr_tabela_motorista_regioes tr
		ON t.id_tabela_motorista = tr.id_tabela_motorista
WHERE 
	numero_tabela_motorista = '0010010000005'
	AND id_regiao_origem = 3
	AND id_regiao_destino = 4;

*/



CREATE OR REPLACE FUNCTION public.f_grava_docs_viagens(
    pNrDoc character,
    pTipoDocumento integer,
    pIdRomaneio integer,
    pIdMotorista integer,
    pData timestamp without time zone,    
    p_id_origem integer,
    p_id_destino integer,
    p_tabela text,
    cDocumento refcursor,
    msg refcursor)
  RETURNS SETOF refcursor AS
$BODY$
DECLARE 	
	pNrDoc ALIAS FOR $1;
	pTipoDocumento ALIAS FOR $2;
	pIdRomaneio ALIAS FOR $3;
	pIdMotorista ALIAS FOR $4;
	pData ALIAS FOR $5;
	vComandoSQL text;
	vCursor refcursor;
	vId_doc integer;
	vData_viagem timestamp;
	vTotal_frete numeric(12,2);
	vPeso numeric(12,2);
	vQtd_volumes integer;
	vVolume_cubico numeric(12,3);
	vStatus integer;	
	vCancelado integer;
	vStatus_desc text;
	vId_romaneio integer;
	vId_motorista integer;
	vPagadorId integer;
	vResultado text;	
	v_id_origem integer;
	v_id_destino integer;    
	v_percentual_bc numeric(5,2);
	v_percentual_bc2 numeric(5,2);
	
BEGIN
	
	--IMPORTAÇÃO DE ACERTOS DA TABELA ROMANEIO
	vResultado = '';
	IF pTipoDocumento = 1 OR pTipoDocumento = 2 THEN 
		OPEN vCursor FOR EXECUTE 'SELECT scr_conhecimento.id_conhecimento, 
						scr_conhecimento.total_frete,
						scr_conhecimento.peso,
						scr_conhecimento.qtd_volumes, 					
						scr_conhecimento.volume_cubico,
						scr_conhecimento.status,
						scr_conhecimento.cancelado,
						status_ctrc(scr_conhecimento.id_conhecimento) as status_desc,
						scr_viagens_docs.id_romaneio,
						CASE 
							WHEN scr_conhecimento.id_motorista IS NOT NULL 
							THEN scr_conhecimento.id_motorista
							ELSE scr_manifesto.id_motorista 
						END as id_motorista,
						consig_red_id						
					FROM scr_conhecimento
						LEFT JOIN scr_manifesto 	ON scr_conhecimento.id_manifesto = scr_manifesto.id_manifesto
						LEFT JOIN scr_viagens_docs 	ON scr_conhecimento.id_conhecimento = scr_viagens_docs.id_documento AND scr_viagens_docs.tipo_documento = 1
					WHERE 
						scr_conhecimento.tipo_documento = ' || pTipoDocumento || 
						' AND numero_ctrc_filial = ''' || pNrDoc || '''';
					
		FETCH vCursor INTO 	vId_doc, 
					vTotal_frete,
					vPeso,
					vQtd_volumes,
					vVolume_cubico,
					vStatus,
					vCancelado,
					vStatus_desc,
					vId_romaneio,
					vId_motorista,
					vPagadorId;

		IF NOT FOUND THEN
			vResultado = 'Documento não existe!';	
		END IF;

		CLOSE vCursor;		

		BEGIN
			SELECT 	COALESCE(replace(valor_parametro,',','.')::numeric(12,2),0.00)
			INTO v_percentual_bc
			FROM cliente_parametros
				LEFT JOIN cliente
					ON cliente.codigo_cliente = cliente_parametros.codigo_cliente
			WHERE 
				cliente_parametros.id_tipo_parametro = 94
				AND cliente.codigo_cliente = vPagadorId;
				
		EXCEPTION WHEN OTHERS  THEN 
			
			RAISE NOTICE 'ERRO ****************************************%', SQLERRM;
			RAISE NOTICE 'CODIGO INTERNO FRETE %', vCodInternoFrete;
		END; 

		v_percentual_bc = COALESCE(v_percentual_bc, 0.00);
		--Verifica se tem percentual de reducao na tabela
		IF p_tabela IS NOT NULL THEN 

			v_id_origem = retorna_regiao_origem_motorista(p_id_origem, p_tabela);
			v_id_destino = retorna_regiao_destino_motorista(v_id_origem, p_id_destino, p_tabela);

			--RAISE NOTICE 'Destino %', p_id_destino;
			
			RAISE NOTICE 'Origem %', v_id_origem;
			RAISE NOTICE 'Destino %', v_id_destino;
			
			SELECT 
				tr.perc_red_bc_comissao
			INTO 
				v_percentual_bc2					
			FROM 	
				scr_tabela_motorista t
				LEFT JOIN scr_tabela_motorista_regioes tr
					ON t.id_tabela_motorista = tr.id_tabela_motorista
			WHERE 
				numero_tabela_motorista = p_tabela
				AND id_regiao_origem = v_id_origem
				AND id_regiao_destino = v_id_destino;

			RAISE NOTICE 'Percentual Red BC Tabela %', v_percentual_bc2;
			
			IF v_percentual_bc2 IS NOT NULL THEN
				IF v_percentual_bc2 > 0.00 THEN 
					v_percentual_bc = v_percentual_bc2;
				END IF;				
			END IF;
			
		END IF;		
		
		
-- 		IF vId_Motorista IS NOT NULL THEN 
-- 			IF vId_motorista <> pIdMotorista THEN
-- 				vResultado = 'Este documento não foi manifestado para este motorista!';			
-- 				RETURN vResultado;
-- 			END IF;
-- 		END IF;

		-- IF vData_viagem < pData THEN
-- 			vResultado = 'A data de saída do documento é menor que a data de viagem!';			
-- 			RETURN vResultado;
-- 		END IF;


		IF vId_romaneio IS NOT NULL THEN
			IF vId_romaneio = pIdRomaneio THEN 
				vResultado = 'O Documento já está incluído nesta Viagem!';
			ELSE 
				vResultado = 'O Documento já está incluído noutra Viagem!';
			END IF;			
		END IF;
		

		IF vCancelado = 1 THEN 
			vResultado = 'O Documento está cancelado!';
		END IF;

		--Se não há nenhum problema com o documento, inserir o mesmo		
		IF vResultado = '' THEN 

			OPEN cDocumento FOR
			SELECT 
				NULL::integer as id_viagem_doc,
				pIdRomaneio as id_romaneio,
				vId_doc as id_documento,
				1 as tipo_documento, --Tipo CTRC ou Minuta
				vPeso as peso_total,	
				vVolume_cubico as volume_cubado,
				vQtd_volumes as qtd_volumes,
				(vTotal_frete / (1 + (v_percentual_bc/100)))::numeric(12,2) as total_frete,
				pData as data_saida,
				scr_conhecimento.numero_ctrc_filial::character(13) as numero_documento, 				
				CASE 	
					WHEN scr_conhecimento.tipo_documento = 1 THEN 'CTRC/CTe' 
					WHEN scr_conhecimento.tipo_documento = 2 THEN 'MINUTA' 
				END::character(10) as documento,
				string_agg(numero_nota_fiscal,',') as numero_nota_fiscal,
				scr_conhecimento.remetente_nome,
				scr_conhecimento.destinatario_nome,
				destinatario_cidade as cidade_destino,
				destinatario_uf as uf_destino,
				vTotal_frete as total_frete_bruto,
				vPeso as peso_total_bruto,
				v_percentual_bc as perc_red_bc_comissao
			FROM 	
				scr_conhecimento 
				LEFT JOIN scr_conhecimento_notas_fiscais 
					ON scr_conhecimento_notas_fiscais.id_conhecimento = scr_conhecimento.id_conhecimento
			WHERE 
				scr_conhecimento.id_conhecimento = vId_doc
			GROUP BY scr_conhecimento.id_conhecimento;			

			RETURN NEXT cDocumento;
			
			OPEN msg FOR SELECT vResultado::text as resultado;
			RETURN NEXT msg;

		ELSE
			OPEN cDocumento FOR SELECT 1 ;
			RETURN NEXT cDocumento;

			OPEN msg FOR SELECT vResultado::text as resultado;
			RETURN NEXT msg;
		END IF;
	ELSE --Caso o Documento seja manifesto;
		OPEN vCursor FOR EXECUTE 'SELECT scr_manifesto.id_manifesto, 
						scr_manifesto.data_viagem, 
						SUM(scr_conhecimento.total_frete) as total_frete,
						SUM(scr_conhecimento.peso) as peso,
						SUM(scr_conhecimento.qtd_volumes) as qtd_volumes, 					
						SUM(scr_conhecimento.volume_cubico) as volume_cubico,
						scr_manifesto.status,
						0::integer as cancelado,
						null::text as status_desc,
						scr_viagens_docs.id_romaneio,
						scr_manifesto.id_motorista
					FROM scr_manifesto
						LEFT JOIN scr_conhecimento 	ON scr_conhecimento.id_manifesto = scr_manifesto.id_manifesto
						LEFT JOIN scr_viagens_docs 	ON scr_manifesto.id_manifesto = scr_viagens_docs.id_documento AND scr_viagens_docs.tipo_documento = 2
					WHERE 
						trim(scr_manifesto.serie_mdfe) <> ''U''
						AND scr_manifesto.numero_manifesto = ''' || pNrDoc || ''''
						' GROUP BY scr_manifesto.id_manifesto, scr_viagens_docs.id_viagem_doc ';
		
		FETCH vCursor INTO 	vId_doc, 
					vData_viagem,
					vTotal_frete,
					vPeso,
					vQtd_volumes,
					vVolume_cubico,
					vStatus,
					vCancelado,
					vStatus_desc,
					vId_romaneio,
					vId_motorista;

		

		IF NOT FOUND THEN			
			vResultado = 'Documento não existe!';
		END IF;

		CLOSE vCursor;

		IF vId_motorista <> pIdMotorista THEN
			vResultado = 'Este documento não foi manifestado para este motorista!';						
		END IF;

-- 		IF vData_viagem < pData THEN
-- 			vResultado = 'A data de saída do documento é menor que a data de viagem!';			
-- 			RETURN vResultado;
-- 		END IF;

		
		IF vId_romaneio IS NOT NULL THEN

			IF vId_romaneio = pIdRomaneio THEN 
				vResultado = 'O Documento já está incluído nesta Viagem!';
			ELSE 
				vResultado = 'O Documento já está incluído noutra Viagem!';
			END IF;
			
		END IF;

		

		IF vCancelado = 1 THEN 
			vResultado = 'O Documento está cancelado!';			
		END IF;

		--Se não há nenhum problema com o documento, inserir o mesmo
		
		IF vResultado = '' THEN 
			OPEN cDocumento FOR 				
				SELECT 
					NULL::integer as id_viagem_doc,
					pIdRomaneio as id_romaneio,
					vId_doc as id_documento,
					2 as tipo_documento, --Tipo manifesto
					vPeso as peso_total,	
					vVolume_cubico as volume_cubado,
					vQtd_volumes as qtd_volumes,
					vTotal_frete as total_frete,
					pData as data_saida,
					scr_manifesto.numero_manifesto::character(13) as numero_documento, 
					'MANIFESTO'::character(10) as documento,
					null::character(9) as numero_nota_fiscal,
					null::character(50) as  remetente_nome,
					null::character(50) as destinatario_nome,
					null::character(30) as cidade_destino,
					null::character(2) as uf_destino,
					vTotal_frete as total_frete_bruto,
					vPeso as peso_total_bruto,
					COALESCE(v_percentual_bc,0.00) as perc_red_bc_comissao
					
				FROM 
					scr_manifesto 
				WHERE 
					scr_manifesto.id_manifesto = vId_doc;
					
	
			RETURN NEXT cDocumento;

			
			OPEN msg FOR SELECT vResultado::text as resultado;
			RETURN NEXT msg;
		ELSE

			OPEN cDocumento FOR SELECT 1 ;
			RETURN NEXT cDocumento;

			OPEN msg FOR SELECT vResultado::text as resultado;
			RETURN NEXT msg;
		
		END IF;

		
						
	END IF;
	--
	RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

