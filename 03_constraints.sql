USE ecommerce_analytics;

-- Ensure customer email addresses are unique
ALTER TABLE customers
ADD CONSTRAINT uq_customers_email UNIQUE (email);

-- Ensure seller email addresses are unique
ALTER TABLE sellers
ADD CONSTRAINT uq_sellers_email UNIQUE (email);

-- Ensure category names are unique
ALTER TABLE categories
ADD CONSTRAINT uq_categories_name UNIQUE (category_name);

-- Ensure product prices cannot be negative
ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price >= 0);

-- Ensure product cost prices cannot be negative
ALTER TABLE products
ADD CONSTRAINT chk_products_cost_price CHECK (cost_price >= 0);

-- Ensure product stock cannot be negative
ALTER TABLE products
ADD CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0);

-- Connect products with categories
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id)
REFERENCES categories(category_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

-- Connect products with sellers
ALTER TABLE products
ADD CONSTRAINT fk_products_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id)
ON UPDATE CASCADE
ON DELETE SET NULL;

-- Connect inventory records with products
ALTER TABLE product_inventory
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (product_id)
REFERENCES products(product_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Prevent duplicate inventory records for the same product
ALTER TABLE product_inventory
ADD CONSTRAINT uq_inventory_product UNIQUE (product_id);

-- Connect orders with customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Ensure order totals cannot be negative
ALTER TABLE orders
ADD CONSTRAINT chk_orders_total CHECK (total_amount >= 0);

-- Connect order items with orders
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Connect order items with products
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Ensure ordered quantities are positive
ALTER TABLE order_items
ADD CONSTRAINT chk_order_items_quantity CHECK (quantity > 0);

-- Ensure item prices are not negative
ALTER TABLE order_items
ADD CONSTRAINT chk_order_items_price CHECK (unit_price >= 0);

-- Ensure item discounts are not negative
ALTER TABLE order_items
ADD CONSTRAINT chk_order_items_discount CHECK (discount_amount >= 0);

-- Connect payments with orders
ALTER TABLE payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Ensure payment amounts are positive
ALTER TABLE payments
ADD CONSTRAINT chk_payments_amount CHECK (amount > 0);

-- Prevent duplicate payment transaction references
ALTER TABLE payments
ADD CONSTRAINT uq_payments_transaction_reference UNIQUE (transaction_reference);

-- Connect shipments with orders
ALTER TABLE shipments
ADD CONSTRAINT fk_shipments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Prevent duplicate tracking numbers
ALTER TABLE shipments
ADD CONSTRAINT uq_shipments_tracking_number UNIQUE (tracking_number);

-- Connect reviews with products
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_product
FOREIGN KEY (product_id)
REFERENCES products(product_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Connect reviews with customers
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Keep product ratings between one and five
ALTER TABLE reviews
ADD CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5);

-- Prevent a customer from reviewing the same product multiple times
ALTER TABLE reviews
ADD CONSTRAINT uq_reviews_customer_product UNIQUE (customer_id, product_id);

-- Ensure coupon codes are unique
ALTER TABLE coupons
ADD CONSTRAINT uq_coupons_code UNIQUE (coupon_code);

-- Ensure coupon discount values are valid
ALTER TABLE coupons
ADD CONSTRAINT chk_coupons_discount CHECK (discount_value >= 0);

-- Ensure coupon minimum order amounts are valid
ALTER TABLE coupons
ADD CONSTRAINT chk_coupons_minimum_order CHECK (minimum_order_amount >= 0);

-- Ensure coupon dates are valid
ALTER TABLE coupons
ADD CONSTRAINT chk_coupons_dates CHECK (end_date >= start_date);

-- Connect coupon usage with coupons
ALTER TABLE coupon_usage
ADD CONSTRAINT fk_coupon_usage_coupon
FOREIGN KEY (coupon_id)
REFERENCES coupons(coupon_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Connect coupon usage with orders
ALTER TABLE coupon_usage
ADD CONSTRAINT fk_coupon_usage_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Connect coupon usage with customers
ALTER TABLE coupon_usage
ADD CONSTRAINT fk_coupon_usage_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Ensure coupon discounts are not negative
ALTER TABLE coupon_usage
ADD CONSTRAINT chk_coupon_usage_discount CHECK (discount_amount >= 0);

-- Ensure employee emails are unique
ALTER TABLE employees
ADD CONSTRAINT uq_employees_email UNIQUE (email);

-- Ensure employee salaries cannot be negative
ALTER TABLE employees
ADD CONSTRAINT chk_employees_salary CHECK (salary >= 0);

-- Connect product audit records with products
ALTER TABLE product_audit
ADD CONSTRAINT fk_product_audit_product
FOREIGN KEY (product_id)
REFERENCES products(product_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Connect order audit records with orders
ALTER TABLE order_audit
ADD CONSTRAINT fk_order_audit_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON UPDATE CASCADE
ON DELETE CASCADE;