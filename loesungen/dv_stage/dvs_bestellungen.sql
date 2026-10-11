select
    {{ hash_key(['bestell_nr']) }}                   as hk_bestellung,
    {{ hash_key(['kunden_nr']) }}                    as hk_kunde,
    {{ hash_key(['bestell_nr', 'kunden_nr']) }}      as hk_bestellung_kunde,
    {{ hash_diff(['bestelldatum', 'status']) }}      as hd_bestellung_status,
    *
from {{ ref('stg_shop__bestellungen') }}
