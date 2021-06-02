-- Function: public.fpy_get_doc_doria(text)
-- DROP FUNCTION public.fpy_get_doc_doria(text);
CREATE OR REPLACE FUNCTION public.fpy_get_doc_vtex(arquivo text)
  RETURNS json AS
$BODY$


    import traceback
    import json
    from doc_parser import DocParser
    from decimal import Decimal

    def get_viacep(cep):
        r = plpy.execute("SELECT cod_ibge FROM cep WHERE cep = '%s'"%(cep))
        if (r.nrows() > 0):
            #plpy.notice('Encontrei Cep %s' % cep)
            return r[0]['cod_ibge']
        else:
            #plpy.notice('Nao Encontrei Cep %s' % cep)
            return ''

    order = json.loads(arquivo)

    p = {}

    p['part_nome'] = order['clientProfileData']['firstName'] + " " + order['clientProfileData']['lastName']
    p['part_cnpj_cpf'] = order['clientProfileData']['document']
    if p['part_cnpj_cpf'] is None:
        p['part_cnpj_cpf'] = order['clientProfileData']['corporateDocument']
        
    p['part_email'] = order['clientProfileData']['email']
    p['part_fone'] = order['clientProfileData']['phone']
    p['part_logradouro'] = order['shippingData']['selectedAddresses'][0]['street']
    p['part_numero'] = order['shippingData']['selectedAddresses'][0].get('number')
    p['part_bairro'] = order['shippingData']['selectedAddresses'][0].get('neighborhood')
    p['part_cep'] = order['shippingData']['selectedAddresses'][0].get('postalCode').replace("-","")
    p['part_complemento'] = order['shippingData']['selectedAddresses'][0].get('complement')
    p['part_cidade'] = order['shippingData']['selectedAddresses'][0].get('city')
    p['part_cod_mun'] = ''
    p['part_subscricao'] = '4'

    if p['part_cod_mun'].strip() == '':
        try:
            p['part_cod_mun'] = get_viacep(p['part_cep'])
        except:
            pass

    dest_cod_mun = p['part_cod_mun']

    c = order['shippingData']['selectedAddresses'][0].get('geoCoordinates')
   
    if c is not None:
        try:
            p['part_latitude'] = c[1]
            p['part_longitude'] = c[0]
        except:
            pass


    dest_cnpj_cpf = p['part_cnpj_cpf']

    nf = {}

    nf['nfe_numero_pedido'] = order['orderId'].replace('-','')
    nf['nfe_dest_cnpj_cpf'] = dest_cnpj_cpf
    nf['nfe_valor'] = str(Decimal(str(order['value']))/100)

    for t in order['totals']:
    
        if t['id'] == "Items":
            nf['nfe_valor_produtos'] = str(Decimal(str(t['value']))/100)

        if t['id'] == 'Shipping':
            nf['nfe_valor_frete'] = str(Decimal(str(t['value']))/100)

    dados = order['packageAttachment']['packages'][0]

    
    nf['nfe_chave_nfe'] = dados['invoiceKey']
    nf['nfe_numero_doc'] = nf['nfe_chave_nfe'][25:25+9]
    nf['nfe_serie'] = nf['nfe_chave_nfe'][22:25]
    emit_cnpj_cpf = nf['nfe_chave_nfe'][6:6+14]
    nf['nfe_emit_cnpj_cpf'] = emit_cnpj_cpf

    nf['nfe_data_emissao'] = order['authorizedDate'][0:10]
    nf['nfe_data_emissao_dh'] = order['authorizedDate']
    nf['nfe_dest_cod_mun']  = dest_cod_mun
    nf['nfe_unidade'] = 'UN'
    nf['nfe_modo_frete'] = '0'

    nf['nfe_previsao_entrega'] = order['shippingData']['logisticsInfo'][0].get('shippingEstimateDate')

    transportadora = order['shippingData']['logisticsInfo'][0].get('deliveryIds')
            
    items = order['items']

    qt_volumes = 0
    qt_peso = Decimal("0.00")
    qt_vol_cubico = Decimal("0.00")

    for item in items:
        qt_volumes = qt_volumes + int(item["quantity"])
        dim = item['additionalInfo'].get('dimension')

        if dim is None:
            continue
        qt_peso =  qt_peso + (Decimal(str(dim["weight"]))/1000)
        qt_vol_cubico =  qt_vol_cubico + (Decimal(str(dim["cubicweight"])))

    nf['nfe_volume_produtos'] = str(qt_volumes)
    nf['nfe_volume_presumido'] = str(qt_volumes)

    nf['nfe_peso'] = str(qt_peso)
    nf['nfe_peso_presumido'] = str(qt_peso)

    nf['nfe_volume_cubico'] = str(qt_vol_cubico)               
    destinatarios = []
    nfs = []

    nfs.append(nf)
    destinatarios.append(p)

    if not (transportadora[0].get('courierId') == '1d2dd12'):
        destinatarios = []
        nfs = []

    if not (dados['invoiceKey'][:2] == '35'):
        destinatarios = []
        nfs = []


    dados = {'participantes':destinatarios,
                 'nfs':nfs
        }
   
    retorno = json.dumps(dados)    
    return retorno
    
$BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;

--ALTER FUNCTION fpy_get_doc_vtex(arquivo text) OWNER TO softlog_dfreire;
