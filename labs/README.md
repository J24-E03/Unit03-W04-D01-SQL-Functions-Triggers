## Lab: E-commerce System with Triggers and Functions

### Objective:
1. Understand the use of **functions** in PostgreSQL to encapsulate business logic.
2. Learn how to implement **triggers** to automatically perform actions in response to changes in data (e.g., after insert, update, delete).
3. Implement **audit logging** and **inventory updates** with triggers and functions.

---

### Part 1: Create Tables

Create the following tables:

1. **Products Table**
   - Store product information such as name, category, price, and stock quantity.

2. **Orders Table**
   - Track user orders, including order date and total price.

3. **Order_Items Table**
   - Track individual items in an order, linking products and orders.

4. **Deleted Products Audit Table**
   - Store audit information for products that are deleted from the system.

---

### Part 2: Insert Sample Data

Insert sample data into the tables:

```sql
-- Insert Products
INSERT INTO products (name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 1200.00, 50),
('Phone', 'Electronics', 800.00, 100),
('Headphones', 'Accessories', 150.00, 200),
('Desk Chair', 'Furniture', 200.00, 150);

-- Insert Orders
INSERT INTO orders (user_id, total_price) VALUES
(1, 2500.50),
(2, 800.00),
(3, 150.00);

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 1200.00),
(2, 2, 1, 800.00),
(3, 3, 3, 150.00);
```

---

### Part 3: Functions to Create

1. **Function to Calculate the Total Value of an Order**
   - Write a function that calculates the total value of an order based on the products and quantities in the `order_items` table.

2. **Function to Update Stock Quantities**
   - Write a function that updates the stock quantity of products in the `products` table after an order is placed, based on the items in `order_items`.

---

### Part 4: Triggers to Implement

1. **Trigger to Update the Total Price of an Order**
   - Create a trigger that automatically updates the `total_price` of an order whenever items are added to the order.

2. **Trigger to Log Deleted Products for Auditing**
   - Create a trigger that logs the details of any deleted product into the `product_audit` table whenever a product is deleted from the `products` table.

---

### Part 5: Additional Tasks

1. **Inventory Check**
   - Write a query to find out which products have a stock quantity lower than a certain threshold (e.g., less than 10 items).

2. **Sales Summary**
   - Write a query to calculate the total revenue from each product category based on the products in the `order_items` table.

