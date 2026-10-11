-- LINK = Beziehung zwischen Hubs. Nur Hash Keys, keine Attribute.
{{ config(unique_key='hk_bestellung_kunde') }}

with erstes_auftreten as (
    select hk_bestellung_kunde, hk_bestellung, hk_kunde, ladedatum, datenquelle
    from {{ ref('dvs_bestellungen') }}
    qualify row_number() over (partition by hk_bestellung_kunde order by ladedatum) = 1
)

select * from erstes_auftreten
{% if is_incremental() %}
where hk_bestellung_kunde not in (select hk_bestellung_kunde from {{ this }})
{% endif %}
