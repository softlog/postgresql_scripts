
--DELETE FROM edi_sefaz_docs WHERE tipo_documento = 'ROMANEIO_CANCELAMENTO'
INSERT INTO edi_sefaz_docs (nome_leiaute, tipo_documento, versao_leiaute, inicio, fim, descricao_leiaute, funcao_responsavel, leiaute)
VALUES ('XML CANCELAMENTO ROMANEIO ATM', 'ROMANEIO_CANCELAMENTO', '3.0','2020-01-01', NULL, 'XML do Romaneio Cancelado para Averbação ATM','f_get_xml_sefaz_romaneio_cancelamento',
'<retCancCTe xmlns=”http://www.portalfiscal.inf.br/cte” versao=”1.04”>
    <infCanc>
        <tpAmb>{{dados.tpamb}}</tpAmb>
        <cUF>{{dados.cuf}}</cUF>
        <verAplic>99</verAplic>
        <cStat>101</cStat>
        <xMotivo>Cancelamento de CT-e homologado</xMotivo>
        <chCTe>{{dados.protocolo}}</chCTe>
        <dhRecbto>{{dados.data_recebimento}}</dhRecbto>
        <nProt>{{dados.protocolo}}</nProt>
    </infCanc>
</retCancCTe>')