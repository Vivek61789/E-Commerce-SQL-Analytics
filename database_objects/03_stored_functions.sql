USE ecommerce_analytics;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_customer_total_spending;

DELIMITER $$

-- Return the total amount spent by a customer
CREATE FUNCTION fn_customer_total_spending(
    p_customer_id INT
)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status <> 'Cancelled';

    RETURN v_total;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_customer_order_count;

DELIMITER $$

-- Return the number of orders placed by a customer
CREATE FUNCTION fn_customer_order_count(
    p_customer_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN v_count;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_product_profit;

DELIMITER $$

-- Return the profit earned from one product unit
CREATE FUNCTION fn_product_profit(
    p_product_id INT
)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_profit DECIMAL(12, 2);

    SELECT COALESCE(price - cost_price, 0)
    INTO v_profit
    FROM products
    WHERE product_id = p_product_id;

    RETURN v_profit;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_product_profit_margin;

DELIMITER $$

-- Return the profit margin percentage of a product
CREATE FUNCTION fn_product_profit_margin(
    p_product_id INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_margin DECIMAL(10, 2);

    SELECT COALESCE(
        ((price - cost_price) / NULLIF(price, 0)) * 100,
        0
    )
    INTO v_margin
    FROM products
    WHERE product_id = p_product_id;

    RETURN v_margin;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_stock_status;

DELIMITER $$

-- Return the current stock status of a product
CREATE FUNCTION fn_stock_status(
    p_product_id INT
)
RETURNS VARCHAR(30)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock INT;
    DECLARE v_status VARCHAR(30);

    SELECT stock_quantity
    INTO v_stock
    FROM products
    WHERE product_id = p_product_id;

    SET v_status = CASE
        WHEN v_stock IS NULL THEN 'Product Not Found'
        WHEN v_stock = 0 THEN 'Out of Stock'
        WHEN v_stock <= 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END;

    RETURN v_status;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_customer_segment;

DELIMITER $$

-- Return a customer segment based on spending
CREATE FUNCTION fn_customer_segment(
    p_customer_id INT
)
RETURNS VARCHAR(30)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_spending DECIMAL(12, 2);

    SET v_spending = fn_customer_total_spending(p_customer_id);

    RETURN CASE
        WHEN v_spending >= 10000 THEN 'VIP'
        WHEN v_spending >= 5000 THEN 'Premium'
        WHEN v_spending > 0 THEN 'Regular'
        ELSE 'No Purchase'
    END;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_order_value_category;

DELIMITER $$

-- Classify an order based on its total value
CREATE FUNCTION fn_order_value_category(
    p_order_amount DECIMAL(12, 2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_order_amount >= 10000 THEN 'Very High'
        WHEN p_order_amount >= 5000 THEN 'High'
        WHEN p_order_amount >= 2000 THEN 'Medium'
        WHEN p_order_amount > 0 THEN 'Low'
        ELSE 'Invalid'
    END;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_discount_amount;

DELIMITER $$

-- Calculate a discount amount from a percentage
CREATE FUNCTION fn_discount_amount(
    p_amount DECIMAL(12, 2),
    p_discount_percent DECIMAL(5, 2)
)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(
        p_amount * p_discount_percent / 100,
        2
    );
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_final_price;

DELIMITER $$

-- Calculate the final price after a discount
CREATE FUNCTION fn_final_price(
    p_amount DECIMAL(12, 2),
    p_discount_percent DECIMAL(5, 2)
)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(
        p_amount - (p_amount * p_discount_percent / 100),
        2
    );
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_delivery_days;

DELIMITER $$

-- Calculate the number of days between shipping and delivery
CREATE FUNCTION fn_delivery_days(
    p_shipped_date DATETIME,
    p_delivered_date DATE
)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_shipped_date IS NULL
          OR p_delivered_date IS NULL THEN NULL
        ELSE DATEDIFF(
            p_delivered_date,
            DATE(p_shipped_date)
        )
    END;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_delivery_status;

DELIMITER $$

-- Compare actual delivery with estimated delivery
CREATE FUNCTION fn_delivery_status(
    p_estimated_date DATE,
    p_delivered_date DATE
)
RETURNS VARCHAR(30)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_delivered_date IS NULL THEN 'Not Delivered'
        WHEN p_delivered_date <= p_estimated_date THEN 'On Time'
        ELSE 'Late'
    END;
END $$

DELIMITER ;

-- Remove the function if it already exists
DROP FUNCTION IF EXISTS fn_customer_average_order;

DELIMITER $$

-- Return the average order value for a customer
CREATE FUNCTION fn_customer_average_order(
    p_customer_id INT
)
RETURNS DECIMAL(12, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_average DECIMAL(12, 2);

    SELECT COALESCE(AVG(total_amount), 0)
    INTO v_average
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status <> 'Cancelled';

    RETURN v_average;
END $$

DELIMITER ;

-- Show customer spending using the custom function
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    fn_customer_total_spending(customer_id) AS total_spending
FROM customers;

-- Show customer segments using the custom function
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    fn_customer_order_count(customer_id) AS total_orders,
    fn_customer_total_spending(customer_id) AS total_spending,
    fn_customer_segment(customer_id) AS customer_segment
FROM customers;

-- Show product profitability using custom functions
SELECT
    product_id,
    product_name,
    price,
    cost_price,
    fn_product_profit(product_id) AS profit_per_unit,
    fn_product_profit_margin(product_id) AS profit_margin
FROM products;

-- Show product stock status using the custom function
SELECT
    product_id,
    product_name,
    stock_quantity,
    fn_stock_status(product_id) AS stock_status
FROM products;

-- Show order value categories using the custom function
SELECT
    order_id,
    total_amount,
    fn_order_value_category(total_amount) AS order_category
FROM orders;

-- Test discount calculation
SELECT
    5000.00 AS original_amount,
    fn_discount_amount(5000.00, 10) AS discount_amount,
    fn_final_price(5000.00, 10) AS final_price;

-- Show shipment delivery performance
SELECT
    shipment_id,
    order_id,
    shipped_date,
    estimated_delivery_date,
    delivered_date,
    fn_delivery_days(shipped_date, delivered_date) AS delivery_days,
    fn_delivery_status(
        estimated_delivery_date,
        delivered_date
    ) AS delivery_status
FROM shipments;

-- Show customer average order value
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    fn_customer_average_order(customer_id) AS average_order_value
FROM customers;