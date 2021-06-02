CREATE OR REPLACE FUNCTION fpy_get_divs_canhoto(p_urls text)
  RETURNS text AS
$BODY$

tpl_url = """<div class=container style="
									display: flex;
									flex-direction: row;
									justify-content: center;">
			<div>
				<div style="margin-top: -80;margin-bottom: -80;"><a href="%(url)s">
						<img src="%(url)s" alt="Imagem do Documento" style="transform: rotate(-90deg);" width="600" height="855">
				</a></div>
				<div style="text-align: center;">
					<button onclick="window.location.href='%(url)s'">Visualizar Imagem do Documento.</button>
				</div>
			</div>            
</div>"""

urls = p_urls.split(",")
divs = []
for url in urls:
    d = {}
    d["url"] = url
    div = tpl_url % (d)
    divs.append(div)

v_retorno = "\n".join(divs)

return v_retorno
$BODY$
  LANGUAGE plpython3u VOLATILE;
