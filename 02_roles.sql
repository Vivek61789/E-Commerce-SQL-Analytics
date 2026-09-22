USE ecommerce_analytics;

-- Remove the roles if they already exist
DROP ROLE IF EXISTS
    'ecommerce_admin_role',
    'ecommerce_analyst_role',
    'ecommerce_app_role',
    'ecommerce_readonly_role';

-- Create an administrator role
CREATE ROLE 'ecommerce_admin_role';

-- Create an analyst role
CREATE ROLE 'ecommerce_analyst_role';

-- Create an application role
CREATE ROLE 'ecommerce_app_role';

-- Create a read-only role
CREATE ROLE 'ecommerce_readonly_role';

-- Give the administrator role full access to the database
GRANT ALL PRIVILEGES
ON ecommerce_analytics.*
TO 'ecommerce_admin_role';

-- Give the analyst role access to data for reporting
GRANT SELECT
ON ecommerce_analytics.*
TO 'ecommerce_analyst_role';

-- Give the application role access to common application operations
GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.customers
TO 'ecommerce_app_role';

GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.orders
TO 'ecommerce_app_role';

GRANT SELECT, INSERT, UPDATE, DELETE
ON ecommerce_analytics.order_items
TO 'ecommerce_app_role';

GRANT SELECT, INSERT, UPDATE
ON ecommerce_analytics.payments
TO 'ecommerce_app_role';

GRANT SELECT, INSERT, UPDATE
ON ecommerce_analytics.shipments
TO 'ecommerce_app_role';

GRANT SELECT
ON ecommerce_analytics.products
TO 'ecommerce_app_role';

GRANT SELECT
ON ecommerce_analytics.categories
TO 'ecommerce_app_role';

-- Give the read-only role reporting access
GRANT SELECT
ON ecommerce_analytics.*
TO 'ecommerce_readonly_role';

-- Assign the administrator role to the admin user
GRANT 'ecommerce_admin_role'
TO 'ecommerce_admin'@'localhost';

-- Assign the analyst role to the analyst user
GRANT 'ecommerce_analyst_role'
TO 'ecommerce_analyst'@'localhost';

-- Assign the application role to the application user
GRANT 'ecommerce_app_role'
TO 'ecommerce_app'@'localhost';

-- Assign the read-only role to the reporting user
GRANT 'ecommerce_readonly_role'
TO 'ecommerce_readonly'@'localhost';

-- Set the default role for the administrator
SET DEFAULT ROLE 'ecommerce_admin_role'
TO 'ecommerce_admin'@'localhost';

-- Set the default role for the analyst
SET DEFAULT ROLE 'ecommerce_analyst_role'
TO 'ecommerce_analyst'@'localhost';

-- Set the default role for the application user
SET DEFAULT ROLE 'ecommerce_app_role'
TO 'ecommerce_app'@'localhost';

-- Set the default role for the read-only user
SET DEFAULT ROLE 'ecommerce_readonly_role'
TO 'ecommerce_readonly'@'localhost';

-- Show administrator role privileges
SHOW GRANTS FOR 'ecommerce_admin_role';

-- Show analyst role privileges
SHOW GRANTS FOR 'ecommerce_analyst_role';

-- Show application role privileges
SHOW GRANTS FOR 'ecommerce_app_role';

-- Show read-only role privileges
SHOW GRANTS FOR 'ecommerce_readonly_role';

-- Show the roles assigned to the admin user
SHOW GRANTS FOR 'ecommerce_admin'@'localhost';

-- Show the roles assigned to the analyst user
SHOW GRANTS FOR 'ecommerce_analyst'@'localhost';

-- Show the roles assigned to the application user
SHOW GRANTS FOR 'ecommerce_app'@'localhost';

-- Show the roles assigned to the read-only user
SHOW GRANTS FOR 'ecommerce_readonly'@'localhost';

-- Activate the administrator role for the current session
SET ROLE 'ecommerce_admin_role';

-- Show the currently active role
SELECT CURRENT_ROLE();

-- Reset the role for the current session
SET ROLE NONE;