CREATE DATABASE FoodDeliveryDB;
USE FoodDeliveryDB;
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(100) UNIQUE NOT NULL,
    contact_number VARCHAR(15) UNIQUE NOT NULL,
    home_address TEXT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Dishes (
    dish_id INT PRIMARY KEY AUTO_INCREMENT,
    dish_name VARCHAR(100) NOT NULL,
    dish_category VARCHAR(50) NOT NULL,
    dish_price DECIMAL(10,2) NOT NULL CHECK (dish_price > 0),
    is_available BOOLEAN DEFAULT TRUE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Food_Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending', 'Cooking', 'Dispatched', 'Delivered') DEFAULT 'Pending',
    total_cost DECIMAL(10,2) NOT NULL CHECK (total_cost >= 0),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
CREATE TABLE Order_Details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    dish_id INT NOT NULL,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered > 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Food_Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES Dishes(dish_id) ON DELETE CASCADE
);
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_type ENUM('Cash', 'Credit Card', 'Digital Wallet') NOT NULL,
    transaction_status ENUM('Pending', 'Success', 'Failed') DEFAULT 'Pending',
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid >= 0),
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Food_Orders(order_id) ON DELETE CASCADE
);
CREATE TABLE Stock (
    stock_id INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100) NOT NULL,
    available_quantity INT NOT NULL CHECK (available_quantity >= 0),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO Users (full_name, email_address, contact_number, home_address)
VALUES ('Alice Johnson', 'alice@example.com', '9876543210', '45 Avenue, City'),
       ('Bob Smith', 'bob@example.com', '8765432109', '12 Street, Town');
INSERT INTO Dishes (dish_name, dish_category, dish_price, is_available)
VALUES ('Cheese Pizza', 'Italian', 250.00, TRUE),
       ('Chicken Biryani', 'Indian', 200.00, TRUE),
       ('Veg Burger', 'Fast Food', 100.00, TRUE);
INSERT INTO Food_Orders (user_id, total_cost)
VALUES (1, 350.00),
       (2, 200.00);
INSERT INTO Order_Details (order_id, dish_id, quantity_ordered, total_price)
VALUES (1, 1, 1, 250.00),
       (1, 3, 1, 100.00),
       (2, 2, 1, 200.00);
INSERT INTO Transactions (order_id, payment_type, transaction_status, amount_paid)
VALUES (1, 'Credit Card', 'Success', 350.00),
       (2, 'Cash', 'Success', 200.00);
INSERT INTO Stock (ingredient_name, available_quantity)
VALUES ('Flour', 50),
       ('Cheese', 30),
       ('Chicken', 20);
 SELECT f.order_id, u.full_name, u.contact_number, f.order_status, f.total_cost
FROM Food_Orders f
JOIN Users u ON f.user_id = u.user_id
WHERE f.order_status != 'Delivered';
SELECT order_id, order_time, order_status
FROM Food_Orders
WHERE order_status = 'Dispatched';
SELECT d.dish_name, SUM(od.quantity_ordered) AS total_sold
FROM Order_Details od
JOIN Dishes d ON od.dish_id = d.dish_id
GROUP BY d.dish_name
ORDER BY total_sold DESC
LIMIT 5;
DELIMITER //
CREATE PROCEDURE Compute_Total_Cost(IN orderID INT, OUT totalAmount DECIMAL)
BEGIN
    SELECT SUM(total_price) INTO totalAmount
    FROM Order_Details
    WHERE order_id = orderID;
END //
DELIMITER ;