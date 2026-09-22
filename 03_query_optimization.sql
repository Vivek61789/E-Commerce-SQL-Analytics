USE ecommerce_analytics;

-- Create a larger result set for optimization testing
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- Avoid selecting unnecessary columns
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE customer_id = 1;

-- Use indexed columns in filtering
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Avoid applying functions to indexed columns in WHERE
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_date >= '2026-01-01'
  AND order_date < '2027-01-01';

-- Use a range instead of extracting the year
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_date BETWEEN '2026-01-01' AND '2026-12-31';

-- Filter before joining large result sets
SELECT
    o.order_id,
    c.customer_id,
    c.first_name,
    o.total_amount
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id = 1;

-- Select only the required columns from joined tables
SELECT
    o.order_id,
    p.product_name,
    oi.quantity
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.customer_id = 1;

-- Use EXISTS when only existence needs to be checked
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Avoid unnecessary DISTINCT when the join already produces unique rows
SELECT
    o.order_id,
    c.customer_id,
    c.first_name
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- Use GROUP BY only when aggregation is required
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id;

-- Filter grouped results with HAVING
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Use WHERE before GROUP BY to reduce rows
SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY customer_id;

-- Compare a correlated subquery with a grouped approach
SELECT
    p.product_id,
    p.product_name,
    p.price
FROM products p
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
);

-- Use a CTE to calculate category averages once
WITH category_average AS (
    SELECT
        category_id,
        AVG(price) AS average_price
    FROM products
    GROUP BY category_id
)
SELECT
    p.product_id,
    p.product_name,
    p.price,
    ca.average_price
FROM products p
INNER JOIN category_average ca
    ON p.category_id = ca.category_id
WHERE p.price > ca.average_price;

-- Use LIMIT when only a small number of rows are needed
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Use indexed ordering where possible
SELECT
    order_id,
    customer_id,
    order_date
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC
LIMIT 10;

-- Check the execution plan for the optimized customer query
EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Check the execution plan for the optimized product query
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
  AND status = 'Active'
ORDER BY price DESC
LIMIT 10;

-- Create a composite index for category filtering and price sorting
DROP INDEX IF EXISTS idx_products_category_status_price
ON products;

CREATE INDEX idx_products_category_status_price
ON products(category_id, status, price);

-- Check the composite index usage
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
  AND status = 'Active'
ORDER BY price DESC
LIMIT 10;

-- Create a composite index for customer order reporting
DROP INDEX IF EXISTS idx_orders_customer_status_date
ON orders;

CREATE INDEX idx_orders_customer_status_date
ON orders(customer_id, order_status, order_date);

-- Check the customer order reporting plan
EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
  AND order_status = 'Delivered'
ORDER BY order_date DESC;

-- Use UNION ALL when duplicate removal is not required
SELECT
    customer_id,
    'Customer' AS record_type
FROM customers
WHERE status = 'Active'

UNION ALL

SELECT
    seller_id,
    'Seller' AS record_type
FROM sellers
WHERE status = 'Active';

-- Use UNION when duplicate removal is required
SELECT
    email
FROM customers

UNION

SELECT
    email
FROM sellers;

-- Convert values explicitly when comparing different data types
SELECT
    product_id,
    product_name,
    CAST(price AS DECIMAL(12, 2)) AS formatted_price
FROM products;

-- Use NULL-safe calculations
SELECT
    product_id,
    product_name,
    COALESCE(cost_price, 0) AS cost_price,
    price - COALESCE(cost_price, 0) AS estimated_profit
FROM products;

-- Avoid leading wildcards when an index can support the search
SELECT
    product_id,
    product_name
FROM products
WHERE product_name LIKE 'Laptop%';

-- Use full result filtering instead of a leading wildcard when possible
SELECT
    product_id,
    product_name
FROM products
WHERE product_name LIKE '%Laptop%';

-- Refresh optimizer statistics after major data changes
ANALYZE TABLE customers;
ANALYZE TABLE products;
ANALYZE TABLE product_inventory;
ANALYZE TABLE orders;
ANALYZE TABLE order_items;
ANALYZE TABLE payments;

-- Check table sizes for optimization planning
SELECT
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    ROUND(
        (DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024,
        2
    ) AS total_size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
ORDER BY total_size_mb DESC;

-- Check unused or redundant-looking index definitions
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Check the final optimized product query
EXPLAIN ANALYZE
SELECT
    p.product_id,
    p.product_name,
    p.price
FROM products p
WHERE p.category_id = 1
  AND p.status = 'Active'
ORDER BY p.price DESC
LIMIT 10;