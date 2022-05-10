
CREATE TRIGGER tgg_z_before_xml_nfe_insert_nf
  BEFORE INSERT OR UPDATE
  ON public.xml_nfe
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_insert_dados_from_xml_nfe();
