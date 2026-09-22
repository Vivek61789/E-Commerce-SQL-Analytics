USE ecommerce_analytics;

-- Remove demo indexes if they already exist
DROP INDEX IF EXISTS idx_products_category_status
ON products;

DROP INDEX IF EXISTS idx_orders_customer_date
ON orders;

DROP INDEX IF EXISTS idx_order_items_product_order
ON order_items;

DROP INDEX IF EXISTS idx_payments_status_date
ON payments;

DROP INDEX IF EXISTS idx_products_name
ON products;

-- Create a single-column index for product name searches
CREATE INDEX idx_products_name
ON products(product_name);

-- Create a composite index for category and status filtering
CREATE INDEX idx_products_category_status
ON products(category_id, status);

-- Create a composite index for customer order history
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

-- Create a composite index for product sales analysis
CREATE INDEX idx_order_items_product_order
ON order_items(product_id, order_id);

-- Create a composite index for payment reporting
CREATE INDEX idx_payments_status_date
ON payments(payment_status, payment_date);

-- Create a unique index for coupon codes
CREATE UNIQUE INDEX idx_coupons_code
ON coupons(coupon_code);

-- Create an index for customer registration analysis
CREATE INDEX idx_customers_registration
ON customers(registration_date);

-- Create an index for product price filtering
CREATE INDEX idx_products_price
ON products(price);

-- Create an index for order amount analysis
CREATE INDEX idx_orders_total_amount
ON orders(total_amount);

-- Show indexes on the products table
SHOW INDEX FROM products;

-- Show indexes on the orders table
SHOW INDEX FROM orders;

-- Show indexes on the order_items table
SHOW INDEX FROM order_items;

-- Show indexes on the payments table
SHOW INDEX FROM payments;

-- Show indexes on the coupons table
SHOW INDEX FROM coupons;

-- Check indexes used for product filtering
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
  AND status = 'Active';

-- Check indexes used for customer order history
EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Check indexes used for product sales
EXPLAIN
SELECT
    product_id,
    SUM(quantity) AS units_sold
FROM order_items
WHERE product_id = 1
GROUP BY product_id;

-- Check indexes used for payment filtering
EXPLAIN
SELECT
    payment_id,
    order_id,
    amount
FROM payments
WHERE payment_status = 'Completed'
ORDER BY payment_date DESC;

-- Check indexes used for product name search
EXPLAIN
SELECT
    product_id,
    product_name
FROM products
WHERE product_name = 'Laptop Pro 15';

-- List all indexes created for the project
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE,
    SEQ_IN_INDEX
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;