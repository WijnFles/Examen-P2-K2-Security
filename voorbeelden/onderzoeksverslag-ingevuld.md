# Onderzoeksverslag gasttoegang fileserver SRV001

| | |
|---|---|
| **Opdrachtgever** | Hanneke Cool, Handelsbedrijf Conley |
| **Auteur** | Kyan Wossink, IT-expert SecureIT |
| **Datum** | 2 november 2026 |
| **Versie** | 1.0 |

> *Voorbeelduitwerking. Vervang tijden, IP-adressen, bestanden en aantallen door wat jij op het examen vindt. Bij elk punt hoort een screenshot.*

## Overzicht van de te onderzoeken onderdelen
In dit onderzoeksverslag wordt beschreven welke onderdelen zijn onderzocht en welke resultaten dit heeft opgeleverd.

### 1.1 Aanleiding onderzoek
Op fileserver SRV001 worden gegevens van alle afdelingen van Handelsbedrijf Conley opgeslagen. Een collega heeft geconstateerd dat gegevens van de server kunnen worden gedownload **zonder juiste authenticatie**. De directie gaat ervan uit dat er gegevens gekopieerd kunnen zijn. SecureIT is gevraagd om:
- te controleren of dit probleem aanwezig is
- te onderzoeken hoe het kon gebeuren, wanneer, welke informatie het betreft en hoeveel
- het probleem op te lossen, zodat alleen geautoriseerde gebruikers de gegevens kunnen raadplegen

### 1.2 Uitgevoerd onderzoek
**Stap 1: constatering bevestigd.** Met `smbclient -L //localhost -N` (inloggen zonder wachtwoord) waren alle gedeelde mappen zichtbaar. Met `smbclient //localhost/management -N -c ls` kon de inhoud van de map Management zonder wachtwoord worden bekeken en gedownload. **De constatering van de collega is daarmee bevestigd.**
📸 *[screenshot]*

**Stap 2: oorzaak.** In `/etc/samba/smb.conf` en met `ls -l /home/fileserver` zijn de volgende zwakheden gevonden:

| # | Zwakheid | Bewijs | Risiconiveau |
|---|---|---|---|
| 1 | **Gasttoegang staat open op alle mappen** | `map to guest = bad user` in [global]; `guest ok = yes` bij alle shares | **Hoog**: iedereen in het netwerk kan zonder wachtwoord gegevens van alle afdelingen lezen, kopiëren en wijzigen. Het gaat om persoonsgegevens (AVG) |
| 2 | **Rechten op de map Management te ruim** | `[management]` zonder `valid users`, met `guest ok = yes` | **Hoog**: vertrouwelijke managementgegevens voor iedereen toegankelijk |
| 3 | **Eigenaarschap van de mappen verkeerd geconfigureerd** | `ls -l`: map administratie is eigendom van `anniestryker:sales`, andere mappen van `root:root`, alle mappen `rwxrwxrwx` (777) | **Middel**: iedere gebruiker op de server kan bij alle bestanden, en een medewerker kan zelf de rechten van een afdelingsmap aanpassen |

📸 *[screenshot smb.conf] · [screenshot ls -l]*

**Stap 3: wanneer?** In de Samba-logbestanden (`/var/log/samba/log.192.168.1.50`) staat dat op **1 november 2026 om 21:31** een gastgebruiker (`nobody`) vanaf IP-adres **192.168.1.50** het bestand `rapport-management.txt` heeft geopend. Het configuratiebestand is voor het laatst gewijzigd op [datum uit `stat /etc/samba/smb.conf`]. Vanaf dat moment stond de gasttoegang open.
📸 *[screenshot grep logs] · [screenshot stat]*

**Stap 4: welke informatie?**
| Map | Inhoud | Persoonsgegevens? |
|---|---|---|
| Sales | klantenbestand webshop (`klanten.csv`: naam, adres, IBAN) | **Ja** |
| Administratie | financiële rapportages | **Ja** (medewerkers/klanten) |
| Management | managementrapportage | vertrouwelijk |
| Magazijn | voorraadrapportage | nee |
| Iedereen | algemene informatie | nee |

**Stap 5: hoeveel?** In totaal staan er **6 bestanden (44 kB)** in de vijf mappen (`find … | wc -l`, `du -sh`). Volgens de logs is **1 bestand** aantoonbaar door een gast geopend. Omdat de gasttoegang op alle mappen openstond en de logging beperkt was, moet worden aangenomen dat **alle 6 bestanden** gekopieerd kunnen zijn.
📸 *[screenshot]*

### Conclusie
Het probleem is **bevestigd**. Door een configuratiefout in Samba (gasttoegang op alle mappen), te ruime rechten op de map Management en verkeerd ingesteld eigenaarschap van de mappen konden onbevoegden **zonder authenticatie** gegevens van **alle afdelingen** inzien en kopiëren. Daaronder vallen **persoonsgegevens van klanten**. Er is daarom sprake van een **datalek in de zin van de AVG**. De impact is groter dan één afdeling; de directie moet worden geïnformeerd (zie communicatiematrix).

### Aanpassing
| # | Aanpassing | Commando / plek | Test |
|---|---|---|---|
| 1 | Backup van de configuratie gemaakt | `cp /etc/samba/smb.conf /etc/samba/smb.conf.bak` | – |
| 2 | **Gasttoegang uitgeschakeld** | [global]: `map to guest = never`, `restrict anonymous = 2`, `usershare allow guests = no`; alle shares: `guest ok = no` | `smbclient //localhost/<share> -N` → **NT_STATUS_ACCESS_DENIED** op alle shares ✅ |
| 3 | **Gastaccount uitgeschakeld** | `smbpasswd -d gast`, `usermod -L -s /usr/sbin/nologin gast` (Windows: Guest → *Account is disabled*) | `pdbedit -L -v` → flag `[D]` · `passwd -S gast` → `L` ✅ |
| 4 | **Rechten management beperkt** | `[management]` `valid users = @management` | hannekecool → toegang ✅ · younesbulut → ACCESS_DENIED ✅ |
| 5 | **Eigenaarschap gecorrigeerd** | `chown -R root:<afdeling> /home/fileserver/<map>` · `chmod 2770` | `ls -l` → `drwxrws--- root <afdeling>` ✅ |
| 6 | Samba herstart en configuratie gecontroleerd | `testparm -s` · `systemctl restart smbd` · `diff smb.conf.bak smb.conf` | "Loaded services file OK" ✅ |

📸 *[screenshot diff voor/na] · [screenshot elke test]*

## Communicatiematrix
| Probleem | Impact | Met wie contact opnemen | Van toepassing |
|---|---|---|---|
| Rechten verkeerd ingesteld | Gegevens van 1 gebruiker | De betreffende gebruiker | Nee |
| Rechten verkeerd ingesteld | Gegevens van 1 afdeling | Alle medewerkers binnen de afdeling + de directie | Nee |
| Rechten verkeerd ingesteld | Groter dan 1 afdeling | De directie | **Ja**: eigenaarschap alle mappen, management te ruim |
| Configuratiefout fileserver | Gegevens van 1 gebruiker | De betreffende gebruiker | Nee |
| Configuratiefout fileserver | Gegevens van 1 afdeling | Alle medewerkers binnen de afdeling + de directie | Nee |
| Configuratiefout fileserver | Groter dan 1 afdeling | De directie | **Ja**: gasttoegang op alle mappen |
| Mogelijk datalek persoonsgegevens | Klanten en medewerkers | AVG-verantwoordelijke (S. Aslan) + directie → melding AP binnen 72 uur, betrokkenen informeren | **Ja** |

**Communicatieadvies:** de directie (mevrouw Cool) wordt geïnformeerd, met een kopie aan mevrouw Aslan als AVG-verantwoordelijke. Zij beoordelen of de melding bij de Autoriteit Persoonsgegevens binnen 72 uur moet worden gedaan en of klanten en medewerkers moeten worden geïnformeerd. Medewerkers worden pas na het dichten van het lek, en zonder technische details, ingelicht.
