-- Gleiches Muster wie sat_kunde_stammdaten.
with quelle as (
    select hk_bestellposition, hd_bestellposition, ladedatum, datenquelle, menge, einzelpreis_eur
    from {{ ref('dvs_bestellpositionen') }}
    {% if is_incremental() %}
    where ladedatum > (select max(ladedatum) from {{ this }})
    {% endif %}
),

{% if is_incremental() %}
letzter_stand as (
    select hk_bestellposition, hd_bestellposition
    from {{ this }}
    qualify row_number() over (partition by hk_bestellposition order by ladedatum desc) = 1
),
{% endif %}

mit_vorgaenger as (
    select
        quelle.*,
        lag(hd_bestellposition) over (partition by hk_bestellposition order by ladedatum) as hd_vorgaenger
    from quelle
)

select
    m.hk_bestellposition, m.ladedatum, m.hd_bestellposition, m.datenquelle,
    m.menge, m.einzelpreis_eur
from mit_vorgaenger m
{% if is_incremental() %}
left join letzter_stand l on m.hk_bestellposition = l.hk_bestellposition
{% endif %}
where m.hd_bestellposition <> coalesce(
          m.hd_vorgaenger,
          {% if is_incremental() %} l.hd_bestellposition, {% endif %}
          ''
      )
