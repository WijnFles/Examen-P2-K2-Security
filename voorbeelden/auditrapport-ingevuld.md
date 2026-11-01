# Auditrapport fileserver SRV001

| | |
|---|---|
| **Opdrachtgever** | Hanneke Cool namens Handelsbedrijf Conley |
| **Auteur** | Kyan Wossink, IT-expert SecureIT |
| **Datum** | 2 november 2026 |
| **Versie** | 1.0 |

> *Voorbeelduitwerking op basis van de proeftoets. Vervang de namen en bevindingen door wat je op het examen vindt. Afwijkingen in je Word-document **rood** maken.*

---

## 1. Overzicht van de te testen onderdelen
In dit auditrapport wordt beschreven welke onderdelen zijn getest en welke resultaten dit heeft opgeleverd.

Aanleiding: mevrouw Cool vindt het belangrijk dat alle gebruikers correct zijn ingesteld en geautoriseerd. Er is geen concrete aanwijzing van misbruik, maar zij wil zeker weten dat alles in orde is. Als uitgangspunt is de medewerkerslijst gebruikt die Tjeerd Nickson heeft opgesteld.

Getest zijn:
1. **Gebruikers en groepen**: bestaan alle medewerkers, zijn oud-medewerkers verwijderd, zitten gebruikers in de juiste groep?
2. **Rechten op mappen**: hebben alleen de juiste afdelingen (via groepen) toegang tot de gedeelde mappen, en is gasttoegang uitgeschakeld?

**Gebruikte tools**
| Tool | Doel | Motivatie |
|---|---|---|
| `/etc/passwd` (cat, grep) | overzicht van alle gebruikersaccounts | bevat alle accounts op de Linux-server |
| `/etc/group` (cat, groups) | groepslidmaatschap per afdeling | laat zien wie bij welke afdeling hoort |
| `pdbedit -L -v` | Samba-accounts en hun status | alleen Samba-accounts hebben toegang tot de gedeelde mappen |
| `/etc/samba/smb.conf`, `testparm -s` | rechten per gedeelde map | bevat wie toegang heeft (`valid users`) en of gasten toegang hebben |
| `smbclient -N` | test van gasttoegang zonder wachtwoord | bewijst in de praktijk of een onbevoegde bij de gegevens kan |
| `ls -l` | eigenaar en rechten van de mappen | controleert de tweede beveiligingslaag (bestandsrechten) |
| Local Users and Groups, Share Permissions (Windows) | gebruikers, groepen en share-rechten op de Windows-server | ingebouwde beheertools van Windows Server |

### 1.1 Gebruikers en groepen
Hieronder staat een samenvatting van de Windows-omgeving (Local Users and Groups) en de Linux-omgeving (`/etc/passwd`, `/etc/group`). Afwijkingen ten opzichte van de medewerkerslijst zijn **vetgedrukt** (in Word: rood).

| Medewerker (lijst) | Afdeling (lijst) | In systeem | Groep(en) in systeem | Opmerking |
|---|---|---|---|---|
| Tjeerd Nickson | Administratie | tjeerdnickson | administratie | in orde |
| Salma Aslan | Administratie | salmademirci | administratie | **Achternaam in het systeem is Demirci** |
| Bjorn Hentges | Magazijn | bjornhentges | magazijn | in orde |
| Ayoub Ahmadi | Magazijn | ayoubozcan | magazijn | **Achternaam in het systeem is Özcan** |
| Hanneke Cool | Management | hannekecool | management | in orde |
| Younes Bulut | Sales | younesbulut | sales, **administratie** | **Ook lid van groep Administratie** |
| Annie Stryker | Sales | anniestryker | sales | in orde (zie 1.2: directe rechten) |
| – | – | **bramburg** | **sales** | **Staat niet op de medewerkerslijst: oud-medewerker met actief account** |
| – | – | **Guest / Gast** | – | **Gastaccount actief met rechten op mappen** |

📸 *[screenshot `/etc/passwd`] · [screenshot `/etc/group`] · [screenshot Windows Users]*

### 1.2 Rechten op mappen
Hieronder staat per gedeelde map wie er toegang heeft. Dit is gecontroleerd in `/etc/samba/smb.conf` (Linux) en bij de share-rechten (Windows). Toegang die niet past bij de afdeling is **vetgedrukt**.

| Map | Hoort toegankelijk voor | Toegekend in systeem | Opmerking |
|---|---|---|---|
| Administratie | Administratie, Management | Administratie, Management, **Sales**, **Annie Stryker** | Sales en een losse gebruiker hebben toegang |
| Iedereen | Iedereen | Iedereen, **Annie Stryker** | Losse gebruiker (overbodig, zit al in de groep Iedereen) |
| Magazijn | Magazijn, Management | Magazijn, Management | in orde |
| Management | Management | Management, **Gast** | **Gasten hebben toegang tot managementgegevens** |
| Sales | Sales, Management, Administratie* | Sales, Management, Administratie, **Annie Stryker** | Losse gebruiker. *Administratie is akkoord: gedocumenteerd verzoek van Salma (3 januari 2023)* |

📸 *[screenshot smb.conf per share] · [screenshot `smbclient //localhost/management -N`] · [screenshot Share Permissions]*

### 1.3 Kwetsbaarheden en bedreigingen (gesorteerd op prioriteit)
| Prio | Kwetsbaarheid | Bedreiging | Kans | Impact | Risico |
|---|---|---|---|---|---|
| 1 | Gastaccount heeft toegang tot de map Management | Iedereen in het netwerk kan zonder wachtwoord vertrouwelijke managementgegevens inzien, kopiëren of wijzigen. Mogelijk datalek (AVG) | Hoog | Hoog | **Hoog** |
| 2 | Account van oud-medewerker Bram Burg is actief en lid van Sales | Een persoon buiten de organisatie heeft toegang tot klant- en verkoopgegevens | Middel | Hoog | **Hoog** |
| 3 | Annie Stryker heeft als losse gebruiker toegang tot Administratie (en Sales, Iedereen) | Een salesmedewerker kan financiële en administratieve gegevens inzien; rechten buiten de groepen om zijn onoverzichtelijk en worden vergeten | Middel | Hoog | **Middel** |
| 4 | Younes Bulut (Sales) is lid van groep Administratie | Toegang tot administratieve gegevens die niet bij zijn functie horen | Middel | Middel | **Middel** |
| 5 | Achternaam Salma wijkt af (Demirci / Aslan) | Onduidelijk wie het account gebruikt; controle en verantwoording worden lastig | Laag | Laag | **Laag** |
| 6 | Achternaam Ayoub wijkt af (Özcan / Ahmadi) | Idem | Laag | Laag | **Laag** |

## 2. Conclusie
De gebruikers en rechten op de fileserver zijn **niet juist geconfigureerd**. Er zijn zes afwijkingen gevonden, waarvan twee met een **hoog risico**:
- Gasten hebben zonder wachtwoord toegang tot de map Management.
- Een oud-medewerker heeft nog een actief account met toegang tot Sales.

Daarnaast hebben medewerkers toegang tot mappen van een andere afdeling. Bij één medewerker loopt dat via een directe toekenning, buiten de groepen om. Twee namen in het systeem komen niet overeen met de medewerkerslijst.

Omdat gasten toegang hadden, kan niet worden uitgesloten dat onbevoegden gegevens hebben ingezien. Wij adviseren de punten met een hoog risico **direct** op te lossen en daarna de gehele server periodiek na te lopen op gebruikers, groepen en rechten.

## 3. Checklist testen
| Gebruikers en groepen | |
|---|---|
| Zijn alle medewerkers opgenomen als gebruiker? | Ja |
| Zijn alle voormalige medewerkers verwijderd? | **Nee**: Bram Burg |
| Zijn alle gebruikers opgenomen in de juiste groepen? | **Nee**: Younes Bulut in Administratie |
| **Rechten op mappen** | |
| Zijn rechten op mappen verleend aan de juiste groepen? | **Nee**: Sales op Administratie, Gast op Management |
| Hebben de juiste groepen toegang tot alle mappen? | Ja (Management heeft overal toegang; afdelingen tot hun eigen map) |
| Zijn alle rechten verleend aan groepen, dus niet direct aan medewerkers? | **Nee**: Annie Stryker |

> *Let op: de docent vulde hier deels anders in (Ja/Nee/Nee/Ja/Nee/Nee). Het gaat om de onderbouwing: zet er altijd achter **waarom**.*

## 4. Advies
| Prio | Advies | Onderbouwing | Haalbaarheid |
|---|---|---|---|
| 1 | **Gasttoegang uitschakelen**: gastaccount uitschakelen (Windows: *Account is disabled*; Linux/Samba: `map to guest = never`, `guest ok = no` op alle shares) | Neemt het grootste risico weg: niemand komt nog zonder wachtwoord bij de gegevens | Systeembeheerder, 15 minuten, geen kosten, geen hinder voor medewerkers |
| 2 | **Account van Bram Burg blokkeren en daarna verwijderen** | Oud-medewerkers horen geen toegang te hebben | 5 minuten. Eerst blokkeren, dan na overleg met de leidinggevende de data overzetten en het account verwijderen |
| 3 | **Rechten alleen via groepen toekennen**: Annie Stryker als losse gebruiker van de shares halen, Sales van Administratie halen | Groepen maken rechten overzichtelijk en controleerbaar; een medewerker krijgt automatisch de rechten van zijn afdeling | 15 minuten. Annie behoudt via de groep Sales haar toegang tot Sales en Iedereen |
| 4 | **Younes Bulut uit de groep Administratie halen** | Toegang hoort bij de functie (least privilege) | 2 minuten. Eerst bij de directie navragen of hij bewust toegang nodig heeft |
| 5 | **Namen laten controleren door HR** en de volledige naam in het systeem corrigeren | Accounts moeten eenduidig bij één persoon horen | 10 minuten; gebruikersnaam blijft gelijk om problemen met bestanden te voorkomen |
| 6 | **In- en uitdienstprocedure**: HR meldt vertrek of functiewissel, IT past dezelfde dag de rechten aan | Voorkomt dat oud-medewerkers en verkeerde rechten blijven bestaan | Beleidsmatig: één afspraak tussen HR en IT, plus een formulier |
| 7 | **Autorisatiematrix** vastleggen (wie mag waarbij) en **elk kwartaal** controleren | Afwijkingen worden op tijd ontdekt | 1 uur per kwartaal |
| 8 | **Logging/auditing aanzetten** (Samba `log level`, Windows *Audit File Share*) | Bij een incident is dan na te gaan wie wat wanneer heeft geopend | 10 minuten, geen kosten |
