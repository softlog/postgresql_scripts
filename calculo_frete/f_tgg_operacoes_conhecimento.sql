-- Function: public.f_tgg_operacoes_conhecimento()

-- DROP FUNCTION public.f_tgg_operacoes_conhecimento();

CREATE OR REPLACE FUNCTION public.f_tgg_operacoes_conhecimento()
  RETURNS trigger AS
$BODY$
DECLARE
	vIdRegiaoOrigem 	integer;
	vIdRegiaoDestino 	integer;
	vTabelaFrete 		character(13); 
	vCliente 		json;
	vFornecedor		json;
	vRegioes		json;
	vCidade 		text;
	vUf 			text;	
	vNaturezaOperacao	text;
	vEmpresa		text;
	vFilial 		text;
	vOperacao		text;
	vHistorico		text;
	vUsuario		text;
	vGravaHistorico		boolean;
	vRecalculaRegiao	boolean;
	vObs	 		integer;
	vObservacoes		text;
	vFilialEmissora 	text;
	vIdUsuario		integer;
	v_id_banco_dados	integer;
	v_id_nota_fiscal_imp	integer;
	vCursor			refcursor;
	v_densidade		integer;
	v_usar_valor_presumido  integer;
	
	
BEGIN
	--Alteração em 01/04/15
	--Alteração da variavel global de ambiente que contém informação
	--  Sobre qual ação deve ser logada, quando o conhecimento foi
	--  gravado via formulário.
	-- Operações a serem realizadas antes de determinado evento

	--Alteração em 15/05/15
	--Correção do fluxo da gravação do log de atividades conhecimento.


	--Alteração em 18/05/15
	--Alteração na forma de gravar observacoes previstas na tabela de templates.
	-- Criação de uma nova coluna: observacoes_conhecimento_2

	--Alteração em 14/07/15
	-- Correção do tamanho do nome da filial_emissora 

	--Alteração em 03/09/15
	-- Definição da data de expedição a partir da data de emissao.
	-- Data de expedição começa das 8 horas mais 24 horas corridas.

	--Alteração em 05/10/15
	--Gravação dos valores rateados nas notas do CTE RE quando o mesmo é emitido no SEFAZ
	
	--Alteração em 05/07/16
	--Gravação do Usuario logado no sistema ao gerar o conhecimento.

	--Alteracao em 23/09/16 
	-- ALTERAÇÃO das Observacoes do Regime Especial 

	--Alteração em 28/09/2016
	--Permite alterar após cStat 100 apenas para CORTESIA.

	--Alteração em 26/07/2017
	--Reversão de status da Nota Fiscal Importada no cancelamento

	--Alteração em 11/09/2017
	--Calcula o peso cubado com a densidade padrao = 300

	--Alteração em 03/01/2018
	--Reversao de status da Nota Fiscal Importada no cancelamento da Minuta

	--Alteração em 24/08/2018
	--Calcular peso cubado com densidade de natureza da carga, quando esta existir;

	-- Alteração em 29/0/2018
	-- Seta tipo_doc_referenciado automaticamente para CTe	

	-- Alteracao em 16/01/2019
	-- Utilizar peso_transportado no peso cubado, quando a transportadora nao utilizar peso presumido.


	IF TG_WHEN IN ('BEFORE') THEN 

		IF TG_OP = 'INSERT' THEN
			vIdUsuario  = COALESCE(fp_get_session('pst_usuario'),'-1')::integer;
			IF vIdUsuario > -1 THEN
				NEW.usuario_inclusao = vIdUsuario;
			END IF;
		END IF; 

		IF TG_OP = 'DELETE' THEN 
			RETURN OLD;
		END IF;	

		IF TG_OP = 'UPDATE' AND NEW.cancelado = 1 THEN 
			NEW.cod_interno_frete = NULL;
			NEW.data_emissao = OLD.data_digitacao;	-- recebe a data de digitacao para cancelados para que apareçam nos filtros
		END IF;	

		IF TG_OP = 'UPDATE' THEN 

			--Grava dados da Região de Origem e Destino, caso houver
			IF 
				(CASE WHEN TG_OP = 'UPDATE' 	THEN
					COALESCE(NEW.tabele_frete,'') <> COALESCE(OLD.tabele_frete,'') OR vRecalculaRegiao
								ELSE
					NEW.tabele_frete IS NOT NULL
				END)
			THEN
				vRegioes = f_scr_retorna_regioes_origem_destino(COALESCE(NEW.calculado_de_id_cidade,0), COALESCE(NEW.calculado_ate_id_cidade,0), NEW.tabele_frete);
				NEW.id_regiao_origem 	= vRegioes->'id_regiao_origem' ;
				NEW.id_regiao_destino	= vRegioes->'id_regiao_destino';				
			END IF;


			
			SELECT valor_parametro
			INTO v_usar_valor_presumido
			FROM parametros
			WHERE UPPER(cod_parametro) = 'PST_USAR_VALOR_PRESUMIDO'
			AND cod_empresa = NEW.empresa_emitente;

			v_usar_valor_presumido = COALESCE(v_usar_valor_presumido, 1);

			
			--Grava peso cubado
			IF NEW.volume_cubico > 0 AND v_usar_valor_presumido = 1 THEN 
			
-- 				BEGIN 
-- 					SELECT densidade
-- 					INTO v_densidade
-- 					FROM scr_natureza_carga
-- 					WHERE
-- 						trim(NEW.natureza_carga) = trim(natureza_carga);
-- 						
-- 				EXCEPTION WHEN OTHERS  THEN 
-- 					v_densidade = NULL;
-- 				END;
					

				IF v_densidade IS NULL THEN 
					
					SELECT 
						tod.densidade 
					INTO 
						v_densidade
					FROM 
						scr_tabelas t
						LEFT JOIN scr_tabelas_origem_destino tod
							ON tod.id_tabela_frete = t.id_tabela_frete
					WHERE
						numero_tabela_frete = NEW.tabele_frete
						AND 	CASE 	WHEN tod.tipo_rota = 3 THEN 
									true				
								WHEN tod.ida_volta = 1 AND tod.tipo_rota = 2 THEN 
									((tod.id_origem = NEW.id_regiao_origem AND tod.id_destino = NEW.id_regiao_destino) 
										OR 
									(tod.id_origem = NEW.id_regiao_destino AND tod.id_destino = NEW.id_regiao_origem))
									
								WHEN tod.ida_volta = 0 AND tod.tipo_rota = 2 THEN
									(tod.id_origem = NEW.id_regiao_origem AND tod.id_destino = NEW.id_regiao_destino)

								WHEN tod.ida_volta = 1 AND tod.tipo_rota = 1 THEN
									((tod.id_origem = NEW.calculado_de_id_cidade AND tod.id_destino = NEW.calculado_ate_id_cidade) 
										OR 
									(tod.id_origem = NEW.calculado_ate_id_cidade AND tod.id_destino = NEW.calculado_de_id_cidade))							
									
								WHEN NOT tod.ida_volta = 0 AND tod.tipo_rota = 1 THEN 
									(tod.id_origem = NEW.calculado_de_id_cidade AND tod.id_destino = NEW.calculado_ate_id_cidade)

								WHEN tod.tipo_rota = 0 THEN 
									tod.id_destino = NEW.destinatario_id
								ELSE
									true
							END;
				END IF;

				RAISE NOTICE 'Densidade % ', v_densidade;				
				
				NEW.peso_cubado = NEW.volume_cubico * v_densidade;
			END IF;
			IF v_usar_valor_presumido = 0 THEN 
				NEW.peso_cubado = NEW.peso_transportado;
			END IF;
		END IF;

		IF TG_OP = 'UPDATE' THEN 

			
			IF NEW.cstat = '100' THEN 				

				--Realiza rateio quando o cte foi autorizado no Sefaz
				--Se cstat é igual a 100 e antes não era 
				IF COALESCE(OLD.cstat,'') <> '100' THEN 
					--Grava valores rateado nas notas do CTe regime especial
					--Os valores rateados já estão calculados nas notas 
					-- das Minutas de RE que compõem o CTe
					IF NEW.regime_especial_mg = 1 AND NEW.tipo_documento = 1 THEN 
						UPDATE  scr_conhecimento_notas_fiscais nf SET
							total_frete_nf   =  nf2.total_frete_nf,
							total_frete_prod  = nf2.total_frete_prod
						FROM	scr_conhecimento_notas_fiscais nf2
							LEFT JOIN scr_conhecimento c
								ON c.id_conhecimento = nf2.id_conhecimento
							LEFT JOIN scr_conhecimento m
								ON m.id_conhecimento = c.id_conhecimento_principal
						WHERE 	nf.id_conhecimento = c.id_conhecimento_principal
								AND nf2.numero_nota_fiscal = nf.numero_nota_fiscal
								AND m.id_conhecimento = NEW.id_conhecimento;
					END IF;
					--Grava valores rateado nas notas da Minuta regime especial
					--Os valores rateados já estão calculados nas notas 
					-- das Minutas de RE que compõem o CTe
					IF NEW.regime_especial_mg = 1 AND NEW.tipo_documento = 2 THEN 
						UPDATE  scr_conhecimento_notas_fiscais nf SET
							total_frete_nf   =  nf2.total_frete_nf,
							total_frete_prod  = nf2.total_frete_prod
						FROM	scr_conhecimento_notas_fiscais nf2
							LEFT JOIN scr_conhecimento c
								ON c.id_conhecimento = nf2.id_conhecimento
							LEFT JOIN scr_conhecimento m
								ON m.id_conhecimento = c.id_conhecimento_principal
						WHERE 	nf.id_conhecimento = c.id_conhecimento_principal
								AND nf2.numero_nota_fiscal = nf.numero_nota_fiscal
								AND m.id_conhecimento = NEW.id_conhecimento;
					END IF;					
				END IF;

				--Se não houve alteração de pagador aborta execução da trigger e não seja cortesia
				IF OLD.consig_red_cnpj = NEW.consig_red_cnpj  AND NEW.tipo_transporte NOT IN (4) THEN 
					RETURN NEW;
				END IF;
			END IF;

			
			
		END IF;

		-- Operações a serem realizadas no Update
		IF TG_OP IN ('INSERT','UPDATE') THEN

			-- Define a data de expedição
			IF NEW.data_emissao IS NOT NULL THEN
				IF extract('hour' from NEW.data_emissao) < 8 THEN 
					NEW.data_expedicao =  (NEW.data_emissao - INTERVAL'23 HOURS 59 MINUTES 59 SECONDS')::date;
				ELSE
					NEW.data_expedicao = NEW.data_emissao::date;
				END IF;
			END IF;

			-- Seta tipo_doc_referenciado automaticamente para CTe
			IF NEW.conhecimento_origem is not null THEN
				NEW.tipo_doc_referenciado = 2;
			END IF;
			--Seta variavel que recalcula região como false
			vRecalculaRegiao = false;


			
			--Grava dados do Remetente
-- 			IF 
-- 				(CASE WHEN TG_OP = 'UPDATE' 	THEN  
-- 					COALESCE(NEW.remetente_cnpj,'') <> COALESCE(OLD.remetente_cnpj,'') 
-- 								ELSE 
-- 					NEW.remetente_cnpj IS NOT NULL
-- 				END)
-- 
-- 			THEN 
				vCliente = f_scr_json_cliente(trim(NEW.remetente_cnpj));

				NEW.remetente_id 		= vCliente->>'codigo_cliente';
				NEW.remetente_nome 		= vCliente->>'nome_cliente';
				NEW.remetente_id_endereco 	= vCliente->>'id_endereco';
				NEW.remetente_endereco 		= left(vCliente->>'endereco',50);
				NEW.remetente_numero 		= vCliente->>'numero';
				NEW.remetente_bairro 		= vCliente->>'bairro';
				NEW.remetente_cidade 		= vCliente->>'cidade';
				NEW.remetente_uf 		= vCliente->>'estado';
				NEW.remetente_cep 		= vCliente->>'cep';	
				NEW.remetente_ie 		= vCliente->>'inscricao_estadual';
				NEW.remetente_ddd 		= vCliente->>'ddd';
				NEW.remetente_telefone  = vCliente->>'telefone';	
				


				
-- 			END IF;	
					
			--Grava dados do Destinatario
-- 			IF 
-- 				(CASE WHEN TG_OP = 'UPDATE' 	THEN
-- 					COALESCE(NEW.destinatario_cnpj,'') <> COALESCE(OLD.destinatario_cnpj,'') 
-- 								ELSE
-- 					NEW.destinatario_cnpj IS NOT NULL
-- 				END)
-- 			THEN 
				vCliente = f_scr_json_cliente(trim(NEW.destinatario_cnpj));
				
				NEW.destinatario_id 		= vCliente->>'codigo_cliente';
				NEW.destinatario_nome 		= vCliente->>'nome_cliente';
				NEW.destinatario_id_endereco 	= vCliente->>'id_endereco';
				NEW.destinatario_endereco 	= left(vCliente->>'endereco',50);
				NEW.destinatario_numero 	= vCliente->>'numero';
				NEW.destinatario_bairro 	= vCliente->>'bairro';
				NEW.destinatario_cidade 	= vCliente->>'cidade';
				NEW.destinatario_uf 		= vCliente->>'estado';
				NEW.destinatario_cep 		= vCliente->>'cep';	
				NEW.destinatario_ie 		= vCliente->>'inscricao_estadual';
				NEW.destinatario_ddd 		= vCliente->>'ddd';
				NEW.destinatario_telefone  	= vCliente->>'telefone';					
-- 			END IF;

			--Grava dados do Consignatario
-- 			IF 
-- 				(CASE WHEN TG_OP = 'UPDATE' 	THEN
-- 					COALESCE(NEW.consig_red_cnpj,'') <> COALESCE(OLD.consig_red_cnpj,'') 
-- 								ELSE
-- 					NEW.consig_red_cnpj IS NOT NULL
-- 				END)
-- 			THEN
			
				vCliente = f_scr_json_cliente(trim(NEW.consig_red_cnpj));

				--PERFORM f_debug('Código do CLiente Pagador',vCliente->>'codigo_cliente'::text);
				
				NEW.consig_red_id 	= vCliente->>'codigo_cliente';
				--PERFORM f_debug('Código NEW.consig_red_id',NEW.consig_red_id::text);
				
				NEW.consig_red_nome 	= vCliente->>'nome_cliente';
				NEW.consig_red_id_endereco = vCliente->>'id_endereco';
				NEW.consig_red_endereco = left(vCliente->>'endereco',50);
				NEW.consig_red_numero 	= vCliente->>'numero';
				NEW.consig_red_bairro 	= vCliente->>'bairro';
				NEW.consig_red_cidade 	= vCliente->>'cidade';
				NEW.consig_red_uf 	= vCliente->>'estado';
				NEW.consig_red_cep 	= vCliente->>'cep';	
				NEW.consig_red_ie 	= vCliente->>'inscricao_estadual';
				NEW.consig_red_ddd 	= vCliente->>'ddd';
				NEW.consig_red_telefone = vCliente->>'telefone';

				
				NEW.responsavel_seguro  = COALESCE((vCliente->>'responsavel_seguro')::integer,5);

				--Mantido para fins de compatibilidade (obsoleto)
				NEW.pagador_id  	= vCliente->>'codigo_cliente';
				NEW.pagador_cnpj	= NEW.consig_red_cnpj; 	


				--Manter compatibilidade com a estrutura antiga.
				IF NEW.pagador_cnpj NOT IN (NEW.remetente_cnpj,NEW.destinatario_cnpj) THEN 
					NEW.consig_red = 1;
				END IF ;

				-- Definição de expedidor
-- 				IF NEW.expedidor_cnpj is NULL THEN
-- 					IF NEW.remetente_cnpj <> NEW.consig_red_cnpj AND new.destinatario_cnpj <> NEW.consig_red_cnpj THEN
-- 						 NEW.expedidor_cnpj = NEW.consig_red_cnpj ;
-- 					END IF;
-- 				END IF;
				
				IF NEW.frete_cif_fob = 1 THEN 
					NEW.tipo_frete = 'CCC'; 
				ELSE 
					IF NEW.frete_cif_fob = 1 THEN 
						IF NEW.avista = 1 THEN 
							NEW.tipo_frete = 'CIF';
						ELSE
							NEW.tipo_frete = 'CCR';
						END IF;
					ELSE -- frete_cif_fob = 2
						IF NEW.avista = 1 THEN
							NEW.tipo_frete = 'FOB';
						ELSE
							NEW.tipo_frete = 'CCD';
						END IF;
					END IF;
				END IF;
							
-- 			END IF;
			
			--Grava dados do Redespacho
-- 			IF 
-- 				(CASE WHEN TG_OP = 'UPDATE' 	THEN
-- 					COALESCE(NEW.redespachador_cnpj,'') <> COALESCE(OLD.redespachador_cnpj,'') 
-- 								ELSE
-- 					NEW.redespachador_cnpj IS NOT NULL
-- 				END)
-- 			THEN
				vFornecedor = f_scr_json_fornecedor(trim(NEW.redespachador_cnpj));
								
				NEW.redespachador_id 		= vFornecedor->>'id_fornecedor';
				NEW.redespachador_nome 		= vFornecedor->>'nome_cliente';
				NEW.redespachador_endereco 	= left(vFornecedor->>'endereco',50);
				NEW.redespachador_numero 	= vFornecedor->>'numero';
				NEW.redespachador_bairro 	= vFornecedor->>'bairro';
				NEW.redespachador_cidade 	= vFornecedor->>'cidade';
				NEW.redespachador_uf 		= vFornecedor->>'estado';
				NEW.redespachador_cep 		= vFornecedor->>'cep';	
				NEW.redespachador_ie 		= vFornecedor->>'inscricao_estadual';
				NEW.redespachador_ddd 		= vFornecedor->>'ddd';
				NEW.redespachador_telefone 	= vFornecedor->>'telefone';
				NEW.redespachador_codigo_pais	= vFornecedor->>'codigo_pais';

				
-- 			END IF;

			--Grava dados da Cidade de Origem
			IF 
				(CASE WHEN TG_OP = 'UPDATE' 	THEN
					COALESCE(NEW.calculado_de_id_cidade,0) <> COALESCE(OLD.calculado_de_id_cidade,0)
								ELSE
					NEW.calculado_de_id_cidade IS NOT NULL
				END)
				
			THEN
				SELECT nome_cidade, uf 	INTO vCidade, vUf FROM cidades WHERE id_cidade = NEW.calculado_de_id_cidade;
				
				NEW.calculado_de_cidade = vCidade;
				NEW.calculado_de_uf	= vUf;
				vRecalculaRegiao = true;
			END IF;
			
			--Grava dados da Cidade de Destino			
			IF 
				(CASE WHEN TG_OP = 'UPDATE' 	THEN
					COALESCE(NEW.calculado_ate_id_cidade,0) <> COALESCE(OLD.calculado_ate_id_cidade,0) 
								ELSE
					NEW.calculado_ate_id_cidade IS NOT NULL
				END)
			THEN
				SELECT nome_cidade, uf 	INTO vCidade, vUf FROM cidades WHERE id_cidade = NEW.calculado_ate_id_cidade;				
				NEW.calculado_ate_cidade = vCidade;
				NEW.calculado_ate_uf	 = vUf;
				vRecalculaRegiao = true;
			END IF;			





	
			

			--Grava dados da natureza da operação
			IF 
				(CASE WHEN TG_OP = 'UPDATE' 	THEN				
					COALESCE(NEW.cod_operacao_fiscal,'') <> COALESCE(NEW.cod_operacao_fiscal,'') 
								ELSE
					NEW.cod_operacao_fiscal IS NOT NULL
				END)
			THEN
				SELECT descricao_cfop INTO vNaturezaOperacao FROM cfop WHERE codigo_cfop = NEW.cod_operacao_fiscal;
				NEW.natureza_operacao 	=  left(vNaturezaOperacao,20);		
			END IF;			
			
			--Grava dados da empresa e filial emitente
			IF NEW.empresa_emitente IS NULL THEN
				NEW.empresa_emitente = fp_get_session('pst_cod_empresa');				 
			END IF;
			
			IF NEW.filial_emitente IS NULL THEN 
				NEW.filial_emitente = fp_get_session('pst_filial');
			END IF;

			--Grava observações se o modal for aéreo
			IF NEW.modal = 2 THEN

				SELECT nome_descritivo
				INTO vFilialEmissora
				FROM filial 
				WHERE codigo_filial = NEW.filial_emitente AND codigo_empresa = NEW.empresa_emitente;
				
				NEW.ident_emissor_aereo 	= left(vFilialEmissora,20);
				NEW.classe_tarifa_aereo 	= 'G';
				NEW.valor_tarifa_aereo  	= 1.00;
				NEW.dimensao_aereo 		= '1X1X1';
				NEW.data_previsao_entrega 	= NEW.data_digitacao::date + 4;
				--SELECT FROM scr_conhecimento LIMIT 1				
			ELSE
				NEW.ident_emissor_aereo 	= NULL;
				NEW.classe_tarifa_aereo 	= NULL;
				NEW.valor_tarifa_aereo  	= NULL;
				NEW.dimensao_aereo 		= NULL;
				-- NEW.data_previsao_entrega 	= NULL;
			END IF;			


			
			--Grava observações se o conhecimento for regime especial de minas gerais/Customizacao DNG
			--TODO: Parametrizar estas observacoes no banco de dados
			IF NEW.regime_especial_mg = 1 AND NEW.tipo_documento = 1 AND current_database() = 'softlog_dng' THEN 
				IF position('Emissão global e diária autorizada pelo Regime Especial/PTA' in NEW.observacoes_conhecimento) < 1 THEN 
					NEW.observacoes_conhecimento = COALESCE(NEW.observacoes_conhecimento) || ' /Emissão global e diária autorizada pelo Regime Especial/PTA nº 45.000007071-12 - SEF/MG referente a '  
					|| to_char(NEW.data_cte_re,'DD/MM/YYYY') ;
				END IF;				
			END IF;

			--Grava observações se o conhecimento for regime especial de minas gerais/Customizacao TRANSMED
			--TODO: Parametrizar estas observacoes no banco de dados
			IF NEW.regime_especial_mg = 1 AND NEW.tipo_documento = 1 AND current_database() = 'softlog_transmed' THEN 
				IF position('Dispensa de emissão de CTRC a cada prestacao - Emissão posterior - Regime Especial/PTA' in NEW.observacoes_conhecimento) < 1 THEN 
					NEW.observacoes_conhecimento = COALESCE(NEW.observacoes_conhecimento) || ' /Dispensa de emissão de CTRC a cada prestacao - Emissão posterior - Regime Especial/PTA nr. 45.000005805-46, Delegacia Fiscal de Contagem. Data:'   
					|| to_char(NEW.data_cte_re,'DD/MM/YYYY');
				END IF;				
			END IF;

			--Grava observações se o conhecimento for regime especial de Sao Paulo/Customizacao MEDILOG
			--TODO: Parametrizar estas observacoes no banco de dados
			IF NEW.regime_especial_mg = 1 AND NEW.tipo_documento = 1 AND NEW.calculado_ate_uf = 'SP' AND NEW.calculado_de_uf = 'SP' THEN 
				IF position('PROCEDIMENTO EFETUADO NOS TERMOS DA PORTARIA CAT 121/2013 DE 29/11/13' in COALESCE(NEW.observacoes_conhecimento,'')) < 1 THEN 
					NEW.observacoes_conhecimento = COALESCE(NEW.observacoes_conhecimento,'') || 'PROCEDIMENTO EFETUADO NOS TERMOS DA PORTARIA CAT 121/2013 DE 29/11/13';
				END IF;				
			END IF;

			
			IF NEW.cod_interno_frete IS NOT NULL AND TG_OP = 'INSERT' THEN 
				NEW.observacoes_conhecimento = COALESCE(NEW.observacoes_conhecimento,'') || ' /Ordem de Carregamento: ' || NEW.cod_interno_frete;
			END IF;	

			--Grava observações geradas através de template
			NEW.observacoes_conhecimento_2 = f_scr_set_obs_ctrc_2(row_to_json(NEW));
			
		END IF;	
		
		RETURN NEW;		
	END IF;

	-- Operações a serem realizadas após determinado evento
	IF TG_WHEN = 'AFTER' THEN 

		IF TG_OP = 'DELETE' THEN 
			RETURN NULL;
		END IF;	

		IF TG_OP = 'UPDATE' AND NEW.cancelado = 1 THEN 

			--Obtem o id do banco de dados
			SELECT id_string_conexao 
			INTO v_id_banco_dados 
			FROM string_conexoes 
			WHERE trim(banco_dados) = trim(current_database());

			DELETE FROM 
				fila_frete_automatico 
			WHERE 
				id_conhecimento = NEW.id_conhecimento 
				AND id_banco_dados = v_id_banco_dados;						


			--Reseta o status da nota fiscal importada 

			--CTe normal e Minuta normal
			IF NEW.tipo_documento IN (1,2) AND NEW.regime_especial_mg = 0 THEN 
				
				UPDATE scr_notas_fiscais_imp SET
					id_conhecimento = NULL, 
					status = 0
				WHERE
					id_conhecimento = NEW.id_conhecimento;			
				
			END IF;	

			--Cte Re
			IF NEW.tipo_documento IN (1, 2) AND NEW.regime_especial_mg = 1 THEN 				
				--muda o status da nota
				UPDATE scr_notas_fiscais_imp SET
					id_conhecimento = NULL, 
					status = 0
				WHERE
					id_conhecimento = NEW.id_conhecimento;

				--Cancela as minutas de re
				UPDATE scr_conhecimento SET 
					cancelado = 1,
					data_cancelamento = now()
				WHERE
					id_conhecimento_principal = NEW.id_conhecimento;
				
			END IF;

			--Minuta Re
			IF NEW.tipo_documento = 3 THEN 
				RAISE NOTICE 'Cancelando nota fiscal de %',NEW.id_conhecimento;
				UPDATE scr_notas_fiscais_imp SET
					id_conhecimento = NULL,
					id_minuta_re = NULL, 
					status = 0
				WHERE
					id_minuta_re = NEW.id_conhecimento;
			END IF;				
			
		END IF;


		-- Grava log de ativades   
		vUsuario  = fp_get_session('pst_login');

		--Verifica se tem alguma operação realizada no form de digitação do conhecimento
		vOperacao = fp_get_session('ATIVIDADE_EXECUTADA');

		PERFORM fp_set_session('ATIVIDADE_EXECUTADA',NULL);
		
		IF vOperacao IS NOT NULL THEN 
			CASE 	WHEN vOperacao = 'NOVO' 	THEN 
					vHistorico = 'DIGITAÇÃO DO CTRC';
				
				ELSE
					vHistorico = 'CTRC ALTERADO';


			END CASE;			

			INSERT INTO scr_conhecimento_log_atividades(id_conhecimento,data_hora, atividade_executada,usuario)
			VALUES (NEW.id_conhecimento, now(), vHistorico, vUsuario);

			--Quando a operação for setada por alguma parte do sistema, 
			--executar a rotina que grava observações fiscais e outras das mensagens
			--vObs = f_scr_set_obs_ctrc(row_to_json(NEW));

		END IF;	
		
	
		IF NEW.cstat = '100' THEN 
			RETURN NULL;
		END IF;		

		-- Gravação das observações 


		RETURN NULL;
	END IF;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

