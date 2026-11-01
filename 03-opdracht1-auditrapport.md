# 03 · Opdracht 1: security-audit + auditrapport (W1, 12 punten, 180 min)

**Kort:** vergelijk de **lijst uit het interview** (wie werkt er, op welke afdeling) met wat er **echt op de server** staat (gebruikers, groepen, rechten op mappen). Elk verschil is een **bevinding**. Schrijf alles op in het **auditrapport** (Bijlage 1.2) en geef advies.

➡️ Volledig ingevuld voorbeeld: [voorbeelden/auditrapport-ingevuld.md](voorbeelden/auditrapport-ingevuld.md)

---

## Hoe word je beoordeeld? (uit de nakijkonderlegger van de docent)
| Criterium | 3 punten (volledig) als… | Hoe haal je dat |
|---|---|---|
| **Tools kiezen** | je **meerdere tools** hebt gekozen, **geconfigureerd** en gebruikt, en **motiveert waarom** | Tabel "Gebruikte tools" in je rapport (zie hieronder). Gebruikers **én** groepen **én** rechten op mappen bekeken |
| **Communicatie** | **alle 5 onderdelen** volledig en deskundig, **formeel/zakelijk**, voor de klant helder (geen vragen nodig) | U-vorm ("u"), geen spreektaal, tabellen, afwijkingen **rood** |
| **Security analyse** | overzicht van problemen met **goed ingeschatte impact**, **gesorteerd op prioriteit**, **5 of meer** gevonden | Tabel "Kwetsbaarheden en bedreigingen" met risico Hoog/Middel/Laag, hoogste bovenaan |
| **Verbetervoorstel** | helemaal ingevuld, **onderbouwd én haalbaar** | Per advies: *wat* · *waarom* · *hoe/wie/hoe lang* |

Cijfer: 6 pnt = 5.5 · 7 pnt = 6.3 · **8 pnt = 7.0** · 10 pnt = 8.5 · 12 pnt = 10

> ⚠️ Het voorbeeldrapport van de docent heeft **geen** aparte tabel met prioriteit en **geen** toolsmotivatie, maar de onderlegger vraagt dat wél voor 3 punten. Zet ze er dus bij.

---

## Stappenplan (180 min)
| Tijd | Stap |
|---|---|
| 10 min | Opdracht + interview lezen. **Maak de "zo hoort het"-tabel** (hieronder) |
| 10 min | Server starten, inloggen `administrator` / `T0or1`, `sudo su` |
| 20 min | **Gebruikers** controleren: `/etc/passwd`, `pdbedit -L`, gastaccount? 📸 |
| 15 min | **Groepen** controleren: `/etc/group` 📸 |
| 25 min | **Rechten op mappen**: `smb.conf` (valid users, guest ok), `ls -l /home/fileserver`, test met `smbclient -N` 📸 |
| (20 min) | Is er ook een **Windows**-server? Zelfde controles via `lusrmgr.msc` en share-rechten ([02](02-windows-waar-vind-ik-wat.md)) 📸 |
| 60 min | **Auditrapport** schrijven: 1.1 · 1.2 · kwetsbaarheden · conclusie · checklist · advies |
| 10 min | Nalezen: formeel? elke bevinding een screenshot? prioriteit gesorteerd? |

## Stap 1 · Maak eerst de "zo hoort het"-tabel (uit het interview)
| Medewerker | Afdeling = groep | Mag bij share |
|---|---|---|
| Tjeerd Nickson | administratie | administratie, iedereen |
| Salma **Aslan** | administratie | administratie, iedereen (+ sales: op haar verzoek, zie smb.conf-commentaar) |
| Bjorn Hentges | magazijn | magazijn, iedereen |
| Ayoub **Ahmadi** | magazijn | magazijn, iedereen |
| Hanneke Cool | management | **alle** mappen |
| Younes Bulut | sales | sales, iedereen |
| Annie Stryker | sales | sales, iedereen |
| *(niemand anders)* | | |
| *Gast* | – | **niets** |

## Stap 2 · Vergelijk met de server
Gebruik [01-linux-commandos.md §10](01-linux-commandos.md#10-spiekkaart-het-hele-onderzoek-in-15-commandos). Vink af:

| Controle (= checklist uit het sjabloon) | Commando | Fout als… |
|---|---|---|
| Zijn alle medewerkers opgenomen als gebruiker? | `grep /home /etc/passwd` · `pdbedit -L` | iemand van de lijst ontbreekt |
| Kloppen de namen? | `getent passwd <naam>` (Full name) | andere achternaam |
| Zijn alle voormalige medewerkers verwijderd? | zelfde | iemand staat erin die **niet** op de lijst staat |
| Bestaat er een actief gastaccount? | `grep -iE "gast\|guest" /etc/passwd` · `pdbedit -L -v` · Windows: `Get-LocalUser Guest` | Enabled / geen `D`-flag |
| Zitten alle gebruikers in de juiste groep? | `cat /etc/group` | iemand in een groep van een andere afdeling |
| Zijn rechten op mappen verleend aan de juiste groepen? | `grep -A8 "\[sales\]" /etc/samba/smb.conf` | andere afdeling heeft toegang |
| Hebben de juiste groepen toegang tot alle mappen? | zelfde | afdeling mist bij eigen map, management mist |
| Zijn alle rechten verleend aan **groepen**, niet aan personen? | `grep "valid users" /etc/samba/smb.conf` | naam **zonder @** (bijv. `anniestryker`) |
| Kan een gast erbij? | `grep -i guest smb.conf` · `smbclient -L //localhost -N` | `guest ok = yes`, `map to guest = bad user` |
| Klopt de eigenaar van de mappen? | `ls -l /home/fileserver` | eigenaar is een medewerker, of rechten `rwxrwxrwx` |

## De 6 fouten uit de proeftoets (onderlegger docent)
| # | Bevinding | Waar gezien |
|---|---|---|
| 1 | Gast heeft rechten (Windows: Guest op share **Management**) | Share Permissions / `smb.conf` |
| 2 | **Bram Burg** (Sales) staat niet op de medewerkerslijst → oud-medewerker nog actief | `/etc/passwd`, `/etc/group` (sales), Windows Users |
| 3 | **Annie Stryker** heeft als **losse gebruiker** rechten op Administratie, Iedereen en Sales | `valid users = …, anniestryker` / Share Permissions |
| 4 | **Younes Bulut** (Sales) zit ook in groep **Administratie** | `/etc/group` |
| 5 | **Salma** heet in het systeem **Demirci**, op de lijst **Aslan** | `/etc/passwd`, Full Name |
| 6 | **Ayoub** heet in het systeem **Özcan**, op de lijst **Ahmadi** | `/etc/passwd`, Full Name |

**Géén fout:** `@administratie` op share **sales**. In `smb.conf` staat `#administratie toegevoegd per 3 januari 2023 op verzoek van Salma`. Benoem dat in je rapport als *"gecontroleerd, akkoord (gedocumenteerde uitzondering)"*. Dat laat zien dat je goed kijkt.

> Het examen is "bijna identiek, met andere namen". Verwacht dus hetzelfde **soort** fouten: andere naam, oud-medewerker, persoon in de verkeerde groep, persoon direct op een share, gasttoegang, verkeerde eigenaar/rechten.

---

## Impact en risico inschatten
**Risico = kans × impact**

| | Impact laag (weinig/niet-gevoelige data) | Impact hoog (persoonsgegevens, financiën, management) |
|---|---|---|
| **Kans hoog** (iedereen kan het, geen wachtwoord) | Middel | **Hoog** |
| **Kans laag** (alleen een eigen medewerker, met wachtwoord) | Laag | Middel |

Denk bij impact aan **BIV**:
- **B**eschikbaarheid: kan data weg/kapot? (schrijfrechten!)
- **I**ntegriteit: kan data veranderd worden?
- **V**ertrouwelijkheid: kan iemand meelezen die dat niet mag?

| Bevinding | Kans | Impact | **Risico** | Waarom |
|---|---|---|---|---|
| Gasttoegang op een share | Hoog: geen wachtwoord nodig | Hoog: managementgegevens, mogelijk persoonsgegevens | **Hoog** | Iedereen in het netwerk kan lezen/schrijven/kopiëren = **datalek (AVG)** |
| Oud-medewerker nog actief | Middel/hoog: kent het wachtwoord, is niet meer in dienst | Hoog: klantgegevens Sales | **Hoog** | Iemand van buiten de organisatie heeft toegang |
| Persoon direct op share Administratie | Middel: eigen medewerker | Hoog: financiële/personeelsgegevens | **Middel** | Ziet gegevens van een andere afdeling; rechten worden onoverzichtelijk |
| Gebruiker in groep van een andere afdeling | Middel | Middel/hoog | **Middel** | Toegang tot administratie die niet bij de functie hoort |
| Verkeerde eigenaar/rechten op mappen (`777`) | Middel | Middel | **Middel** | Via de server zelf kan iedereen erbij; rechten kunnen worden aangepast |
| Naam in systeem wijkt af van HR-lijst | Laag | Laag | **Laag** | Administratieve fout. Wel onduidelijk wie het account gebruikt (identiteit/audit) |

---

## Tools: welke en waarom (voor "Tools kiezen" = 3 punten)
Zet deze tabel in je rapport onder *Overzicht van de te testen onderdelen*:

| Tool | Gebruikt voor | Waarom deze tool |
|---|---|---|
| `cat` + `grep` op `/etc/passwd` | lijst van alle Linux-gebruikers | bron van alle accounts op de server; met grep filter ik snel op echte gebruikers (`/home`) |
| `cat /etc/group`, `groups`, `id` | groepslidmaatschap | laat per afdeling zien wie lid is |
| `pdbedit -L -v` | Samba-gebruikers en hun status | alleen Samba-accounts kunnen op de shares; laat zien of een account (gast) uitgeschakeld is |
| `testparm -s` + `grep` op `smb.conf` | rechten per share (`valid users`, `guest ok`) | toont de configuratie zoals Samba die echt gebruikt, en controleert meteen op fouten |
| `smbclient -L //localhost -N` / `smbclient //localhost/<share> -N` | **testen** of een gast zonder wachtwoord bij de shares kan | aanval nadoen = **bewijs** in plaats van aanname (*geconfigureerd*: met `-N` = zonder wachtwoord) |
| `ls -l`, `getfacl` | eigenaar en rechten van de mappen op schijf | Samba-rechten zijn maar één laag; de bestandsrechten moeten ook kloppen |
| *(Windows)* `lusrmgr.msc`, Share Permissions, `Get-SmbShareAccess` | gebruikers, groepen, share-rechten | ingebouwde beheertools, betrouwbaar en volledig |
| *(optioneel, gespecialiseerd)* `nmap --script smb-enum-shares -p 445 <ip>` | shares en gasttoegang **van buitenaf** scannen | bekijkt de server zoals een aanvaller dat doet |

---

## Advies (verbetervoorstel): zo schrijf je het
Per advies **drie dingen**: **Wat** · **Waarom** (welk risico verdwijnt) · **Haalbaarheid** (wie, hoe lang, kosten).

> **Advies 1 (prioriteit Hoog): Gasttoegang volledig uitschakelen.**
> *Wat:* het gastaccount uitschakelen en in de Samba-configuratie `guest ok = no` en `map to guest = never` instellen.
> *Waarom:* nu kan iedereen in het netwerk zonder wachtwoord bij de map Management. Dat is een direct risico op een datalek, met meldplicht volgens de AVG.
> *Haalbaarheid:* een systeembeheerder kan dit binnen 15 minuten uitvoeren. Er zijn geen kosten, en medewerkers merken er niets van, want zij loggen al met hun eigen account in.

Meer adviezen (beleidsmatig **én** technisch, dat vraagt de onderlegger):
- **Technisch:** oud-medewerkers verwijderen · rechten alleen via groepen · gebruiker uit de verkeerde groep · namen corrigeren (via HR) · eigenaar/rechten van mappen `root:<afdeling>` + `2770` · logging aanzetten (`log level`, Windows auditing)
- **Beleidsmatig:** **in- en uitdienstprocedure** (HR meldt vertrek → IT blokkeert dezelfde dag) · **autorisatiematrix** (wie mag waarbij, eigenaar per map) · **periodieke controle** (elk kwartaal de rechten nalopen) · **least privilege** · wachtwoordbeleid
