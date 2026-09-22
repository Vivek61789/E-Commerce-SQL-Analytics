USE ecommerce_analytics;

-- Find products priced above the average product price
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- Find the most expensive product
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);

-- Find the cheapest product
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price = (
    SELECT MIN(price)
    FROM products
);

-- Find customers who have placed at least one order
SELECT
    customer_id,
    first_name,
    last_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);

-- Find customers who have never placed an order
SELECT
    customer_id,
    first_name,
    last_name
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM orders
);

-- Find products that have been ordered
SELECT
    product_id,
    product_name
FROM products
WHERE product_id IN (
    SELECT product_id
    FROM order_items
);

-- Find products that have never been ordered
SELECT
    product_id,
    product_name
FROM products
WHERE product_id NOT IN (
    SELECT product_id
    FROM order_items
);

-- Find customers whose spending is above the average customer spending
SELECT
    customer_id,
    total_spending
FROM (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spending
    FROM orders
    GROUP BY customer_id
) AS customer_totals
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM (
        SELECT
            customer_id,
            SUM(total_amount) AS total_spending
        FROM orders
        GROUP BY customer_id
    ) AS spending_totals
);

-- Find products more expensive than every product in category 5
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > ALL (
    SELECT price
    FROM products
    WHERE category_id = 5
);

-- Find products more expensive than at least one product in category 5
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE price > ANY (
    SELECT price
    FROM products
    WHERE category_id = 5
);

-- Find customers who have at least one order above 5000
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.total_amount > 5000
);

-- Find customers who have no order above 5000
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.total_amount > 5000
);

-- Find products that belong to categories containing more than two products
SELECT
    p.product_id,
    p.product_name,
    p.category_id
FROM products p
WHERE p.category_id IN (
    SELECT category_id
    FROM products
    GROUP BY category_id
    HAVING COUNT(*) > 2
);

-- Find orders greater than the customer's average order value
SELECT
    o.order_id,
    o.customer_id,
    o.total_amount
FROM orders o
WHERE o.total_amount > (
    SELECT AVG(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- Find products whose price is above their category average
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.price
FROM products p
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
);

-- Find the highest-priced product in each category
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    p.price
FROM products p
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
);

-- Find customers who placed more orders than the average customer
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > (
    SELECT AVG(order_count)
    FROM (
        SELECT
            customer_id,
            COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS customer_orders
);

-- Find the order with the highest total amount
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE total_amount = (
    SELECT MAX(total_amount)
    FROM orders
);

-- Find sellers whose products have an average price above 3000
SELECT
    seller_id,
    seller_name
FROM sellers s
WHERE (
    SELECT AVG(p.price)
    FROM products p
    WHERE p.seller_id = s.seller_id
) > 3000;

-- Find products with sales quantity above the average product sales quantity
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) > (
    SELECT AVG(product_quantity)
    FROM (
        SELECT
            product_id,
            SUM(quantity) AS product_quantity
        FROM order_items
        GROUP BY product_id
    ) AS product_sales
);

-- Find customers who purchased a product from the Electronics category
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category_id = (
          SELECT category_id
          FROM categories
          WHERE category_name = 'Electronics'
      )
);

-- Find the second highest product price
SELECT MAX(price) AS second_highest_price
FROM products
WHERE price < (
    SELECT MAX(price)
    FROM products
);

-- Find customers whose latest order is above 3000
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE (
    SELECT o.total_amount
    FROM orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC
    LIMIT 1
) > 3000;