-- DROP TRIGGER tgg_send_averbacao_fila_manifesto ON public.scr_manifesto_averbacao;

CREATE TRIGGER tgg_send_averbacao_fila_romaneio
  AFTER INSERT OR UPDATE OR DELETE
  ON public.scr_romaneio_averbacao
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_send_averbacao_fila_romaneio();
