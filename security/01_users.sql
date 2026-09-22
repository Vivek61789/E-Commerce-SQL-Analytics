-- Create database users for different application responsibilities

-- Remove the users if they already exist
DROP USER IF EXISTS 'ecommerce_admin'@'localhost';
DROP USER IF EXISTS 'ecommerce_analyst'@'localhost';
DROP USER IF EXISTS 'ecommerce_app'@'localhost';
DROP USER IF EXISTS 'ecommerce_readonly'@'localhost';

-- Create an administrator user
CREATE USER 'ecommerce_admin'@'localhost'
IDENTIFIED BY 'Admin@Ecommerce2026';

-- Create an analyst user
CREATE USER 'ecommerce_analyst'@'localhost'
IDENTIFIED BY 'Analyst@Ecommerce2026';

-- Create an application user
CREATE USER 'ecommerce_app'@'localhost'
IDENTIFIED BY 'App@Ecommerce2026';

-- Create a read-only reporting user
CREATE USER 'ecommerce_readonly'@'localhost'
IDENTIFIED BY 'Readonly@Ecommerce2026';

-- Check the created users
SELECT
    User,
    Host
FROM mysql.user
WHERE User IN (
    'ecommerce_admin',
    'ecommerce_analyst',
    'ecommerce_app',
    'ecommerce_readonly'
);

-- Check the administrator account
SHOW CREATE USER 'ecommerce_admin'@'localhost';

-- Check the analyst account
SHOW CREATE USER 'ecommerce_analyst'@'localhost';

-- Check the application account
SHOW CREATE USER 'ecommerce_app'@'localhost';

-- Check the read-only account
SHOW CREATE USER 'ecommerce_readonly'@'localhost';

-- Change the application user's password
ALTER USER 'ecommerce_app'@'localhost'
IDENTIFIED BY 'AppSecure@2026';

-- Lock the read-only account temporarily
ALTER USER 'ecommerce_readonly'@'localhost'
ACCOUNT LOCK;

-- Unlock the read-only account
ALTER USER 'ecommerce_readonly'@'localhost'
ACCOUNT UNLOCK;

-- Set the password expiration policy for the analyst account
ALTER USER 'ecommerce_analyst'@'localhost'
PASSWORD EXPIRE INTERVAL 180 DAY;

-- Show the current account status
SELECT
    User,
    Host,
    account_locked,
    password_expired
FROM mysql.user
WHERE User IN (
    'ecommerce_admin',
    'ecommerce_analyst',
    'ecommerce_app',
    'ecommerce_readonly'
);

-- Check current user
SELECT CURRENT_USER();

-- Check authenticated user
SELECT USER();

-- Check the current database
SELECT DATABASE();