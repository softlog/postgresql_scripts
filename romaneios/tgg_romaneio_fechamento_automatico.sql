-- Trigger: tgg_romaneio_fechamento_automatico on public.scr_romaneios

-- DROP TRIGGER tgg_romaneio_fechamento_automatico ON public.scr_romaneios;

CREATE TRIGGER tgg_romaneio_fechamento_automatico
  BEFORE UPDATE 
  ON public.scr_romaneios
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_calcula_tabela_motorista('cursor_fechamento', 'msg');
--ALTER TABLE public.scr_romaneios DISABLE TRIGGER tgg_romaneio_fechamento_automatico;
