-- Function: public.f_insere_nf_parceiros(json, integer, text, text)

-- DROP FUNCTION public.f_insere_nf_parceiros(json, integer, text, text);

CREATE OR REPLACE FUNCTION public.f_insere_nf_parceiros(
    dado_nf json,
    v_id_usuario integer,
    empresa text,
    filial text)
  RETURNS integer AS
$BODY$
DECLARE
	v_resultado 	integer;        
	vModal 		text;
	vCtrcCte 	text;
	vTabelaPadrao 	text;	
	v_origem_frete 	text;
	v_login		text;
	v_temp 		text;
	
BEGIN


	SELECT trim(valor_parametro)
	INTO vModal
	FROM parametros 
	WHERE cod_empresa = empresa AND upper(cod_parametro) = 'PST_MODAL';

	SELECT trim(valor_parametro)
	INTO vCtrcCte
	FROM parametros 
	WHERE cod_empresa = empresa AND upper(cod_parametro) = 'PST_MODULO_CTE';

	SELECT trim(valor_parametro)
	INTO vTabelaPadrao
	FROM parametros 
	WHERE cod_empresa = empresa AND upper(cod_parametro) = 'PST_TABELA_AVULSA_PADRAO';
	--SELECT * FROM edi_destinatario


	SELECT trim(valor_parametro)
	INTO v_origem_frete
	FROM parametros 
	WHERE cod_empresa = empresa AND upper(cod_parametro) = 'PST_USAR_ORIGEM_DE_FILIAL';

	SELECT 
		trim(login_name)
	INTO 	
		v_login		
	FROM 
		usuarios 
	WHERE 
		id_usuario = v_id_usuario;


	v_temp	 	= fp_set_session('pst_cod_empresa',empresa);
	v_temp	  	= fp_set_session('pst_filial', filial);
	v_temp	 	= fp_set_session('pst_modulo_cte',vCtrcCte);
	v_temp		= fp_set_session('pst_login',v_login);
	v_temp		= fp_set_session('pst_usuario',v_id_usuario::text);
	v_temp		= fp_set_session('pst_modal',vModal);
	v_temp	 	= fp_set_session('pst_usar_origem_de_filial', v_origem_frete);

	
        v_resultado = f_insere_nf(dado_nf);
        
	RETURN v_resultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

