# E-mail (Bijlage 2.2), ingevuld

> *Op het examen: gebruik de mailadressen die in de opdracht staan. Staan er geen? Verzin dan zakelijke adressen zoals hieronder, en zeg dat je dat gedaan hebt.*

| | |
|---|---|
| **Van** | kyan.wossink@secureit.nl |
| **Aan** | h.cool@conley.nl (Hanneke Cool, directrice, opdrachtgever) |
| **CC** | s.aslan@conley.nl (Salma Aslan, AVG-verantwoordelijke) |
| **Onderwerp** | Vertrouwelijk: onderzoek gasttoegang fileserver SRV001 |
| **Bijlage** | Onderzoeksverslag_SRV001_v1.0.pdf (beveiligd met wachtwoord, dat ik u telefonisch doorgeef) |

---

Geachte mevrouw Cool,

Op uw verzoek heb ik de server SRV001 gecontroleerd. Deze e-mail stuur ik aan u als opdrachtgever, met een kopie aan mevrouw Aslan, omdat zij verantwoordelijk is voor de naleving van de AVG. Het volledige onderzoeksverslag vindt u in de bijlage. Omdat het verslag gevoelige informatie over de beveiliging bevat, verzoek ik u het niet verder te verspreiden dan nodig.

**Bevindingen**
- De constatering is bevestigd: gegevens op de server konden **zonder wachtwoord** worden bekeken en gedownload.
- Oorzaak 1: de **gasttoegang stond open op alle mappen** van alle afdelingen.
- Oorzaak 2: de rechten op de map **Management** waren te ruim ingesteld.
- Oorzaak 3: het **eigenaarschap van de mappen** was verkeerd ingesteld.
- Uit de logbestanden blijkt dat op 1 november 2026 om 21:31 vanaf een onbekend apparaat (192.168.1.50) een bestand uit de map Management is geopend. Omdat alle mappen openstonden, moet worden aangenomen dat alle 6 bestanden (44 kB) gekopieerd kunnen zijn. Daaronder valt het klantenbestand van de webshop.

Ik heb de gasttoegang inmiddels volledig uitgeschakeld, de rechten op de map Management beperkt tot de groep Management en het eigenaarschap van alle mappen gecorrigeerd. Ik heb getest dat de server nu alleen nog toegankelijk is voor geautoriseerde medewerkers.

**Risico's**
- Er is een **hoog risico** dat persoonsgegevens van klanten en medewerkers door onbevoegden zijn ingezien of gekopieerd. Dit is een **datalek** in de zin van de AVG.
- Gekopieerde gegevens kunnen worden misbruikt, bijvoorbeeld voor phishing of fraude met de gegevens van uw klanten.
- Vertrouwelijke managementinformatie kan in verkeerde handen zijn gekomen.

**Adviezen en vervolgstappen**
1. **Datalek melden:** meld het datalek **binnen 72 uur** na ontdekking bij de **Autoriteit Persoonsgegevens** (AVG artikel 33), via het meldformulier op autoriteitpersoonsgegevens.nl.
2. **Betrokkenen informeren:** omdat het om naam-, adres- en bankgegevens gaat, is het risico voor de betrokkenen hoog. Informeer daarom de betrokken klanten en medewerkers (AVG artikel 34).
3. **Datalekregister:** leg het datalek vast in het interne datalekregister (AVG artikel 33 lid 5).
4. **Onderzoek naar 192.168.1.50:** laat nagaan welk apparaat dit IP-adres had. Zo weet u of het om een eigen apparaat of om een onbekende gaat.
5. **Wachtwoorden wijzigen:** laat alle medewerkers hun wachtwoord wijzigen.
6. **Logging aanzetten:** zet uitgebreide logging aan, zodat toegang tot bestanden voortaan te herleiden is.
7. **Periodieke controle:** laat de rechten op de server elk kwartaal controleren, en leg in een in- en uitdienstprocedure vast wie waarbij mag.

Voor vragen ben ik uiteraard bereikbaar.

Met vriendelijke groet,

Kyan Wossink
IT-expert, SecureIT
kyan.wossink@secureit.nl

---

### Waarom zo? (checklist onderlegger)
- [x] **Van** ingevuld met een zakelijk adres
- [x] **Aan** = opdrachtgever/directie · **CC** = AVG-verantwoordelijke
- [x] **Benoemd naar wie de mail gaat en waarom** (eerste alinea)
- [x] **Bijlage** = onderzoeksverslag, beveiligd verstuurd
- [x] Zakelijk: "Geachte mevrouw", u-vorm, kopjes uit het sjabloon
- [x] **Vervolgstappen** (5a) én **wettelijke verplichtingen** (5b: art. 33, 34, 33 lid 5)
- [x] Geen persoonsgegevens of wachtwoorden in de mailtekst
