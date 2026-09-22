USE ecommerce_analytics;

-- Show overall product statistics
SELECT
    COUNT(*) AS total_products,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_products,
    SUM(CASE WHEN status = 'Inactive' THEN 1 ELSE 0 END) AS inactive_products,
    AVG(price) AS average_product_price,
    MAX(price) AS highest_product_price,
    MIN(price) AS lowest_product_price
FROM products;

-- Show products with category and seller information
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.seller_name,
    p.price,
    p.cost_price,
    p.stock_quantity,
    p.status
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN sellers s
    ON p.seller_id = s.seller_id
ORDER BY p.product_name;

-- Show product sales performance
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        0
    ) AS revenue
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN orders o
    ON oi.order_id = o.order_id
   AND o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY revenue DESC;

-- Show top products by units sold
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- Show top products by revenue
SELECT
    p.product_id,
    p.product_name,
    SUM(
        (oi.quantity * oi.unit_price) - oi.discount_amount
    ) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- Rank products by revenue
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank;

-- Rank products within each category
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id
)
SELECT
    product_id,
    product_name,
    category_id,
    revenue,
    RANK() OVER (
        PARTITION BY category_id
        ORDER BY revenue DESC
    ) AS category_revenue_rank
FROM product_revenue
ORDER BY category_id, category_revenue_rank;

-- Find the top product in each category
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id
),
ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category_id
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category_id,
    revenue
FROM ranked_products
WHERE product_rank = 1;

-- Calculate product profit
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    price - cost_price AS profit_per_unit,
    ROUND(
        ((price - cost_price) / NULLIF(price, 0)) * 100,
        2
    ) AS profit_margin
FROM products
WHERE cost_price IS NOT NULL
ORDER BY profit_per_unit DESC;

-- Calculate estimated profit from product sales
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(
        oi.quantity * (p.price - p.cost_price)
    ) AS estimated_profit
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
  AND p.cost_price IS NOT NULL
GROUP BY
    p.product_id,
    p.product_name
ORDER BY estimated_profit DESC;

-- Find products with the highest profit margins
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    ROUND(
        ((price - cost_price) / NULLIF(price, 0)) * 100,
        2
    ) AS profit_margin
FROM products
WHERE cost_price IS NOT NULL
ORDER BY profit_margin DESC
LIMIT 10;

-- Show product inventory value
SELECT
    product_id,
    product_name,
    stock_quantity,
    price,
    stock_quantity * price AS inventory_value
FROM products
ORDER BY inventory_value DESC;

-- Find products with low inventory
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available <= pi.reorder_level
ORDER BY pi.quantity_available;

-- Find products that are out of stock
SELECT
    product_id,
    product_name,
    stock_quantity,
    status
FROM products
WHERE stock_quantity = 0;

-- Find products that have never been sold
SELECT
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status <> 'Cancelled'
);

-- Find products with high sales and low stock
WITH product_sales AS (
    SELECT
        product_id,
        SUM(quantity) AS units_sold
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
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
WHERE ps.units_sold >= 5
  AND p.stock_quantity <= 20
ORDER BY ps.units_sold DESC;

-- Show product review performance
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating,
    MIN(r.rating) AS lowest_rating,
    MAX(r.rating) AS highest_rating
FROM products p
LEFT JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY average_rating DESC;

-- Find highly rated products
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM products p
INNER JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING AVG(r.rating) >= 4
ORDER BY average_rating DESC;

-- Find poorly rated products
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM products p
INNER JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING AVG(r.rating) < 3
ORDER BY average_rating;

-- Compare product sales with average product sales
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(oi.quantity), 0) AS units_sold
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    units_sold
FROM product_sales
WHERE units_sold > (
    SELECT AVG(units_sold)
    FROM product_sales
)
ORDER BY units_sold DESC;

-- Calculate each product's percentage of total revenue
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS revenue_percentage
FROM product_revenue
ORDER BY revenue DESC;

-- Show monthly product sales
SELECT
    p.product_id,
    p.product_name,
    YEAR(o.order_date) AS sales_year,
    MONTH(o.order_date) AS sales_month,
    SUM(oi.quantity) AS units_sold,
    SUM(
        (oi.quantity * oi.unit_price) - oi.discount_amount
    ) AS revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name,
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    p.product_id,
    sales_year,
    sales_month;

-- Calculate product revenue growth month over month
WITH monthly_product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name,
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    product_id,
    product_name,
    sales_year,
    sales_month,
    revenue,
    LAG(revenue) OVER (
        PARTITION BY product_id
        ORDER BY sales_year, sales_month
    ) AS previous_revenue,
    ROUND(
        (
            revenue - LAG(revenue) OVER (
                PARTITION BY product_id
                ORDER BY sales_year, sales_month
            )
        )
        /
        NULLIF(
            LAG(revenue) OVER (
                PARTITION BY product_id
                ORDER BY sales_year, sales_month
            ),
            0
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly_product_sales
ORDER BY
    product_id,
    sales_year,
    sales_month;

-- Show products by price category
SELECT
    product_id,
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 5000 THEN 'High'
        WHEN price >= 2000 THEN 'Medium'
        ELSE 'Budget'
    END AS price_category
FROM products
ORDER BY price DESC;

-- Find the most expensive product in each category
WITH ranked_products AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        p.price,
        RANK() OVER (
            PARTITION BY p.category_id
            ORDER BY p.price DESC
        ) AS price_rank
    FROM products p
)
SELECT
    product_id,
    product_name,
    category_id,
    price
FROM ranked_products
WHERE price_rank = 1;

-- Build a complete product analytics summary
WITH sales AS (
    SELECT
        p.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(
            (oi.quantity * oi.unit_price) - oi.discount_amount
        ) AS revenue
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY p.product_id
),
reviews_summary AS (
    SELECT
        product_id,
        COUNT(*) AS review_count,
        AVG(rating) AS average_rating
    FROM reviews
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.price,
    p.cost_price,
    p.stock_quantity,
    COALESCE(s.units_sold, 0) AS units_sold,
    COALESCE(s.revenue, 0) AS revenue,
    ROUND(
        ((p.price - p.cost_price) / NULLIF(p.price, 0)) * 100,
        2
    ) AS profit_margin,
    COALESCE(rs.review_count, 0) AS review_count,
    ROUND(COALESCE(rs.average_rating, 0), 2) AS average_rating
FROM products p
LEFT JOIN sales s
    ON p.product_id = s.product_id
LEFT JOIN reviews_summary rs
    ON p.product_id = rs.product_id
ORDER BY revenue DESC;