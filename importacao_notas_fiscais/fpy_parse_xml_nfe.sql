/*
SELECT * FROM scr_doc_integracao WHERE chave_doc = '52190508070566001254550010000667911660936966'

--SELECT * FROM fd_dados_tabela('scr_notas_fiscais_imp') WHERE tipo like '%(30)%'

DELETE FROM scr_doc_integracao WHERE data_recebimento < current_date - 2
SELECT * FROM scr_doc_integracao WHERE chave_doc = '35190520064155000107550010000421561102030403'
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
INSERT INTO scr_doc_integracao (tipo_doc, codigo_empresa, codigo_filial, doc_xml)
VALUES (2,'001','001','<?xml version="1.0" encoding="UTF-8"?>
<nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe">
	<NFe xmlns="http://www.portalfiscal.inf.br/nfe">
		<infNFe versao="4.00" Id="NFe31190825773037000183550010000882181003289571">
			<ide>
				<cUF>31</cUF>
				<cNF>00328957</cNF>
				<natOp>Compra para industrializacao ou producao rura</natOp>
				<mod>55</mod>
				<serie>1</serie>
				<nNF>88218</nNF>
				<dhEmi>2019-08-30T13:41:02-03:00</dhEmi>
				<tpNF>0</tpNF>
				<idDest>3</idDest>
				<cMunFG>3106705</cMunFG>
				<tpImp>1</tpImp>
				<tpEmis>1</tpEmis>
				<cDV>0</cDV>
				<tpAmb>1</tpAmb>
				<finNFe>1</finNFe>
				<indFinal>0</indFinal>
				<indPres>9</indPres>
				<procEmi>0</procEmi>
				<verProc>TEK_DFS_6.19.106</verProc>
			</ide>
			<emit>
				<CNPJ>25773037000183</CNPJ>
				<xNome>Pharmascience I. Farm. Eirelli</xNome>
				<xFant>Pharmascience I. Farm. Eirelli</xFant>
				<enderEmit>
					<xLgr>RUA TEXACO</xLgr>
					<nro>.</nro>
					<xBairro>JARDIM PIEMONTE</xBairro>
					<cMun>3106705</cMun>
					<xMun>BETIM</xMun>
					<UF>MG</UF>
					<CEP>32689322</CEP>
					<cPais>1058</cPais>
					<xPais>BRASIL</xPais>
					<fone>3135050505</fone>
				</enderEmit>
				<IE>0676094230093</IE>
				<CRT>3</CRT>
			</emit>
			<dest>
				<idEstrangeiro>01270</idEstrangeiro>
				<xNome>GEMINI EXPORTS</xNome>
				<enderDest>
					<xLgr>A 201 NAVBHARAT ESTATES</xLgr>
					<nro>.</nro>
					<xBairro>ZAKARIA BUNDER ROAD</xBairro>
					<cMun>9999999</cMun>
					<xMun>EXTERIOR</xMun>
					<UF>EX</UF>
					<CEP>00400015</CEP>
					<cPais>3611</cPais>
					<xPais>INDIA</xPais>
					<fone>00400015</fone>
				</enderDest>
				<indIEDest>9</indIEDest>
			</dest>
			<det nItem="1">
				<prod>
					<cProd>1010201192</cProd>
					<cEAN>SEM GTIN</cEAN>
					<xProd>SULFATO FERROSO (DESSECADO) KG CST 1</xProd>
					<NCM>28332940</NCM>
					<CFOP>3101</CFOP>
					<uCom>KG</uCom>
					<qCom>5000.0000</qCom>
					<vUnCom>6.3098820000</vUnCom>
					<vProd>31549.41</vProd>
					<cEANTrib>SEM GTIN</cEANTrib>
					<uTrib>KG</uTrib>
					<qTrib>5000.0000</qTrib>
					<vUnTrib>6.3098820000</vUnTrib>
					<vOutro>12831.38</vOutro>
					<indTot>1</indTot>
					<DI><nDI>1915847739</nDI>
						<dDI>2019-08-28</dDI>
						<xLocDesemb>ECOPORTO SANTOS S.A</xLocDesemb>
						<UFDesemb>SP</UFDesemb>
						<dDesemb>2019-08-28</dDesemb>
						<tpViaTransp>1</tpViaTransp>
						<vAFRMM>110.16</vAFRMM>
						<tpIntermedio>1</tpIntermedio>
						<CNPJ>25773037000183</CNPJ>
						<UFTerceiro>MG</UFTerceiro>
						<cExportador>01270</cExportador>
						<adi>
							<nAdicao>1</nAdicao>
							<nSeqAdic>1</nSeqAdic>
							<cFabricante>01270</cFabricante>
						</adi>
					</DI>
				</prod>
				<imposto>
					<ICMS>
						<ICMS00>
							<orig>1</orig>
							<CST>00</CST>
							<modBC>3</modBC>
							<vBC>50690.67</vBC>
							<pICMS>18.0000</pICMS>
							<vICMS>9124.32</vICMS>
						</ICMS00>
					</ICMS>
					<IPI>
						<cEnq>999</cEnq>
						<IPITrib>
							<CST>00</CST>
							<vBC>0.00</vBC>
							<pIPI>0.0000</pIPI>
							<vIPI>0.00</vIPI>
						</IPITrib>
					</IPI>
					<II>
						<vBC>31549.41</vBC>
						<vDespAdu>3154.94</vDespAdu>
						<vII>3154.94</vII>
						<vIOF>0.00</vIOF>
					</II>
					<PIS>
						<PISOutr>
							<CST>50</CST>
							<vBC>31549.41</vBC>
							<pPIS>2.1000</pPIS>
							<vPIS>662.54</vPIS>
						</PISOutr>
					</PIS>
					<COFINS>
						<COFINSOutr>
							<CST>50</CST>
							<vBC>31549.41</vBC>
							<pCOFINS>9.6500</pCOFINS>
							<vCOFINS>3044.52</vCOFINS>
						</COFINSOutr>
					</COFINS>
				</imposto>
			</det>
			<total>
				<ICMSTot>
					<vBC>50690.67</vBC>
					<vICMS>9124.32</vICMS>
					<vICMSDeson>0.00</vICMSDeson>
					<vFCP>0.00</vFCP>
					<vBCST>0.00</vBCST>
					<vST>0.00</vST>
					<vFCPST>0.00</vFCPST>
					<vFCPSTRet>0.00</vFCPSTRet>
					<vProd>31549.41</vProd>
					<vFrete>0.00</vFrete>
					<vSeg>0.00</vSeg>
					<vDesc>0.00</vDesc>
					<vII>3154.94</vII>
					<vIPI>0.00</vIPI>
					<vIPIDevol>0.00</vIPIDevol>
					<vPIS>662.54</vPIS>
					<vCOFINS>3044.52</vCOFINS>
					<vOutro>12831.38</vOutro>
					<vNF>50690.67</vNF>
				</ICMSTot>
			</total>
			<transp>
				<modFrete>4</modFrete>
				<transporta>
					<CNPJ>08944556000148</CNPJ>
					<xNome>BSB-DF TRANSPORTES DE CARGAS LTDA</xNome>
					<IE>0748976900130</IE>
					<xEnder>Q ADE CONJUNTO 27 LOTE 28 E 29</xEnder>
					<xMun>BRASILIA</xMun>
					<UF>DF</UF>
				</transporta>
				<vol>
					<qVol>5</qVol>
					<esp>PALLETS</esp>
					<pesoL>5000.000</pesoL>
					<pesoB>5040.000</pesoB>
				</vol>
			</transp>
			<pag>
				<detPag>
					<tPag>90</tPag>
					<vPag>0.00</vPag>
				</detPag>
			</pag>
			<infAdic>
				<infCpl>NOTA FISCAL DE IMPORTACAO DI: 19/1584773- 9 DE 28/02/2019, DESPESA ACESSORIA ICMS: R$ 9.124,32 | II: R$ 3.154,94, PIS: R$ 662,53, COFINS: R$ 3.044,51 | PESO BRUTO: 5.040 KG, PESO LIQUIDO: 5.000 KG | VOLUME: 5, ESPECIE: PALLETS</infCpl>
			</infAdic>
		</infNFe>
		<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
			<SignedInfo>
				<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
				<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
				<Reference URI="#NFe31190825773037000183550010000882181003289571">
					<Transforms>
						<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
						<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
					</Transforms>
					<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
					<DigestValue>LfrmqWKiymsHtn+mvJx+nGxXvCk=</DigestValue>
				</Reference>
			</SignedInfo>
			<SignatureValue>MhOBU77lltFYyV8FdyFpZbs5w9uVEevX5BMPho63ahjlJ1P9lOtKhLQz03cUwUyRfZcahxv714x+qEI+doDQO+4iTFSH7kM43PSbyiQrKwWojDDhFnXGoE7rfNUoyn1nXcK3mrMESxxdZMoEZLw298nom1+42ciLdi/R3BIXEL0=</SignatureValue>
			<KeyInfo>
				<X509Data>
					<X509Certificate>MIICOTCCAaKgAwIBAgIQJpLn3fwH17RNXJHw5VenaDANBgkqhkiG9w0BAQUFADBbMVkwVwYDVQQDHlAAdwB3AHcALgBmAHMAaQBzAHQALgBjAG8AbQAuAGIAcgAgACgAUwBFAE0AIABWAEEATABJAEQAQQBEAEUAIABKAFUAUgDNAEQASQBDAEEAKTAeFw0xNTEyMjQwODI1MjVaFw0xODEyMjQwODI1MjVaMFsxWTBXBgNVBAMeUAB3AHcAdwAuAGYAcwBpAHMAdAAuAGMAbwBtAC4AYgByACAAKABTAEUATQAgAFYAQQBMAEkARABBAEQARQAgAEoAVQBSAM0ARABJAEMAQQApMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDX4BYmJiNwrPz9At2ioXYkMuMWAOf669VPS3SAzIKkJLhSE7Bf9sbTjGHRFZhs6STxKkMBKKnx6dqAEMGlQwDSU42/kqhGya28SUn3HigH2w3dR/536Gt4eAxyLp9ODNXUqWTpnraWCeT41kcnJ27cmOAUMxzxDcsA93n32L4u8wIDAQABMA0GCSqGSIb3DQEBBQUAA4GBAAN89zf+wSFL+4+2Ic8mGva8Z51EzYzNgYEqXwEMHxw4jCxxbsuxewQWedSGWi3SFZla6zmNUEA+UO95tSZ353klTvWDzut2BFSJOPLcMu8HPTTdnMt4ofVeVqKyi2vp+3t78vjqDAAfSAu5C9wT7stoUx41Nok+L6WbmpOIgvHy</X509Certificate>
				</X509Data>
			</KeyInfo>
		</Signature>
	</NFe>
	<protNFe versao="4.00">
		<infProt>
			<tpAmb>1</tpAmb>
			<verAplic>TEK_DFS_6.19.106</verAplic>
			<chNFe>31190825773037000183550010000882181003289571</chNFe>
			<dhRecbto>2019-08-30T13:40:57-03:00</dhRecbto>
			<nProt>131193403262743</nProt>
			<digVal>r2gZUIo0cT9ODzqc7oUtWcjifn4=</digVal>
			<cStat>100</cStat>
			<xMotivo>Autorizado o uso da NF-e</xMotivo>
		</infProt>
	</protNFe>
</nfeProc>')
SELECT * FROM v_mgr_notas_fiscais WHERE id_nota_fiscal_imp = 14970742;
ROLLBACK;

COMMIT;
SELECT fpy_parse_xml_nfe('<?xml version="1.0" encoding="UTF-8"?><nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe versao="4.00" Id="NFe35190528104240000155550010000287201258741999"><ide><cUF>35</cUF><cNF>25874199</cNF><natOp>VENDA DE MERCADORIA ADQUIRIDA OU RECEBIDA DE TERCEIROS EM OP</natOp><mod>55</mod><serie>1</serie><nNF>28720</nNF><dhEmi>2019-05-30T00:00:00-03:00</dhEmi><dhSaiEnt>2019-05-30T00:00:00-03:00</dhSaiEnt><tpNF>1</tpNF><idDest>1</idDest><cMunFG>3553807</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>9</cDV><tpAmb>1</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>9</indPres><procEmi>0</procEmi><verProc>RacSID v2.2.99</verProc></ide><emit><CNPJ>28104240000155</CNPJ><xNome>RODRIGO SOLDERA DE CAMPOS EIRELI</xNome><xFant>QUALY NUTRI</xFant><enderEmit><xLgr>R SAO PAULO</xLgr><nro>310</nro><xBairro>CENTRO</xBairro><cMun>3553807</cMun><xMun>TAQUARITUBA</xMun><UF>SP</UF><CEP>18740000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>1437624061</fone></enderEmit><IE>685034531113</IE><CRT>3</CRT></emit><dest><CNPJ>55299135000191</CNPJ><xNome>DROGARIA SAO GERALDO LTDA - EPP</xNome><enderDest><xLgr>AV OLSEN</xLgr><nro>118</nro><xBairro>CENTRO</xBairro><cMun>3537305</cMun><xMun>PENAPOLIS</xMun><UF>SP</UF><CEP>16300000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>1836523016</fone></enderDest><indIEDest>1</indIEDest><IE>521017876110</IE></dest><det nItem="1"><prod><cProd>3616</cProd><cEAN>798190060996</cEAN><xProd>DESINCHA NOITE C/ 60 SACHES</xProd><NCM>21069090</NCM><CFOP>5405</CFOP><uCom>UND</uCom><qCom>1.0000</qCom><vUnCom>61.9900000000</vUnCom><vProd>61.99</vProd><cEANTrib>798190060996</cEANTrib><uTrib>UND</uTrib><qTrib>1.0000</qTrib><vUnTrib>61.9900000000</vUnTrib><indTot>1</indTot><rastro><nLote>41182</nLote><qLote>1.000</qLote><dFab>2019-05-01</dFab><dVal>2021-05-01</dVal></rastro></prod><imposto><ICMS><ICMS60><orig>0</orig><CST>60</CST><vBCSTRet>106.66</vBCSTRet><pST>0.0000</pST><vICMSSubstituto>0.00</vICMSSubstituto><vICMSSTRet>8.04</vICMSSTRet></ICMS60></ICMS><IPI><cEnq>999</cEnq><IPITrib><CST>99</CST><vBC>0.00</vBC><pIPI>0.0000</pIPI><vIPI>0.00</vIPI></IPITrib></IPI><PIS><PISAliq><CST>01</CST><vBC>61.99</vBC><pPIS>0.6500</pPIS><vPIS>0.40</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>61.99</vBC><pCOFINS>3.0000</pCOFINS><vCOFINS>1.86</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>Lote: 41182 / Fabr.: 01/05/2019 / Val.: 01/05/2021</infAdProd></det><total><ICMSTot><vBC>0.00</vBC><vICMS>0.00</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>61.99</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.40</vPIS><vCOFINS>1.86</vCOFINS><vOutro>0.00</vOutro><vNF>61.99</vNF></ICMSTot></total><transp><modFrete>0</modFrete><transporta><CNPJ>06209025000186</CNPJ><xNome>MARCIO RODRIGO DE PAULA RIBEIRO TRANSPORTE</xNome><IE>279048406119</IE><xEnder>R HILARIO PESSARELLO, 108</xEnder><xMun>CRAVINHOS</xMun><UF>SP</UF></transporta><vol><qVol>1</qVol><esp>VOLUMES</esp><marca>DIVERSAS</marca></vol></transp><cobr><fat><nFat>31366</nFat><vOrig>61.99</vOrig><vDesc>0.00</vDesc><vLiq>61.99</vLiq></fat><dup><nDup>001</nDup><dVenc>2019-06-13</dVenc><vDup>61.99</vDup></dup></cobr><pag><detPag><indPag>1</indPag><tPag>15</tPag><vPag>61.99</vPag></detPag></pag><infAdic><infCpl>Nota fiscal refere-se ao pedido: 31366;Representante: 000078-LUCIMAR APARECIDA COSTA BERNARDES;</infCpl></infAdic></infNFe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#NFe35190528104240000155550010000287201258741999"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>gFW1wPwhWwqGlv5WijGtRaKpSJY=</DigestValue></Reference></SignedInfo><SignatureValue>RXfGz7wpnM3DXElWY0Mzs3tDu79QXOR3Hda8+ZGFgk1BlhbjHi0YQ96SFGkREM8v5nsSFfdg4jOWrNiEd2Ga5K8b2aZ3kkft6vjpusOBpuW9nyS66jVIpkLRrOCk0dAzWDLwlbC7XbhlAlFumou3yLT8O7I45LF3dWQdpX2Pj2yk1b04yVg8CaqMyzWCf40ZLfAYe3tHelg27p//XpIRZo7JK+HvKWKtGbrIzSCmOg7wo2qcW3S1KQ6KY1h7Xs9Ew4b4cKGMCVK5VpAyf2EEdSO2gu6Yk+frsa7CQqTNVo/TKd7XHfzTD4ft0ekP/+Myh05zQQrnVLGAd6huqpREdQ==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe versao="4.00"><infProt><tpAmb>1</tpAmb><verAplic>SP_NFE_PL009_V4</verAplic><chNFe>35190528104240000155550010000287201258741999</chNFe><dhRecbto>2019-05-30T17:37:37-03:00</dhRecbto><nProt>135190387444680</nProt><digVal>gFW1wPwhWwqGlv5WijGtRaKpSJY=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>')
SELECT fpy_parse_xml_nfe(doc_xml), * FROM scr_doc_integracao WHERE ORDER BY data_recebimento::date >= '2017-11-03' AND chave_doc IS NULL;
SELECT fpy_parse_xml_nfe(doc_xml), * FROM scr_doc_integracao WHERE  data_recebimento::date >= '2017-11-03' AND chave_doc IS NULL;
rollback;

-- WHERE id_doc_integracao = 8549417
UPDATE scr_doc_integracao SET id_doc_integracao = id_doc_integracao;

SELECT * FROM scr_doc_integracao WHERE chave_doc = '32180604307650001298550120001380841288168311';
SELECT data_registro, status, numero_nota_fiscal FROM scr_notas_fiscais_imp WHERE chave_doc = '52170904274988000219550010001632641006852782'
DELETE FROM scr_notas_fiscais_imp WHERE chave_nfe = '35170924934972000111550010000113621251540273'
SELECT now()

SELECT * FROM scr_doc_integracao ORDER BY 1 DESC LIMIT 10
SELECT * FROM scr_doc_integracao WHERE id_uid_imap = 11265
SELECT * FROM email_uid_imap ORDER BY 1 DESC LIMIT 10

BEGIN;
INSERT INTO scr_doc_integracao (tipo_doc, codigo_empresa, codigo_filial, doc_xml)
VALUES (2,'001','001','<?xml version="1.0" encoding="UTF-8"?><nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe versao="4.00" Id="NFe42190578256336000107550040005083991422084340"><ide><cUF>42</cUF><cNF>42208434</cNF><natOp>VENDA DE PRODUCAO DO ESTABELECIMENTO</natOp><mod>55</mod><serie>4</serie><nNF>508399</nNF><dhEmi>2019-05-08T18:46:47-03:00</dhEmi><tpNF>1</tpNF><idDest>2</idDest><cMunFG>4208906</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>0</cDV><tpAmb>1</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>9</indPres><procEmi>0</procEmi><verProc>5.0</verProc></ide><emit><CNPJ>78256336000107</CNPJ><xNome>ZANOTTI S.A.</xNome><enderEmit><xLgr>GERMANO WAGNER</xLgr><nro>1000</nro><xBairro>CENTENARIO</xBairro><cMun>4208906</cMun><xMun>JARAGUA DO SUL</xMun><UF>SC</UF><CEP>89256800</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>4733725000</fone></enderEmit><IE>251057143</IE><CRT>3</CRT></emit><dest><CNPJ>06942256000102</CNPJ><xNome>S DA SILVA AVIAMENTOS</xNome><enderDest><xLgr>AVE MINAS GERAIS</xLgr><nro>404</nro><xCpl>QD 87 LT 08</xCpl><xBairro>SETOR CAMPINAS</xBairro><cMun>5208707</cMun><xMun>GOIANIA</xMun><UF>GO</UF><CEP>74510040</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>6232337929</fone></enderDest><indIEDest>1</indIEDest><IE>103800352</IE><email>aviamentosecia@hotmail.com</email></dest><det nItem="1"><prod><cProd>119532</cProd><cEAN>7894881570966</cEAN><xProd>ELAST JARAGUA 80 CRU 70%PES 30%ED - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>0.4500</qCom><vUnCom>832.6700000000</vUnCom><vProd>374.70</vProd><cEANTrib>7894881570966</cEANTrib><uTrib>KM</uTrib><qTrib>0.4500</qTrib><vUnTrib>832.6666666667</vUnTrib><indTot>1</indTot><nFCI>DC891A7C-6B3A-4422-960F-CD8741509E57</nFCI></prod><imposto><ICMS><ICMS00><orig>5</orig><CST>00</CST><modBC>3</modBC><vBC>374.70</vBC><pICMS>7.0000</pICMS><vICMS>26.23</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>374.70</vBC><pPIS>1.6500</pPIS><vPIS>6.18</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>374.70</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>28.48</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: DC891A7C-6B3A-4422-960F-CD8741509E57|</infAdProd></det><det nItem="2"><prod><cProd>002784</cProd><cEAN>7894881010530</cEAN><xProd>ELAST JARAGUA 50 CRU 71%PES 29%ED - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>0.6000</qCom><vUnCom>405.8600000000</vUnCom><vProd>243.52</vProd><cEANTrib>7894881010530</cEANTrib><uTrib>KM</uTrib><qTrib>0.6000</qTrib><vUnTrib>405.8666666667</vUnTrib><indTot>1</indTot><nFCI>5F93B973-B0AF-4A8F-A3F3-890845839F76</nFCI></prod><imposto><ICMS><ICMS00><orig>5</orig><CST>00</CST><modBC>3</modBC><vBC>243.52</vBC><pICMS>7.0000</pICMS><vICMS>17.05</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>243.52</vBC><pPIS>1.6500</pPIS><vPIS>4.02</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>243.52</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>18.51</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: 5F93B973-B0AF-4A8F-A3F3-890845839F76|</infAdProd></det><det nItem="3"><prod><cProd>005939</cProd><cEAN>7894881016303</cEAN><xProd>ELAST CR 45* JARAGUA CRU 30X25=750 - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>0.7500</qCom><vUnCom>353.5000000000</vUnCom><vProd>265.13</vProd><cEANTrib>7894881016303</cEANTrib><uTrib>KM</uTrib><qTrib>0.7500</qTrib><vUnTrib>353.5066666667</vUnTrib><indTot>1</indTot><nFCI>2C5037A9-512A-4D7A-AB07-EF4F76A61123</nFCI></prod><imposto><ICMS><ICMS00><orig>5</orig><CST>00</CST><modBC>3</modBC><vBC>265.13</vBC><pICMS>7.0000</pICMS><vICMS>18.56</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>265.13</vBC><pPIS>1.6500</pPIS><vPIS>4.37</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>265.13</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>20.15</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: 2C5037A9-512A-4D7A-AB07-EF4F76A61123|</infAdProd></det><det nItem="4"><prod><cProd>002779</cProd><cEAN>7894881010486</cEAN><xProd>ELAST CR 40* JARAGUA CRU 30X25=750 - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>2.2500</qCom><vUnCom>288.0300000000</vUnCom><vProd>648.07</vProd><cEANTrib>7894881010486</cEANTrib><uTrib>KM</uTrib><qTrib>2.2500</qTrib><vUnTrib>288.0311111111</vUnTrib><indTot>1</indTot><nFCI>9312DB1A-58BB-462E-BC63-3CB8B225E990</nFCI></prod><imposto><ICMS><ICMS00><orig>5</orig><CST>00</CST><modBC>3</modBC><vBC>648.07</vBC><pICMS>7.0000</pICMS><vICMS>45.36</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>648.07</vBC><pPIS>1.6500</pPIS><vPIS>10.69</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>648.07</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>49.25</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: 9312DB1A-58BB-462E-BC63-3CB8B225E990|</infAdProd></det><det nItem="5"><prod><cProd>002777</cProd><cEAN>7894881010462</cEAN><xProd>ELAST JARAGUA 35 CRU 72%PES 28%ED - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>2.7000</qCom><vUnCom>243.5100000000</vUnCom><vProd>657.48</vProd><cEANTrib>7894881010462</cEANTrib><uTrib>KM</uTrib><qTrib>2.7000</qTrib><vUnTrib>243.5111111111</vUnTrib><indTot>1</indTot><nFCI>B824FC75-CDC8-4CF2-864C-5F5F1BF62569</nFCI></prod><imposto><ICMS><ICMS00><orig>3</orig><CST>00</CST><modBC>3</modBC><vBC>657.48</vBC><pICMS>4.0000</pICMS><vICMS>26.30</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>657.48</vBC><pPIS>1.6500</pPIS><vPIS>10.85</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>657.48</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>49.97</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: B824FC75-CDC8-4CF2-864C-5F5F1BF62569|</infAdProd></det><det nItem="6"><prod><cProd>005939</cProd><cEAN>7894881016303</cEAN><xProd>ELAST CR 45* JARAGUA CRU 30X25=750 - CX_ROLO -OC986365</xProd><NCM>58062000</NCM><CFOP>6101</CFOP><uCom>KM</uCom><qCom>0.7500</qCom><vUnCom>353.4900000000</vUnCom><vProd>265.12</vProd><cEANTrib>7894881016303</cEANTrib><uTrib>KM</uTrib><qTrib>0.7500</qTrib><vUnTrib>353.4933333333</vUnTrib><indTot>1</indTot><nFCI>2C5037A9-512A-4D7A-AB07-EF4F76A61123</nFCI></prod><imposto><ICMS><ICMS00><orig>5</orig><CST>00</CST><modBC>3</modBC><vBC>265.12</vBC><pICMS>7.0000</pICMS><vICMS>18.56</vICMS></ICMS00></ICMS><IPI><cEnq>999</cEnq><IPINT><CST>51</CST></IPINT></IPI><PIS><PISAliq><CST>01</CST><vBC>265.12</vBC><pPIS>1.6500</pPIS><vPIS>4.37</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>265.12</vBC><pCOFINS>7.6000</pCOFINS><vCOFINS>20.15</vCOFINS></COFINSAliq></COFINS></imposto><infAdProd>| Resolucao do Senado Federal no. 13/12, no. FCI: 2C5037A9-512A-4D7A-AB07-EF4F76A61123|</infAdProd></det><total><ICMSTot><vBC>2454.02</vBC><vICMS>152.06</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>2454.02</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>40.48</vPIS><vCOFINS>186.51</vCOFINS><vOutro>0.00</vOutro><vNF>2454.02</vNF></ICMSTot></total><transp><modFrete>1</modFrete><transporta><CNPJ>22955711000233</CNPJ><xNome>FD TRANSPORTES EIRELI - ME</xNome><IE>257752170</IE><xEnder>R GENERAL OSORIO, 288, GALPAO1 PISO</xEnder><xMun>BRUSQUE</xMun><UF>SC</UF></transporta><vol><qVol>10</qVol><esp>CAIXA</esp><marca>ZANOTTI S.A.</marca><pesoL>100.265</pesoL><pesoB>104.321</pesoB></vol></transp><cobr><fat><nFat>0508399</nFat><vOrig>2454.02</vOrig><vLiq>2454.02</vLiq></fat><dup><nDup>001</nDup><dVenc>2019-05-15</dVenc><vDup>817.92</vDup></dup><dup><nDup>002</nDup><dVenc>2019-05-22</dVenc><vDup>817.92</vDup></dup><dup><nDup>003</nDup><dVenc>2019-05-29</dVenc><vDup>818.18</vDup></dup></cobr><pag><detPag><tPag>15</tPag><vPag>2454.02</vPag></detPag></pag><infAdic><infCpl>.ALIQUOTA DO IPI = 0 ( ZERO ) CONFORME DECR. 7660, DE 23/12/2011. ATENCAO: Caso nao receba o boleto bancario, solicitar atraves do fone: (47) 3372-5000 ou email: financeiro.acr@zanotti.com.br. O nao recebimento do boleto nao isenta o onus e outras despesas. ** PES=Poliester PA=Poliamida ED=Elastodieno EL=Elastano ELAST=Elastico MT=Metalizado ** PedCli: 986365/ ** PedRepres: 26586 ** Tipo de Frete: FOB IMPORTANTE: O PRAZO MAXIMO PARA ABRIR QUALQUER RECLAMACAO OU DEVOLUCAO DO(S) PRODUTO(S) RELACIONADO(S) NESTE DOCUMENTO E DE 30 DIAS A PARTIR DO RECEBIMENTO DO(S) MESMO(S). ATENCAO: CASO NAO RECEBA O BOLETO BANCARIO, SOLICITAR ATRAVES DO FONE: (47) 3372-5000 OU E-MAIL: FINANCEIRO.ACR@ZANOTTI.COM.BR. O NAO RECEBIMENTO DO BOLETO NAO ISENTA O ONUS E OUTRAS DESPESAS.</infCpl></infAdic><compra><xPed>986365</xPed></compra></infNFe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" /><Reference URI="#NFe42190578256336000107550040005083991422084340"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" /><DigestValue>uo9h1zuZYqqPAPdLvaQuBedhfyc=</DigestValue></Reference></SignedInfo><SignatureValue>PAnzMHxvHS2u7i7D+1CZLjsubP616JWGPvmXxw3jcSRUo1S/NoPkLr4rawjI3EEJWg/fCSvaHftbFXxVEBZCuAKW/EAQrqV2GmeZFrDr+Z1Id/J5vrchVj3FQug48NWJp21n8jETuAwRepDrbx7fg5M7neZLCa22wHNpuXVaMl0=</SignatureValue><KeyInfo><X509Data><X509Certificate>MIICOTCCAaKgAwIBAgIQJpLn3fwH17RNXJHw5VenaDANBgkqhkiG9w0BAQUFADBbMVkwVwYDVQQDHlAAdwB3AHcALgBmAHMAaQBzAHQALgBjAG8AbQAuAGIAcgAgACgAUwBFAE0AIABWAEEATABJAEQAQQBEAEUAIABKAFUAUgDNAEQASQBDAEEAKTAeFw0xNTEyMjQwODI1MjVaFw0xODEyMjQwODI1MjVaMFsxWTBXBgNVBAMeUAB3AHcAdwAuAGYAcwBpAHMAdAAuAGMAbwBtAC4AYgByACAAKABTAEUATQAgAFYAQQBMAEkARABBAEQARQAgAEoAVQBSAM0ARABJAEMAQQApMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDX4BYmJiNwrPz9At2ioXYkMuMWAOf669VPS3SAzIKkJLhSE7Bf9sbTjGHRFZhs6STxKkMBKKnx6dqAEMGlQwDSU42/kqhGya28SUn3HigH2w3dR/536Gt4eAxyLp9ODNXUqWTpnraWCeT41kcnJ27cmOAUMxzxDcsA93n32L4u8wIDAQABMA0GCSqGSIb3DQEBBQUAA4GBAAN89zf+wSFL+4+2Ic8mGva8Z51EzYzNgYEqXwEMHxw4jCxxbsuxewQWedSGWi3SFZla6zmNUEA+UO95tSZ353klTvWDzut2BFSJOPLcMu8HPTTdnMt4ofVeVqKyi2vp+3t78vjqDAAfSAu5C9wT7stoUx41Nok+L6WbmpOIgvHy</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe versao="4.00"><infProt><tpAmb>1</tpAmb><verAplic>5.0</verAplic><chNFe>42190578256336000107550040005083991422084340</chNFe><dhRecbto>2019-05-08T18:45:03-03:00</dhRecbto><nProt>342190065784882</nProt><digVal>Yy181+hxjWZVWa+yeJrQowXVVL4=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>
')
SELECT peso_liquido, remetente_id  FROM scr_notas_fiscais_imp WHERE chave_nfe = '35190520064155000107550010000421561102030403'

SELECT id_conhecimento FROM scr_conhecimento WHERE numero_ctrc_filial = '0010010000005'
SELECT * FROM scr_conhecimento_notas_fiscais WHERE id_conhecimento = 17332
COMMIT;
ROLLBACK;


SELECT fpy_parse_xml_nfe(doc_xml), doc_xml, chave_doc, data_recebimento FROM scr_doc_integracao WHERE tipo_doc = 2 LIMIT 1 chave_doc = '32180604307650001379550130000287161691788439'



SELECT fpy_parse_xml_nfe('<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe versao="4.00" Id="NFe52190508070566001254550010000667911660936966"><ide><cUF>52</cUF><cNF>66093696</cNF><natOp>Vda combustivel lubrificante prod.estab. dest.com.</natOp><mod>55</mod><serie>1</serie><nNF>66791</nNF><dhEmi>2019-05-04T12:24:27-03:00</dhEmi><tpNF>1</tpNF><idDest>1</idDest><cMunFG>5213103</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>6</cDV><tpAmb>1</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>9</indPres><procEmi>0</procEmi><verProc>SAP NFE 10.0</verProc></ide><emit><CNPJ>08070566001254</CNPJ><xNome>Brenco Companhia Brasileira de Energia Renovavel</xNome><xFant>Brenco Morro Vermelho</xFant><enderEmit><xLgr>Rodovia GO 341 - KM 67 a Direita KM 13</xLgr><nro>SN</nro><xBairro>Zona Rural</xBairro><cMun>5213103</cMun><xMun>Mineiros</xMun><UF>GO</UF><CEP>75830000</CEP><cPais>1058</cPais><xPais>Brasil</xPais></enderEmit><IE>104321911</IE><CRT>3</CRT></emit><dest><CNPJ>34274233030605</CNPJ><xNome>PETROBRAS DISTRIBUIDORA S A</xNome><enderDest><xLgr>AV BRUXELAS</xLgr><nro>300</nro><xBairro>JARDIM NOVO MUNDO</xBairro><cMun>5208707</cMun><xMun>GOIANIA</xMun><UF>GO</UF><CEP>74703050</CEP><cPais>1058</cPais><xPais>Brasil</xPais></enderDest><indIEDest>1</indIEDest><IE>100496725</IE><email>xmlnfebr@br.com.br</email></dest><autXML><CNPJ>13937073000156</CNPJ></autXML><det nItem="1"><prod><cProd>000000000000200870</cProd><cEAN>SEM GTIN</cEAN><xProd>ETANOL HIDRATADO</xProd><NCM>22071090</NCM><CFOP>5652</CFOP><uCom>L</uCom><qCom>59568.0000</qCom><vUnCom>2.0323332998</vUnCom><vProd>121062.03</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>L</uTrib><qTrib>59568.0000</qTrib><vUnTrib>2.0323332998</vUnTrib><indTot>1</indTot><xPed>4502807447</xPed><comb><cProdANP>810101001</cProdANP><descANP>ETANOL HIDRATADO COMUM</descANP><qTemp>26.7000</qTemp><UFCons>GO</UFCons></comb></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>121062.03</vBC><pICMS>25.0000</pICMS><vICMS>30265.51</vICMS></ICMS00></ICMS><IPI><qSelo>000000000000</qSelo><cEnq>999</cEnq><IPINT><CST>53</CST></IPINT></IPI><PIS><PISQtde><CST>03</CST><qBCProd>59.5680</qBCProd><vAliqProd>23.3800</vAliqProd><vPIS>1392.70</vPIS></PISQtde></PIS><COFINS><COFINSQtde><CST>03</CST><qBCProd>59.5680</qBCProd><vAliqProd>107.5200</vAliqProd><vCOFINS>6404.75</vCOFINS></COFINSQtde></COFINS></imposto></det><total><ICMSTot><vBC>121062.03</vBC><vICMS>30265.51</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>121062.03</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>1392.70</vPIS><vCOFINS>6404.75</vCOFINS><vOutro>0.00</vOutro><vNF>121062.03</vNF></ICMSTot></total><transp><modFrete>1</modFrete><transporta><CNPJ>00183277000520</CNPJ><xNome>PRIMAVERA DIESEL LTDA</xNome><IE>104416335</IE><xEnder>AV BRUXELAS 587, QDR 254</xEnder><xMun>GOIANIA</xMun><UF>GO</UF></transporta></transp><cobr><fat><nFat>0090024740</nFat><vOrig>121062.03</vOrig><vLiq>121062.03</vLiq></fat><dup><nDup>001</nDup><dVenc>2019-05-10</dVenc><vDup>121062.03</vDup></dup></cobr><pag><detPag><tPag>99</tPag><vPag>121062.03</vPag></detPag></pag><infAdic><infCpl>** ICMS TRIBUTADO CONFORME PREVISAO DO ART. 20, VIII DO RCTE/GO** SAIDA NAO TRIBUTADA NOS TERMOS DO DEC. 8. 950/16**ANP 102019 CP 6791 E 6792**DESCRICAO LONGA DO PRODUTO: 200870 - COMBUSTIVEL LIQUIDOTIPO COMBUSTIVEL: ETANOLCOMPLEMENTO: HIDRATADODECLARAMOS QUE O PRODUTO ESTA ADEQUADAMENTE ACONDICIONADO PARA SUPORTAR OS RISCOS NORMAIS CARREGAMENTO, DESCARREGAMENTO ETRANSPORTE, CONFORME REGULAMENTACAO EM VIGOR, ART.22 INCISO II DECRETO 96.044/88,CARACTERISTICAS ADICIONAIS: CLASSE OU SUBCLASSE RISCO - 3 - GRUPO EMBALAGEM II,DESCRICAO CLASSE OU SUBCLASSE RISCO - LIQUIDO INFLAMAVEL,NUMERO ONU - 1170,NUMERO RISCO - 33**N(o) DA ORDEM DE COMPRA: 4502807447**PEDIDO DE VENDA: 0000012100**N(o) CONTRATO: 0000000158**COD. ANP: 810101001**LACRES: 1123561 1123562 1123563 1123564 1123565 1123566 1123567 1123568 AMOSTRA 1123569**MOTORISTA: KLEBER DE OLIVEIRA CPF DO MOTORISTA: 41499280106**LAUDO: 28572**PLACA DO VEICULO: ONC8539 UF: GO**PLACA REBOQUE : OMO4008 UF: GO ** PLACA REBOQUE : OMO4048 UF: GO COD. ANP: 810101001</infCpl></infAdic></infNFe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#NFe52190508070566001254550010000667911660936966"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>FxmYpPd558hA3PLWNQsIYFghW4I=</DigestValue></Reference></SignedInfo><SignatureValue>FXvk+HdkAMl4JcsrhEIKVKE24dfluQvKFU3YzeLchxOX9HZ5UD+16OKVw4Wkgr60Ur2N5pJjpQ2U
bUQFdkFbk0MgDSzhN9/ghu0a2C6ZFAd5P0HrrMY8DR9LYD71ac3f5Q+Ltn1hZm6BPiRDx9b4+2/k
5f3YF8qDoIXUCkf8NQZnJrgET95AcJb8xsD2pCckJbG41H1RDamr0VOfff3fVmcixeOVBNBlOeh5
H3E9yuOnBIOfVWU8kKh00KN4Yv9Eqha/Sy9pV8GD+I5zWzA4oroIkya1gOWdlU9kpwIxMsWBcC6d
Pux/a5eGgYbDKKpOAz9gAEjNzCSZojwehDzqtA==</SignatureValue><KeyInfo><X509Data><X509Certificate>MIIHwjCCBaqgAwIBAgIIeOW2kom8HY0wDQYJKoZIhvcNAQELBQAwdjELMAkGA1UEBhMCQlIxEzAR
BgNVBAoTCklDUC1CcmFzaWwxNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEgUmVjZWl0YSBGZWRlcmFs
IGRvIEJyYXNpbCAtIFJGQjEaMBgGA1UEAxMRQUMgU0FGRVdFQiBSRkIgdjUwHhcNMTkwMzI4MTgx
MjA1WhcNMjAwMzI4MTgxMjA1WjCB+DELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwx
CzAJBgNVBAgTAlNQMRIwEAYDVQQHEwlTQU8gUEFVTE8xNjA0BgNVBAsTLVNlY3JldGFyaWEgZGEg
UmVjZWl0YSBGZWRlcmFsIGRvIEJyYXNpbCAtIFJGQjEWMBQGA1UECxMNUkZCIGUtQ05QSiBBMTEZ
MBcGA1UECxMQQVIgREdTIENFUlRJRklDQTFIMEYGA1UEAxM/QlJFTkNPIENPTVBBTkhJQSBCUkFT
SUxFSVJBIERFIEVORVJHSUEgUkVOT1ZBVkVMOjA4MDcwNTY2MDAwMTAwMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA7tLuHgmoOoglUfSP7K9CvSWNy56g1Tx1Ou8XcZ+uHq7sIgt6ymgO
TVnOnzn6xDuvNBc7cz8uUppW06rHOXuVnXWXuh6baxl5w3/8AXHMPlCTUpmqEqVYVOkZe9WstNeT
AWAbF4ZGu3B5z3FQm63rGcjzf3BNUWdTKRNr5c91PYHzjwUKTOC6LGTJye9X6kSONk0s6YBZzpZB
d5jYl6l64paYZupHrlYbTmCJag+6Gft5++w00zzbaMhebQ9DEYoTc7OHSbN1Q9mPD3YKReKfkXuR
c71f5Mkto6YIsC4ajEm15GglOanObIitq8g4F8tMaNQ2IFVLQKZ5/PsbmInC5wIDAQABo4ICzzCC
AsswHwYDVR0jBBgwFoAUKV5L1UZMu/4Wp2PBHcQm8t3Y8wUwDgYDVR0PAQH/BAQDAgXgMG0GA1Ud
IARmMGQwYgYGYEwBAgEzMFgwVgYIKwYBBQUHAgEWSmh0dHA6Ly9yZXBvc2l0b3Jpby5hY3NhZmV3
ZWIuY29tLmJyL2FjLXNhZmV3ZWJyZmIvYWMtc2FmZXdlYi1yZmItcGMtYTEucGRmMIGuBgNVHR8E
gaYwgaMwT6BNoEuGSWh0dHA6Ly9yZXBvc2l0b3Jpby5hY3NhZmV3ZWIuY29tLmJyL2FjLXNhZmV3
ZWJyZmIvbGNyLWFjLXNhZmV3ZWJyZmJ2NS5jcmwwUKBOoEyGSmh0dHA6Ly9yZXBvc2l0b3JpbzIu
YWNzYWZld2ViLmNvbS5ici9hYy1zYWZld2VicmZiL2xjci1hYy1zYWZld2VicmZidjUuY3JsMIGL
BggrBgEFBQcBAQR/MH0wUQYIKwYBBQUHMAKGRWh0dHA6Ly9yZXBvc2l0b3Jpby5hY3NhZmV3ZWIu
Y29tLmJyL2FjLXNhZmV3ZWJyZmIvYWMtc2FmZXdlYnJmYnY1LnA3YjAoBggrBgEFBQcwAYYcaHR0
cDovL29jc3AuYWNzYWZld2ViLmNvbS5icjCBvwYDVR0RBIG3MIG0gRtOQVRBTElBLk1BUkNISUBB
VFZPUy5DT00uQlKgJwYFYEwBAwKgHhMcQUxFWEFORFJFIFBFUkFaWk8gREUgQUxNRUlEQaAZBgVg
TAEDA6AQEw4wODA3MDU2NjAwMDEwMKA4BgVgTAEDBKAvEy0wNTA5MTk3NTY0MTkxMzYyNTM0MDAw
MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDCgFwYFYEwBAwegDhMMMDAwMDAwMDAwMDAwMB0GA1UdJQQW
MBQGCCsGAQUFBwMCBggrBgEFBQcDBDAJBgNVHRMEAjAAMA0GCSqGSIb3DQEBCwUAA4ICAQCU3jUw
8SvZOJwKGL+nyUHof9zF1tSPY7moIB7h196jAWLlthNRQyktN2i16YS2IqPieZj/i4B7koYzGIYR
VaaGO0/WZam7ENJwrpeSxJ3yyMRsyEE0NxiBUSm/xJm3MpfOdlZ5DkIQiE98S85knBb8n28HQ+cM
3LMaGAreNq4Kuye/coABcScJSx/VL42U1MlvfYWsOwOdtxZXHH5YgGFsSc/DzZ+g8cm3NwFPZ2IF
sw+zSNWj/7+WZwlDp/BUQCFX9wL9yIJFoA44NsmBmvcwr26jI8LEYX88j9mm/cXFTKkuQ7Qe2Fps
QPoEoxGfWyoCdkUTgnEbPXcl+BEZpYJYBqeExs5UM/8/1eFx9PIrKKao8i8M3UrkB+uzZkqgSney
scoY80zHNURBxQo8GLl4dczvSswUz+T2C5HaoLaK5ymnxeo6lToIs6AJoB4Z+rX0IkXhNVpQgVxY
Qn9x5ZzrkjsYZGj2MG5of05tV5WmTB+q72PK/BVcaSppJ5K+gizBefEnrCqcMvs6GDLemaPqCmq9
YxKEUE9A+mUuQhuVlNYv1SwA3TZsJF2KsRD8WlpWIuDCMHwQJWJy5Fpa6Aba0cXVii/i+RfE/uYK
6z5kdrXJoEFiR2Zaxb49mND/JtDe5eTYRhK7V7M6AP7wU0JwwsadMZP10dCNYx7krW/Ycw==</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00"><infProt Id="NFe00"><tpAmb>1</tpAmb><verAplic>GO4.0</verAplic><chNFe>52190508070566001254550010000667911660936966</chNFe><dhRecbto>2019-05-04T12:24:38-03:00</dhRecbto><nProt>152192169408449</nProt><digVal>FxmYpPd558hA3PLWNQsIYFghW4I=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>');

*/

CREATE OR REPLACE FUNCTION public.fpy_parse_xml_nfe(xml text)
  RETURNS json AS
$BODY$
import xmltodict
import json 
import traceback

#a = open('C:\\Python\\projetos\\parse_nfe_xml\\31150771015853000145550020000619111004309337.xml')
#a = open('C:\\Python\\projetos\\parse_nfe_xml\\teste.xml')

xml2 = xml.replace('version=1.0','version="1.0"')
xml2 = xml2.replace('encoding=UTF-8','encoding="UTF-8"')
xml2 = xml2.replace('</nfeProc>>','</nfeProc>')

             
if xml2.find('<?xml version="1.0" encoding="utf-8"?><NFe') > -1:
    xml2 = xml2.replace('<?xml version="1.0" encoding="utf-8"?><NFe','<?xml version="1.0" encoding="utf-8"?><nfeProc><NFe')
    xml2 = xml2 + '</nfeProc>'

if xml2.find('nfeProc') == -1:
    
    if not (xml2.find('<nNF>') == -1):
        plpy.notice('Nao achou <nfeProc>')
        xml2 = xml2.replace('<NFe','<nfeProc><NFe').replace('</NFe>','</NFe></nfeProc>')
        
        
try:
    xml_nfe = xmltodict.parse(xml2)
except:
    return None


try:
    info = {}
    info['chave_nfe'] = xml_nfe['procEventoNFe']['evento']['infEvento']['chNFe']
    info['tp_evento']  = xml_nfe['procEventoNFe']['retEvento']['infEvento']['tpEvento']
    info['cstat'] = xml_nfe['procEventoNFe']['retEvento']['infEvento']['cStat']
    plpy.notice(str(info))
    if info.get('tp_evento') == '110111' and info.get('cstat') == '135':
        retorno = json.dumps(info)
        return retorno
except: 
    plpy.notice('Deu erro aqui')   
    plpy.notice(traceback.format_exc())


    
p = dict()
nfe = dict()
#a.close()

try:
    valida = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['xNome']
except:
    return None



lst_part = []


#Dados do Emitente/Remetente
try:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['CPF']

emit_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['xNome'].replace('&','e')
p['part_logradouro'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['xLgr'].replace('&','e')
p['part_numero'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['nro']
p['part_bairro'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['cMun']
emit_cod_mun = p['part_cod_mun']
p['part_uf'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit']['UF']
p['part_cep'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('CEP')
p['part_pais'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('xPais')
p['part_fone'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['enderEmit'].get('fone')
p['part_ie'] = xml_nfe['nfeProc']['NFe']['infNFe']['emit']['IE']
lst_part.append(p)

#Dados do Destinatario
p = dict()

try:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['CNPJ']
except:
    p['part_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('CPF')


    

dest_cnpj = p['part_cnpj_cpf']

p['part_nome'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['xNome'].replace('&','e')
p['part_logradouro'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['xLgr'].replace('&','e')
p['part_numero'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['nro']
p['part_bairro'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['xBairro'].replace('&','e')
p['part_cod_mun'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['cMun']
dest_cod_mun = p['part_cod_mun']
p['part_uf'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest']['UF']
p['part_cep'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('CEP')
p['part_pais'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('xPais')
p['part_fone'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest']['enderDest'].get('fone')
try:
    p['part_ie'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('IE')
except:
    pass
p['part_email'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('email')
lst_part.append(p)

#dados da Nota Fiscal

n = {}

##Chave da NFe
try:
    n['nfe_chave_nfe'] = xml_nfe['nfeProc']['protNFe']['infProt']['chNFe']
except:
    try:
        n['nfe_chave_nfe'] = xml_nfe['nfeProc']['NFe']['infNFe']['@Id'][-44:]
    except:
        pass

##informacoes de remetente/destinatario
n['nfe_emit_cnpj_cpf'] = emit_cnpj
n['nfe_emit_cod_mun']  = emit_cod_mun
n['nfe_dest_cnpj_cpf'] = dest_cnpj
n['nfe_dest_cod_mun']  = dest_cod_mun

##informacoes gerais
onf = xml_nfe['nfeProc']['NFe']['infNFe']['ide']
n['nfe_data_emissao_hr'] = onf.get('dhEmi')
n['nfe_data_emissao'] = onf.get('dhEmi')
n['nfe_pagador_cnpj_cpf'] = onf.get('pagador_cnpj')

try:
    n['nfe_id_nota_fiscal_parceiro'] = onf.get('id_nota_fiscal_parceiro')
    n['nfe_codigo_softlog_parceiro'] = onf.get('codigo_softlog_parceiro')
    n['nfe_id_conhecimento_notas_fiscais'] = onf.get('id_conhecimento_notas_fiscais')
    n['nfe_id_conhecimento_parceiro'] = onf.get('id_conhecimento_parceiro')
    n['nfe_codigo_integracao'] = onf.get('codigo_integracao')
    n['chave_cte'] = onf.get('chave_cte')
except:
    pass

if n['nfe_data_emissao'] is None:
    n['nfe_data_emissao'] = onf.get('dEmi')
n['nfe_numero_doc'] = onf.get('nNF')
n['nfe_modelo'] = onf.get('mod')
n['nfe_serie'] = onf.get('serie')
n['nfe_tp_nf'] = onf.get('tpNF')
n['nfe_ind_final'] = onf.get('indFinal')
n['nfe_ie_dest'] = xml_nfe['nfeProc']['NFe']['infNFe']['dest'].get('indIEDest')
n['nfe_origem_cod_mun']  = onf.get('cMunIni')
try:
    info = xml_nfe['nfeProc']['NFe']['infNFe']['infAdic']['infCpl']    
except:
    info = ""
    pass

try:
    natop = onf.get('natOp').upper()
except:
    natop = None
    
##valores
onf = xml_nfe['nfeProc']['NFe']['infNFe']['total']['ICMSTot']

if natop == 'INDUSTRIALIZACAO':
    n['nfe_valor'] = '0.00'
    n['nfe_valor_produtos'] = '0.00'
else:
    n['nfe_valor'] = onf.get('vNF')
    n['nfe_valor_produtos'] = onf.get('vProd')

    
n['nfe_valor_bc'] = onf.get('vBC')
n['nfe_valor_icms'] = onf.get('vICMS')
n['nfe_valor_bc_st'] = onf.get('vBCST')
n['nfe_valor_icms_st'] = onf.get('vST')


##informacoes relativas ao transporte
try:
    n['nfe_transportador_cnpj_cpf'] = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['transporta'].get('CNPJ')
except:
    pass

try:
    n['nfe_modo_frete'] = xml_nfe['nfeProc']['NFe']['infNFe']['transp'].get('modFrete')
except:
    pass

try:
    placa = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['placa']
    n['nfe_placa_veiculo'] = placa[0:8]
except:
    pass

try:
    #Em alguns casos reboque pode ser uma lista com mais de um veiculo
    onf = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['reboque']
    if str(type(onf)) == "<class 'list'>":
        reboque1 = onf[0].get('placa')
    else:
        reboque1 = onf.get('placa')

    n['nfe_placa_reboque1'] = reboque1[0:8]

except:
    pass

try:
    reboque2 = xml_nfe['nfeProc']['NFe']['infNFe']['transp']['veicTransp']['reboque'][1]['placa']
    n['nfe_placa_reboque1'] = reboque2[0:8]
except:
    pass

## Coleta de dados
peso_presumido = '0 '
peso_liquido = '0 '
vol_presumido = '0 '

try:
    #Em alguns casos, vol pode vir em mais de um item
    onf = xml_nfe['nfeProc']['NFe']['infNFe']['transp'].get('vol')

    if str(type(onf)) == "<class 'list'>":
        for v in onf:
            peso_item = v.get('pesoB') or v.get('pesoL') or '0'
            peso_liquido_item = v.get('pesoL') or v.get('pesoB') or '0'
            vol_item = v.get('qVol') or '0'

            peso_presumido = peso_presumido + ' + ' + peso_item
            peso_liquido = peso_liquido + ' + ' + peso_liquido_item
            vol_presumido = vol_presumido + ' + ' + vol_item
    else:
            peso_item = onf.get('pesoB') or onf.get('pesoL') or '0'
            peso_liquido_item = onf.get('pesoL') or onf.get('pesoB') or '0'
            vol_item = onf.get('qVol') or '0'

            peso_presumido = peso_presumido + ' + ' + peso_item
            peso_liquido = peso_liquido + ' + ' + peso_liquido_item
            vol_presumido = vol_presumido + ' + ' + vol_item
except:
    pass

if natop == 'INDUSTRIALIZACAO':
    n['nfe_peso_presumido'] = '0.00'
    n['nfe_peso_liquido'] = '0.00'
    n['nfe_volume_presumido'] = '0.00'
else:
    n['nfe_peso_presumido'] = peso_presumido
    n['nfe_peso_liquido'] = peso_liquido
    n['nfe_volume_presumido'] = vol_presumido



## Informacoes dos Itens de Produto
peso = '0 '
volume = '0 '
especie_mercadoria = '0 '
cfop = None
lst_unidades = []

onf = xml_nfe['nfeProc']['NFe']['infNFe']['det']

descProd = ""
#Testa se tem mais de um produto
if str(type(onf)) == "<class 'list'>":
    for prod in onf:
        peso_item = prod['prod'].get('qCom')
        peso = peso + ' + ' + peso_item

        unidade = prod['prod'].get('uCom')
        if unidade not in lst_unidades:
            lst_unidades.append(unidade)

        cfop = cfop or prod['prod'].get('CFOP')

        try:
            xprod = prod['prod']['xProd']
            descProd = descProd + ' - ' + xprod.replace("'","")
        except:
            descProd = ""
else:
        peso_item = onf['prod'].get('qCom')
        peso = peso +  '+' + peso_item

        unidade = onf['prod'].get('uCom')
        if unidade not in lst_unidades:
            lst_unidades.append(unidade)

        cfop = cfop or onf['prod'].get('CFOP')

        try:
            xprod = onf['prod']['xProd']
            descProd = descProd + ' - ' + xprod.replace("'","")
        except:
            descProd = ""

if info is None:
    info = ""
    
n['nfe_informacoes'] = info.replace("'","") + ' - ' + descProd



n['nfe_volume_produtos'] = peso
n['nfe_peso_produtos'] = peso
try:
    n['nfe_unidade'] = lst_unidades[0]
except:
    n['nfe_unidade'] = 'UN'

n['nfe_especie_mercadoria'] = ','.join(lst_unidades)
n['nfe_especie_mercadoria'] = n['nfe_especie_mercadoria'][0:30]
n['nfe_cfop_predominante'] = cfop	

nfe['dados_nota'] = n
nfe['remetente'] = lst_part[0]
nfe['destinatario'] = lst_part[1]

retorno = json.dumps(nfe)
return retorno
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_parse_xml_nfe(xml text)  OWNER TO softlog_unitylog;