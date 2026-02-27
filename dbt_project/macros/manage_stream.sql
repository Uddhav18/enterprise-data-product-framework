{% macro manage_stream(stream_name, table_name) %}

  {# Resolve env once (CI/CD can set ENV_NAME; otherwise use dbt target name) #}
  {% set env_name = env_var('ENV_NAME', target.name) %}
  {% set db_name  = "db_oprn_" ~ env_name %}
  {% set schema_name = "LANDING" %}

  {% if execute %}

    {# 1. Check if stream exists (fully qualified) #}
    {% set show_sql %}
      SHOW STREAMS LIKE '{{ stream_name }}' IN SCHEMA {{ db_name }}.{{ schema_name }};
    {% endset %}

    {% set result = run_query(show_sql) %}

    {% if result is not none and (result.rows | length) > 0 %}

      {# Stream exists #}
      {% set stale_index = result.column_names.index('stale') %}
      {% set stale_value = result.rows[0][stale_index] %}

      {% if stale_value|string|lower == 'true' %}

        {% set drop_sql %}
          DROP STREAM {{ db_name }}.{{ schema_name }}.{{ stream_name }};
        {% endset %}

        {% set create_sql %}
          CREATE STREAM {{ db_name }}.{{ schema_name }}.{{ stream_name }}
          ON TABLE {{ db_name }}.{{ schema_name }}.{{ table_name }}
          APPEND_ONLY = TRUE;
        {% endset %}

        {% do run_query(drop_sql) %}
        {% do run_query(create_sql) %}
        {{ log("Stream was stale → dropped and recreated: " ~ db_name ~ "." ~ schema_name ~ "." ~ stream_name, info=True) }}

      {% else %}
        {{ log("Stream exists and is active. No action performed: " ~ db_name ~ "." ~ schema_name ~ "." ~ stream_name, info=True) }}
      {% endif %}

    {% else %}

      {# Stream does not exist → create #}
      {% set create_sql %}
        CREATE STREAM {{ db_name }}.{{ schema_name }}.{{ stream_name }}
        ON TABLE {{ db_name }}.{{ schema_name }}.{{ table_name }}
        APPEND_ONLY = TRUE;
      {% endset %}

      {% do run_query(create_sql) %}
      {{ log("Stream created first time: " ~ db_name ~ "." ~ schema_name ~ "." ~ stream_name, info=True) }}

    {% endif %}

  {% else %}
    {{ log("Compile-time: No actions executed.", info=True) }}
  {% endif %}

{% endmacro %}
