USE ecommerce_analytics;

-- Convert customer names to uppercase
SELECT
    customer_id,
    UPPER(first_name) AS first_name_upper,
    UPPER(last_name) AS last_name_upper
FROM customers;

-- Convert customer names to lowercase
SELECT
    customer_id,
    LOWER(first_name) AS first_name_lower,
    LOWER(last_name) AS last_name_lower
FROM customers;

-- Combine customer first and last names
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM customers;

-- Find the length of each customer name
SELECT
    customer_id,
    first_name,
    LENGTH(first_name) AS name_length
FROM customers;

-- Remove extra spaces from customer names
SELECT
    customer_id,
    TRIM(first_name) AS cleaned_first_name
FROM customers;

-- Extract the first three characters of product names
SELECT
    product_id,
    product_name,
    LEFT(product_name, 3) AS name_prefix
FROM products;

-- Extract the last three characters of product names
SELECT
    product_id,
    product_name,
    RIGHT(product_name, 3) AS name_suffix
FROM products;

-- Round product prices to the nearest whole number
SELECT
    product_id,
    product_name,
    ROUND(price) AS rounded_price
FROM products;

-- Calculate the absolute difference between price and cost
SELECT
    product_id,
    product_name,
    ABS(price - cost_price) AS price_difference
FROM products;

-- Calculate product profit
SELECT
    product_id,
    product_name,
    price - cost_price AS profit
FROM products;

-- Calculate the profit margin percentage
SELECT
    product_id,
    product_name,
    ROUND(((price - cost_price) / price) * 100, 2) AS profit_margin
FROM products;

-- Find the remainder of product prices divided by 100
SELECT
    product_id,
    product_name,
    MOD(price, 100) AS price_remainder
FROM products;

-- Get the current date
SELECT CURDATE() AS current_date;

-- Get the current date and time
SELECT NOW() AS current_datetime;

-- Extract the year from order dates
SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year
FROM orders;

-- Extract the month from order dates
SELECT
    order_id,
    order_date,
    MONTH(order_date) AS order_month
FROM orders;

-- Extract the day from order dates
SELECT
    order_id,
    order_date,
    DAY(order_date) AS order_day
FROM orders;

-- Calculate the number of days since each order
SELECT
    order_id,
    order_date,
    DATEDIFF(CURDATE(), order_date) AS days_since_order
FROM orders;

-- Calculate the expected delivery date
SELECT
    order_id,
    order_date,
    DATE_ADD(order_date, INTERVAL 7 DAY) AS expected_delivery_date
FROM orders;

-- Count the number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Count customers with phone numbers
SELECT COUNT(phone) AS customers_with_phone
FROM customers;

-- Calculate total revenue from orders
SELECT SUM(total_amount) AS total_revenue
FROM orders;

-- Calculate average order value
SELECT ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders;

-- Find the highest order value
SELECT MAX(total_amount) AS highest_order
FROM orders;

-- Find the lowest order value
SELECT MIN(total_amount) AS lowest_order
FROM orders;

-- Find the total product stock
SELECT SUM(stock_quantity) AS total_stock
FROM products;

-- Find the average product price
SELECT ROUND(AVG(price), 2) AS average_product_price
FROM products;

-- Find products with missing cost prices
SELECT
    product_id,
    product_name,
    COALESCE(cost_price, 0) AS cost_price
FROM products;

-- Avoid division by zero when calculating profit margins
SELECT
    product_id,
    product_name,
    COALESCE(
        ROUND(((price - cost_price) / NULLIF(price, 0)) * 100, 2),
        0
    ) AS profit_margin
FROM products;