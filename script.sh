#!/bin/bash

export OPENSSL_CONF=openssl.cnf
BASEDIR=~/tools
index=$BASEDIR/index.html

ipa_url='https://www.indicepa.gov.it/public-services/opendata-read-service.php?dstype=FS&filename=amministrazioni.txt'
ipa_data=$BASEDIR/ipa

# download ipa_url (remove header)
if [[ ! -e $ipa_data || $(($(date +%s)-$(stat --printf '%Y' $ipa_data))) -gt 3600 ]]
then
    curl -s "$ipa_url" | tail -n+2 > $ipa_data
fi

cat > $index <<EOF
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

    cat >> $index <<EOF
      <tr>
        <th scope="row">$cod_amm</th>
        <td>$des_amm</td>
        <td>$url</td>
        <td>$https</td>
      </tr>
EOF
break
done < $ipa_data

cat >> $index <<EOF
    </tbody>
  </body>
</html>
EOF

## update gh-pages
[[ -n $GIT_ACCESS_TOKEN ]] || exit 1

git config --global user.email "info@eutopian.eu"
git config --global user.name "Eutopian"
git config --global credential.helper store
echo "https://$GIT_ACCESS_TOKEN:x-oauth-basic@github.com" >> ~/.git-credentials

rm -fr /tmp/gh-pages && mkdir /tmp/gh-pages
cd /tmp/gh-pages
git clone https://github.com/eutopian-eu/tools.git
cd tools
git checkout gh-pages || git checkout --orphan gh-pages
git rm -rf .

cp -a $index /tmp/gh-pages/tools

git add -A
git commit -m "Automated deployment to GitHub Pages" --allow-empty
git push origin gh-pages
