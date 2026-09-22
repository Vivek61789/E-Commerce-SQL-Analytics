USE ecommerce_analytics;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_customer_orders;

DELIMITER $$

-- Get all orders for a customer
CREATE PROCEDURE sp_get_customer_orders(
    IN p_customer_id INT
)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.total_amount,
        o.order_status,
        o.shipping_address
    FROM orders o
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_product_sales;

DELIMITER $$

-- Get sales information for a product
CREATE PROCEDURE sp_get_product_sales(
    IN p_product_id INT
)
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(
            SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
            0
        ) AS total_revenue
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    WHERE p.product_id = p_product_id
    GROUP BY p.product_id, p.product_name;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_customer_spending;

DELIMITER $$

-- Get a customer's spending summary
CREATE PROCEDURE sp_get_customer_spending(
    IN p_customer_id INT
)
BEGIN
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0) AS total_spending,
        COALESCE(AVG(o.total_amount), 0) AS average_order_value
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE c.customer_id = p_customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_orders_by_status;

DELIMITER $$

-- Get orders using a selected status
CREATE PROCEDURE sp_get_orders_by_status(
    IN p_order_status VARCHAR(30)
)
BEGIN
    SELECT
        order_id,
        customer_id,
        order_date,
        total_amount,
        order_status
    FROM orders
    WHERE order_status = p_order_status
    ORDER BY order_date DESC;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_update_product_price;

DELIMITER $$

-- Update the price of a product
CREATE PROCEDURE sp_update_product_price(
    IN p_product_id INT,
    IN p_new_price DECIMAL(10, 2)
)
BEGIN
    UPDATE products
    SET price = p_new_price
    WHERE product_id = p_product_id;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_update_product_stock;

DELIMITER $$

-- Update product stock quantity
CREATE PROCEDURE sp_update_product_stock(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    UPDATE products
    SET stock_quantity = p_quantity
    WHERE product_id = p_product_id;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_update_order_status;

DELIMITER $$

-- Update the status of an order
CREATE PROCEDURE sp_update_order_status(
    IN p_order_id INT,
    IN p_new_status VARCHAR(30)
)
BEGIN
    UPDATE orders
    SET order_status = p_new_status
    WHERE order_id = p_order_id;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_sales_summary;

DELIMITER $$

-- Return overall sales statistics
CREATE PROCEDURE sp_get_sales_summary()
BEGIN
    SELECT
        COUNT(order_id) AS total_orders,
        COALESCE(SUM(total_amount), 0) AS total_revenue,
        COALESCE(AVG(total_amount), 0) AS average_order_value,
        COALESCE(MAX(total_amount), 0) AS highest_order_value,
        COALESCE(MIN(total_amount), 0) AS lowest_order_value
    FROM orders
    WHERE order_status <> 'Cancelled';
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_category_sales;

DELIMITER $$

-- Return sales information for a category
CREATE PROCEDURE sp_get_category_sales(
    IN p_category_id INT
)
BEGIN
    SELECT
        c.category_id,
        c.category_name,
        COUNT(DISTINCT p.product_id) AS product_count,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(
            SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
            0
        ) AS revenue
    FROM categories c
    LEFT JOIN products p
        ON c.category_id = p.category_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    WHERE c.category_id = p_category_id
    GROUP BY
        c.category_id,
        c.category_name;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_low_stock_products;

DELIMITER $$

-- Return products that need restocking
CREATE PROCEDURE sp_get_low_stock_products(
    IN p_threshold INT
)
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        pi.quantity_available,
        pi.reorder_level
    FROM products p
    INNER JOIN product_inventory pi
        ON p.product_id = pi.product_id
    WHERE pi.quantity_available <= p_threshold
    ORDER BY pi.quantity_available ASC;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_add_customer;

DELIMITER $$

-- Add a new customer
CREATE PROCEDURE sp_add_customer(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_date_of_birth DATE,
    IN p_gender VARCHAR(20)
)
BEGIN
    INSERT INTO customers (
        first_name,
        last_name,
        email,
        phone,
        date_of_birth,
        gender
    )
    VALUES (
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_date_of_birth,
        p_gender
    );
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_add_product;

DELIMITER $$

-- Add a new product
CREATE PROCEDURE sp_add_product(
    IN p_product_name VARCHAR(150),
    IN p_category_id INT,
    IN p_seller_id INT,
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_cost_price DECIMAL(10, 2),
    IN p_stock_quantity INT
)
BEGIN
    INSERT INTO products (
        product_name,
        category_id,
        seller_id,
        description,
        price,
        cost_price,
        stock_quantity
    )
    VALUES (
        p_product_name,
        p_category_id,
        p_seller_id,
        p_description,
        p_price,
        p_cost_price,
        p_stock_quantity
    );
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_customer_order_count;

DELIMITER $$

-- Return the number of orders for a customer
CREATE PROCEDURE sp_get_customer_order_count(
    IN p_customer_id INT,
    OUT p_order_count INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_order_count
    FROM orders
    WHERE customer_id = p_customer_id;
END $$

DELIMITER ;

-- Remove the procedure if it already exists
DROP PROCEDURE IF EXISTS sp_get_product_count;

DELIMITER $$

-- Return the number of products in a category
CREATE PROCEDURE sp_get_product_count(
    IN p_category_id INT,
    OUT p_product_count INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_product_count
    FROM products
    WHERE category_id = p_category_id;
END $$

DELIMITER ;

-- Test customer orders
CALL sp_get_customer_orders(1);

-- Test product sales
CALL sp_get_product_sales(1);

-- Test customer spending
CALL sp_get_customer_spending(1);

-- Test orders by status
CALL sp_get_orders_by_status('Delivered');

-- Test sales summary
CALL sp_get_sales_summary();

-- Test category sales
CALL sp_get_category_sales(1);

-- Test low stock products
CALL sp_get_low_stock_products(20);

-- Test customer order count
CALL sp_get_customer_order_count(1, @order_count);
SELECT @order_count AS total_orders;

-- Test product count
CALL sp_get_product_count(1, @product_count);
SELECT @product_count AS total_products;