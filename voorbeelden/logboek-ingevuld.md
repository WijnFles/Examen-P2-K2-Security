# Logboek (Bijlage 2.4), ingevuld

> *Bijhouden **tijdens** het werk, niet achteraf. Elke regel = tijd + wat je zag + wat je deed + screenshot. "Kort maar duidelijk" (docent). Zonder screenshots maximaal 2 van de 3 punten.*

**Datum:** 2 november 2026 · **Systeem:** SRV001 · **Uitgevoerd door:** Kyan Wossink (SecureIT)

| Tijd | Omschrijving kwetsbaarheid | Actie uitgevoerd | Screenshots |
|---|---|---|---|
| 09:05 | – | Ingelogd als administrator, root geworden (`sudo su`) | 📸 01 |
| 09:10 | Melding: gegevens downloadbaar zonder authenticatie | Gecontroleerd met `smbclient -L //localhost -N` en `smbclient //localhost/management -N -c ls`. **Bevestigd**: inhoud zichtbaar en downloadbaar zonder wachtwoord | 📸 02 |
| 09:20 | **Gasttoegang open op alle mappen** (`map to guest = bad user`, `guest ok = yes` op alle shares) · Risico **Hoog** | Gevonden in `/etc/samba/smb.conf` (`grep -n -i guest`) | 📸 03 |
| 09:25 | **Rechten map Management te ruim** (geen `valid users`) · Risico **Hoog** | Gevonden in `smb.conf` | 📸 04 |
| 09:30 | **Eigenaarschap mappen verkeerd** (administratie = `anniestryker:sales`, alle mappen 777) · Risico **Middel** | Gevonden met `ls -l /home/fileserver` | 📸 05 |
| 09:40 | Wanneer / wat / hoeveel | Logs: `grep -rh "opened file" /var/log/samba/` → gast opende `rapport-management.txt` op 01-11 21:31 vanaf 192.168.1.50 · `find … \| wc -l` → 6 bestanden · `du -sh` → 44 kB | 📸 06, 07 |
| 09:55 | – | Backup gemaakt: `cp /etc/samba/smb.conf /etc/samba/smb.conf.bak` | 📸 08 |
| 10:00 | Gasttoegang open | `smb.conf`: `map to guest = never`, `restrict anonymous = 2`, `usershare allow guests = no`, alle shares `guest ok = no` · `testparm -s` · `systemctl restart smbd` | 📸 09 (diff voor/na) |
| 10:05 | Gastaccount actief | `smbpasswd -d gast`, `usermod -L -s /usr/sbin/nologin gast` (Windows: Guest → *Account is disabled*) | 📸 10 |
| 10:10 | Rechten Management te ruim | `[management]` `valid users = @management` · Samba herstart | 📸 11 |
| 10:15 | Eigenaarschap verkeerd | `chown -R root:<afdeling>` + `chmod 2770` per afdelingsmap | 📸 12 |
| 10:20 | **Test** | Gast → `NT_STATUS_ACCESS_DENIED` op alle shares ✅ · hannekecool → management OK ✅ · younesbulut → management DENIED ✅ · `ls -l` → `drwxrws--- root <afdeling>` ✅ | 📸 13, 14, 15 |
| 10:45 | – | Onderzoeksverslag + e-mail verstuurd aan H. Cool, CC S. Aslan (AVG) | 📸 16 |

### Voorbeeld van de docent (proeftoets, Windows-kant)
| Tijd | Omschrijving kwetsbaarheid | Actie uitgevoerd |
|---|---|---|
| 14:00 | Guest is geactiveerd | Guest gedeactiveerd |
| 14:10 | Gebruiker die niet meer werkt voor het bedrijf is nog actief | Gebruiker Bram Burg verwijderd |
| 14:20 | Gebruiker (Annie Stryker) is toegevoegd aan een afdelingsshare waar ze niet hoort. Afdeling Administratie mist in deze share | Gebruiker verwijderd en groep toegevoegd |
