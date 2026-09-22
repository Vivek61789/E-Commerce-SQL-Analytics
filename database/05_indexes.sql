USE ecommerce_analytics;

-- Create indexes for commonly searched customer data
CREATE INDEX idx_customers_email
ON customers(email);

CREATE INDEX idx_customers_status
ON customers(status);

-- Create indexes for product searches and filtering
CREATE INDEX idx_products_category
ON products(category_id);

CREATE INDEX idx_products_seller
ON products(seller_id);

CREATE INDEX idx_products_status
ON products(status);

-- Create indexes for order lookups and analysis
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_date
ON orders(order_date);

CREATE INDEX idx_orders_status
ON orders(order_status);

-- Create indexes for order item relationships
CREATE INDEX idx_order_items_order
ON order_items(order_id);

CREATE INDEX idx_order_items_product
ON order_items(product_id);

-- Create indexes for payment and shipment lookups
CREATE INDEX idx_payments_order
ON payments(order_id);

CREATE INDEX idx_payments_status
ON payments(payment_status);

CREATE INDEX idx_shipments_order
ON shipments(order_id);

CREATE INDEX idx_shipments_status
ON shipments(shipment_status);

-- Create indexes for product review analysis
CREATE INDEX idx_reviews_product
ON reviews(product_id);

CREATE INDEX idx_reviews_customer
ON reviews(customer_id);

CREATE INDEX idx_reviews_rating
ON reviews(rating);

-- Create indexes for coupon analysis
CREATE INDEX idx_coupon_usage_coupon
ON coupon_usage(coupon_id);

CREATE INDEX idx_coupon_usage_customer
ON coupon_usage(customer_id);

-- Create an index for inventory monitoring
CREATE INDEX idx_inventory_quantity
ON product_inventory(quantity_available);