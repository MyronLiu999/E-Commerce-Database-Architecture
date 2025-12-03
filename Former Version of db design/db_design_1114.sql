-- E-Commerce Database Schema

-- Create User table

-- Country Table
CREATE TABLE Country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- State Table
CREATE TABLE State (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    tax_rate DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- City Table
CREATE TABLE City (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    state_id INT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES State(state_id)
);

-- Address Table
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    address_type VARCHAR(50) NOT NULL COMMENT,
    zip_code VARCHAR(20),
    city_id INT NOT NULL,
    street_line TEXT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);

-- User Table
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    password_hash VARCHAR(50) NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- Product Table
CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100) NOT NULL
);

-- Payment Table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_status TINYINT NOT NULL COMMENT '0-Unpaid/1-Paid',
    payment_method VARCHAR(50) NOT NULL COMMENT 'Credit Card/Bank Account',
    amount DECIMAL(10, 2) NOT NULL,
    payment_timestamp DATETIME NOT NULL
);

-- Order Table
CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_status TINYINT NOT NULL COMMENT '0-Ppdaid/1-Paid/2-Send/3-Close',
    payment_id INT NOT NULL,
    check_out_timestamp DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id)
);

-- Shipping Method Table
CREATE TABLE ShippingMethod (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL COMMENT 'Standard/Overnight/Mid-tier',
    base_cost DECIMAL(10, 2) NOT NULL
);

-- Shipping Method
CREATE TABLE Shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    shipping_method_id INT NOT NULL,
    address_id INT NOT NULL,
    delivery_timestamp DATETIME NOT NULL,
    FOREIGN KEY (shipping_method_id) REFERENCES ShippingMethod(shipping_method_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- Order Product Table
CREATE TABLE OrderProduct (
    order_product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    shipping_id INT NOT NULL,
    order_product_subtotal DECIMAL(10, 2) NOT NULL COMMENT 'Product amount + shipping fee + tax',
    order_product_status TINYINT NOT NULL COMMENT '0-Send/1-Close',
    order_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);

-- Return Product Table
CREATE TABLE Return (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_product_id INT NOT NULL,
    shipping_id INT NOT NULL,
    return_status TINYINT NOT NULL COMMENT '0-Applied/1-Approved/2-Rejected/3-Close',
    return_requested_time DATETIME NOT NULL,
    exp_return_time DATETIME,
    return_amount DECIMAL(10, 2) NOT NULL,
    return_fee DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_product_id) REFERENCES OrderProduct(order_product_id),
    FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id)
);

-- Create Inventory table
CREATE TABLE Inventory (
    -- Specification ID: Primary key, uniquely identifies each product specification (e.g., "1_XS_pink", "501_ANC_black")
    spec_id VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL COMMENT 'Available stock quantity of the specific product specification',
    PRIMARY KEY (spec_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Product inventory management table - tracks stock levels per product specification';

