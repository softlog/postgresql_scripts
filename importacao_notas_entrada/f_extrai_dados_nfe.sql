-- Function: public.f_extrai_dados_nfe(text, refcursor, refcursor, refcursor, refcursor, refcursor)

-- DROP FUNCTION public.f_extrai_dados_nfe(text, refcursor, refcursor, refcursor, refcursor, refcursor);

CREATE OR REPLACE FUNCTION public.f_extrai_dados_nfe(
    p_xml_nfe text,
    crsdadosnfe refcursor,
    crsemitente refcursor,
    crsdestinatario refcursor,
    crsitens refcursor,
    crsfat refcursor)
  RETURNS SETOF refcursor AS
$BODY$
DECLARE
        v_xml text;        
        v_comandos text[];
        v_cmd text;
BEGIN

	--SELECT xml_nfe::text  INTO v_xml FROM xml_nfe WHERE chave_nfe = p_chave_nfe;

	v_xml = p_xml_nfe;
	RAISE NOTICE '%', v_xml;
	
        v_comandos = string_to_array(f_py_get_cmd_bloco_nfe(v_xml),'###');

	RAISE NOTICE 'Comandos %', v_comandos;

        --Cria cursor de dados da nfe
        v_cmd = v_comandos[1];
        OPEN crsdadosnfe FOR EXECUTE v_cmd;
        RETURN NEXT crsdadosnfe;

        --Cria cursor de dados do emitente
        v_cmd = v_comandos[2];
        OPEN crsemitente FOR EXECUTE v_cmd;
        RETURN NEXT crsemitente;

        --Cria cursor de dados do destinatario
        v_cmd = v_comandos[3];
        OPEN crsdestinatario FOR EXECUTE v_cmd;
        RETURN NEXT crsdestinatario;

        --Cria cursor de dados dos itens                
        v_cmd = v_comandos[4];
        OPEN crsitens FOR EXECUTE v_cmd;
        RETURN NEXT crsitens;

        --Cria cursor de dados das faturas
        v_cmd = v_comandos[5];
        OPEN crsfat FOR EXECUTE v_cmd;
        RETURN NEXT crsfat;        
        
	RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.f_extrai_dados_nfe(text, refcursor, refcursor, refcursor, refcursor, refcursor)
  OWNER TO softlog_bsb;
