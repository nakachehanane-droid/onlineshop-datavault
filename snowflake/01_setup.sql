-- =====================================================================
-- 01_setup.sql  –  Einmalig in einem Snowsight-Worksheet ausführen
-- Legt Warehouse, Rolle, Datenbanken, Stage und RAW-Tabellen an.
-- =====================================================================

use role accountadmin;

-- ---------------------------------------------------------------------
-- 1) Warehouse: klein und sparsam
-- ---------------------------------------------------------------------
create warehouse if not exists lern_wh
  warehouse_size = 'XSMALL'
  auto_suspend   = 60          -- nach 60 Sekunden Leerlauf schlafen legen
  auto_resume    = true
  initially_suspended = true;

-- ---------------------------------------------------------------------
-- 2) Rolle für dbt (nie mit ACCOUNTADMIN entwickeln!)
-- ---------------------------------------------------------------------
create role if not exists transformer;
grant role transformer to role sysadmin;
grant usage on warehouse lern_wh to role transformer;

-- Deinen eigenen Benutzer berechtigen (Namen anpassen!)
-- grant role transformer to user <DEIN_BENUTZERNAME>;

-- ---------------------------------------------------------------------
-- 3) Datenbanken
--    RAW       = Rohdaten, wie sie aus der Quelle kommen (nur Laden)
--    ANALYTICS = alles, was dbt baut (staging, raw_vault, marts ...)
-- ---------------------------------------------------------------------
create database if not exists raw;
create schema   if not exists raw.shop;
create database if not exists analytics;

grant usage on database raw to role transformer;
grant usage on schema raw.shop to role transformer;
grant select on all tables in schema raw.shop to role transformer;
grant select on future tables in schema raw.shop to role transformer;

grant ownership on database analytics to role transformer;

-- ---------------------------------------------------------------------
-- 4) Dateiformat und interne Stage
-- ---------------------------------------------------------------------
use schema raw.shop;

create or replace file format csv_semikolon
  type = csv
  field_delimiter = ';'
  skip_header = 1
  field_optionally_enclosed_by = '"'
  encoding = 'UTF8'
  null_if = ('', 'NULL');

create stage if not exists shop_stage
  file_format = csv_semikolon
  comment = 'Hier landen die CSV-Dateien aus data/ladung_1 und data/ladung_2';

-- ---------------------------------------------------------------------
-- 5) RAW-Tabellen
--    Jede Tabelle hat zwei technische Spalten:
--    _geladen_am  = wann wurde die Zeile geladen (wird zum Load Date im Vault)
--    _quelldatei  = aus welcher Datei kommt sie  (wird zur Record Source)
--    Die RAW-Schicht ist insert-only: hier wird nie etwas geändert.
-- ---------------------------------------------------------------------
create table if not exists kunden (
  kunden_nr        varchar,
  vorname          varchar,
  nachname         varchar,
  email            varchar,
  strasse          varchar,
  plz              varchar,
  stadt            varchar,
  registriert_am   varchar,
  _geladen_am      timestamp_ntz,
  _quelldatei      varchar
);

create table if not exists produkte (
  produkt_nr       varchar,
  produktname      varchar,
  kategorie        varchar,
  listenpreis_eur  varchar,
  _geladen_am      timestamp_ntz,
  _quelldatei      varchar
);

create table if not exists bestellungen (
  bestell_nr       varchar,
  kunden_nr        varchar,
  bestelldatum     varchar,
  status           varchar,
  _geladen_am      timestamp_ntz,
  _quelldatei      varchar
);

create table if not exists bestellpositionen (
  bestell_nr       varchar,
  position         varchar,
  produkt_nr       varchar,
  menge            varchar,
  einzelpreis_eur  varchar,
  _geladen_am      timestamp_ntz,
  _quelldatei      varchar
);

-- Hinweis: Alle Fachspalten sind bewusst VARCHAR. Rohdaten werden 1:1
-- übernommen; Datentypen setzt erst das dbt-Staging. So bricht ein Ladelauf
-- nie wegen eines kaputten Datums ab.
