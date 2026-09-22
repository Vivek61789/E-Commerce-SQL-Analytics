USE ecommerce_analytics;

-- Show the execution plan for a simple product search
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id = 1;

-- Show the execution plan for a filtered product search
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
  AND status = 'Active';

-- Show the execution plan for a customer order search
EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Show the execution plan for order status filtering
EXPLAIN
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE order_status = 'Delivered';

-- Show the execution plan for payment filtering
EXPLAIN
SELECT
    payment_id,
    order_id,
    amount
FROM payments
WHERE payment_status = 'Completed';

-- Show the execution plan for product sales aggregation
EXPLAIN
SELECT
    product_id,
    SUM(quantity) AS total_units_sold
FROM order_items
WHERE product_id = 1
GROUP BY product_id;

-- Show the execution plan for a customer and order join
EXPLAIN
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    o.total_amount
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.customer_id = 1;

-- Show the execution plan for a multi-table join
EXPLAIN
SELECT
    o.order_id,
    c.first_name,
    p.product_name,
    oi.quantity
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_id = 1;

-- Show the execution plan for a grouped revenue query
EXPLAIN
SELECT
    p.category_id,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category_id;

-- Show the execution plan for a subquery
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- Show the execution plan for a derived table
EXPLAIN
SELECT
    category_id,
    average_price
FROM (
    SELECT
        category_id,
        AVG(price) AS average_price
    FROM products
    GROUP BY category_id
) AS category_summary;

-- Show the execution plan for a CTE
EXPLAIN
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spending
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spending
FROM customer_sales
WHERE total_spending > 5000;

-- Show the execution plan for a window function query
EXPLAIN
SELECT
    product_id,
    product_name,
    price,
    RANK() OVER (
        ORDER BY price DESC
    ) AS price_rank
FROM products;

-- Show detailed execution statistics for a product query
EXPLAIN ANALYZE
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
  AND status = 'Active';

-- Show detailed execution statistics for customer orders
EXPLAIN ANALYZE
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Show detailed execution statistics for a multi-table join
EXPLAIN ANALYZE
SELECT
    o.order_id,
    c.first_name,
    p.product_name,
    oi.quantity
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_id = 1;

-- Show the optimizer's estimated execution plan in JSON format
EXPLAIN FORMAT=JSON
SELECT
    p.product_name,
    c.category_name,
    p.price
FROM products p
INNER JOIN categories c
    ON p.category_id = c.category_id
WHERE p.price > 1000;

-- Show the optimizer's estimated execution plan for aggregation
EXPLAIN FORMAT=JSON
SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM orders
GROUP BY customer_id;

-- Check available indexes for the products table
SHOW INDEX FROM products;

-- Check available indexes for the orders table
SHOW INDEX FROM orders;

-- Check available indexes for the order_items table
SHOW INDEX FROM order_items;

-- Check table statistics used by the optimizer
ANALYZE TABLE products;
ANALYZE TABLE customers;
ANALYZE TABLE orders;
ANALYZE TABLE order_items;
ANALYZE TABLE payments;

-- Show the updated execution plan after refreshing statistics
EXPLAIN
SELECT
    o.order_id,
    o.order_date,
    o.total_amount
FROM orders o
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;