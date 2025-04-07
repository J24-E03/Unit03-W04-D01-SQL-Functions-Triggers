
-- Users Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    registered_on DATE DEFAULT CURRENT_DATE
);

-- Employees Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary NUMERIC(10, 2),
    hire_date DATE
);

-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    order_date DATE DEFAULT CURRENT_DATE,
    total_price NUMERIC(10, 2)
);

-- Products Table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10, 2)
);

-- Sales Table
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INT,
    price NUMERIC(10, 2),
    sale_date DATE DEFAULT CURRENT_DATE
);



INSERT INTO users (name, email, registered_on) VALUES
('Alice Johnson', 'alice@example.com', '2024-01-10'),
('Bob Smith', 'bob@example.com', '2024-02-15'),
('Charlie Davis', 'charlie@example.com', '2024-03-05');

-- Insert Employees
INSERT INTO employees (employee_name, department, salary, hire_date) VALUES
('John Doe', 'HR', 50000, '2020-05-20'),
('Jane Smith', 'IT', 75000, '2019-07-15'),
('Mike Brown', 'Finance', 60000, '2021-09-10'),
('Sara White', 'IT', 80000, '2018-03-25');

-- Insert Orders
INSERT INTO orders (user_id, order_date, total_price) VALUES
(1, '2024-03-10', 250.50),
(2, '2024-03-12', 100.00),
(3, '2024-03-15', 75.99),
(1, '2024-03-18', 300.75);

-- Insert Products
INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1200.00),
('Phone', 'Electronics', 800.00),
('Headphones', 'Accessories', 150.00),
('Desk Chair', 'Furniture', 200.00);

-- Insert Sales
INSERT INTO sales (user_id, product_id, quantity, price, sale_date) VALUES
(1, 1, 1, 1200.00, '2024-03-10'),
(2, 2, 1, 800.00, '2024-03-12'),
(3, 3, 2, 150.00, '2024-03-15'),
(1, 4, 1, 200.00, '2024-03-18');


-- Function to calculate employee Bonuses

CREATE FUNCTION calculate_bonus(salary NUMERIC) RETURNS NUMERIC AS $$
BEGIN
  RETURN salary * 0.10; -- Bonus is 10% of salary
END;
$$ LANGUAGE plpgsql;


SELECT calculate_bonus(50000); -- Returns: 5000

UPDATE employees
SET salary = salary + calculate_bonus(salary)
WHERE employee_id = 1;


-- Setting percentage:
CREATE OR REPLACE FUNCTION calculate_bonus(salary NUMERIC, percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
  RETURN salary * percent;
END;
$$ LANGUAGE plpgsql;







-- Step 1: Create an Audit Log Table for deleted employees
CREATE TABLE employee_audit (
    employee_id INTEGER,
    name TEXT,
    department TEXT,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by TEXT
);


-- Step 2: Create a function to log deleted employees
CREATE OR REPLACE FUNCTION log_employee_deletion() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO employee_audit(employee_id, name, department, deleted_by)
  VALUES (OLD.employee_id, OLD.name, OLD.department, current_user);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;


-- Step 3: Creat the trigger
CREATE TRIGGER employee_delete_trigger
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_deletion();






