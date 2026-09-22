USE ecommerce_analytics;

-- Find the top-selling product by quantity
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 1;

-- Find the top-selling product in each category
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(oi.quantity) AS units_sold
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category_id
            ORDER BY units_sold DESC
        ) AS sales_rank
    FROM product_sales
)
SELECT
    product_id,
    product_name,
    category_id,
    units_sold
FROM ranked_products
WHERE sales_rank = 1;

-- Find the highest-spending customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(o.total_amount) AS total_spending
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spending DESC
LIMIT 1;

-- Calculate customer lifetime value
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC;

-- Find customers with repeat purchases
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Find customers who purchased from multiple categories
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT p.category_id) AS categories_purchased
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.category_id) > 1
ORDER BY categories_purchased DESC;

-- Find products that have never been purchased
SELECT
    p.product_id,
    p.product_name,
    p.price
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);

-- Find customers who purchased both electronics and books
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    INNER JOIN categories cat
        ON p.category_id = cat.category_id
    WHERE o.customer_id = c.customer_id
      AND cat.category_name = 'Electronics'
)
AND EXISTS (
    SELECT 1
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    INNER JOIN categories cat
        ON p.category_id = cat.category_id
    WHERE o.customer_id = c.customer_id
      AND cat.category_name = 'Books'
);

-- Find the most profitable products
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    price - cost_price AS profit,
    ROUND(((price - cost_price) / NULLIF(price, 0)) * 100, 2) AS profit_margin
FROM products
ORDER BY profit DESC;

-- Calculate category revenue and percentage of total revenue
WITH category_sales AS (
    SELECT
        c.category_id,
        c.category_name,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue
    FROM categories c
    INNER JOIN products p
        ON c.category_id = p.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
)
SELECT
    category_id,
    category_name,
    revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;

-- Calculate monthly revenue growth
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS sales_year,
        MONTH(order_date) AS sales_month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY YEAR(order_date), MONTH(order_date)
),
monthly_growth AS (
    SELECT
        sales_year,
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_year, sales_month
        ) AS previous_revenue
    FROM monthly_sales
)
SELECT
    sales_year,
    sales_month,
    revenue,
    previous_revenue,
    ROUND(
        ((revenue - previous_revenue) / NULLIF(previous_revenue, 0)) * 100,
        2
    ) AS growth_percentage
FROM monthly_growth
ORDER BY sales_year, sales_month;

-- Calculate average order value by customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(AVG(o.total_amount), 2) AS average_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY average_order_value DESC;

-- Find customers whose average order value is above the overall average
WITH customer_averages AS (
    SELECT
        customer_id,
        AVG(total_amount) AS average_order_value
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(ca.average_order_value, 2) AS average_order_value
FROM customer_averages ca
INNER JOIN customers c
    ON ca.customer_id = c.customer_id
WHERE ca.average_order_value > (
    SELECT AVG(total_amount)
    FROM orders
)
ORDER BY average_order_value DESC;

-- Calculate seller revenue and profit
SELECT
    s.seller_id,
    s.seller_name,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue,
    SUM(oi.quantity * (p.price - p.cost_price)) AS estimated_profit
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY s.seller_id, s.seller_name
ORDER BY revenue DESC;

-- Find products below their inventory reorder level
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available < pi.reorder_level
ORDER BY pi.quantity_available;

-- Calculate total inventory value
SELECT
    SUM(price * stock_quantity) AS total_inventory_value
FROM products;

-- Find the most valuable inventory products
SELECT
    product_id,
    product_name,
    stock_quantity,
    price,
    price * stock_quantity AS inventory_value
FROM products
ORDER BY inventory_value DESC;

-- Calculate payment success rate
SELECT
    ROUND(
        SUM(CASE
            WHEN payment_status = 'Completed' THEN 1
            ELSE 0
        END) / COUNT(*) * 100,
        2
    ) AS payment_success_rate
FROM payments;

-- Calculate order delivery rate
SELECT
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN 1
            ELSE 0
        END) / COUNT(*) * 100,
        2
    ) AS delivery_rate
FROM orders;

-- Calculate average delivery time
SELECT
    ROUND(
        AVG(DATEDIFF(delivered_date, shipped_date)),
        2
    ) AS average_delivery_days
FROM shipments
WHERE shipped_date IS NOT NULL
  AND delivered_date IS NOT NULL;

-- Find late deliveries
SELECT
    shipment_id,
    order_id,
    estimated_delivery_date,
    delivered_date,
    DATEDIFF(delivered_date, estimated_delivery_date) AS days_late
FROM shipments
WHERE delivered_date > estimated_delivery_date
ORDER BY days_late DESC;

-- Calculate review statistics for each product
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) AS five_star_reviews,
    SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END) AS low_rating_reviews
FROM products p
LEFT JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- Find products with strong sales but low inventory
WITH product_sales AS (
    SELECT
        product_id,
        SUM(quantity) AS units_sold
    FROM order_items
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    ps.units_sold,
    p.stock_quantity
FROM products p
INNER JOIN product_sales ps
    ON p.product_id = ps.product_id
WHERE ps.units_sold > 1
  AND p.stock_quantity < 50
ORDER BY ps.units_sold DESC;

-- Find the second highest spending customer
WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spending
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spending,
        DENSE_RANK() OVER (
            ORDER BY total_spending DESC
        ) AS spending_rank
    FROM customer_spending
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    rc.total_spending
FROM ranked_customers rc
INNER JOIN customers c
    ON rc.customer_id = c.customer_id
WHERE rc.spending_rank = 2;

-- Create a complete customer performance report
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0) AS total_spending,
        COALESCE(AVG(o.total_amount), 0) AS average_order_value
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT
    customer_id,
    customer_name,
    total_orders,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(average_order_value, 2) AS average_order_value,
    CASE
        WHEN total_spending >= 10000 THEN 'VIP'
        WHEN total_spending >= 5000 THEN 'Premium'
        WHEN total_orders > 1 THEN 'Repeat'
        WHEN total_orders = 1 THEN 'New'
        ELSE 'No Orders'
    END AS customer_segment
FROM customer_metrics
ORDER BY total_spending DESC;