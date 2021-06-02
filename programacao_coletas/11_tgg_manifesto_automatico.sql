CREATE TRIGGER tgg_manifesto_automatico
  BEFORE UPDATE OF flg_manifesto
  ON scr_conhecimento
  FOR EACH ROW
  EXECUTE PROCEDURE f_tgg_manifesto_automatico();
