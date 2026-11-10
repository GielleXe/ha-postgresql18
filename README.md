# PostgreSQL 18 voor Home Assistant OS

Deze apprepository gebruikt het officiële PostgreSQL-image. Home Assistant
Supervisor bouwt de app op het apparaat en beheert de installatie en updates.

## Repository publiceren

1. Maak een lege, openbare GitHub-repository en push de inhoud van deze map naar
   de standaardbranch. Zorg dat `repository.yaml` en `.github/workflows/` in
   de hoofdmap van de repository staan.
2. Schakel GitHub Actions in. De workflow heeft voor releases schrijfrechten
   op de standaardbranch nodig. Als een branchregel directe pushes blokkeert,
   kan de workflow de release niet aanbieden.
3. Start in **Actions → PostgreSQL 18-updates → Run workflow** een eerste
   controle. Wacht tot de tests op beide architecturen groen zijn.

## Installeren en automatisch bijwerken

1. Open in Home Assistant **Instellingen → Apps → App installeren**. Kies in
   het menu rechtsboven **Repositories** en voeg de GitHub-URL toe.
2. Installeer **PostgreSQL 18** uit deze repository. Volg de [apphandleiding](postgresql18/DOCS.md)
   om een wachtwoord in te stellen, de app te starten en de Recorder aan te sluiten.
3. Zet **Automatisch bijwerken** aan op het tabblad **Info** van de geïnstalleerde
   app. Neem de app op in je Home Assistant-back-ups.

De workflow controleert dagelijks of het officiële image `postgres:18` een
nieuwere 18.x-versie bevat. Bij een nieuwe patch test hij op amd64 en arm64
of het Recorder-account kan verbinden en of bestaande data behouden blijft.
Daarna verhoogt hij de appversie op de standaardbranch. Home Assistant ziet
de versie bij de volgende controle en installeert die als automatisch
bijwerken aanstaat. De database herstart kort tijdens de update.

GitHub kan geplande workflows in openbare repositories na 60 dagen zonder
activiteit uitschakelen. Bij een geslaagde controle zonder nieuwe versie legt
de workflow na 30 dagen zonder commit die controle vast met een lege commit.
Die verandert de appversie niet. Als GitHub de planning uitschakelt, kun je die
onder **Actions** opnieuw inschakelen.

De workflow blijft binnen PostgreSQL 18. Voor een volgende hoofdversie is een
databasemigratie nodig.
