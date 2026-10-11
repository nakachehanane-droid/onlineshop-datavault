# NordLicht Wohnen – Data Vault mit dbt und Snowflake

Übungsprojekt: Du baust das Data Warehouse für einen fiktiven Möbel-Onlineshop.
Rohdaten kommen in zwei Ladungen nach Snowflake, dbt modelliert sie als
**Data Vault 2.0** und baut daraus ein **Star-Schema** fürs Reporting.
Alles läuft über **Git** mit Branches und Pull Requests.

```
CSV-Dateien ──COPY INTO──▶ RAW (Snowflake)
                              │
                       dbt    ▼
   staging ──▶ dv_stage ──▶ raw_vault ──▶ business_vault ──▶ marts
   (Typen)     (Hashes)     (Hub/Link/Sat)  (PIT, Regeln)     (dim/fct)
```

## Datenmodell (Ziel)

```
          ┌──────────────┐        ┌────────────────────┐        ┌──────────────┐
          │  hub_kunde   │◀───────│link_bestellung_kunde│──────▶│hub_bestellung│
          └──────┬───────┘        └────────────────────┘        └──────┬───────┘
                 │                                                     │
   sat_kunde_stammdaten                                    sat_bestellung_status
                                                                       │
          ┌──────────────┐        ┌────────────────────┐               │
          │ hub_produkt  │◀───────│link_bestellposition│───────────────┘
          └──────┬───────┘        └─────────┬──────────┘
                 │                          │
       sat_produkt_details           sat_bestellposition
```

## Was ist schon fertig, was machst du?

| Schicht | Fertig als Vorlage | Deine Aufgabe |
| --- | --- | --- |
| Snowflake | `snowflake/01_setup.sql`, `02_laden.sql` | ausführen und verstehen |
| staging | `stg_shop__kunden` | Produkte, Bestellungen, Positionen |
| dv_stage | `dvs_kunden` + Hash-Macros | die drei anderen |
| raw_vault | `hub_kunde`, `sat_kunde_stammdaten` | 2 Hubs, 2 Links, 3 Satellites |
| business_vault | – | PIT-Tabelle, Kundensegment |
| marts | `dim_kunde` | `dim_produkt`, `fct_bestellpositionen` |

Die Schritt-für-Schritt-Aufgaben stehen in **[AUFGABEN.md](AUFGABEN.md)**.
Musterlösungen liegen in `loesungen/` – erst selbst probieren!

## Schnellstart

1. **Repo auf GitHub anlegen** (leer, ohne README) und dieses Projekt pushen:
   ```bash
   git remote add origin https://github.com/<dein-name>/onlineshop-datavault.git
   git push -u origin main
   ```
2. **Snowflake vorbereiten:** `snowflake/01_setup.sql` in einem Worksheet ausführen
   (Zeile mit `grant role transformer to user ...` anpassen).
3. **Ladung 1 hochladen und laden:** siehe Kopf von `snowflake/02_laden.sql`.
4. **dbt verbinden**
   - *dbt Cloud:* neues Projekt, Snowflake-Verbindung (Rolle `transformer`,
     Warehouse `lern_wh`, Datenbank `analytics`), dieses GitHub-Repo verknüpfen.
   - *dbt Core lokal:*
     ```bash
     python -m venv .venv && source .venv/bin/activate
     pip install dbt-snowflake
     cp profiles.yml.example ~/.dbt/profiles.yml   # dann ausfüllen
     dbt debug
     ```
5. **Erster Lauf:**
   ```bash
   dbt deps
   dbt build
   ```
   Danach gibt es in `analytics` die Schemas `<dein_schema>_staging`,
   `..._dv_stage`, `..._raw_vault` und `..._marts`.

## Erwartete Zeilenzahlen (zur Selbstkontrolle)

| Tabelle | nach Ladung 1 | nach Ladung 2 |
| --- | ---: | ---: |
| hub_kunde | 120 | 135 |
| sat_kunde_stammdaten | 120 | 145 |
| hub_produkt | 25 | 26 |
| sat_produkt_details | 25 | 29 |
| hub_bestellung | 400 | 460 |
| sat_bestellung_status | 400 | 485 |
| link_bestellung_kunde | 400 | 460 |
| link_bestellposition | 1030 | 1184 |
| sat_bestellposition | 1030 | 1184 |

Stimmen deine Zahlen, funktioniert deine Historisierung.

## Testdaten neu erzeugen

```bash
python tools/daten_erzeugen.py
```
Die Daten sind deterministisch – dieselben Zahlen bei jedem Lauf.
Ladung 2 enthält **absichtlich einen Datenfehler** (Aufgabe 5).

## Projektstruktur

```
├── data/ladung_1, data/ladung_2   CSV-Testdaten
├── snowflake/                      Setup- und Lade-Skripte
├── macros/data_vault_hashes.sql    hash_key() und hash_diff()
├── models/
│   ├── staging/        stg_*
│   ├── dv_stage/       dvs_*
│   ├── raw_vault/      hubs/ links/ sats/
│   ├── business_vault/
│   └── marts/
├── tests/              Singular Tests
├── loesungen/          Musterlösungen (nicht von dbt gelesen)
└── AUFGABEN.md
```
