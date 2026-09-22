USE ecommerce_analytics;

-- Add a new customer
INSERT INTO customers
(first_name, last_name, email, phone, date_of_birth, gender, status)
VALUES
('Nikhil', 'Rao', 'nikhil.rao@email.com', '9876543220', '2001-02-14', 'Male', 'Active');

-- Add a new product
INSERT INTO products
(product_name, category_id, seller_id, description, price, cost_price, stock_quantity, status)
VALUES
('Wireless Mouse', 1, 1, 'Ergonomic wireless mouse', 1499.00, 850.00, 100, 'Active');

-- Update a customer's phone number
UPDATE customers
SET phone = '9999999999'
WHERE customer_id = 1;

-- Update a product price
UPDATE products
SET price = 2699.00
WHERE product_id = 1;

-- Increase the stock of a product
UPDATE products
SET stock_quantity = stock_quantity + 20
WHERE product_id = 1;

-- Apply a discount to selected products
UPDATE products
SET price = price * 0.90
WHERE category_id = 2;

-- Update an order status
UPDATE orders
SET order_status = 'Delivered'
WHERE order_id = 5;

-- Update multiple products based on their stock
UPDATE products
SET status = 'Out of Stock'
WHERE stock_quantity = 0;

-- Delete a review
DELETE FROM reviews
WHERE review_id = 10;

-- Delete a cancelled order
DELETE FROM orders
WHERE order_status = 'Cancelled';

-- Add a temporary column for demonstration
ALTER TABLE products
ADD COLUMN warranty_months INT DEFAULT 0;

-- Update the new warranty information
UPDATE products
SET warranty_months = 12
WHERE category_id = 1;

-- Modify the warranty column definition
ALTER TABLE products
MODIFY warranty_months INT NOT NULL DEFAULT 0;

-- Rename the warranty column
ALTER TABLE products
RENAME COLUMN warranty_months TO warranty_period;

-- Remove the demonstration column
ALTER TABLE products
DROP COLUMN warranty_period;

-- Create a temporary table for demonstration
CREATE TABLE temp_import_data (
    import_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150),
    imported_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Remove all records from the temporary table
TRUNCATE TABLE temp_import_data;

-- Remove the temporary table
DROP TABLE temp_import_data;