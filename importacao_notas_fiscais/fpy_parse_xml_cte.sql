--SELECT * FROM fd_dados_tabela('scr_notas_fiscais_imp') WHERE tipo like '%(30)%'
/*
SELECT data_registro, id_nota_fiscal_imp FROm scr_notas_fiscais_imp WHERE chave_nfe = '52170908618022000121550010003844721026624872';
	--TRUNCATE scr_doc_integracao
	
BEGIN;
SELECT fp_set_session('pst_login', 'suporte');
SELECT fp_set_session('pst_usuario', '1');
SELECT fp_set_session('pst_cod_empresa', '001');
SELECT fp_set_session('pst_filial', '001');
SELECT fp_set_session('pst_modulo_cte', '1');
SELECT fp_set_session('pst_viagem_automatica','0');
SELECT fp_set_session('pst_cte_serie', '2');
SELECT fp_set_session('pst_tipo_ambiente','2');
SELECT fp_set_session('pst_modal','1');
SELECT fp_set_session('pst_regime_especial','0');
SELECT fp_set_session('pst_tipo_especifico_importacao','Debug');
UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao WHERE data_recebimento::date >= '2017-11-03';
COMMIT;

SELECT fpy_parse_xml_nfe(doc_xml), * FROM scr_doc_integracao WHERE ORDER BY data_recebimento::date >= '2017-11-03' AND chave_doc IS NULL;
SELECT fpy_parse_xml_nfe(doc_xml), * FROM scr_doc_integracao WHERE  data_recebimento::date >= '2017-11-03' AND chave_doc IS NULL;


-- WHERE id_doc_integracao = 8549417



SELECT * FROM scr_doc_integracao WHERE chave_doc = '32180604307650001298550120001380841288168311';
SELECT data_registro, status, numero_nota_fiscal FROM scr_notas_fiscais_imp WHERE chave_doc = '52170904274988000219550010001632641006852782'
DELETE FROM scr_notas_fiscais_imp WHERE chave_nfe = '35170924934972000111550010000113621251540273'
SELECT now()

SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 10
SELECT * FROM scr_doc_integracao WHERE id_uid_imap = 11265
SELECT * FROM email_uid_imap ORDER BY 1 DESC LIMIT 10
rollback;

SELECT data_registro, data_expedicao, * FROM v_mgr_notas_fiscais WHERE numero_nota_fiscal = '000076116'
SELECT id_nota_fiscal_imp FROM scr_notas_fiscais_imp WHERE chave_nfe = '35190810630293000144550010000761161055022051'
BEGIN;
INSERT INTO scr_doc_integracao (tipo_doc, codigo_empresa, codigo_filial, doc_xml)
VALUES (1,'001','001','')
VALUES (2,'001','003','<?xml version="1.0"?><cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte"><CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte versao="3.00" Id="CTe31190523979770000123570010000575601000595370"><ide><cUF>31</cUF><cCT>00059537</cCT><CFOP>5353</CFOP><natOp>TRANSP. INTERMUNICIPAL (COM)</natOp><mod>57</mod><serie>1</serie><nCT>57560</nCT><dhEmi>2019-05-15T17:29:58-03:00</dhEmi><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>0</cDV><tpAmb>1</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>S01.95</verProc><cMunEnv>3106200</cMunEnv><xMunEnv>BELO HORIZONTE</xMunEnv><UFEnv>MG</UFEnv><modal>01</modal><tpServ>0</tpServ><cMunIni>3106200</cMunIni><xMunIni>Belo Horizonte</xMunIni><UFIni>MG</UFIni><cMunFim>3138401</cMunFim><xMunFim>Leopoldina</xMunFim><UFFim>MG</UFFim><retira>1</retira><indIEToma>1</indIEToma><toma3><toma>0</toma></toma3></ide><compl><xCaracAd>1</xCaracAd><xObs>ICMS ISENTO CFE. ITEM 144 E 144.1 DO ANEXO I DO RICMS/MG.</xObs><ObsCont xCampo="PO"><xTexto>0</xTexto></ObsCont><ObsCont xCampo="respSeg"><xTexto>4</xTexto></ObsCont></compl><emit><CNPJ>23979770000123</CNPJ><IE>0026881280068</IE><xNome>FAMA TRANSPORTES BH - ME</xNome><xFant>TSOUZA TRANSPORTES BH LTDA</xFant><enderEmit><xLgr>R EMERECIANA BATISTA CAMARGOS, 302</xLgr><nro>0</nro><xBairro>CALIFORNIA</xBairro><cMun>3106200</cMun><xMun>BELO HORIZONTE</xMun><CEP>30855030</CEP><UF>MG</UF></enderEmit></emit><rem><CNPJ>07068488000138</CNPJ><IE>0623514620023</IE><xNome>APORTE NUTRICIONAL LTDA</xNome><xFant>APORTE NUTRICIONAL LTDA</xFant><fone>34653900</fone><enderReme><xLgr>AV SILVIANO BRANDAO, 1042</xLgr><nro>0</nro><xBairro>FLORESTA</xBairro><cMun>3106200</cMun><xMun>BELO HORIZONTE</xMun><CEP>31015254</CEP><UF>MG</UF></enderReme></rem><dest><CNPJ>22149165000162</CNPJ><IE>ISENTO</IE><xNome>CASA DE CARIDADE LEOPOLDINENSE</xNome><fone>34014664</fone><enderDest><xLgr>RUA PADRE JULIO, 138</xLgr><nro>0</nro><xBairro>CENTRO</xBairro><cMun>3138401</cMun><xMun>LEOPOLDINA</xMun><CEP>36700000</CEP><UF>MG</UF></enderDest></dest><vPrest><vTPrest>25.00</vTPrest><vRec>25.00</vRec><Comp><xNome>FRETE PESO</xNome><vComp>25.00</vComp></Comp><Comp><xNome>ICMS</xNome><vComp>0.00</vComp></Comp><Comp><xNome>SEGURO</xNome><vComp>0.00</vComp></Comp><Comp><xNome>PEDAGIO</xNome><vComp>0.00</vComp></Comp><Comp><xNome>SECCAT</xNome><vComp>0.00</vComp></Comp><Comp><xNome>DESPACHO</xNome><vComp>0.00</vComp></Comp><Comp><xNome>ADEME</xNome><vComp>0.00</vComp></Comp><Comp><xNome>MOVIMENTACAO</xNome><vComp>0.00</vComp></Comp><Comp><xNome>OUTROS</xNome><vComp>0.00</vComp></Comp><Comp><xNome>VL FRETE PAR</xNome><vComp>25.00</vComp></Comp><Comp><xNome>RASTREAMENTO</xNome><vComp>0.00</vComp></Comp><Comp><xNome>AGENCIADOR</xNome><vComp>0.00</vComp></Comp></vPrest><imp><ICMS><ICMS45><CST>40</CST></ICMS45></ICMS></imp><infCTeNorm><infCarga><vCarga>455.46</vCarga><proPred>CONFORME NF</proPred><infQ><cUnid>03</cUnid><tpMed>VOLUME</tpMed><qCarga>1.0000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>PESO BRUTO</tpMed><qCarga>0.5000</qCarga></infQ></infCarga><infDoc><infNFe><chave>31190507068488000138550020001556371001556375</chave></infNFe></infDoc><infModal versaoModal="3.00"><rodo><RNTRC>49395514</RNTRC></rodo></infModal></infCTeNorm></infCte><Signature Id="Ass_CTe31190523979770000123570010000575601000595370" xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" /><Reference URI="#CTe31190523979770000123570010000575601000595370"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" /><DigestValue>TypODnFj4Kv4B0O7hkdAH3+wWjo=</DigestValue></Reference></SignedInfo><SignatureValue>Yb5nDZN/aqNCZ46UTpHnoY1c60LXFhwUD8IZQgVFg6kuh8d8y1PBnnIWZKzHyfLYZm2F8kt//N6AE1S5yAoKb8dI4BXJteypG37eUxirgXGYj8I5dekK5OuCaTBGjQ+T6eJA70LV5pUj4WbKqDs0cDTvMYK9qZrMMcsCgngsjlEu+kbrpSIHBL7gy1bVlzIVkNDyQ09lfSWtoh1hnR/eCKh74K10bn9rmCTvJ11ikka18zKXOYQpBjoMuYjwUqNGIZ+WQbixdUt7zQnpN1iz2fKnGx10Y9SptbE5s9NaOuLw9ZrfxT4rnPy6FMVx64uydvRL63cIJfSBUDWw8Ub47Q==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></CTe><protCTe versao="3.00"><infProt Id="ID131190332211182"><tpAmb>1</tpAmb><verAplic>1.2.70</verAplic><chCTe>31190523979770000123570010000575601000595370</chCTe><dhRecbto>2019-05-15T17:30:39-03:00</dhRecbto><nProt>131190332211182</nProt><digVal>TypODnFj4Kv4B0O7hkdAH3+wWjo=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso do CT-e</xMotivo></infProt></protCTe></cteProc>')
SELECT * FROM scr_doc_integracao
SELECT tipo_transporte, * FROM v_mgr_notas_fiscais WHERE chave_nfe = '35190152601333000170550010000064611000064614'
update scr_doc_integracao SET id_doc_integracao = id_doc_integracao 
ROLLBACK;

SELECT * FROM scr_doc_integracao WHERE tipo_doc = 1

SELECT * FROM scr_doc_integracao WHERE doc_xml LIKE '<infCte' AND data_recebimento::date > current_date -1
COMMIT;

SELECT fpy_parse_xml_cte('<?xml version="1.0" encoding="utf-8"?><cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte"><CTe><infCte versao="3.00" Id="CTe53190807575651002950570130000219771564381513"><ide><cUF>53</cUF><cCT>56438151</cCT><CFOP>6351</CFOP><natOp>SERV. DE TRANSPORTE</natOp><mod>57</mod><serie>13</serie><nCT>21977</nCT><dhEmi>2019-08-27T11:49:07-03:00</dhEmi><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>3</cDV><tpAmb>1</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>3.00</verProc><cMunEnv>5300108</cMunEnv><xMunEnv>BRASÍLIA</xMunEnv><UFEnv>DF</UFEnv><modal>02</modal><tpServ>0</tpServ><cMunIni>5300108</cMunIni><xMunIni>BRASÍLIA</xMunIni><UFIni>DF</UFIni><cMunFim>2611606</cMunFim><xMunFim>RECIFE</xMunFim><UFFim>PE</UFFim><retira>0</retira><indIEToma>1</indIEToma><toma3><toma>0</toma></toma3></ide><compl><xCaracSer>NORMAL FREIGHT</xCaracSer><fluxo><xOrig>BSB</xOrig><xDest>REC</xDest></fluxo><origCalc>DF BRASÍLIA</origCalc><destCalc>PE RECIFE</destCalc><xObs>Tarifa Negociada. Alíquota de ICMS de 4% conforme Resolução do Senado Federal nº 95/1996.</xObs><ObsCont xCampo="LEI DA TRANSPARENCIA"><xTexto>BSB/REC.   O valor aproximado de tributos incidentes sobre o preço deste serviço é de R$ 4.84.</xTexto></ObsCont></compl><emit><CNPJ>07575651002950</CNPJ><IE>749005600224</IE><xNome>GOL LINHAS AEREAS SA</xNome><xFant>GOLLOG SERVIÇO INTELIGENTE DE CARGAS</xFant><enderEmit><xLgr>AEROPORTO INTERNACIONAL BRASILIA PR</xLgr><nro>SN</nro><xBairro>LAGO SUL</xBairro><cMun>5300108</cMun><xMun>BRASÍLIA</xMun><CEP>71608900</CEP><UF>DF</UF></enderEmit></emit><rem><CNPJ>08944556000148</CNPJ><IE>748976900130</IE><xNome>BSBDF TRANSPORTES DE CARGAS</xNome><xFant>BSBDF TRANSPORTES DE CARGAS</xFant><enderReme><xLgr>Q AD</xLgr><nro>SN</nro><xBairro>AGUAS CLARAS</xBairro><cMun>5300108</cMun><xMun>BRASÍLIA</xMun><CEP>71991140</CEP><UF>DF</UF><xPais>BRASIL</xPais></enderReme><email>RASTREAMENTO@BSBEXPRESS.COM.BR</email></rem><exped><CNPJ>08944556000148</CNPJ><IE>748976900130</IE><xNome>BSBDF TRANSPORTES DE CARGAS</xNome><enderExped><xLgr>Q AD</xLgr><nro>SN</nro><xBairro>AGUAS CLARAS</xBairro><cMun>5300108</cMun><xMun>BRASÍLIA</xMun><CEP>71991140</CEP><UF>DF</UF><xPais>BRASIL</xPais></enderExped><email>RASTREAMENTO@BSBEXPRESS.COM.BR</email></exped><receb><CPF>02911466438</CPF><xNome>CARLOS ALBERTO FRANCA DO NASCIMENT</xNome><enderReceb><xLgr>RUA SAO JOSE DA COROA GRANDE 65</xLgr><nro>0</nro><xBairro>BOMBA DO HEMET</xBairro><cMun>2611606</cMun><xMun>RECIFE</xMun><CEP>52111624</CEP><UF>PE</UF></enderReceb></receb><dest><CPF>02911466438</CPF><xNome>CARLOS ALBERTO FRANCA DO NASCIMENT</xNome><enderDest><xLgr>RUA SAO JOSE DA COROA GRANDE 65</xLgr><nro>0</nro><xBairro>BOMBA DO HEMET</xBairro><cMun>2611606</cMun><xMun>RECIFE</xMun><CEP>52111624</CEP><UF>PE</UF></enderDest></dest><vPrest><vTPrest>120.95</vTPrest><vRec>120.95</vRec><Comp><xNome>FRETE VALOR</xNome><vComp>120.95</vComp></Comp></vPrest><imp><ICMS><ICMS00><CST>00</CST><vBC>120.95</vBC><pICMS>4.00</pICMS><vICMS>4.84</vICMS></ICMS00></ICMS><vTotTrib>4.84</vTotTrib></imp><infCTeNorm><infCarga><vCarga>100.00</vCarga><proPred>IMPRESSOS</proPred><infQ><cUnid>03</cUnid><tpMed>VOLUMES</tpMed><qCarga>3</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>PESO REAL</tpMed><qCarga>40.5000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>PESO BASE DE CALCULO</tpMed><qCarga>41.0000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>PESO CUBADO</tpMed><qCarga>0.0000</qCarga></infQ></infCarga><infDoc><infOutros><tpDoc>00</tpDoc><descOutros>DECLARACAO</descOutros><nDoc>00</nDoc><dEmi>2019-08-27</dEmi><dPrev>2019-08-27</dPrev></infOutros></infDoc><infModal versaoModal="3.00"><aereo><nOCA>12737769056</nOCA><dPrevAereo>2019-09-11</dPrevAereo><natCarga /><tarifa><CL>G</CL><vTar>2.95</vTar></tarifa></aereo></infModal></infCTeNorm><autXML><CNPJ>07947821000189</CNPJ></autXML></infCte><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" /><Reference URI="#CTe53190807575651002950570130000219771564381513"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" /><DigestValue>LyVi2FxY7LM0mLZkhDUy6/qHsjE=</DigestValue></Reference></SignedInfo><SignatureValue>uzSoCSk++nqFEeHF3EVEg/G5Nk6GYfAow/we9GwqaRJIIZHMWtGuvwdVrW/+ilmzjwq5/EAxDrP54wIyVsdwwUAARkbm5ubRfqIEVLl9skBDgAk0CAiOwabGNJcvMX6zuqO/hjxgcsXaqL079BuMh8qvVk5S84d5Uy86/pWr9C0BmjY4P64g4ISqr3IAxi0aVWn/bkvFWVKb6VBrE/UfYW39Iuh20pquVOCFrg3pfr5/6HdlZ22vgrhEg44Gvbh2WtJ4bwT/TBdzVTCivpkkXx+LGYQq+Mtd9H4D8YynFLoNMnqJ0mMEWm2oTM+VISoToRQWB8OP0+jrr0w7KMRxrw==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></CTe><protCTe versao="3.00"><infProt Id="CTe353190001632304"><tpAmb>1</tpAmb><verAplic>RS20190823163910</verAplic><chCTe>53190807575651002950570130000219771564381513</chCTe><dhRecbto>2019-08-27T11:49:30-03:00</dhRecbto><nProt>353190001632304</nProt><digVal>LyVi2FxY7LM0mLZkhDUy6/qHsjE=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso do CT-e</xMotivo></infProt></protCTe></cteProc>');

select max(id_nota_fiscal_
--SELECT fpy_parse_xml_nfe(doc_xml), doc_xml, chave_doc, data_recebimento FROM scr_doc_integracao WHERE chave_doc = '32180604307650001379550130000287161691788439'
ELECT fpy_parse_xml_cte('<?xml version="1.0" encoding="utf-8"?><cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte"><CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte Id="CTe31190511280282000144570010000366811589599510" versao="3.00"><ide><cUF>31</cUF><cCT>58959951</cCT><CFOP>6353</CFOP><natOp>PRESTACAO DE SERVICO DE TRANSPORTE A ESTABELECIMENTO COMERCI</natOp><mod>57</mod><serie>1</serie><nCT>36681</nCT><dhEmi>2019-05-28T19:27:18-03:00</dhEmi><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>0</cDV><tpAmb>1</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>RODOWEB 2.00</verProc><cMunEnv>3106200</cMunEnv><xMunEnv>BELO HORIZONTE</xMunEnv><UFEnv>MG</UFEnv><modal>02</modal><tpServ>0</tpServ><cMunIni>3106200</cMunIni><xMunIni>BELO HORIZONTE</xMunIni><UFIni>MG</UFIni><cMunFim>2909802</cMunFim><xMunFim>CRUZ DAS ALMAS</xMunFim><UFFim>BA</UFFim><retira>1</retira><indIEToma>1</indIEToma><toma3><toma>3</toma></toma3></ide><compl><xEmi>JOHNNY JUNIO TOMAZ</xEmi><fluxo><xOrig>CNF</xOrig><xDest>SSA</xDest></fluxo><Entrega><comData><tpPer>2</tpPer><dProg>2019-05-28</dProg></comData><comHora><tpHor>3</tpHor><hProg>18:00:00</hProg></comHora></Entrega><origCalc>CNF</origCalc><destCalc>SSA</destCalc><xObs>Aliquota conforme resolucao do senado federal 95/96 de 13/12/1996. | EMPRESA OPTANTE PELO SIMPLES NACIONAL. DESTAQUE DE ICMS EM CONFORMIDADE COM A LEI 123/2006 ART. 13 INCLUIDO PELA LCP 155/2016. | TARGET STANDARD | MD 44382 | DESTINO: SSA | ORIGEM: CNF</xObs><ObsCont xCampo="minuta"><xTexto>0000044382</xTexto></ObsCont><ObsCont xCampo="RAMO"><xTexto>RCTAC</xTexto></ObsCont><ObsCont xCampo="rota"><xTexto>|SSA</xTexto></ObsCont><ObsCont xCampo="RESPSEG"><xTexto>4</xTexto></ObsCont></compl><emit><CNPJ>11280282000144</CNPJ><IE>0014780260078</IE><xNome>TARGET TRANSPORTE DE CARGAS E ENCOMENDAS EXPRESSAS LTDA</xNome><xFant>TARGET CARGO</xFant><enderEmit><xLgr>RUA MARTINICA, GALPOES 4 E 5</xLgr><nro>021</nro><xBairro>SANTA BRANCA</xBairro><cMun>3106200</cMun><xMun>BELO HORIZONTE</xMun><CEP>31565400</CEP><UF>MG</UF><fone>3136533060</fone></enderEmit></emit><rem><CNPJ>66320789000419</CNPJ><IE>0627694970200</IE><xNome>FRUTO PROIBIDO COMERCIAL E INDUSTRIAL LTDA.</xNome><xFant>FRUTO PROIBIDO COMERCIAL E INDUSTRIAL LTDA</xFant><enderReme><xLgr>R PARACATU</xLgr><nro>1340</nro><xBairro>SANTO AGOSTINHO</xBairro><cMun>3106200</cMun><xMun>BELO HORIZONTE</xMun><CEP>30180091</CEP><UF>MG</UF><cPais>1058</cPais><xPais>Brasil</xPais></enderReme></rem><dest><CNPJ>14021463000144</CNPJ><IE>94295429</IE><xNome>RUBENE MARIA LIMA SANTOS ROSA - ME</xNome><enderDest><xLgr>R RIBEIRO DOS SANTOS</xLgr><nro>090</nro><xBairro>CENTRO</xBairro><cMun>2909802</cMun><xMun>CRUZ DAS ALMAS</xMun><CEP>44380000</CEP><UF>BA</UF><cPais>1058</cPais><xPais>Brasil</xPais></enderDest><email>RUBENE.ROSA@GMAIL.COM</email></dest><vPrest><vTPrest>350.92</vTPrest><vRec>350.92</vRec><Comp><xNome>TX. COLETA</xNome><vComp>30.31</vComp></Comp><Comp><xNome>OUTRAS TAXAS</xNome><vComp>8.00</vComp></Comp><Comp><xNome>AD VALOREM</xNome><vComp>55.17</vComp></Comp><Comp><xNome>TX. ENTREGA</xNome><vComp>98.13</vComp></Comp><Comp><xNome>TX. DESPACHO</xNome><vComp>159.31</vComp></Comp></vPrest><imp><ICMS><ICMS00><CST>00</CST><vBC>350.92</vBC><pICMS>4.00</pICMS><vICMS>14.04</vICMS></ICMS00></ICMS></imp><infCTeNorm><infCarga><vCarga>8283.11</vCarga><proPred>CONFECCAO</proPred><xOutCat>70 - CONFECCOES E TEXTEIS</xOutCat><infQ><cUnid>01</cUnid><tpMed>PESO BRUTO</tpMed><qCarga>47.0000</qCarga></infQ><infQ><cUnid>03</cUnid><tpMed>VOLUMES</tpMed><qCarga>2.0000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>CUBADO</tpMed><qCarga>47.0000</qCarga></infQ><vCargaAverb>8283.11</vCargaAverb></infCarga><infDoc><infNFe><chave>31190566320789000419550010000162091816359404</chave></infNFe></infDoc><infModal versaoModal="3.00"><aereo><nMinu>000044382</nMinu><dPrevAereo>2019-05-28</dPrevAereo><natCarga/><tarifa><CL>G</CL><vTar>0.00</vTar></tarifa></aereo></infModal></infCTeNorm><autXML><CNPJ>30059305000130</CNPJ></autXML><autXML><CNPJ>06367953000179</CNPJ></autXML></infCte><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#CTe31190511280282000144570010000366811589599510"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>Elws+DWJJAwOg4pEeemr7YNcAHs=</DigestValue></Reference></SignedInfo><SignatureValue>fKI7FDpf/DRTVJRUWXj7uorOYZVhjZncqPyq1JxdNFpq8mp66X5h6VsFTx4fpKUlS8BUUaA2aeAMz0t5HaYwO5PLJjrhi1Ikz3ua8FlifNAfWS5cXr2k5rrxzeF6RqGWxaQXlC4SbjX4+Qh0TxkduyfVFPicBEinSAbZrv311fKEvtcdumfWbisx8A6RZWrvk/vur2OIRtzOWItSix4reLVAhUcOASEFXFoayWaTNIxTezX3eKq17Y+bHeQO+PFEv5HcBqHgDeky4XKXTTRSUXIxeoY2K2HiXnp8dWxJ1WyoUvhJ4YEFVEYZuMwPpLk3kEE7IFSjDdzMa4M8xcM5Sw==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></CTe><protCTe versao="3.00"><infProt xmlns="http://www.portalfiscal.inf.br/cte" Id="ID131190334671995"><tpAmb>1</tpAmb><verAplic>1.2.70</verAplic><chCTe>31190511280282000144570010000366811589599510</chCTe><dhRecbto>2019-05-28T19:27:20-03:00</dhRecbto><nProt>131190334671995</nProt><digVal>Elws+DWJJAwOg4pEeemr7YNcAHs=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso do CT-e</xMotivo></infProt></protCTe></cteProc>')
SELECT fpy_parse_xml_cte('<?xml version="1.0" encoding="UTF-8" ?>
<cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">
	<CTe xmlns="http://www.portalfiscal.inf.br/cte">
		<infCte versao="3.00" Id="CTe32190605529929000398570010000319121001390385">
			<ide>
				<cUF>32</cUF>
				<cCT>00139038</cCT>
				<CFOP>6353</CFOP>
				<natOp>PREST. SERV. TRANSP. A ESTABELECIMENTO COMERCIAL</natOp>
				<mod>57</mod>
				<serie>1</serie>
				<nCT>31912</nCT>
				<dhEmi>2019-06-14T20:11:32-03:00</dhEmi>
				<tpImp>1</tpImp>
				<tpEmis>1</tpEmis>
				<cDV>5</cDV>
				<tpAmb>1</tpAmb>
				<tpCTe>0</tpCTe>
				<procEmi>0</procEmi>
				<verProc>770</verProc>
				<cMunEnv>3205002</cMunEnv>
				<xMunEnv>SERRA</xMunEnv>
				<UFEnv>ES</UFEnv>
				<modal>02</modal>
				<tpServ>0</tpServ>
				<cMunIni>3205200</cMunIni>
				<xMunIni>VILA VELHA</xMunIni>
				<UFIni>ES</UFIni>
				<cMunFim>3304557</cMunFim>
				<xMunFim>RIO DE JANEIRO</xMunFim>
				<UFFim>RJ</UFFim>
				<retira>1</retira>
				<indIEToma>1</indIEToma>
				<toma3>
					<toma>0</toma>
				</toma3>
			</ide>
			<compl>
				<xCaracAd>AEREO CONVENCIO</xCaracAd>
				<xCaracSer>AEREO ES X BRASIL</xCaracSer>
				<xEmi>CARLA CRISTINA DE FR</xEmi>
				<fluxo>
					<xOrig>VIX</xOrig>
					<xDest>SDU</xDest>
				</fluxo>
				<Entrega>
					<noPeriodo>
						<tpPer>4</tpPer>
						<dIni>2019-06-14</dIni>
						<dFim>2019-06-18</dFim>
					</noPeriodo>
					<comHora>
						<tpHor>2</tpHor>
						<hProg>00:00:00</hProg>
					</comHora>
				</Entrega>
				<xObs>ENDERECO DE ENTREGA HOSPITAL SOUZA AGUIAR - CNPJ: 00.801.512/0001-57**PRACA DA REPUBLICA, 111 - CENTRO - RIO DE JANEIRO - CEP 22.211-350</xObs>
				<ObsCont xCampo="Obs1">
					<xTexto>/ CEP ENTREGA: 22211350 / ENDERECO ENTREGA: PRACA DA REPUBLICA 111 / BAIRRO ENTREGA: CENTRO / CIDADE ENTREGA: RIO DE JANEIRO / ESTADO ENTREGA: RJ / NOTA FISCAL</xTexto>
				</ObsCont>
				<ObsCont xCampo="Obs2">
					<xTexto>:104748,</xTexto>
				</ObsCont>
				<ObsCont xCampo="ObsReservado1">
					<xTexto>NOTA FISCAL :104748,</xTexto>
				</ObsCont>
			</compl>
			<emit>
				<CNPJ>05529929000398</CNPJ>
				<IE>083216774</IE>
				<xNome>AEROFLEX CARGO E LOGISTICA LTDA ME</xNome>
				<xFant>AEROFLEX CARGO FILIAL VITORIA ES</xFant>
				<enderEmit>
					<xLgr>RUA MARICA, S/N</xLgr>
					<nro>00</nro>
					<xCpl>LT.06 QD.26</xCpl>
					<xBairro>MORADA DE LARANJEIRAS</xBairro>
					<cMun>3205002</cMun>
					<xMun>SERRA</xMun>
					<CEP>29166848</CEP>
					<UF>ES</UF>
					<fone>02721255952</fone>
				</enderEmit>
			</emit>
			<rem>
				<CNPJ>36325157000134</CNPJ>
				<IE>081526253</IE>
				<xNome>COSTA CAMARGO COM. DE PRODUTOS HOSPITALARES LTDA</xNome>
				<fone>2733202214</fone>
				<enderReme>
					<xLgr>R JUIZ ALEXANDRE MARTINS DE CASTRO FILHO</xLgr>
					<nro>8</nro>
					<xBairro>PRAIA DE ITAPOA</xBairro>
					<cMun>3205200</cMun>
					<xMun>VILA VELHA</xMun>
					<CEP>29101800</CEP>
					<UF>ES</UF>
				</enderReme>
				<email>ESTOQUE@COSTACAMARGO.COM.BR</email>
			</rem>
			<dest>
				<CNPJ>00801512000157</CNPJ>
				<IE>85688510</IE>
				<xNome>AGILE CORP SERVICOS ESPECIALIZADOS LTDA</xNome>
				<fone>38494938</fone>
				<enderDest>
					<xLgr>EST SAO LOURENCO QUADRA 21 LOTE 01</xLgr>
					<nro>S/N</nro>
					<xBairro>CHACARAS RIO PETROPO</xBairro>
					<cMun>3301702</cMun>
					<xMun>DUQUE DE CAXIAS</xMun>
					<CEP>25243150</CEP>
					<UF>RJ</UF>
				</enderDest>
			</dest>
			<vPrest>
				<vTPrest>154.49</vTPrest>
				<vRec>154.49</vRec>
				<Comp>
					<xNome>FRETE_PESO</xNome>
					<vComp>143.57</vComp>
				</Comp>
				<Comp>
					<xNome>EXCEDENTE_PESO</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>COLETA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>EXCED_COLETA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>ENTREGA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>EXCED_ENTREGA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>REDESPACHO</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>SECCAT</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>ITR</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>DESPACHO</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>GRIS</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>ADVALOREM</xNome>
					<vComp>4.74</vComp>
				</Comp>
				<Comp>
					<xNome>PEDAGIO</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>TAXAS_DIVERSAS</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>ACRESCIMO</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>SUFRAMA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>TDA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>TTD</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>EMERGENCIA</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>OUTROS</xNome>
					<vComp>0.00</vComp>
				</Comp>
				<Comp>
					<xNome>ICMS</xNome>
					<vComp>6.18</vComp>
				</Comp>
			</vPrest>
			<imp>
				<ICMS>
					<ICMS00>
						<CST>00</CST>
						<vBC>154.49</vBC>
						<pICMS>4.00</pICMS>
						<vICMS>6.18</vICMS>
					</ICMS00>
				</ICMS>
			</imp>
			<infCTeNorm>
				<infCarga>
					<vCarga>1437.00</vCarga>
					<proPred>MEDICAMENTOS</proPred>
					<xOutCat>CAIXA DE PAPELAO</xOutCat>
					<infQ>
						<cUnid>01</cUnid>
						<tpMed>Peso_Real</tpMed>
						<qCarga>22.0000</qCarga>
					</infQ>
					<infQ>
						<cUnid>01</cUnid>
						<tpMed>Peso_Cubado</tpMed>
						<qCarga>7.0000</qCarga>
					</infQ>
					<infQ>
						<cUnid>01</cUnid>
						<tpMed>Peso_Taxado</tpMed>
						<qCarga>22.0000</qCarga>
					</infQ>
					<infQ>
						<cUnid>01</cUnid>
						<tpMed>Tara_Container</tpMed>
						<qCarga>0.0000</qCarga>
					</infQ>
					<infQ>
						<cUnid>03</cUnid>
						<tpMed>Volume</tpMed>
						<qCarga>3.0000</qCarga>
					</infQ>
					<infQ>
						<cUnid>00</cUnid>
						<tpMed>Metros_Cubico</tpMed>
						<qCarga>0.0429</qCarga>
					</infQ>
				</infCarga>
				<infDoc>
					<infNFe>
						<chave>32190636325157000134550000001047481971764178</chave>
						<dPrev>2019-06-18</dPrev>
					</infNFe>
				</infDoc>
				<infModal versaoModal="3.00">
					<aereo>
						<dPrevAereo>2019-06-18</dPrevAereo>
						<natCarga>
							<cInfManu>99</cInfManu>
						</natCarga>
						<tarifa>
							<CL>M</CL>
							<vTar>0.00</vTar>
						</tarifa>
					</aereo>
				</infModal>
			</infCTeNorm>
		</infCte>
		<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
			<SignedInfo>
				<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
				<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
				<Reference URI="#CTe32190605529929000398570010000319121001390385">
					<Transforms>
						<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
						<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
					</Transforms>
					<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
					<DigestValue>Y9GN047DeN6PAf4Ue/YmmHhufGQ=</DigestValue>
				</Reference>
			</SignedInfo>
			<SignatureValue>cH4jOKPfGiDKTBw2ihz+G4yUKInHzZ1S8zdpvCPMs8UgOT0J2+aJx1e5x2FR5DM6jc7A9fb6eDqyAmOWKyfyMAqhj/MkBVAZpN4v0MYvO6lDWcEKSzJ2kmLOjSqv/IgH4gpRDAcdbKVxDJfHbeGnv18eLlC4zvtwRBqWp7tu+thI0CLGyEDUf6c6H0CikLkU8ss2FRkcKdCmXG8S8VG8495acgnrENlef6ff7b/q7smY5f5KcYR995u11bqTKo9FfNFjHOcXSFVQd5GyLpfHLLeN+yf10eW3d8NroQ07Gcml21lRmXnbpdeJbwk7SaYKmSgXQc4Ij5gLzYOF7ealMQ==</SignatureValue>
			<KeyInfo>
				<X509Data>
					<X509Certificate>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</X509Certificate>
				</X509Data>
			</KeyInfo>
		</Signature>
	</CTe>
	<protCTe versao="3.00">
		<infProt Id="CTe332190006940491">
			<tpAmb>1</tpAmb>
			<verAplic>RS20190412160025</verAplic>
			<chCTe>32190605529929000398570010000319121001390385</chCTe>
			<dhRecbto>2019-06-14T20:11:35-03:00</dhRecbto>
			<nProt>332190006940491</nProt>
			<digVal>Y9GN047DeN6PAf4Ue/YmmHhufGQ=</digVal>
			<cStat>100</cStat>
			<xMotivo>Autorizado o uso do CT-e</xMotivo>
		</infProt>
	</protCTe>
</cteProc>
')
*/

CREATE OR REPLACE FUNCTION public.fpy_parse_xml_cte(xml_cte text)
  RETURNS json AS
$BODY$


import traceback
import xmltodict
from decimal import Decimal
from collections import OrderedDict
import json


#a = open('C:\\Python\\projetos\\parse_nfe_xml\\31150771015853000145550020000619111004309337.xml')
#a = open('C:\\Python\\projetos\\parse_nfe_xml\\teste.xml')


try:
    xml = xmltodict.parse(xml_cte)
except:
    return None

lst_part = []
#Dados do Remetente
p = dict()
try:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['rem']['CNPJ']    
except:
    plpy.notice(traceback.format_exc())
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['rem']['CPF']

emit_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml['cteProc']['CTe']['infCte']['rem']['xNome'].replace('&','e')
p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['xLgr'].replace('&','e')
p['part_numero'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['nro']
p['part_bairro'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['cMun']
emit_cod_mun = p['part_cod_mun']
p['part_uf'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme']['UF']
p['part_cep'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme'].get('CEP')
p['part_pais'] = xml['cteProc']['CTe']['infCte']['rem']['enderReme'].get('xPais')
p['part_fone'] = xml['cteProc']['CTe']['infCte']['rem'].get('fone')
try:
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['rem']['IE']
except:
    p['part_ie'] = None
    
lst_part.append(p)


#Dados do Destinatario
p = dict()
try:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['dest']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['dest']['CPF']

dest_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml['cteProc']['CTe']['infCte']['dest']['xNome'].replace('&','e')
p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['xLgr'].replace('&','e')
p['part_numero'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['nro']
p['part_bairro'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['cMun']
dest_cod_mun = p['part_cod_mun']
p['part_uf'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest']['UF']
p['part_cep'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('CEP')
p['part_pais'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('xPais')
p['part_fone'] = xml['cteProc']['CTe']['infCte']['dest']['enderDest'].get('fone')
try:
    p['part_ie'] = xml['cteProc']['CTe']['infCte']['dest'].get('IE')
except:
    pass
p['part_email'] = xml['cteProc']['CTe']['infCte']['dest'].get('email')
lst_part.append(p)

#Dados do Emitente/Transportador
p = dict()
try:
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['emit']['CNPJ']
except:    
    p['part_cnpj_cpf'] = xml['cteProc']['CTe']['infCte']['emit']['CPF']

pagador_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml['cteProc']['CTe']['infCte']['emit']['xNome'].replace('&','e')
p['part_logradouro'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['xLgr'].replace('&','e')
p['part_numero'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['nro']
p['part_bairro'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['cMun']

pagador_cod_mun = p['part_cod_mun']
p['part_uf'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit']['UF']
p['part_cep'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit'].get('CEP')
p['part_pais'] = xml['cteProc']['CTe']['infCte']['emit']['enderEmit'].get('xPais')
p['part_fone'] = xml['cteProc']['CTe']['infCte']['emit'].get('fone')
p['part_ie'] = xml['cteProc']['CTe']['infCte']['emit']['IE']
lst_part.append(p)

#dados da Nota Fiscal

n = {}


infNFe = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infDoc']['infNFe'] 

if type(infNFe) == type([]):
    lista_nfe = [ x['chave'] for x in infNFe]
else:
    nfes = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infDoc']['infNFe']['chave']

    if type(nfes) == type(""):
        lista_nfe = []
        lista_nfe.append(nfes)

    elif  type(nfes) == type([]):
        lista_nfe = [x for x in nfes]
    else:
        lista_nfe = []

total_nfe = len(lista_nfe)
valor_carga = Decimal(xml['cteProc']['CTe']['infCte']['infCTeNorm']['infCarga']['vCarga'])
valor_cte_origem = Decimal(xml['cteProc']['CTe']['infCte']['vPrest']['vTPrest'])
peso_carga = Decimal(0.00)

volume_carga = Decimal(0.00)

inf_c = xml['cteProc']['CTe']['infCte']['infCTeNorm']['infCarga']['infQ']

if type(inf_c) == type(OrderedDict()):
    lista_inf = [inf_c]

if type(inf_c) == type([]):
    lista_inf = [x for x in inf_c]

for inf in lista_inf:
     if peso_carga == Decimal(0.00) and inf['tpMed'].upper().find('PESO') > -1 and peso_carga == Decimal(0.00):
        peso_carga = Decimal(inf.get('qCarga'))

     if volume_carga == Decimal(0.00) and inf['tpMed'].upper().find('VOLUME') > -1:
        volume_carga = Decimal(inf.get('qCarga'))

notas_fiscais = []
for chave in lista_nfe:

    ##plpy.notice(chave)
    n = {}
    ##Chave do CTe
    try:
        n['chave_cte'] = xml['cteProc']['protCTe']['infProt']['chCTe']
    except:
        try:
            n['chave_cte'] = xml['cteProc']['CTe']['infCte']['@Id'][-44:]
        except:
            pass

    n['nfe_valor_cte_origem'] = str(valor_cte_origem)
    
    n['nfe_chave_nfe'] = chave
    
    n['nfe_emit_cnpj_cpf'] = emit_cnpj
    n['nfe_emit_cod_mun']  = emit_cod_mun
    n['nfe_dest_cnpj_cpf'] = dest_cnpj
    n['nfe_dest_cod_mun']  = dest_cod_mun
    n['nfe_origem_cod_mun']  = xml['cteProc']['CTe']['infCte']['ide']['cMunIni']

    ##informacoes gerais
    onf = xml['cteProc']['CTe']['infCte']['ide']

    n['nfe_data_emissao_hr'] = onf.get('dhEmi')
    n['nfe_data_emissao'] = onf.get('dhEmi')
    n['nfe_pagador_cnpj_cpf'] = pagador_cnpj

    if n['nfe_data_emissao'] is None:
        n['nfe_data_emissao'] = onf.get('dEmi')



    n['nfe_numero_doc'] =  n['nfe_chave_nfe'][25:34]
    n['nfe_modelo'] = '55'
    n['nfe_serie'] = n['nfe_chave_nfe'][22:25]
    n['nfe_tp_nf'] = '1'
    n['nfe_ind_final'] = '0'
    n['nfe_ie_dest'] = '1'

    n['nfe_informacoes'] = ""

    ##valores
    n['nfe_valor'] = str(valor_carga/total_nfe)
    n['nfe_valor_bc'] = "0.00"
    n['nfe_valor_icms'] = "0.00"
    n['nfe_valor_bc_st'] = "0.00"
    n['nfe_valor_icms_st'] = "0.00"
    n['nfe_valor_produtos'] = str(valor_carga/total_nfe)


    ##informacoes relativas ao transporte
    try:
        n['nfe_modo_frete'] = "0"
    except:
        pass

    ## Coleta de dados
    peso_presumido = str(peso_carga/total_nfe)
    peso_liquido = str(peso_carga/total_nfe)
    vol_presumido = str(volume_carga/total_nfe)

    n['nfe_peso_presumido'] = peso_presumido
    n['nfe_peso_liquido'] = peso_liquido
    n['nfe_volume_presumido'] = vol_presumido
    

    ## Informacoes dos Itens de Produto
    n['nfe_volume_produtos'] = peso_presumido
    n['nfe_peso_produtos'] = peso_presumido
    n['nfe_unidade'] = 'UN'

    n['nfe_especie_mercadoria'] = "UN"
    n['nfe_especie_mercadoria'] = ""
    n['nfe_cfop_predominante'] = ""

    notas_fiscais.append(n)


dados = {'participantes':lst_part,
         'nfs':notas_fiscais}

retorno = json.dumps(dados)

return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_parse_xml_cte(xml text)  OWNER TO softlog_fg;