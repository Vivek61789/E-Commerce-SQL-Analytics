USE ecommerce_analytics;

-- Show overall revenue metrics
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price - oi.discount_amount),
        2
    ) AS total_revenue,
    ROUND(
        AVG(oi.quantity * oi.unit_price - oi.discount_amount),
        2
    ) AS average_item_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate gross sales before discounts
SELECT
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS gross_sales
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate total discount given
SELECT
    ROUND(
        SUM(oi.discount_amount),
        2
    ) AS total_discount
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Compare gross sales, discounts, and net revenue
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_sales,
    ROUND(SUM(oi.discount_amount), 2) AS total_discount,
    ROUND(
        SUM(oi.quantity * oi.unit_price - oi.discount_amount),
        2
    ) AS net_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate revenue by order status
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;

-- Calculate daily revenue
SELECT
    DATE(o.order_date) AS revenue_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS daily_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY DATE(o.order_date)
ORDER BY revenue_date;

-- Calculate monthly revenue
SELECT
    YEAR(o.order_date) AS revenue_year,
    MONTH(o.order_date) AS revenue_month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS monthly_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    revenue_year,
    revenue_month;

-- Calculate yearly revenue
SELECT
    YEAR(o.order_date) AS revenue_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS yearly_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY YEAR(o.order_date)
ORDER BY revenue_year;

-- Calculate running revenue by month
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS revenue_year,
        MONTH(o.order_date) AS revenue_month,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    revenue_year,
    revenue_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue_year, revenue_month
        ),
        2
    ) AS running_revenue
FROM monthly_revenue
ORDER BY
    revenue_year,
    revenue_month;

-- Calculate month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS revenue_year,
        MONTH(o.order_date) AS revenue_month,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
),
revenue_comparison AS (
    SELECT
        revenue_year,
        revenue_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY revenue_year, revenue_month
        ) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    revenue_year,
    revenue_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(previous_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY
    revenue_year,
    revenue_month;

-- Calculate revenue contribution by category
WITH category_revenue AS (
    SELECT
        c.category_id,
        c.category_name,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM categories c
    INNER JOIN products p
        ON c.category_id = p.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        c.category_id,
        c.category_name
)
SELECT
    category_id,
    category_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_percentage
FROM category_revenue
ORDER BY revenue DESC;

-- Calculate revenue contribution by seller
WITH seller_revenue AS (
    SELECT
        s.seller_id,
        s.seller_name,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
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
)
SELECT
    seller_id,
    seller_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_percentage
FROM seller_revenue
ORDER BY revenue DESC;

-- Calculate revenue by payment method
SELECT
    p.payment_method,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.amount), 2) AS payment_revenue
FROM payments p
INNER JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
  AND p.payment_status = 'Completed'
GROUP BY p.payment_method
ORDER BY payment_revenue DESC;

-- Calculate revenue by payment status
SELECT
    p.payment_status,
    COUNT(*) AS payment_count,
    ROUND(SUM(p.amount), 2) AS payment_amount
FROM payments p
GROUP BY p.payment_status
ORDER BY payment_amount DESC;

-- Compare order revenue with recorded payment amounts
SELECT
    o.order_id,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS calculated_order_revenue,
    ROUND(
        COALESCE(SUM(p.amount), 0),
        2
    ) AS recorded_payment_amount,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) - COALESCE(SUM(p.amount), 0),
        2
    ) AS payment_difference
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY o.order_id
ORDER BY ABS(payment_difference) DESC;

-- Calculate revenue by customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Calculate average order value
SELECT
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        )
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate revenue by day of week
SELECT
    DAYNAME(o.order_date) AS day_name,
    DAYOFWEEK(o.order_date) AS day_number,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    DAYNAME(o.order_date),
    DAYOFWEEK(o.order_date)
ORDER BY day_number;

-- Calculate revenue by hour
SELECT
    HOUR(o.order_date) AS order_hour,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY HOUR(o.order_date)
ORDER BY order_hour;

-- Calculate monthly revenue and order count
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS revenue_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY revenue_month;

-- Calculate revenue from discounted orders
SELECT
    CASE
        WHEN oi.discount_amount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END AS order_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue,
    ROUND(
        SUM(oi.discount_amount),
        2
    ) AS total_discount
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    CASE
        WHEN oi.discount_amount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END;

-- Calculate revenue lost through discounts
SELECT
    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS gross_sales,
    ROUND(
        SUM(oi.discount_amount),
        2
    ) AS discount_amount,
    ROUND(
        SUM(oi.discount_amount)
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0) * 100,
        2
    ) AS discount_percentage,
    ROUND(
        SUM(oi.quantity * oi.unit_price - oi.discount_amount),
        2
    ) AS net_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate estimated gross profit
SELECT
    ROUND(
        SUM(
            oi.quantity *
            (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        ),
        2
    ) AS estimated_gross_profit
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status <> 'Cancelled';

-- Calculate revenue and profit margin by month
SELECT
    YEAR(o.order_date) AS revenue_year,
    MONTH(o.order_date) AS revenue_month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue,
    ROUND(
        SUM(
            oi.quantity *
            (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        ),
        2
    ) AS estimated_profit,
    ROUND(
        SUM(
            oi.quantity *
            (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        )
        / NULLIF(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) * 100,
        2
    ) AS profit_margin_percentage
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    revenue_year,
    revenue_month;

-- Calculate cumulative revenue percentage
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS revenue_year,
        MONTH(o.order_date) AS revenue_month,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    revenue_year,
    revenue_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue_year, revenue_month
        ),
        2
    ) AS cumulative_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue_year, revenue_month
        )
        / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS cumulative_revenue_percentage
FROM monthly_revenue
ORDER BY
    revenue_year,
    revenue_month;

-- Rank months by revenue
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS revenue_year,
        MONTH(o.order_date) AS revenue_month,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)
SELECT
    revenue_year,
    revenue_month,
    ROUND(revenue, 2) AS monthly_revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM monthly_revenue
ORDER BY revenue_rank;

-- Calculate the top revenue-generating products
SELECT
    p.product_id,
    p.product_name,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
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

-- Calculate the top revenue-generating customers
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY revenue DESC
LIMIT 10;

-- Find the percentage of revenue from the top customers
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / NULLIF(SUM(revenue) OVER (), 0) * 100,
        2
    ) AS revenue_percentage
FROM customer_revenue
ORDER BY revenue DESC;

-- Calculate revenue by category and month
SELECT
    c.category_name,
    YEAR(o.order_date) AS revenue_year,
    MONTH(o.order_date) AS revenue_month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM categories c
INNER JOIN products p
    ON c.category_id = p.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.category_id,
    c.category_name,
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    revenue_year,
    revenue_month,
    revenue DESC;

-- Calculate revenue by seller and month
SELECT
    s.seller_name,
    YEAR(o.order_date) AS revenue_year,
    MONTH(o.order_date) AS revenue_month,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
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
    revenue_year,
    revenue_month,
    revenue DESC;

-- Calculate revenue by shipment status
SELECT
    sh.shipment_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS revenue
FROM shipments sh
INNER JOIN orders o
    ON sh.order_id = o.order_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY sh.shipment_status
ORDER BY revenue DESC;

-- Calculate delivered revenue percentage
SELECT
    ROUND(
        SUM(
            CASE
                WHEN sh.shipment_status = 'Delivered'
                THEN oi.quantity * oi.unit_price - oi.discount_amount
                ELSE 0
            END
        ),
        2
    ) AS delivered_revenue,
    ROUND(
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ),
        2
    ) AS total_revenue,
    ROUND(
        SUM(
            CASE
                WHEN sh.shipment_status = 'Delivered'
                THEN oi.quantity * oi.unit_price - oi.discount_amount
                ELSE 0
            END
        )
        / NULLIF(
            SUM(
                oi.quantity * oi.unit_price - oi.discount_amount
            ),
            0
        ) * 100,
        2
    ) AS delivered_revenue_percentage
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN shipments sh
    ON o.order_id = sh.order_id
WHERE o.order_status <> 'Cancelled';

-- Calculate revenue from repeat customers
WITH customer_orders AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY o.customer_id
)
SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS repeat_customer_revenue,
    ROUND(
        SUM(revenue),
        2
    ) AS total_revenue,
    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN revenue
                ELSE 0
            END
        )
        / NULLIF(SUM(revenue), 0) * 100,
        2
    ) AS repeat_customer_revenue_percentage
FROM customer_orders;

-- Build a complete revenue analytics summary
WITH revenue_metrics AS (
    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS gross_sales,
        SUM(oi.discount_amount) AS total_discount,
        SUM(
            oi.quantity * oi.unit_price - oi.discount_amount
        ) AS net_revenue,
        SUM(
            oi.quantity *
            (oi.unit_price - COALESCE(p.cost_price, 0))
            - oi.discount_amount
        ) AS estimated_profit
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.order_status <> 'Cancelled'
)
SELECT
    total_orders,
    unique_customers,
    units_sold,
    ROUND(gross_sales, 2) AS gross_sales,
    ROUND(total_discount, 2) AS total_discount,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(estimated_profit, 2) AS estimated_profit,
    ROUND(
        total_discount / NULLIF(gross_sales, 0) * 100,
        2
    ) AS discount_percentage,
    ROUND(
        estimated_profit / NULLIF(net_revenue, 0) * 100,
        2
    ) AS profit_margin_percentage,
    ROUND(
        net_revenue / NULLIF(total_orders, 0),
        2
    ) AS average_order_value
FROM revenue_metrics;