-- Singular Test: liefert die fehlerhaften Zeilen. 0 Zeilen = Test bestanden.
select *
from {{ ref('stg_shop__bestellpositionen') }}
where menge <= 0
