-- PIT (Point in Time): für jeden Kunden und jeden Stichtag der Ladedatum-
-- Zeiger auf den dann gültigen Satellite-Stand. Damit werden historische
-- Abfragen ("Wie war die Adresse am 01.07.?") zu einfachen Joins.
-- Stichtage hier: jedes Ladedatum, das es im System gibt.

with stichtage as (
    select distinct ladedatum as stichtag
    from {{ ref('sat_kunde_stammdaten') }}
),

kunden_x_stichtage as (
    select h.hk_kunde, s.stichtag
    from {{ ref('hub_kunde') }} h
    join stichtage s on s.stichtag >= h.ladedatum
)

select
    k.hk_kunde,
    k.stichtag,
    max(sat.ladedatum) as sat_kunde_stammdaten_ladedatum
from kunden_x_stichtage k
left join {{ ref('sat_kunde_stammdaten') }} sat
    on  sat.hk_kunde  = k.hk_kunde
    and sat.ladedatum <= k.stichtag
group by k.hk_kunde, k.stichtag
