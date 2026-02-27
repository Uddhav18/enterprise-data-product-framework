{% materialization one_time_object, adapter='snowflake' %}

  {% set relation = this %}
  {% set object_type = config.get('object_type', 'table') | lower %}
  {% set existing_relation = adapter.get_relation(relation.database, relation.schema, relation.identifier) %}

  {% if existing_relation is none %}
      {{ log("Creating " ~ object_type ~ ": " ~ relation, info=True) }}
      {% call statement('main', fetch_result=False) %}
          create {{ object_type }} {{ relation }} as
          {{ sql }}
      {% endcall %}

      {% do persist_docs(relation, model) %}
  {% else %}
      {{ log(object_type | capitalize ~ ": " ~ relation ~ " exists → skip", info=True) }}
      {% call statement('main', fetch_result=False) %} select 1 {% endcall %}
  {% endif %}

  {# ---------------- NEW STREAM CALL LOGIC ---------------- #}
  {% set stream_name = config.get('stream_name', none) %}
  {% if stream_name %}
      {{ manage_stream(stream_name,this.identifier ) }}
  {% endif %}
  {# ------------------------------------------------------- #}

  {{ return({'relations': [relation]}) }}

{% endmaterialization %}
