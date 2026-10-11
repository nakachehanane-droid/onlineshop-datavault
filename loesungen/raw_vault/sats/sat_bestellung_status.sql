-- Gleiches Muster wie sat_kunde_stammdaten.
with quelle as (
    select hk_bestellung, hd_bestellung_status, ladedatum, datenquelle, bestelldatum, status
    from {{ ref('dvs_bestellungen') }}
    {% if is_incremental() %}
    where ladedatum > (select max(ladedatum) from {{ this }})
    {% endif %}
),

{% if is_incremental() %}
letzter_stand as (
    select hk_bestellung, hd_bestellung_status
    from {{ this }}
    qualify row_number() over (partition by hk_bestellung order by ladedatum desc) = 1
),
{% endif %}

mit_vorgaenger as (
    select
        quelle.*,
        lag(hd_bestellung_status) over (partition by hk_bestellung order by ladedatum) as hd_vorgaenger
    from quelle
)

select
    m.hk_bestellung, m.ladedatum, m.hd_bestellung_status, m.datenquelle,
    m.bestelldatum, m.status
from mit_vorgaenger m
{% if is_incremental() %}
left join letzter_stand l on m.hk_bestellung = l.hk_bestellung
{% endif %}
where m.hd_bestellung_status <> coalesce(
          m.hd_vorgaenger,
          {% if is_incremental() %} l.hd_bestellung_status, {% endif %}
          ''
      )
