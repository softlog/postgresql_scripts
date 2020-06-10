-- Trigger: tgg_scr_manifesto_averbacao on public.scr_manifesto

-- DROP TRIGGER tgg_scr_manifesto_averbacao ON public.scr_manifesto;

CREATE TRIGGER tgg_scr_romaneio_averbacao
  AFTER INSERT OR UPDATE OR DELETE
  ON public.scr_romaneios
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_set_averbacao_romaneio();

