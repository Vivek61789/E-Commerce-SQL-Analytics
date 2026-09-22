USE ecommerce_analytics;

-- Classify products based on their price
SELECT
    product_id,
    product_name,
    price,
    CASE
        WHEN price >= 5000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_category
FROM products;

-- Classify products based on available stock
SELECT
    product_id,
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < 20 THEN 'Low Stock'
        WHEN stock_quantity <= 100 THEN 'Normal Stock'
        ELSE 'High Stock'
    END AS stock_status
FROM products;

-- Classify orders based on their total amount
SELECT
    order_id,
    total_amount,
    CASE
        WHEN total_amount >= 7500 THEN 'High Value'
        WHEN total_amount >= 3000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category
FROM orders;

-- Classify customers based on total spending
SELECT
    customer_id,
    SUM(total_amount) AS total_spending,
    CASE
        WHEN SUM(total_amount) >= 10000 THEN 'VIP'
        WHEN SUM(total_amount) >= 5000 THEN 'Premium'
        ELSE 'Regular'
    END AS customer_segment
FROM orders
GROUP BY customer_id;

-- Classify orders based on their current status
SELECT
    order_id,
    order_status,
    CASE order_status
        WHEN 'Delivered' THEN 'Completed'
        WHEN 'Shipped' THEN 'In Transit'
        WHEN 'Processing' THEN 'Being Prepared'
        WHEN 'Cancelled' THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_description
FROM orders;

-- Calculate the discount category for each order item
SELECT
    order_item_id,
    quantity,
    unit_price,
    discount_amount,
    CASE
        WHEN discount_amount = 0 THEN 'No Discount'
        WHEN discount_amount < 200 THEN 'Small Discount'
        WHEN discount_amount <= 500 THEN 'Medium Discount'
        ELSE 'Large Discount'
    END AS discount_category
FROM order_items;

-- Determine whether products are profitable
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    CASE
        WHEN price > cost_price THEN 'Profitable'
        WHEN price = cost_price THEN 'Break Even'
        ELSE 'Loss'
    END AS profitability
FROM products;

-- Calculate profit amount and classify profit level
SELECT
    product_id,
    product_name,
    price - cost_price AS profit,
    CASE
        WHEN price - cost_price >= 2000 THEN 'High Profit'
        WHEN price - cost_price >= 1000 THEN 'Medium Profit'
        ELSE 'Low Profit'
    END AS profit_level
FROM products;

-- Identify customers based on their order frequency
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    CASE
        WHEN COUNT(*) >= 3 THEN 'Frequent Customer'
        WHEN COUNT(*) = 2 THEN 'Repeat Customer'
        ELSE 'New Customer'
    END AS customer_type
FROM orders
GROUP BY customer_id;

-- Calculate delivery performance
SELECT
    shipment_id,
    order_id,
    estimated_delivery_date,
    delivered_date,
    CASE
        WHEN delivered_date IS NULL THEN 'Not Delivered'
        WHEN delivered_date <= estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_performance
FROM shipments;

-- Classify products by profit margin
SELECT
    product_id,
    product_name,
    ROUND(((price - cost_price) / NULLIF(price, 0)) * 100, 2) AS profit_margin,
    CASE
        WHEN ((price - cost_price) / NULLIF(price, 0)) * 100 >= 40 THEN 'High Margin'
        WHEN ((price - cost_price) / NULLIF(price, 0)) * 100 >= 20 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS margin_category
FROM products;

-- Count orders by status using conditional aggregation
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN order_status = 'Shipped' THEN 1 ELSE 0 END) AS shipped_orders,
    SUM(CASE WHEN order_status = 'Processing' THEN 1 ELSE 0 END) AS processing_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders;

-- Calculate revenue by order status
SELECT
    SUM(CASE
        WHEN order_status = 'Delivered'
        THEN total_amount
        ELSE 0
    END) AS delivered_revenue,
    SUM(CASE
        WHEN order_status = 'Shipped'
        THEN total_amount
        ELSE 0
    END) AS shipped_revenue,
    SUM(CASE
        WHEN order_status = 'Processing'
        THEN total_amount
        ELSE 0
    END) AS processing_revenue,
    SUM(CASE
        WHEN order_status = 'Cancelled'
        THEN total_amount
        ELSE 0
    END) AS cancelled_revenue
FROM orders;

-- Count products by price category
SELECT
    CASE
        WHEN price >= 5000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_category,
    COUNT(*) AS total_products
FROM products
GROUP BY
    CASE
        WHEN price >= 5000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END;

-- Calculate total inventory value by stock level
SELECT
    CASE
        WHEN stock_quantity < 20 THEN 'Low Stock'
        WHEN stock_quantity <= 100 THEN 'Normal Stock'
        ELSE 'High Stock'
    END AS stock_category,
    SUM(price * stock_quantity) AS inventory_value
FROM products
GROUP BY
    CASE
        WHEN stock_quantity < 20 THEN 'Low Stock'
        WHEN stock_quantity <= 100 THEN 'Normal Stock'
        ELSE 'High Stock'
    END;

-- Identify customers with spending and order frequency
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spending,
    CASE
        WHEN COUNT(*) >= 3 AND SUM(total_amount) >= 10000 THEN 'High Value Frequent'
        WHEN COUNT(*) >= 2 AND SUM(total_amount) >= 5000 THEN 'Valuable Repeat'
        WHEN COUNT(*) >= 2 THEN 'Repeat'
        ELSE 'Occasional'
    END AS customer_segment
FROM orders
GROUP BY customer_id;