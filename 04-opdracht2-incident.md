# 04 · Opdracht 2: reageren op een security-incident (W2, 15 punten, 120 min)

**Situatie:** op SRV001 kunnen gegevens **zonder juiste authenticatie** gedownload worden, via gasttoegang. Jij:
1. **bevestigt** dat het probleem er is
2. zoekt uit **hoe, wanneer, wat en hoeveel**
3. **lost het op** en **test** het
4. schrijft een **onderzoeksverslag**, een **logboek** en een **e-mail** (met AVG)

➡️ Ingevulde voorbeelden: [onderzoeksverslag](voorbeelden/onderzoeksverslag-ingevuld.md) · [e-mail](voorbeelden/email-ingevuld.md) · [logboek](voorbeelden/logboek-ingevuld.md)

---

## Hoe word je beoordeeld? (nakijkonderlegger)
| Criterium | 3 punten (volledig) als… |
|---|---|
| **Security-incidenten** | **alle (3) kwetsbaarheden** overgenomen, **geanalyseerd** en **correct gecategoriseerd** (risiconiveau) |
| **Technische oplossingen** | **3 verbeteringen** doorgevoerd, correct geconfigureerd **én getest**: ① gastaccount actief → uit · ② gastaccount heeft rechten op mappen → weg · ③ rechten op map **management** te ruim → beperkt |
| **AVG** | mailadressen **Aan/CC** correct · **Van** correct · **benoemd waar de mail heen gaat** |
| **Logboek** | datum, tijd, werkzaamheden, acties **+ screenshots** van de verbeteringen |
| **Informeren** | **zakelijke** mail, **juiste bijlage** (onderzoeksverslag) toegevoegd, volgens AVG verstuurd |

Cijfer: 8 pnt = 5.8 · 9 pnt = 6.4 · **10 pnt = 7.0** · 12 pnt = 8.2 · 15 pnt = 10

**Bijlage 2.3 Zwakheden** (krijg je op papier **na** het inleveren van je verslag):
- Gasttoegang staat open op alle mappen
- Eigenaarschap van de mappen is verkeerd geconfigureerd

> 💡 Het 3e punt uit de onderlegger: *"rechten op de map management zijn te ruim geconfigureerd"*. Met deze drie heb je ze alle 3.

---

## Stappenplan (120 min)
| Tijd | Stap |
|---|---|
| 0:00 | **Logboek openen** en meteen bijhouden: elke actie = regel met **tijd** + 📸 |
| 0:05 | Inloggen `administrator`/`T0or1` → `sudo su` |
| 0:10 | **2.1 Bevestigen**: `smbclient -L //localhost -N` + `smbclient //localhost/management -N -c ls` 📸 (dit is je bewijs) |
| 0:20 | **Oorzaak zoeken**: `grep -n -i guest /etc/samba/smb.conf`, `ls -l /home/fileserver`, gastaccount 📸 |
| 0:35 | **Wanneer / wat / hoeveel**: logs, `stat`, `find`, `du` 📸 |
| 0:50 | **Oplossen**: backup → smb.conf aanpassen → gastaccount uit → eigenaar/rechten → management beperken 📸 |
| 1:05 | **Testen**: opnieuw `smbclient -N` (moet nu DENIED geven) + een echte gebruiker (moet werken) 📸 |
| 1:15 | **Onderzoeksverslag** invullen |
| 1:40 | **E-mail** met verslag als bijlage |
| 1:50 | Logboek nalopen: elke regel tijd + actie + screenshot? |

---

## 2.1 Bevestig de constatering
```bash
smbclient -L //localhost -N                               # welke shares zie je zonder wachtwoord?
smbclient //localhost/management -N -c ls                 # kan een gast de inhoud zien?
smbclient //localhost/management -N -c "get <bestand> /tmp/bewijs.txt"   # kan een gast downloaden?
```
Test **alle** shares in één keer (want `valid users` kan een gast soms toch tegenhouden, zie [01 §4](01-linux-commandos.md#4-samba-welke-mappen-worden-gedeeld-en-wie-mag-erbij)):
```bash
for s in $(smbclient -L //localhost -N -g 2>/dev/null | awk -F'|' '$1=="Disk"{print $2}'); do echo -n "$s: "; smbclient //localhost/$s -N -c ls >/dev/null 2>&1 && echo "OPEN voor gast" || echo "dicht"; done
```
Lukt dat? **Probleem bevestigd**. Screenshot + logboekregel: *"Gasttoegang bevestigd: zonder wachtwoord kan de inhoud van share management worden bekeken en gedownload."*

Windows: Verkenner → `\\SRV001\Management` → opent zonder inlogvraag? Of `Get-LocalUser Guest` → `Enabled: True`.

---

## 2.2 Vraag 1: hoe kon dit gebeuren?
### a. i. Welke zwakheden?
Zoek ze zo op:
```bash
grep -n -i -E "guest|public|map to guest" /etc/samba/smb.conf     # gasttoegang
grep -n "valid users" /etc/samba/smb.conf                          # wie mag erbij (ontbreekt = iedereen!)
ls -l /home/fileserver                                             # eigenaar + rechten
pdbedit -L -v | grep -E "Unix username|Account Flags"              # gastaccount actief?
grep -iE "gast|guest" /etc/passwd
```

| # | Zwakheid | Hoe zie je het | Gevolg |
|---|---|---|---|
| 1 | **Gasttoegang staat open op alle mappen** | `guest ok = yes` (of `public = yes`) bij de shares · `map to guest = bad user` in `[global]` · Windows: Guest enabled, Guest/Everyone op de shares | iedereen in het netwerk kan zonder wachtwoord alle afdelingsmappen lezen, downloaden (en wijzigen) |
| 2 | **Eigenaarschap van de mappen is verkeerd** | `ls -l`: eigenaar is een medewerker (`anniestryker`) of `root:root`, rechten `rwxrwxrwx` (777) | iedereen op de server kan erbij; de verkeerde persoon kan rechten aanpassen |
| 3 | **Rechten op de map management te ruim** | `[management]` zonder `valid users = @management`, of met gast/andere groepen | vertrouwelijke managementinformatie is voor iedereen leesbaar |

### a. ii. Welk risiconiveau heeft elke zwakheid?
Gebruik **kans × impact** (zie [03 § Impact en risico](03-opdracht1-auditrapport.md#impact-en-risico-inschatten)).

| Zwakheid | Kans | Impact | **Risiconiveau** |
|---|---|---|---|
| Gasttoegang op alle mappen | Hoog: geen wachtwoord, iedereen in het netwerk | Hoog: alle afdelingen, persoonsgegevens (webshopklanten), AVG | **Hoog** |
| Rechten management te ruim | Hoog | Hoog: strategische en personeelsgegevens | **Hoog** |
| Eigenaarschap verkeerd | Middel: vereist toegang tot de server zelf | Middel/hoog: rechten kunnen worden aangepast | **Middel** |

### b. Wanneer is het gebeurd?
```bash
ls -l /var/log/samba/                                   # logbestanden per IP/computer (log.192.168.1.50)
grep -rh "nobody\|NO_SUCH_USER\|ANONYMOUS" /var/log/samba/ | head     # gastlogins met datum/tijd
grep -rh "opened file" /var/log/samba/                  # welke bestanden geopend, door wie
stat /home/fileserver/*/*                               # Access = laatst gelezen
ls -lu --time-style=full-iso /home/fileserver/*         # leestijd per bestand
stat /etc/samba/smb.conf                                # Modify = sinds wanneer staat de fout erin?
grep -n "#" /etc/samba/smb.conf                         # commentaar met datum?
journalctl -u smbd --no-pager | tail -50
```
Windows: Event Viewer → Security → **4624** (Account *Guest*/*ANONYMOUS LOGON*, Logon Type 3) en **5140**.

**Zo schrijf je het op:**
- Logs gevonden → *"Op 1 november 2026 om 21:31 heeft een gastgebruiker (nobody) vanaf IP 192.168.1.50 het bestand rapport-management.txt geopend (bron: /var/log/samba/log.192.168.1.50)."*
- Geen logs → *"Het exacte tijdstip is niet te achterhalen, omdat Samba geen bestandstoegang logde. Het configuratiebestand is voor het laatst gewijzigd op [datum uit stat]. Vanaf dat moment stond de gasttoegang open. De periode van blootstelling is dus van [datum] tot [nu]."*

### c. Over welke informatie kan het gaan?
```bash
ls -lR /home/fileserver                                 # alle bestanden per afdeling
grep -rilE "iban|bsn|adres|klant|geboortedatum|salaris" /home/fileserver   # persoonsgegevens?
```
Schrijf het **per afdeling** op, bijvoorbeeld:
- **Sales:** klantgegevens van de webshop (namen, adressen, bestellingen) → **persoonsgegevens**
- **Administratie:** facturen, salarisgegevens, IBAN → **persoonsgegevens + financieel**
- **Management:** strategie, personeelsdossiers → **vertrouwelijk**
- **Magazijn:** voorraad, leveranciers
- **Iedereen:** algemene informatie (laag risico)

### d. Hoeveel informatie is buitgemaakt?
```bash
find /home/fileserver -type f | wc -l                   # totaal aantal bestanden
for d in /home/fileserver/*; do echo "$d: $(find $d -type f | wc -l) bestanden, $(du -sh $d | cut -f1)"; done
grep -rh "nobody opened file" /var/log/samba/ | sort | uniq -c    # wat is ECHT geopend door een gast
```
**Zo schrijf je het op:** *"Uit de logs blijkt dat 3 bestanden door een gast zijn geopend (…). Omdat de gasttoegang op alle mappen openstond, moet worden aangenomen dat **alle 42 bestanden (12 MB)** in de vijf afdelingsmappen gekopieerd kunnen zijn."*

> 🔑 Bij twijfel ga je uit van het **ergste geval** (*worst case*). Dat is ook wat de AVG verwacht bij de beoordeling van een datalek.

---

## Vraag 3: gasttoegang zo volledig mogelijk uitschakelen
"**Zo volledig mogelijk**" = op **alle lagen**:

| Laag | Linux / Samba | Windows |
|---|---|---|
| 1. Server niet meer naar gast laten omzetten | `[global]` `map to guest = never` | – |
| 2. Anonieme toegang blokkeren | `[global]` `restrict anonymous = 2` · `usershare allow guests = no` | secpol: *Restrict anonymous access…* = Enabled |
| 3. Per share | `guest ok = no` (en geen `public = yes`) + `valid users = @<groep>` | Guest/Everyone uit Share Permissions |
| 4. Gastaccount zelf | `smbpasswd -d gast` · `usermod -L -s /usr/sbin/nologin gast` | `Disable-LocalUser Guest` / ☑ *Account is disabled* |
| 5. Bestandsrechten | `chown root:<afdeling>` · `chmod 2770` | NTFS: Guest/Everyone weg, owner Administrators |

Uitvoeren (Linux): zie [01 §8](01-linux-commandos.md#8-aanpassen-opdracht-1-advies-opdracht-2-uitvoeren). In het kort:
```bash
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak                  # 1. backup
nano /etc/samba/smb.conf                                        # 2. aanpassen (zie tabel)
testparm -s                                                     # 3. controleren
systemctl restart smbd                                          # 4. herstarten
diff /etc/samba/smb.conf.bak /etc/samba/smb.conf                # 5. voor/na-screenshot
chown -R root:management /home/fileserver/management            # 6. eigenaarschap (per map)
chmod 2770 /home/fileserver/management
```
**Management minder ruim:**
```ini
[management]
   path = /home/fileserver/management
   valid users = @management
   guest ok = no
```

### Testen (= het verschil tussen 2 en 3 punten!)
```bash
smbclient //localhost/management -N -c ls                   # → NT_STATUS_ACCESS_DENIED   ✅ gast eruit
smbclient //localhost/sales -N -c ls                        # → NT_STATUS_ACCESS_DENIED   ✅ (alle shares!)
smbclient //localhost/management -U hannekecool -c ls       # → werkt                       ✅ bevoegd kan nog
smbclient //localhost/management -U younesbulut -c ls       # → NT_STATUS_ACCESS_DENIED   ✅ te ruim opgelost
ls -l /home/fileserver                                      # → root <afdeling> drwxrws---  ✅ eigenaarschap
```
Zo zag het eruit in de testomgeving:
```text
--- VOOR ---
$ smbclient //localhost/management -N -c ls
  rapport-management.txt              N       25  Sun Nov  1 21:31:43 2026
--- NA ---
$ smbclient //localhost/management -N -c ls
tree connect failed: NT_STATUS_ACCESS_DENIED
$ smbclient //localhost/management -U hannekecool%******** -c ls
  rapport-management.txt              N       25  Sun Nov  1 21:31:43 2026
$ smbclient //localhost/management -U younesbulut%******** -c ls
tree connect failed: NT_STATUS_ACCESS_DENIED
```

---

## Vraag 4: communicatiematrix
De matrix staat al ingevuld in het sjabloon. Jij geeft aan **welke regel(s) van toepassing zijn** en **wie dus geïnformeerd moet worden**. Zie [05-avg-en-communicatie.md](05-avg-en-communicatie.md#communicatiematrix-invullen).

## Vraag 5: e-mail met vervolgstappen en wettelijke verplichtingen
Zie [voorbeelden/email-ingevuld.md](voorbeelden/email-ingevuld.md) en [05-avg-en-communicatie.md](05-avg-en-communicatie.md).
