# Examen P2-K2 · Controleert de security

Alles voor het examen **P2-K2 Security** (Expert IT systems and devices), gebaseerd op de **proeftoets SecureIT / Handelsbedrijf Conley**, de voorbeelduitwerkingen en de nakijkonderlegger van de docent.

| Werkproces | Opdracht | Tijd | Punten | Start hier |
|---|---|---|---|---|
| **W1** Geeft security advies en verbetert de security | Gebruikers, groepen en maprechten controleren → **auditrapport** | 180 min | 12 | [03-opdracht1-auditrapport.md](03-opdracht1-auditrapport.md) |
| **W2** Reageert op security incidenten | Gasttoegang onderzoeken + dichtzetten → **onderzoeksverslag, e-mail, logboek** | 120 min | 15 | [04-opdracht2-incident.md](04-opdracht2-incident.md) |

📋 **[EXAMENDAG.md](EXAMENDAG.md)**: het stappenplan op één pagina.

## Naslag
| Bestand | Wat |
|---|---|
| [01-linux-commandos.md](01-linux-commandos.md) | ⭐ **Alle Linux-commando's**: `ls`, `cat`, `grep`, `getent`, `pdbedit`, `testparm`, `smbclient`, `stat`, `find`, `du`, logs + aanpassen en testen |
| [02-windows-waar-vind-ik-wat.md](02-windows-waar-vind-ik-wat.md) | ⭐ **Windows: waar klik je**: lusrmgr, Share Permissions, Security-tab, Event Viewer, secpol + PowerShell |
| [05-avg-en-communicatie.md](05-avg-en-communicatie.md) | AVG-meldplicht (72 uur), wie in Aan/CC, communicatiematrix |

## Ingevulde voorbeelden (beter dan de voorbeelden van de docent: met prioriteit, tools en tests)
| Sjabloon | Ingevuld |
|---|---|
| Bijlage 1.2 Auditrapport | [voorbeelden/auditrapport-ingevuld.md](voorbeelden/auditrapport-ingevuld.md) · [.docx](voorbeelden/docx/) |
| Bijlage 2.1 Onderzoeksverslag | [voorbeelden/onderzoeksverslag-ingevuld.md](voorbeelden/onderzoeksverslag-ingevuld.md) |
| Bijlage 2.2 E-mail | [voorbeelden/email-ingevuld.md](voorbeelden/email-ingevuld.md) |
| Bijlage 2.4 Logboek | [voorbeelden/logboek-ingevuld.md](voorbeelden/logboek-ingevuld.md) |

## Oefenen
- [lab/maak-oefenserver.sh](lab/maak-oefenserver.sh): bouwt op een Ubuntu-VM een fileserver met **dezelfde fouten** als de proeftoets. Daarop kun je alle commando's oefenen.
- [afbeeldingen/docent/](afbeeldingen/docent/): de screenshots uit de uitwerkingen van de docent (`passwd`, `group`, `smb.conf`, Windows-schermen, vóór en ná).

## De situatie in één oogopslag
- **Klant:** Handelsbedrijf Conley (webshop voor particulieren → **persoonsgegevens → AVG**)
- **Opdrachtgever:** Hanneke Cool (directrice) · **AVG:** Salma (administratie) · **Lijst gemaakt door:** Tjeerd Nickson
- **Server:** SRV001, login `administrator` / `T0or1`, `sudo su` · Samba-shares in `/home/fileserver/<afdeling>` · (ook een Windows-variant met `C:\Fileserver`)
- **Afdelingen:** Administratie · Magazijn · Management (mag overal bij) · Sales · Iedereen

| Medewerker | Afdeling |
|---|---|
| Tjeerd Nickson | Administratie |
| Salma Aslan | Administratie |
| Bjorn Hentges | Magazijn |
| Ayoub Ahmadi | Magazijn |
| Hanneke Cool | Management |
| Younes Bulut | Sales |
| Annie Stryker | Sales |

## Getest
Alle Linux-commando's zijn uitgevoerd op een Samba-testserver die is opgebouwd zoals SRV001 (Ubuntu, Samba 4): gasttoegang aantonen, logs lezen, dichtzetten en hertesten. De Windows-stappen komen uit de schermen van de docent en de standaard PowerShell-cmdlets. Die zijn niet op een Windows-server uitgevoerd.
