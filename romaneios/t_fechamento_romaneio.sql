
CREATE TYPE t_fechamento_romaneio AS
   (id_fechamento integer,
    id_romaneio integer,
    tipo_calculo integer,
    excedente integer,
    base_calculo numeric(12,5),
    valor_item numeric(12,6),
    total_itens numeric(12,2),
    valor_minimo numeric(12,2),
    valor_pagar numeric(12,2),
    programado integer);