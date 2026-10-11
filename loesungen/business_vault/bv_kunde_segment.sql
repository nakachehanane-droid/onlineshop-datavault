-- Geschäftsregel (gehört in den Business Vault, nicht in den Raw Vault):
-- Kundensegment nach Gesamtumsatz.  >= 1500 EUR = Premium, >= 500 = Stammkunde, sonst Gelegenheitskunde.

with pos_aktuell as (
    select *
    from {{ ref('sat_bestellposition') }}
    qualify row_number() over (partition by hk_bestellposition order by ladedatum desc) = 1
),

umsatz as (
    select
        lbk.hk_kunde,
        sum(pos.menge * pos.einzelpreis_eur) as umsatz_eur
    from {{ ref('link_bestellung_kunde') }} lbk
    join {{ ref('link_bestellposition') }} lbp on lbp.hk_bestellung = lbk.hk_bestellung
    join pos_aktuell pos on pos.hk_bestellposition = lbp.hk_bestellposition
    group by lbk.hk_kunde
)

select
    hk_kunde,
    umsatz_eur,
    case
        when umsatz_eur >= 1500 then 'Premium'
        when umsatz_eur >= 500  then 'Stammkunde'
        else 'Gelegenheitskunde'
    end as segment
from umsatz
