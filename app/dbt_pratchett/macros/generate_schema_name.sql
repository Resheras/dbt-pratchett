{% macro generate_schema_name(custom_schema_name, node) -%}

    {#-
        Only in prod do custom +schema configs take effect (writing to a
        named schema like `analytics`). In every other target — local dev
        and CI — everything lands in the target's own dataset instead.
        That keeps CI runs fully contained in their per-PR dataset.
    -#}
    {%- set default_schema = target.schema -%}
    {%- if target.name == 'prod' and custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}

{%- endmacro %}