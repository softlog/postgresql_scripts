
CREATE TYPE public.t_xml_pessoas AS
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