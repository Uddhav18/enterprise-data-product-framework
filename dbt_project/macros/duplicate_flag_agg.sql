{% macro duplicate_flag_agg(
    src_cte='hash_rec',
    target_relation=this,
    key_col='rec_unq_id',
    order_col='create_ts'
) %}

 src as (
  select * from {{ src_cte }}
),

incoming as (
  select
      s.*,
      /* Pick the first occurrence deterministically within this run */
      row_number() over (
        partition by {{ key_col }}
        order by {{ order_col }} asc, {{ key_col }} asc
      ) as _rn_in_batch
  from src s
),


  {# If incremental and target exists -> use keys. Else -> 0-row relation #}
  {% if is_incremental() and adapter.get_relation(
        database=this.database,
        schema=this.schema,
        identifier=this.identifier
     ) %}
  existing as (
    select distinct {{ key_col }}
    from {{ target_relation }} ),

flagged as (
  select
      i.*,
      case
        when (i._rn_in_batch > 1) or (e.{{ key_col }} is not null) then true
        else false
      end as duplicate_flag
  from incoming i
  left join existing e
    on i.{{ key_col }} = e.{{ key_col }}
),


  {% else %}

flagged as (
  select
      i.*,
      case
        when (i._rn_in_batch > 1) then true
        else false
      end as duplicate_flag
  from incoming i

),


  {% endif %}

{% endmacro %}
