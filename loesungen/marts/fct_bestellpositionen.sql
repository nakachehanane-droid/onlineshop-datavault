-- Fakt: eine Zeile je Bestellposition, Fremdschlüssel auf die Dimensionen.
with pos as (
    select *
    from {{ ref('sat_bestellposition') }}
    qualify row_number() over (partition by hk_bestellposition order by ladedatum desc) = 1
),
best as (
    select *
    from {{ ref('sat_bestellung_status') }}
    qualify row_number() over (partition by hk_bestellung order by ladedatum desc) = 1
)
select
    lbp.hk_bestellposition                  as bestellposition_key,
    lbk.hk_kunde                            as kunde_key,
    lbp.hk_produkt                          as produkt_key,
    hb.bestell_nr,
    lbp.position,
    best.bestelldatum,
    best.status,
    pos.menge,
    pos.einzelpreis_eur,
    pos.menge * pos.einzelpreis_eur         as umsatz_eur
from {{ ref('link_bestellposition') }} lbp
join {{ ref('hub_bestellung') }} hb       on hb.hk_bestellung  = lbp.hk_bestellung
join {{ ref('link_bestellung_kunde') }} lbk on lbk.hk_bestellung = lbp.hk_bestellung
join pos                                  on pos.hk_bestellposition = lbp.hk_bestellposition
join best                                 on best.hk_bestellung = lbp.hk_bestellung
