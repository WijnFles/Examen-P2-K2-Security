# 01 · Linux-commando's: alles vinden en aanpassen op de fileserver

> Getest op Ubuntu met Samba 4, dezelfde opbouw als SRV001 in de proeftoets.
> Zoek op deze pagina met **Ctrl+F**: "gast", "groep", "eigenaar", "wanneer", "hoeveel"…

## 0. Inloggen en root worden
```bash
# login:     administrator
# password:  T0or1          (je ziet niets als je typt, dat is normaal)
sudo su                     # root worden, nogmaals T0or1
whoami                      # → root   (controle)
hostname                    # → SRV001
```
Je ziet nu `root@SRV001:~#`. Met `#` aan het eind ben je root, met `$` niet.

> 💡 **Screenshot-tip:** zet vóór elk commando dat je laat zien eerst even `clear`. Dan staat alleen dat commando met de uitvoer in beeld.

---

## 1. Basis: rondkijken (de 12 commando's die je altijd nodig hebt)
| Commando | Doet | Voorbeeld |
|---|---|---|
| `pwd` | waar ben ik? | `pwd` → `/root` |
| `ls` | wat staat er in deze map? | `ls /home/fileserver` |
| `ls -l` | met rechten, eigenaar, groep, datum | `ls -l /home/fileserver` |
| `ls -la` | ook verborgen bestanden (beginnen met `.`) | `ls -la /home` |
| `cd` | naar een map gaan | `cd /etc/samba` · `cd ..` (map omhoog) · `cd` (naar home) |
| `cat` | inhoud van een bestand tonen | `cat /etc/group` |
| `less` | lang bestand rustig lezen (pijltjes, **q** = stoppen, **/woord** = zoeken) | `less /etc/samba/smb.conf` |
| `head` / `tail` | eerste / laatste 10 regels | `tail -n 50 /var/log/samba/log.smbd` |
| `grep` | regels zoeken met een woord | `grep sales /etc/group` |
| `\|` (pipe) | uitvoer doorgeven aan het volgende commando | `cat /etc/passwd \| grep /home` |
| `nano` | bestand **bewerken** | `nano /etc/samba/smb.conf` |
| `cp` | kopiëren (**altijd eerst een backup!**) | `cp /etc/samba/smb.conf /etc/samba/smb.conf.bak` |

**nano bedienen:** pijltjes = bewegen · **Ctrl+O** + Enter = opslaan · **Ctrl+X** = afsluiten · **Ctrl+W** = zoeken · **Ctrl+K** = regel knippen.

**grep-opties:**
| Optie | Betekent | Voorbeeld |
|---|---|---|
| `-i` | hoofdletters negeren | `grep -i guest /etc/samba/smb.conf` |
| `-n` | regelnummer tonen | `grep -n "guest ok" /etc/samba/smb.conf` |
| `-v` | regels **zonder** het woord | `grep -v "^#" smb.conf` (zonder commentaar) |
| `-c` | alleen tellen | `grep -c "opened file" /var/log/samba/log.*` |
| `-r` | in alle bestanden in een map | `grep -r "nobody" /var/log/samba/` |
| `-A 8` | 8 regels erna ook tonen | `grep -A 8 "\[sales\]" /etc/samba/smb.conf` |
| `-E "a\|b"` | a **of** b | `grep -E "guest\|valid users" smb.conf` |

---

## 2. Gebruikers: wie bestaat er?
| Wat wil je weten? | Commando | Wat zie je / waar let je op |
|---|---|---|
| Alle gebruikers | `cat /etc/passwd` | per regel: `naam:x:UID:GID:volledige naam:home:shell` |
| Alleen **echte** gebruikers (geen systeemaccounts) | `grep /home /etc/passwd` of `awk -F: '$3>=1000' /etc/passwd` | echte gebruikers hebben UID ≥ 1000 |
| Alleen de namen | `cut -d: -f1 /etc/passwd` | |
| Eén gebruiker | `getent passwd salmademirci` | |
| Volledige naam (achternaam!) | `getent passwd salmademirci \| cut -d: -f5` | **vergelijk met de lijst uit het interview** |
| Kan iemand inloggen? | `passwd -S <naam>` | `P` = actief wachtwoord · `L` = **geblokkeerd** · `NP` = geen wachtwoord ⚠️ |
| Shell van de gebruiker | `grep <naam> /etc/passwd` | `/usr/sbin/nologin` of `/bin/false` = kan niet inloggen |
| Wanneer laatst ingelogd (op de server zelf) | `lastlog` / `last` | |
| Is er een gast-/guest-account? | `grep -iE "gast\|guest" /etc/passwd` | |
| **Samba**-gebruikers (wie mag op de shares) | `pdbedit -L` | lijst van accounts met een Samba-wachtwoord |
| Samba-gebruiker in detail | `pdbedit -L -v -u <naam>` | `Account Flags: [U ]` = actief · `[DU ]` = **D**isabled |

> ⚠️ Een gebruiker kan in `/etc/passwd` staan **én** in Samba (`pdbedit -L`). Controleer en verwijder in **beide**.

Voorbeeld uit de proeftoets:
```text
tjeerdnickson:x:1002:1002::/home/tjeerdnickson:/bin/sh
salmademirci:x:1003:1003::/home/salmademirci:/bin/sh      ← lijst zegt Salma ASLAN
ayoubozcan:x:1005:1005::/home/ayoubozcan:/bin/sh          ← lijst zegt Ayoub AHMADI
bramburg:x:1009:1009::/home/bramburg:/bin/sh              ← staat NIET op de lijst = oud-medewerker
```

---

## 3. Groepen: wie zit waar?
| Wat wil je weten? | Commando | Wat zie je |
|---|---|---|
| Alle groepen met leden | `cat /etc/group` | `groep:x:GID:lid1,lid2,lid3` |
| Alleen de afdelingsgroepen | `grep -E "administratie\|magazijn\|management\|sales\|iedereen" /etc/group` | |
| Leden van één groep | `getent group sales` | |
| In welke groepen zit een gebruiker? | `groups younesbulut` of `id younesbulut` | |
| Alle gebruikers en hun groepen in één keer | `for u in $(awk -F: '$3>=1000 && $3<60000{print $1}' /etc/passwd); do groups $u; done` | handig voor 1 screenshot |

Voorbeeld uit de proeftoets:
```text
administratie:x:1010:tjeerdnickson,younesbulut,salmademirci   ← younesbulut hoort bij SALES
magazijn:x:1011:bjornhentges,ayoubozcan
management:x:1012:hannekecool
sales:x:1013:younesbulut,anniestryker,bramburg                ← bramburg = oud-medewerker
iedereen:x:1014:tjeerdnickson,…,bramburg
```

---

## 4. Samba: welke mappen worden gedeeld en wie mag erbij?
Samba is het programma dat Linux-mappen deelt met Windows-computers (zoals `\\SRV001\sales`). De instellingen staan in **`/etc/samba/smb.conf`**.

| Wat wil je weten? | Commando |
|---|---|
| Het hele configuratiebestand | `cat /etc/samba/smb.conf` |
| Zonder commentaar en lege regels (overzichtelijk!) | `grep -v -E "^\s*[#;]\|^\s*$" /etc/samba/smb.conf` |
| Zoals Samba het echt leest (+ fouten controleren) | `testparm -s` |
| Inclusief alle standaardwaarden | `testparm -sv \| less` |
| Eén share bekijken | `grep -A 10 "\[sales\]" /etc/samba/smb.conf` |
| Alle gast-instellingen | `grep -n -i guest /etc/samba/smb.conf` |
| Wie mag waarbij | `grep -n -E "^\[\|valid users\|write list\|guest ok" /etc/samba/smb.conf` |
| Welke shares zijn zichtbaar **zonder wachtwoord**? | `smbclient -L //localhost -N` |
| Kan een gast in een share? (**het bewijs!**) | `smbclient //localhost/management -N -c ls` |
| Kan een gast een bestand downloaden? | `smbclient //localhost/management -N -c "get rapport.txt /tmp/test.txt"` |
| Inloggen als een echte gebruiker | `smbclient //localhost/sales -U anniestryker -c ls` |
| Wie is er **nu** verbonden en welke bestanden staan open? | `smbstatus` |
| Draait Samba? | `systemctl status smbd` |

### De regels in smb.conf: wat betekenen ze?
```ini
[global]                          ← instellingen voor de hele server
   map to guest = bad user        ⚠️ verkeerd wachtwoord/onbekende gebruiker → wordt GAST
   guest account = nobody         de Linux-gebruiker die "gast" is
   security = user                inloggen met gebruikersnaam + wachtwoord

[sales]                           ← naam van de share (\\SRV001\sales)
   comment = Sales
   path = /home/fileserver/sales  ← de echte map op de server
   valid users = @sales, @management, anniestryker
                 ↑ @ = groep          ↑ zonder @ = losse gebruiker ⚠️ (rechten horen via groepen!)
   browseable = yes               share zichtbaar in de lijst
   writable = yes                 mag schrijven
   read only = no                 (zelfde als writable = yes)
   guest ok = yes                 ⚠️ GAST MAG ERIN ZONDER WACHTWOORD
   public = yes                   ⚠️ zelfde als guest ok = yes!
```
| Instelling | Veilig | Onveilig |
|---|---|---|
| `map to guest` | `never` | `bad user`, `bad password` |
| `guest ok` / `public` | `no` | `yes` |
| `valid users` | alleen `@groepen` | ontbreekt (= iedereen) of bevat losse namen |
| `restrict anonymous` | `2` | `0` |
| `usershare allow guests` | `no` | `yes` |

> ⚠️ **Belangrijk, gezien in de testomgeving:** staat er bij een share `valid users = @groep`, dan komt een gast er **meestal tóch niet in**, ook al staat er `guest ok = yes`. De gast (`nobody`) staat namelijk niet in de lijst. Gevaarlijk zijn dus vooral shares **zonder** `valid users` (of met `nobody`/`guest` erin). Ga daarom niet alleen af op het bestand, maar **test elke share**:
> ```bash
> for s in $(smbclient -L //localhost -N -g 2>/dev/null | awk -F'|' '$1=="Disk"{print $2}'); do echo -n "$s: "; smbclient //localhost/$s -N -c ls >/dev/null 2>&1 && echo "OPEN voor gast" || echo "dicht"; done
> ```
> Uitvoer in de oefenserver: `management: OPEN voor gast`, de rest `dicht`. Zet beide in je rapport: *"`guest ok = yes` staat op alle shares (configuratiefout); door `valid users` was in de praktijk de map management open"*. En zet `guest ok = no` **overal**: als iemand later `valid users` weghaalt, staat de deur anders meteen open.

---

## 5. Mappen: eigenaar, groep en rechten
| Wat wil je weten? | Commando |
|---|---|
| Rechten van alle afdelingsmappen | `ls -l /home/fileserver` |
| Ook van de bestanden erin | `ls -lR /home/fileserver` |
| Uitgebreide rechten (ACL's) | `getfacl /home/fileserver/sales` |
| Bestanden van een bepaalde eigenaar | `find /home/fileserver -user anniestryker` |
| Mappen die voor **iedereen** schrijfbaar zijn | `find /home/fileserver -perm -o+w` |

### `ls -l` lezen
```text
drwxrwxrwx 2 anniestryker sales 4096 Nov 1 21:31 administratie
│└┬┘└┬┘└┬┘   └─────┬────┘ └─┬─┘                  └─ mapnaam
│ │  │  │          │        └─ GROEP-eigenaar   ← moet de afdelingsgroep zijn (administratie)
│ │  │  │          └─ EIGENAAR (gebruiker)      ← moet root zijn, geen losse medewerker
│ │  │  └─ rechten OVERIGEN (iedereen)  rwx ⚠️ moet --- zijn
│ │  └─ rechten GROEP                   rwx = lezen, schrijven, openen
│ └─ rechten EIGENAAR
└─ d = map (directory), - = bestand
```
| Letter | Bij een map | Getal |
|---|---|---|
| `r` | inhoud bekijken | 4 |
| `w` | bestanden maken/verwijderen | 2 |
| `x` | de map in gaan | 1 |
| `-` | niets | 0 |

`chmod 770` = eigenaar 7 (rwx) · groep 7 (rwx) · overigen 0 (---) → **goed voor een afdelingsmap**
`chmod 777` = iedereen alles → ⚠️ **fout**

> **"Eigenaarschap van de mappen is verkeerd geconfigureerd"** (zwakheid uit de proeftoets): de map `administratie` is eigendom van `anniestryker:sales`, maar hoort bij `root:administratie`.

---

## 6. Wanneer is het gebeurd? (incident, opdracht 2)
| Wat wil je weten? | Commando |
|---|---|
| Welke logbestanden heeft Samba? | `ls -l /var/log/samba/` |
| Wie heeft als **gast** (nobody) bestanden geopend? | `grep -r "nobody" /var/log/samba/` |
| Welke bestanden zijn geopend? | `grep -rh "opened file" /var/log/samba/` |
| Mislukte/anonieme logins | `grep -r -E "NO_SUCH_USER\|ANONYMOUS\|guest" /var/log/samba/` |
| Vanaf welk IP? | `ls /var/log/samba/` → bestanden heten `log.<ip-adres>` of `log.<computernaam>` |
| Systeemlog van Samba | `journalctl -u smbd --no-pager \| tail -50` |
| Wanneer is een bestand **laatst gelezen** (= gekopieerd)? | `stat /home/fileserver/management/*` → regel **Access** |
| Alle bestanden met hun leestijd | `ls -lu --time-style=full-iso /home/fileserver/*` |
| Bestanden gelezen in de laatste 24 uur | `find /home/fileserver -type f -atime -1` |
| Bestanden gelezen tussen twee datums | `find /home/fileserver -type f -newerat "2026-11-01" ! -newerat "2026-11-02"` |
| Wie logde in op de server zelf? | `last` · `grep -i "session opened" /var/log/auth.log` |
| Wanneer is smb.conf laatst aangepast? | `stat /etc/samba/smb.conf` → **Modify** |
| Is er commentaar met een datum in de config? | `grep -n "#" /etc/samba/smb.conf` |

Voorbeeld uit de logs (gast heeft een bestand geopend):
```text
[2026/11/01 21:31:57.224273, 2] auth/auth_log.c:858
  Auth: user [WORKGROUP]\[root] with [No-Password] status [NT_STATUS_NO_SUCH_USER] remote host [ipv4:192.168.1.50] mapped to …
  nobody opened file rapport-management.txt read=Yes write=No
```
→ **wie**: `nobody` (= gast) · **vanaf**: 192.168.1.50 · **wanneer**: 2026/11/01 21:31 · **wat**: rapport-management.txt

> 💡 Staat er niets in de logs? Dan is dat óók een bevinding: *"Samba logde op een laag niveau, waardoor niet meer te achterhalen is wie wat heeft gedownload. Daarom moet het ergste worden aangenomen: alle bestanden in de gastshares kunnen zijn gekopieerd."* Advies: log level verhogen.

---

## 7. Over welke informatie gaat het en hoeveel? (opdracht 2)
| Wat wil je weten? | Commando |
|---|---|
| Welke bestanden staan er in alle shares? | `ls -lR /home/fileserver` of `find /home/fileserver -type f` |
| **Hoeveel** bestanden in totaal? | `find /home/fileserver -type f \| wc -l` |
| Hoeveel per map? | `for d in /home/fileserver/*; do echo "$d: $(find $d -type f \| wc -l)"; done` |
| Hoe **groot** (MB) per map? | `du -sh /home/fileserver/*` |
| Totaal | `du -sh /home/fileserver` |
| Inhoud van een bestand bekijken (persoonsgegevens?) | `cat` / `head` |
| Zoeken naar persoonsgegevens | `grep -rilE "iban\|bsn\|adres\|geboortedatum\|klant" /home/fileserver` |
| Hoeveel keer heeft een gast iets geopend? | `grep -rh "nobody opened file" /var/log/samba/ \| wc -l` |
| Welke bestanden, en hoe vaak? | `grep -rh "nobody opened file" /var/log/samba/ \| sort \| uniq -c` |

---

## 8. Aanpassen (opdracht 1 advies, opdracht 2 uitvoeren)
> ⚠️ **Altijd eerst een backup** van wat je aanpast. Dan kun je het laten zien (voor/na) en terugdraaien:
> `cp /etc/samba/smb.conf /etc/samba/smb.conf.bak`

### Gasttoegang uitschakelen (zo volledig mogelijk)
```bash
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
nano /etc/samba/smb.conf
```
In `[global]`:
```ini
   map to guest = never
   restrict anonymous = 2
   usershare allow guests = no
```
In **elke** share: `guest ok = no` (en `public = yes` weghalen) + `valid users = @<groep>`

Of in één keer alle `guest ok = yes` vervangen:
```bash
sed -i 's/guest ok = yes/guest ok = no/I; s/public = yes/public = no/I' /etc/samba/smb.conf
```
Daarna **altijd**:
```bash
testparm -s                       # fouten? (moet "Loaded services file OK." zeggen)
systemctl restart smbd            # Samba opnieuw starten
diff /etc/samba/smb.conf.bak /etc/samba/smb.conf   # voor/na laten zien (screenshot!)
```
Bestaat er ook een Linux-account `gast`/`guest`?
```bash
smbpasswd -d gast                       # Samba-account uitschakelen
usermod -L -s /usr/sbin/nologin gast    # Linux-account blokkeren
passwd -S gast                          # controle → "L" = locked
```

### Gebruiker verwijderen (oud-medewerker)
```bash
smbpasswd -x bramburg       # EERST uit Samba (anders lukt dat niet meer)
userdel -r bramburg         # dan uit Linux (-r = ook home-map weg)
grep bramburg /etc/passwd /etc/group   # controle: geen uitvoer = weg
```
> 💡 Wil je de data bewaren? Gebruik dan geen `-r`. Of blokkeer het account: `usermod -L bramburg` + `smbpasswd -d bramburg`. Dat is netjes richting AVG: je verwijdert eerst toegang, daarna pas data.

### Gebruiker uit een verkeerde groep halen / aan een groep toevoegen
```bash
gpasswd -d younesbulut administratie    # uit groep halen
usermod -aG sales younesbulut           # aan groep toevoegen (-a = toevoegen, NIET vergeten!)
groups younesbulut                      # controle
```

### Naam aanpassen (achternaam)
```bash
chfn -f "Salma Aslan" salmademirci      # volledige naam aanpassen
getent passwd salmademirci              # controle
```
De **gebruikersnaam** (`salmademirci`) wijzig je liever niet: dat geeft problemen met bestanden en Samba. Advies: in overleg met HR nagaan wat de juiste naam is, en eventueel een nieuw account aanmaken. Zo staat het ook in de uitwerking van de docent.

### Losse gebruiker weghalen uit een share (rechten via groepen)
In smb.conf:
```ini
   valid users = @sales, @management, anniestryker      ← VOOR
   valid users = @sales, @management                    ← NA
```

### Rechten op de map management minder ruim maken
```ini
[management]
   valid users = @management
   guest ok = no
```

### Eigenaarschap en rechten van mappen goedzetten
```bash
chown -R root:administratie /home/fileserver/administratie
chown -R root:magazijn      /home/fileserver/magazijn
chown -R root:management    /home/fileserver/management
chown -R root:sales         /home/fileserver/sales
chown -R root:iedereen      /home/fileserver/iedereen
chmod 2770 /home/fileserver/*      # rwx eigenaar + groep, niets voor overigen; 2 = nieuwe bestanden krijgen de groep
ls -l /home/fileserver             # controle
```
> Management moet bij alle mappen? Dat regel je in **Samba** met `valid users = @administratie, @management`. Op Linux-niveau kun je management toegang geven met een ACL: `setfacl -m g:management:rwx /home/fileserver/sales`

---

## 9. Testen dat je oplossing werkt (= punten voor "getest")
```bash
smbclient -L //localhost -N                          # → gast ziet geen shares meer / access denied
smbclient //localhost/management -N -c ls            # → NT_STATUS_ACCESS_DENIED  ✅
for s in $(smbclient -L //localhost -N -g 2>/dev/null | awk -F'|' '$1=="Disk"{print $2}'); do echo -n "$s: "; smbclient //localhost/$s -N -c ls >/dev/null 2>&1 && echo "OPEN voor gast" || echo "dicht"; done   # → overal "dicht" ✅
smbclient //localhost/management -U hannekecool -c ls   # → werkt wel (management)    ✅
smbclient //localhost/management -U younesbulut -c ls   # → ACCESS_DENIED (sales)     ✅
grep bramburg /etc/passwd                            # → geen uitvoer               ✅
pdbedit -L                                           # → bramburg weg, gast [D]     ✅
ls -l /home/fileserver                               # → root:<afdeling>, drwxrws---  ✅
```
Van een Windows-pc: Verkenner → `\\<ip-van-SRV001>` → als gast moet je nu om een wachtwoord gevraagd worden.

Het IP-adres van de server: `ip a` (zoek `inet 192.168.x.x`) of `hostname -I`.

---

## 10. Spiekkaart: het hele onderzoek in 15 commando's
```bash
sudo su
cat /etc/passwd | grep /home                 # 1. gebruikers
cat /etc/group                               # 2. groepen + leden
pdbedit -L -v | grep -E "Unix username|Account Flags"   # 3. Samba-gebruikers + status
grep -iE "gast|guest" /etc/passwd            # 4. gastaccount?
grep -v -E "^\s*[#;]|^\s*$" /etc/samba/smb.conf   # 5. shares + wie mag erbij
grep -n -i guest /etc/samba/smb.conf         # 6. gasttoegang
smbclient -L //localhost -N                  # 7. BEWIJS: shares zonder wachtwoord?
smbclient //localhost/management -N -c ls    # 8. BEWIJS: gast in management?
for s in $(smbclient -L //localhost -N -g 2>/dev/null | awk -F'|' '$1=="Disk"{print $2}'); do echo -n "$s: "; smbclient //localhost/$s -N -c ls >/dev/null 2>&1 && echo "OPEN voor gast" || echo "dicht"; done   # 8b. ALLE shares testen
ls -l /home/fileserver                       # 9. eigenaar/groep/rechten mappen
ls -lR /home/fileserver                      # 10. welke bestanden
du -sh /home/fileserver/*                    # 11. hoeveel
ls -l /var/log/samba/                        # 12. logs (log.<ip>)
grep -rh "opened file" /var/log/samba/       # 13. wat is geopend, door wie
stat /home/fileserver/management/*           # 14. wanneer gelezen
smbstatus                                    # 15. wie is nu verbonden
```
