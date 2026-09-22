USE ecommerce_analytics;

-- Show complete product information with category and seller
CREATE OR REPLACE VIEW vw_product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.seller_name,
    p.price,
    p.cost_price,
    p.stock_quantity,
    p.status,
    p.created_at
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN sellers s
    ON p.seller_id = s.seller_id;

-- Show customer order information
CREATE OR REPLACE VIEW vw_customer_orders AS
SELECT
    o.order_id,
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    o.order_date,
    o.total_amount,
    o.order_status,
    o.shipping_address
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- Show detailed order items
CREATE OR REPLACE VIEW vw_order_details AS
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS item_total
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN categories cat
    ON p.category_id = cat.category_id;

-- Show customer spending summary
CREATE OR REPLACE VIEW vw_customer_spending AS
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
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

-- Show product sales performance
CREATE OR REPLACE VIEW vw_product_sales AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        0
    ) AS revenue
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name;

-- Show category performance
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        0
    ) AS revenue
FROM categories c
LEFT JOIN products p
    ON c.category_id = p.category_id
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    c.category_id,
    c.category_name;

-- Show seller performance
CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        0
    ) AS revenue
FROM sellers s
LEFT JOIN products p
    ON s.seller_id = p.seller_id
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    s.seller_id,
    s.seller_name;

-- Show inventory status
CREATE OR REPLACE VIEW vw_inventory_status AS
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level,
    CASE
        WHEN pi.quantity_available = 0 THEN 'Out of Stock'
        WHEN pi.quantity_available <= pi.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS inventory_status
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id;

-- Show payment information with order and customer details
CREATE OR REPLACE VIEW vw_payment_details AS
SELECT
    pay.payment_id,
    pay.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    pay.payment_method,
    pay.amount,
    pay.payment_status,
    pay.transaction_reference,
    pay.payment_date
FROM payments pay
INNER JOIN orders o
    ON pay.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- Show shipment tracking information
CREATE OR REPLACE VIEW vw_shipment_tracking AS
SELECT
    sh.shipment_id,
    sh.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    sh.tracking_number,
    sh.courier_name,
    sh.shipped_date,
    sh.estimated_delivery_date,
    sh.delivered_date,
    sh.shipment_status,
    CASE
        WHEN sh.delivered_date IS NULL THEN 'Not Delivered'
        WHEN sh.delivered_date <= sh.estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_performance
FROM shipments sh
INNER JOIN orders o
    ON sh.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- Show product review summary
CREATE OR REPLACE VIEW vw_product_reviews AS
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    MIN(r.rating) AS lowest_rating,
    MAX(r.rating) AS highest_rating
FROM products p
LEFT JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name;

-- Show active products that need restocking
CREATE OR REPLACE VIEW vw_restock_required AS
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE p.status = 'Active'
  AND pi.quantity_available <= pi.reorder_level;

-- Show profitable products
CREATE OR REPLACE VIEW vw_product_profitability AS
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    price - cost_price AS profit_per_unit,
    ROUND(
        ((price - cost_price) / NULLIF(price, 0)) * 100,
        2
    ) AS profit_margin
FROM products
WHERE cost_price IS NOT NULL;

-- Show monthly revenue
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY
    YEAR(order_date),
    MONTH(order_date);

-- Test the product catalog view
SELECT *
FROM vw_product_catalog;

-- Test the customer spending view
SELECT *
FROM vw_customer_spending
ORDER BY total_spending DESC;

-- Test the product sales view
SELECT *
FROM vw_product_sales
ORDER BY revenue DESC;

-- Test the inventory view
SELECT *
FROM vw_inventory_status;

-- Test the monthly revenue view
SELECT *
FROM vw_monthly_revenue
ORDER BY sales_year, sales_month;