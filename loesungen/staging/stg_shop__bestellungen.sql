with quelle as (
    select * from {{ source('shop', 'bestellungen') }}
)
select
    upper(trim(bestell_nr))                 as bestell_nr,
    upper(trim(kunden_nr))                  as kunden_nr,
    try_cast(bestelldatum as date)          as bestelldatum,
    lower(trim(status))                     as status,
    _geladen_am                             as ladedatum,
    _quelldatei                             as datenquelle
from quelle
