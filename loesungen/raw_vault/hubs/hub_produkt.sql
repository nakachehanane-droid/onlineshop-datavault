{{ config(unique_key='hk_produkt') }}

with erstes_auftreten as (
    select hk_produkt, produkt_nr, ladedatum, datenquelle
    from {{ ref('dvs_produkte') }}
    qualify row_number() over (partition by hk_produkt order by ladedatum) = 1
)

select * from erstes_auftreten
{% if is_incremental() %}
where hk_produkt not in (select hk_produkt from {{ this }})
{% endif %}
