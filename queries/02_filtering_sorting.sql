USE ecommerce_analytics;

-- Find customers with an active account
SELECT *
FROM customers
WHERE status = 'Active';

-- Find products with a price greater than 3000
SELECT product_id, product_name, price
FROM products
WHERE price > 3000;

-- Find products priced between 1000 and 4000
SELECT product_id, product_name, price
FROM products
WHERE price BETWEEN 1000 AND 4000;

-- Find products belonging to selected categories
SELECT product_id, product_name, category_id
FROM products
WHERE category_id IN (1, 3, 5);

-- Find products that are not in selected categories
SELECT product_id, product_name, category_id
FROM products
WHERE category_id NOT IN (1, 3, 5);

-- Find customers whose first name starts with A
SELECT customer_id, first_name, last_name
FROM customers
WHERE first_name LIKE 'A%';

-- Find customers whose last name ends with a
SELECT customer_id, first_name, last_name
FROM customers
WHERE last_name LIKE '%a';

-- Find products containing the word 'Book'
SELECT product_id, product_name
FROM products
WHERE product_name LIKE '%Book%';

-- Find products with stock below 50
SELECT product_id, product_name, stock_quantity
FROM products
WHERE stock_quantity < 50;

-- Find products with stock between 50 and 100
SELECT product_id, product_name, stock_quantity
FROM products
WHERE stock_quantity BETWEEN 50 AND 100;

-- Find orders with a completed delivery
SELECT order_id, customer_id, total_amount, order_status
FROM orders
WHERE order_status = 'Delivered';

-- Find orders that are not cancelled
SELECT order_id, customer_id, total_amount, order_status
FROM orders
WHERE order_status <> 'Cancelled';

-- Find high-value orders
SELECT order_id, customer_id, total_amount
FROM orders
WHERE total_amount >= 5000;

-- Find customers who have a phone number
SELECT customer_id, first_name, last_name, phone
FROM customers
WHERE phone IS NOT NULL;

-- Find customers without a phone number
SELECT customer_id, first_name, last_name, phone
FROM customers
WHERE phone IS NULL;

-- Find active products costing less than 3000
SELECT product_id, product_name, price, status
FROM products
WHERE status = 'Active'
AND price < 3000;

-- Find products that are expensive or have low stock
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE price > 4000
OR stock_quantity < 50;

-- Find products that are active and have sufficient stock
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE status = 'Active'
AND stock_quantity >= 50;

-- Sort products by price from lowest to highest
SELECT product_id, product_name, price
FROM products
ORDER BY price ASC;

-- Sort products by price from highest to lowest
SELECT product_id, product_name, price
FROM products
ORDER BY price DESC;

-- Sort customers alphabetically by last name
SELECT customer_id, first_name, last_name
FROM customers
ORDER BY last_name ASC;

-- Sort orders by newest first
SELECT order_id, customer_id, order_date, total_amount
FROM orders
ORDER BY order_date DESC;

-- Display the five most expensive products
SELECT product_id, product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- Display the five cheapest products
SELECT product_id, product_name, price
FROM products
ORDER BY price ASC
LIMIT 5;

-- Display unique order statuses
SELECT DISTINCT order_status
FROM orders;

-- Display unique payment methods
SELECT DISTINCT payment_method
FROM payments;

-- Find active products priced between 1000 and 5000
SELECT product_id, product_name, price
FROM products
WHERE status = 'Active'
AND price BETWEEN 1000 AND 5000
ORDER BY price DESC
LIMIT 10;