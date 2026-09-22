USE ecommerce_analytics;

-- Insert customer records
INSERT INTO customers
(first_name, last_name, email, phone, date_of_birth, gender, registration_date, status)
VALUES
('Arjun', 'Reddy', 'arjun.reddy@email.com', '9876543210', '2000-05-14', 'Male', '2024-01-15 10:30:00', 'Active'),
('Priya', 'Sharma', 'priya.sharma@email.com', '9876543211', '1999-08-22', 'Female', '2024-02-10 14:20:00', 'Active'),
('Rahul', 'Kumar', 'rahul.kumar@email.com', '9876543212', '2001-03-18', 'Male', '2024-02-25 09:15:00', 'Active'),
('Sneha', 'Rao', 'sneha.rao@email.com', '9876543213', '2000-11-05', 'Female', '2024-03-12 16:45:00', 'Active'),
('Vikram', 'Singh', 'vikram.singh@email.com', '9876543214', '1998-07-30', 'Male', '2024-03-20 11:10:00', 'Active'),
('Ananya', 'Patel', 'ananya.patel@email.com', '9876543215', '2002-01-12', 'Female', '2024-04-05 13:25:00', 'Active'),
('Karthik', 'Nair', 'karthik.nair@email.com', '9876543216', '1999-12-08', 'Male', '2024-04-18 10:00:00', 'Active'),
('Meera', 'Iyer', 'meera.iyer@email.com', '9876543217', '2001-06-21', 'Female', '2024-05-02 15:30:00', 'Active'),
('Rohit', 'Verma', 'rohit.verma@email.com', '9876543218', '1997-09-16', 'Male', '2024-05-19 12:40:00', 'Active'),
('Divya', 'Menon', 'divya.menon@email.com', '9876543219', '2000-04-27', 'Female', '2024-06-01 09:50:00', 'Active');

-- Insert seller records
INSERT INTO sellers
(seller_name, email, phone, registration_date, status)
VALUES
('TechWorld India', 'sales@techworld.in', '9000000001', '2023-10-01 09:00:00', 'Active'),
('Fashion Hub', 'contact@fashionhub.in', '9000000002', '2023-10-15 10:30:00', 'Active'),
('Home Essentials', 'support@homeessentials.in', '9000000003', '2023-11-05 11:00:00', 'Active'),
('Sports Arena', 'sales@sportsarena.in', '9000000004', '2023-11-20 14:15:00', 'Active'),
('Book World', 'contact@bookworld.in', '9000000005', '2023-12-10 16:00:00', 'Active');

-- Insert product categories
INSERT INTO categories
(category_name, description, status)
VALUES
('Electronics', 'Electronic devices and accessories', 'Active'),
('Fashion', 'Clothing and fashion accessories', 'Active'),
('Home & Kitchen', 'Home appliances and kitchen products', 'Active'),
('Sports', 'Sports equipment and accessories', 'Active'),
('Books', 'Books and educational materials', 'Active');

-- Insert product records
INSERT INTO products
(product_name, category_id, seller_id, description, price, cost_price, stock_quantity, status)
VALUES
('Wireless Headphones', 1, 1, 'Bluetooth wireless headphones', 2499.00, 1600.00, 100, 'Active'),
('Mechanical Keyboard', 1, 1, 'RGB mechanical gaming keyboard', 3499.00, 2200.00, 75, 'Active'),
('Smart Watch', 1, 1, 'Fitness and notification smartwatch', 4999.00, 3200.00, 60, 'Active'),
('USB-C Charger', 1, 1, 'Fast charging USB-C adapter', 999.00, 550.00, 150, 'Active'),
('Men Casual Shirt', 2, 2, 'Cotton casual shirt', 1299.00, 700.00, 120, 'Active'),
('Women Handbag', 2, 2, 'Premium leather handbag', 2999.00, 1700.00, 50, 'Active'),
('Running Shoes', 4, 4, 'Lightweight running shoes', 3999.00, 2400.00, 80, 'Active'),
('Yoga Mat', 4, 4, 'Non-slip fitness yoga mat', 899.00, 450.00, 200, 'Active'),
('Coffee Maker', 3, 3, 'Automatic home coffee maker', 5499.00, 3500.00, 40, 'Active'),
('Non-Stick Cookware Set', 3, 3, 'Five-piece cookware set', 4299.00, 2700.00, 45, 'Active'),
('Python Programming', 5, 5, 'Python programming guide', 799.00, 450.00, 100, 'Active'),
('Database Systems', 5, 5, 'Relational database fundamentals', 999.00, 600.00, 70, 'Active'),
('Data Structures', 5, 5, 'Data structures and algorithms', 899.00, 500.00, 90, 'Active'),
('Bluetooth Speaker', 1, 1, 'Portable wireless speaker', 1999.00, 1200.00, 110, 'Active'),
('Sports Water Bottle', 4, 4, 'Insulated sports bottle', 699.00, 350.00, 180, 'Active');

-- Insert inventory records
INSERT INTO product_inventory
(product_id, quantity_available, reorder_level, last_restocked_at)
VALUES
(1, 100, 20, '2024-06-01 09:00:00'),
(2, 75, 15, '2024-06-02 10:00:00'),
(3, 60, 10, '2024-06-03 11:00:00'),
(4, 150, 30, '2024-06-04 09:30:00'),
(5, 120, 25, '2024-06-05 12:00:00'),
(6, 50, 10, '2024-06-06 14:00:00'),
(7, 80, 15, '2024-06-07 10:30:00'),
(8, 200, 40, '2024-06-08 11:15:00'),
(9, 40, 8, '2024-06-09 13:00:00'),
(10, 45, 10, '2024-06-10 15:00:00'),
(11, 100, 20, '2024-06-11 09:45:00'),
(12, 70, 15, '2024-06-12 10:20:00'),
(13, 90, 18, '2024-06-13 11:30:00'),
(14, 110, 22, '2024-06-14 14:00:00'),
(15, 180, 35, '2024-06-15 16:00:00');

-- Insert customer orders
INSERT INTO orders
(customer_id, order_date, total_amount, order_status, shipping_address)
VALUES
(1, '2024-06-15 10:30:00', 5998.00, 'Delivered', 'Hyderabad, Telangana'),
(2, '2024-06-16 14:20:00', 4298.00, 'Delivered', 'Bengaluru, Karnataka'),
(3, '2024-06-18 09:45:00', 4999.00, 'Delivered', 'Chennai, Tamil Nadu'),
(1, '2024-06-20 16:10:00', 1299.00, 'Delivered', 'Hyderabad, Telangana'),
(4, '2024-06-22 11:30:00', 8498.00, 'Shipped', 'Pune, Maharashtra'),
(5, '2024-06-24 13:15:00', 3999.00, 'Delivered', 'Mumbai, Maharashtra'),
(6, '2024-06-26 15:40:00', 5499.00, 'Processing', 'Ahmedabad, Gujarat'),
(7, '2024-06-28 10:00:00', 1898.00, 'Delivered', 'Kochi, Kerala'),
(8, '2024-07-01 12:25:00', 9998.00, 'Delivered', 'Chennai, Tamil Nadu'),
(9, '2024-07-03 17:00:00', 1999.00, 'Cancelled', 'Delhi, Delhi'),
(10, '2024-07-05 09:20:00', 2999.00, 'Delivered', 'Hyderabad, Telangana'),
(2, '2024-07-07 14:45:00', 4298.00, 'Delivered', 'Bengaluru, Karnataka'),
(3, '2024-07-10 11:15:00', 2597.00, 'Shipped', 'Chennai, Tamil Nadu'),
(5, '2024-07-12 16:30:00', 6998.00, 'Delivered', 'Mumbai, Maharashtra'),
(1, '2024-07-15 10:50:00', 5499.00, 'Processing', 'Hyderabad, Telangana');

-- Insert order items
INSERT INTO order_items
(order_id, product_id, quantity, unit_price, discount_amount)
VALUES
(1, 1, 1, 2499.00, 0.00),
(1, 2, 1, 3499.00, 0.00),
(2, 10, 1, 4299.00, 1.00),
(3, 3, 1, 4999.00, 0.00),
(4, 5, 1, 1299.00, 0.00),
(5, 6, 1, 2999.00, 0.00),
(5, 7, 1, 3999.00, 500.00),
(6, 7, 1, 3999.00, 0.00),
(7, 9, 1, 5499.00, 0.00),
(8, 8, 1, 899.00, 0.00),
(8, 15, 1, 699.00, 0.00),
(9, 3, 1, 4999.00, 0.00),
(9, 9, 1, 5499.00, 500.00),
(10, 14, 1, 1999.00, 0.00),
(11, 6, 1, 2999.00, 0.00),
(12, 10, 1, 4299.00, 1.00),
(13, 11, 1, 799.00, 0.00),
(13, 13, 2, 899.00, 0.00),
(14, 7, 1, 3999.00, 0.00),
(14, 1, 1, 2499.00, 0.00),
(14, 15, 1, 699.00, 199.00),
(15, 9, 1, 5499.00, 0.00);

-- Insert payment records
INSERT INTO payments
(order_id, payment_date, payment_method, amount, payment_status, transaction_reference)
VALUES
(1, '2024-06-15 10:35:00', 'UPI', 5998.00, 'Completed', 'TXN100001'),
(2, '2024-06-16 14:25:00', 'Card', 4298.00, 'Completed', 'TXN100002'),
(3, '2024-06-18 09:50:00', 'UPI', 4999.00, 'Completed', 'TXN100003'),
(4, '2024-06-20 16:15:00', 'Cash', 1299.00, 'Completed', 'TXN100004'),
(5, '2024-06-22 11:35:00', 'Card', 8498.00, 'Completed', 'TXN100005'),
(6, '2024-06-24 13:20:00', 'UPI', 3999.00, 'Completed', 'TXN100006'),
(7, '2024-06-26 15:45:00', 'Card', 5499.00, 'Pending', 'TXN100007'),
(8, '2024-06-28 10:05:00', 'UPI', 1898.00, 'Completed', 'TXN100008'),
(9, '2024-07-01 12:30:00', 'Card', 9998.00, 'Completed', 'TXN100009'),
(10, '2024-07-03 17:05:00', 'UPI', 1999.00, 'Refunded', 'TXN100010'),
(11, '2024-07-05 09:25:00', 'Card', 2999.00, 'Completed', 'TXN100011'),
(12, '2024-07-07 14:50:00', 'UPI', 4298.00, 'Completed', 'TXN100012'),
(13, '2024-07-10 11:20:00', 'Card', 2597.00, 'Completed', 'TXN100013'),
(14, '2024-07-12 16:35:00', 'UPI', 6998.00, 'Completed', 'TXN100014'),
(15, '2024-07-15 10:55:00', 'Card', 5499.00, 'Pending', 'TXN100015');

-- Insert shipment records
INSERT INTO shipments
(order_id, tracking_number, courier_name, shipped_date, estimated_delivery_date, delivered_date, shipment_status)
VALUES
(1, 'TRK100001', 'BlueDart', '2024-06-16', '2024-06-19', '2024-06-18', 'Delivered'),
(2, 'TRK100002', 'Delhivery', '2024-06-17', '2024-06-20', '2024-06-20', 'Delivered'),
(3, 'TRK100003', 'DTDC', '2024-06-19', '2024-06-22', '2024-06-21', 'Delivered'),
(4, 'TRK100004', 'BlueDart', '2024-06-21', '2024-06-24', '2024-06-23', 'Delivered'),
(5, 'TRK100005', 'Delhivery', '2024-06-23', '2024-06-27', NULL, 'In Transit'),
(6, 'TRK100006', 'DTDC', '2024-06-25', '2024-06-28', '2024-06-27', 'Delivered'),
(7, 'TRK100007', 'BlueDart', NULL, '2024-06-30', NULL, 'Processing'),
(8, 'TRK100008', 'Delhivery', '2024-06-29', '2024-07-02', '2024-07-01', 'Delivered'),
(9, 'TRK100009', 'DTDC', '2024-07-02', '2024-07-05', '2024-07-04', 'Delivered'),
(10, 'TRK100010', 'BlueDart', NULL, '2024-07-07', NULL, 'Cancelled'),
(11, 'TRK100011', 'Delhivery', '2024-07-06', '2024-07-09', '2024-07-08', 'Delivered'),
(12, 'TRK100012', 'DTDC', '2024-07-08', '2024-07-11', '2024-07-10', 'Delivered'),
(13, 'TRK100013', 'BlueDart', '2024-07-11', '2024-07-14', NULL, 'In Transit'),
(14, 'TRK100014', 'Delhivery', '2024-07-13', '2024-07-16', '2024-07-15', 'Delivered'),
(15, 'TRK100015', 'DTDC', NULL, '2024-07-18', NULL, 'Processing');

-- Insert product reviews
INSERT INTO reviews
(product_id, customer_id, rating, review_text, review_date)
VALUES
(1, 1, 5, 'Excellent sound quality and battery life.', '2024-06-20 18:00:00'),
(2, 1, 4, 'Good keyboard with responsive keys.', '2024-06-21 19:00:00'),
(10, 2, 4, 'Good cookware quality.', '2024-06-25 17:30:00'),
(3, 3, 5, 'Very useful smartwatch with good features.', '2024-06-25 20:00:00'),
(5, 1, 4, 'Comfortable and good quality shirt.', '2024-06-27 15:00:00'),
(7, 5, 5, 'Great shoes for running.', '2024-06-29 18:30:00'),
(9, 6, 4, 'Makes good coffee and easy to use.', '2024-07-02 16:00:00'),
(8, 7, 5, 'Very comfortable yoga mat.', '2024-07-03 14:00:00'),
(15, 7, 4, 'Keeps water cold for a long time.', '2024-07-04 12:00:00'),
(6, 10, 5, 'Stylish and spacious handbag.', '2024-07-09 19:30:00');

-- Insert coupon records
INSERT INTO coupons
(coupon_code, discount_type, discount_value, minimum_order_amount, start_date, end_date, usage_limit, status)
VALUES
('WELCOME10', 'Percentage', 10.00, 1000.00, '2024-01-01', '2024-12-31', 1000, 'Active'),
('SAVE500', 'Fixed', 500.00, 5000.00, '2024-01-01', '2024-12-31', 500, 'Active'),
('FESTIVE15', 'Percentage', 15.00, 3000.00, '2024-06-01', '2024-08-31', 300, 'Active'),
('NEWUSER20', 'Percentage', 20.00, 2000.00, '2024-06-01', '2024-09-30', 200, 'Active'),
('BOOK100', 'Fixed', 100.00, 500.00, '2024-05-01', '2024-12-31', 500, 'Active');

-- Insert coupon usage records
INSERT INTO coupon_usage
(coupon_id, order_id, customer_id, discount_amount, used_at)
VALUES
(1, 1, 1, 599.80, '2024-06-15 10:30:00'),
(2, 5, 4, 500.00, '2024-06-22 11:30:00'),
(3, 9, 8, 1499.70, '2024-07-01 12:25:00'),
(4, 11, 10, 599.80, '2024-07-05 09:20:00'),
(5, 13, 3, 100.00, '2024-07-10 11:15:00');

-- Insert employee records
INSERT INTO employees
(first_name, last_name, email, department, job_title, hire_date, salary, status)
VALUES
('Amit', 'Shah', 'amit.shah@ecommerce.com', 'Management', 'Operations Manager', '2022-01-10', 85000.00, 'Active'),
('Neha', 'Kapoor', 'neha.kapoor@ecommerce.com', 'Sales', 'Sales Executive', '2022-04-15', 55000.00, 'Active'),
('Suresh', 'Rao', 'suresh.rao@ecommerce.com', 'Technology', 'Database Administrator', '2021-08-20', 95000.00, 'Active'),
('Pooja', 'Reddy', 'pooja.reddy@ecommerce.com', 'Customer Support', 'Support Executive', '2023-02-12', 45000.00, 'Active'),
('Manish', 'Verma', 'manish.verma@ecommerce.com', 'Logistics', 'Logistics Coordinator', '2023-06-05', 50000.00, 'Active');

-- Insert initial product audit records
INSERT INTO product_audit
(product_id, action_type, old_price, new_price, old_stock, new_stock, changed_at)
VALUES
(1, 'PRICE_UPDATE', 2299.00, 2499.00, 120, 100, '2024-06-01 09:00:00'),
(3, 'STOCK_UPDATE', 4999.00, 4999.00, 80, 60, '2024-06-03 11:00:00'),
(7, 'PRICE_UPDATE', 3799.00, 3999.00, 90, 80, '2024-06-07 10:30:00');

-- Insert initial order audit records
INSERT INTO order_audit
(order_id, old_status, new_status, changed_at)
VALUES
(1, 'Processing', 'Shipped', '2024-06-16 09:00:00'),
(1, 'Shipped', 'Delivered', '2024-06-18 17:00:00'),
(2, 'Processing', 'Shipped', '2024-06-17 10:00:00'),
(2, 'Shipped', 'Delivered', '2024-06-20 16:00:00'),
(5, 'Processing', 'Shipped', '2024-06-23 09:30:00');