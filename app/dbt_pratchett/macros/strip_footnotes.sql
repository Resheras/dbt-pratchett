{% macro strip_footnotes(column_name) %}
    regexp_replace({{ column_name }}, r'\[\d+\]', '')
{% endmacro %}