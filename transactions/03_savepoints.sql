USE ecommerce_analytics;

-- Start a transaction for multiple changes
START TRANSACTION;

-- Update the first product
UPDATE products
SET price = price + 100
WHERE product_id = 1;

-- Create a savepoint after the first change
SAVEPOINT product_update_1;

-- Update the second product
UPDATE products
SET price = price + 200
WHERE product_id = 2;

-- Create another savepoint
SAVEPOINT product_update_2;

-- Update the third product
UPDATE products
SET price = price + 300
WHERE product_id = 3;

-- Roll back only the third product change
ROLLBACK TO SAVEPOINT product_update_2;

-- Check the product prices
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id IN (1, 2, 3);

-- Roll back the second product change
ROLLBACK TO SAVEPOINT product_update_1;

-- Check the product prices again
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE product_id IN (1, 2, 3);

-- Permanently save the first product change
COMMIT;

-- Start a new transaction for inventory updates
START TRANSACTION;

-- Increase inventory for product 1
UPDATE product_inventory
SET quantity_available = quantity_available + 10,
    last_restocked_at = NOW()
WHERE product_id = 1;

-- Create an inventory savepoint
SAVEPOINT inventory_update;

-- Increase inventory for product 2
UPDATE product_inventory
SET quantity_available = quantity_available + 20,
    last_restocked_at = NOW()
WHERE product_id = 2;

-- Check both inventory updates
SELECT
    product_id,
    quantity_available,
    last_restocked_at
FROM product_inventory
WHERE product_id IN (1, 2);

-- Undo only the product 2 inventory update
ROLLBACK TO SAVEPOINT inventory_update;

-- Check the remaining inventory change
SELECT
    product_id,
    quantity_available,
    last_restocked_at
FROM product_inventory
WHERE product_id IN (1, 2);

-- Save the product 1 inventory update
COMMIT;

-- Start a transaction for customer and order changes
START TRANSACTION;

-- Update customer information
UPDATE customers
SET phone = '9111111111'
WHERE customer_id = 2;

-- Create a customer savepoint
SAVEPOINT customer_update;

-- Update another customer's information
UPDATE customers
SET phone = '9222222222'
WHERE customer_id = 3;

-- Roll back only the second customer update
ROLLBACK TO SAVEPOINT customer_update;

-- Save the first customer update
COMMIT;

-- Verify the customer changes
SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM customers
WHERE customer_id IN (2, 3);

-- Start a transaction for order processing
START TRANSACTION;

-- Update the order status
UPDATE orders
SET order_status = 'Processing'
WHERE order_id = 4;

-- Create an order savepoint
SAVEPOINT order_status_update;

-- Update the payment status
UPDATE payments
SET payment_status = 'Completed'
WHERE order_id = 4;

-- Roll back the payment update only
ROLLBACK TO SAVEPOINT order_status_update;

-- Commit the order status update
COMMIT;

-- Verify the final order status
SELECT
    order_id,
    order_status
FROM orders
WHERE order_id = 4;

-- Verify the payment status
SELECT
    order_id,
    payment_status
FROM payments
WHERE order_id = 4;

-- Start a transaction with multiple savepoints
START TRANSACTION;

-- First change
UPDATE products
SET stock_quantity = stock_quantity + 5
WHERE product_id = 5;

-- First savepoint
SAVEPOINT stock_step_1;

-- Second change
UPDATE products
SET stock_quantity = stock_quantity + 10
WHERE product_id = 6;

-- Second savepoint
SAVEPOINT stock_step_2;

-- Third change
UPDATE products
SET stock_quantity = stock_quantity + 15
WHERE product_id = 7;

-- Roll back the third change
ROLLBACK TO SAVEPOINT stock_step_2;

-- Remove the second savepoint
RELEASE SAVEPOINT stock_step_2;

-- Commit the remaining changes
COMMIT;

-- Check the final stock values
SELECT
    product_id,
    product_name,
    stock_quantity
FROM products
WHERE product_id IN (5, 6, 7);

-- Start a transaction for complete rollback
START TRANSACTION;

-- Temporary customer update
UPDATE customers
SET status = 'Inactive'
WHERE customer_id = 4;

-- Create a savepoint
SAVEPOINT before_customer_rollback;

-- Temporary product update
UPDATE products
SET status = 'Inactive'
WHERE product_id = 8;

-- Roll back only the product update
ROLLBACK TO SAVEPOINT before_customer_rollback;

-- Commit the customer update
COMMIT;

-- Verify the final results
SELECT
    customer_id,
    status
FROM customers
WHERE customer_id = 4;

SELECT
    product_id,
    product_name,
    status
FROM products
WHERE product_id = 8;