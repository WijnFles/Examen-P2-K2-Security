#!/bin/bash
# =====================================================================
#  OEFENSERVER P2-K2: bouwt een fileserver met DEZELFDE FOUTEN als de proeftoets
#  Gebruik: op een Ubuntu/Debian-VM (NIET op een echte server!):
#      sudo bash maak-oefenserver.sh
#  Daarna kun je alle controles en reparaties uit 01-linux-commandos.md oefenen.
#  Alle wachtwoorden: Welkom01
#
#  Ingebouwde fouten (zoek ze zelf!):
#   - 2 achternamen wijken af van de medewerkerslijst
#   - 1 oud-medewerker heeft nog een account
#   - 1 medewerker zit in de groep van een andere afdeling
#   - 1 medewerker heeft direct (niet via een groep) rechten op shares
#   - een gastaccount bestaat en gasttoegang staat open
#   - map management: rechten te ruim
#   - eigenaarschap/rechten van de mappen verkeerd
# =====================================================================
set -e
[ "$(id -u)" -eq 0 ] || { echo "Start met sudo"; exit 1; }

apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq samba smbclient acl >/dev/null

for g in administratie magazijn management sales iedereen; do groupadd -f "$g"; done

maak() {   # maak <login> "<volledige naam>"
  id "$1" >/dev/null 2>&1 || useradd -m -s /bin/sh -c "$2" "$1"
  echo "$1:Welkom01" | chpasswd
  (echo Welkom01; echo Welkom01) | smbpasswd -a -s "$1" >/dev/null
}
maak tjeerdnickson "Tjeerd Nickson"
maak salmademirci  "Salma Demirci"
maak bjornhentges  "Bjorn Hentges"
maak ayoubozcan    "Ayoub Ozcan"
maak hannekecool   "Hanneke Cool"
maak younesbulut   "Younes Bulut"
maak anniestryker  "Annie Stryker"
maak bramburg      "Bram Burg"
maak gast          "Gast"

gpasswd -M tjeerdnickson,younesbulut,salmademirci administratie
gpasswd -M bjornhentges,ayoubozcan magazijn
gpasswd -M hannekecool management
gpasswd -M younesbulut,anniestryker,bramburg sales
gpasswd -M tjeerdnickson,younesbulut,salmademirci,bjornhentges,ayoubozcan,hannekecool,anniestryker,bramburg iedereen

mkdir -p /home/fileserver/{administratie,iedereen,magazijn,management,sales}
echo "Factuur 2026-001;Klant: J. de Vries;IBAN NL00BANK0123456789" > /home/fileserver/administratie/facturen.csv
echo "Salarisoverzicht oktober (vertrouwelijk)"                     > /home/fileserver/administratie/salaris.txt
echo "Welkom bij Conley! Kantine open 12-13 uur."                   > /home/fileserver/iedereen/mededelingen.txt
echo "Voorraad: 120 dozen, 45 pallets"                              > /home/fileserver/magazijn/voorraad.txt
echo "Strategie 2027 + reorganisatieplan (VERTROUWELIJK)"           > /home/fileserver/management/strategie.txt
printf "Naam;Adres;Woonplaats;IBAN\nJan Jansen;Dorpsstraat 1;Utrecht;NL00BANK0000000001\n" > /home/fileserver/sales/klanten-webshop.csv
chown -R anniestryker:sales /home/fileserver/administratie
chown -R root:root /home/fileserver/{iedereen,magazijn,management,sales}
chmod -R 777 /home/fileserver

[ -f /etc/samba/smb.conf.origineel ] || cp /etc/samba/smb.conf /etc/samba/smb.conf.origineel
cat > /etc/samba/smb.conf <<'EOF'
[global]
   workgroup = WORKGROUP
   server string = SRV001
   security = user
   map to guest = bad user
   log file = /var/log/samba/log.%m
   max log size = 1000
   log level = 2
   logging = file

[iedereen]
   comment = Informatie voor iedereen
   path = /home/fileserver/iedereen
   valid users = @iedereen, anniestryker
   browseable = yes
   writable = yes
   read only = no
   guest ok = yes

[administratie]
   comment = Administratie
   path = /home/fileserver/administratie
   valid users = @administratie, @management, @sales, anniestryker
   browseable = yes
   writable = yes
   read only = no
   guest ok = yes

[magazijn]
   comment = Magazijn
   path = /home/fileserver/magazijn
   valid users = @magazijn, @management
   browseable = yes
   writable = yes
   read only = no
   guest ok = yes

[management]
   comment = Management
   path = /home/fileserver/management
   browseable = yes
   writable = yes
   read only = no
   guest ok = yes

[sales]
   comment = Sales
   path = /home/fileserver/sales
   valid users = @sales, @management, @administratie, anniestryker
#administratie toegevoegd per 3 januari 2023 op verzoek van Salma
   browseable = yes
   writable = yes
   read only = no
   guest ok = yes
EOF

systemctl restart smbd 2>/dev/null || { pkill smbd; smbd -D; }
echo
echo "Oefenserver klaar. Probeer:  smbclient //localhost/management -N -c ls"
echo "Medewerkerslijst (interview):"
echo "  Administratie: Tjeerd Nickson, Salma Aslan | Magazijn: Bjorn Hentges, Ayoub Ahmadi"
echo "  Management: Hanneke Cool | Sales: Younes Bulut, Annie Stryker"
