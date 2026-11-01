# 📋 Examendag P2-K2 Security: stappenplan

## Vooraf
- [ ] [01-linux-commandos.md](01-linux-commandos.md) en [02-windows-waar-vind-ik-wat.md](02-windows-waar-vind-ik-wat.md) open in een tabblad
- [ ] Word-sjablonen klaar: auditrapport, onderzoeksverslag, e-mail, logboek
- [ ] Onthoud: **elke bevinding = screenshot** · **prioriteit sorteren** · **tools motiveren** · **testen na elke aanpassing**

---

## Opdracht 1 · Auditrapport (180 min)
1. **Interview lezen** → maak de tabel *medewerker → afdeling → mag bij welke map* ([03 stap 1](03-opdracht1-auditrapport.md#stap-1--maak-eerst-de-zo-hoort-het-tabel-uit-het-interview)).
2. Inloggen `administrator` / `T0or1` → `sudo su` → `whoami` → root.
3. **Gebruikers:** `grep /home /etc/passwd` · `pdbedit -L` · `grep -iE "gast|guest" /etc/passwd` 📸
   → ontbreekt er iemand? andere achternaam? iemand die **niet** op de lijst staat?
4. **Groepen:** `cat /etc/group` 📸 → iemand in de groep van een andere afdeling?
5. **Shares:** `grep -v -E "^\s*[#;]|^\s*$" /etc/samba/smb.conf` 📸
   → `valid users` met een **naam zonder @**? verkeerde afdeling? `guest ok = yes`? **lees ook het #commentaar** (uitzonderingen!)
6. **Gasttest:** `smbclient -L //localhost -N` + per share `smbclient //localhost/<share> -N -c ls` 📸
7. **Mappen:** `ls -l /home/fileserver` 📸 → eigenaar `root:<afdeling>`? geen `rwxrwxrwx`?
8. **Windows-server erbij?** `lusrmgr.msc` (Users, Groups, Guest) + map → Properties → **Sharing → Advanced Sharing → Permissions** + **Security** 📸
9. **Rapport** ([voorbeeld](voorbeelden/auditrapport-ingevuld.md)):
   - 1 Overzicht + **tabel gebruikte tools met motivatie**
   - 1.1 Gebruikers en groepen (tabel, afwijkingen **rood**)
   - 1.2 Rechten op mappen (tabel, afwijkingen **rood**)
   - **Kwetsbaarheden en bedreigingen**: kans × impact → **Hoog/Middel/Laag**, **hoogste bovenaan**, **≥ 5 stuks**
   - 2 Conclusie
   - Checklist met Ja/Nee **+ waarom**
   - **Advies**: per punt **wat · waarom · haalbaarheid**, technisch **én** beleid
10. **Formeel** schrijven: "u", geen "je/jij", geen spreektaal.

## Opdracht 2 · Incident (120 min)
0. **Logboek meteen openen**: elke actie = tijd + omschrijving + actie + 📸
1. **Bevestigen:** `smbclient -L //localhost -N` · `smbclient //localhost/management -N -c ls` 📸
2. **Zwakheden** (verwacht deze 3): gasttoegang op alle mappen · eigenaarschap mappen verkeerd · management te ruim → elk een **risiconiveau** 📸
3. **Wanneer:** `ls -l /var/log/samba/` · `grep -rh "opened file\|nobody" /var/log/samba/` · `stat` 📸
4. **Welke info:** `ls -lR /home/fileserver` → persoonsgegevens? (klanten webshop!) 📸
5. **Hoeveel:** `find /home/fileserver -type f | wc -l` · `du -sh /home/fileserver/*` 📸 → bij twijfel: **alles**
6. **Repareren:** backup → `smb.conf` (`map to guest = never`, `restrict anonymous = 2`, `guest ok = no` overal, `[management] valid users = @management`) → `testparm -s` → `systemctl restart smbd` → gastaccount uit → `chown root:<afdeling>` + `chmod 2770` 📸
7. **Testen:** gast → `ACCESS_DENIED` (alle shares) · management-gebruiker → werkt · andere afdeling → `DENIED` · `ls -l` 📸
8. **Onderzoeksverslag** ([voorbeeld](voorbeelden/onderzoeksverslag-ingevuld.md)) + **communicatiematrix** (kolom "van toepassing" + communicatieadvies)
9. **E-mail** ([voorbeeld](voorbeelden/email-ingevuld.md)):
   - **Van** (zakelijk) · **Aan** Hanneke Cool · **CC** AVG-verantwoordelijke (kijk in het interview!)
   - eerste alinea: **naar wie en waarom**
   - **bijlage** = onderzoeksverslag
   - vervolgstappen + **AVG**: melden bij de AP **binnen 72 uur** (art. 33), betrokkenen informeren (art. 34), datalekregister

---

## Als je vastloopt
| Probleem | Oplossing |
|---|---|
| `smbclient: command not found` | Test vanaf Windows: Verkenner → `\\<ip>` (ip via `hostname -I`) |
| `testparm` geeft een fout | Typfout in smb.conf → regelnummer staat erbij → `nano +<regel> /etc/samba/smb.conf` |
| Aanpassing werkt niet | `systemctl restart smbd` vergeten? |
| Iets kapot | `cp /etc/samba/smb.conf.bak /etc/samba/smb.conf` + restart |
| `userdel` faalt "user is currently used" | Gebruiker is ingelogd: `usermod -L` + `smbpasswd -d` (blokkeren) is ook goed |
| Geen logs | Ook een bevinding: "niet te achterhalen → worst case aannemen" + advies log level |
| Tijd dringt | Liever alle onderdelen half mét screenshots dan één perfect |

Succes Kyan! 💪
