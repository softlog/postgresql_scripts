ALTER TABLE filial ADD COLUMN url_site text;
ALTER TABLE filial ADD COLUMN url_contato text;
ALTER TABLE filial ADD COLUMN dados_contato text;
ALTER TABLE filial ADD COLUMN url_facebook text;
ALTER TABLE filial ADD COLUMN url_linkedin text;


UPDATE filial SET url_site = 'https://assislog.com.br/', url_contato = 'https://assislog.com.br/', url_linkedin = 'https://www.linkedin.com/in/marcos-aur%C3%A9lio-18b40a124' 


SELECT * FROM filial