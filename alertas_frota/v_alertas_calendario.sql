-- View: public.v_alertas_calendario

-- DROP VIEW public.v_alertas_calendario;

--CREATE OR REPLACE VIEW public.v_alertas_calendario AS 
 WITH tbl_calcula AS (
         SELECT
                CASE
                    WHEN row_number() OVER w > 8 AND row_number() OVER w < 29 THEN (((v_alertas.data_vencto || ' '::text) || f_retorna_hora(8 * 60 + 30 * row_number() OVER w::integer - 30))::timestamp without time zone) + '02:00:00'::interval
                    WHEN row_number() OVER w > 32 AND row_number() OVER w < 49 THEN ((v_alertas.data_vencto || ' '::text) || f_retorna_hora(8 * 60 - 30 * (row_number() OVER w::integer - 32)))::timestamp without time zone
                    WHEN row_number() OVER w > 48 THEN ((v_alertas.data_vencto || ' '::text) || f_retorna_hora(30 * row_number() OVER w::integer - 30))::timestamp without time zone
                    ELSE ((v_alertas.data_vencto || ' '::text) || f_retorna_hora(8 * 60 + 30 * row_number() OVER w::integer - 30))::timestamp without time zone
                END AS dstarttime,
            ((v_alertas.tipo_alerta::text || ' '::text))::character(100) AS cevent,
            (((((btrim(v_alertas.descr_doc::text) || ' Nr '::text) || btrim(v_alertas.numero_doc::text)) || ' - '::text) || btrim(v_alertas.descr_alerta::text)))::character(100) AS cnotes,
                CASE v_alertas.situacao
                    WHEN 1 THEN 1184895
                    WHEN 2 THEN 11206640
                    WHEN 3 THEN 16777130
                    ELSE 15790320
                END::numeric(8,0) AS ncolor,
            0 AS lallday,
            v_alertas.do_form
           FROM v_alertas
          WINDOW w AS (PARTITION BY v_alertas.data_vencto ORDER BY v_alertas.data_vencto)
          ORDER BY v_alertas.data_vencto
        )
 SELECT tbl_calcula.dstarttime,
    tbl_calcula.dstarttime + '00:30:00'::interval AS dendtime,
    tbl_calcula.cevent,
    tbl_calcula.cnotes,
    tbl_calcula.ncolor,
    tbl_calcula.lallday,
    tbl_calcula.do_form
   FROM tbl_calcula;


SELECT * FROM frt_pmveic