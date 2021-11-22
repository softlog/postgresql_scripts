-- View: public.v_bd_tabelas

-- DROP VIEW public.v_bd_tabelas;

CREATE OR REPLACE VIEW public.v_bd_tabelas AS 
 SELECT DISTINCT ON (pg_tables.tablename) tmp_class.oid::integer AS id_tabela,
    pg_tables.tablename::character varying(63) AS nome_tabela,
    tmp_class.obj_description::character varying(250) AS alias_tabela,
    pg_tables.schemaname::character varying(63) AS nome_schema,
    tmp_class.attname::character varying(63) AS pkey_tabela,
    tmp_class.usa_log
   FROM pg_tables
     LEFT JOIN ( SELECT pg_class.oid,
            pg_class.relname,
            obj_description(pg_class.oid, 'pg_class'::name) AS obj_description,
            pk_attribute.attname,
            COALESCE(log.tglogenabled, 2) AS usa_log
           FROM pg_class
             LEFT JOIN ( SELECT pg_attribute.attrelid,
                    pg_attribute.attname
                   FROM pg_attribute
                     JOIN pg_index ON pg_attribute.attrelid = pg_index.indrelid
                  WHERE pg_index.indkey[0] = pg_attribute.attnum AND pg_index.indisprimary = true) pk_attribute ON pg_class.oid = pk_attribute.attrelid
             LEFT JOIN ( SELECT pg_trigger.tgrelid,
                        CASE pg_trigger.tgenabled
                            WHEN 'O'::"char" THEN 1
                            ELSE 0
                        END AS tglogenabled
                   FROM pg_trigger
                  WHERE pg_trigger.tgname = 'tgg_log_atividades'::name) log ON pg_class.oid = log.tgrelid
          WHERE pg_class.relkind = ANY (ARRAY['r'::"char", ''::"char"])) tmp_class ON pg_tables.tablename = tmp_class.relname
  WHERE pg_tables.schemaname <> ALL (ARRAY['pg_catalog'::name, 'pg_toast'::name, 'information_schema'::name])
  ORDER BY pg_tables.tablename;
