# 02 · Windows Server: waar vind ik wat?

In de proeftoets stond SRV001 er **ook als Windows-server**: map `C:\Fileserver` met de afdelingsmappen. De docent controleerde allebei. Hieronder staat per vraag **waar je klikt**, en ernaast het **PowerShell/cmd-commando** dat hetzelfde laat zien.

> 💡 **Snel openen:** druk **Win + R**, typ de naam (bijv. `lusrmgr.msc`) en druk op Enter.
> PowerShell als admin: rechtsklik **Start** → **Windows PowerShell (Admin)** / **Terminal (Admin)**.

---

## 1. Gebruikers: wie bestaat er?
**Waar:** `Win + R` → **`lusrmgr.msc`** → **Users**
(of: Server Manager → Tools → **Computer Management** → System Tools → **Local Users and Groups** → **Users**)

| Kolom / plek | Waar let je op |
|---|---|
| **Name** | inlognaam, bijv. `SalmaDemirci` |
| **Full Name** | vergelijk met de lijst uit het interview (achternaam!) |
| Pijltje-omlaag-icoontje op het gebruikersicoon | account is **uitgeschakeld** |
| Dubbelklik op een gebruiker → tabblad **General** | ☐ **Account is disabled** · ☐ Password never expires |
| Tabblad **Member Of** | in welke groepen zit deze gebruiker |
| **Guest** | ⚠️ ingebouwd gastaccount. Moet **disabled** zijn (pijltje-icoon) |

```powershell
Get-LocalUser                                        # alle gebruikers + Enabled True/False
Get-LocalUser | Select Name, FullName, Enabled, LastLogon
Get-LocalUser -Name Guest                            # gastaccount: Enabled moet False zijn
net user                                             # cmd: lijst
net user SalmaDemirci                                # details + "Local Group Memberships"
net user Guest                                       # "Account active  Yes" ⚠️
```

## 2. Groepen: wie zit waar?
**Waar:** `lusrmgr.msc` → **Groups** → dubbelklik op een groep (bijv. *Administratie*) → **Members**

```powershell
Get-LocalGroup                                       # alle groepen
Get-LocalGroupMember Administratie                   # leden van één groep
foreach ($g in 'Administratie','Magazijn','Management','Sales','Iedereen') {
  "== $g"; (Get-LocalGroupMember $g).Name }          # alles in één screenshot
net localgroup Administratie                         # cmd
net localgroup Guests                                # wie zit in de ingebouwde gastgroep?
```

## 3. Gedeelde mappen (shares): welke zijn er?
**Waar:** `Win + R` → **`fsmgmt.msc`** → **Shares**
(of: Computer Management → System Tools → **Shared Folders** → **Shares**)

Je ziet hier: sharenaam, pad (`C:\Fileserver\Sales`), aantal verbindingen.

```powershell
Get-SmbShare                                         # alle shares + pad
net share                                            # cmd
```

## 4. Wie mag bij een share? (share-rechten)
**Waar:** `fsmgmt.msc` → **Shares** → rechtsklik op de share → **Properties** → tabblad **Share Permissions**
of: Verkenner → `C:\Fileserver` → rechtsklik op de map → **Properties** → tabblad **Sharing** → **Advanced Sharing…** → **Permissions**

| Wat zie je | Goed / fout |
|---|---|
| Groep van de afdeling (bijv. `Sales`) | ✅ |
| `Management` | ✅ (als management overal bij mag) |
| Een **losse gebruiker** (persoon-icoon, bijv. `AnnieStryker`) | ⚠️ rechten horen via **groepen** |
| `Guest` / `Guests` | ⚠️ **gast heeft toegang** |
| `Everyone` | ⚠️ iedereen, ook gasten (als het gastaccount aanstaat) |
| Groep van een **andere** afdeling | ⚠️ (tenzij bewust gevraagd, zoals Administratie op Sales) |

Rechten: **Full Control** (alles) · **Change** (lezen + schrijven) · **Read** (alleen lezen)

```powershell
Get-SmbShareAccess -Name Sales                       # wie mag bij de share Sales
Get-SmbShare | Where-Object Path -like 'C:\Fileserver*' | ForEach-Object { Get-SmbShareAccess -Name $_.Name }   # alle afdelingsshares
```

## 5. NTFS-rechten en eigenaar van de map (eigenaarschap!)
Er zijn **twee lagen** rechten: de **share-rechten** (§4) en de **NTFS-rechten** op de map zelf. De **strengste** van de twee wint.

**Waar:** Verkenner → rechtsklik op de map → **Properties** → tabblad **Security**
- bovenste vak: groepen en gebruikers met rechten
- **Advanced** → bovenaan **Owner: …** = **eigenaar** van de map ← *"eigenaarschap verkeerd geconfigureerd"*

```powershell
Get-Acl C:\Fileserver\Sales | Format-List Owner, AccessToString    # eigenaar + rechten
icacls C:\Fileserver\Sales                                         # cmd: rechten
dir C:\Fileserver /q                                               # eigenaar van elke map
```
`icacls`-afkortingen: **(F)** full · **(M)** modify · **(RX)** lezen+uitvoeren · **(R)** lezen · **(W)** schrijven · **(OI)(CI)** geldt ook voor submappen en bestanden

## 6. Wie is er nu verbonden en wat staat er open?
**Waar:** `fsmgmt.msc` → **Sessions** (wie is verbonden, vanaf welke computer) en **Open Files** (welke bestanden)

```powershell
Get-SmbSession                    # verbonden gebruikers + IP
Get-SmbOpenFile                   # geopende bestanden
```

## 7. Wanneer is het gebeurd? (Event Viewer)
**Waar:** `Win + R` → **`eventvwr.msc`** → **Windows Logs** → **Security** → rechts **Filter Current Log…** → vul bij *Event IDs* het nummer in

| Event ID | Betekent | Waar let je op |
|---|---|---|
| **4624** | succesvolle login | *Logon Type 3* = via het netwerk (share) · *Account Name* = **Guest** of **ANONYMOUS LOGON** ⚠️ · *Source Network Address* = IP |
| **4625** | mislukte login | veel achter elkaar = iemand probeert wachtwoorden |
| **5140** | share geopend | welke share, door wie, vanaf welk IP |
| **5145** | bestand in een share benaderd | welk bestand (alleen als auditing aan staat) |
| 4720 / 4726 | gebruiker aangemaakt / verwijderd | |
| 4722 / 4725 | account ingeschakeld / uitgeschakeld | wanneer is Guest aangezet? |
| 4732 / 4733 | lid toegevoegd aan / verwijderd uit groep | |

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 50 |
  Where-Object { $_.Message -match 'Guest|ANONYMOUS' } | Select TimeCreated, Message
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=5140} -MaxEvents 50 | Select TimeCreated, Message
```
> Staan 5140/5145 er niet in? Dan stond **auditing uit**. Dat is óók een bevinding + advies:
> `secpol.msc` → Advanced Audit Policy Configuration → System Audit Policies → **Object Access** → **Audit File Share** en **Audit Detailed File Share** → Success + Failure.

Wanneer is een bestand laatst geopend? Verkenner → rechtsklik → **Properties** → **General** → *Accessed* (of `Get-ChildItem C:\Fileserver -Recurse | Select FullName, LastAccessTime`).

## 8. Hoeveel informatie? Welke bestanden?
```powershell
Get-ChildItem C:\Fileserver -Recurse -File | Select FullName, Length, LastAccessTime      # alle bestanden
(Get-ChildItem C:\Fileserver -Recurse -File).Count                                         # aantal
Get-ChildItem C:\Fileserver -Directory | ForEach-Object {
  [pscustomobject]@{Map=$_.Name; Bestanden=(Get-ChildItem $_.FullName -Recurse -File).Count;
  MB=[math]::Round((Get-ChildItem $_.FullName -Recurse -File | Measure-Object Length -Sum).Sum/1MB,2)} }   # per map
```
Of: Verkenner → rechtsklik op `C:\Fileserver` → **Properties** → *Size* en *Contains: x Files*.

## 9. Gastinstellingen in het beveiligingsbeleid
**Waar:** `Win + R` → **`secpol.msc`** → **Local Policies** → **Security Options**

| Instelling | Veilig |
|---|---|
| Accounts: **Guest account status** | **Disabled** |
| Network access: **Let Everyone permissions apply to anonymous users** | **Disabled** |
| Network access: **Restrict anonymous access to Named Pipes and Shares** | **Enabled** |
| Network access: **Shares that can be accessed anonymously** | **leeg** |
| Network access: Do not allow anonymous enumeration of SAM accounts and shares | **Enabled** |

---

## 10. Aanpassen

### Gastaccount uitschakelen
`lusrmgr.msc` → Users → dubbelklik **Guest** → ☑ **Account is disabled** → OK
```powershell
Disable-LocalUser -Name Guest
Get-LocalUser Guest            # controle: Enabled = False
net user Guest /active:no      # cmd
```

### Guest / Everyone / losse gebruiker uit een share halen
Share Permissions → selecteer **Guest** (of AnnieStryker) → **Remove** → **Apply**
```powershell
Revoke-SmbShareAccess -Name Management -AccountName Guest -Force
Revoke-SmbShareAccess -Name Sales -AccountName AnnieStryker -Force
Revoke-SmbShareAccess -Name Management -AccountName Everyone -Force
Grant-SmbShareAccess  -Name Sales -AccountName Administratie -AccessRight Full -Force   # groep toevoegen
Get-SmbShareAccess -Name Sales                                                        # controle
```

### Gebruiker verwijderen of uitschakelen (oud-medewerker)
`lusrmgr.msc` → Users → rechtsklik **BramBurg** → **Delete** (of: Properties → Account is disabled)
```powershell
Disable-LocalUser -Name BramBurg      # eerst uitschakelen (veilig, data blijft)
Remove-LocalUser  -Name BramBurg      # verwijderen
```

### Gebruiker uit een verkeerde groep halen
`lusrmgr.msc` → Groups → **Administratie** → selecteer **YounesBulut** → **Remove**
```powershell
Remove-LocalGroupMember -Group Administratie -Member YounesBulut
Add-LocalGroupMember    -Group Sales         -Member YounesBulut
```

### Volledige naam aanpassen
`lusrmgr.msc` → Users → dubbelklik → **Full name**
```powershell
Set-LocalUser -Name SalmaDemirci -FullName "Salma Aslan"
```

### Eigenaar van een map goedzetten
Properties → **Security** → **Advanced** → naast *Owner* op **Change** → `Administrators` → ☑ *Replace owner on subcontainers and objects* → OK
```powershell
icacls C:\Fileserver\Administratie /setowner Administrators /T
icacls C:\Fileserver\Administratie /grant "Administratie:(OI)(CI)M" "Management:(OI)(CI)M"
icacls C:\Fileserver\Administratie /remove AnnieStryker Guest Everyone
```

## 11. Testen
- Op een andere pc of op de server zelf: Verkenner → `\\SRV001\Management`. Als gast moet je nu een **inlogscherm** krijgen, en met een verkeerd account **Access is denied**.
- `Get-LocalUser Guest` → `Enabled : False`
- `Get-SmbShareAccess -Name Management` → alleen `Management` (en `Administrators`)
- Screenshot van elk "na"-scherm voor je logboek.
