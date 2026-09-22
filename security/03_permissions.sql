USE ecommerce_analytics;

-- Remove old permissions before rebuilding them
REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'ecommerce_admin'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'ecommerce_analyst'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'ecommerce_app'@'localhost';

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'ecommerce_readonly'@'localhost';

-- Give the admin user complete database access
GRANT ALL PRIVILEGES
ON ecommerce_analytics.*
TO 'ecommerce_admin'@'localhost'
WITH GRANT OPTION;

-- Give the analyst user read access to reporting data
GRANT SELECT
ON ecommerce_analytics.*
TO 'ecommerce_analyst'@'localhost';

-- Give the application user customer permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.customers
TO 'ecommerce_app'@'localhost';

-- Give the application user order permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.orders
TO 'ecommerce_app'@'localhost';

-- Give the application user order item permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.order_items
TO 'ecommerce_app'@'localhost';

-- Give the application user payment permissions
GRANT SELECT, INSERT, UPDATE
ON ecommerce_analytics.payments
TO 'ecommerce_app'@'localhost';

-- Give the application user shipment permissions
GRANT SELECT, INSERT, UPDATE
ON ecommerce_analytics.shipments
TO 'ecommerce_app'@'localhost';

-- Give the application user product read access
GRANT SELECT
ON ecommerce_analytics.products
TO 'ecommerce_app'@'localhost';

-- Give the application user category read access
GRANT SELECT
ON ecommerce_analytics.categories
TO 'ecommerce_app'@'localhost';

-- Give the application user seller read access
GRANT SELECT
ON ecommerce_analytics.sellers
TO 'ecommerce_app'@'localhost';

-- Give the application user inventory read access
GRANT SELECT
ON ecommerce_analytics.product_inventory
TO 'ecommerce_app'@'localhost';

-- Give the application user review permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.reviews
TO 'ecommerce_app'@'localhost';

-- Give the application user coupon read access
GRANT SELECT
ON ecommerce_analytics.coupons
TO 'ecommerce_app'@'localhost';

-- Give the application user coupon usage permissions
GRANT SELECT, INSERT
ON ecommerce_analytics.coupon_usage
TO 'ecommerce_app'@'localhost';

-- Give the reporting user read-only access
GRANT SELECT
ON ecommerce_analytics.*
TO 'ecommerce_readonly'@'localhost';

-- Allow the analyst to use reporting views
GRANT SELECT
ON ecommerce_analytics.vw_product_catalog
TO 'ecommerce_analyst'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_customer_orders
TO 'ecommerce_analyst'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_customer_spending
TO 'ecommerce_analyst'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_product_sales
TO 'ecommerce_analyst'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_category_performance
TO 'ecommerce_analyst'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_seller_performance
TO 'ecommerce_analyst'@'localhost';

-- Allow the reporting user to use reporting views
GRANT SELECT
ON ecommerce_analytics.vw_customer_spending
TO 'ecommerce_readonly'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_product_sales
TO 'ecommerce_readonly'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_category_performance
TO 'ecommerce_readonly'@'localhost';

GRANT SELECT
ON ecommerce_analytics.vw_seller_performance
TO 'ecommerce_readonly'@'localhost';

-- Allow the application user to execute stored procedures
GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_get_customer_orders
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_get_product_sales
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_get_customer_spending
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_update_product_price
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_update_product_stock
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON PROCEDURE ecommerce_analytics.sp_update_order_status
TO 'ecommerce_app'@'localhost';

-- Allow the application user to execute stored functions
GRANT EXECUTE
ON FUNCTION ecommerce_analytics.fn_customer_total_spending
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON FUNCTION ecommerce_analytics.fn_customer_order_count
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON FUNCTION ecommerce_analytics.fn_product_profit
TO 'ecommerce_app'@'localhost';

GRANT EXECUTE
ON FUNCTION ecommerce_analytics.fn_product_profit_margin
TO 'ecommerce_app'@'localhost';

-- Remove DELETE permission from the application user for payments
REVOKE DELETE
ON ecommerce_analytics.payments
FROM 'ecommerce_app'@'localhost';

-- Remove UPDATE permission from the application user for products
REVOKE UPDATE
ON ecommerce_analytics.products
FROM 'ecommerce_app'@'localhost';

-- Show administrator permissions
SHOW GRANTS FOR 'ecommerce_admin'@'localhost';

-- Show analyst permissions
SHOW GRANTS FOR 'ecommerce_analyst'@'localhost';

-- Show application permissions
SHOW GRANTS FOR 'ecommerce_app'@'localhost';

-- Show read-only permissions
SHOW GRANTS FOR 'ecommerce_readonly'@'localhost';

-- Refresh the privilege tables
FLUSH PRIVILEGES;