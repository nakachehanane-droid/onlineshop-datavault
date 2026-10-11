with quelle as (
    select * from {{ source('shop', 'produkte') }}
)
select
    upper(trim(produkt_nr))                         as produkt_nr,
    trim(produktname)                               as produktname,
    trim(kategorie)                                 as kategorie,
    try_cast(listenpreis_eur as decimal(10, 2))     as listenpreis_eur,
    _geladen_am                                     as ladedatum,
    _quelldatei                                     as datenquelle
from quelle
