SELECT order_id, customer_id, order_amount,
UPPER(order_status) AS order_status,
DATE(created_at) AS order_date
FROM {{ ref('stg_orders') }}
