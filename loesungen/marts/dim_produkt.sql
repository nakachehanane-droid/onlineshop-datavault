with aktuell as (
    select *
    from {{ ref('sat_produkt_details') }}
    qualify row_number() over (partition by hk_produkt order by ladedatum desc) = 1
)
select
    h.hk_produkt          as produkt_key,
    h.produkt_nr,
    a.produktname,
    a.kategorie,
    a.listenpreis_eur
from {{ ref('hub_produkt') }} h
left join aktuell a on a.hk_produkt = h.hk_produkt
