-- HUB = Liste aller Business Keys, die es je gab. Nie Update, nie Delete.
-- Eine Zeile pro Kunde, mit dem Zeitpunkt, an dem er ZUERST gesehen wurde.

{{ config(unique_key='hk_kunde') }}

with quelle as (

    select hk_kunde, kunden_nr, ladedatum, datenquelle
    from {{ ref('dvs_kunden') }}

),

erstes_auftreten as (

    select
        hk_kunde,
        kunden_nr,
        ladedatum,
        datenquelle
    from quelle
    qualify row_number() over (partition by hk_kunde order by ladedatum) = 1

)

select * from erstes_auftreten

{% if is_incremental() %}
-- Nur Kunden einfügen, die im Hub noch fehlen
where hk_kunde not in (select hk_kunde from {{ this }})
{% endif %}
