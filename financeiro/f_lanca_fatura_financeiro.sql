-- Function: public.f_lanca_fatura_financeiro()

-- DROP FUNCTION public.f_lanca_fatura_financeiro();

CREATE OR REPLACE FUNCTION public.f_lanca_fatura_financeiro()
  RETURNS trigger AS
$BODY$
DECLARE
	vCursor refcursor;
	vTabela text;	
	vCampo text;
	
	vCommand text;	
	vHistorico text;
	vNumeroDocumento character(10);
	
	vLancamentoContaPagar integer;	
	vIdLancamento integer;	

	vTipoOperacao integer; -- 1 --> Insere, 2 --> Update, 3 --> Deleta
BEGIN	
	
	--Se a fatura estava baixada, o portador era Carteira e Não é mais
	IF NEW.portador <> 2 AND OLD.portador = 2 AND OLD.status = 2 THEN 
		NEW.id_caixa = NULL;		
		NEW.tabela_credito_sistema = NULL;
		NEW.numero_lancamento = NULL;
		NEW.especie_pagamento = NULL;
		NEW.numero_doc_pagamento = NULL;
		NEW.data_cheque = NULL;
				
		vCommand = 'DELETE FROM ' || OLD.tabela_credito_sistema || ' WHERE numero_lancamento = ' || OLD.numero_lancamento::text;
		EXECUTE vCommand;
		vTipoOperacao = 3;		
	END IF; 

	
	--Se o portador é carteira faz lançamento nas contas de crédito
	IF NEW.portador = 2 THEN 		
		-- A fatura foi baixada		
		IF OLD.status = 1 AND NEW.status = 2 THEN
			vTipoOperacao = 1;
		END IF;

		-- A fatura já estava baixada e foi alterada 
		IF (OLD.status = 2 AND NEW.status = 2)  THEN
			IF OLD.tabela_credito_sistema IS NOT NULL THEN 
				IF 	OLD.conta_credito <> NEW.conta_credito 
					OR OLD.id_caixa <> NEW.id_caixa  
					OR (NEW.fatura_conta_corrente <> OLD.fatura_conta_corrente) 
					OR (NEW.fatura_banco) <> (OLD.fatura_banco)
				THEN
					vCommand = 'DELETE FROM ' || OLD.tabela_credito_sistema || ' WHERE numero_lancamento = ' || OLD.numero_lancamento::text;
					EXECUTE vCommand;
					vTipoOperacao = 1;
				ELSE 
					vTipoOperacao = 2;
				END IF;			
			ELSE 
				vTipoOperacao = 1;
			END IF;	
		END IF;
	
		-- A fatura já estava baixada e foi revertida
		IF (OLD.status = 2 AND NEW.status = 1) THEN 
		
			NEW.id_caixa = NULL;
			NEW.fatura_banco = NULL;
			NEW.fatura_agencia = NULL;
			NEW.fatura_conta_corrente = NULL;
			NEW.tabela_credito_sistema = NULL;			
			NEW.numero_lancamento = NULL;
			NEW.especie_pagamento = NULL;
			NEW.numero_doc_pagamento = NULL;
			NEW.data_cheque = NULL;
						
			vCommand = 'DELETE FROM ' || OLD.tabela_credito_sistema || ' WHERE numero_lancamento = ' || OLD.numero_lancamento::text;
			EXECUTE vCommand;
			vTipoOperacao = 3;
			
		END IF;
		
		--Insere um novo registro
		IF  vTipoOperacao = 1 THEN 
			--Lança no Contas Corrente		
			IF NEW.conta_credito = 1 THEN
				OPEN vCursor FOR SELECT tabela_conta 
						 FROM 	scf_contas_correntes 
							LEFT JOIN scf_agencias_bancarias 
								ON scf_contas_correntes.id_agencia = scf_agencias_bancarias.id_agencia::numeric
							LEFT JOIN banco 
								ON scf_agencias_bancarias.id_banco = banco.id_banco::numeric
						 WHERE 	
							numero_conta = NEW.fatura_conta_corrente 
							AND scf_agencias_bancarias.numero_agencia = NEW.fatura_agencia
							AND banco.numero_banco = NEW.fatura_banco;
			ELSE
				OPEN vCursor FOR SELECT tabela_conta 
						 FROM 	scf_caixas 
						 WHERE 	id_caixa = NEW.id_caixa;
			END IF;

			
			FETCH vCursor INTO vTabela;

			CLOSE vCursor;
				
			vHistorico = 'CRÉDITO REF. FATURA Nº ' || NEW.numero_fatura; --|| '-' || NEW.fatura_nome;

			--SELECT * FROM scf_conta_corrente_001    LIMIT 1
			--SELECT * FROM scf_conta_caixa_015 WHERE numero_lancamento = 3183	
			IF NEW.conta_credito = 1 THEN 		
				vCommand = 'INSERT INTO ' || trim(vTabela) || '(
										data_lancamento, 
										data_movimento, 
										data_compensacao, 
										historico, 
										tipo_movimento, 
										valor, 
										numero_documento, 
										origem_transacao, 
										id_usuario_inclusao, 
										arq_lancamento_externo, 
										numero_lancamento_externo
									)
									VALUES (' || '''' ||
										now()::text 			|| ''',''' ||
										NEW.data_pagamento::text 	|| ''',''' ||
										NEW.data_pagamento::text 	|| ''',''' ||
										TRIM(vHistorico)		|| ''',''' ||
										'C'				|| ''',' ||
										NEW.valor_recebido::text	|| ',''' ||
										RIGHT(NEW.numero_fatura,10)::text || ''',''' ||
										'F'				|| ''',' ||
										NEW.id_usuario_operacao::text 	|| ',''' ||
										'scr_faturamento'		|| ''',' ||
										NEW.id_faturamento::text	||						
									') RETURNING numero_lancamento';
			ELSE
								vCommand = 'INSERT INTO ' || trim(vTabela) || '(
									data_lancamento, 
									data_movimento, 
									historico, 
									tipo_movimento, 
									valor, 
									numero_documento, 
									origem_transacao, 
									id_usuario_inclusao, 
									arq_lancamento_externo, 
									numero_lancamento_externo
								)
								VALUES (' || '''' ||
									now()::text 			|| ''',''' ||
									NEW.data_pagamento::text 	|| ''',''' ||
									TRIM(vHistorico)		|| ''',''' ||
									'C'				|| ''',' ||
									NEW.valor_recebido::text	|| ',''' ||
									RIGHT(NEW.numero_fatura,10)::text || ''',''' ||
									'F'				|| ''',' ||
									NEW.id_usuario_operacao::text 	|| ',''' ||
									'scr_faturamento'		|| ''',' ||
									NEW.id_faturamento::text	||						
								') RETURNING numero_lancamento';

			END IF;

			OPEN vCursor FOR EXECUTE vCommand;
			
			FETCH vCursor INTO vIdLancamento;

			CLOSE vCursor;
				
			NEW.numero_lancamento = vIdLancamento;
			NEW.tabela_credito_sistema = vTabela;								 
			
		END IF;

		--Atualiza Registro
		IF  vTipoOperacao = 2 THEN 
			vCommand = 	'UPDATE ' || trim(NEW.tabela_credito_sistema) || ' '
					'SET ' ||
						'data_movimento = ''' 	|| NEW.data_pagamento::text 	|| ''', ' ||
						'data_compensacao = ''' 	|| NEW.data_pagamento::text 	|| ''', ' ||
						'valor = ' 		|| NEW.valor_recebido::text	|| ', '   ||
						'id_usuario_alteracao = '||NEW.id_usuario_operacao::text || ',' ||
						'data_ultima_modificacao = ''' || NOW()::text || ''' ' 
					'WHERE numero_lancamento = '    ||  NEW.numero_lancamento::text; 
					
			--PERFORM f_debug('Comando ',vCommand);
			
			EXECUTE vCommand;			
		END IF;
	END IF;

	--PROCESSAMENTO AUTOMATICO DE ARQUIVO DE RETORNO
-- 	IF NEW.baixa_automatica = 1 AND OLD.baixa_automatica = 0 THEN 
-- 		OPEN vCursor FOR SELECT tabela_conta 
-- 						 FROM 	scf_contas_correntes 
-- 							LEFT JOIN scf_agencias_bancarias 
-- 								ON scf_contas_correntes.id_agencia = scf_agencias_bancarias.id_agencia::numeric
-- 							LEFT JOIN banco 
-- 								ON scf_agencias_bancarias.id_banco = banco.id_banco::numeric
-- 						WHERE 	
-- 							numero_conta = NEW.fatura_conta_corrente 
-- 							AND scf_agencias_bancarias.numero_agencia = NEW.fatura_agencia
-- 							AND banco.numero_banco = NEW.fatura_banco;
-- 		
-- 		FETCH vCursor INTO vTabela;
-- 
-- 		CLOSE vCursor;	
-- 
-- 		vHistorico = 'LIQUIDACAO AUTOMATICA ARQ.RETORNO ';
-- 
-- 		--SELECT * FROM scf_conta_caixa_015 WHERE numero_lancamento = 3183			
-- 		vCommand = 'SELECT numero_lancamento FROM ' || trim(vTabela) || ' WHERE data_movimento = ''' || NEW.data_credito::text 	|| ''' AND origem_transacao = ''A'' ';
-- 							
-- 		OPEN vCursor FOR EXECUTE vCommand;
-- 
-- 		FETCH vCursor INTO vIdLancamento;
-- 
-- 		IF FOUND THEN 
-- 			CLOSE vCursor;
-- 			vCommand = 	'UPDATE ' || trim(vTabela) || ' '
-- 					'SET ' ||
-- 						'valor = valor + ' 		|| NEW.valor_recebido::text	|| ' '   ||
-- 					'WHERE numero_lancamento = '    ||  vIdLancamento::text || ' RETURNING numero_lancamento'; 
-- 		
-- 		
-- 		ELSE
-- 			CLOSE vCursor;
-- 			vCommand = 'INSERT INTO ' || trim(vTabela) || '(
-- 									data_lancamento, 
-- 									data_movimento, 
-- 									historico, 
-- 									tipo_movimento, 
-- 									valor, 
-- 									numero_documento, 
-- 									origem_transacao, 
-- 									id_usuario_inclusao, 
-- 									arq_lancamento_externo, 
-- 									numero_lancamento_externo
-- 								)
-- 								VALUES (' || '''' ||
-- 									now()::text 			|| ''',''' ||
-- 									NEW.data_credito::text 	|| ''',''' ||
-- 									TRIM(vHistorico)		|| ''',''' ||
-- 									'C'				|| ''',' ||
-- 									NEW.valor_recebido::text	|| ',''' ||
-- 									'SEM NUMERO'::text || ''',''' ||
-- 									'A'				|| ''',' ||
-- 									1::text 	|| ',''' ||
-- 									'scr_faturamento'		|| ''',' ||
-- 									' NULL '			||						
-- 								') RETURNING numero_lancamento';			
-- 
-- 		END IF;
-- 
-- 		OPEN vCursor FOR EXECUTE vCommand;	
-- 
-- 		FETCH vCursor INTO vIdLancamento;
-- 		
-- 		CLOSE vCursor;
-- 				
-- 		NEW.numero_lancamento = vIdLancamento;
-- 		NEW.tabela_credito_sistema = vTabela;								 
-- 	END IF ;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_lanca_fatura_financeiro()
  OWNER TO softlog_vazio;
