USE ecommerce_analytics;

-- Start a transaction and commit successful changes
START TRANSACTION;

-- Update a customer's phone number
UPDATE customers
SET phone = '9000000001'
WHERE customer_id = 1;

-- Commit the customer update
COMMIT;

-- Verify the committed change
SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM customers
WHERE customer_id = 1;

-- Start a transaction and roll back the changes
START TRANSACTION;

-- Temporarily change a product price
UPDATE products
SET price = price + 1000
WHERE product_id = 1;

-- Check the temporary price
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id = 1;

-- Undo the price change
ROLLBACK;

-- Verify that the original price is restored
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id = 1;

-- Start a transaction with multiple changes
START TRANSACTION;

-- Update an order status
UPDATE orders
SET order_status = 'Processing'
WHERE order_id = 3;

-- Update the payment status
UPDATE payments
SET payment_status = 'Completed'
WHERE order_id = 3;

-- Create a shipment record
INSERT INTO shipments (
    order_id,
    tracking_number,
    courier_name,
    shipped_date,
    estimated_delivery_date,
    shipment_status
)
VALUES (
    3,
    CONCAT('ROLLBACK-TEST-', UNIX_TIMESTAMP()),
    'Delhivery',
    NOW(),
    DATE_ADD(CURDATE(), INTERVAL 5 DAY),
    'Processing'
);

-- Undo all changes in the transaction
ROLLBACK;

-- Verify that the order update was rolled back
SELECT
    order_id,
    order_status
FROM orders
WHERE order_id = 3;

-- Verify that the payment update was rolled back
SELECT
    order_id,
    payment_status
FROM payments
WHERE order_id = 3;

-- Verify that the shipment was not created
SELECT
    shipment_id,
    order_id,
    tracking_number
FROM shipments
WHERE order_id = 3
  AND tracking_number LIKE 'ROLLBACK-TEST-%';

-- Demonstrate rollback after an invalid operation
START TRANSACTION;

-- Update a valid product
UPDATE products
SET price = price + 200
WHERE product_id = 2;

-- Force an invalid operation to demonstrate transaction recovery
SET @invalid_product_id = -1;

-- Roll back the transaction
ROLLBACK;

-- Verify that the valid update was also undone
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id = 2;

-- Demonstrate a successful transaction with multiple operations
START TRANSACTION;

-- Increase product stock
UPDATE products
SET stock_quantity = stock_quantity + 10
WHERE product_id = 3;

-- Increase inventory stock
UPDATE product_inventory
SET quantity_available = quantity_available + 10,
    last_restocked_at = NOW()
WHERE product_id = 3;

-- Record the transaction permanently
COMMIT;

-- Verify the committed inventory changes
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    pi.quantity_available,
    pi.last_restocked_at
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE p.product_id = 3;

-- Check the current transaction isolation level
SELECT @@transaction_isolation AS transaction_isolation_level;

-- Check whether autocommit is enabled
SELECT @@autocommit AS autocommit_status;

-- Disable autocommit for manual transaction control
SET autocommit = 0;

-- Start a manual transaction
START TRANSACTION;

-- Make a temporary product update
UPDATE products
SET price = price + 25
WHERE product_id = 4;

-- Undo the temporary change
ROLLBACK;

-- Restore autocommit mode
SET autocommit = 1;

-- Verify the rollback
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id = 4;