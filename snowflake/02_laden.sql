-- =====================================================================
-- 02_laden.sql  –  Eine Ladung von der Stage in die RAW-Tabellen kopieren
--
-- VORHER: die CSV-Dateien in die Stage hochladen, je Ladung ein Ordner.
--
--   Variante A – Snowsight (ohne Installation):
--     Data » Databases » RAW » SHOP » Stages » SHOP_STAGE » "+ Files"
--     Pfad "ladung_1" angeben und die 4 Dateien aus data/ladung_1 hochladen.
--
--   Variante B – SnowSQL / Snowflake CLI:
--     put file://data/ladung_1/*.csv @raw.shop.shop_stage/ladung_1/ auto_compress=false;
--
-- Dann das Skript komplett ausführen. Für Ladung 2 vorher mit Suchen &
-- Ersetzen (Strg+H) überall "ladung_1" durch "ladung_2" ersetzen.
-- Ladung 2 erst laden, NACHDEM du dbt einmal mit Ladung 1 gebaut hast!
-- =====================================================================

use role accountadmin;
use warehouse lern_wh;
use schema raw.shop;

list @shop_stage;          -- Kontrolle: liegen die Dateien da?

-- COPY mit Transformation: $1, $2 ... sind die Spalten der CSV-Datei.
-- metadata$filename liefert den Dateipfad in der Stage -> Record Source.
copy into kunden
from (
  select $1, $2, $3, $4, $5, $6, $7, $8, current_timestamp()::timestamp_ntz, metadata$filename
  from @shop_stage/ladung_1/
)
files = ('kunden.csv');

copy into produkte
from (
  select $1, $2, $3, $4, current_timestamp()::timestamp_ntz, metadata$filename
  from @shop_stage/ladung_1/
)
files = ('produkte.csv');

copy into bestellungen
from (
  select $1, $2, $3, $4, current_timestamp()::timestamp_ntz, metadata$filename
  from @shop_stage/ladung_1/
)
files = ('bestellungen.csv');

copy into bestellpositionen
from (
  select $1, $2, $3, $4, $5, current_timestamp()::timestamp_ntz, metadata$filename
  from @shop_stage/ladung_1/
)
files = ('bestellpositionen.csv');

-- Kontrolle: wie viele Zeilen je Ladung?
select _quelldatei, _geladen_am, count(*) as zeilen
from kunden group by all order by 2;

-- Erwartung nach Ladung 1: kunden 120 | produkte 25 | bestellungen 400 | bestellpositionen 1030
-- Erwartung nach Ladung 2: + 25       | + 4         | + 85             | + 154
--
-- Gut zu wissen: COPY INTO merkt sich bereits geladene Dateien (64 Tage).
-- Ein zweites Ausführen lädt dieselbe Datei NICHT doppelt.
