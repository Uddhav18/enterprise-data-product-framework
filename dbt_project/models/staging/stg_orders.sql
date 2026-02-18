{{ config(materialized='incremental', unique_key='order_id') }}

SELECT order_id, customer_id, order_amount, order_status, created_at
FROM {{ source('landing', 'orders_raw') }}

{% if is_incremental() %}
WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}
