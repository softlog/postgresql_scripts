CREATE TRIGGER tgg_scr_romaneios_set_notificacao
  AFTER UPDATE
  ON public.scr_romaneios
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_set_notificacao();
