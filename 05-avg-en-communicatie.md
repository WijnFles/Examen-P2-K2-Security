# 05 · AVG, wie informeer je, en de communicatiematrix

Bij opdracht 2 gaan **3 van de 5 criteria** (15 punten) over communicatie en AVG: *AVG*, *Logboek*, *Informeren*. Hier haal je dus makkelijk punten.

## Waarom valt dit onder de AVG?
Conley is een **handelsbedrijf met een webshop voor particulieren**. Op de fileserver staan dus (waarschijnlijk) **persoonsgegevens** van klanten: namen, adressen, bestellingen, misschien IBAN. Daarnaast staan er gegevens van medewerkers (administratie, salaris).

**Persoonsgegevens die onbevoegden konden inzien of kopiëren = een datalek** (inbreuk op de beveiliging, AVG art. 4 lid 12). Het maakt niet uit of het zeker is dat iemand iets heeft gekopieerd. Dat het **kon**, is genoeg.

## Wettelijke verplichtingen (zet deze in de e-mail, vraag 5b)
| Verplichting | Wat | Wie doet het |
|---|---|---|
| **Meldplicht datalekken** (AVG art. 33) | Melden bij de **Autoriteit Persoonsgegevens (AP)** binnen **72 uur** na ontdekking, via het meldformulier op autoriteitpersoonsgegevens.nl. Niet nodig als het lek waarschijnlijk geen risico oplevert, maar bij open gasttoegang tot klantgegevens is dat er wel | **Conley** (de verwerkingsverantwoordelijke), meestal via de directie of de AVG-verantwoordelijke |
| **Betrokkenen informeren** (AVG art. 34) | Bij een **hoog risico** voor de betrokkenen (bijv. adres + IBAN) moeten de **klanten/medewerkers** zelf ook worden ingelicht, zonder onnodige vertraging | Conley |
| **Datalekregister** (AVG art. 33 lid 5) | **Elk** datalek intern documenteren: wat, wanneer, gevolgen, genomen maatregelen. Ook als het niet gemeld hoeft te worden | Conley (AVG-verantwoordelijke) |
| **Passende beveiliging** (AVG art. 32) | Technische en organisatorische maatregelen nemen om dit te voorkomen. Jouw verbeteringen + advies | Conley, met SecureIT |
| **SecureIT als verwerker** (AVG art. 33 lid 2) | Als externe partij meld jij het lek **zonder onredelijke vertraging aan de opdrachtgever**. Jij meldt het **niet zelf** bij de AP | **Jij** → mevrouw Cool |

> 💡 Mooie zin voor de e-mail: *"Omdat er mogelijk persoonsgegevens van klanten en medewerkers door onbevoegden zijn ingezien, is er sprake van een datalek in de zin van de AVG. Conley is verplicht dit binnen 72 uur na ontdekking te melden bij de Autoriteit Persoonsgegevens en het datalek vast te leggen in het interne datalekregister. Als het risico voor de betrokkenen hoog is, moeten ook de betrokken klanten en medewerkers worden geïnformeerd."*

## Wie informeer je? (Aan / CC)
| Persoon | Rol | In de mail |
|---|---|---|
| **Hanneke Cool** | directrice, opdrachtgever | **Aan** |
| **Salma Aslan** (administratie) | houdt zich bezig met **naleving van de AVG** (interview) | **CC** |
| Jouw leidinggevende bij SecureIT | "breng het bedrijf **en je leidinggevende** op de hoogte" (opdracht 1) | eventueel CC |
| Alle medewerkers | ❌ **niet**: het verslag bevat gevoelige informatie over de beveiliging | – |
| Autoriteit Persoonsgegevens | ❌ niet door jou, wel door Conley (benoem dat **in** de mail) | – |

> ⚠️ **Let op de namen in het interview van het examen.** In de proeftoets zegt het interview dat **Salma** de AVG doet, maar de nakijkonderlegger noemt **Bjorn Hentges**. Volg **wat er in jouw interview staat** en schrijf er één zin bij waarom, bijvoorbeeld: *"In CC: mevrouw Aslan, omdat zij volgens het interview verantwoordelijk is voor de naleving van de AVG."*

### "Volgens de AVG versturen": wat betekent dat?
- Alleen naar mensen die het **moeten** weten (need-to-know): directie + AVG-verantwoordelijke.
- **Geen** persoonsgegevens of wachtwoorden in de tekst van de mail zelf.
- Het verslag als **bijlage**. Bij voorkeur beveiligd: met een wachtwoord, dat je via een **ander kanaal** stuurt (telefoon/sms).
- **Benoem in de mail naar wie hij gaat en waarom** (dat staat letterlijk in de onderlegger!).
- **Van**: een zakelijk adres (`naam@secureit.nl`), geen privé-Gmail.

## Communicatiematrix invullen
De matrix in het sjabloon is al ingevuld met algemene regels. Jij laat zien **welke regel van toepassing is** op jouw bevindingen, en **wie je dus informeert**. Voeg een kolom toe:

| Probleem | Impact | Met wie contact opnemen | **Van toepassing?** |
|---|---|---|---|
| Rechten verkeerd ingesteld | Gegevens van 1 gebruiker | De betreffende gebruiker | Nee |
| Rechten verkeerd ingesteld | Gegevens van 1 afdeling | Alle medewerkers binnen de afdeling + de directie | Nee |
| Rechten verkeerd ingesteld | Groter dan 1 afdeling | De directie | **Ja**: eigenaarschap van alle mappen verkeerd, rechten op management te ruim |
| Configuratiefout fileserver | Gegevens van 1 gebruiker | De betreffende gebruiker | Nee |
| Configuratiefout fileserver | Gegevens van 1 afdeling | Alle medewerkers binnen de afdeling + de directie | Nee |
| Configuratiefout fileserver | Groter dan 1 afdeling | De directie | **Ja**: gasttoegang op **alle** mappen (alle afdelingen) |
| *(toegevoegd)* Mogelijk datalek met persoonsgegevens | Klanten en medewerkers | AVG-verantwoordelijke (Salma Aslan) + directie → zij melden bij de **Autoriteit Persoonsgegevens** en informeren zo nodig de **betrokkenen** | **Ja** |

**Communicatieadvies** (zet dit onder de matrix):
> *"Omdat de gasttoegang alle afdelingen betrof, wordt de directie (mevrouw Cool) geïnformeerd. Omdat er mogelijk persoonsgegevens zijn ingezien, gaat er een kopie naar mevrouw Aslan als AVG-verantwoordelijke. Zij beoordelen samen of het datalek binnen 72 uur bij de Autoriteit Persoonsgegevens gemeld moet worden en of klanten en medewerkers geïnformeerd moeten worden. Wij adviseren de medewerkers pas te informeren als het lek is gedicht, en daarbij geen technische details te delen."*
