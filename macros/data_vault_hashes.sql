{#
  Data Vault 2.0 Hash-Macros

  hash_key(['kunden_nr'])
    -> Hash Key eines Hubs oder Links aus einem oder mehreren Business Keys.
       Business Keys werden getrimmt und in GROSSBUCHSTABEN gehasht, damit
       ' k00001' und 'K00001' denselben Schlüssel ergeben.

  hash_diff(['vorname', 'nachname', ...])
    -> Hashdiff eines Satellites: ein Fingerabdruck aller beschreibenden
       Attribute. Ändert sich ein Attribut, ändert sich der Hashdiff und
       der Satellite schreibt eine neue Zeile. Hier KEIN upper(), weil
       eine Änderung der Groß-/Kleinschreibung eine echte Änderung ist.

  NULL wird durch '^^' ersetzt, damit (NULL, 'A') und ('A', NULL)
  unterschiedliche Hashes ergeben. '||' trennt die Spalten.
#}

{% macro hash_key(spalten) -%}
    md5(
    {%- for spalte in spalten %}
        coalesce(nullif(upper(trim(cast({{ spalte }} as varchar))), ''), '^^')
        {%- if not loop.last %} || '||' || {% endif %}
    {%- endfor %}
    )
{%- endmacro %}


{% macro hash_diff(spalten) -%}
    md5(
    {%- for spalte in spalten %}
        coalesce(nullif(trim(cast({{ spalte }} as varchar)), ''), '^^')
        {%- if not loop.last %} || '||' || {% endif %}
    {%- endfor %}
    )
{%- endmacro %}
