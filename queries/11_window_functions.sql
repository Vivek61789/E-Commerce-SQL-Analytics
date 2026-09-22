USE ecommerce_analytics;

-- Rank products by price
SELECT
    product_id,
    product_name,
    price,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;

-- Rank products by price without gaps
SELECT
    product_id,
    product_name,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;

-- Assign a unique row number to products by price
SELECT
    product_id,
    product_name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS row_number
FROM products;

-- Rank products within each category
SELECT
    product_id,
    product_name,
    category_id,
    price,
    RANK() OVER (
        PARTITION BY category_id
        ORDER BY price DESC
    ) AS category_rank
FROM products;

-- Rank sellers by total revenue
SELECT
    s.seller_id,
    s.seller_name,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue,
    RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.unit_price - oi.discount_amount) DESC
    ) AS revenue_rank
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY s.seller_id, s.seller_name;

-- Rank customers by total spending
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(o.total_amount) DESC
    ) AS spending_rank
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Number each customer's orders chronologically
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS customer_order_number
FROM orders;

-- Find each customer's previous order value
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_value
FROM orders;

-- Find each customer's next order value
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LEAD(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS next_order_value
FROM orders;

-- Compare each order with the customer's previous order
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order,
    total_amount - LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS change_from_previous
FROM orders;

-- Calculate a running total of order revenue
SELECT
    order_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date, order_id
    ) AS running_revenue
FROM orders;

-- Calculate running revenue for each customer
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS customer_running_spending
FROM orders;

-- Calculate the average order value for each customer
SELECT
    order_id,
    customer_id,
    total_amount,
    ROUND(
        AVG(total_amount) OVER (
            PARTITION BY customer_id
        ),
        2
    ) AS customer_average_order
FROM orders;

-- Compare each order with the customer's average order
SELECT
    order_id,
    customer_id,
    total_amount,
    ROUND(
        AVG(total_amount) OVER (
            PARTITION BY customer_id
        ),
        2
    ) AS average_customer_order,
    total_amount -
    AVG(total_amount) OVER (
        PARTITION BY customer_id
    ) AS difference_from_average
FROM orders;

-- Calculate product sales totals with window functions
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(SUM(oi.quantity)) OVER () AS total_units_sold_all_products
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- Calculate each product's percentage of total revenue
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price - oi.discount_amount)
        / SUM(SUM(oi.quantity * oi.unit_price - oi.discount_amount)) OVER ()
        * 100,
        2
    ) AS revenue_percentage
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

-- Find the top three products in each category
SELECT
    product_id,
    product_name,
    category_id,
    price,
    product_rank
FROM (
    SELECT
        product_id,
        product_name,
        category_id,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY price DESC
        ) AS product_rank
    FROM products
) ranked_products
WHERE product_rank <= 3;

-- Find the top three customers by spending
SELECT
    customer_id,
    customer_name,
    total_spending,
    customer_rank
FROM (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(o.total_amount) AS total_spending,
        ROW_NUMBER() OVER (
            ORDER BY SUM(o.total_amount) DESC
        ) AS customer_rank
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) ranked_customers
WHERE customer_rank <= 3;

-- Calculate monthly revenue and running monthly revenue
SELECT
    order_year,
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY order_year, order_month
    ) AS running_revenue
FROM (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
) monthly_sales;

-- Calculate month-over-month revenue change
SELECT
    order_year,
    order_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY order_year, order_month
    ) AS previous_month_revenue,
    monthly_revenue -
    LAG(monthly_revenue) OVER (
        ORDER BY order_year, order_month
    ) AS revenue_change
FROM (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
) monthly_sales;

-- Calculate a three-row moving average of order values
SELECT
    order_id,
    order_date,
    total_amount,
    ROUND(
        AVG(total_amount) OVER (
            ORDER BY order_date, order_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_average
FROM orders;

-- Divide customers into four spending groups
SELECT
    customer_id,
    customer_name,
    total_spending,
    NTILE(4) OVER (
        ORDER BY total_spending DESC
    ) AS spending_quartile
FROM (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(o.total_amount) AS total_spending
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) customer_totals;

-- Find the highest priced product in each category
SELECT
    product_id,
    product_name,
    category_id,
    price
FROM (
    SELECT
        product_id,
        product_name,
        category_id,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY price DESC
        ) AS category_position
    FROM products
) ranked_products
WHERE category_position = 1;