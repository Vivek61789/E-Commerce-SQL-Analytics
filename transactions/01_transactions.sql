USE ecommerce_analytics;

-- Start a transaction for multiple related operations
START TRANSACTION;

-- Create a new customer order
INSERT INTO orders (
    customer_id,
    total_amount,
    order_status,
    shipping_address
)
VALUES (
    1,
    2500.00,
    'Pending',
    'Hyderabad, Telangana'
);

-- Store the newly created order ID
SET @new_order_id = LAST_INSERT_ID();

-- Add products to the order
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount
)
VALUES
    (@new_order_id, 1, 1, 1200.00, 0.00),
    (@new_order_id, 2, 1, 1300.00, 0.00);

-- Record the payment for the order
INSERT INTO payments (
    order_id,
    payment_method,
    amount,
    payment_status,
    transaction_reference
)
VALUES (
    @new_order_id,
    'UPI',
    2500.00,
    'Completed',
    CONCAT('TXN-', @new_order_id, '-', UNIX_TIMESTAMP())
);

-- Complete the transaction
COMMIT;

-- Check the newly created order
SELECT *
FROM orders
WHERE order_id = @new_order_id;

-- Check the order items
SELECT *
FROM order_items
WHERE order_id = @new_order_id;

-- Check the payment
SELECT *
FROM payments
WHERE order_id = @new_order_id;

-- Start a transaction for updating multiple related records
START TRANSACTION;

-- Update the order status
UPDATE orders
SET order_status = 'Shipped'
WHERE order_id = @new_order_id;

-- Create shipment information
INSERT INTO shipments (
    order_id,
    tracking_number,
    courier_name,
    shipped_date,
    estimated_delivery_date,
    shipment_status
)
VALUES (
    @new_order_id,
    CONCAT('TRK-', @new_order_id),
    'BlueDart',
    NOW(),
    DATE_ADD(CURDATE(), INTERVAL 5 DAY),
    'Shipped'
);

-- Commit the shipment update
COMMIT;

-- Check order and shipment details
SELECT
    o.order_id,
    o.order_status,
    s.tracking_number,
    s.courier_name,
    s.shipment_status
FROM orders o
LEFT JOIN shipments s
    ON o.order_id = s.order_id
WHERE o.order_id = @new_order_id;

-- Start a transaction for inventory changes
START TRANSACTION;

-- Reduce product stock
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1
  AND stock_quantity >= 1;

-- Reduce inventory quantity
UPDATE product_inventory
SET quantity_available = quantity_available - 1
WHERE product_id = 1
  AND quantity_available >= 1;

-- Commit inventory changes
COMMIT;

-- Check updated inventory
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    pi.quantity_available
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE p.product_id = 1;

-- Demonstrate a transaction containing multiple updates
START TRANSACTION;

-- Update customer information
UPDATE customers
SET phone = '9876543210'
WHERE customer_id = 1;

-- Update product information
UPDATE products
SET price = price + 50
WHERE product_id = 2;

-- Update an order status
UPDATE orders
SET order_status = 'Processing'
WHERE order_id = 2;

-- Save all three changes
COMMIT;

-- Verify committed changes
SELECT customer_id, phone
FROM customers
WHERE customer_id = 1;

SELECT product_id, product_name, price
FROM products
WHERE product_id = 2;

SELECT order_id, order_status
FROM orders
WHERE order_id = 2;