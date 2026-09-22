USE ecommerce_analytics;

-- Show overall customer statistics
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN status = 'Inactive' THEN 1 ELSE 0 END) AS inactive_customers
FROM customers;

-- Show customer registration trends
SELECT
    YEAR(registration_date) AS registration_year,
    MONTH(registration_date) AS registration_month,
    COUNT(*) AS new_customers
FROM customers
GROUP BY
    YEAR(registration_date),
    MONTH(registration_date)
ORDER BY
    registration_year,
    registration_month;

-- Show customers with their order statistics
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spending,
    COALESCE(AVG(o.total_amount), 0) AS average_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
ORDER BY total_spending DESC;

-- Find the top ten customers by spending
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spending DESC
LIMIT 10;

-- Rank customers by total spending
WITH customer_spending AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(o.total_amount) AS total_spending
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank
FROM customer_spending
ORDER BY spending_rank;

-- Classify customers by spending
WITH customer_spending AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    total_orders,
    total_spending,
    CASE
        WHEN total_spending >= 10000 THEN 'VIP'
        WHEN total_spending >= 5000 THEN 'Premium'
        WHEN total_spending > 0 THEN 'Regular'
        ELSE 'No Purchase'
    END AS customer_segment
FROM customer_spending
ORDER BY total_spending DESC;

-- Find customers who have never placed an order
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.registration_date
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Find customers with repeat purchases
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Calculate customer lifetime value
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY lifetime_value DESC;

-- Calculate average order value for each customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(AVG(o.total_amount), 2) AS average_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY average_order_value DESC;

-- Find customers with above-average spending
WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spending
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    cs.total_spending
FROM customer_spending cs
INNER JOIN customers c
    ON cs.customer_id = c.customer_id
WHERE cs.total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY cs.total_spending DESC;

-- Find customers with above-average order values
WITH customer_orders AS (
    SELECT
        customer_id,
        AVG(total_amount) AS average_order_value
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(co.average_order_value, 2) AS average_order_value
FROM customer_orders co
INNER JOIN customers c
    ON co.customer_id = c.customer_id
WHERE co.average_order_value > (
    SELECT AVG(total_amount)
    FROM orders
    WHERE order_status <> 'Cancelled'
)
ORDER BY co.average_order_value DESC;

-- Find the first order placed by each customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MIN(o.order_date) AS first_order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY first_order_date;

-- Find the latest order placed by each customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_date) AS latest_order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY latest_order_date DESC;

-- Calculate days since each customer's latest order
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_date) AS latest_order_date,
    DATEDIFF(
        CURDATE(),
        DATE(MAX(o.order_date))
    ) AS days_since_last_order
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY days_since_last_order DESC;

-- Identify inactive customers based on recent purchasing activity
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_date) AS latest_order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING latest_order_date IS NULL
    OR latest_order_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
ORDER BY latest_order_date;

-- Show customer spending by month
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    YEAR(o.order_date) AS sales_year,
    MONTH(o.order_date) AS sales_month,
    SUM(o.total_amount) AS monthly_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    c.customer_id,
    sales_year,
    sales_month;

-- Calculate running spending for each customer
WITH monthly_customer_spending AS (
    SELECT
        customer_id,
        YEAR(order_date) AS sales_year,
        MONTH(order_date) AS sales_month,
        SUM(total_amount) AS monthly_spending
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY
        customer_id,
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    customer_id,
    sales_year,
    sales_month,
    monthly_spending,
    SUM(monthly_spending) OVER (
        PARTITION BY customer_id
        ORDER BY sales_year, sales_month
    ) AS running_spending
FROM monthly_customer_spending
ORDER BY
    customer_id,
    sales_year,
    sales_month;

-- Find the most frequently purchased categories by customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    cat.category_name,
    SUM(oi.quantity) AS units_purchased
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN categories cat
    ON p.category_id = cat.category_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    cat.category_name
ORDER BY
    c.customer_id,
    units_purchased DESC;

-- Find customers who purchased from multiple categories
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT p.category_id) AS categories_purchased
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(DISTINCT p.category_id) > 1
ORDER BY categories_purchased DESC;

-- Calculate customer review activity
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.review_id) AS reviews_written,
    ROUND(AVG(r.rating), 2) AS average_rating_given
FROM customers c
LEFT JOIN reviews r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY reviews_written DESC;

-- Find customers who have written product reviews
SELECT DISTINCT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email
FROM customers c
INNER JOIN reviews r
    ON c.customer_id = r.customer_id
ORDER BY customer_name;

-- Find high-value customers who also write reviews
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spending,
    COUNT(DISTINCT r.review_id) AS reviews_written
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN reviews r
    ON c.customer_id = r.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(o.total_amount) >= 5000
   AND COUNT(DISTINCT r.review_id) > 0
ORDER BY total_spending DESC;

-- Rank customers within spending segments
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COALESCE(SUM(o.total_amount), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
),
segmented_customers AS (
    SELECT
        *,
        CASE
            WHEN total_spending >= 10000 THEN 'VIP'
            WHEN total_spending >= 5000 THEN 'Premium'
            WHEN total_spending > 0 THEN 'Regular'
            ELSE 'No Purchase'
        END AS customer_segment
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    total_spending,
    customer_segment,
    RANK() OVER (
        PARTITION BY customer_segment
        ORDER BY total_spending DESC
    ) AS segment_rank
FROM segmented_customers
ORDER BY
    customer_segment,
    segment_rank;

-- Build a complete customer analytics summary
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0) AS total_spending,
        COALESCE(AVG(o.total_amount), 0) AS average_order_value,
        MAX(o.order_date) AS latest_order_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    total_orders,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(average_order_value, 2) AS average_order_value,
    latest_order_date,
    CASE
        WHEN total_spending >= 10000 THEN 'VIP'
        WHEN total_spending >= 5000 THEN 'Premium'
        WHEN total_spending > 0 THEN 'Regular'
        ELSE 'No Purchase'
    END AS customer_segment
FROM customer_metrics
ORDER BY total_spending DESC;