# 🛒 E-Commerce SQL Analytics Engine

A complete **MySQL e-commerce database project** built to practice and demonstrate SQL from **basic queries to advanced database engineering and analytics**.

The project uses a realistic e-commerce system with customers, products, sellers, orders, payments, shipments, inventory, reviews, coupons, and more.

It is designed to show not only how to write SQL queries, but also how SQL is used to **design, manage, secure, optimize, and analyze a real-world database**.

---

## 📌 Project Overview

This project simulates the database behind an e-commerce platform.

It answers practical business questions such as:

* Which products sell the most?
* Which customers generate the most revenue?
* Which sellers perform well?
* Which products are running out of stock?
* How much revenue is generated each month?
* Which categories generate the most sales?
* How profitable are products?
* Which customers are repeat buyers?
* What is the average order value?
* Which products need to be restocked?
* How can slow SQL queries be optimized?

The entire project is implemented using **MySQL 8.x**.

---

## 🎯 What This Project Demonstrates

This project covers SQL in multiple stages:

```text
Database Design
      ↓
Tables & Relationships
      ↓
Constraints & Sample Data
      ↓
Basic SQL Queries
      ↓
Advanced SQL Queries
      ↓
Views & Stored Programs
      ↓
Transactions
      ↓
Security
      ↓
Query Optimization
      ↓
Business Analytics
```

---

# 🗄️ Database

The database is named:

```sql
ecommerce_analytics
```

The project contains **15 related tables**.

### Main Tables

| Table               | Purpose                            |
| ------------------- | ---------------------------------- |
| `customers`         | Stores customer information        |
| `sellers`           | Stores seller information          |
| `categories`        | Stores product categories          |
| `products`          | Stores product details and pricing |
| `product_inventory` | Tracks available stock             |
| `orders`            | Stores customer orders             |
| `order_items`       | Stores products included in orders |
| `payments`          | Stores payment information         |
| `shipments`         | Tracks order shipments             |
| `reviews`           | Stores customer product reviews    |
| `coupons`           | Stores promotional coupons         |
| `coupon_usage`      | Tracks coupon usage                |
| `employees`         | Stores employee information        |
| `product_audit`     | Tracks product changes             |
| `order_audit`       | Tracks order status changes        |

---

# 🧩 Database Design

The database demonstrates important relational database concepts including:

* Primary Keys
* Foreign Keys
* Unique Constraints
* NOT NULL Constraints
* CHECK Constraints
* Default Values
* AUTO_INCREMENT
* One-to-many relationships
* Many-to-one relationships
* Referential Integrity
* Cascading Updates
* Cascading Deletes
* Restricted Deletes
* Nullable Foreign Keys

The database also includes audit tables for tracking important changes.

---

# 📁 Project Structure

```text
E-Commerce-SQL-Analytics-Engine/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── database/
│   ├── 01_database_setup.sql
│   ├── 02_tables.sql
│   ├── 03_constraints.sql
│   ├── 04_sample_data.sql
│   └── 05_indexes.sql
│
├── queries/
│   ├── 01_basic_queries.sql
│   ├── 02_filtering_sorting.sql
│   ├── 03_data_modification.sql
│   ├── 04_functions.sql
│   ├── 05_grouping_aggregation.sql
│   ├── 06_joins.sql
│   ├── 07_subqueries.sql
│   ├── 08_case_statements.sql
│   ├── 09_cte.sql
│   ├── 10_recursive_cte.sql
│   ├── 11_window_functions.sql
│   └── 12_advanced_queries.sql
│
├── database_objects/
│   ├── 01_views.sql
│   ├── 02_stored_procedures.sql
│   ├── 03_stored_functions.sql
│   └── 04_triggers.sql
│
├── transactions/
│   ├── 01_transactions.sql
│   ├── 02_commit_rollback.sql
│   └── 03_savepoints.sql
│
├── security/
│   ├── 01_users.sql
│   ├── 02_roles.sql
│   └── 03_permissions.sql
│
├── optimization/
│   ├── 01_indexes.sql
│   ├── 02_explain.sql
│   └── 03_query_optimization.sql
│
├── analytics/
│   ├── 01_sales_analysis.sql
│   ├── 02_customer_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_inventory_analysis.sql
│   ├── 05_seller_analysis.sql
│   └── 06_revenue_analysis.sql
│
├── er_diagram/
│   └── ecommerce_erd.png
│
└── screenshots/
    ├── database.png
    ├── queries.png
    └── analytics.png
```

---

# 🏗️ 1. Database Setup

The `database/` folder creates the complete e-commerce database.

### Includes

* Database creation
* Table creation
* Relationships
* Constraints
* Realistic sample data
* Database indexes

### Files

```text
01_database_setup.sql
```

Creates the database and selects it.

```text
02_tables.sql
```

Creates all 15 tables.

```text
03_constraints.sql
```

Adds foreign keys, unique constraints, checks, and referential integrity rules.

```text
04_sample_data.sql
```

Adds realistic customers, products, orders, payments, sellers, reviews, inventory, and other data.

```text
05_indexes.sql
```

Creates indexes for commonly searched and joined columns.

---

# 🔎 2. SQL Queries

The `queries/` folder contains SQL from beginner level to advanced analysis.

## Basic SQL

Covers:

* `SELECT`
* Selecting specific columns
* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`

## Filtering & Sorting

Covers:

* `WHERE`
* Comparison operators
* `BETWEEN`
* `IN`
* `NOT IN`
* `LIKE`
* `IS NULL`
* `IS NOT NULL`
* `AND`
* `OR`
* `NOT`
* `ORDER BY`
* `LIMIT`
* `DISTINCT`

## Data Modification

Covers:

* `INSERT`
* `UPDATE`
* `DELETE`
* `ALTER TABLE`
* `TRUNCATE`
* `DROP`
* Temporary tables

## SQL Functions

Covers:

### String Functions

```text
UPPER()
LOWER()
CONCAT()
LENGTH()
TRIM()
LEFT()
RIGHT()
```

### Numeric Functions

```text
ROUND()
ABS()
MOD()
```

### Date Functions

```text
CURDATE()
NOW()
YEAR()
MONTH()
DAY()
DATEDIFF()
DATE_ADD()
```

### NULL Handling

```text
COALESCE()
NULLIF()
```

---

# 📊 3. Grouping & Aggregation

The project demonstrates:

* `GROUP BY`
* Aggregate functions
* `HAVING`
* Monthly revenue
* Yearly revenue
* Product sales
* Seller performance
* Category performance

These queries turn raw database records into useful business summaries.

---

# 🔗 4. Joins

The project demonstrates different types of joins:

```text
INNER JOIN
LEFT JOIN
CROSS JOIN
SELF JOIN
```

It also includes multi-table joins involving:

```text
Customers
Products
Categories
Sellers
Orders
Order Items
Payments
Shipments
Reviews
Inventory
```

---

# 🧠 5. Subqueries

The project includes:

* Scalar subqueries
* `IN` subqueries
* `NOT IN`
* `EXISTS`
* `NOT EXISTS`
* Correlated subqueries
* Derived tables
* `ANY`
* `ALL`

Examples include finding:

* Products above average price
* Second-highest prices
* Customers spending above average
* Maximum-priced products
* Latest high-value orders

---

# 🔀 6. CASE Statements

`CASE` is used to turn database values into meaningful categories.

Examples:

```text
Stock Status
Order Status
Customer Segment
Product Profitability
Delivery Status
Price Category
```

It is also used for conditional aggregation and business classification.

---

# 🧱 7. Common Table Expressions

The project covers:

### Standard CTEs

Using:

```sql
WITH
```

for complex queries that are easier to read and maintain.

### Recursive CTEs

Used for generating:

* Number sequences
* Date ranges
* Month calendars
* Day calendars
* Week sequences
* Cumulative sequences

---

# 📈 8. Window Functions

Advanced analytical SQL includes:

```text
RANK()
DENSE_RANK()
ROW_NUMBER()
LAG()
LEAD()
NTILE()
```

Along with:

* Partitioning
* Running totals
* Moving averages
* Revenue percentages
* Ranking within categories
* Top-N analysis
* Month-over-month comparisons

---

# 🚀 9. Advanced SQL

The advanced query section combines multiple SQL concepts to solve realistic business problems.

Examples include:

* Top customers
* Top products
* Category revenue contribution
* Seller performance
* Inventory analysis
* Revenue growth
* Customer performance
* Product profitability
* Advanced ranking
* Business performance reports

---

# 👁️ 10. Views

The project includes reusable database views for commonly needed information.

Examples:

```text
vw_product_catalog
vw_customer_orders
vw_order_details
vw_customer_spending
vw_product_sales
vw_category_performance
vw_seller_performance
vw_inventory_status
vw_payment_details
vw_shipment_tracking
vw_product_reviews
vw_restock_required
vw_product_profitability
vw_monthly_revenue
```

Views make frequently used queries easier to access and maintain.

---

# ⚙️ 11. Stored Procedures

Stored procedures are used for reusable database operations.

Examples include:

```text
Get customer orders
Get product sales
Get customer spending
Get orders by status
Update product price
Update product stock
Update order status
Get sales summary
Get category sales
Get low-stock products
Add customer
Add product
```

The project also demonstrates procedures using `OUT` parameters.

---

# 🧮 12. Stored Functions

Reusable SQL functions are included for calculations such as:

```text
Customer total spending
Customer order count
Product profit
Product profit margin
Stock status
Customer segment
Order value category
Discount amount
Final price
Delivery days
Delivery status
Average customer order value
```

---

# 🔔 13. Triggers

Triggers demonstrate automatic database actions.

Examples include:

* Recording product price changes
* Recording product stock changes
* Validating product prices
* Validating product stock
* Tracking order status changes
* Synchronizing inventory
* Updating stock after order items are inserted
* Validating review ratings
* Validating payments
* Validating coupons

Audit tables are used to record important changes.

---

# 💳 14. Transactions

The project demonstrates database transaction management using:

```text
START TRANSACTION
COMMIT
ROLLBACK
SAVEPOINT
ROLLBACK TO SAVEPOINT
RELEASE SAVEPOINT
```

Transactions are demonstrated using realistic operations such as:

* Creating orders
* Adding order items
* Recording payments
* Updating inventory
* Updating shipment information

---

# 🔐 15. Database Security

The `security/` folder demonstrates basic MySQL access management.

It includes:

* Database users
* Roles
* Permissions
* `GRANT`
* `REVOKE`
* Default roles
* Account locking
* Password expiration
* Read-only access
* Application access
* Analyst access
* Admin access

Example roles include:

```text
ecommerce_admin_role
ecommerce_analyst_role
ecommerce_app_role
ecommerce_readonly_role
```

> The sample security scripts are for learning and demonstration. Replace example credentials before using them in any real environment.

---

# ⚡ 16. Query Optimization

The project demonstrates how SQL performance can be investigated and improved.

It includes:

* Single-column indexes
* Composite indexes
* `EXPLAIN`
* `EXPLAIN ANALYZE`
* `EXPLAIN FORMAT=JSON`
* `SHOW INDEX`
* `ANALYZE TABLE`

Optimization examples include:

* Using indexes effectively
* Avoiding unnecessary functions on indexed columns
* Filtering before aggregation
* Using `EXISTS`
* Comparing CTEs and correlated subqueries
* Choosing appropriate composite indexes
* Using `UNION` and `UNION ALL`
* Improving `LIKE` searches
* Checking query execution plans

---

# 📊 17. E-Commerce Analytics

The `analytics/` folder contains business-focused SQL analysis.

## Sales Analysis

Includes:

* Total sales
* Daily sales
* Monthly sales
* Yearly sales
* Top customers
* Top products
* Category performance
* Seller performance
* Repeat customers
* Discount analysis

## Customer Analysis

Includes:

* Customer spending
* Customer lifetime value
* Average order value
* Customer segmentation
* Repeat purchases
* Inactive customers
* Customer rankings
* Purchase categories
* Customer activity

## Product Analysis

Includes:

* Product sales
* Product revenue
* Product rankings
* Product profitability
* Profit margins
* Product ratings
* Best products
* Poor-performing products
* Unsold products

## Inventory Analysis

Includes:

* Current stock
* Inventory value
* Low-stock products
* Out-of-stock products
* Restocking requirements
* Inventory by category
* Inventory by seller
* Stock turnover

## Seller Analysis

Includes:

* Seller revenue
* Units sold
* Seller rankings
* Seller profit
* Product performance
* Seller inventory
* Seller ratings
* Category performance

## Revenue Analysis

Includes:

* Gross revenue
* Discounts
* Net revenue
* Profit
* Profit margin
* Monthly revenue
* Revenue growth
* Revenue contribution
* Payment analysis
* Revenue by category
* Revenue by seller
* Revenue by customer

---

# 🖼️ Project Visuals

## ER Diagram

The ER diagram provides a visual representation of the database structure and relationships.

```text
er_diagram/ecommerce_erd.png
```

## Database

A MySQL Workbench screenshot showing the database and schema.

```text
screenshots/database.png
```

## Queries

A MySQL Workbench screenshot showing SQL queries and query results.

```text
screenshots/queries.png
```

## Analytics

A MySQL Workbench screenshot showing analytical SQL and results.

```text
screenshots/analytics.png
```

---

# 🛠️ Technologies Used

* **MySQL 8.x**
* **SQL**
* **MySQL Workbench**
* Relational Database Design
* SQL Analytics
* Query Optimization

---

# ▶️ How to Run the Project

## 1. Install MySQL

Install:

* MySQL Server 8.x
* MySQL Workbench

## 2. Clone the repository

```bash
git clone https://github.com/Vivek61789/E-Commerce-SQL-Analytics-Engine.git
```

## 3. Open MySQL Workbench

Connect to your local MySQL server.

## 4. Create the database

Run:

```text
database/01_database_setup.sql
```

## 5. Create the tables

Run:

```text
database/02_tables.sql
```

## 6. Add constraints

Run:

```text
database/03_constraints.sql
```

## 7. Insert sample data

Run:

```text
database/04_sample_data.sql
```

## 8. Create indexes

Run:

```text
database/05_indexes.sql
```

## 9. Run the SQL examples

Run the files inside:

```text
queries/
```

## 10. Create database objects

Run:

```text
database_objects/
```

## 11. Explore transactions and security

Run the files inside:

```text
transactions/
security/
```

Use appropriate MySQL privileges when testing security scripts.

## 12. Explore optimization

Run:

```text
optimization/
```

## 13. Explore analytics

Run:

```text
analytics/
```

---

# 📚 Recommended Learning Order

If you are using this project to learn SQL, follow this order:

```text
1. Database Setup
2. Tables
3. Constraints
4. Sample Data
5. Basic Queries
6. Filtering & Sorting
7. Data Modification
8. Functions
9. Grouping & Aggregation
10. Joins
11. Subqueries
12. CASE Statements
13. CTEs
14. Recursive CTEs
15. Window Functions
16. Advanced Queries
17. Views
18. Stored Procedures
19. Stored Functions
20. Triggers
21. Transactions
22. Security
23. Indexes & EXPLAIN
24. Query Optimization
25. Sales Analytics
26. Customer Analytics
27. Product Analytics
28. Inventory Analytics
29. Seller Analytics
30. Revenue Analytics
```

---

# 💡 What You Can Learn From This Project

After working through the project, you will have practical experience with:

* Designing relational databases
* Creating normalized tables
* Connecting tables using foreign keys
* Writing SQL queries
* Working with real-world relationships
* Performing data analysis
* Writing complex joins
* Using subqueries and CTEs
* Performing advanced analytics with window functions
* Creating reusable database objects
* Managing transactions
* Managing database permissions
* Creating and using indexes
* Reading query execution plans
* Optimizing SQL queries
* Turning raw data into business insights

---

# 🎓 Who Is This Project For?

This project is useful for:

* SQL beginners
* Computer Science students
* Freshers preparing for interviews
* Database learners
* Data Analyst beginners
* Backend developers
* Full Stack developers
* Anyone preparing for SQL interviews

It can also be used as a **portfolio project to demonstrate practical SQL skills**.

---

# 📌 Important Note

This is a **learning and portfolio project** using sample e-commerce data.

The database structure and queries are designed to demonstrate SQL concepts in a realistic environment. They should be adapted and secured appropriately before being used in a production application.

---

# 📄 License

This project is licensed under the **MIT License**.

See the [`LICENSE`](LICENSE) file for details.

---

# 👨‍💻 Author

**Vivek Reddy**

GitHub: [Vivek61789](https://github.com/Vivek61789)

---

## ⭐ Project Goal

The goal of this project is simple:

> **Start with basic SQL and build all the way to real-world database analytics, optimization, security, and engineering using one complete e-commerce database.**

If this project helps you learn SQL, feel free to ⭐ the repository.
