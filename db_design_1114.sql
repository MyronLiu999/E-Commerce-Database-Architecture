-- E-Commerce Database Schema

-- Create User table
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    address_id INT
);

-- Create Address table
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_type VARCHAR(50),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Create PaymentMethod table
CREATE TABLE PaymentMethod (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Create Product table
CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100) NOT NULL
);

-- Create Inventory table
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity_available INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Order table
CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Create OrderProduct table
CREATE TABLE OrderProduct (
    order_product_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    order_product_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Payment table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(50),
    payment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (payment_method_id) REFERENCES PaymentMethod(payment_method_id)
);

-- Create ShippingMethod table
CREATE TABLE ShippingMethod (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL,
    base_cost DECIMAL(10, 2) NOT NULL
);

-- Create Shipping table
CREATE TABLE Shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    return_id INT,
    shipping_method_id INT NOT NULL,
    tracking_number VARCHAR(255),
    shipping_type VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (shipping_method_id) REFERENCES ShippingMethod(shipping_method_id)
);

-- Create Return table
CREATE TABLE `Return` (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_product_id INT NOT NULL,
    return_reason VARCHAR(255),
    return_status VARCHAR(50),
    return_requested_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    return_received_time TIMESTAMP NULL,
    FOREIGN KEY (order_product_id) REFERENCES OrderProduct(order_product_id)
);

-- Add foreign key for Shipping.return_id after Return table exists
ALTER TABLE Shipping
    ADD FOREIGN KEY (return_id) REFERENCES `Return`(return_id);

-- Create Refund table
CREATE TABLE Refund (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    return_id INT NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_status VARCHAR(50),
    FOREIGN KEY (return_id) REFERENCES `Return`(return_id)
);