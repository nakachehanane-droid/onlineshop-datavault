-- Staging: genau eine Quelle, keine Joins, keine Geschäftslogik.
-- Aufgaben hier: Spalten umbenennen, Datentypen setzen, säubern.

with quelle as (

    select * from {{ source('shop', 'kunden') }}

),

bereinigt as (

    select
        -- Business Key
        upper(trim(kunden_nr))                  as kunden_nr,

        -- Attribute
        trim(vorname)                           as vorname,
        trim(nachname)                          as nachname,
        lower(trim(email))                      as email,
        trim(strasse)                           as strasse,
        trim(plz)                               as plz,
        trim(stadt)                             as stadt,
        try_cast(registriert_am as date)        as registriert_am,

        -- Technische Spalten für den Data Vault
        _geladen_am                             as ladedatum,
        _quelldatei                             as datenquelle

    from quelle

)

select * from bereinigt
