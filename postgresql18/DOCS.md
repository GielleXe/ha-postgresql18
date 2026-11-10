# PostgreSQL 18 voor Home Assistant OS

Deze app gebruikt het officiële PostgreSQL 18-image. PostgreSQL bewaart
zijn data in de eigen datamap van de app. Home Assistant verbindt via het interne
netwerk van de Supervisor.

## Installeren

1. Open **Instellingen → Apps → App installeren**. Kies **Repositories** in het
   menu rechtsboven en voeg de URL van deze repository toe.
2. Open **PostgreSQL 18** uit deze repository en kies **Installeren**.
3. Stel onder **Configuratie** een uniek `recorder_password` in. Gebruik 24 tot
   128 tekens uit `A–Z`, `a–z`, `0–9`, `-` en `_`. Met
   `openssl rand -hex 24` maak je bijvoorbeeld een geschikt wachtwoord.
4. Start de app en wacht in het log op `database system is ready to accept connections`
   na `PostgreSQL init process complete`. Bij een volgende start is de
   initialisatie al voltooid. Het wachtwoord in de appconfiguratie wordt gebruikt
   bij het aanmaken van de database. Een latere wachtwoordwijziging moet je ook
   in PostgreSQL zelf doorvoeren.

## Recorder aansluiten

Maak eerst een back-up van je huidige Recorder-database. Home Assistant zet
bestaande SQLite-geschiedenis en energiestatistieken bij een databasewissel
niet automatisch over. Als je die wilt meenemen, regel de migratie vóór je
de configuratie omschakelt.

Voeg in `configuration.yaml` het volgende toe. Heb je al een `recorder:`-blok,
voeg dan alleen `db_url` toe aan dat blok.

```yaml
recorder:
  db_url: !secret recorder_db_url
```

Zoek de interne hostnaam van de app op. Voer in **Terminal & SSH**
`ha apps list` uit en zoek de volledige slug die eindigt op `_postgresql18`.
Voer daarna `ha apps info VOLLEDIGE_SLUG` uit en gebruik het veld
`hostname`. Op oudere installaties gebruik je `ha addons` in plaats van
`ha apps`.

Zet in `secrets.yaml` die hostnaam en dezelfde waarde die je als
`recorder_password` hebt ingesteld.

```yaml
recorder_db_url: "postgresql://homeassistant:VERVANG_DOOR_JE_WACHTWOORD@VERVANG_DOOR_HOSTNAAM:5432/homeassistant"
```

Herstart Home Assistant en controleer de logs op Recorder-fouten. Controleer
daarna in **Geschiedenis** of een recente toestandswijziging zichtbaar is.

## Back-ups en updates

Neem de app mee in je Home Assistant-back-ups. De Supervisor stopt PostgreSQL
kort tijdens de back-up zodat de databasebestanden consistent zijn.

Zet op het tabblad **Info** van de app **Automatisch bijwerken** aan. De
Supervisor installeert een nieuwere appversie zodra die wordt aangeboden.
De app herstart kort en gebruikt daarna dezelfde datamap.

Als je eerder de lokale app met hostnaam `local-postgresql18` gebruikte, heeft
de repositoryversie een eigen app-ID, hostnaam en datamap. Maak eerst een
back-up en zet die database over voordat je de Recorder naar de nieuwe hostnaam
omschakelt.
