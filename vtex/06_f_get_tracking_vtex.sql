--SELECT fd_modelo_funcao()
--SELECT fd_get_tracking_vtex(p_id_fila integer)

CREATE OR REPLACE FUNCTION f_get_tracking_vtex(p_id_fila integer)
  RETURNS integer AS
$BODY$
DECLARE
        
BEGIN
	WITH t AS (
		SELECT 
			fo.id,
			(left(nf.numero_pedido_nf,14) || '-' || right(nf.numero_pedido_nf,2)) as numero_pedido_nf,
			ltrim(nf.numero_nota_fiscal,'0') as numero_nota_fiscal,
			fo.id_ocorrencia,
			CASE WHEN fo.id_ocorrencia = 0 THEN origem.nome_cidade ELSE destino.nome_cidade END::text as cidade,
			CASE WHEN fo.id_ocorrencia = 0 THEN origem.uf ELSE destino.uf END::text as uf,
			CASE WHEN fo.id_ocorrencia IN (1,2) THEN 'true' ELSE 'false' END::text as entregue,
			initcap(edi.ocorrencia) as descricao,
			nfo.data_ocorrencia
		FROM 
			fila_ocorrencias_pedido_vtex fo
			LEFT JOIN scr_conhecimento_ocorrencias_nf nfo
				ON nfo.id_conhecimento_ocorrencia_nf = fo.id_ocorrencia_nf
			LEFT JOIN scr_conhecimento_notas_fiscais nf
				ON nf.id_conhecimento_notas_fiscais = nfo.id_conhecimento_notas_fiscais
			LEFT JOIN scr_conhecimento c
				ON nf.id_conhecimento = c.id_conhecimento
			LEFT JOIN cidades origem
				ON origem.id_cidade = c.calculado_de_id_cidade
			LEFT JOIN cidades destino
				ON destino.id_cidade = c.calculado_ate_id_cidade
			LEFT JOIN scr_ocorrencia_edi edi
				ON edi.codigo_edi = fo.id_ocorrencia
		WHERE
			fo.id = p_id_fila
	) 
	, ocorrencia AS (
		SELECT * FROM scr_ocorrencia_edi
	);
        
	RETURN 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

  SELECT 