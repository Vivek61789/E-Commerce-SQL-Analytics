USE ecommerce_analytics;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_product_after_update;

DELIMITER $$

-- Record product price and stock changes
CREATE TRIGGER trg_product_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price
       OR OLD.stock_quantity <> NEW.stock_quantity THEN

        INSERT INTO product_audit (
            product_id,
            action_type,
            old_price,
            new_price,
            old_stock,
            new_stock
        )
        VALUES (
            NEW.product_id,
            'UPDATE',
            OLD.price,
            NEW.price,
            OLD.stock_quantity,
            NEW.stock_quantity
        );

    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_product_before_insert;

DELIMITER $$

-- Prevent products with invalid pricing
CREATE TRIGGER trg_product_before_insert
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product price cannot be negative';
    END IF;

    IF NEW.cost_price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product cost price cannot be negative';
    END IF;

    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product stock cannot be negative';
    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_product_before_update;

DELIMITER $$

-- Prevent invalid product updates
CREATE TRIGGER trg_product_before_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product price cannot be negative';
    END IF;

    IF NEW.cost_price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product cost price cannot be negative';
    END IF;

    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product stock cannot be negative';
    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_order_after_update;

DELIMITER $$

-- Record order status changes
CREATE TRIGGER trg_order_after_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.order_status <> NEW.order_status THEN

        INSERT INTO order_audit (
            order_id,
            old_status,
            new_status
        )
        VALUES (
            NEW.order_id,
            OLD.order_status,
            NEW.order_status
        );

    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_inventory_after_update;

DELIMITER $$

-- Keep product stock synchronized with inventory
CREATE TRIGGER trg_inventory_after_update
AFTER UPDATE ON product_inventory
FOR EACH ROW
BEGIN
    IF OLD.quantity_available <> NEW.quantity_available THEN

        UPDATE products
        SET stock_quantity = NEW.quantity_available
        WHERE product_id = NEW.product_id;

    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_order_item_after_insert;

DELIMITER $$

-- Reduce available stock when an order item is added
CREATE TRIGGER trg_order_item_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    UPDATE product_inventory
    SET quantity_available = quantity_available - NEW.quantity
    WHERE product_id = NEW.product_id;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_review_before_insert;

DELIMITER $$

-- Keep product ratings between one and five
CREATE TRIGGER trg_review_before_insert
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_review_before_update;

DELIMITER $$

-- Validate updated product ratings
CREATE TRIGGER trg_review_before_update
BEFORE UPDATE ON reviews
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_payment_before_insert;

DELIMITER $$

-- Prevent invalid payment amounts
CREATE TRIGGER trg_payment_before_insert
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero';
    END IF;
END $$

DELIMITER ;

-- Remove the trigger if it already exists
DROP TRIGGER IF EXISTS trg_coupon_before_insert;

DELIMITER $$

-- Validate coupon dates and discount values
CREATE TRIGGER trg_coupon_before_insert
BEFORE INSERT ON coupons
FOR EACH ROW
BEGIN
    IF NEW.discount_value < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coupon discount cannot be negative';
    END IF;

    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coupon end date cannot be before start date';
    END IF;
END $$

DELIMITER ;

-- Test product audit trigger
UPDATE products
SET price = price + 100
WHERE product_id = 1;

-- Check the generated product audit record
SELECT *
FROM product_audit
WHERE product_id = 1
ORDER BY changed_at DESC;

-- Test order audit trigger
UPDATE orders
SET order_status = 'Shipped'
WHERE order_id = 1;

-- Check the generated order audit record
SELECT *
FROM order_audit
WHERE order_id = 1
ORDER BY changed_at DESC;

-- Check current inventory
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    pi.quantity_available
FROM products p
INNER JOIN product_inventory pi
    ON p.product_id = pi.product_id;

-- Check product audit history
SELECT *
FROM product_audit
ORDER BY changed_at DESC;

-- Check order audit history
SELECT *
FROM order_audit
ORDER BY changed_at DESC;