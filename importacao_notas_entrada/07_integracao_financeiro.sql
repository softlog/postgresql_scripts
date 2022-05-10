ALTER TABLE com_compras ADD COLUMN contas_pagar_id integer;

--ALTER TABLE cfop ADD COLUMN cfop_entrada character(4);



--SELECT cfop.id_cfop, cfop.codigo_cfop, initcap(cfop.descricao_cfop) as descricao_cfop, cfop.cfop_entrada, initcap(cfop_entrada.descricao_cfop)  as descricao_cfop_entrada FROM cfop LEFT JOIN cfop cfop_entrada ON cfop.cfop_entrada = cfop_entrada.codigo_cfop WHERE LEFT(cfop.codigo_cfop,1) IN ('1','2','3') ORDER BY cfop.codigo_cfop;
--SELECT cfop.id_cfop, cfop.codigo_cfop, initcap(cfop.descricao_cfop) as descricao_cfop FROM cfop WHERE LEFT(cfop.codigo_cfop,1) IN ('4','5','6','7') ORDER BY cfop.codigo_cfop;
--SELECT * FROM string_conexoes ORDER BY 1 DESC 