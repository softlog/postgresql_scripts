CREATE TRIGGER tgg_scr_romaneios_envio
  AFTER INSERT OR UPDATE
  ON public.scr_romaneios
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_scr_romaneios_envio();
