{% macro incremental_lookback(column_name, days=3) %}
    (select timestamp_sub(max({{ column_name }}), interval {{ days }} day) from {{ this }})
{% endmacro %}