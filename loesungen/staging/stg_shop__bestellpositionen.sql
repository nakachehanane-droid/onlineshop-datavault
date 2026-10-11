with quelle as (
    select * from {{ source('shop', 'bestellpositionen') }}
)
select
    upper(trim(bestell_nr))                         as bestell_nr,
    try_cast(position as integer)                   as position,
    upper(trim(produkt_nr))                         as produkt_nr,
    try_cast(menge as integer)                      as menge,
    try_cast(einzelpreis_eur as decimal(10, 2))     as einzelpreis_eur,
    _geladen_am                                     as ladedatum,
    _quelldatei                                     as datenquelle
from quelle
