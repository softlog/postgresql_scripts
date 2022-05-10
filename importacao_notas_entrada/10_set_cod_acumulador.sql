CREATE OR REPLACE FUNCTION f_set_cod_acum_cad_produtos(limite integer)
  RETURNS integer AS
$BODY$
DECLARE
        
        id_max integer;
        id_ini integer;
        id_fim integer;
BEGIN

	SELECT MAX(id)
	INTO id_max
	FROM cad_produtos_for
		LEFT JOIN cad_empresa
			ON cad_empresa.codigo = cad_produtos_for.fk_cad_empresa_codigo;
	WHERE
		tipo_empresa <> 'PJ';


	id_ini = 1;
	id_fim = id_ini + limite;
	
        LOOP 
		RAISE NOTICE 'Atualizando CAD PRODUTOS FOR de % ate %', id_ini, id_fim-1;
		
		UPDATE cad_produtos_for SET id = id WHERE id >= id_ini AND id < id_fim;
		
		id_ini = id_fim;
		id_fim = id_ini + limite;
        
		EXIT WHEN NOT (id_fim - limite) > id_max;

	END LOOP;	
	RETURN id_max;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;