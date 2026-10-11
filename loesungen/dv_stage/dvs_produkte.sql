select
    {{ hash_key(['produkt_nr']) }}                                   as hk_produkt,
    {{ hash_diff(['produktname', 'kategorie', 'listenpreis_eur']) }} as hd_produkt_details,
    *
from {{ ref('stg_shop__produkte') }}
