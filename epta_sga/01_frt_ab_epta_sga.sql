CREATE OR REPLACE FUNCTION fpy_read_epta_sga(arquivo text)
  RETURNS integer AS
$BODY$

from jinja2 import Environment	

et = Environment(
    autoescape=True,    
    trim_blocks=True,
    lstrip_blocks=True)

registros = arquivo.split('\r\n')

for reg in registros:

    a = {}
    a['ident'] = reg[0:1]
    a['ident_veiculo'] = reg[1:11]
    a['hodometro'] = reg[11:21]
    a['horimetro'] = reg[21:31]
    a['ident_custom'] = reg[31:51]
    a['numero_empresa'] = reg[51:54]
    a['numero_filial'] = reg[54:57]
    a['numero_posto'] = reg[57:62]
    a['numero_tanque'] = reg[62:67]
    a['numero_bomba'] = reg[67:72]
    a['numero_bico'] = reg[72:77]
    a['ident_produto'] = reg[77:80]
    a['data_abastecimento'] = reg[80:90]
    a['hora_abastecimento'] = reg[90:98]
    a['id_abastecedor'] = reg[98:117]
    a['quantidade'] = reg[117:128]
    a['cpf_frentista'] = reg[128:142]
    a['cpf_motorista'] = reg[142:156]
    a['valor_unitario'] = reg[156:162]
    a['valor_total'] = reg[162:172]
    a['numero_cupom'] = reg[172:182]
    a['encerrante_bomba'] = reg[182:202]
    a['placa_veiculo'] = reg[202:212]
    a['cnpj_cadastro_posto'] = reg[212:226]
    a['campo_livre'] = reg[226:236]
    a['campo_livre_2'] = reg[236:246]
    a['campo_livre_3'] = reg[246:256]

    tpl_sql = """INSERT INTO frt_ab_epta_sga(
            ident,
            ident_veiculo,
            hodometro,
            horimetro,
            ident_custom,
            numero_empresa,
            numero_filial,
            numero_posto,
            numero_tanque,
            numero_bomba,
            numero_bico,
            ident_produto,
            data_abastecimento,
            hora_abastecimento,
            id_abastecedor,
            quantidade,
            cpf_frentista,
            cpf_motorista,
            valor_unitario,
            valor_total,
            numero_cupom,
            encerrante_bomba,
            placa_veiculo,
            cnpj_cadastro_posto,
            campo_livre,
            campo_livre_2,
            campo_livre_3
        ) VALUES (
            '{{ident}}',
            '{{ident_veiculo}}',
            '{{hodometro}}',
            '{{horimetro}}',
            '{{ident_custom}}',
            '{{numero_empresa}}',
            '{{numero_filial}}',
            '{{numero_posto}}',
            '{{numero_tanque}}',
            '{{numero_bomba}}',
            '{{numero_bico}}',
            '{{ident_produto}}',
            '{{data_abastecimento}}',
            '{{hora_abastecimento}}',
            '{{id_abastecedor}}',
            '{{quantidade}}',
            '{{cpf_frentista}}',
            '{{cpf_motorista}}',
            '{{valor_unitario}}',
            '{{valor_total}}',
            '{{numero_cupom}}',
            '{{encerrante_boma}}',
            '{{placa_veiculo}}',
            '{{cnpj_cadastro_posto}}',
            '{{campo_livre}}',
            '{{campo_livre_2}}',
            '{{campo_livre_3}}'
         );"""
		
    sql_ins = et.from_string(tpl_sql).render(a)
    plpy.notice(sql_ins)
    plpy.execute(sql_ins)


return 1
$BODY$
  LANGUAGE plpython3u VOLATILE;
