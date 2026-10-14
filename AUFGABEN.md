# Aufgaben

Arbeite die Aufgaben der Reihe nach ab. **Jede Aufgabe = ein eigener Git-Branch
und ein Pull Request.** So übst du Git nebenbei wie im echten Team.

```bash
git checkout main && git pull
git checkout -b aufgabe-01-staging
# ... arbeiten, dbt build ...
git add . && git commit -m "Staging für Produkte, Bestellungen, Positionen"
git push -u origin aufgabe-01-staging
# auf GitHub: Pull Request öffnen, selbst reviewen, mergen
```

Hake ab, was erledigt ist. Musterlösungen: `loesungen/`.

---

## Aufgabe 0 – Ankommen (Snowflake + Git)

- [ ] `snowflake/01_setup.sql` ausführen. Erkläre dir: Warum gibt es eine eigene Rolle `transformer`?
- [ ] Ladung 1 hochladen und mit `02_laden.sql` laden. Zeilenzahlen prüfen.
- [ ] Projekt auf GitHub pushen, dbt verbinden, `dbt deps` und `dbt build` ausführen.
- [ ] In Snowflake `hub_kunde` und `sat_kunde_stammdaten` ansehen. Was steht in `hk_kunde`?
- [ ] Bonus: `select * from raw.shop.kunden at(offset => -60*5)` – was zeigt Time Travel?

## Aufgabe 1 – Staging (Woche 4–5)

Vorlage: `models/staging/stg_shop__kunden.sql`

- [ ] `stg_shop__produkte` – Preis als `decimal(10,2)`
- [ ] `stg_shop__bestellungen` – Datum als `date`, Status klein geschrieben
- [ ] `stg_shop__bestellpositionen` – Position und Menge als `integer`
- [ ] In `_staging.yml` Tests ergänzen: `not_null` auf Business Keys,
      `accepted_values` für den Status (`bezahlt`, `versendet`, `zugestellt`).
      Schreibweise in dbt 2 (Parameter stehen unter `arguments:`):
      ```yaml
      - name: status
        data_tests:
          - accepted_values:
              arguments:
                values: ['bezahlt', 'versendet', 'zugestellt']
      ```
- [ ] `dbt build --select staging` läuft grün

## Aufgabe 2 – Hashes verstehen (Woche 8)

Lies `macros/data_vault_hashes.sql` und `models/dv_stage/dvs_kunden.sql`.

- [ ] Kompiliere `dvs_kunden` (`dbt compile --select dvs_kunden`) und lies das SQL in `target/compiled/`
- [ ] Beantworte für dich: Warum `upper()` im Hash Key, aber nicht im Hashdiff?
- [ ] Baue `dvs_produkte`, `dvs_bestellungen`, `dvs_bestellpositionen`
- [ ] Überlege: `dvs_bestellungen` braucht **drei** Hash Keys. Welche und warum?
- [ ] Überlege: Warum gehört `position` in den Hash Key der Bestellposition?

## Aufgabe 3 – Hubs und Links (Woche 9)

Vorlage: `models/raw_vault/hubs/hub_kunde.sql`

- [ ] `hub_produkt`, `hub_bestellung`
- [ ] `link_bestellung_kunde` (Bestellung ↔ Kunde)
- [ ] `link_bestellposition` (Bestellung ↔ Produkt, mit `position`)
- [ ] Tests: Hash Keys `unique` + `not_null`, `relationships` vom Link zu beiden Hubs

## Aufgabe 4 – Satellites (Woche 9)

Vorlage: `models/raw_vault/sats/sat_kunde_stammdaten.sql`

- [ ] `sat_produkt_details` (Name, Kategorie, Listenpreis)
- [ ] `sat_bestellung_status` (Bestelldatum, Status)
- [ ] `sat_bestellposition` – ein Satellite **am Link** (Menge, Einzelpreis)
- [ ] Test `dbt_utils.unique_combination_of_columns` auf (Hash Key, ladedatum)

## Aufgabe 5 – Ladung 2: der eigentliche Härtetest

- [ ] In `02_laden.sql` `ladung_1` durch `ladung_2` ersetzen, Dateien hochladen, laden
- [ ] **Vorher** notieren: Wie viele Zeilen erwartest du in jedem Satellite? (README)
- [ ] `dbt build` ausführen und die Zahlen mit der Tabelle im README vergleichen
- [ ] Finde einen Kunden, der umgezogen ist: beide Stände im Satellite ansehen
- [ ] `dbt build` ein **zweites Mal** ausführen: Es dürfen keine neuen Zeilen entstehen. Warum nicht?
- [ ] Ladung 2 enthält eine negative Menge. Schreib den Singular Test
      `tests/assert_keine_negative_menge.sql`. Er wird fehlschlagen – gut so!
- [ ] Entscheide: Fehler in der Quelle melden und Test auf `severity: warn` stellen,
      oder die Zeile im Business Vault/Mart herausfiltern? (Tipp: Im Raw Vault wird
      **nie** gefiltert – er speichert, was die Quelle geliefert hat.)

## Aufgabe 6 – Business Vault und Marts (Woche 10)

- [ ] `business_vault/pit_kunde`: je Kunde und Stichtag der gültige Satellite-Stand
- [ ] Abfrage schreiben: Wo wohnte Kunde X am Tag von Ladung 1, wo heute?
- [ ] `business_vault/bv_kunde_segment`: Premium (≥ 1500 €), Stammkunde (≥ 500 €), Gelegenheitskunde
- [ ] `marts/dim_produkt` (aktueller Stand)
- [ ] `marts/fct_bestellpositionen` mit `umsatz_eur = menge * einzelpreis_eur`
- [ ] Segment in `dim_kunde` aufnehmen
- [ ] Analyse in `analyses/`: Umsatz je Kategorie und Monat

## Aufgabe 7 – Profi-Werkzeuge (Woche 11–12)

- [ ] **DRY:** Die Satellites sehen fast gleich aus. Schreibe ein Macro
      `sat_laden(hash_key, hashdiff, quelle, attribute)` und baue alle Satellites damit.
- [ ] **CI:** `.github/workflows/dbt.yml` – bei jedem Pull Request `dbt build`
      gegen ein eigenes CI-Schema (Snowflake-Zugang als GitHub Secrets)
- [ ] **Doku:** Beschreibungen für alle Models, `dbt docs generate`, Lineage ansehen
- [ ] **Vergleich:** Baue einen Hub zusätzlich mit dem Package AutomateDV oder
      datavault4dbt und vergleiche das erzeugte SQL mit deinem
- [ ] **Kosten:** In Snowsight unter *Admin » Cost Management* ansehen, wie viele
      Credits deine Läufe verbraucht haben
- [ ] README um eigene Erkenntnisse ergänzen – das Projekt ist dein Portfolio

---

## Fragen zum Selbsttest

1. Warum hat ein Hub keine beschreibenden Attribute?
2. Was passiert im Satellite, wenn dieselbe Ladung zweimal verarbeitet wird?
3. Warum ist der Raw Vault insert-only, und wo darf Geschäftslogik stehen?
4. Wann brauchst du eine PIT-Tabelle, wann reicht `qualify row_number()`?
5. Was ist der Unterschied zwischen `dbt run`, `dbt test` und `dbt build`?
6. Warum sind in RAW alle Spalten `varchar`?
