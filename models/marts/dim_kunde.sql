-- Dimension Kunde: der AKTUELLE Stand je Kunde (SCD Typ 1).
-- Quelle ist der Raw Vault, nicht das Staging!

with hub as (

    select * from {{ ref('hub_kunde') }}

),

aktueller_stand as (

    select *
    from {{ ref('sat_kunde_stammdaten') }}
    qualify row_number() over (partition by hk_kunde order by ladedatum desc) = 1

)

select
    hub.hk_kunde                         as kunde_key,
    hub.kunden_nr,
    sat.vorname,
    sat.nachname,
    sat.vorname || ' ' || sat.nachname   as kundenname,
    sat.email,
    sat.strasse,
    sat.plz,
    sat.stadt,
    sat.registriert_am,
    hub.ladedatum                        as erstmals_gesehen_am,
    sat.ladedatum                        as zuletzt_geaendert_am
from hub
left join aktueller_stand sat
    on hub.hk_kunde = sat.hk_kunde
