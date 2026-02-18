SELECT order_date,
COUNT(order_id) AS total_orders,
SUM(order_amount) AS total_revenue
FROM {{ ref('base_orders') }}
GROUP BY order_date
