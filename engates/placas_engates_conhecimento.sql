/*
	Banco da SanLorenzo
	O objetivo é ter um select com id_conhecimento, placa_tracao, placa_engate, ordem da placa_engate
	Exemplo
	4105	FDR4H83	OIP0941	1
	4105	FDR4H83 NJV0H03 2
	
*/
	WITH    cur_placa AS (
		SELECT   scr_conhecimento.placa_veiculo AS tracao
			,scr_conhecimento.id_conhecimento
			,scr_conhecimento.data_viagem
			,f_retorna_placas_engates(scr_conhecimento.placa_veiculo,scr_conhecimento.data_viagem) AS placas_engates
			,trim(UNNEST(string_to_array(
			       f_retorna_placas_engates(scr_conhecimento.placa_veiculo,scr_conhecimento.data_viagem),','))
			) AS placa_engate
		FROM    scr_conhecimento
		WHERE   cancelado <> 1
		AND     PLACA_VEICULO = 'FDR4H83'
		ORDER BY id_conhecimento DESC        
        )        
        SELECT  
		ROW_NUMBER() OVER (PARTITION BY id_conhecimento, tracao ORDER BY id_conhecimento, tracao) AS ordem
		,id_conhecimento
                ,tracao
                ,placa_engate
                ,data_viagem                
                		
        FROM    cur_placa
        WHERE   TRIM(cur_placa.placa_engate) <> ''
        AND     cur_placa.placa_engate IS NOT NULL
        ORDER BY id_conhecimento, ordem, tracao, placa_engate
