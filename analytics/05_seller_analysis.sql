USE ecommerce_analytics;

-- Show overall seller statistics
SELECT
    COUNT(*) AS total_sellers,
    SUM(s.status = 'Active') AS active_sellers,
    SUM(s.status <> 'Active') AS inactive_sellers
FROM sellers s;

-- Show seller details with product counts
SELECT
    s.seller_id,
    s.seller_name,
    s.email,
    s.status,
    COUNT(p.product_id) AS total_products
FROM sellers s
LEFT JOIN products p
    ON s.seller_id = p.seller_id
GROUP BY
    s.seller_id,
    s.seller_name,
    s.email,
    s.status
ORDER BY total_products DESC;

-- Calculate seller sales performance
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(
        oi.quantity * oi.unit_price - oi.discount_amount
    ), 2) AS total_revenue
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY total_revenue DESC;

-- Include sellers with no sales
WITH seller_sales AS (
    SELECT
        p.seller_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(
            SUM(oi.quantity * oi.unit_price - oi.discount_amount),
            0
        ) AS total_revenue
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY p.seller_id
)
SELECT
    s.seller_id,
    s.seller_name,
    COALESCE(ss.total_orders, 0) AS total_orders,
    COALESCE(ss.units_sold, 0) AS units_sold,
    COALESCE(ss.total_revenue, 0) AS total_revenue
FROM sellers s
LEFT JOIN seller_sales ss
    ON s.seller_id = ss.seller_id
ORDER BY total_revenue DESC;

-- Rank sellers by revenue
WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_name,
        COALESCE(
            SUM(oi.quantity * oi.unit_price - oi.discount_amount),
            0
        ) AS total_revenue
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name
)
SELECT
    seller_id,
    seller_name,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM seller_revenue
ORDER BY revenue_rank;

-- Rank sellers by units sold
WITH seller_units AS (
    SELECT
        s.seller_id,
        s.seller_name,
        COALESCE(SUM(oi.quantity), 0) AS units_sold
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name
)
SELECT
    seller_id,
    seller_name,
    units_sold,
    DENSE_RANK() OVER (
        ORDER BY units_sold DESC
    ) AS units_sold_rank
FROM seller_units
ORDER BY units_sold_rank;

-- Calculate average order value by seller
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY average_order_value DESC;

-- Calculate seller profit and profit margin
SELECT
    s.seller_id,
    s.seller_name,
    ROUND(
        SUM(
            oi.quantity * (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        ),
        2
    ) AS estimated_profit,
    ROUND(
        SUM(
            oi.quantity * (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        )
        / NULLIF(
            SUM(oi.quantity * oi.unit_price - oi.discount_amount),
            0
        ) * 100,
        2
    ) AS profit_margin_percentage
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY estimated_profit DESC;

-- Count products for each seller by category
SELECT
    s.seller_id,
    s.seller_name,
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN categories c
    ON p.category_id = c.category_id
GROUP BY
    s.seller_id,
    s.seller_name,
    c.category_id,
    c.category_name
ORDER BY
    s.seller_name,
    product_count DESC;

-- Find each seller's top-selling product
WITH product_sales AS (
    SELECT
        p.seller_id,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.seller_id,
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY seller_id
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    s.seller_id,
    s.seller_name,
    rp.product_id,
    rp.product_name,
    rp.units_sold,
    rp.revenue
FROM ranked_products rp
INNER JOIN sellers s
    ON rp.seller_id = s.seller_id
WHERE rp.product_rank = 1
ORDER BY rp.revenue DESC;

-- Calculate seller revenue by category
SELECT
    s.seller_id,
    s.seller_name,
    c.category_name,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS category_revenue
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN categories c
    ON p.category_id = c.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    s.seller_id,
    s.seller_name,
    c.category_id,
    c.category_name
ORDER BY
    s.seller_name,
    category_revenue DESC;

-- Calculate seller inventory value
SELECT
    s.seller_id,
    s.seller_name,
    SUM(pi.quantity_available) AS total_units,
    ROUND(
        SUM(pi.quantity_available * p.price),
        2
    ) AS inventory_value
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY inventory_value DESC;

-- Find sellers with low-stock products
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(p.product_id) AS low_stock_products
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available <= pi.reorder_level
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY low_stock_products DESC;

-- Calculate average product rating for each seller
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
LEFT JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY average_rating DESC;

-- Find sellers with highly rated products
SELECT
    s.seller_id,
    s.seller_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY
    s.seller_id,
    s.seller_name
HAVING AVG(r.rating) >= 4
ORDER BY average_rating DESC;

-- Calculate seller monthly revenue
SELECT
    s.seller_id,
    s.seller_name,
    YEAR(o.order_date) AS sales_year,
    MONTH(o.order_date) AS sales_month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS monthly_revenue
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    s.seller_id,
    s.seller_name,
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    sales_year,
    sales_month,
    monthly_revenue DESC;

-- Calculate seller revenue percentage
WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_name,
        COALESCE(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) AS total_revenue
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name
)
SELECT
    seller_id,
    seller_name,
    total_revenue,
    ROUND(
        total_revenue /
        NULLIF(SUM(total_revenue) OVER (), 0) * 100,
        2
    ) AS revenue_percentage
FROM seller_revenue
ORDER BY revenue_percentage DESC;

-- Find sellers contributing above average revenue
WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_name,
        COALESCE(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) AS total_revenue
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name
)
SELECT
    seller_id,
    seller_name,
    total_revenue
FROM seller_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM seller_revenue
)
ORDER BY total_revenue DESC;

-- Find sellers with products that have never been sold
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(p.product_id) AS unsold_products
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY unsold_products DESC;

-- Compare seller performance using a scorecard
WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_name,
        COUNT(DISTINCT p.product_id) AS total_products,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) AS revenue
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY
        s.seller_id,
        s.seller_name
)
SELECT
    seller_id,
    seller_name,
    total_products,
    total_orders,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    CASE
        WHEN revenue >= 50000 AND units_sold >= 20
            THEN 'High Performance'
        WHEN revenue >= 20000 OR units_sold >= 10
            THEN 'Medium Performance'
        ELSE 'Low Performance'
    END AS performance_category
FROM seller_metrics
ORDER BY revenue DESC;

-- Create a complete seller analytics summary
WITH seller_sales AS (
    SELECT
        s.seller_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) AS revenue,
        COALESCE(
            SUM(
                oi.quantity *
                (oi.unit_price - COALESCE(p.cost_price, 0))
                - oi.discount_amount
            ),
            0
        ) AS profit
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    LEFT JOIN orders o
        ON oi.order_id = o.order_id
       AND o.order_status <> 'Cancelled'
    GROUP BY s.seller_id
),
seller_inventory AS (
    SELECT
        s.seller_id,
        COUNT(p.product_id) AS total_products,
        COALESCE(SUM(pi.quantity_available), 0) AS available_units,
        COALESCE(
            SUM(pi.quantity_available * p.price),
            0
        ) AS inventory_value
    FROM sellers s
    LEFT JOIN products p
        ON s.seller_id = p.seller_id
    LEFT JOIN product_inventory pi
        ON p.product_id = pi.product_id
    GROUP BY s.seller_id
)
SELECT
    s.seller_id,
    s.seller_name,
    s.status,
    si.total_products,
    ss.total_orders,
    ss.units_sold,
    ROUND(ss.revenue, 2) AS revenue,
    ROUND(ss.profit, 2) AS estimated_profit,
    ROUND(
        ss.profit / NULLIF(ss.revenue, 0) * 100,
        2
    ) AS profit_margin_percentage,
    si.available_units,
    ROUND(si.inventory_value, 2) AS inventory_value
FROM sellers s
LEFT JOIN seller_sales ss
    ON s.seller_id = ss.seller_id
LEFT JOIN seller_inventory si
    ON s.seller_id = si.seller_id
ORDER BY revenue DESC;