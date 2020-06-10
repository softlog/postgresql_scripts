ALTER TABLE scr_docs_digitalizados ADD COLUMN link_s3 text;
ALTER TABLE scr_docs_digitalizados ADD COLUMN upload_s3 integer DEFAULT 0;


CREATE INDEX ind_scr_docs_digitalizados_upload_s3
   ON scr_docs_digitalizados (upload_s3 ASC NULLS LAST);



--SELECT * FROM scr_docs_digitalizados WHERE upload_s3 = 1

