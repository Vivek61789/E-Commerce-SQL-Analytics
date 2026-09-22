USE ecommerce_analytics;

-- Show overall sales performance
SELECT
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value,
    MAX(total_amount) AS highest_order_value,
    MIN(total_amount) AS lowest_order_value
FROM orders
WHERE order_status <> 'Cancelled';

-- Show daily sales
SELECT
    DATE(order_date) AS sales_date,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS daily_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE(order_date)
ORDER BY sales_date;

-- Show monthly sales
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS monthly_revenue,
    AVG(total_amount) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year, sales_month;

-- Show yearly sales
SELECT
    YEAR(order_date) AS sales_year,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS yearly_revenue,
    AVG(total_amount) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY YEAR(order_date)
ORDER BY sales_year;

-- Show sales by order status
SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value
FROM orders
GROUP BY order_status
ORDER BY total_value DESC;

-- Calculate sales conversion by order status
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Find the top customers by revenue
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC
LIMIT 10;

-- Find the top products by units sold
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- Find the top products by revenue
SELECT
    p.product_id,
    p.product_name,
    SUM(
        (oi.quantity * oi.unit_price) - oi.discount_amount
    ) AS product_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC
LIMIT 10;

-- Show category sales performance
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    SUM(
        (oi.quantity * oi.unit_price) - oi.discount_amount
    ) AS category_revenue
FROM categories c
INNER JOIN products p
    ON c.category_id = p.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- Calculate category revenue percentage
WITH category_sales AS (
    SELECT
        c.category_id,
        c.category_name,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM categories c
    INNER JOIN products p
        ON c.category_id = p.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.category_id, c.category_name
)
SELECT
    category_id,
    category_name,
    revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;

-- Show seller sales performance
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS units_sold,
    SUM(
        (oi.quantity * oi.unit_price) - oi.discount_amount
    ) AS revenue
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY s.seller_id, s.seller_name
ORDER BY revenue DESC;

-- Calculate monthly revenue growth
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS sales_year,
        MONTH(order_date) AS sales_month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    sales_year,
    sales_month,
    revenue,
    LAG(revenue) OVER (
        ORDER BY sales_year, sales_month
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue - LAG(revenue) OVER (
                ORDER BY sales_year, sales_month
            )
        )
        /
        NULLIF(
            LAG(revenue) OVER (
                ORDER BY sales_year, sales_month
            ),
            0
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY sales_year, sales_month;

-- Calculate running revenue
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS sales_year,
        MONTH(order_date) AS sales_month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    sales_year,
    sales_month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY sales_year, sales_month
    ) AS running_revenue
FROM monthly_sales
ORDER BY sales_year, sales_month;

-- Show average daily revenue
WITH daily_sales AS (
    SELECT
        DATE(order_date) AS sales_date,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY DATE(order_date)
)
SELECT
    ROUND(AVG(revenue), 2) AS average_daily_revenue
FROM daily_sales;

-- Find the highest revenue day
SELECT
    DATE(order_date) AS sales_date,
    SUM(total_amount) AS daily_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE(order_date)
ORDER BY daily_revenue DESC
LIMIT 1;

-- Find the highest revenue month
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY monthly_revenue DESC
LIMIT 1;

-- Show discount impact on sales
SELECT
    COUNT(*) AS discounted_items,
    SUM(discount_amount) AS total_discount,
    SUM(quantity * unit_price) AS gross_sales,
    SUM(
        (quantity * unit_price) - discount_amount
    ) AS net_sales
FROM order_items;

-- Calculate average discount per order item
SELECT
    ROUND(AVG(discount_amount), 2) AS average_discount
FROM order_items;

-- Show payment method performance
SELECT
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_payment_amount,
    AVG(amount) AS average_payment_amount
FROM payments
WHERE payment_status = 'Completed'
GROUP BY payment_method
ORDER BY total_payment_amount DESC;

-- Calculate payment completion rate
SELECT
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'Completed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS payment_completion_rate
FROM payments;

-- Show delivery performance
SELECT
    shipment_status,
    COUNT(*) AS shipment_count
FROM shipments
GROUP BY shipment_status
ORDER BY shipment_count DESC;

-- Calculate average delivery time
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                delivered_date,
                shipped_date
            )
        ),
        2
    ) AS average_delivery_days
FROM shipments
WHERE shipped_date IS NOT NULL
  AND delivered_date IS NOT NULL;

-- Find late deliveries
SELECT
    shipment_id,
    order_id,
    estimated_delivery_date,
    delivered_date,
    DATEDIFF(
        delivered_date,
        estimated_delivery_date
    ) AS days_late
FROM shipments
WHERE delivered_date > estimated_delivery_date
ORDER BY days_late DESC;

-- Find repeat customers
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Calculate repeat customer percentage
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS repeat_customer_percentage
FROM customer_orders;

-- Show sales by day of week
SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY DAYOFWEEK(order_date);

-- Show sales by month name
SELECT
    MONTHNAME(order_date) AS month_name,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);

-- Build a complete sales performance summary
WITH sales_summary AS (
    SELECT
        COUNT(order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS average_order_value
    FROM orders
    WHERE order_status <> 'Cancelled'
),
product_summary AS (
    SELECT
        SUM(oi.quantity) AS units_sold
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
)
SELECT
    ss.total_orders,
    ss.unique_customers,
    ss.total_revenue,
    ss.average_order_value,
    ps.units_sold
FROM sales_summary ss
CROSS JOIN product_summary ps;