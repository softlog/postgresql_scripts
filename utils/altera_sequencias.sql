WITH t AS (
	SELECT 
		('WITH t AS (

			SELECT last_value, ''' || c.relname || '''::text as sequencia FROM ' || c.relname  || ' 
		) 
		SELECT ''ALTER SEQUENCE ''|| sequencia || '' RESTART WITH '' || (last_value + 1000000)::text || '';'' FROM t;') as cmd
		
	FROM 
		pg_class c 
	WHERE c.relkind = 'S'
) SELECT f_exec_cmd(cmd) FROM t



UPDATE anexos_id_anexos_seq SET last_value = last_value + 1000 
SELECT * FROM anexos_id_anexo_seq

WITH t AS (

		SELECT last_value, 'aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq'::text as sequencia FROM aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq 
	) SELECT 'ALTER SEQUENCE ' || sequencia || ' RESTART WITH ' || (last_value + 100000)::text || ';' FROM t;

WITH t AS (

		SELECT last_value, 'aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq'::text as sequencia FROM aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq 
	) SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 100000)::text || ';' FROM t


ALTER SEQUENCE aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq RESTART WITH 100001;	



WITH t AS (

		SELECT last_value, 'aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq'::text as sequencia FROM aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq 
	)
	 SELECT 'ALTER SEQUENCE '|| sequencia || ' RESTART WITH ' || (last_value + 1000000)::text || ';' FROM t;



SELECT * FROM aer_tbl_servicos_cia_aerea_id_servico_cia_aerea_seq