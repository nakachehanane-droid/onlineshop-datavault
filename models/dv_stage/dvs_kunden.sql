-- Data-Vault-Staging: hier werden alle Hashes EINMAL berechnet.
-- Hubs, Links und Satellites lesen nur noch aus dieser Schicht.

with stg as (

    select * from {{ ref('stg_shop__kunden') }}

)

select
    -- Hash Key des Hubs "Kunde"
    {{ hash_key(['kunden_nr']) }}                         as hk_kunde,

    -- Hashdiff für den Satellite mit den Kundenstammdaten
    {{ hash_diff(['vorname', 'nachname', 'email',
                  'strasse', 'plz', 'stadt',
                  'registriert_am']) }}                   as hd_kunde_stammdaten,

    kunden_nr,
    vorname,
    nachname,
    email,
    strasse,
    plz,
    stadt,
    registriert_am,
    ladedatum,
    datenquelle

from stg
