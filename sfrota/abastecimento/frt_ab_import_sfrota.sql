-- Table: public.frt_ab_import
-- DROP TABLE frt_ab_import_sfrota
-- DROP TABLE public.frt_ab_import;


--SELECT * FROM frt_ab_import_sfrota
CREATE TABLE public.frt_ab_import_sfrota
(
	id serial,
	placa_veiculo character(7),
	id_motorista integer,
	id_viagem_aplicativo integer,
	data_abastecimento date,
	odometro integer,
	horimetro integer,
	litragem numeric(12,2),
	id_tp_combust integer,
	codigo_empresa character(3),
	codigo_filial character(3),
	data_registro timestamp DEFAULT now(),
	id_frt_ab integer,
	id_usuario integer,
	CONSTRAINT frt_ab_import_sfrota_id_pk PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

--SELECT * FROM frt_ab_import_sfrota
ALTER TABLE frt_ab_import_sfrota ADD COLUMN valor_unitario numeric(12,2) DEFAULT 0.00;

-- ALTER TABLE frt_ab_import_sfrota OWNER TO softlog_organics
-- Trigger: tgg_lanca_ab on public.frt_ab_import
-- DROP TRIGGER tgg_lanca_ab ON public.frt_ab_import;
/*
SELECT * FROM usuarios
CREATE TRIGGER tgg_lanca_ab
  AFTER INSERT
  ON public.frt_ab_import
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_tgg_lanca_ab();
  
*/

