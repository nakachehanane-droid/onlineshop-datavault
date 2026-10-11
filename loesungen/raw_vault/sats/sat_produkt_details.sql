-- Gleiches Muster wie sat_kunde_stammdaten.
with quelle as (
    select hk_produkt, hd_produkt_details, ladedatum, datenquelle, produktname, kategorie, listenpreis_eur
    from {{ ref('dvs_produkte') }}
    {% if is_incremental() %}
    where ladedatum > (select max(ladedatum) from {{ this }})
    {% endif %}
),

{% if is_incremental() %}
letzter_stand as (
    select hk_produkt, hd_produkt_details
    from {{ this }}
    qualify row_number() over (partition by hk_produkt order by ladedatum desc) = 1
),
{% endif %}

mit_vorgaenger as (
    select
        quelle.*,
        lag(hd_produkt_details) over (partition by hk_produkt order by ladedatum) as hd_vorgaenger
    from quelle
)

select
    m.hk_produkt, m.ladedatum, m.hd_produkt_details, m.datenquelle,
    m.produktname, m.kategorie, m.listenpreis_eur
from mit_vorgaenger m
{% if is_incremental() %}
left join letzter_stand l on m.hk_produkt = l.hk_produkt
{% endif %}
where m.hd_produkt_details <> coalesce(
          m.hd_vorgaenger,
          {% if is_incremental() %} l.hd_produkt_details, {% endif %}
          ''
      )
