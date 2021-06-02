-- Function: public.f_grava_itens_acerto(text, integer, text)

-- DROP FUNCTION public.f_grava_itens_acerto(text, integer, text);

CREATE OR REPLACE FUNCTION public.f_grava_itens_acerto(
    plista text,
    prelatorioviagem integer,
    pusuario text)
  RETURNS integer AS
$BODY$
DECLARE 
	pListaItens ALIAS FOR $1;
	pUsuario ALIAS FOR $2;
	vComandoSQL text;
BEGIN
	
	--IMPORTAÇÃO DE ACERTOS DA TABELA ROMANEIO
	vComandoSQL = 	'INSERT INTO scr_relatorio_viagem_romaneios(id_relatorio_viagem, id_romaneio) '
			|| 'SELECT ' 
			|| pRelatorioViagem::text 
			|| ', id_documento FROM v_acertos_relatorio_viagem WHERE chave IN (' 
			|| plista
			|| ')';

	EXECUTE vComandoSQL;

	--IMPORTAÇÃO DE ACERTOS DA TABELA ROMANEIO
	vComandoSQL = 	'INSERT INTO scr_relatorio_viagem_redespachos(id_relatorio_viagem, id_conhecimento_redespacho) '
			|| 'SELECT ' 
			|| pRelatorioViagem::text 
			|| ', id_documento FROM v_acertos_relatorio_viagem WHERE chave IN (' 
			|| plista
			|| ')';

	EXECUTE vComandoSQL;
	

	--GRAVA ID DO RELATÓRIO DE VIAGEM NO ROMANEIO DE COLETAS E ENTREGAS PARA ACERTO DE MOTORISTA E REDESPACHO
	vComandoSQL = 	'UPDATE scr_romaneios SET id_acerto = ' 
			|| pRelatorioViagem::text 
			|| ' WHERE id_romaneio IN ('
			|| 'SELECT id_romaneio FROM v_acertos_relatorio_viagem WHERE chave IN (' 
			|| plista
			|| ') AND categoria < 3)';

	EXECUTE vComandoSQL;
	
	--GRAVA ID DO RELATÓRIO DE VIAGEM NA TABELA DE CONHECIMENTO PARA REDESPACHO 
	vComandoSQL = 	'UPDATE scr_conhecimento_redespacho SET id_acerto = ' 
			|| pRelatorioViagem::text 
			|| ' WHERE id_conhecimento_redespacho IN ('
			|| 'SELECT id_documento FROM v_acertos_relatorio_viagem WHERE chave IN (' 
			|| plista
			|| ') AND categoria = 3)';

	EXECUTE vComandoSQL;

RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_grava_itens_acerto(text, integer, text)
  OWNER TO softlog_sanlorenzo;
