USE ecommerce_analytics;

-- Display all customers
SELECT *
FROM customers;

-- Display all sellers
SELECT *
FROM sellers;

-- Display all categories
SELECT *
FROM categories;

-- Display all products
SELECT *
FROM products;

-- Display all orders
SELECT *
FROM orders;

-- Display selected customer information
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customers;

-- Display selected product information
SELECT
    product_id,
    product_name,
    price,
    stock_quantity
FROM products;

-- Display selected order information
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    order_status
FROM orders;

-- Count the total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Count the total number of products
SELECT COUNT(*) AS total_products
FROM products;

-- Count the total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Calculate the total value of all orders
SELECT SUM(total_amount) AS total_order_value
FROM orders;

-- Find the average order value
SELECT AVG(total_amount) AS average_order_value
FROM orders;

-- Find the highest order value
SELECT MAX(total_amount) AS highest_order_value
FROM orders;

-- Find the lowest order value
SELECT MIN(total_amount) AS lowest_order_value
FROM orders;