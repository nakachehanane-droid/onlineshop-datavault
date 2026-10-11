{{ config(unique_key='hk_bestellung') }}

with erstes_auftreten as (
    select hk_bestellung, bestell_nr, ladedatum, datenquelle
    from {{ ref('dvs_bestellungen') }}
    qualify row_number() over (partition by hk_bestellung order by ladedatum) = 1
)

select * from erstes_auftreten
{% if is_incremental() %}
where hk_bestellung not in (select hk_bestellung from {{ this }})
{% endif %}
