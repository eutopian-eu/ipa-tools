-- sqlite

create table ipa (
    cod_amm text,
    des_amm text,
    Comune text,
    nome_resp text,
    cogn_resp text,
    Cap text,
    Provincia text,
    Regione text,
    sito_istituzionale text,
    Indirizzo text,
    titolo_resp text,
    tipologia_istat text,
    tipologia_amm text,
    acronimo text,
    cf_validato text,
    Cf text,
    mail1 text,
    tipo_mail1 text,
    mail2 text,
    tipo_mail2 text,
    mail3 text,
    tipo_mail3 text,
    mail4 text,
    tipo_mail4 text,
    mail5 text,
    tipo_mail5 text,
    url_facebook text,
    url_twitter text,
    url_linkedin text,
    url_youtube text,
    liv_accessibili text
);

create unique index i_cod_amm on ipa(cod_amm);

.separator "\t"

.import ipa ipa
