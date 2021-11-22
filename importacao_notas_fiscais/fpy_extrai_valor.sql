	
CREATE OR REPLACE FUNCTION public.fpy_extrai_valor(
    texto text,
    termo text)
  RETURNS text AS
$BODY$

    import re
    import traceback
    try:
        l = texto.partition(termo)

        #Verifica se a divisão foi bem sucedida 
        if l[2] is not None:
            r = l[2].strip().split(' ')[0]
        else:
            r = None
    except Exception as e:
        r = None

    if r is not None and r != '':
        
        return r.strip()

    try:
        l = re.findall(termo,texto)
        
        r = l[0].strip()                
        if r.strip() == '':
            r = None
    except:
        #plpy.notice(termo)
        #plpy.notice(texto)
        #plpy.notice(traceback.format_exc())
        r = None

    return r
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;
  
/*

SELECT fpy_extrai_valor('Motorista: CARLOS ANTONIO SARMENTO VITAL / No do lacre: 02934811 / 02934812 / 02934813 / 02934814 / 02934815 / 02934816 / 02934817 / 02934818 / 02934821 / 02934822 / 02934823 / 02934824 / 02934825 / 02934826 / No do lacre: 02934827 / 02934828 / 02934829 / 02934830 / Escopo do Certif.ISO-9001, No. QSC-4524: fabricacao e servicos associados para oleos lubes e isolantes / Tipo Doc.Vendas: Z700 Venda Produtos - Ord.Venda(s): 0248512286 - Faturamento: 0165749876 - Conceito de Pesquisa: CENTRO COM / N. Transporte: 4032449213 / CIF - Rodoviario /','N. Transporte:(.+?)/')

SELECT fpy_extrai_valor('PGTO APOLICE SEGURO N 3002651 - INDIANA SEGUROS CNPJ: {61.100145000159REF. JOHN DEERE 8335R ANO 2013 CHASSI: 1RW8335RLCP067810 - PARC 04/04',
'CNPJ[^0-9]+([0-9\.\-/]+)[^0-9]');

SELECT * FROM cliente_parametros
SELECT fpy_extrai_valor('PEDIDO 200669. ISENTO DE ICMS CONF Art. 7 Inciso 25 Alinea F do anexo 9 DO RICMS. -  - TORTA DE ALGODAO ENSACADA 40KG - TORTA DE ALGODAO CONCENTRAL ENSACADA 40KG',
'(ALGODAO CONCENTRAL ENSACADA)');


SELECT * FROM scr_natureza_carga WHERE natureza_carga = 'ALGODAO CONCENTRAL ENSACADA'
ALGODAO CONCENTRAL.+ENSACADA

SELECT * FROM scr_natureza_carga
SELECT COALESCE(
	fpy_extrai_valor(upper(historico),'CNPJ[^0-9]+([0-9\.\-/]+)[^0-9]'),
	fpy_extrai_valor(upper(historico),'CPF[^0-9]+([0-9\.\-/]+)[^0-9]')
	)
FROm tabela
	

SELECT fpy_extrai_valor('PGTO APOLICE SEGURO N 3002651 - INDIANA SEGUROS CNPJ: {61.100145000159REF. JOHN DEERE 8335R ANO 2013 CHASSI: 1RW8335RLCP067810 - PARC 04/04',
'ALGODAO.+CONCENTRAL.+ENSACADA');



+[^0-9-./]

: ([0-9]+?) -

SELECT * FROM cliente_tipo_parametros ORDER BY 2
Motorista:(.+?)/

SELECT fpy_extrai_valor('PEDIDO 42755206 VOLUME 0,062700M3 OPERACAO CONTRATADA NO AMBITO DO COMERCIO ELETRONICO OU DO TELEMARKETING.  - Consulte o pedido em: http://bit.ly/1sapJlE','PEDIDO ([0-9]+?) ')

SELECT fpy_extrai_valor('(Documento - 53210609053134000145550050002645611862734140) já esta em outra rota (35251 - 2021-06-07 - 07759006721) ou está finalizado. Importação cancelada!'
,'rota \((.+)\)')


*/

--ALTER FUNCTION fpy_extrai_valor(texto text, termo text) OWNER TO softlog_solar;