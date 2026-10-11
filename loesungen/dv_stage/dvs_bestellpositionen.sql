-- Die Position ist ein "Dependent Child Key": sie gehört in den Link-Hash,
-- weil dasselbe Produkt in einer Bestellung zweimal vorkommen könnte.
select
    {{ hash_key(['bestell_nr']) }}                                as hk_bestellung,
    {{ hash_key(['produkt_nr']) }}                                as hk_produkt,
    {{ hash_key(['bestell_nr', 'produkt_nr', 'position']) }}      as hk_bestellposition,
    {{ hash_diff(['menge', 'einzelpreis_eur']) }}                 as hd_bestellposition,
    *
from {{ ref('stg_shop__bestellpositionen') }}
