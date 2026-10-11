-- LINK = Beziehung zwischen Hubs. Nur Hash Keys, keine Attribute.
{{ config(unique_key='hk_bestellposition') }}

with erstes_auftreten as (
    select hk_bestellposition, hk_bestellung, hk_produkt, position, ladedatum, datenquelle
    from {{ ref('dvs_bestellpositionen') }}
    qualify row_number() over (partition by hk_bestellposition order by ladedatum) = 1
)

select * from erstes_auftreten
{% if is_incremental() %}
where hk_bestellposition not in (select hk_bestellposition from {{ this }})
{% endif %}
