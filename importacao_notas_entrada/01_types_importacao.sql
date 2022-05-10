-- Type: public.t_xml_pessoas

--\ DROP TYPE public.t_xml_pessoas_v2;

CREATE TYPE public.t_xml_pessoas_v2 AS
   (cnpjcpf character(14),
    nomerazao character(60),
    endereco character(60),
    numero character(10),
    bairro character(60),
    cidade character(60),
    estado character(2),
    cep character(10),
    telefone character(15),
    iestadual character(20),
    codmunicipio character(10),
    codpais character(5),
    crt character(1));


CREATE TYPE public.t_xml_cte_complementar_v2 AS
   (cod_mun_ini character(7),
    mun_ini character(50),
    uf_ini character(2),
    cod_mun_fim character(7),
    mun_fim character(50),
    uf_fim character(2),
    cfop character(4),
    tomador character(1));


 
CREATE TYPE public.t_xml_faturas_v2 AS
   (parcela text,
    fk_notas_fiscais_id integer,
    fk_notas_fiscais_numeronf character(10),
    numero_fatura character(10),
    data_vencimento date,
    valor_fatura numeric(12,2));

  
  CREATE TYPE public.t_xml_notas_fiscais_v2 AS
   (
    chave character(44),
    numeronf character(10),
    serie character(3),
    data_emissao date,
    indpag character(1),
    vlr_bc numeric(12,2),
    vlr_icms numeric(12,2),
    vlr_bcst numeric(12,2),
    vlr_st numeric(12,2),
    vlr_prod numeric(12,2),
    vlr_frete numeric(12,2),
    vlr_seg numeric(12,2),
    vlr_desc numeric(12,2),
    vlr_ipi numeric(12,2),
    vlr_pis numeric(12,2),
    vlr_cofins numeric(12,2),
    vlr_outro numeric(12,2),
    vlr_nf numeric(12,2),
    tpag character(3),
    modfrete character(1),
    obs text,
    transportador_cnpj character(14)
    );

   
CREATE TYPE public.t_xml_notas_itens_v2 AS
   (num_item integer,
    cod_prod character(20),
    descricao character(60),
    ncm character(15),
    cfop_for character(4),
    cfop_ent character(4),
    und character(3),
    qtd numeric(18,6),
    unit numeric(18,6),
    total numeric(18,2),
    desconto numeric(10,2),
    frete numeric(12,2),
    seguro numeric(12,2),
    despesas_acessorias numeric(12,2),
    cst character(4),
    bc numeric(12,2),
    aliq_icms numeric(8,2),
    icms numeric(12,2),
    bcst numeric(12,2),
    aliq_icmsst numeric(12,2),
    icmsst numeric(12,2),
    aliq_ipi numeric(12,2),
    valor_ipi numeric(12,2),
    tem_st_ncm integer,
    p_cred_sn numeric(12,2),
    v_cred_icms_sn numeric(12,2),
    bc_pis numeric(12,2),
    aliq_pis numeric(12,2),
    vl_pis numeric(12,2),
    bc_cofins numeric(12,2),
    aliq_cofins numeric(12,2),
    vl_cofins numeric(12,2));

    