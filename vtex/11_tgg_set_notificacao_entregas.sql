CREATE TRIGGER tgg_set_notificacao_entregas_notas_fiscais 
  AFTER INSERT OR UPDATE
  ON scr_notas_fiscais_imp_ocorrencias
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_set_notificacao();
