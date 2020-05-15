#!/bin/bash

export OPENSSL_CONF=openssl.cnf

ipa_url='https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=amministrazioni.txt'

# download ipa_url (remove header)
curl -s "$ipa_url" | tail -n+2 > ipa

cat <<EOF
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <title>HTTPS per siti PA</title>
  </head>
  <body>
    <p>Last updated on $(date +'%d/%m/%Y %H:%M:%S %Z')</p>
    <table class="table">
    <thead>
      <tr>
        <th scope="col">Codice</th>
        <th scope="col">Descrizione</th>
        <th scope="col">Sito Web</th>
        <th scope="col">HTTPS</th>
      </tr>
    </thead>
    <tbody>
EOF

while IFS= read -r line
do
    IFS=$'\t' read -r -a fields <<<"$line"
    tipologia_amm="${fields[11]}"
    [[ "$tipologia_amm" == 'Organi Costituzionali e di Rilievo Costituzionale' || "$tipologia_amm" == 'Presidenza del Consiglio dei Ministri, Ministeri e Avvocatura dello Stato' ]] || continue

    cod_amm="${fields[0]}"
    des_amm="${fields[1]}"

    >&2 echo "$des_amm"
    url="${fields[8]}"

    # the website of the Ministry of Justice is not up-to-date
    [[ $cod_amm == m_dg ]] && url=giustizia.it

    https="AVAILABLE"

    curl -ksSL -D - "https://$url" -o /dev/null > /dev/null
    [[ $? -eq 0 ]] || https="NOT AVAILABLE"

    cat <<EOF
      <tr>
        <th scope="row">$cod_amm</th>
        <td>$des_amm</td>
        <td>$url</td>
        <td>$https</td>
      </tr>
EOF
done < ipa

cat <<EOF
    </tbody>
  </body>
</html>
EOF
