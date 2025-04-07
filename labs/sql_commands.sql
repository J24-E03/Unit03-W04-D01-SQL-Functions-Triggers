-- Part 1: Create Tables
-- Products Table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL
);

-- Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT
);

-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_price DECIMAL(10, 2) NOT NULL
);

-- Order_Items Table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE SET NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Deleted Products Audit Table
CREATE TABLE deleted_products_audit (
    audit_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_by TEXT

);

-- Part 2: Insert Sample Data
-- Insert Users
INSERT INTO users (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Elm St, Springfield, IL'),
('Jane', 'Smith', 'jane.smith@example.com', '987-654-3210', '456 Oak St, Springfield, IL'),
('Mike', 'Brown', 'mike.brown@example.com', '555-123-4567', '789 Pine St, Springfield, IL');

-- Insert Products (Already provided)
INSERT INTO products (name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 1200.00, 50),
('Phone', 'Electronics', 800.00, 100),
('Headphones', 'Accessories', 150.00, 200),
('Desk Chair', 'Furniture', 200.00, 150);

-- Insert Orders (Already provided)
INSERT INTO orders (user_id, total_price) VALUES
(1, 2500.50),
(2, 800.00),
(3, 150.00);

-- Insert Order Items (Already provided)
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 1200.00),
(2, 2, 1, 800.00),
(3, 3, 3, 150.00);

-- Part 3: Functions to Create
-- 1.Function to Calculate the Total Value of an Order
CREATE OR REPLACE FUNCTION calculate_total_order_value (oder_id INT) RETURNS DECIMAL(10,2) AS $$
DECLARE
    total_value DECIMAL(10, 2);
BEGIN
	SELECT SUM (oi.quantity * oi.price)
	INTO total_value
	FROM order_items oi
	WHERE oi.order_id = order_id;

	RETURN total_value;
END;
$$ LANGUAGE plpgsql;

SELECT calculate_total_order_value(1);

-- 2. Function to Update Stock Quantities
CREATE OR REPLACE FUNCTION update_stock_quantities(poid INT) RETURNS VOID AS $$
BEGIN
    UPDATE products p
    SET stock_quantity = stock_quantity - oi.quantity
    FROM order_items oi
    WHERE oi.order_id = poid
    AND oi.product_id = p.product_id;
END;
$$ LANGUAGE plpgsql;

-- Part 4: Triggers to Implement
-- 1. Trigger to Update the Total Price of an Order
CREATE OR REPLACE FUNCTION update_order_total_price_using_function() RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total_price = calculate_total_order_value(NEW.order_id)
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_total_price_after_insert
AFTER INSERT OR UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total_price_using_function();

-- 2. Trigger to Log Deleted Products for Auditing
CREATE OR REPLACE FUNCTION log_deleted_product() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO deleted_products_audit (product_id, deleted_at, deleted_by)
    VALUES (OLD.product_id, CURRENT_TIMESTAMP, CURRENT_USER); 
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_deleted_product_trigger
AFTER DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION log_deleted_product();

-- Part 5: Additional Tasks
-- 1. Inventory Check
SELECT product_id, name, category, stock_quantity
FROM products
WHERE stock_quantity < 100;

-- 2. Sales Summary
SELECT p.category, SUM (oi.quantity * oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category;
