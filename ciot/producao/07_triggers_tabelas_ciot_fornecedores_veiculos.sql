CREATE TRIGGER tgg_scr_ciot
AFTER INSERT OR UPDATE 
ON scr_ciot
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_ciot();


CREATE TRIGGER tgg_efrete_fornecedores
AFTER INSERT OR UPDATE 
ON fornecedores
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_ciot();

CREATE TRIGGER tgg_efrete_veiculos
AFTER INSERT OR UPDATE 
ON veiculos
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_ciot()

CREATE TRIGGER tgg_efrete_pagamentos
AFTER INSERT OR UPDATE 
ON scr_ciot_pagamentos
FOR EACH ROW
EXECUTE PROCEDURE f_tgg_scr_ciot()
