CREATE OR REPLACE FUNCTION f_tgg_scr_nf_protocolo()
  RETURNS trigger AS
$BODY$
DECLARE
	v_codigo_empresa character(3);
	v_codigo_filial character(3);
BEGIN
        v_codigo_empresa = fp_get_session('pst_cod_empresa');
        v_codigo_filial =  fp_get_session('pst_filial');

        NEW.codigo_empresa = COALESCE(v_codigo_empresa, '001');
        NEW.codigo_filial = COALESCE(v_codigo_filial,'001');
         
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


CREATE TRIGGER tgg_scr_nf_protocolo
BEFORE INSERT 
ON scr_nf_protocolo
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_nf_protocolo();