USE ecommerce_analytics;

-- Show overall inventory statistics
SELECT
    COUNT(*) AS total_products,
    SUM(quantity_available) AS total_units_available,
    SUM(
        quantity_available * p.price
    ) AS total_inventory_value,
    AVG(quantity_available) AS average_stock
FROM product_inventory pi
INNER JOIN products p
    ON pi.product_id = p.product_id;

-- Show inventory with product details
SELECT
    p.product_id,
    p.product_name,
    p.price,
    pi.quantity_available,
    pi.reorder_level,
    pi.last_restocked_at
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY pi.quantity_available ASC;

-- Classify products by inventory status
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level,
    CASE
        WHEN pi.quantity_available = 0 THEN 'Out of Stock'
        WHEN pi.quantity_available <= pi.reorder_level THEN 'Low Stock'
        WHEN pi.quantity_available <= pi.reorder_level * 2 THEN 'Medium Stock'
        ELSE 'Healthy Stock'
    END AS inventory_status
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY pi.quantity_available;

-- Find products that are out of stock
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available = 0;

-- Find products below reorder level
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level,
    pi.reorder_level - pi.quantity_available AS units_needed
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available < pi.reorder_level
ORDER BY units_needed DESC;

-- Find products exactly at reorder level
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available = pi.reorder_level;

-- Calculate inventory value for each product
SELECT
    p.product_id,
    p.product_name,
    p.price,
    pi.quantity_available,
    pi.quantity_available * p.price AS inventory_value
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY inventory_value DESC;

-- Find the most valuable inventory
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    p.price,
    pi.quantity_available * p.price AS inventory_value
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY inventory_value DESC
LIMIT 10;

-- Calculate inventory value by category
SELECT
    c.category_id,
    c.category_name,
    SUM(pi.quantity_available) AS total_units,
    SUM(pi.quantity_available * p.price) AS inventory_value
FROM categories c
INNER JOIN products p
    ON c.category_id = p.category_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY inventory_value DESC;

-- Calculate inventory value by seller
SELECT
    s.seller_id,
    s.seller_name,
    SUM(pi.quantity_available) AS total_units,
    SUM(pi.quantity_available * p.price) AS inventory_value
FROM sellers s
INNER JOIN products p
    ON s.seller_id = p.seller_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
GROUP BY
    s.seller_id,
    s.seller_name
ORDER BY inventory_value DESC;

-- Find sellers with low inventory
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(*) AS low_stock_products,
    SUM(pi.quantity_available) AS remaining_units
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

-- Find products that need immediate restocking
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level,
    CASE
        WHEN pi.quantity_available = 0 THEN 'Critical'
        WHEN pi.quantity_available < pi.reorder_level THEN 'High'
        ELSE 'Normal'
    END AS restock_priority
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available <= pi.reorder_level
ORDER BY
    CASE
        WHEN pi.quantity_available = 0 THEN 1
        WHEN pi.quantity_available < pi.reorder_level THEN 2
        ELSE 3
    END;

-- Estimate the quantity required to reach twice the reorder level
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.reorder_level,
    GREATEST(
        (pi.reorder_level * 2) - pi.quantity_available,
        0
    ) AS suggested_restock_quantity
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY suggested_restock_quantity DESC;

-- Find products with high sales but low inventory
WITH product_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    ps.units_sold,
    pi.quantity_available,
    pi.reorder_level
FROM products p
INNER JOIN product_sales ps
    ON p.product_id = ps.product_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.quantity_available <= pi.reorder_level
ORDER BY ps.units_sold DESC;

-- Calculate stock turnover using sold units and available units
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
    COALESCE(ps.units_sold, 0) AS units_sold,
    pi.quantity_available,
    ROUND(
        COALESCE(ps.units_sold, 0)
        / NULLIF(pi.quantity_available, 0),
        2
    ) AS stock_turnover_ratio
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
LEFT JOIN product_sales ps
    ON p.product_id = ps.product_id
ORDER BY stock_turnover_ratio DESC;

-- Rank products by inventory value
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available * p.price AS inventory_value,
    RANK() OVER (
        ORDER BY pi.quantity_available * p.price DESC
    ) AS inventory_value_rank
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY inventory_value_rank;

-- Rank inventory within each category
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    pi.quantity_available * p.price AS inventory_value,
    RANK() OVER (
        PARTITION BY c.category_id
        ORDER BY pi.quantity_available * p.price DESC
    ) AS category_inventory_rank
FROM products p
INNER JOIN categories c
    ON p.category_id = c.category_id
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY
    c.category_name,
    category_inventory_rank;

-- Find categories with the highest low-stock percentage
WITH category_inventory AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(*) AS total_products,
        SUM(
            CASE
                WHEN pi.quantity_available <= pi.reorder_level
                THEN 1
                ELSE 0
            END
        ) AS low_stock_products
    FROM categories c
    INNER JOIN products p
        ON c.category_id = p.category_id
    INNER JOIN product_inventory pi
        ON p.product_id = pi.product_id
    GROUP BY
        c.category_id,
        c.category_name
)
SELECT
    category_id,
    category_name,
    total_products,
    low_stock_products,
    ROUND(
        low_stock_products / total_products * 100,
        2
    ) AS low_stock_percentage
FROM category_inventory
ORDER BY low_stock_percentage DESC;

-- Show products by last restock date
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.last_restocked_at
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY pi.last_restocked_at;

-- Find products that have not been restocked recently
SELECT
    p.product_id,
    p.product_name,
    pi.quantity_available,
    pi.last_restocked_at,
    DATEDIFF(
        CURDATE(),
        DATE(pi.last_restocked_at)
    ) AS days_since_restock
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE pi.last_restocked_at IS NULL
   OR pi.last_restocked_at < DATE_SUB(
       NOW(),
       INTERVAL 90 DAY
   )
ORDER BY days_since_restock DESC;

-- Show inventory aging categories
SELECT
    p.product_id,
    p.product_name,
    pi.last_restocked_at,
    CASE
        WHEN pi.last_restocked_at IS NULL THEN 'Never Restocked'
        WHEN pi.last_restocked_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            THEN 'Recent'
        WHEN pi.last_restocked_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
            THEN 'Aging'
        ELSE 'Old'
    END AS inventory_age
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
ORDER BY pi.last_restocked_at;

-- Calculate total potential sales value of inventory
SELECT
    SUM(
        pi.quantity_available * p.price
    ) AS potential_inventory_sales_value
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id;

-- Calculate potential profit from current inventory
SELECT
    SUM(
        pi.quantity_available *
        (p.price - COALESCE(p.cost_price, 0))
    ) AS potential_inventory_profit
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id;

-- Find high-value products with low stock
SELECT
    p.product_id,
    p.product_name,
    p.price,
    pi.quantity_available,
    pi.reorder_level,
    pi.quantity_available * p.price AS current_inventory_value
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id
WHERE p.price >= 5000
  AND pi.quantity_available <= pi.reorder_level
ORDER BY p.price DESC;

-- Build a complete inventory analytics summary
WITH inventory_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        p.seller_id,
        p.price,
        p.cost_price,
        pi.quantity_available,
        pi.reorder_level,
        pi.last_restocked_at,
        pi.quantity_available * p.price AS inventory_value
    FROM products p
    INNER JOIN product_inventory pi
        ON p.product_id = pi.product_id
)
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    quantity_available,
    reorder_level,
    inventory_value,
    CASE
        WHEN quantity_available = 0 THEN 'Out of Stock'
        WHEN quantity_available <= reorder_level THEN 'Low Stock'
        WHEN quantity_available <= reorder_level * 2 THEN 'Medium Stock'
        ELSE 'Healthy Stock'
    END AS inventory_status,
    CASE
        WHEN quantity_available = 0 THEN 'Critical'
        WHEN quantity_available <= reorder_level THEN 'Restock Soon'
        ELSE 'Normal'
    END AS restock_status,
    last_restocked_at
FROM inventory_metrics
ORDER BY inventory_value DESC;