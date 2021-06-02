ALTER TABLE msg_fila_edi ADD COLUMN proximo_processamento timestamp;
ALTER TABLE msg_fila_edi ADD COLUMN qt_tentativas integer DEFAULT 0;