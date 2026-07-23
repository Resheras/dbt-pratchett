{% macro clean_whitespace(column_name) %}
    trim(regexp_replace({{ column_name }}, r'\s+', ' '))
{% endmacro %}