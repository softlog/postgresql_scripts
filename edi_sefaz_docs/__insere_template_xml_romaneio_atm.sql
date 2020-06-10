
INSERT INTO edi_sefaz_docs (nome_leiaute, tipo_documento, versao_leiaute, inicio, fim, descricao_leiaute, funcao_responsavel, leiaute)
VALUES ('XML ROMANEIO ATM', 'ROMANEIO', '3.0','2020-01-01', NULL, 'XML do Romaneio para Averbação ATM','f_get_xml_sefaz_romaneio',
'<?xml version="1.0" encoding="UTF-8"?>
<cteProc>
    <CTe>
        <infCte>
            <ide>
               
                <mod>{{dados.mod}}</mod>
                <serie>{{dados.serie}}</serie>
                <nCT>{{dados.nct}}</nCT>
                <dhEmi>{{dados.dhemi}}</dhEmi>               
                <tpAmb>{{dados.tpamb}}</tpAmb>
                <tpCTe>{{dados.tpcte}}</tpCTe>                
                <modal>{{dados.modal}}</modal>
                <tpServ>{{dados.tpserv}}</tpServ>
                <cMunIni>{{dados.cmunini}}</cMunIni>                
                <UFIni>{{dados.ufini}}</UFIni>
                <cMunFim>{{dados.cmunfim}}</cMunFim>                
                <UFFim>{{dados.uffim}}</UFFim>
                <retira>{{dados.retira}}</retira>
                <indIEToma>{{dados.indietoma}}</indIEToma>
                <toma3>
                    <toma>{{dados.toma}}</toma>
                </toma3>
            </ide>
            <compl>
                <xObs>{{dados.compl_xobs}}</xObs>
                <ObsCont>
                    <xCampo>{{dados.obscont_xcampo}}</xCampo>
                    <xTexto>{{dados.obscont_xtexto}}</xTexto>
                </ObsCont>
            </compl>
            <emit>
                <CNPJ>{{dados.emit_cnpj}}</CNPJ>                
                <enderEmit>                    
                    <cMun>{{dados.emit_enderemit_cmun}}</cMun>                    
                    <UF>{{dados.emit_enderemit_uf}}</UF>
                </enderEmit>
            </emit>
            <rem>
                <CNPJ>{{dados.rem_cnpj}}</CNPJ>                                
                <enderReme>
                    <cMun>{{dados.rem_enderreme_cmun}}</cMun>
                    <UF>{{dados.rem_enderreme_uf}}</UF>
                    <cPais>{{dados.rem_enderreme_cpais}}</cPais>
                </enderReme>
            </rem>
            <dest>
                {% if dados.tipo_pessoa_dest == 1 %}
                <CPF>{{dados.dest_cpf}}</CPF>                
                {% else %}
                <CPF>{{dados.dest_cnpj}}</CPF>                
                {% endif %}
                <enderDest>
                    <cMun>{{dados.dest_enderdest_cmun}}</cMun>
                    <UF>{{dados.dest_enderdest_uf}}</UF>
                    <cPais>{{dados.dest_enderdest_cpais}}</cPais>
                </enderDest>
            </dest>
            <infCTeNorm>
                <infCarga>
                    <vCarga>{{dados.infcarga_vcarga}}</vCarga>                    
                </infCarga>                
                <seg>
                    <respSeg>{{dados.responsavel_seguro}}</respSeg>
                    <vCarga>{{dados.seg_vcarga}}</vCarga>
                </seg>
            </infCTeNorm>		
        </infCte>
    </CTe>
</cteProc>')