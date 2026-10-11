-- SATELLITE = beschreibende Attribute + deren Historie.
-- Regel: eine neue Zeile NUR, wenn sich der Hashdiff gegenüber dem
-- vorherigen Stand desselben Kunden geändert hat. Insert-only.

with quelle as (

    select
        hk_kunde,
        hd_kunde_stammdaten,
        ladedatum,
        datenquelle,
        vorname,
        nachname,
        email,
        strasse,
        plz,
        stadt,
        registriert_am
    from {{ ref('dvs_kunden') }}

    {% if is_incremental() %}
    -- nur Zeilen, die neuer sind als alles, was schon im Satellite steht
    where ladedatum > (select max(ladedatum) from {{ this }})
    {% endif %}

),

{% if is_incremental() %}
letzter_stand as (

    -- der aktuell gültige Hashdiff je Kunde im Satellite
    select hk_kunde, hd_kunde_stammdaten
    from {{ this }}
    qualify row_number() over (partition by hk_kunde order by ladedatum desc) = 1

),
{% endif %}

mit_vorgaenger as (

    -- falls eine Ladung mehrere Stände enthält: Vorgänger innerhalb der Ladung
    select
        quelle.*,
        lag(hd_kunde_stammdaten) over (
            partition by hk_kunde order by ladedatum
        ) as hd_vorgaenger
    from quelle

)

select
    m.hk_kunde,
    m.ladedatum,
    m.hd_kunde_stammdaten,
    m.datenquelle,
    m.vorname,
    m.nachname,
    m.email,
    m.strasse,
    m.plz,
    m.stadt,
    m.registriert_am
from mit_vorgaenger m
{% if is_incremental() %}
left join letzter_stand l
    on m.hk_kunde = l.hk_kunde
{% endif %}

-- neue Zeile nur bei echter Änderung
where m.hd_kunde_stammdaten <> coalesce(
          m.hd_vorgaenger,
          {% if is_incremental() %} l.hd_kunde_stammdaten, {% endif %}
          ''
      )
