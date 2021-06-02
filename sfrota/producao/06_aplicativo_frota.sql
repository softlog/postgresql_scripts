ALTER TABLE com_produtos ADD COLUMN aplicativo_frota integer DEFAULT 0;

INSERT INTO com_produtos (descr_item, id_unidade, aplicativo_frota)
VALUES ('ESTERCO',1,1);

INSERT INTO com_produtos (descr_item, id_unidade, aplicativo_frota)
VALUES ('ADUBO',1,1);

INSERT INTO com_produtos (descr_item, id_unidade, aplicativo_frota)
VALUES ('DESCARTE',1,1);

INSERT INTO com_produtos (descr_item, id_unidade, aplicativo_frota)
VALUES ('OUTROS',1,1);